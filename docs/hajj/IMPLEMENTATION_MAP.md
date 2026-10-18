# Hajj Journey Planner — Phase 0 implementation map

**Date:** 2026-10-17. **Repository:** `C:\Development\Muhasabah02`. **Package:** `Private_Muhasabah_Hajj_Module_Implementation_Package.zip` v1.0.

Phase 0 is reconnaissance only. No Hajj feature code was changed. Storage format and standing semantics **were established**; Phase 1 may proceed after user approval. Ambiguous standing values must not be auto-reinterpreted.

## Session baseline

| Check | Result |
| --- | --- |
| Git branch | `step-4a-ontology-rationalisation` |
| Upstream | `origin` `https://github.com/mak-digital/Muhasabah02.git` answers; branch **ahead 2** |
| Uncommitted | Fasting 30-day White Day overflow fix (`lib/presentation/shared/progress_calendar.dart`, `test/widget/fasting_progress_matrix_test.dart`) — leave it; unrelated to Hajj |
| Flutter | 3.47.1 / Dart 3.13.1 |
| Analyze | 6 pre-existing infos/warnings; no Hajj-related findings |
| Hajj tests | `test/widget/hajj_home_test.dart`, `test/domain/practice_hajj_test.dart` pass |
| Last full suite (prior Fasting gate commit) | 685 pass, 3 skip |
| Emulator | `emulator-5554` already open (Android 16). Not reused for Hajj capture so the owner’s current session is not replaced |
| Golden screenshots | **Not taken on device** (avoid overwriting the running emulator). Widget coverage of current Hajj Home: `test/widget/hajj_home_test.dart` |
| Localization | No `.arb` files. English `Copy` strings only. RTL/configChanges exist on Android Activity |
| Notifications | **None**. No `flutter_local_notifications` in `pubspec.yaml` |
| Network | `INTERNET` in `android/app/src/main/AndroidManifest.xml` with comment “Optional citation open only”. `url_launcher`, `webview_flutter`, `just_audio` for citations/recitation. No Hajj HTTP adapter |
| Backup | `android:allowBackup="false"` |
| Suggested package paths | App uses `lib/domain`, `lib/data`, `lib/application`, `lib/presentation` — **not** `lib/features/hajj`. Phase 1+ should follow existing layout, not invent a parallel features tree unless the owner asks |

## Layout (actual)

```
lib/domain/monitor_domain.dart          MonitorDomain.hajj last; id `hajj`
lib/domain/home_traces.dart             HajjStatus, hajjHomeRows, kHajjPreparationKey
lib/domain/personal_mix.dart            kHajjMixKey = 'hajj' (standing mix item, not a daily row)
lib/domain/practice_hajj_catalog.dart   4 Learn & Practice items, group Preparation
lib/domain/daily_check_in.dart          schema v6; homeTraces JSON
lib/domain/today_workspace.dart         Hajj mix rows exclude kHajjMixKey; gate by status
lib/domain/quick_tap.dart               Hajj standing mix id is not a Quick Tap tile
lib/domain/copy.dart                    hajjStatusLabel/Note, practiceHajj*
lib/domain/domain_briefing.dart         hajjBriefing
lib/domain/faq.dart                     Hajj FAQ
lib/data/app_prefs.dart                 hajjStatus getter/setter
lib/data/hive_repositories.dart         prefs key `hajj_status`
lib/data/memory_repositories.dart       MemoryAppPrefs
lib/application/providers.dart          Riverpod; appPrefsProvider, checkInsProvider
lib/presentation/home/home_screen.dart  OptionalDomainHomeCard includeHajjStatus
lib/presentation/home/optional_domain_home_card.dart  status dropdown + gated prep row
lib/presentation/home/practice_dhikr_home.dart        Hajj Learn spec
lib/presentation/checkin/check_in_screen.dart         status editor + traces
lib/presentation/review/review_screen.dart            Hajj Progress tile
lib/presentation/recorded_days/day_evidence_screen.dart
test/widget/hajj_home_test.dart
test/domain/practice_hajj_test.dart
docs/PRODUCT_SPEC.md § 4.13
docs/visual_review/hajj_status_proposal.html
```

No `lib/features/hajj`, no `assets/hajj/`, no `integration_test/`.

## Domain order

`MonitorDomain.values` (presentation order): salah, quran, hadith, dhikr, fasting, akhlaq, huquq, charity, knowledge, time, health, wealth, ummah, **hajj**.

- Stable id: `hajj` (`MonitorDomain.hajj.id`)
- Default visible set `kBasicDhikrVisibleDomains` does **not** include Hajj
- `usesCompactHomeWeek(hajj)` is false (item week, not compact day dots)
- `showsHomeActionFollowOn` is true (listed actions + developer notes)

Do not rewrite stored domain ids.

## Current Hajj product (accepted)

Standing is user-owned, not calculated. Daily **Noticed preparation** (`hajj.preparation`) appears only when status is `due` or `preparing`. Unanswered standing is not missed. Umrah is not this status. Performed is a record, not a trophy. Learn & Practice is educational, not fatwa.

Home today: status dropdown (`Key('hajj-status')`) plus optional preparation week row. Review: Hajj Progress with `includeHajjStatus`. Mix: standing item `hajj` plus optional `hajj.preparation` row.

## Persistence (established)

| Store | Box / key | Format |
| --- | --- | --- |
| Prefs | Hive `muhasabah_prefs_v1` | `Box<String>` |
| Standing | prefs key `hajj_status` | enum **`.name`**: `unanswered`, `notDue`, `due`, `preparing`, `performed`, `notApplicable`. Missing/unknown → `unanswered` (`HajjStatusX.fromId`) |
| Daily days | Hive `muhasabah_checkins_v5` | JSON strings, `DailyCheckIn` **schemaVersion 6** |
| Preparation | `homeTraces['hajj.preparation']` | `positive` / `didNot` via `tracesToJson` (unanswered omitted) |
| Check-in box name | remains `v5` while JSON schema is v6 | do not rename box casually |

Other boxes (responses, domain actions, practice hadith, personal Qur’an/hadith) are unrelated standing. Hajj Learn register uses the shared practice-hadith box pattern (`practiceHadithBrowseIndex` is Qur’an/Hadith browse, not Hajj-specific).

No Hive TypeAdapter for Hajj. Adding journeys should be a **new** string box or prefs JSON key with an explicit schemaVersion, not a rewrite of `hajj_status` in place.

## Standing mapping (migration hazard)

Package `standing` enum: `unsure`, `believe_due`, `preparing`, `performed`, `not_planning`, `prefer_not_to_record`.

| Stored `HajjStatus.name` | UI label today | Package candidate | Decision |
| --- | --- | --- | --- |
| `preparing` | Preparing | `preparing` | **Safe map**; keep original name in a provenance field |
| `performed` | Performed | `performed` | **Safe map**; planning a later journey must not overwrite this |
| `due` | Due | `believe_due` | **Safe map** of meaning; **do not** rename stored prefs until a versioned migrator writes both |
| `unanswered` | Not recorded | — | **Do not map** to `unsure` or `prefer_not_to_record`. Empty ≠ “I am unsure whether due” |
| `notDue` | Not due | `not_planning`? | **Ambiguous**. Keep readable as Legacy / original `notDue` until the person edits |
| `notApplicable` | Not applicable | `not_planning`? | **Ambiguous**. Not the same as “not currently planning”. Legacy history |

Phase 1 rule: never silently merge `notDue` and `notApplicable` into `not_planning`. Surface them under **Legacy Hajj history** if the new model cannot hold the original `.name`.

Daily `hajj.preparation` traces: **legacy noticing only**. Do not convert `positive` into readiness task `confirmed_ready`.

Mix id `hajj` (`kHajjMixKey`) is the standing chip, not a daily confirmation.

## Learn & Practice

`lib/domain/practice_hajj_catalog.dart` — 4 items, group `Preparation`, topic `Noticed preparation`:

- `hj.prep.noticed` Qur’an 3:97
- `hj.prep.noticed.2_196` Qur’an 2:196
- `hj.prep.noticed.2_197` Qur’an 2:197
- `hj.prep.noticed.bukhari_1513` catalog id vs source Ṣaḥīḥ al-Bukhārī **1521** (id/source mismatch to verify in a later phase, not a storage migration)

Register is the shared personal-hadith practice register, not a Hajj-only box.

## Calendar / history

- Date keys `YYYY-MM-DD` Gregorian (`lib/domain/date_key.dart`)
- Display calendar Gregorian / civil Islamic (`lib/domain/display_calendar.dart`)
- Progress 7 / 30 / 90 days (`ReviewPeriod`) — package wants 6/9/12-month journey calendar **in addition**, not as a replacement of other domains’ 7/30/90
- Hajj Home does not use compact 7-day dots
- Recorded days / Historical Reflection already list Hajj traces when the domain is shown

## Privacy / online

- No telemetry. Privacy settings: on-device storage copy, optional device unlock (`local_auth`)
- INTERNET exists for citation/audio; Hajj must not call network at launch
- No consent-preview gateway yet
- Package Phase 4 `FakeHajjOnlineGateway` is new work; no official endpoints are verified in-repo

## Package vs repo gap (Phase 1+)

| Package capability | In repo now |
| --- | --- |
| Lifetime standing | Yes, prefs `hajj_status` |
| Season journeys, travelers, tasks, sources | **No** |
| Route classifier / six pathway tags | **No** |
| Readiness inventory / critical path scheduler | **No** |
| 6/9/12 month Hajj calendar | **No** |
| Family profiles | **No** (domain `family` on DailyCheckIn is a different observation, not Hajj party) |
| Providers / cost / return scenarios | **No** |
| Consent + fake online gateway | **No** |
| Local reminders | **No notification architecture** — Phase 2 optional reminders need a new local plugin + permission story |
| `prefer_not_to_record` standing | **No** (only unanswered empty) |
| Arabic/Bengali UI | **No** ARB; Arabic script setting is for cited text |

`DailyCheckIn.family` is **not** Hajj family members. Do not reuse it for traveler profiles.

## Recommended Phase 1 shape (no edits yet)

1. Keep `MonitorDomain.hajj` id, colours, Home/Review/Learn entry points.
2. Keep reading `hajj_status` `.name` forever; add a versioned `HajjStandingRecord` JSON (new prefs key or new Hive box `muhasabah_hajj_v1`) with `schemaVersion`, `legacyStatusName`, mapped standing, `legacyRecordRefs`.
3. Keep `hajj.preparation` in `homeTraces` as historical noticing; gate the Home week as today.
4. Add optional `HajjJourney` list without deleting standing.
5. Tests: round-trip every current `HajjStatus` value; unanswered stays empty; preparation traces unchanged; backup/restore of prefs box.

## Stop / do-not-claim

- Storage format **is** established (string enum in prefs + ternary homeTraces).
- Semantics **are** established for labels and gates; **equivalence to the package enum is only proven for preparing, performed, and due→believe_due**.
- No live Nusuk/MOH/provider URL is verified. Do not ship “official” deadlines in Phase 1.
- Do not commit, push, or run a destructive Hive migration without explicit approval.

## Owner follow-ups before Phase 1

Superseded. Phase 1 was authorized as a clean store with no legacy migration.

## Phase 1 (clean store, 2026-10-17)

Canonical document: Hive box `muhasabah_hajj_v1`, key `current`, `schemaVersion` 1. AppPrefs `hajj_status` is discarded on open. Daily `hajj.preparation` is retired (leftover traces still classified). Standing is lifetime. Journeys, travelers, readiness, milestones, sources, and after-Hajj are optional and separate. Learn & Practice groups are Learn, Readiness, After Hajj, always available.

## Phase 2 (offline planner UI, 2026-10-17)

Hajj Home dashboard on the Phase 1 store (`schemaVersion` 1, additive fields only). Compact summary cards for standing, optional journey, readiness, 6/9/12-month calendar, travelers, readiness-learning, and After Hajj. No network, no obligation engine, no booking.

Phase 3A (offline planning engine) and Phase 3B (consent-controlled on-device demonstration assistance) are implemented. Phase 3B-2A adds registry, resolver, and gateway contracts. Phase 3B-2B adds a local Worker twin and Flutter live gateway; **not deployed**, AI disabled. See `docs/hajj/PHASE_3B2B.md`.
