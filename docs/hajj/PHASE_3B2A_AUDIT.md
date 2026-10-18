# Phase 3B-2A audit of Phase 3B-1

**Date:** 2026-10-18  
**Schema:** Hajj store `schemaVersion` 1 (unchanged)  
**Live services:** not activated

## Session baseline

- Branch: `step-4a-ontology-rationalisation` (ahead of origin by 2).
- HEAD at start of this phase: `58637fc`.
- Flutter 3.47.1 / Dart 3.13.1.
- Uncommitted Hajj work from Phases 1–3B plus this 3B-2A layer. Fasting overflow files are separate (see Git inventory below).
- No commit, push, backend deploy, or paid activation in this phase.

## What 3B-1 already did well

- Offline planning remains the default. Hajj Home does not require a network.
- Two consent switches (official-source bookmarks vs AI-style interpretation).
- Request buttons stay disabled until the matching switch is on.
- `DemoHajjOnlineAssistGateway` and `FailingHajjOnlineAssistGateway` — no HTTP, no API keys.
- Payloads omit names, passport numbers, scans, health notes, and reflections.
- Demonstration sources stay `unverified`. Providers cannot be labelled authorised without evidence.
- AI proposals add a reminder milestone only after **Accept**, with no invented `officialDeadline`.
- Untitled legacy milestones stay off the critical path. Empty return costs show **Not estimated**.

## Gaps found (3B-1)

| Gap | Risk | 3B-2A action |
| --- | --- | --- |
| Demo lookup always used a UK mission URL regardless of nationality | Misleading “official” bookmark | Local registry + pathway resolver |
| One invented “licensed operator” row | Could look like a real directory | Demo provider lookup now returns none |
| Label was “Demonstration”, not the mandated banner | User might treat it as live | **Demo — no live verification** |
| Lookup used only the first traveller | Mixed-nationality families ignored | Country lists + citizenships (codes only) |
| Return country not in the payload | Incomplete travel context | Additive `returnCountry` |
| No reject path for proposals | Only accept was obvious | **Reject** dismisses without changing the plan |
| Single `HajjOnlineAssistGateway` bundled lookup, AI, and providers | Hard to swap a future live backend | Split mockable contracts + Riverpod DI |
| No maintainable official-portal catalog | Ad-hoc URLs in the demo class | `BundledHajjSourceRegistry` |
| `revokedAt` could not clear on re-opt-in via `copyWith` | Consent state sticky | `HajjConsentManager` constructs a fresh record |
| User-marked “verified” is not government certification | Over-trust | Verification service keeps `interpretationIsOfficial: false` |

## Network isolation

- Default gateway is on-device. No Hajj HTTP client was added.
- Android `INTERNET` remains for Qur’an/Hadith citations elsewhere, not Hajj lookup.
- Failures throw `HajjOnlineAssistException`; the store is unchanged unless the person already opted in and a demo write succeeded.

## Git inventory (do not stage without approval)

### Hajj-only (untracked)

- `lib/domain/hajj_*.dart` (planning, engine, math, pathway, readiness, learning, online assist, catalog, contracts)
- `lib/presentation/home/hajj_home_dashboard.dart`, `hajj_online_assist_panel.dart`
- `lib/presentation/shared/hajj_standing_editor.dart`
- `test/domain/hajj_*.dart`, `test/widget/hajj_planner_test.dart`
- `docs/hajj/**`

### Shared files modified for Hajj (also may contain earlier standing/Home work)

- `lib/application/providers.dart`
- `lib/data/hive_repositories.dart`, `memory_repositories.dart`, `repositories.dart`
- `lib/domain/copy.dart`, `practice_hajj_catalog.dart`, `faq.dart`, `home_traces.dart`
- `lib/presentation/home/home_screen.dart`, `optional_domain_home_card.dart`
- `test/widget/hajj_home_test.dart`, `test/domain/practice_hajj_test.dart`
- `docs/accepted_product_state.md`, `docs/architecture.md`, `docs/PRODUCT_SPEC.md`, `docs/product_guardrails.md`

### Unrelated Fasting overflow (do not mix into a Hajj commit)

- `lib/presentation/shared/progress_calendar.dart` (`dense` White Day highlight)
- `test/widget/fasting_progress_matrix_test.dart`

### Ambiguous / mixed-purpose

- `lib/main.dart`, `lib/data/app_prefs.dart`, `lib/domain/today_workspace.dart`, `lib/domain/personal_mix.dart`, `lib/domain/ontology.dart`
- `lib/presentation/checkin/check_in_screen.dart`, `today_domain_workspace.dart`, `today_overview.dart`, `review_screen.dart`
- `lib/presentation/shared/brand_title.dart`, `week_nav_strip.dart`
- Related tests under `test/domain` and `test/widget` for mix, ontology, dhikr matrix, check-in

These mixed files contain Hajj standing retirement **and** earlier Home/mix/Fasting-adjacent work. Split by `git add -p` only with owner approval.

## Proposed commit sequence (not executed)

1. Fasting overflow only, if the owner wants that preserved separately.
2. Hajj Phase 1–2C store + dashboard (schema v1).
3. Hajj Phase 3A offline engine.
4. Hajj Phase 3B-1 demo assistance + 3B-2A contracts/docs.
5. Shared copy/architecture docs that mention Hajj.
6. Leave mixed Home/mix files for a dedicated commit after review.

Do not commit or push until asked.
