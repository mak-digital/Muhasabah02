# Check 7 regression closure

Date: 2026-10-23  
Branch: `step-4a-ontology-rationalisation`  
HEAD: `eeee2692686b483673dc09eeee19998100e64f62` (7 commits ahead of origin)  
No commit, push, or merge.

## A1. Repository state

Unrelated uncommitted work was left in place (Hadith Map, Registry, Hajj worker leftovers, Productivity files, ANR boot/decode, Review snapshot provider).

**ANR-related files (not reset):** `lib/app/boot.dart`, `lib/debug/startup_probe.dart`, `lib/data/codecs.dart`, `lib/data/hive_repositories.dart`, `lib/data/memory_repositories.dart`, `lib/presentation/home/home_screen.dart` (lazy tabs), `lib/domain/review_period_snapshot.dart`, `lib/application/providers.dart`, `lib/presentation/review/review_screen.dart`, `android/app/src/debug/AndroidManifest.xml`, `docs/performance/*`, closure tests.

**Failing-test files:** `test/widget/calendar_rollover_test.dart`, `test/widget/first_look_door_test.dart`.  
**Involved production (inspected, not rewritten for these bugs):** `lib/presentation/home/quick_tap_sheet.dart` (accordion + Home-stage expansion), `lib/presentation/home/first_look_door_screen.dart`, `lib/data/codecs.dart` (`yieldToEventLoop`).

## Before

- Two `calendar_rollover_test` cases: `quick-tap-salah.fajr` not in the tree.
- `first_look_door_test` sample path did not finish (`pumpAndSettle(Duration(minutes: 1))` hung the full suite).
- Analyzer: 0 errors; pre-existing infos/warnings.

## A2. Calendar rollover — cause

**Obsolete test assumption, not a production defect.**

Quick Tap is an accordion. When Salah is the Home-stage domain it **starts expanded**. The tests always tapped `quick-tap-domain-toggle-salah`, which **collapsed** Salah, so `quick-tap-salah.fajr` was not built.

Lazy tab init does not apply (Quick Tap is a sheet from Home). Off-screen was not the failure (`Found 0 widgets`). Date/seed did not hide Fajr; firstLook mix still includes `salah.fajr`.

**Correction:** `ensureQuickTapFajrVisible` expands only if Fajr is missing, then `ensureVisible`. Same idea as `quick_tap_test`. Production Quick Tap unchanged in this workstream.

## A3. First-look — cause

**Obsolete test wait, plus FakeAsync vs decode yields. Production door behaviour is correct.**

1. `pumpAndSettle(const Duration(minutes: 1))` is a **one-minute frame interval**, not a timeout. Default settle timeout is 10 minutes wall. A `CircularProgressIndicator` never goes idle.
2. After sample seed, Home loads ~120 synthetic days. `decodeStoredCheckIns` `await`s `Future.delayed(Duration.zero)` every 24 keys. Unflushed zero-duration timers fail at test end; awaiting `allHealthy()` on FakeAsync without pumping those timers hangs.

**Correction:** one `pump` after the tap, twelve `pump(Duration.zero)` to flush decode yields, then `tester.runAsync(checkIns.allHealthy)` for the assertion. No `pumpAndSettle` on the seeded Home tree.

## Files changed (this recovery)

- `test/widget/calendar_rollover_test.dart`
- `test/widget/first_look_door_test.dart`
- this document

Production Flutter was not changed for these two failures.

## A4. Results after

| Run | Result |
| --- | --- |
| Previously failing calendar cases (each) | pass |
| `test/widget/calendar_rollover_test.dart` | **11 passed** |
| `test/widget/first_look_door_test.dart` | **2 passed** |
| ANR closure suite (boot, decode, snapshot, impeller) + first-look | **9 passed** |
| Full `flutter test` | **874 passed, 4 skipped, 0 failed** |
| `flutter analyze` | **0 errors**; 6 remaining infos/warnings in other files (calendar unused import removed) |

Skipped (expected, `skip: true`): screenshot capture tests in `checkin_screenshot_test.dart`, `review_progress_screenshot_test.dart`, and `settings_screenshot_test.dart` (four skipped cases in the compact reporter). They are not Check 7 regressions.

## Remaining

- Check 7 **full suite is green** (skips as above).
- Gate 4: Release-mode and physical-device ANR verification still pending.
- Gate 2: do not implement the Review HTML mockup in Flutter until approved.
- Gate 3: Productivity implementation still paused pending phase confirmation.
- Hajj remains dormant; Hajj worker leftovers still uncommitted.
