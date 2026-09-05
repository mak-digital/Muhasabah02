# Remaining Home domain cards — visual review

Mockups: `docs/visual_review/remaining_domain_cards.html`. **No implementation in this package.**

Approved already and not redesigned here: Marks Guide, Home architecture, first day of week, Salah and Qur’an interaction, progressive disclosure, global circle semantics.

## Shared rules on every proposed card

- Week arrows, **This week**, first-day-of-week columns (Monday shown).
- 14px markers; tappable cells; title opens Progress; cell opens a compact sheet (not a full editor).
- No card legends. Home **ⓘ Guide** only.
- Layer 1 daily rows: Recorded engagement · Recorded as not done · Unanswered.
- Layer 2: optional **Factors you noticed**. Stored. Never causality, completion, or scoring.
- No auto-fill between any rows in this package.

## Suggested Home order

1. Salah  
2. Qur’an  
3. Dhikr  
4. Fasting  
5. Family  
6. Charity (with Zakat)  
7. Hadith  
8. Current review snapshot · Recognition · PONDER · Add a response  

Reason: worship grids first; sparse Fasting before long kinship/giving cards; Hadith separated from Qur’an so Reading/Memorisation/Reflection are not visually fused.

## Density and readability

**Home length is the main risk.** Salah + Qur’an already fill a first screen. Adding five more full grids pushes Review and PONDER far down. That fights SEE → PONDER → EXPLORE.

**Charity is the densest card:** five giving rows plus a Zakat row (six label columns of 10px type). Family Support appears on both Family and Charity.

**Hadith is the second densest:** six rows, overlapping Qur’an vocabulary (Reading, Memorisation, Reflection).

**Fasting looks “empty.”** That is correct (unanswered ≠ missed) but can be misread as a broken card unless Guide copy is clear.

**Travel Dhikr and Parents Visit** will often be all-dotted. Same reading risk.

## Simplifications — proposed only

Do not implement unless approved.

| Card | Concern | Proposal |
| --- | --- | --- |
| All remaining cards on Home | Too much scroll | Home shows **one preview row** (or first group only) plus title; full grid lives on the domain Progress screen. |
| Dhikr | Five daily rows | Keep Morning + Evening; fold General / Gratitude / Travel into one **Other Dhikr** row, or hide Travel unless travel is recorded that week. |
| Dhikr | Gratitude Dhikr vs check-in gratitude | Keep gratitude **text** on check-in; if Gratitude Dhikr stays, name it clearly as remembrance, not the journal field. |
| Family | Parents Contact vs Visit vs Family vs Relative | Keep Parents Contact + Visit; merge Family Contact and Relative Contact into **Other kinship contact**. Rename Family Support to **Kinship care** so it is not Charity’s Family Support. |
| Charity | Five support types | Keep **Voluntary Charity**; collapse Community / Family / Educational / Emergency into **Directed support** (detail in check-in activities). Zakat stays a separate row. |
| Charity | Family Support label clash | Rename Charity row to **Household or kinship giving**. |
| Fasting | Four rows, mostly unanswered | Keep Weekly Sunnah Fast on Home; move Monthly / Make-up / Ramadan Preparation to Progress only, or a single **Other fast** row. |
| Hadith | Six rows + name clash | Keep Reading + Listening on Home; Memorisation / Study Circle / Teaching on Progress. Visible row: **Hadith Reflection**, never bare “Reflection”. |
| Zakat on a 7-day grid | Zakat is not usually daily | Prefer a **week-level strip** (one current status) plus optional dated cells only when a zakat observation exists. Still use diamonds, not circles. |

No scores, remaining-fast counts, zakat progress bars, or kinship “coverage” percentages.

## Layer 1 / Layer 2 by domain

### Dhikr

**Layer 1:** Recorded engagement / Recorded as not done / Unanswered per row.

**Layer 2 support (examples):** Reminder or cue; After Salah; Quiet space; Existing routine; Family participation; Travel setting; Other.

**Layer 2 challenges (examples):** Limited time; Fatigue; Forgot; Device distraction; Competing priorities; Other.

### Family

**Layer 1:** same ternary. Visit unanswered is not a missed visit.

**Layer 2 support:** Reminder or cue; Existing routine; Family gathering; Travel home; Shared meal; Other.

**Layer 2 challenges:** Distance; Work commitments; Limited time; Health; Travel; Competing priorities; Other.

### Charity (daily giving)

**Layer 1:** ternary. Independent of Zakat.

**Layer 2 support:** Payday or means available; Reminder or cue; Community collection; Seeing a need; Family participation; Other.

**Layer 2 challenges:** Limited means; Competing priorities; Forgot; Uncertainty about channel; Other.

### Zakat

**Layer 1 (not ternary):** Due · Planned · Paid · Not applicable · Unanswered.

Visual: diamond (Due outline, Planned half-fill, Paid fill); Not applicable = muted bar, **not** the missed slash; Unanswered = dotted diamond.

**Layer 2:** same optional catalog as Charity, or skipped. Paid is not an achievement. Due is not a warning red.

### Fasting

**Layer 1:** ternary. No remaining-fasts ledger.

**Layer 2 support:** Existing routine; Health felt sufficient; Community programme; Reminder or cue; Other.

**Layer 2 challenges:** Health; Travel; Work commitments; Fatigue; Competing priorities; Other.

Do not prescribe fasting. Health is an observation the user may record.

### Hadith

**Layer 1:** ternary. No fill from Qur’an rows.

**Layer 2 support:** Book or recording available; Study circle; Teacher guidance; Commute audio; Existing routine; Other.

**Layer 2 challenges:** Limited time; Device distraction; Competing priorities; Fatigue; Other.

## Terminology to keep distinct

| Phrase | Use |
| --- | --- |
| Qur’anic Reflection | Qur’an daily row |
| Hadith Reflection | Hadith notice row (if “Reflection” is approved) |
| Application Reflection | Settings → About only |
| Personal Reflection | Check-in note |
| Gratitude Dhikr | Remembrance row (proposed) |
| Gratitude (check-in) | Existing optional text field — not a Home grid in this package |
| Family Support (Family card) | Kinship care |
| Family Support (Charity card) | Giving — rename if both stay |

## Dependencies

**None proposed.** No Morning Adhkar → Evening. No Parents Visit → Parents Contact. No Paid zakat → Voluntary Charity. No Hadith Reading → Hadith Reflection.

## Stop

Visual review only. Implementation waits on approval of rows, Zakat diamonds, Home order, and any simplifications above.
