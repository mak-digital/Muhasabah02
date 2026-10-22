# Flutter implementation plan (not started)

Phase R0 stops at mockup and docs. Implement only after owner approval.

## Constraints to keep

- No nav-bar change until this design is approved and tested on device
- No Hive migration; schema v6 unchanged
- No new scores; reuse `analytics.dart` / traces
- Do not alter Hajj dormancy or Productivity feature work
- Do not log private text
- Do not commit unless asked

## Suggested phases (after approval)

### R1 — Dashboard composition without nav change

- New widgets under `lib/presentation/review/` (overview strip, domain cards, in-page calendar)
- `ReviewScreen` becomes the scroll in the mockup; mosaic cards gain expand + viz
- Keep History and My Response tabs
- Widget tests: period switch updates counts; empty/sparse copy; unanswered excluded from denominators
- Emulator: 1.0 / 1.3 / 1.5 text, light/dark, 390 width

### R2 — Date sheet and edit parity

- Selected `dateKey` sheet: marks, View/Edit → existing `CheckInScreen`, remove confirm copied from History
- Guarantee upsert by `dateKey` (regression: no duplicate keys)
- Day evidence remains available as more-detail

### R3 — Domain-specific charts from real fields

- Map each card to the definitions in `DOMAIN_METRIC_DEFINITIONS.md`
- Fasting: no daily denominator
- Charity: no amounts
- Dhikr: ticks only; hide dua text
- Productivity: read existing store; do not invent a worship score
- Golden tests for copy (no “performance %”, no “you declined spiritually”)

### R4 — Insights / Recognition fold-in

- Move `narrativeCopy` and Recognition 30/90 into the insights block with adequacy gates
- 7-day: insufficient for Recognition, still show counts

### R5 — Navigation reduction (optional, gated)

- Prototype Home | Review on a flag or debug build
- History: All saved days push **or** in-page All mode
- My Response: push existing list from Review
- Keep IndexedStack destinations until a full regression pass
- Only then hide extra `NavigationDestination`s

### R6 — Accessibility and release checks

- Contrast, non-colour state, overflow, TalkBack labels on chips/days
- `dart format`, `flutter analyze`, full `flutter test`, debug APK
- Privacy: log inspection for response/journal/dua

## Architecture notes

- Riverpod: `reviewPeriodProvider`, `checkInsProvider`, `nowProvider`, prefs mix already feed Review
- Extract chart math to `lib/domain/` (pure functions + tests), not `CustomPaint` in the widget file
- Reuse `MuhasabahColors` washes
- Calendar: reuse `weekly_calendar.dart` / first-day-of-week prefs (mockup is Monday-first only)
- Wide layout: `LayoutBuilder` two-pane; do not add a second data source

## Explicit non-goals

- Cloud, AI, telemetry
- Ranking domains
- Auto-creating check-ins when tapping empty days
- Changing Response or check-in semantics

## Owner gate

Stop after R0. R1 starts only with explicit approval.
