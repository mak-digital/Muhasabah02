# Visual review package

Implemented Home Guide, Salah/Qur’an week cards, and first-day-of-week presentation.

Emulator stills (this implementation):

- `docs/visual_review/renders/impl-01-home-salah.png` — Salah week grid, no card legend, `ⓘ Guide`
- `docs/visual_review/renders/impl-02-marks-guide.png` — Marks Guide sheet
- `docs/visual_review/renders/impl-03-home-quran.png` and `impl-05-quran-card.png` — Qur’an Study and notice rows
- `docs/visual_review/renders/impl-04-settings.png` — First day of week on Settings
- `docs/visual_review/renders/impl-06-first-day-of-week.png` — Monday / Sunday / Saturday / device locale

Mockups remain reference: `home_symbols.html`, `quran_card.html`, `salah_card.html`, `quran_card_review.md`, `review_page_proposal.html` (Review layout — implemented: period snapshot, domain mosaic, Look closer, Ponder, Add a response), `recorded_days_proposal.html` (Recorded days + Historical Reflection compactness — implemented), `history_page_proposal.html` (Manage past check-ins compactness — implemented).

- `docs/visual_review/renders/impl-07-home-reflection.png` — Reflection of the Week, Noticed This Week, weekly journal
- `docs/visual_review/renders/impl-08-home-domains.png`
- `docs/visual_review/renders/impl-09-settings-reflection.png` — Baselines, Aspirations, quotation cadence
- `docs/visual_review/renders/impl-11-home-order.png` — approved Home order through Hadith
- `docs/visual_review/renders/impl-13-settings-approved.png` — approved Settings sections
- `docs/visual_review/renders/impl-14-settings-application.png` — Application (Appearance, first day of week, reflection)
- `docs/visual_review/renders/impl-15-checkin-dhikr.png` — full check-in Dhikr Home rows
- `docs/visual_review/renders/impl-16-checkin-family.png` — full check-in Family rows
- `docs/visual_review/checkin_dropdown_proposal.html` — check-in data entry: capital domain titles, bold row names, indented A–Z dropdowns
- `docs/visual_review/renders/impl-17-review-domain-progress.png` — Review domain Progress links
- `docs/visual_review/renders/impl-18-dhikr-progress.png` — Dhikr Progress calendar
- `docs/visual_review/factors_dropdown_proposal.html` — optional helping/distracting factor dropdowns
- `docs/visual_review/renders/impl-21-factors-unanswered.png` — accepted factor groups from the main choice
- `docs/visual_review/renders/impl-22-nested-factors.png` — accepted nested indent and quieter sub-dropdowns
- `docs/visual_review/renders/impl-23-fajr-helping-menu.png` — Fajr helping list includes sleep/waking cues
- `docs/visual_review/renders/impl-24-dhuhr-helping-menu.png` — daytime helping list omits those cues
- `docs/visual_review/renders/impl-27-marks-guide-close-button.png` — accepted Marks Guide Close (labeled header Close + full-width Close)
- `docs/visual_review/renders/impl-31-home-guide-slash.png` — accepted Guide control: filled / outlined + Guide
- `docs/visual_review/renders/impl-32-home-no-theme-toggle.png` — accepted Home app bar without theme cycle; Appearance is Settings only
- `docs/visual_review/renders/impl-33-settings-faq-entry.png` — Settings → About → FAQ
- `docs/visual_review/renders/impl-40-faq-answer-muted.png` — accepted FAQ: two-digit numbers, bold questions, quieter answers, comparison table
- `docs/visual_review/renders/impl-41-faq-manage-checkins.png` — accepted FAQ 10: Manage past check-ins vs Recorded days
- `docs/visual_review/renders/impl-42-home-dhikr-post-fard.png` — Dhikr Home: Post-fard Salah Adhkar (Fajr–Isha)
- `docs/visual_review/renders/impl-43-checkin-dhikr-post-fard.png` — check-in Dhikr post-fard rows
- `docs/visual_review/renders/impl-44-dhikr-progress-post-fard.png` — Dhikr Progress post-fard calendars
- `docs/visual_review/renders/impl-45-dhikr-progress-7day-matrix.png` — Dhikr 7-day week matrices
- `docs/visual_review/renders/impl-46-salah-progress-7day-matrix.png` — Salah 7-day week matrix
- `docs/visual_review/renders/impl-47-family-progress-7day-matrix.png` — Family 7-day week matrices
- `docs/visual_review/renders/impl-48-dhikr-progress-week-arrows.png` — 7-day matrix period arrows and today-row wash
- `docs/visual_review/renders/impl-51-dhikr-progress-today-mark-halo.png` — pale yellow halo on today’s marks only
- `docs/visual_review/renders/impl-52-salah-progress-90day.png` — 90-day Salah: one full-width grid, month labels, alternating day-cell washes
- `docs/visual_review/renders/impl-53-dhikr-progress-90day.png` — 90-day Dhikr: same presentation, no Earlier/Middle/Recent blocks
- `docs/visual_review/renders/impl-54-salah-progress-90day-today-halo.png` — 90-day today glow (18px, centred on the mark) and period arrows
- `docs/visual_review/renders/impl-55-salah-progress-90day-previous.png` — previous 90-day window via ←
- `docs/visual_review/renders/impl-56-home-shared-mark-colour.png` — Home marks share one colour; domain wash unchanged
- `docs/visual_review/renders/impl-57-salah-progress-shared-mark-colour.png` — Salah Progress 90-day: same mark colour, prayer washes kept
- `docs/visual_review/renders/impl-49-dhikr-progress-next-week.png` — next week: future empty marks inactive
- `docs/visual_review/renders/impl-50-dhikr-progress-today-sheet.png` — tap today’s mark to add/update
- `docs/visual_review/home_domain_stage_proposal.html` — Home one-domain stage (implemented: prev/next short names, session-only, pills not a score). Today’s full check-in uses the same stage.
- `docs/visual_review/home_lookback_proposal.html` — Home look-back band (implemented: This week presence marks, Noticed ticks, Patterns weekday strip; not a score)

## Earlier packages

- `docs/visual_review/REMEDIATION_AUDIT.md`
- `docs/visual_review/remediation.html`
- `docs/visual_review/dashboard.html`
