# Android ANR root cause

Date: 2026-10-23. Branch `step-4a-ontology-rationalisation` HEAD `eeee269`. Uncommitted work was left in place. Hive boxes and emulator data were not wiped. Emulator `emulator-5554` (API 36, 1080×2400) was reused.

## What was verified

The 11:04 ANR is **after** Flutter engine start. It is **during Activity OPEN / first GPU frame**, not during Hive box open.

Logcat (pid 5086, then a later process):

1. `11:04:27` Impeller OpenGLES context comes up after the process was frozen.
2. `10:59:47` `BLASTSyncEngine: WM sent Transaction (#20, Transition-OPEN) … never received commit callback. Application ANR likely to follow.`
3. `10:59:48` `ActivityManager: freezing 5086 com.muhasabah.muhasabah02`
4. `11:04:26` `sync unfroze 5086 …`
5. `11:04:56` `ANR in com.muhasabah.muhasabah02/.MainActivity`

CPU in the ANR dump is not a tight Dart loop:

- `1.9%` then `37%` of the process, with **29 768 minor / 7 287 major** page faults on the first sample.
- Process RSS ~280 MB with ~58 MB SwapPss while frozen — the working set had been paged out.

`muhasabah:persistence_ready` appears in earlier sessions **before** later ANRs. The 11:04 ANR is a **resume of a frozen process**, not a hang inside `openHiveRepositories()`.

On-device `/data/anr/anr_2026-10-23-11-04-56-233` exists (727 KB) but is not readable without root on this userdebug-less image. Thread stacks were therefore taken from ActivityManager’s ANR text in logcat, not from the private ANR file.

Flutter DevTools timeline was not attached (no competing `flutter run`; install used `adb install -r`).

## Application contributors (verified in code, not the 11:04 stack)

`AppShell` previously built **Home + Review + Registry** in one `IndexedStack`. Review walks every in-period check-in in `build()`. Registry’s `TabBarView` builds five tables. That work ran on the first interactive frame after persistence, which matches “Skipped N frames / too much work on its main thread” even when it does not reach the 5 s ANR threshold.

`HiveCheckInRepository.allHealthy()` JSON-decodes every stored day on the UI isolate. Sample days (~120) make that noticeable; it is **after** `persistence_ready`.

## Emulator contributors (verified)

- API 36 emulator + Impeller **OpenGLES**.
- Process freeze / swap, then OPEN transition with no frame commit.
- Graphics: FlutterView is a single Android view (7 Views in meminfo is normal for Flutter).

This is **intermittent**: it appears after idle freeze, not on every cold start. It is **not** a Hajj or Productivity-specific crash. Productivity was not on the ANR stack.

## Hypothesis vs fact

| Item | Status |
| --- | --- |
| ANR on OPEN because first Impeller GLES frame did not commit after unfreeze | **Fact** (BLASTSyncEngine + Impeller line + ANR) |
| Heavy paging on resume | **Fact** (major faults, SwapPss) |
| Hive init as the ANR blocked thread | **Not supported** for the 11:04 event |
| IndexedStack + Review aggregation causing skipped frames | **Fact** in code; **likely** for Choreographer warnings |
| Emulator-only vs device | **Emulator confirmed**; physical device not measured |

## Closure (2026-10-23)

Lazy Review/Registry construction is **not** debug-gated. Check-in decode yields every 24 keys via `Future.delayed(Duration.zero)`. Impeller remains off **only** in the debug Android manifest. Release Impeller + physical-device cold/warm still outstanding. Review period totals moved to `reviewPeriodSnapshotProvider` so `build()` does not walk history.

## Earliest relevant error

For the 11:04 event, the earliest line is `BLASTSyncEngine` missing the OPEN commit callback (`10:59:47`), not the later ANR toast (`11:04:56`).
