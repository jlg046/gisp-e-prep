BUCKNELL GISP-E / PreGISP PREPARATION PROGRAM
Order 36 — Exam Skip + 120-Minute Timer Update
Date: 2026-09-01

BASE PACKAGE
Order 35: 35_Bucknell_GISPE_Complete_Website_Navigation_Tab_Update_2026-09-01.zip

SCOPE
All 18 student practice exam HTML files under student/exams/.
No exam questions, answer keys, domain mappings, difficulty assignments, student/admin portal navigation, Supabase configuration, database schema, or remediation resources were intentionally changed.

CHANGES
1. Students may leave questions unanswered and continue through the exam.
2. Students may return to unanswered questions while time remains.
3. Manual submission displays a confirmation warning with the exact number of unanswered questions. Unanswered questions are scored as incorrect.
4. Every exam now has a visible 120-minute countdown timer.
5. The timer turns attention colors as time becomes short (last 10 minutes / last 5 minutes).
6. At 0:00, the exam automatically submits. Any unanswered questions are scored as incorrect.
7. The countdown deadline is stored in sessionStorage for that specific exam path, so a normal page refresh in the same browser tab/session does not restart the 120-minute clock.
8. Remediation identifies skipped items as "Unanswered" and treats them as missed questions.

DEPLOYMENT SAFETY
For this update, only the 18 HTML files in student/exams/ need to be replaced on GitHub.
Do NOT replace assets/config.js. No Supabase/database migration is required.

VALIDATION
- 18/18 exam files patched.
- 18/18 no longer use HTML required validation on answer radio buttons.
- 18/18 include the 120-minute timer controller.
- 18/18 include manual unanswered-question submission confirmation.
- 18/18 include automatic submission at time expiration.
- 18/18 safely handle unanswered answers during scoring/remediation.
- Inline JavaScript syntax check passed for all 18 exam files using node --check.
