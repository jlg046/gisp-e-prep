ORDER 50 — 20 NEW GISCI COMPANION INTERACTIVE PRACTICE EXAMS
Created: 2026-09-04

WHAT THIS UPDATE ADDS
• 10 Calibrated / Right-Sized GISCI Companion exams (75 MC questions each; 120 minutes)
• 10 Advanced / Over-Preparation GISCI Companion exams (75 MC questions each; 120 minutes)
• 1,500 new questions total
• Same interactive behavior as the existing 18 exams:
  - student-session check
  - skip/return while time remains
  - visible 120-minute countdown
  - automatic submission at 0:00
  - unanswered items scored incorrect
  - raw and blueprint-weighted scoring
  - domain-specific performance
  - missed-item remediation
  - automatic Supabase result saving
  - student My Progress integration
  - administrator submission/cohort analytics

IMPORTANT DATABASE STEP
Before students submit any of the 20 new exams, run:
50_EXPAND_DATABASE_TO_38_EXAMS.sql
once in the Supabase SQL Editor.

DEPLOYMENT
This is a full-site package built from the verified Order 44 website and overlaid with the verified clean Chapter 1-9 Order 46 link patch. Copy its contents over the existing GitHub repository. DO NOT delete the repository first.

IMPORTANT: assets/config.js is intentionally NOT included. Keep your existing live assets/config.js unchanged.

PRACTICE-EXAM STRUCTURE
Existing 18 exams remain unchanged.
New:
• Calibrated 1-10 = right-sized GISP-E simulations based on GISCI August 2026 Companion guidance.
• Advanced 1-10 = over-preparation simulations using the same content scope with deeper reasoning.

DATABASE IDs
Existing forms: versions 1-18.
Advanced 1-10: versions 19-28, difficulty_code ADV.
Calibrated 1-10: versions 29-38, difficulty_code CAL.
