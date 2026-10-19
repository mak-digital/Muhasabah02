# Productivity — Product requirements (P0)

**Status:** Phase P0 — design and audit only. Not approved for P1 coding.
**Date:** 18 October 2026
**UI authority:** `DASHBOARD_DESIGN_SPEC.md` (dashboard-first amendment). That amendment **supersedes** any earlier multi-screen navigation proposal.

Owner sample dashboard (tablet/web mock): `docs/productivity/dashboard-sample.jpg`. That image is the **layout and interaction reference**. The Flutter app still uses the existing Home / Review shell; the mock’s left navigation is conceptual only.

The earlier “Productivity Tracker Master Development Specification” text was **not present in this repository**. Working product text is this pack plus the dashboard-first amendment.

Hajj stays independent. Productivity must not import Hajj types or Worker code. Hajj remains dormant on Home.

---

## 1. What Productivity is

A **user-owned action planner** for worldly and mixed work the person chooses to notice: study, household, employment, caregiving, learning projects, and similar. It is **not** a worship grade, iman score, hustle badge, or Time & Barakah replacement.

The person opens **one dashboard** and from there plans, starts, pauses, finishes, reorders, and inspects history.

## 2. What Productivity is not

- Not a productivity **score**, streak, leaderboard, or “wasted day” label.
- Not a spiritual ranking. Unfinished work is not a sin record.
- Not Time & Barakah. Time stores eight optional **observations** of intention, attention, action, and balance. Productivity stores **actions with effort, dates, and dependencies**.
- Not the existing Home **listed-actions** strip (`muhasabah_domain_actions_v1`). That strip stays on Salah and other domain Homes (five chips, soon/week/later). Productivity has its own store and richer model.
- Not DailyCheckIn field 11. It does not change `recordableFieldCount`.
- Not cloud, AI, or telemetry. Private titles and notes never log.
- Not Hajj milestones, Nusuk, or official deadlines.

Missing or unanswered days are **not negative**. An empty dashboard is a quiet list, not a fail.

## 3. Placement in the app

| Surface | P1 intent (after approval) |
| --- | --- |
| Settings → Domains in Focus | **Productivity** listed, **off** the Salah, Qur’an & Dhikr preset, selectable (unlike dormant Hajj). |
| Home | When shown, the domain body **is** `ProductivityDashboard`. No daily week-trace matrix of worship marks. |
| Review / Progress | Compact counts only if a journey exists in the store; no spiritual mosaic for Productivity. |
| Today’s full check-in | No required Productivity band. Actions live on the dashboard, not as unanswered check-in rows. |
| Quick tap | Out of P1 unless the owner asks. |

Id (proposed): `productivity`. Label: **Productivity**. Short label: **Productivity**. Focus question (orientation only, not a grade): *Which actions did I choose to move today?*

## 4. Core objects

All local, Hive, schema version **1** (proposed box `muhasabah_productivity_v1`).

### 4.1 Action

- Title (required, user text, cap ~200 scalars).
- Optional note (private; never logged).
- Priority (four levels, matching the sample): **1 Critical (Do first)**, **2 High (Important)**, **3 Medium (Do today)**, **4 Low (If time permits)** — numbered colour **and** words. Colour names order of work, not worth or iman.
- Optional tags (sample: Main Activity, Setup, Testing, App Testing, App Improvement, Documentation, Technology). User-owned labels, not scores.
- Status (sample wording): **Not started**, **In progress**, **Needs a look** (blocked, past the date you set, or 0% with remaining work — never “failed”), **Paused**, **Completed**. Deleted is a register state.
- Estimate (hours/minutes) and remaining; a fill bar is **effort used vs planned**, not a grade.
- Remaining effort when known (whole minutes or a short user unit; optional).
- Original estimate when known (optional; for planned vs actual later).
- Target completion date (Gregorian `YYYY-MM-DD`, optional, unknown allowed).
- Parent id (optional). Depth **at most three**: action → child → grandchild.
- Prerequisite action ids (optional). An action is **blocked** while any unfinished prerequisite remains.
- Sort order within Today’s five and within MAL.
- Created / updated timestamps (ISO, local device).

Synthetic flag for tests only.

### 4.2 Today’s five

At most **five** actions marked as today’s focus. Order is user-owned (reorder on the dashboard). Selecting a sixth requires releasing one of the five, with a clear prompt — not silent drop.

### 4.3 Master Action List (MAL)

Every non-deleted action. The dashboard shows it **collapsed** by default. From MAL the person can add to Today’s five, change priority, or open the card expand.

### 4.4 Events (history)

Append-only local events, independent of whether a panel is expanded:

- created, selected-for-today, removed-from-today
- started, paused, resumed, completed
- remaining-effort changed
- priority changed
- target date revised
- carried forward (unfinished focus still open at next local day)
- prerequisite added/cleared
- title edited

Event payloads store ids and numeric/date fields. They must not dump free-text notes into logs.

### 4.5 Day snapshot

For each local date key: which five were focus, which were carried forward, recommended-next id at last write. Used by compact trends. Not a score.

## 5. Behaviours

1. **Add action** — from dashboard; lands in MAL; optional “add to Today’s five” if a slot is free.
2. **Select from MAL** — pick into Today’s five (cap 5).
3. **Reorder** today’s five.
4. **Change priority** on the card (one or two taps).
5. **Start / pause / resume / complete** on the card.
6. **Update remaining effort** inline or in a compact sheet.
7. **Expand** children and grandchildren inline.
8. **Prerequisites** — view and edit; blocked cards show **what** is blocking, in words.
9. **Target date** — change without leaving the dashboard (sheet allowed).
10. **Carry-forward** — unfinished today’s items appear next day without retyping. A notice lists them.
11. **Recommended next** — first of today’s five that is not blocked and not paused, else first unblocked carry-forward, else empty state (“Nothing queued”). Never “you failed yesterday”.
12. **History / trends** — expandable; inspect events; compact planned vs actual when both estimates exist.

## 6. Carry-forward rule

At the first dashboard open after local midnight (or when the date key changes):

- Today’s five that are not Completed remain focus **and** emit a carry-forward event if they were already focus yesterday.
- Completed items leave the five; MAL keeps them as completed.
- The person may drop an item from today’s five without deleting it.

No streak. No penalty copy.

## 7. Blocked actions

Status **Blocked** is derived when prerequisites are unfinished, and may also be set by the person. The card must name the unfinished prerequisite titles. Completing the last prerequisite clears Blocked unless the person set it by hand.

## 8. Privacy and guardrails

- No telemetry of titles, notes, or events.
- Tests use synthetic titles (`Action A`, `Child 1`).
- No traffic-light **spiritual** meaning. Priority uses numbered discs 1–4 **and** the words Critical / High / Medium / Low. Colour names work order, not iman.
- Illness, caregiving, rest, and empty days are valid. Copy must not shame them.

## 9. Acceptance (product, after P1)

See `DASHBOARD_DESIGN_SPEC.md` § implementation acceptance. P0 does not ship UI.

## 10. Open questions for the owner (do not block P0 docs)

These wait for a short owner note before P1:

1. Effort: sample uses hours (`1h`, `0.5h`). Confirm hours+minutes, not a free “sessions” unit.
2. May an action optionally **link** to an existing domain-action id, or must the two lists stay fully separate?
3. Should completed MAL items auto-archive after N days, or only by hand?
4. Confirm sample tabs stay **sections** (not Planner/Analytics routes).
5. Confirm “Needs a look” instead of sample “Needs Attention”.
6. Learn & Practice catalog for Productivity — **out of P1** unless asked.
