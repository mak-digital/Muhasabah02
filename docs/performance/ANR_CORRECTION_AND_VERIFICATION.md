# ANR correction and verification

## Closure checks (2026-10-23)

| Check | Result |
| --- | --- |
| 1. Lazy tabs in Debug **and** Release | **Pass.** `AppShellState._opened` has no `kDebugMode` / flavor gate. Same Dart tree in both. |
| 2. Decode yields to the event loop | **Pass.** `decodeStoredCheckIns` `await`s `yieldToEventLoop()` (`Future.delayed(Duration.zero)`) every 24 keys. Test injects a counter and expects one yield at 25 keys. |
| 3. Decode preserves records, order, errors | **Pass.** Newest `dateKey` first; corrupt JSON listed and omitted; healthy fields kept. Shared by Hive and memory repos. |
| 4. Regression tests | **Pass.** Lazy tabs: `test/widget/app_boot_test.dart`. Decode/yield: `test/data/check_in_decode_yield_test.dart`. Impeller flavor: `test/config/impeller_flavor_test.dart`. Review cache: `test/domain/review_period_snapshot_test.dart`. |
| 5. Impeller debug-only | **Pass.** `EnableImpeller=false` only in `android/app/src/debug/AndroidManifest.xml`. Main and profile manifests do not set it (Release keeps Impeller). |
| 6. Remaining verification | **Documented below.** Release + physical device still required. |
| 7. Analyzer / tests | **Pass (2026-10-23 recovery).** Full `flutter test`: **874 passed, 4 skipped, 0 failed**. See `docs/performance/CHECK7_REGRESSION_CLOSURE.md`. |

Review period totals now live in `reviewPeriodSnapshotProvider` / `buildReviewPeriodSnapshot`, not in widget `build()`.

## Correction (smallest safe set)

1. **Debug Impeller off** — `android/app/src/debug/AndroidManifest.xml` sets `io.flutter.embedding.android.EnableImpeller=false`. Release is unchanged. Addresses the verified OPEN/commit ANR on the API 36 emulator.
2. **Lazy bottom tabs** — `AppShell` still uses `IndexedStack` for visited tabs, but Review and Registry are not built until first open. Home is the only first-frame dashboard. Addresses skipped-frame / main-thread work after `persistence_ready`.
3. **Yield while decoding check-ins** — `HiveCheckInRepository.allHealthy()` yields every 24 records so a large sample set cannot monopolise the UI isolate.
4. **Startup probes** — debug-only timestamps, stage names only.

No Hive schema change. No Hajj/Productivity behaviour change. No commit/push.

### Files (including closure)

- `lib/debug/startup_probe.dart` (new)
- `lib/main.dart`
- `lib/app/boot.dart`
- `lib/data/hive_repositories.dart`
- `lib/presentation/home/home_screen.dart`
- `lib/data/codecs.dart`
- `lib/data/memory_repositories.dart`
- `lib/domain/review_period_snapshot.dart`
- `lib/application/providers.dart`
- `lib/presentation/review/review_screen.dart`
- `android/app/src/debug/AndroidManifest.xml`
- `test/widget/app_boot_test.dart`
- `test/data/check_in_decode_yield_test.dart`
- `test/domain/review_period_snapshot_test.dart`
- `test/config/impeller_flavor_test.dart`
- these `docs/performance/*.md`

## Tests

- Closure suite (`app_boot_test`, `check_in_decode_yield_test`, `review_period_snapshot_test`, `impeller_flavor_test`) — **7 passed**
- `flutter analyze` — **0 errors**; 7 pre-existing infos/warnings in other files
- Full `flutter test` — **not completed green**: two Quick Tap rollover failures; first-look sample `pumpAndSettle` did not finish (run stopped)

## Runtime (emulator-5554, data preserved)

- Five cold starts: all reached `home_first_input_frame` (~1.5 s), **ANR 0**
- Five warm resumes: TotalTime 0, **ANR 0**
- Bottom nav taps Home / Review / Registry after install: **ANR 0** in logcat
- Background/resume: warm `am start -W` while running, **ANR 0**

Productivity dashboard was not on the default First-season Home mix; it was not forced on. Review scrolling used a swipe after opening Review.

## Remaining limitations

- **Release still uses Impeller.** A **physical device** cold start, warm resume after idle, and Home/Review/Registry pass have **not** been run. Do that before treating ANR as closed for store builds.
- Registry `TabBarView` still builds five pages **once Registry is opened**.
- Check-in JSON still decodes on the UI isolate (now chunked).
- Emulator freeze + swap can still make the **next** OPEN slow; debug Skia reduces the GLES commit failure that produced the 11:04 ANR.
- `/data/anr` files remain unread (no root).

## Follow-up

- Confirm Impeller on a physical device.
- Optionally lazy-build Registry tabs.
- Optionally `compute()` for `allHealthy` if personal histories grow past sample size.
- Do not add dashboard work until a further idle-overnight freeze test is clean.

## Decision

For **debug emulator cold start and tab navigation after this APK**, the 11:04-class ANR did not recur in five cold + five warm + nav. That is not a claim that every future freeze on every device is impossible.
