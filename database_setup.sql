-- GISP-E / PreGISP simple-login central progress database
-- Run this entire script once in Supabase Dashboard -> SQL Editor.
-- IMPORTANT: Before running, replace CHANGE-ME-ADMIN-PIN below with the admin PIN you want.

create extension if not exists pgcrypto;

create table if not exists public.program_students (
  id uuid primary key default gen_random_uuid(),
  username text not null unique,
  pin_hash text not null,
  display_name text not null,
  cohort text default '',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.student_sessions (
  token uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.program_students(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '365 days')
);

create table if not exists public.exam_attempts (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.program_students(id) on delete cascade,
  exam_version integer not null check (exam_version between 1 and 6),
  completed_at timestamptz not null,
  raw_correct integer not null check (raw_correct between 0 and 75),
  raw_percent numeric(5,2) not null,
  weighted_score numeric(5,2) not null,
  domains jsonb not null default '{}'::jsonb,
  remediation jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists exam_attempts_student_completed_idx
on public.exam_attempts(student_id, completed_at desc);

create table if not exists public.app_settings (
  key text primary key,
  value text not null
);

insert into public.app_settings(key,value)
values ('admin_pin_hash', encode(digest('B1s0n_1846','sha256'),'hex'))
on conflict (key) do update set value=excluded.value;

create table if not exists public.admin_sessions (
  token uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 days')
);

alter table public.program_students enable row level security;
alter table public.student_sessions enable row level security;
alter table public.exam_attempts enable row level security;
alter table public.app_settings enable row level security;
alter table public.admin_sessions enable row level security;

revoke all on public.program_students, public.student_sessions, public.exam_attempts, public.app_settings, public.admin_sessions from anon, authenticated;

create or replace function public.student_login(p_username text, p_pin text)
returns jsonb
language plpgsql security definer set search_path=public
as $$
declare s public.program_students; t uuid;
begin
  select * into s from public.program_students
   where lower(username)=lower(trim(p_username))
     and pin_hash=encode(digest(p_pin,'sha256'),'hex')
     and active=true;
  if not found then return jsonb_build_object('ok',false,'message','Invalid username or PIN.'); end if;
  insert into public.student_sessions(student_id) values(s.id) returning token into t;
  return jsonb_build_object('ok',true,'token',t,'student_id',s.id,'username',s.username,'display_name',s.display_name,'cohort',s.cohort);
end $$;

create or replace function public.student_session_profile(p_token uuid)
returns jsonb
language plpgsql security definer set search_path=public
as $$
declare s public.program_students;
begin
  select ps.* into s
  from public.student_sessions ss join public.program_students ps on ps.id=ss.student_id
  where ss.token=p_token and ss.expires_at>now() and ps.active=true;
  if not found then return jsonb_build_object('ok',false); end if;
  return jsonb_build_object('ok',true,'student_id',s.id,'username',s.username,'display_name',s.display_name,'cohort',s.cohort);
end $$;

create or replace function public.student_attempts(p_token uuid)
returns table(
  id uuid, exam_version integer, completed_at timestamptz, raw_correct integer,
  raw_percent numeric, weighted_score numeric, domains jsonb, remediation jsonb
)
language plpgsql security definer set search_path=public
as $$
begin
  return query
  select ea.id,ea.exam_version,ea.completed_at,ea.raw_correct,ea.raw_percent,ea.weighted_score,ea.domains,ea.remediation
  from public.exam_attempts ea
  where ea.student_id=(select ss.student_id from public.student_sessions ss where ss.token=p_token and ss.expires_at>now())
  order by ea.completed_at asc;
end $$;

create or replace function public.student_save_attempt(
  p_token uuid, p_exam_version integer, p_completed_at timestamptz,
  p_raw_correct integer, p_raw_percent numeric, p_weighted_score numeric,
  p_domains jsonb, p_remediation jsonb
)
returns uuid
language plpgsql security definer set search_path=public
as $$
declare sid uuid; aid uuid;
begin
  select ss.student_id into sid from public.student_sessions ss
  join public.program_students ps on ps.id=ss.student_id
  where ss.token=p_token and ss.expires_at>now() and ps.active=true;
  if sid is null then raise exception 'Invalid or expired student session'; end if;
  insert into public.exam_attempts(student_id,exam_version,completed_at,raw_correct,raw_percent,weighted_score,domains,remediation)
  values(sid,p_exam_version,p_completed_at,p_raw_correct,p_raw_percent,p_weighted_score,coalesce(p_domains,'{}'::jsonb),coalesce(p_remediation,'[]'::jsonb))
  returning id into aid;
  return aid;
end $$;

create or replace function public.student_logout(p_token uuid)
returns boolean language plpgsql security definer set search_path=public
as $$ begin delete from public.student_sessions where token=p_token; return true; end $$;

create or replace function public.admin_login(p_pin text)
returns jsonb
language plpgsql security definer set search_path=public
as $$
declare expected text; t uuid;
begin
  select value into expected from public.app_settings where key='admin_pin_hash';
  if expected is null or expected<>encode(digest(p_pin,'sha256'),'hex') then
    return jsonb_build_object('ok',false,'message','Invalid administrator PIN.');
  end if;
  insert into public.admin_sessions default values returning token into t;
  return jsonb_build_object('ok',true,'token',t);
end $$;

create or replace function public.admin_session_valid(p_token uuid)
returns jsonb language plpgsql security definer set search_path=public
as $$ begin
  if exists(select 1 from public.admin_sessions where token=p_token and expires_at>now())
    then return jsonb_build_object('ok',true);
    else return jsonb_build_object('ok',false);
  end if;
end $$;

create or replace function public.admin_students(p_token uuid)
returns table(id uuid, username text, display_name text, cohort text, active boolean, created_at timestamptz)
language plpgsql security definer set search_path=public
as $$
begin
  if not exists(select 1 from public.admin_sessions where token=p_token and expires_at>now()) then raise exception 'Invalid admin session'; end if;
  return query select s.id,s.username,s.display_name,s.cohort,s.active,s.created_at from public.program_students s order by s.display_name,s.username;
end $$;

create or replace function public.admin_attempts(p_token uuid)
returns table(id uuid, student_id uuid, exam_version integer, completed_at timestamptz, raw_correct integer, raw_percent numeric, weighted_score numeric, domains jsonb, remediation jsonb)
language plpgsql security definer set search_path=public
as $$
begin
  if not exists(select 1 from public.admin_sessions where token=p_token and expires_at>now()) then raise exception 'Invalid admin session'; end if;
  return query select e.id,e.student_id,e.exam_version,e.completed_at,e.raw_correct,e.raw_percent,e.weighted_score,e.domains,e.remediation from public.exam_attempts e order by e.completed_at asc;
end $$;

create or replace function public.admin_create_student(p_token uuid,p_username text,p_pin text,p_display_name text,p_cohort text default '')
returns jsonb
language plpgsql security definer set search_path=public
as $$
declare sid uuid;
begin
  if not exists(select 1 from public.admin_sessions where token=p_token and expires_at>now()) then raise exception 'Invalid admin session'; end if;
  insert into public.program_students(username,pin_hash,display_name,cohort)
  values(lower(trim(p_username)),encode(digest(p_pin,'sha256'),'hex'),trim(p_display_name),coalesce(trim(p_cohort),''))
  returning id into sid;
  return jsonb_build_object('ok',true,'student_id',sid);
exception when unique_violation then
  return jsonb_build_object('ok',false,'message','That username already exists.');
end $$;

create or replace function public.admin_reset_student_pin(p_token uuid,p_student_id uuid,p_new_pin text)
returns jsonb language plpgsql security definer set search_path=public
as $$
begin
  if not exists(select 1 from public.admin_sessions where token=p_token and expires_at>now()) then raise exception 'Invalid admin session'; end if;
  update public.program_students set pin_hash=encode(digest(p_new_pin,'sha256'),'hex') where id=p_student_id;
  delete from public.student_sessions where student_id=p_student_id;
  return jsonb_build_object('ok',true);
end $$;

create or replace function public.admin_set_student_active(p_token uuid,p_student_id uuid,p_active boolean)
returns jsonb language plpgsql security definer set search_path=public
as $$
begin
  if not exists(select 1 from public.admin_sessions where token=p_token and expires_at>now()) then raise exception 'Invalid admin session'; end if;
  update public.program_students set active=p_active where id=p_student_id;
  if p_active=false then delete from public.student_sessions where student_id=p_student_id; end if;
  return jsonb_build_object('ok',true);
end $$;

grant execute on function public.student_login(text,text) to anon, authenticated;
grant execute on function public.student_session_profile(uuid) to anon, authenticated;
grant execute on function public.student_attempts(uuid) to anon, authenticated;
grant execute on function public.student_save_attempt(uuid,integer,timestamptz,integer,numeric,numeric,jsonb,jsonb) to anon, authenticated;
grant execute on function public.student_logout(uuid) to anon, authenticated;
grant execute on function public.admin_login(text) to anon, authenticated;
grant execute on function public.admin_session_valid(uuid) to anon, authenticated;
grant execute on function public.admin_students(uuid) to anon, authenticated;
grant execute on function public.admin_attempts(uuid) to anon, authenticated;
grant execute on function public.admin_create_student(uuid,text,text,text,text) to anon, authenticated;
grant execute on function public.admin_reset_student_pin(uuid,uuid,text) to anon, authenticated;
grant execute on function public.admin_set_student_active(uuid,uuid,boolean) to anon, authenticated;
