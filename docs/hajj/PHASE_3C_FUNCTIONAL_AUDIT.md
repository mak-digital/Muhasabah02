# Phase 3C — Hajj Planner functional audit

**Date:** 18 October 2026  
**Scope:** Existing Hajj Planner only. No new features were implemented in this phase.  
**Schema:** Hajj store `schemaVersion` 1 (`muhasabah_hajj_v1`).  
**Authority:** `docs/PRODUCT_SPEC.md` § 4.13, `docs/accepted_product_state.md`, `docs/product_guardrails.md`.

Classifications use only what is in the repository and on emulator-5554. Proposed work is **not** marked implemented.

## Classification key

| Class | Meaning |
| --- | --- |
| Fully implemented and tested | Domain behaviour exists, UI can complete the flow, and automated tests cover the contract. |
| Implemented but needing refinement | The function works, but UX, copy, or completeness is weak. |
| Partially implemented | Data model or engine exists without a complete user flow, or UI exists without the engine. |
| Not implemented | Absent. |

## Summary

| # | Function | Class |
| --- | --- | --- |
| 1 | Lifetime Hajj standing vs journeys | Fully implemented and tested |
| 2 | Journey create, edit, archive, target season | Implemented but needing refinement |
| 3 | International pathway selection and confirmation | Fully implemented and tested |
| 4 | Family and traveler-specific planning | Implemented but needing refinement |
| 5 | Readiness categories and prerequisites | Fully implemented and tested |
| 6 | Backward planning and milestone scheduling | Implemented but needing refinement |
| 7 | Critical-path and schedule-conflict detection | Implemented but needing refinement |
| 8 | Document and official-source tracking | Implemented but needing refinement |
| 9 | Budget and return-travel scenarios | Implemented but needing refinement |
| 10 | Religious learning and After Hajj | Fully implemented and tested |

Cloud Worker lookup is **optional assistance**, not a core planning function. Offline planning works with `HAJJ_LIVE_BASE_URL` empty.

---

### 1. Lifetime Hajj standing and separation from journeys

**Class:** Fully implemented and tested.

Standing lives on `HajjStore.standing` / `standingHistory`, not in `DailyCheckIn` and not as AppPrefs `hajj_status`. Choices include unanswered, unsure, I believe it is due, preparing, performed, not planning, not applicable, prefer not to record.

`HajjStandingEditor` is the first Hajj Home control. Copy states it is a lifetime record the person sets, not a ruling.

Tests: `test/widget/hajj_home_test.dart` (no daily Hajj week matrix); `test/domain/hajj_planning_test.dart` (standing vs journey lifecycles); `test/domain/hajj_planning_math_test.dart` (archive/delete leave standing unchanged; After Hajj stays empty when standing becomes performed).

Emulator: standing **I believe it is due** with a journey **Considering · Season undecided**.

### 2. Journey creation, editing, archiving and target-season selection

**Class:** Implemented but needing refinement.

Create, edit (bottom sheet), select among visible journeys, archive, delete, another plan, 6/9/12-month horizon, season Hijri year or undecided, date certainty, departure/return countries and intended dates.

Tests: widget planner (create/save, horizon); math (create/edit/archive/delete).

Gaps (present, not invented):

- **Edit plan**, **Archive**, and **Delete** sit on the expanded journey card with **no confirmation**. Delete is irreversible in the store.
- Edit plan is easy to open accidentally (Phase 3B-2F).
- Target season is a free-text Hijri year plus “undecided”; there is no season catalog.
- The journey card is expanded by default, so destructive actions are immediately visible.

### 3. International pathway selection and confirmation

**Class:** Fully implemented and tested.

Six planning families (`HajjPathwayFamily`) are suggestions only. `suggestHajjPathways` never auto-selects. The person must confirm routes (`pathwaysConfirmedByUser`). Unknown route is shown on Journey summary.

Tests: `hajj_planning_engine_test.dart` (all six families; unknown route unconfirmed); widget `pathways need confirmation and templates stay planning estimates`.

Emulator: **Route not confirmed**, **0 confirmed**, duplicated “Planning pathway is not confirmed yet” in the summary.

### 4. Family and traveler-specific planning

**Class:** Implemented but needing refinement.

Travelers store role, optional display name, nationality vs residence, passport **expiry** (no number), residence expiry, health notes, per-traveler readiness. Saving a traveler can attach them to the selected journey.

Tests: separate nationality/residence; independent traveler readiness; widget traveler save; document notices (missing/expired are not neglect).

Gaps:

- Emulator journey has **0 traveler(s)** while templates and sources already exist — companions are optional and easy to skip.
- `HajjMilestone.travelerIds` is persisted but the milestone sheet does not offer traveler assignment. Traveler-specific milestone blockers are therefore **partial at the UI**.
- Mixed-family pathway is a suggestion only; there is no per-person route board.

### 5. Readiness categories and prerequisites

**Class:** Fully implemented and tested.

Nine groups / ten seeded items (`kHajjReadinessCatalog`). Statuses include unanswered, confirmed by you, not applicable. Confirmed-by-user is not official verification.

Journey readiness and traveler readiness are independent.

Tests: math + widget readiness details.

Emulator: **0 of 10 confirmed by you**.

### 6. Backward planning and milestone scheduling

**Class:** Implemented but needing refinement.

`applyHajjPreparationTemplates` seeds conservative lead/processing/float days from an **anchor** (intended departure, expected Hajj period start, or return). `recalculateJourneyMilestones` walks dependencies and never overwrites `officialDeadline`. Untitled legacy rows can be named or deleted. Unscheduled milestones can save.

Tests: engine backward scheduling; math date recalculation; widget empty/invalid/unscheduled; dependency loop blocked.

Gaps:

- Templates without an anchor date produce titled pending rows with **no calendar dates**.
- Planning Calendar is the **last** Hajj card, collapsed, after online/sources/providers (`07_hajj_calendar.png`).
- Horizon grouping (past / in-horizon / beyond / unscheduled) works; remaining preparation time is not a first-class Home summary.

### 7. Critical-path and schedule-conflict detection

**Class:** Implemented but needing refinement.

Engine: longest path by processing + float (`hajjCriticalPathIds`); untitled titles excluded; float-too-short vs typed official deadline; start/completion after official; prerequisite after official; cycles rejected.

UI: Journey summary lists critical titles; calendar rows show Upcoming / Overdue (your dates) and the first conflict.

Inconsistency: `hajjMilestoneIsCritical` is **true for any undoned milestone with an official deadline**, not for the engine critical path. Calendar “Critical ·” can disagree with Journey summary.

Journey summary shows **only the first** conflict and **only the first** confirmation notice.

### 8. Document and official-source tracking

**Class:** Implemented but needing refinement.

Documents: passport/residence expiry notices on travelers; readiness items; no uploads (product-correct).

Sources: manual add; demo lookup; live Worker lookup (opt-in URL); origin `userEntered` / `demonstration` / `liveWorker` (Phase 3B-2G); verification independent; HTTP 200 is not verification; conflicts listed, not auto-chosen.

Providers: slots + empty state; demonstration never “authorized”.

Tests: source worker, online contracts, widget consent, Hive origin correction.

Gaps:

- Worker-unavailable is a **SnackBar** (default short duration, easy to miss; not a persistent banner).
- Online card duplicates “Live official-source information” and still says lookup is off until a Worker URL is configured **while live URL is compiled in**.
- Consent switch still says “demonstration catalog on this device” in a live-configured debug build.
- Tapping a source toggles verified-by-you with no dedicated review screen.
- `DemoMinistry` is a **user-entered** title, not a demo catalog row (see `PHASE_3C_UX_REVIEW.md` and Stage 3).

### 9. Budget and return-travel scenarios

**Class:** Implemented but needing refinement.

Budget: `budgetNote` and `planning.budgetAmount` on the **Edit plan** sheet only; a template milestone “Budget and payment readiness”; readiness “Financial preparation noted”. There is no dedicated budget card or payment schedule.

Return: three scenarios (standard, early after rites, different country) with optional costs; missing costs show **Not estimated**, not zero; unused package not assumed refundable; rites must not be omitted.

Tests: engine return comparison; online assist missing-cost test.

Emulator: Return scenarios summary **Standard package return**.

### 10. Religious learning and After Hajj

**Class:** Fully implemented and tested.

Home **LEARN & PRACTICE (Hajj)** is independent of standing/journey. Readiness-learning catalog (cited Qur’an/hadith, self-reported states) is always available. After Hajj: optional reflection, continuing practice ids, return intention; not auto-filled when standing is performed.

Tests: Learn catalog independent; After Hajj empty after performed; widget Learn without a journey.

Emulator: Learn collapsed at top; After Hajj **Optional**.

---

## Stage 3 — Data integrity (Phase 3B-2G)

Confirmed from code, tests, and emulator source rows (`06` / `07` screenshots):

| Check | Result |
| --- | --- |
| Origins distinct | `userEntered`, `demonstration`, `liveWorker` stored and labelled separately |
| Verification independent | All five emulator rows **Unverified**; live HTTP 200 does not set verified |
| No blanket reclassify | Manual `src.manual.*` stays user-entered; only missing-origin `src.live.*` / `liveHttp` inferred |
| Standing / journey | Lookup upserts sources only; standing remained **I believe it is due**; season undecided |
| Schema | Still version **1**; decode of sources without `origin` still works |

**DemoMinistry:** Title is not metadata. On device it is **Entered by you · Unknown retrieval · Unverified**. Treat as a user-typed label, not a demonstration catalog or ministry feed.

---

## What is not implemented (do not treat as present)

- Live government eligibility, quotas, or booking.
- Paid or remote AI interpretation (on-device demo only; live interpret throws).
- Provider search, rankings, or payments.
- Automatic official verification from HTTP 200.
- Spiritual scores, streaks, or istita‘ah calculation.
- Physical-device USB validation (pending).
- Cloudflare staging Access / deploy (out of this phase).
