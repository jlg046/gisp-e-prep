-- ORDER 37: Add administrator function to move an existing student between cohorts.
-- Safe for existing exam history: exam_attempts are linked to program_students.id, not cohort text.
-- Run once in Supabase SQL Editor before deploying the Order 37 dashboard/db.js files.

create or replace function public.admin_update_student_cohort(p_token uuid,p_student_id uuid,p_cohort text default '')
returns jsonb
language plpgsql security definer set search_path=public
as $$
begin
  if not exists(select 1 from public.admin_sessions where token=p_token and expires_at>now()) then
    raise exception 'Invalid admin session';
  end if;

  update public.program_students
  set cohort=coalesce(trim(p_cohort),'')
  where id=p_student_id;

  if not found then
    return jsonb_build_object('ok',false,'message','Student not found.');
  end if;

  return jsonb_build_object('ok',true,'student_id',p_student_id,'cohort',coalesce(trim(p_cohort),''));
end $$;

grant execute on function public.admin_update_student_cohort(uuid,uuid,text) to anon,authenticated;
