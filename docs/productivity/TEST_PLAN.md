# Productivity — Test plan (P0)

**Status:** Matrix for P1+. No production tests added in P0.

Privacy: synthetic titles only. Never assert on real journal-like notes.

---

## 1. Domain / store

| Id | Case |
| --- | --- |
| D1 | Empty store schemaVersion 1 |
| D2 | Action round-trip JSON (priority, status, remaining, dates, parent, prerequisites) |
| D3 | Depth > 3 rejected |
| D4 | Today’s five cap 5; sixth select refused |
| D5 | Recommended next skips paused and blocked |
| D6 | Completing last prerequisite clears derived blocked |
| D7 | Carry-forward at date-key change emits event, keeps unfinished focus |
| D8 | Completed yesterday does not carry forward |
| D9 | Events append; effort/priority/date revisions recorded |
| D10 | Corrupt document isolated; healthy actions remain |
| D11 | `synthetic: true` on fixtures |

## 2. Dashboard widget tests (P1 acceptance)

| Id | Case |
| --- | --- |
| W1 | Shown domain opens dashboard (key `productivity-dashboard`) |
| W2 | Add action from dashboard; title appears in MAL and optionally today’s five |
| W3 | Today’s five visible; reorder up/down changes order |
| W4 | Priority change (levels 1–4) on card without a new `MaterialPageRoute` |
| W5 | Start → Pause → Resume → Complete on card |
| W6 | Expand card shows child; grandchild when present |
| W7 | MAL expansion; select into today’s five |
| W8 | History panel lists a completion event after Complete |
| W9 | Blocked card shows prerequisite title |
| W10 | Carry-forward notice when fixture date is yesterday unfinished |
| W11 | Empty state has Add, no crash |
| W12 | 360×800, text scale 1.5, no RenderFlex overflow |
| W13 | Dark theme, priority still has text |
| W14 | Hajj dashboard still builds with Productivity files absent-from-import (compile/lint: no hajj→productivity import) |

Do **not** require a full-screen route for W2–W8.

## 3. Settings / Home integration

| Id | Case |
| --- | --- |
| S1 | Productivity checkbox present; default off on Salah, Qur’an & Dhikr |
| S2 | All domains includes Productivity (Hajj still dormant) |
| S3 | Home stage shows Productivity dashboard when visible |
| S4 | Hidden Productivity: Home omits it; store unchanged |

## 4. Guardrail tests

| Id | Case |
| --- | --- |
| G1 | No copy containing score/streak/rank for Productivity |
| G2 | Unfinished is not labelled missed/failed |
| G3 | Time practices catalog unchanged |
| G4 | DailyCheckIn `recordableFieldCount` still 10 |

## 5. Manual / emulator (P1 boundary)

Reuse running emulator; do not start a second AVD.

- Add three actions, pick two for today, complete one, restart app, confirm persistence.
- Carry-forward: set device date or inject clock in debug — unfinished still listed.
- Narrow phone and 1.5 scale.
- TalkBack: card announces title, status, priority.

Widget tests do not replace this for release of P1.

## 6. Out of P0

No `test/widget/productivity_*.dart` until P1 is approved.
