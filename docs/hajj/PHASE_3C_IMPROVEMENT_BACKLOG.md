# Phase 3C — Ranked Hajj improvement backlog

**Date:** 18 October 2026  
**Rule:** Essential usability first. Optional extras last. No cloud, AI, or paid services in these items.

Complexity: **S** hours, **M** 1–2 days, **L** several days. All stay on schema version 1 unless noted.

---

## Essential usability corrections

### E1. Stop accidental plan mutation

- **User problem:** Edit plan / Archive / Delete sit on the default-expanded journey card; Archive/Delete have no confirm; 3B-2F opened Edit plan by mistake.
- **Proposed solution:** Read-only journey header. “Change this plan” opens actions. Confirm Archive and Delete. Apply templates behind a short preview (“Adds N planning estimate milestones”).
- **Affected:** `hajj_home_dashboard.dart` `_JourneyBody`; widget `hajj_planner_test.dart`.
- **Complexity:** S–M  
- **Dependencies:** None  
- **Acceptance:** Tapping the journey title does not open the editor. Delete requires confirm. Standing unchanged.  
- **Phase:** **3C-1**

### E2. Persistent Worker-unavailable (and lookup) status

- **User problem:** SnackBars vanish; uiautomator often misses them; Home tabs cover the bottom.
- **Proposed solution:** Durable, semantically labelled banner on Online assistance: unavailable / succeeded / offline. SnackBar optional extra, not the only signal. Do not log private text.
- **Affected:** `hajj_online_assist_panel.dart`; widget tests with `FailingHajjOnlineAssistGateway`.
- **Complexity:** S  
- **Dependencies:** None  
- **Acceptance:** With Worker down, banner remains after 10s; sources/standing/journey unchanged; TalkBack can read the message.  
- **Phase:** **3C-1**

### E3. Honest online/offline copy when a live URL is compiled in

- **User problem:** Duplicate “Live official-source information”; switch still says demonstration catalog; body says Worker URL is not configured while `HAJJ_LIVE_BASE_URL` is set.
- **Proposed solution:** One mode line: Offline / Demonstration catalog / Live Worker (unverified bookmarks). Consent titles follow the actual gateway. Remove the second `Copy.hajjLiveMode` `Text`.
- **Affected:** `hajj_online_assist_panel.dart`, `lib/domain/copy.dart`.
- **Complexity:** S  
- **Dependencies:** None  
- **Acceptance:** No duplicate live line. Debug live build does not claim lookup is unconfigured. Production empty URL still demo/offline.  
- **Phase:** **3C-1**

### E4. Next-action card (offline)

- **User problem:** Twelve cards; no ranked next step. Emulator: 0 travelers, 0 readiness, route unconfirmed, calendar last.
- **Proposed solution:** One “Next on this plan” block under standing: first unmet offline step (create plan → add traveler → confirm pathway → open calendar / typed deadline). Never invent official dates. Missing ≠ failure.
- **Affected:** new small helper from `buildHajjJourneyPlanSummary`; `hajj_home_dashboard.dart`.
- **Complexity:** M  
- **Dependencies:** E1 recommended first so actions are not mixed with next-step.  
- **Acceptance:** With season undecided and 0 travelers, next action names adding companions or a season, not online lookup.  
- **Phase:** **3C-1**

### E5. Collapse noise: Journey summary and card order

- **User problem:** Summary repeats pathway warning; critical path is a comma dump; calendar is below network cards.
- **Proposed solution:** Summary lists at most three bullets (route, next deadline, one conflict). Move **Planning Calendar** above Online assistance. Default-collapse Journey once a plan exists; keep standing visible.
- **Affected:** `HajjHomeDashboard` child order; `_PlanSummaryBody`.
- **Complexity:** S–M  
- **Dependencies:** E4 if next-action replaces part of the summary.  
- **Acceptance:** Calendar reachable without passing Online/Sources. No duplicate pathway sentence.  
- **Phase:** **3C-1**

---

## Planning-intelligence improvements (offline, no regulations invented)

### P1. Align “Critical” with the engine path

- **User problem:** `hajjMilestoneIsCritical` flags any official deadline; summary uses `hajjCriticalPathIds`.
- **Proposed solution:** Calendar prefix “Critical path ·” only when the id is on `hajjCriticalPathIds`. Official-but-not-path stays “Official date you typed”.
- **Affected:** `hajj_planning_math.dart`, `_milestoneTile`.
- **Complexity:** S  
- **Dependencies:** None  
- **Acceptance:** Domain test: official deadline off the longest path is not labelled critical path.  
- **Phase:** **3C-2**

### P2. Show remaining preparation time without scoring

- **User problem:** Windows exist on milestones but Home does not say “N days to your typed date”.
- **Proposed solution:** For the nearest **typed** official or planned date, show days remaining or overdue (your dates). If only estimates exist, label **Planning estimate**. Never invent a Hajj day.
- **Affected:** `hajjMilestoneAttention`, plan summary / E4.
- **Complexity:** S  
- **Dependencies:** E4  
- **Acceptance:** No date stored → no countdown. Typed past date → overdue (your dates), not missed worship.  
- **Phase:** **3C-2**

### P3. Named dependencies and full conflict list

- **User problem:** “Depends on 2”; only first conflict shown.
- **Proposed solution:** Subtitle names predecessor titles. Summary can expand “All schedule notes (N)”.
- **Affected:** `_milestoneLine`, `_PlanSummaryBody`.
- **Complexity:** S  
- **Dependencies:** P1 optional  
- **Acceptance:** Widget or domain test lists both conflicts when two exist.  
- **Phase:** **3C-2**

### P4. Recalculate when the journey anchor date changes

- **User problem:** Edit plan can change departure; templates/windows may stay stale unless the person re-applies templates.
- **Proposed solution:** After saving journey dates, call `recalculateJourneyMilestones` (and template windows if templates already applied). Never overwrite `officialDeadline`.
- **Affected:** `_openJourneySheet` save path; engine tests.
- **Complexity:** M  
- **Dependencies:** None  
- **Acceptance:** Changing intended departure updates recommended windows; typed official dates unchanged.  
- **Phase:** **3C-2**

### P5. Traveler assignment on milestones (optional-looking but useful)

- **User problem:** `travelerIds` exist; UI cannot assign a milestone to a companion; blockers stay generic.
- **Proposed solution:** Multi-select travelers on the milestone sheet; document notices scoped to those people.
- **Affected:** milestone sheet; `hajjTravelerDocumentNotice`.
- **Complexity:** M  
- **Dependencies:** Family list non-empty (E4 helps).  
- **Acceptance:** Two travelers; a passport-expired notice names the right person; standing unchanged.  
- **Phase:** **3C-2**

---

## Optional future (not 3C-1)

### O1. Dedicated budget card

- **User problem:** Amount/note buried in Edit plan.
- **Proposed solution:** Small budget card: amount you typed, note, link to return estimates. No recommended spend.
- **Complexity:** M · **Phase:** **3C-3**

### O2. Source review sheet (not tap-to-verify)

- **User problem:** Tap toggles verification; long provenance truncates.
- **Proposed solution:** Open sheet: origin, verification, URI, limitations; explicit “I reviewed this page”.
- **Complexity:** M · **Phase:** **3C-3**

### O3. Rename-or-explain user titles like DemoMinistry

- **User problem:** Title looks official/demo; origin is user-entered.
- **Proposed solution:** Empty-state hint: “This is your label, not a ministry certificate.” No auto-rename.
- **Complexity:** S · **Phase:** **3C-3**

### O4. Provider directory beyond stored slots

- **User problem:** Empty/demo providers.
- **Proposed solution:** Keep manual notes only until a later approved directory. Do **not** scrape or rank operators.
- **Complexity:** L · **Phase:** later / not 3C

### O5. Cloudflare Access + staging Worker

- Out of this backlog’s implementation until the owner approves Stage 2 deploy. Not a UX patch.

---

## Explicitly out of scope

Spiritual scores, auto-official verification, remote AI, paid Cloudflare, inventing quotas/deadlines, Fasting/Home-title work, git commit/push.
