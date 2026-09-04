-- ORDER 50: expand the existing 18-exam GISP-E database to 38 tracked practice forms.
-- Run this ONCE in Supabase SQL Editor before students submit the new GISCI Companion exams.
-- Existing students, sessions, and exam attempts are preserved.

alter table public.exam_attempts drop constraint if exists exam_attempts_exam_version_check;
alter table public.exam_attempts add constraint exam_attempts_exam_version_check
  check (exam_version between 1 and 38);

alter table public.exam_attempts drop constraint if exists exam_attempts_exam_set_check;
alter table public.exam_attempts add constraint exam_attempts_exam_set_check
  check (exam_set between 1 and 10);

alter table public.exam_attempts drop constraint if exists exam_attempts_difficulty_code_check;
alter table public.exam_attempts add constraint exam_attempts_difficulty_code_check
  check (difficulty_code in ('A','B','C','CAL','ADV'));

-- New version IDs:
-- 19-28 = Advanced / Over-Preparation Exams 1-10
-- 29-38 = Calibrated / Right-Sized Exams 1-10
-- exam_set remains 1-10 within each new series; difficulty_code distinguishes the series.
