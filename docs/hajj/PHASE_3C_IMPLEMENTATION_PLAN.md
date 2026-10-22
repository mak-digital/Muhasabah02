# Phase 3C — Recommended implementation sequence

**Date:** 18 October 2026  
**This phase:** Audit and planning only. **Do not** implement the backlog until the owner reviews it.

## Goal

Turn the existing offline Hajj Planner into a calmer preparation surface: obvious next step, safer editing, honest online labels, calendar and dates easier to see — without new cloud services.

## Sequence

### Phase 3C-1 — Essential UX (do first)

Items **E1–E5** in `PHASE_3C_IMPROVEMENT_BACKLOG.md`.

Suggested order inside 3C-1:

1. **E1** confirm/archive/delete and hide Edit plan  
2. **E2** persistent unavailable banner  
3. **E3** online copy (duplicate live line)  
4. **E5** card order + quieter summary  
5. **E4** next-action block (uses quieter summary)

Stop for a short emulator pass on 5554 (and USB phone if attached) before 3C-2.

**Exit:** Accidental Edit plan gone; Worker-down visible without a disappearing snackbar; calendar above online tools; no duplicate live copy.

### Phase 3C-2 — Offline planning intelligence

Items **P1–P5**.

Order: **P1** critical-path label → **P4** recalc on date change → **P2** remaining time on next-action → **P3** named dependencies → **P5** traveler-on-milestone.

**Exit:** Critical label matches engine; changing departure updates estimates only; traveler notices are specific.

### Phase 3C-3 — Optional polish

**O1** budget card, **O2** source review sheet, **O3** user-title hint.

Do not start **O4/O5** without a separate owner decision.

## Constraints for every later coding session

- Schema version **1**, additive fields only.  
- RECORD→… guardrails: unanswered empty; no faith scores; no invented official deadlines.  
- No Cloudflare deploy, Zero Trust, paid AI.  
- Leave Fasting / `home_screen.dart` / `brand_title.dart` / `week_nav_strip.dart` unstaged unless the task names them.  
- Commit/push/merge only when asked.

## Verification for later coding phases

```
dart format .
flutter analyze
flutter test --reporter compact
```

Plus focused Hajj tests and emulator-5554 (reuse; do not start a second AVD). Physical USB + `adb reverse` still **pending**.

## Current test snapshot (this audit)

- Hajj domain + widget files: **64 passed** (18 Oct 2026).  
- Analyzer on planner files: **clean**.  
- Full suite previously: **770 passed, 4 skipped** (3B-2G; one skip is Wrangler HTTP when the Worker is down).

## Owner decision needed

Approve **3C-1** as the next coding phase, or reorder. Until then, no major Hajj UI implementation.
