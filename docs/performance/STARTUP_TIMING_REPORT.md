# Startup timing report

Probe: `lib/debug/startup_probe.dart` (debugPrint `muhasabah:t <stage> <ms>`, once per process, no record contents).

Stages: `engine_binding`, `run_app`, `boot_hold`, `persistence_start`, `persistence_ready` (also `muhasabah:persistence_ready`), `boot_apply_overrides`, `app_scope`, `home_checkins_loading`, `home_checkins_ready`, `home_first_input_frame`.

## Device

- emulator-5554, API 36, 1080×2400
- Debug APK after correction (`adb install -r`, data kept)
- Five cold launches via `am force-stop` then `am start -W`

## Cold launches (after correction)

| Run | persistence_ready | home_first_input_frame | wall to input (script) | ANR |
| --- | ---: | ---: | ---: | --- |
| 1 | 703 ms | 1736 ms | 3499 ms | 0 |
| 2 | 659 ms | 1474 ms | 2752 ms | 0 |
| 3 | 646 ms | 1543 ms | 2759 ms | 0 |
| 4 | 643 ms | 1454 ms | 2726 ms | 0 |
| 5 | 667 ms | 1522 ms | 2660 ms | 0 |
| **median** | **659 ms** | **1522 ms** | **2752 ms** | **0** |

ANR occurs **after** engine start. On these cold starts, Hive is ready in ~0.65 s and the first Home frame that can take input is ~1.5 s from process start.

Widget-test (memory repos, no Android): hold at 0 ms, Home input frame ~0.6 s.

## Warm launches

Five `am start -W` while the process was already resumed: `TotalTime: 0`, `WaitTime: 2–3` ms, ANR 0. Probes do not re-fire (Dart `main` does not run again).

## Pre-correction baseline

No numeric probe existed. The 11:04 ANR spent ~5 s from `unfroze` (11:04:26) to ANR dump (11:04:56) with Impeller GLES after a freeze that began 10:59:48. That is the baseline failure, not a successful cold-start time.

## Memory after corrected cold start (pid 12506)

TOTAL PSS ~334 MB, SwapPss ~0.3 MB (fresh process, not the frozen 58 MB swap sample).

## Closure (2026-10-23)

Acknowledged: five cold launches without ANR; five warm resumes without ANR; Home ~1.5 s; Hive ~0.65 s; lazy inactive tabs; debug-only Impeller off; existing data preserved.

Still required before calling Release closed:

1. Release APK (Impeller **on**) cold start and warm resume on this emulator.
2. Same pass on a **physical** Android phone, including after idle freeze.
3. Home, Review, and Registry after those starts, with stored data intact.
