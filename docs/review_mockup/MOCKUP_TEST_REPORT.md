# Mockup test report (Phase R0 — refined prototype)

Opened `docs/review_mockup/review_dashboard_prototype.html` via `http://127.0.0.1:8788/` (browser tools cannot load `file://`). Synthetic data only. Production Flutter not launched and not modified for this refinement.

Re-checked 2026-10-23: collapsed cards, 7 / 30 / 90, 90-day week then day, All saved days filter + open, My Response add / archive / restore / edit UI, empty + sparse, mobile + larger-screen, text 1.0 / 1.3 / 1.5.

## How to open

Serve `docs/review_mockup/` over HTTP and open `review_dashboard_prototype.html`. Example: local listener on `127.0.0.1:8788`. Do not treat this page as the live app.

## Pass / fail

| Check | Result |
|---|---|
| 7 / 30 / 90 switching | **Pass.** 7 → 15–21 Oct 2026, 6 saved / 10 domains, 7 strip cells. 30 → 22 Sept–21 Oct, 26 saved / 10 domains. 90 → 24 Jul–21 Oct; strip becomes week cells; counts and card observations change together |
| Collapsed domain cards | **Pass.** Each collapsed card shows name, period + last recorded date, compact viz + legend, one evidence sentence, and Show details (`aria-expanded=false`). Expanded Salah/Qur’an add extra copy and View historical / View Edit |
| 90-day weekly calendar | **Pass.** Week rows with saved-of-N and colour-independent dots. Selecting 28 Sept–4 Oct reveals daily cells (saved vs dashed none). Day 1 / 2026-10-01 opens the sheet |
| Day-kind distinction | **Pass as prototype.** Legend: recorded activity, recorded non-participation, unanswered on a saved day, no check-in. Sheet for 2026-10-01 shows unanswered Salah rows, congregation, fasting prefer-not, character practised, private text hidden |
| All saved days | **Pass.** Review panel (not a fourth tab). Filter `2026-09` → 26 of 164 saved days. Open record returns to Review with that date selected. Bottom nav remains Home \| Review |
| My Response | **Pass as in-memory prototype.** Active / Archived chips, add with provenance (`90-day Review`), archive (Active 3→2, Archived 1→2), restore, Edit opens Save edit / Cancel. Synthetic notes only |
| Actionable insights | **Pass.** Buttons jump to domain + date (Qur’an expanded after jump). Copy is counts and recorded dates, not scores or merit |
| Empty-data | **Pass.** 0/0, dashed strip, “Not enough recorded information…”, domain stack replaced, empty is not missed, calendar days remain |
| Sparse-data | **Pass.** About one saved day in seven; cards still render; Fasting/Charity can show “no recorded mark”; lapse insight omitted when count is 0 |
| Responsive | **Pass.** Mobile frame ~420px. Larger screen: two columns + companion pane |
| Text scaling | **Pass.** Toolbar 1.0 / 1.3 / 1.5 via `--scale`. Native zoom still works |
| Colour-independent meaning | **Pass.** Fill vs dashed outline vs tan; chart legends; `aria-label` on days includes kind |
| Keyboard / expand semantics | **Pass for prototype.** Period chips, Show/Hide details (`aria-expanded`, `aria-controls`), week rows `aria-expanded`. Collapsed extra copy is not in the details DOM |
| Period consistency | **Pass** for labels, cards, insights, calendar |

## Screenshots

- `docs/review_mockup/01_mobile_review_30day.png` — collapsed cards with infographic + observation
- `docs/review_mockup/02_mobile_review_7day.png`
- `docs/review_mockup/03_mobile_history_and_cards.png` — 90-day week selected, daily cells, day sheet
- `docs/review_mockup/04_mobile_empty.png`
- `docs/review_mockup/05_desktop_review_30day.png`
- `docs/review_mockup/06_mobile_90day_weeks.png` — week aggregation list
- `docs/review_mockup/07_all_saved_days.png`
- `docs/review_mockup/08_my_response.png`

## Prototype-only interactions

- View/Edit and Remove: `alert`, not `CheckInScreen` / Hive
- My Response: in-page list, not `ResponseListScreen`; state is in memory and resets on reload
- Density and Layout selects: demonstration only
- Synthetic hash data, labelled in the banner
- Home tab: copy stub
- Monday-first calendar; production should follow `firstDayOfWeek` prefs

## Issues noted (mockup, not production)

- Date-range line still wraps on the narrow frame
- 90-day still has a compact week strip *and* a week list; the list is the inspection surface
- Accessibility snapshots of hidden screens can still include `display:none` nodes depending on the inspector; the prototype now sets `hidden` / `aria-hidden` on inactive panels
- Saving an edited archived note switches the list to Active (prototype convenience)
- Larger-screen companion duplicates the day sheet; production should share one widget tree

## Production code

No Flutter, Hive, navigation, domain data, Hajj, or Productivity files were changed for this refinement. Unrelated uncommitted work was left untouched. No commit, push, merge, or deploy.
