ORDER 39 — ADMIN DELETE TEST UPDATE
Date: 2026-09-02

Purpose
Adds an administrator-only Delete Test action for individual submitted exam attempts.

Required deployment
1. Run 39_ADD_ADMIN_DELETE_ATTEMPT_FUNCTION.sql once in Supabase SQL Editor.
2. Replace assets/db.js on GitHub.
3. Replace admin/dashboard.html on GitHub.
4. Do NOT replace assets/config.js.

Behavior
- Recent submissions now includes a Delete Test button.
- Confirmation identifies student, exam, submission time, and weighted score.
- Deletion is permanent and cannot be undone.
- Only the selected exam_attempts row is deleted.
- Student account, cohort, PIN, status, and all other attempts are retained.
- Dashboard metrics recalculate after deletion.

Retained from prior releases
- Order 38 active/inactive student filtering and reactivation.
- Order 37 cohort filtering, cohort comparison, and cohort reassignment.
- Order 36 120-minute exam timer, skip/unanswered behavior, and auto-submit.
