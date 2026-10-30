# Multi-domain trend mock-up — test report

**Phase M1.** HTML prototype only. Flutter production was not modified. Synthetic data only.

**File:** `docs/review_trends/MULTI_DOMAIN_TREND_MOCKUP.html`  
**Mapping:** `docs/review_trends/MULTI_DOMAIN_PARAMETER_MAPPING.md`

Built-in assertions on the page: **12/12 pass** after Test 10 was aligned to measured rectangle height.

| Test | Result |
|---|---|
| 1 Chronological A → B → C | Pass. Consecutive 30-day windows; C is the displayed calendar. Example C: 24 Sep–23 Oct 2026; B: 25 Aug–23 Sep; A: 26 Jul–24 Aug. |
| 2 Navigation | Pass. Previous moves C to the former B (25 Aug–23 Sep). Next restores. Selected options can change. |
| 3 Percentage | Pass. 6/20 = 30%. Live tooltip example: congregation on time C = 6 of 19 = 32%. |
| 4 Incomplete period | Pass. Incomplete scenario: elapsed days in C = 5, denominator ≤ 5, not 30. |
| 5 Missing responses | Pass. Denominator is answered days only; missing days are omitted. |
| 6 No data | Pass. `denom 0` → unavailable (hatched), not 0%. Genuine 0% is a 2px stub of the option colour. |
| 7 Different activities | Pass. Fajr vs Qur’an Engagement select different option sets (Fajr congregation/missed vs duration bands). |
| 8 Dynamic selection | Pass. Changing scenario (normal vs significant change / sparse) changes ranking. Backward navigation also changed Fajr’s fifth option. |
| 9 Tooltip | Pass. Hover/tap/focus shows the **canonical description**, activity, period letter, date range, hits of answered, percentage. Not colour names. |
| 10 Fixed dimensions | Pass. Chart wash height matches the 30-day calendar board (existing statistics rectangle). |
| 11 Responsive | Pass. Mobile ~390: 15 thin bars in the wash; no horizontal overflow of the card. Larger ~720: same structure, wider card. |
| 12 Stable patterns | Pass. Stable scenario still selects frequent options; a flat trend is allowed. |

## Domains represented

Salah (Fajr), Qur’an (Engagement duration), Hadith (Read and/or Listened duration), Dhikr (Morning Adhkar checklist), Fasting (Ramadan observed), Character (Patience), Rights (Parents), Charity (Voluntary), Ummah (Masjid attendance), Knowledge, Time, Health, Wealth, Productivity (design-only). **Hajj excluded.**

Hadith, Fasting, Charity, Ummah, Knowledge, Time, Health, and Wealth use the same chart engine and current catalogues; representative screenshots below concentrate on Fajr, Qur’an, Dhikr, Character, Rights, 90-day, tooltip, navigation, and Productivity.

## Screenshots (synthetic HTML, not Flutter)

| File | Content |
|---|---|
| `01_fajr_30day.png` | Fajr, 15 bars, 30-day calendar |
| `02_tooltip.png` | Canonical Fajr description + 6 of 19 / 32% |
| `03_nav_back.png` | Previous window (capture may still show an older tooltip overlay; live UI updates the range) |
| `04_sparse.png` | Sparse scenario (same overlay caveat) |
| `05_quran.png` | Engagement duration options |
| `06_dhikr.png` | Morning Adhkar (family tints; mapping gap) |
| `07_patience.png` | Character — Patience |
| `08_parents.png` | Rights — Parents |
| `09_90day.png` | No trend bars; count copy |
| `10_wide_productivity.png` | Larger layout, design-only Productivity banner |

## Remaining limitations

- Morning Adhkar formulas have no calendar-dot colours.
- Productivity statuses have no Review dots; demonstration only.
- `excused` / `aloneOnTime` and 5–10 / 3–5 minute durations share lime in the live app.
- 7-day uses three consecutive 7-day windows; 90-day has no bars.
- HTML approximates the Flutter 30-day card; it is not a pixel-perfect export.

**Stop.** No Flutter implementation until the owner approves this design.
