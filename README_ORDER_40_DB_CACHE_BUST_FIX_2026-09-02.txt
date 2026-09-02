ORDER 40 — DB.JS CACHE-BUST FIX

Purpose:
Force the administrator dashboard to load the current assets/db.js instead of a stale browser/GitHub Pages cached copy.

Changed file:
- admin/dashboard.html

Implementation:
- db.js script reference changed from ../assets/db.js to ../assets/db.js?v=40

No Supabase SQL changes are required.
No assets/config.js changes are required.
Order 39 adminDeleteAttempt implementation remains unchanged.
