# Domain metric definitions (Phase R0)

Rules: use stored fields only. Unrecorded ≠ not practised. No universal score. Private text never appears in summaries.

Adequacy already in production (`lib/domain/analytics.dart`):

- 7-day comparison: ≥4 recorded in current **and** prior
- 30-day: ≥15 and ≥15
- 90-day: do not use 7/30 delta; use three 30-day blocks or “not enough”

“Recorded” for shares means `isRecorded` on that field, not “a check-in exists.”

---

## 1. Salah & Prayer Quality

1. **Meaning.** Among prayer rows the user actually marked, how many were congregation / on-time (existing `isDesirable`), plus a categorical mix of marks.
2. **Fields.** `DailyCheckIn.salah[PrayerId]`, `jumuah`, `tahajjud`, `ishraq`, `tawbah`, `salahFactors`, related `homeTraces`.
3. **Numerator / denominator.** Desirable marks / recorded prayer rows. Unanswered rows and days without a check-in are **out of the denominator**.
4. **Missing.** Unanswered is empty. No “missed Fajr” inference.
5. **History.** Small bars: congregation-on-time count per saved day (0–5). Prior window uses the same share function.
6. **Calculable now.** Yes — `salahShare`.
7. **User can learn.** Which recorded days clustered congregation vs late vs home, without treating blanks as absence.
8. **Misread.** A percentage of 5×N possible slots. The mockup forbids that framing.

## 2. Qur’an Engagement

1. **Meaning.** Days with a recorded duration or notice on Read and/or Listen (and separately Understand / Apply).
2. **Fields.** `quran` map (`QuranDimension.reading`, meaning, …), duration lists on traces, `homeTraces` quran rows. **Not** reflection body text.
3. **N/D.** Days with any engagement mark / days in window, stated as counts. Duration buckets (>20, <20, none) among saved days.
4. **Missing.** Unanswered dimension ≠ “did not read.”
5. **History.** Stacked categorical bar; optional prior-window day counts.
6. **Calculable now.** Yes — `readingShare` plus duration traces.
7. **Learn.** How often they chose to mark engagement; not khushu’.
8. **Misread.** “57% Qur’an performance.” Forbidden.

## 3. Hadith & Living Sunnah

1. **Meaning.** Days with encounter duration or Lived/Noticed mark.
2. **Fields.** `hadith` `DomainObservation`, `homeTraces` hadith rows.
3. **N/D.** Days with a mark / window days, as a count. Duration and Lived/Noticed stay independent.
4. **Missing.** Unanswered is not neglect of sunnah.
5. **History.** Presence ticks on a strip.
6. **Calculable now.** Yes (`record.hadith.isRecorded` / traces).
7. **Learn.** Whether they left a notice, not whether they “live the sunnah.”
8. **Misread.** Ranking Hadith below Salah by “coverage %.”

## 4. Dhikr & Dua

1. **Meaning.** Which **sets** were ticked (post-fard, morning, evening, other contexts) — counts of notices.
2. **Fields.** `dhikr`, `dhikrContext` map, `homeTraces` dhikr rows. Performed-list counts may exist per row.
3. **N/D.** Days with a tick per set / saved days. No target of “all adhkar daily.”
4. **Missing.** Empty context ≠ abandoned dhikr.
5. **History.** Category mix of which sets appeared.
6. **Calculable now.** Yes from `dhikrContext` / traces.
7. **Learn.** Which contexts they tend to record.
8. **Misread.** Publishing dua **words**. Forbidden. Counts are not a wird score.

## 5. Fasting

1. **Meaning.** Days with a voluntary / White-Day / Ramadan observation. **Not** daily fasting compliance.
2. **Fields.** `fasting`, `homeTraces` fasting rows, civil-Hijri gated Ramadan rows.
3. **N/D.** Observed fasting days as a count. **No** denominator of “all days should be fasted.”
4. **Missing.** Unanswered / prefer-not ≠ missed sawm. No validity ruling.
5. **History.** Sparse ticks (13/14/15, Mondays, etc.).
6. **Calculable now.** Yes.
7. **Learn.** When they recorded a fast.
8. **Misread.** “You only fasted 10% of the month.” Forbidden.

## 6. Character & Morals

1. **Meaning.** Distribution of practised / struggled / lapse recognised / corrected / no situation among **recorded** akhlaq rows.
2. **Fields.** Akhlaq traces, `akhlaqStruggleNote` **presence only** (never the note text).
3. **N/D.** Category counts / recorded akhlaq days. Unanswered + no check-in in a separate “empty” slice.
4. **Missing.** Unanswered is not a relapse.
5. **History.** Stacked categories; no traffic-light morals.
6. **Calculable now.** Yes from traces/codes.
7. **Learn.** Which codes they used.
8. **Misread.** A character grade or “improving/declining spiritually.”

## 7. Rights of Others

1. **Meaning.** Days a right was marked attended vs neglect recognised.
2. **Fields.** `huquq` traces / `family` observation as applicable.
3. **N/D.** Counts among saved days. No amount fields.
4. **Missing.** Empty ≠ failed the rights of kin.
5. **History.** Two-colour category + empty slice.
6. **Calculable now.** Yes.
7. **Learn.** Whether they left a notice about rights.
8. **Misread.** Pressuring reconciliation or scoring relationships.

## 8. Charity

1. **Meaning.** Days with a giving / care / smile-as-sadaqah **observation**. Zakat is a **status**, not a second score.
2. **Fields.** `charity`, `zakat`, charity traces. **No amounts in store.**
3. **N/D.** Observation-day counts. Amounts must not be invented.
4. **Missing.** Unanswered ≠ stingy.
5. **History.** Presence strip.
6. **Calculable now.** Yes.
7. **Learn.** How often they chose to mark giving/care.
8. **Misread.** Religious merit from money. Forbidden.

## 9. Ummah

1. **Meaning.** Days with masjid / witness / solidarity / related traces.
2. **Fields.** Ummah traces; remote vs physical must not be collapsed into “attended.”
3. **N/D.** Observation-day counts.
4. **Missing.** Isolation is not a failing.
5. **History.** Presence strip.
6. **Calculable now.** Yes.
7. **Learn.** Whether community-facing notices appear.
8. **Misread.** Public check-in or attendance enforcement.

## 10. Productivity

1. **Meaning.** Days listed actions moved, or plan/effort traces — **effort vs plan, not worship.**
2. **Fields.** Productivity store + optional home traces. Hajj standing is **out of scope** (own dashboard).
3. **N/D.** Moved-days / saved days; empty days separate.
4. **Missing.** No check-in ≠ unproductive soul.
5. **History.** Category: moved / saved-no-move / no check-in.
6. **Calculable now.** Partially — Review already counts time/knowledge traces; full Productivity charts should reuse the Productivity store, not a new score.
7. **Learn.** Whether work lists moved, as the owner recorded.
8. **Misread.** Equating productivity with iman.

---

## Cross-cutting

| Topic | Rule |
|---|---|
| All data missing | “Not enough recorded information.” Charts empty; calendar still shows days |
| One day recorded | Counts allowed; **no trend line** |
| Private text | gratitude, reflection, dua, struggle notes: presence count only |
| Comparison | Equal-length windows; show both ranges; refuse if adequacy fails |
| Synthetic mockup | Labelled in the banner; not Hive |

## What the mockup approximates vs production

The HTML uses a **deterministic hash** of `dateKey` to invent marks. Production must call `salahShare`, traces, and Productivity/Hajj stores. Duration buckets and fasting types must map to real enums, not the demo labels (`>20`, `white-days`).
