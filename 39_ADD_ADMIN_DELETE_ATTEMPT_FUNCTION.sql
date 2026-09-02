-- Order 39: Administrator delete-test function
-- Run once in the Supabase SQL Editor after the existing GISP-E database setup.
-- Deletes ONE exam_attempts row by its unique attempt ID after validating the admin session.
-- It does not delete or modify the student record or any other exam attempts.

create or replace function public.admin_delete_attempt(p_token uuid, p_attempt_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_id uuid;
begin
  if not exists (
    select 1 from public.admin_sessions
    where token = p_token and expires_at > now()
  ) then
    raise exception 'Invalid admin session';
  end if;

  delete from public.exam_attempts
  where id = p_attempt_id
  returning id into deleted_id;

  if deleted_id is null then
    return jsonb_build_object('ok', false, 'message', 'Exam attempt was not found or was already deleted.');
  end if;

  return jsonb_build_object('ok', true, 'attempt_id', deleted_id);
end
$$;

grant execute on function public.admin_delete_attempt(uuid, uuid) to anon, authenticated;
