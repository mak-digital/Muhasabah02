# Productivity — Implementation roadmap

**Status:** P1 dashboard is in the app (owner approved 18 Oct 2026). Later phases still wait for an explicit ask.
**Do not:** deploy, activate AI, commit, push, or merge unless asked.

---

## Phase P0 — Design and audit (this pack)

**In:** these documents, requirement mapping, wireframes, test matrix, boundary with Time & Barakah and Hajj.
**Out:** Dart UI, Hive box, `MonitorDomain.productivity`.
**Exit:** owner review of `DASHBOARD_DESIGN_SPEC.md` against [`dashboard-sample.jpg`](dashboard-sample.jpg).

Audit notes (repository, 18 Oct 2026):

- No in-repo master spec or HTML mockup.
- Hajj is dormant (listed, not selectable).
- Time & Barakah V1 is observation practices `time.t01`–`t08`, not a task list.
- Home listed actions (`kActionStripCap` 5, `ActionPriority` soon/week/later) must **not** be overloaded as the Productivity store.
- DailyCheckIn stays schema v6 / 10 recordable fields.

## Phase P1 — Dashboard shell (only after approval)

Must meet `DASHBOARD_DESIGN_SPEC.md` § 9:

- `MonitorDomain.productivity` + wash/mark (selectable, off basic preset).
- Hive `muhasabah_productivity_v1` schema 1: actions + events.
- Home opens `ProductivityDashboard`.
- Add action, today’s five, reorder, priority, status (planned / in progress / paused / completed) **on the dashboard**.
- MAL expandable; select into today’s five.
- Events written; history panel can list them.
- Widget tests for those interactions.
- Narrow phone + 1.5 scale, no overflow.

**Not in P1 unless time remains:** grandchild depth UI polish, planned-vs-actual charts, tablet three-pane.

## Phase P2 — Hierarchy and blockers

- Child / grandchild expand.
- Prerequisites; derived Blocked; copy names the blocker.
- Remaining effort update.
- Target date sheet.

## Phase P3 — Carry-forward and day rollover

- Local-date rollover without re-entry.
- Notice band.
- Day snapshots for trends.

## Phase P4 — Trends, tablet, a11y pass

- Compact planned vs actual, priority-change and date-revision lists.
- Width ≥ 600 lp three-pane.
- TalkBack labels, reorder buttons, contrast.

## Phase P5 — Fit and finish

- Review tab compact summary (optional).
- Guide/FAQ entries.
- Product spec + accepted_product_state + guardrails updated to match shipped behaviour.
- Emulator smoke on the already-running device (reuse; do not start a second AVD).

---

## Suggested file layout (P1, not created in P0)

```
lib/domain/productivity_planning.dart
lib/data/productivity_store.dart          # Hive box, schema 1
lib/presentation/home/productivity_dashboard.dart
test/domain/productivity_planning_test.dart
test/widget/productivity_dashboard_test.dart
```

Hajj files must not import these. Productivity must not import Hajj.

## Sequencing constraint

Do not start Fasting overflow work, Home title leftovers, or Hajj 3C-1 in the same change as P1.
