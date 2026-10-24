# History and My Response mapping (Phase R0)

Production routes stay until a later phase is approved. This table is the proposed **access map**, not a deletion list.

Current shell: Home (0) · Review (1) · History (2) · My Response (3).

Proposed shell (after approval): Home · Review.

---

## History tab (`HistoryScreen`, `/history`)

| Existing function | Where it lives today | Proposed place on Review | Notes / trade-off |
|---|---|---|---|
| List saved check-ins newest-first in week groups | History list | Calendar + optional week-grouped list under “History in this window” | Empty days **shown** on calendar (today History hides them). Need a toggle “Saved only” to match old list density |
| Filter All / 30 / 90 | History chips | Period chips (7/30/90) + **All saved days** Review panel (date filter, open record) | **7-day is new** on the period calendar. All-time is **not** a Review period chip. Mockup demonstrates the panel; production can push existing `HistoryScreen` |
| Empty state + start today’s check-in | History empty | Review empty copy + Home | Preserve “start today from Home” |
| Guard copy (`Copy.historyGuard`) | History header | Day sheet + calendar intro | Keep: edit does not duplicate |
| Edit check-in | Row / sheet → `CheckInScreen(date: parseDateKey)` | Day sheet **View / Edit this record**; domain card **View / Edit a record** | Same constructor; upsert by `dateKey` |
| Remove check-in + confirm dialog | Row / sheet | Day sheet **Remove check-in (confirm)** | Must keep two-step confirm. Mockup uses `alert` only |
| Overflow menu (edit/remove) | History row | Day sheet actions | Acceptable if all actions visible |
| Display calendar / first day of week | History week labels | Calendar headers | Reuse prefs; mockup is Monday-first synthetic |
| Open a day with no record | Not in History (row absent) | Calendar empty day → “No check-in”; Edit may create the document once | This is Recorded Days behaviour merging in — good, but must not auto-create on tap |

**Must not drop:** All-time list, confirm-remove, edit-in-place, empty History CTA.

**If All-time is too cramped on the dashboard:** keep `HistoryScreen` as a push from Review (“All saved days”) **without** a fourth tab. The refined mockup uses that panel pattern (filter + open record, then back to Review).

---

## Recorded Days / Historical Reflection (`RecordedDaysScreen`)

| Function | Today | Proposed |
|---|---|---|
| Period-scoped week grids with empty cells | Look closer | In-dashboard calendar |
| Legend saved vs empty | Recorded Days | Strip + calendar legend |
| Day evidence (read-only marks) | `DayEvidenceScreen` | Day sheet summary; full evidence can remain a “More detail” push |
| Add response with period provenance | Button | Review footer + day sheet |
| Empty-as-empty note | Copy | Calendar intro |

Look closer as a **separate page** can recede once the in-Review calendar is trusted. Do not delete the route in R0.

---

## Recognition (`RecognitionScreen`)

| Function | Today | Proposed |
|---|---|---|
| Blocked explanation on 7-day | Full page | Insight card: not enough window for Recognition patterns |
| Coverage + pattern list 30/90 | Full page | Progressive disclosure under Reflection insights |
| Subject eligibility via personalisation | Engine | Unchanged engine; UI only moves |
| Jump to day evidence | Pattern tap | Select that date on the calendar |

---

## Ponder (`narrativeCopy`)

| Function | Today | Proposed |
|---|---|---|
| Salah/reading narrative vs prior | Ponder card | Comparison note + insights; **must stay descriptive** |
| Insufficient evidence copy | Ponder | Comparison note (already in mockup) |

Do not retitle Ponder as “you are improving spiritually.” Keep `PeriodNarrative` enum semantics.

---

## Domain Progress

| Function | Today | Proposed |
|---|---|---|
| Salah Progress full page | Mosaic tap | Domain card expand; **Progress route retained** as “More detail” |
| Optional domain progress | Mosaic tap | Same |
| Filters, Hajj/Productivity special pages | Progress | Unchanged entry from expand or existing Home cards |

---

## My Response (`ResponseListScreen`)

| Function | Today | Proposed |
|---|---|---|
| Independent notes list | Tab 3 | Review: **My Response** → active list with provenance |
| FAB add response | Tab 3 | **Add a response from this period** (and from a day sheet) |
| Provenance display | Subtitle | Unchanged model; mockup stamps period or day on add |
| Archive section | List | **Archived** chip; archive / restore without delete |
| Editor / detail | Push routes | Mockup in-place edit; production can keep editor routes |
| Add from Review / Recorded Days | Existing buttons | Footer + day sheet |

**Trade-off:** burying the full list inside Review can hide archived notes. Mitigation: Active / Archived chips on the same panel, or push the **existing** `ResponseListScreen`. Do not add a fourth bottom tab.

---

## Home

Daily recording, week grids, Quick tap, Hajj, Productivity stay on Home. Review does not become a check-in form.

---

## Functions that look similar but are not duplicates

- History (mutate saved documents) ≠ Recorded Days (period calendar including empties) ≠ Review mosaic (aggregates) ≠ My Response (separate notes).
- The redesign **merges presentation**, not stores.

## Routes to keep until R1+ approval

`/review`, `/history`, Response list/editor/detail, Recorded Days, Recognition, Salah Progress, Optional Domain Progress, Check-in.
