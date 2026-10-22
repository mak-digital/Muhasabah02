# Review dashboard design (Phase R0)

This is a proposed layout. Production screens are not implemented.

## Product stance

Your record, not a ruling. Notice your day to improve. Keep it yours.

The dashboard helps the owner **see what they recorded**, notice **where they rarely recorded**, and **open a past day** without leaving Review. It does not score worship, rank domains, or predict spiritual state.

## Proposed structure (one scroll)

### A. Header

- Title: Review
- 7 / 30 / 90 chips (same `reviewPeriodProvider` semantics)
- Actual range: `fmt(start) – fmt(end)`
- Previous / next comparable window (shifts by `period.days`, never mixes unequal lengths)
- Guard: missing days are not missed practice; the view does not score worship

### B. Compact recording overview

- Count of days with a saved check-in
- Count of domains with any mark in the window
- Calendar strip: filled = saved document; dashed empty = no check-in
- **No** large dual share hero

### C. Activity pattern

- Same strip / small bars as presence of a check-in
- Comparison note vs previous equal window
- If either window has too few saved days: “Not enough recorded information…”
- One saved day: not a trend; the day can still be opened

### D. Domain infographic cards

Collapsed: name, compact viz unique to that domain, one descriptive observation.

Expanded (`ExpansionTile` / `AnimatedCrossFade` in Flutter): chart explanation, category breakdown, View historical records (scrolls to calendar, filtered mentally by domain), View/Edit a record.

Cards use existing domain washes. Meaning is also in labels, not colour alone.

### E. Historical calendar / timeline

- Every day in the window (empty visible)
- Tap → sheet: domain marks for that `dateKey`
- View/Edit → `CheckInScreen(date:)` for that key (upsert, no second row)
- Remove with the existing confirm dialog
- Private dua / journal / gratitude **text never rendered** in the sheet summary

### F. Reflection insights

- Count-based sentences: “Qur’an engagement was recorded on four days in this period.”
- No “Your Qur’an performance is 57%.”
- Optional previous-window comparison only when adequacy is met
- Recognition patterns (30/90) fold here as a secondary disclosure, not a trophy

### Navigation (mockup)

Bottom: Home | Review. Home is a stub. Production Home unchanged.

My Response: list + add with period or day provenance, inside Review.

## Interaction model (Flutter-compatible)

| Gesture | Result |
|---|---|
| Period chip | Rebuild all counts, charts, calendar, insights |
| Previous/next window | Same length, different `offset`; labels update |
| Tap domain card | Expand/collapse; only one open by default |
| Tap compact chart | Same as expand (no hidden drill) |
| Tap strip cell or calendar day | Select date; sheet + wide preview |
| View historical records | Scroll to calendar (later: domain-filtered list) |
| View/Edit | Open existing check-in |
| Add a response | Response editor with provenance |
| Keyboard | Chips, cards (`tabindex`), days are buttons; Enter toggles card |

## Empty and sparse

- **Empty window:** domain stack replaced by empty copy; calendar still shows days; Home remains the record path
- **Sparse:** cards still render; comparison note refuses a trend; fasting still not daily-normalised
- **Density toggle in the mockup** is a demonstration control, labelled synthetic — not a product setting

## Layout

- Phone: ~390–420 wide, sticky two-item nav, scroll body
- Wide: cards left, calendar/sheet companion right (`~980px`)

## Progressive disclosure

Not shown all at once: per-prayer table, Recognition subject list, All-time History, archived responses, Progress-screen filters. Those remain reachable from expand actions or existing routes until R1.

## Colour

Domain washes match the app. Saved vs empty uses fill vs dashed outline (not red/green judgment). Gold outline = selected date only.
