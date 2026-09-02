ORDER 37 — COHORT ANALYTICS + STUDENT COHORT MANAGEMENT

This full website package is based on Order 36 and retains the 18-exam skip-question behavior and 120-minute countdown/auto-submit update.

What changed
- Administrator dashboard now has an All Cohorts / individual cohort selector.
- KPI metrics, support priorities, student progress, mastery matrix, and recent submissions follow the selected cohort.
- All Cohorts view includes a cohort-comparison table with active students, baseline counts/averages, latest averages, average change, weighted mastery, and total attempts.
- Each student has a Change cohort control. Moving a student changes only program_students.cohort; prior exam_attempts stay attached through student_id and are preserved.
- New students can continue to be created with a cohort.

Database step required
Before using Change cohort, run 37_ADD_COHORT_ADMIN_FUNCTION.sql once in the Supabase SQL Editor. This adds only one administrator RPC; it does not delete or rewrite student results.

Minimal GitHub files to replace
- assets/db.js
- admin/dashboard.html

Do NOT replace your configured assets/config.js.
