# Mockup test report (Phase R0)

Opened `docs/review_mockup/review_dashboard_prototype.html` via a local HTTP server (browser tools cannot load `file://`). Synthetic data only. Production Flutter not launched.

## Pass / fail

| Check | Result |
|---|---|
| 7 / 30 / 90 switching | **Pass.** 7 → 15–21 Oct 2026, 7 strip cells. 30 → 22 Sept–21 Oct, 26 saved / 10 domains. 90 → 24 Jul–21 Oct, 90 strip cells. Counts, charts, calendar, and comparison copy all change together |
| Domain expand / collapse | **Pass.** Salah starts expanded (Hide + extra copy + actions). Other cards Show. Tap toggles `open` |
| Chart selection | **Pass as prototype.** Tapping the compact chart is the same as expanding the card (no separate drill). Titles on bar segments are `title` attributes |
| Date selection | **Pass.** Calendar day 21 opens “2026-10-21 · saved check-in” with Salah/Qur’an/Dhikr rows and hidden private text. Gold outline on selected day |
| History access | **Pass as in-page calendar.** Empty days remain visible. Saved-only week list is not a separate widget |
| Record-edit entry | **Prototype.** View/Edit shows a browser `alert` describing `CheckInScreen(date:)` upsert. Remove shows confirm `alert`. No Hive write |
| Empty-data | **Pass.** Density “No records”: 0/0, dashed strip, “Not enough recorded information…”, domain stack replaced, empty is not missed |
| Sparse-data | **Pass** (control present). Typical already has gaps in the strip. Sparse uses ~1/7 days |
| Responsive | **Pass.** Mobile frame ~420px. Larger screen: two columns, companion pane. CSS `@media (min-width: 980px)` also applies without the select |
| Text scaling | **Partial.** Native browser zoom works; no in-mock 1.3/1.5 control. Long range label wraps on the 390-wide frame |
| Colour-independent meaning | **Pass.** Saved vs empty = fill vs dashed outline; labels on every observation; selected day uses outline plus date heading |
| Keyboard | **Pass for chips, cards (`tabindex`), days (buttons), Enter toggles card.** Not a full Flutter focus-order test |
| Period consistency | **Pass** for labels and card observations |
| Reduced nav | **Pass as stub.** Home \| Review. Home hides Review body. Production Home unchanged |

## Screenshots

- `docs/review_mockup/01_mobile_review_30day.png`
- `docs/review_mockup/02_mobile_review_7day.png`
- `docs/review_mockup/03_mobile_history_and_cards.png` (full-page: domain cards, insights, calendar)
- `docs/review_mockup/04_mobile_empty.png`
- `docs/review_mockup/05_desktop_review_30day.png`

## Prototype-only interactions

- View/Edit and Remove: `alert`, not `CheckInScreen` / Hive
- My Response list / Add response: in-page sheet, not `ResponseListScreen`
- Density and Layout selects: demonstration only, not product settings
- Synthetic hash data, labelled in the banner
- Home tab: copy stub
- Chart tap has no unique payload beyond expand
- Monday-first calendar; production should follow `firstDayOfWeek` prefs

## Issues noted (mockup, not production)

- Copy sometimes says “1 days” (plural)
- Date-range line wraps on the narrow frame
- Collapsed card extra copy is still in the DOM (`display:none`); screen readers may still hear it
- 90-day calendar is dense on a phone (expected; progressive disclosure needed in Flutter)

## Production code

No Flutter files were modified in R0. Unrelated uncommitted work was left untouched.
