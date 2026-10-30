# Phase 3C-1 — UX implementation proposal

**Status:** Design gate — **not approved for coding until the owner says so.**  
**Date:** 18 October 2026  
**Basis:** `PHASE_3C_FUNCTIONAL_AUDIT.md`, `PHASE_3C_UX_REVIEW.md`, `PHASE_3C_IMPROVEMENT_BACKLOG.md` (E1–E5), `PHASE_3C_IMPLEMENTATION_PLAN.md`, screenshots in `docs/hajj/phase3c_screenshots/`.  
**Out of this proposal:** 3C-2 intelligence (P1–P5), 3C-3 polish, Cloudflare, AI, paid services, Productivity domain, Fasting / Home-title work.

The Hajj Planner stays a **self-contained Home domain**: standing, store, calendar, and online assist do not read a Productivity feature. If Productivity appears later on Home, Hajj cards must still compile and run with it absent.

---

## 1. Current versus proposed main-screen layout

Hajj Home today is a vertical stack of **twelve planner cards** after standing (plus Learn & Practice and the empty Hajj week, which stay as they are). Nothing is deleted in 3C-1. Cards are **reordered, grouped, and default-collapsed** so the person sees preparation first and network tools last.

### Current order (as coded)

From `HajjHomeDashboard` and `03` / `07` screenshots:

| # | Card | Default |
| --- | --- | --- |
| — | Hajj standing | Always open |
| 1 | My Hajj Journey | **Expanded** (Edit / Archive / Delete visible) |
| 2 | Journey summary | **Expanded** (long critical-path paragraph) |
| 3 | Planning pathways | Collapsed |
| 4 | Readiness & Prerequisites | Collapsed |
| 5 | Family & Companions | Collapsed |
| 6 | Return scenarios | Collapsed |
| 7 | Readiness learning | Collapsed |
| 8 | After Hajj | Collapsed |
| 9 | Online assistance | Collapsed (often opened; duplicate live copy) |
| 10 | Official sources | Collapsed |
| 11 | Provider information | Collapsed |
| 12 | Planning Calendar | **Last**, collapsed |

### Proposed order (3C-1)

Four bands. Same twelve bodies; two **chrome** rows added (next-action, upcoming strip).

```
┌─────────────────────────────────────────┐
│ LEARN & PRACTICE (Hajj)     unchanged   │
│ Hajj week question          unchanged   │
├─────────────────────────────────────────┤
│ BAND A — Always in view                 │
│  Hajj standing                          │
│  Next on this plan          NEW         │
│  My Hajj Journey            collapsed   │
│    [Change this plan]       overflow    │
├─────────────────────────────────────────┤
│ BAND B — Preparation (open calendar)    │
│  Planning Calendar          moved up    │
│    Upcoming on this plan    0–3 rows    │
│    month list (existing)                │
│  Journey summary            quieter     │
│  Family & Companions                    │
│  Planning pathways                      │
│  Readiness & Prerequisites              │
├─────────────────────────────────────────┤
│ BAND C — Optional later                 │
│  Return scenarios                       │
│  Readiness learning                     │
│  After Hajj                             │
├─────────────────────────────────────────┤
│ BAND D — Network (last)                 │
│  Online assistance          copy fix    │
│  Official sources                       │
│  Provider information                   │
└─────────────────────────────────────────┘
```

| Proposed # | Section | Default when a journey exists | Notes |
| --- | --- | --- | --- |
| A0 | Standing | Open | Unchanged widget |
| A1 | **Next on this plan** | Open if a step exists | Not a 13th domain; one text + one button |
| A2 | My Hajj Journey | **Collapsed** | Header: season · lifecycle. Actions behind **Change this plan** |
| B1 | Planning Calendar | **Expanded** | Was card 12. Upcoming strip at top of body |
| B2 | Journey summary | Collapsed | Max three lines; no duplicate pathway sentence |
| B3 | Family & Companions | Collapsed | Raised (next-action often points here) |
| B4 | Planning pathways | Collapsed | Unchanged body |
| B5 | Readiness | Collapsed | Unchanged body |
| C1–C3 | Return, learning, After Hajj | Collapsed | Unchanged bodies |
| D1–D3 | Online, sources, providers | Collapsed | Online copy + banner only |

**No journey yet:** Band A shows standing, next-action = create plan, journey card expanded with existing invite + `Create a Hajj plan`. Calendar stays collapsed with “Opens with a plan”. Bands C–D unchanged.

**Consolidation rule:** Do not merge Family into Journey or Sources into Online in 3C-1. Progressive disclosure only. Keys `hajj-*-card` stay so tests can `scrollUntilVisible`.

### Annotated phone layout

```
  Private Muhasabah                    Guide  ⚙
  TODAY : Sunday, 18 Oct 2026
  [ Start check-in ]  [ Quick tap ]
  [<]  Hajj  [>]

  LEARN & PRACTICE (Hajj)                    ▾

  Hajj
  Have I named how Hajj stands with me…
  Hajj standing
  [ I believe it is due            ▾ ]
  Lifetime record you set, not a ruling.

  ┌ Next on this plan ─────────────────────┐
  │ Add who is travelling.                 │  ← derived, not scored
  │ This is optional. Missing is not a     │
  │ shortcoming.                           │
  │ [ Open Family & Companions ]           │
  └────────────────────────────────────────┘

  ┌ My Hajj Journey · Considering      ▸ ─┐  ← collapsed
  │ Season undecided                       │
  │ [ Change this plan ]                   │  ← not Edit plan
  └────────────────────────────────────────┘

  ┌ Planning Calendar · 12 months      ▾ ─┐  ← moved up, open
  │ Upcoming on this plan                  │
  │  (empty) No dates you typed yet.       │
  │  Planning estimates are not deadlines. │
  │ Horizon [6] [9] [12]  [ + Milestone ]  │
  │ 2026-10 … existing month tiles …       │
  └────────────────────────────────────────┘

  Journey summary · Route not confirmed    ▸
  Family & Companions · 0 traveler(s)      ▸
  Planning pathways · 0 confirmed          ▸
  Readiness · 0 of 10 confirmed by you     ▸
  Return scenarios                         ▸
  Readiness learning                       ▸
  After Hajj                               ▸
  Online assistance · Offline              ▸
  Official sources · 5 stored              ▸
  Provider information                     ▸
```

Reference shots of the **current** clutter: `03_hajj_mid_cards.png` (actions + summary), `07_hajj_calendar.png` (calendar last).

---

## 2. Next-action presentation

**New UI:** one card `hajj-next-action-card` under standing. Title: **Next on this plan**. Body: one sentence + one `OutlinedButton` that expands/scrolls the matching existing card. No new dates, quotas, or “you should have”.

**Derivation:** first match only, using fields already on `HajjStore` / `HajjJourneyPlanSummary`. Helper (e.g. `hajjNextPreparationAction`) in domain next to `buildHajjJourneyPlanSummary` — **priority list, not a new scheduler**.

| Priority | Condition (existing data) | Copy (missing ≠ failure) | Button target |
| --- | --- | --- | --- |
| 1 | No visible journey | You may keep a plan here if you want. | `hajj-create-journey` / journey card |
| 2 | `store.travelers.isEmpty` | Add who is travelling, if anyone. Optional. | Expand Family |
| 3 | `summary.unknownRoute` | Confirm a planning route when you know it. | Expand Pathways |
| 4 | No milestone with `officialDeadline` or `plannedDate` | Open the calendar to record a date you already know, or add a planning estimate. | Expand Calendar |
| 5 | Any milestone `hajjMilestoneAttention == overdue` | A date you typed is before today. Review it on the calendar. | Calendar, that row |
| 6 | Else any `upcoming` (≤14 days, existing helper) | A date you typed is within two weeks. | Calendar |
| 7 | Else `readinessAttention` not empty | Continue the readiness list you have not confirmed. | Expand Readiness |
| 8 | Else | No required next step. Learn & Practice and After Hajj stay available. | No button, or Learn |

**Not used in 3C-1:** live Worker, demo lookup, AI, inventing Hajj day, counting unconfirmed readiness as “behind”. Online lookup is never the next action.

Emulator example (current store): standing due, season undecided, 0 travelers, route unconfirmed → **priority 2** (add travelers), not “request bookmarks”.

---

## 3. Calendar prominence

1. Move `hajj-calendar-card` from last to **first preparation card** (Band B).  
2. When a journey exists, **initiallyExpanded: true**.  
3. **Upcoming on this plan** (inside calendar body, above months): up to three milestones already flagged by `hajjMilestoneAttention`, preferring `officialDeadline` then `plannedDate`. Label overdue **Overdue (your dates)** / upcoming **Upcoming**. If none: “No dates you typed yet.” Do **not** list recommended windows as upcoming (those stay estimates inside month tiles).  
4. Keep horizon chips, add milestone, past / beyond / unscheduled groups.  
5. Next-action priorities 4–6 scroll here.

3C-2 remains responsible for renaming “Critical ·” to the engine path (P1) and remaining-day counts (P2). 3C-1 only **surfaces** existing attention.

---

## 4. Safer editing

**Current:** five outlined buttons on an expanded journey card (`03`): Edit plan, Another plan, Archive, Apply preparation template, Delete — Archive/Delete with **no confirm**.

**Proposed:**

| Gesture | Result |
| --- | --- |
| Tap journey **header** | Expand/collapse **read-only** list (season, lifecycle, date certainty). Does **not** open the edit sheet. |
| Tap a journey **row** | Select that journey (existing `selectJourney`). |
| **Change this plan** | Opens a small menu / bottom sheet of actions. |
| Edit details | Existing `_openJourneySheet` (`hajj-edit-journey`). |
| Another plan | Existing create sheet (`hajj-create-journey` remains for empty state; also in the menu). |
| Apply preparation template | Dialog: “Adds planning-estimate milestones. Not official requirements.” Then existing `applyHajjPreparationTemplates`. |
| Archive | Confirm: “Hide this plan from the list. Standing is unchanged.” Then `archiveJourney`. |
| Delete | Confirm: “Remove this plan from the phone. Standing, sources, and travelers stay.” Then `deleteJourney`. |

**Create a Hajj plan** stays a filled button when `visibleJourneys.isEmpty` (current empty state). After a plan exists, create is only under **Change this plan** so tests that create from empty still work; tests that apply templates must open the menu first (same keys).

Do not change the journey **Save** sheet fields in 3C-1 (season, dates, budget stay). No recalc-on-save (that is P4 / 3C-2).

---

## 5. Online assistance copy and unavailable notice

### Exact current problems (`04` / `06`, `HajjOnlineAssistPanel`)

| Location | Current text | Defect |
| --- | --- | --- |
| Line 1 | `Copy.hajjOnlineDefault` → *Offline by default. Nothing is sent until you opt in.* | Fine as default; keep **once**. |
| Line 2 | If consented and live URL set: `Copy.hajjLiveMode` → *Live official-source information* | Duplicated by line 3. |
| Line 3 | If live URL set: **again** `Copy.hajjLiveMode`; else `kHajjOnlineNoLiveBackend` | Duplicate when live; when not live, line 3 contradicts line 2 demo copy. |
| Switch | `Copy.hajjConsentLookup` → *Allow official-source bookmarks (demonstration catalog on this device)* | Wrong when `hajjLiveLookupConfigured`. |
| Body | `Copy.hajjConsentBody` includes *Live lookup stays off until a Worker URL is configured.* | False in a debug build with `--dart-define=HAJJ_LIVE_BASE_URL`. |
| SnackBar | *Live official lookup is unavailable.* | Disappears; often not in the semantics tree. |

AI switch copy (*demonstration only; not a live model*) stays — AI is still not enabled.

### Proposed single mode line

One `Text` (`hajj-online-mode`):

| State | Mode line |
| --- | --- |
| Lookup consent off | Offline. Nothing is sent. |
| Consent on, no live URL | Demonstration catalog on this device. Not a live government feed. |
| Consent on, live URL compiled in | Live Worker bookmarks. Unverified. HTTP 200 is not official verification. |

Remove the second `Copy.hajjLiveMode` widget.

**Lookup switch title:**

- No live URL: keep demonstration wording.  
- Live URL: *Allow official-source bookmarks (live Worker; unverified)*.

**Consent body:** drop “Live lookup stays off until a Worker URL is configured.” Replace with two clauses: (1) if URL empty — demonstration records stay on this phone; (2) if URL set — only season / nationality / residence / departure / pathway labels leave the device. Keep passport/name/reflection prohibition. Keep “AI is not enabled.”

### Persistent unavailable notice

- After a failed lookup (existing `HajjOnlineAssistException`), set a **session** flag (Riverpod/StateProvider). **No schema change** in 3C-1.  
- Banner on the Online assistance card, `Semantics(liveRegion: true, label: …)`, key `hajj-online-status-banner`, remains until the next successful lookup or the person dismisses it.  
- Copy: *Live official lookup is unavailable. Offline planning is unchanged.*  
- SnackBar may still fire once; it is **not** the only signal.  
- Do not log response/journal text.  
- Successful lookup: banner *Last lookup stored on this phone. Rows stay unverified.* (optional, dismissible). Idle: no banner.

Sources list (origin labels from 3B-2G) is unchanged in 3C-1.

---

## 6. Regression protection

Must keep working without behaviour change except layout/copy/safer chrome:

| Workflow | Why it must hold |
| --- | --- |
| Standing vs journey | Lifetime standing; archive/delete do not change standing |
| Create journey from empty | `hajj-create-journey` + `hajj-journey-save` |
| Travelers nationality ≠ residence | Family sheet |
| Pathway confirm | `hajj-pathway-confirm` / save |
| Apply templates = estimates | No `officialDeadline` invented |
| Milestone loop blocked | Prerequisite picker |
| Untitled / invalid / unscheduled save | Calendar sheet |
| Consent off → lookup `onPressed == null` | Online panel |
| Demo lookup unverified | Widget + domain |
| Source origin / verification split | 3B-2G; do not reclassify `DemoMinistry` by title |
| Schema v1 | Additive UI only |
| Offline without Worker | Empty `HAJJ_LIVE_BASE_URL` |
| Learn & Practice without a journey | Independent of planner cards |
| Hajj week not a daily matrix | `hajj_home_test.dart` |

**Tests to keep green (update navigation only if keys move behind a menu):**

- `test/widget/hajj_home_test.dart`  
- `test/widget/hajj_planner_test.dart` (all cases)  
- `test/domain/hajj_planning_test.dart`, `_math_test.dart`, `_engine_test.dart`  
- `test/domain/hajj_online_assist_test.dart`, `_contracts_test.dart`  
- Source worker / live HTTP tests: **do not change contracts**

**Do not:** change Hive schema, Worker JS, Fasting, `home_screen.dart`, `brand_title.dart`, `week_nav_strip.dart`, Productivity.

Widget tests that `scrollUntilVisible(hajj-apply-templates)` will open **Change this plan** first; keep the same keys.

---

## 7. Implementation scope (when approved)

### Files (anticipated)

| File | Change |
| --- | --- |
| `lib/presentation/home/hajj_home_dashboard.dart` | Card order, defaults, next-action, calendar upcoming, journey overflow + confirms |
| `lib/presentation/home/hajj_online_assist_panel.dart` | One mode line, banner, switch title |
| `lib/domain/copy.dart` | Consent / mode strings |
| `lib/domain/hajj_planning_engine.dart` (or small new `hajj_next_action.dart`) | Pure `hajjNextPreparationAction` from existing summary/store |
| `lib/application/providers.dart` | Session lookup-status provider only |
| `test/domain/hajj_next_action_test.dart` | **New** priority-table tests |
| `test/widget/hajj_planner_test.dart` | Menu + banner + no duplicate live line; existing flows |
| `test/widget/hajj_home_test.dart` | Standing still first |

No Worker, no Android release network config, no Productivity files.

### New / extended tests

1. Empty store → next action create plan.  
2. Journey, 0 travelers → next action family (not lookup).  
3. Travelers + unknown route → next action pathways.  
4. Confirmed route, no typed dates → next action calendar.  
5. Typed past `officialDeadline` → overdue copy.  
6. Journey title tap does not open edit sheet.  
7. Delete cancelled leaves journey.  
8. Delete confirmed removes journey, standing unchanged.  
9. `Copy.hajjLiveMode` appears **at most once**.  
10. Failing gateway → banner still on screen after `pump(10s)`.  
11. Family at 1.3 scale still reachable (existing test).  
12. Calendar card appears **above** online card in the tree.

### Screenshots after coding (emulator-5554)

`docs/hajj/phase3c1_screenshots/` — standing + next-action; journey collapsed + Change this plan; calendar with upcoming; confirm-delete dialog; online mode (offline, demo, live); unavailable banner.

### Acceptance criteria (3C-1 exit)

- [ ] Twelve functions still reachable; Hajj does not import Productivity.  
- [ ] Calendar is above Online assistance; expanded when a journey exists.  
- [ ] Next-action uses the table in §2 only.  
- [ ] Edit plan is not a primary journey-card button.  
- [ ] Archive and Delete require confirm.  
- [ ] Duplicate live line gone; live debug build does not say Worker URL is unconfigured.  
- [ ] Unavailable banner remains visible and labelled; store not rewritten on failure.  
- [ ] Focused Hajj tests + analyzer clean; Fasting/Home-title files untouched.  
- [ ] Physical phone still **pending** unless a device appears on `adb`.

---

## What 3C-1 will not do

Critical-path label fix, recalc on departure change, traveler-on-milestone, budget card, source review sheet, Worker deploy, Zero Trust, AI.

---

**Stop.** Please approve this layout (or name changes) before any implementation.
