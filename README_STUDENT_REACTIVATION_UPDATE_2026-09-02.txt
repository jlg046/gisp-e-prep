ORDER 38 — STUDENT REACTIVATION / STATUS FILTER UPDATE
Date: 2026-09-02

Purpose
- Restore administrator visibility of inactive students.
- Allow administrators to reactivate previously deactivated students from the dashboard.
- Preserve each student's username, cohort, PIN, and prior exam history when reactivated.

Website change
- admin/dashboard.html only

New behavior
- Dashboard Filters now includes Student status:
  * Active Students (default)
  * Inactive Students
  * All Students
- The Student progress & login management table follows both the Cohort and Student status filters.
- Inactive students show a Reactivate Student button.
- Active students continue to show Deactivate.
- Cohort analytics, mastery matrix, support priorities, and recent submissions intentionally remain based on active students so inactive historical accounts do not change current cohort-readiness metrics.

Database / Supabase
- No new SQL is required for Order 38.
- The existing admin_set_student_active function already supports setting active=true or active=false.
- Reactivation changes only the active flag. Existing exam attempts remain linked to the same student ID and are not deleted.

Deployment
- Replace only admin/dashboard.html in GitHub for this update.
- Do not replace assets/config.js.
- No Supabase SQL step is required if Order 37 was already installed.
