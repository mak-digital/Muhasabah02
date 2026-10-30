# Fajr 30-day trend — mock-up test report

**Phase:** M1-C  
**Date:** 23 October 2026  
**Prototype:** [`FAJR_30_DAY_TREND_MOCKUP.html`](FAJR_30_DAY_TREND_MOCKUP.html)  
**Browser:** Cursor IDE browser (Chromium), served from `http://127.0.0.1:8876/`  
**Flutter production code:** not modified  
**Hive records:** not read or written  
**Git:** not committed

---

## Visual acceptance

| Viewport | Card | Calendar | Wash | Chart groups | Overflow |
|---|---|---|---|---|---|
| 360 px | 327 × 226 | 106 × 142 | 177 × 126 | 5 | none |
| 390 px | 357 × 226 | 106 × 142 | 207 × 126 | 5 | none |
| 420 px | 387 × 226 | 106 × 142 | 237 × 126 | 5 | none |
| 720 px (desktop frame) | structure unchanged; calendar still 106 × 142 | | | | none |

Card **height stays 226 px**. Calendar **stays 106 × 142** and on the left. Only the wash width tracks leftover inner width. Chart stays inside the wash.

**Before / after:** switching Card content from “Existing statistics text” to “Trend chart” keeps the same measured card, calendar, and wash boxes. Only the wash interior changes (bullet statistics → 5×3 bars).

---

## Screenshots

Saved under [`screenshots/fajr_30_day/`](screenshots/fajr_30_day/).

| File | Content |
|---|---|
| [`01_existing_fajr_card.png`](screenshots/fajr_30_day/01_existing_fajr_card.png) | Existing 30-day Fajr card with statistical text |
| [`02_new_fajr_chart.png`](screenshots/fajr_30_day/02_new_fajr_chart.png) | Same card with trend chart |
| [`03_five_group_chart.png`](screenshots/fajr_30_day/03_five_group_chart.png) | Five groups, fifteen bars, A/B/C under each |
| [`04_tooltip_joined_late.png`](screenshots/fajr_30_day/04_tooltip_joined_late.png) | Tooltip below the card (not over chart or dots): “Joined congregation late”, Period C, 5 of 20, 25% |
| [`09_tooltip_outside_chart.png`](screenshots/fajr_30_day/09_tooltip_outside_chart.png) | Same overlay with transparent background, card fully visible |
| [`10_tooltip_legend_ball.png`](screenshots/fajr_30_day/10_tooltip_legend_ball.png) | Colour ball beside “Prayed late”, matching the yellow calendar/chart colour |
| [`05_incomplete_c.png`](screenshots/fajr_30_day/05_incomplete_c.png) | Incomplete C; C bars use a 3-answered-day denominator |
| [`06_previous_period.png`](screenshots/fajr_30_day/06_previous_period.png) | After previous: C is 25 Aug–23 Sep 2026 |
| [`07_shared_colours.png`](screenshots/fajr_30_day/07_shared_colours.png) | `aloneOnTime` solid lime; `excused` striped lime |
| [`08_360_mobile.png`](screenshots/fajr_30_day/08_360_mobile.png) | 360 px; five groups still fit; no horizontal overflow |

---

## Automated in-page tests (T01–T20)

Executed in the prototype (`runTests()`). All **PASS**.

| ID | Result | Evidence |
|---|---|---|
| T01 | PASS | Baseline vs chart: card width and height differ by &lt; 1 px (357 × 226) |
| T02 | PASS | Calendar width, height, and left edge unchanged (106 × 142) |
| T03 | PASS | `#chart` bounding box is inside `#wash` |
| T04 | PASS | Bar count ≤ 15 and equals selected groups × 3 |
| T05 | PASS | One A/B/C label row per group |
| T06 | PASS | A ends before B starts; C is 2026-09-24 … 2026-10-23 |
| T07 | PASS | Previous window C is 2026-08-25 … 2026-09-23 |
| T08 | PASS | `fajrOn('2026-10-01','normal')` identical at `back=0` and `back=1` |
| T09 | PASS | `pct(6,20) === 30` |
| T10 | PASS | Incomplete scenario: elapsed C days = 5; denom ≤ 5 and &lt; 30 |
| T11 | PASS | Missing / unanswered / future days are not in the denominator |
| T12 | PASS | Explicit `missed` counts in hits and denom |
| T13 | PASS | No-data A: denom 0; `pct(0,0) === null`; `pct(0,10) === 0` |
| T14 | PASS | Selected option ids differ between Normal and Significant-changes |
| T15 | PASS | Stable scenario still selects `congregationOnTime` |
| T16 | PASS | Shared scenario selects both `aloneOnTime` and `excused` |
| T17 | PASS | Tooltip title is “Joined congregation late (Fajr)”; no colour-name description |
| T18 | PASS | Tooltip recorded line is `Recorded: 6 of 20 answered days (30%)` with `Period C (` |
| T19 | PASS | 360 px: no card `scrollWidth` overflow; groups still fit |
| T20 | PASS | Wash remains to the right of the calendar; cal 142 / wash 126 |
| T21 | PASS | Tooltip sits outside calendar and wash; background is transparent |
| T22 | PASS | Legend ball beside the title matches the option colour |
| T22b | PASS | Excused uses the striped lime ball |

---

## Browser checks (manual)

Performed on the live mock-up:

- Hover / tap / focus open the overlay with the canonical first-level description.
- Close dismisses the overlay without changing the period.
- Previous / next shift A/B/C and recalculate bars; the same date keeps the same synthetic response.
- Scenario 7 shows two lime groups; striped bars are Excused; solid lime is Prayed alone on time.
- Scenario 5 keeps the displayed range as 24 Sep–23 Oct while C percentages use the small answered set (example: 1 of 3 = 33%).
- 7-day and 90-day chips remain disabled (out of scope).

---

## Known limitations

1. This is an HTML mock-up. It is not the Flutter Review screen.
2. Shared lime (`aloneOnTime` / `excused`) is distinguished only in the mock-up (stripe + outline). The Flutter colour table is unchanged.
3. Tooltip sits below the Fajr card (or to its side on a wide frame) with a transparent background so it does not cover the chart or calendar dots.
4. 7-day and 90-day Review are not implemented here.
5. Other prayers and domains are not in this file.
6. Synthetic data only; no Hive migration.

---

## Failures

None in T01–T20. No visual overflow of the Fajr card at 360 / 390 / 420.

---

## Completion gate

The original Fajr 30-day Review card geometry is preserved. The calendar is unchanged. The percentage chart occupies only the existing right-hand statistics rectangle.

**Flutter implementation is not started.** Owner review is required before any production work.
