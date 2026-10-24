# Fajr 30-day trend chart — HTML mock-up specification

**Phase:** M1-C  
**Authorisation:** HTML mock-up only. Production Flutter is unchanged.  
**Prototype:** [`FAJR_30_DAY_TREND_MOCKUP.html`](FAJR_30_DAY_TREND_MOCKUP.html)  
**Reference (left intact):** [`MULTI_DOMAIN_TREND_MOCKUP.html`](MULTI_DOMAIN_TREND_MOCKUP.html)

This document records the measured existing Fajr 30-day Review card and the chart that must fit inside its right-hand statistics rectangle.

---

## Existing Fajr card (visual reference)

Measured from the current Flutter Review implementation (`AppDimensions`, `progress_calendar.dart`, `salah_progress_screen.dart` `_prayerBlock` / `WashPanel`, `ui_bits.dart`) and reproduced in the mock-up.

| Element | Value |
|---|---|
| Page list padding | 16 px |
| Fajr card background | `#E1E1EB` (Fajr family wash of `#5B6ABF`) |
| Card corner radius | 18 px |
| Card padding | 18 px |
| Title | “Fajr”, 16 px, weight 500 |
| Date-range text | 12 px, muted |
| Navigation arrows | 40×40 px hit targets, left and right of the title |
| Board height | 142 px (`16` header + `7 × 18` stride) |
| Calendar marker | 14 px diameter, 4 px gap, 18 px stride |
| Weekday column | 16 px |
| Calendar column width | 106 px at 390 px phone frame (`min(gridWidth, 0.62 × inner)`) |
| Calendar position | Left of the board, unchanged |
| Wash (right-hand rectangle) | Remaining board width; height 126 px (board 142 minus 16 px header alignment) |
| Wash padding | 8 px top/bottom, 10 px left/right |
| Wash corner radius | 10 px |
| Wash fill | `#E7E7F0` |

### Measured envelope at 390 px (design target)

| Box | Width × height |
|---|---|
| Fajr card | **357 × 226 px** |
| Calendar column | **106 × 142 px** |
| Right-hand wash (chart envelope) | **207 × 126 px** |
| Chart interior after wash padding | **187 × 110 px** |

This wash interior is the **maximum allowable chart envelope**. The chart must not enlarge the card, calendar, or navigation.

### Other viewports (same card structure)

| Viewport | Card | Calendar | Wash |
|---|---|---|---|
| 360 px | 327 × 226 | 106 × 142 | 177 × 126 |
| 390 px | 357 × 226 | 106 × 142 | 207 × 126 |
| 420 px | 387 × 226 | 106 × 142 | 237 × 126 |

Calendar size and card height stay locked. Only the wash width follows remaining inner width.

---

## Chart layout (inside the wash)

Responsive CSS Grid; no extra card chrome.

| Constraint | Value |
|---|---|
| Groups | Up to 5 equal columns |
| Bars per group | 3 (A, B, C left to right) |
| Maximum bars | 15 |
| Inter-group gap | 5 px |
| Inter-bar gap | 2 px |
| Bar max width | 7 px |
| A/B/C label row | 11 px, 8 px type, under **every** group |
| Scale | Shared 0–100% height for all bars |
| Chart-specific legend / title | None |

If the chart does not fit, reduce bar width, group gap, or label size. Do not grow the card.

---

## Canonical Fajr options

Source of truth: `ActivityCatalog.salah` and `SalahActivityMark` (current Flutter). The mock-up copies these identifiers; it does not invent a second catalogue.

| Canonical ID | Input description | Calendar colour |
|---|---|---|
| `congregationOnTime` | Prayed on time in congregation | `#1565C0` |
| `joinedCongregationLate` | Joined congregation late | `#2E7D32` |
| `smallCongregation` | Prayed in small congregation | `#66BB6A` |
| `aloneOnTime` | Prayed alone on time | `#C0CA33` |
| `excused` | Excused | `#C0CA33` (same lime) |
| `prayedLate` | Prayed late | `#FBC02D` |
| `missedMadeUp` | Missed then made up later | `#F57C00` |
| `missed` | Missed | `#D32F2F` |
| `other` | Other | `#616161` |
| *(not a chart category)* `unanswered` | No answer recorded | `#BDBDBD` |

### Shared-colour treatment (mock-up only)

`aloneOnTime` and `excused` share lime in production. They must not be merged.

In this HTML mock-up, `excused` keeps `#C0CA33` and adds a light stripe plus a thin inset outline. Tooltips still use the canonical description. Production Flutter colour values are not changed.

**Unresolved for Flutter:** the live app still uses one lime for both options. A production chart will need an owner decision on a non-colour cue; this mock-up does not change the app palette.

---

## Periods A, B, C

Rolling 30-day windows, oldest to newest:

| Letter | Meaning |
|---|---|
| **A** | Oldest of the three consecutive windows |
| **B** | Immediately preceding window |
| **C** | Window currently shown on the Fajr calendar |

Default C (display date **23 October 2026**):

| Period | Range (30 dates) |
|---|---|
| A | 26 Jul 2026 – 24 Aug 2026 |
| B | 25 Aug 2026 – 23 Sep 2026 |
| C | 24 Sep 2026 – 23 Oct 2026 |

Previous-period navigation moves C back by 30 days. The new C is the old B; B becomes the old A; A is the next earlier window. Records are not rewritten.

Synthetic records are keyed by `fajr|{scenario}|{YYYY-MM-DD}`. The same date always yields the same response within a scenario, regardless of A/B/C position.

---

## Percentage formula

\[
\text{Percentage} = \frac{\text{days with that canonical Fajr option}}{\text{days with a valid Fajr response}} \times 100
\]

Rules:

- Denominator = answered Fajr days only (`kind === 'dot'`).
- Unanswered and days with no record are **not** missed and are **not** in the denominator.
- Explicit `missed`, `missedMadeUp`, and `excused` **are** valid responses.
- Future days (after “today” in the scenario) are excluded.
- Incomplete C uses the actual answered count, not 30.
- If denominator is 0: percentage is **unavailable** (`null`), not 0%. The bar is a dashed hatch. A true 0% bar is a 2 px baseline fill.

All groups share the same 0–100% scale.

---

## Dynamic selection of five options

Selection is on **canonical IDs**, not colours. Empty groups are not invented to fill five slots.

For each option, score:

1. Weighted percentage-point change across A→B and B→C (weight 0.12 / 0.55 / 1.0 when min(denom) is &lt;3 / &lt;8 / ≥8).
2. Mean frequency across periods that have a defined percentage (`× 0.14`).
3. Evidence cap: `min(max denom, 12) × 0.04`.
4. Options with zero hits in A, B, and C are discarded (`score = −1`).

Sort by score descending, then by id. Take at most five.

A stable, frequent option (for example `congregationOnTime` in the Stable scenario) remains eligible even when change is small. A 0%→100% swing on one recorded day is down-weighted by the evidence factor.

---

## Tooltips

Hover, tap, and keyboard focus on a bar. Overlay only; the card does not resize. The overlay is placed **outside** the calendar dots and the chart wash (prefer below the Fajr card). Background is transparent so the Review card is never covered by a solid panel. The title row shows a 14 px colour ball matching the calendar/chart colour, then the canonical description (for example a yellow ball next to “Prayed late”). Shared lime: `excused` uses the same striped ball as the calendar. Close via Close (tap), click-away, or Escape. Hover hides when the pointer leaves the bar. Opening a tooltip does not change the calendar period.

Answered period (compact):

```text
● Prayed late (Fajr)
  Period A (26 Jul 2026–24 Aug 2026)
  Recorded: 4 of 16 answered days (25%)
```

Unavailable period:

```text
● {canonical description} (Fajr)
  Period {A|B|C} ({date range})
  Recorded: no answered Fajr records (unavailable — not 0%)
```

Do not use colour names or “Category n” as the description.

---

## Synthetic scenarios (development controls, outside the card)

| ID | Name | Purpose |
|---|---|---|
| 1 | Normal | Five meaningful options with varying A/B/C percentages |
| 2 | Significant changes | Selection must differ from Normal |
| 3 | Stable | High-frequency `congregationOnTime` remains selected |
| 4 | Sparse | Correct percentages on a small answered set |
| 5 | Incomplete C | Display still 24 Sep–23 Oct; “today” is 28 Sep so C elapsed = 5 |
| 6 | No data in A | Period A has no answered days → unavailable bars |
| 7 | Shared colours | Both `aloneOnTime` and `excused` selected and distinguishable |

7-day and 90-day chips are shown for layout fidelity and are disabled. Other prayers and domains are out of scope.

---

## Flutter implementation

**Not authorised.** Await explicit owner approval before any production chart work.
