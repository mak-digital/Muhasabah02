# Multi-domain trend mock-up — parameter mapping

**Phase M1.** Authoritative source: current Flutter first-level pickers (`ActivityCatalog`, practice catalogues, Dhikr checklist, Productivity status enum). Not Hive history.

Hajj is dormant and is excluded.

**Eligible denominator (all domains):** answered records only. Unanswered is not a category in the chart. Missing days are not inactivity.

**Shared colour source:** `SalahActivityMark.colourForId` / response-kind twins. Two existing collisions are inherited, not invented: `aloneOnTime` and `excused` share `#C0CA33`; Qur’an `min5to10` and `min3to5` share the same lime.

---

## Salah & Prayer Quality — Fajr

| Field | Value |
|---|---|
| Storage | Obligatory Fajr row (`PrayerId.fajr`) |
| Catalog | `ActivityCatalog.salah` |
| Denominator | Days with a valid Fajr option (not `unanswered`) |

| Canonical id | Description | Colour | Chart |
|---|---|---|---|
| `congregationOnTime` | Prayed on time in congregation | `#1565C0` | Eligible |
| `joinedCongregationLate` | Joined congregation late | `#2E7D32` | Eligible |
| `smallCongregation` | Prayed in small congregation | `#66BB6A` | Eligible |
| `aloneOnTime` | Prayed alone on time | `#C0CA33` | Eligible |
| `excused` | Excused | `#C0CA33` (shared) | Eligible |
| `prayedLate` | Prayed late | `#FBC02D` | Eligible |
| `missedMadeUp` | Missed then made up later | `#F57C00` | Eligible |
| `missed` | Missed | `#D32F2F` | Eligible |
| `other` | Other | `#616161` | Eligible |
| `unanswered` | No answer recorded | `#BDBDBD` | Excluded |

---

## Qur’an Engagement — Engagement duration

| Field | Value |
|---|---|
| Storage | Engagement duration (`QuranDurationIds`) |
| Catalog | `ActivityCatalog.quranEngagementDuration` |
| Denominator | Days with a valid Engagement duration response |

| Canonical id | Description | Colour | Chart |
|---|---|---|---|
| `over20` | Engaged more than 20 minutes — Engagement | `#1565C0` | Eligible |
| `min15to20` | Engaged 15–20 minutes — Engagement | `#2E7D32` | Eligible |
| `min10to15` | Engaged 10–15 minutes — Engagement | `#66BB6A` | Eligible |
| `min5to10` | Engaged 5–10 minutes — Engagement | `#C0CA33` | Eligible |
| `min3to5` | Engaged 3–5 minutes — Engagement | `#C0CA33` (shared) | Eligible |
| `notEngaged` | I did not notice this today — Engagement | `#FBC02D` | Eligible |
| `other` | Other — Engagement | `#616161` | Eligible |
| `unanswered` | No answer recorded — Engagement | grey | Excluded |

---

## Hadith & Living Sunnah — Read and/or Listened

| Field | Value |
|---|---|
| Storage | `hadith.encounter` |
| Catalog | `ActivityCatalog.hadithEncounterDuration` (same duration ids as Qur’an) |
| Denominator | Days with a valid encounter-duration response |

Labels use “Engaged … — Read and/or Listened”. Colours match the duration twins. Lived-Sunnah options (`hadithLived.*`) are a different row and are not mixed into this chart.

---

## Dhikr & Dua — Morning Adhkar (checklist)

| Field | Value |
|---|---|
| Storage | `dhikr.morningAdhkar` |
| Catalog | Practice Dhikr morning items (`dhikr.morningAdhkar.<practiceId>`) |
| First-level meaning | Checklist: Practised / Not today / Prefer not, per formula |
| Denominator | Days with **any** Morning Adhkar checklist answer |
| Numerator | Days that formula was marked **Practised** |

**Mapping limitation:** individual morning formulas have **no** established calendar-dot colour. The mock-up uses Dhikr-family tints (`#3F7D6A` and neighbours). These are **not** Salah dots.

Representative formulas in the prototype (current catalogue topics): Ayat al-Kursi; three Quls; Sayyid al-istighfar; Nothing harms with His name; Perfect words of Allah; By You we enter the morning; Upon the fitrah of Islam; Well-being in body, hearing, and sight.

---

## Fasting — Ramadan observed

| Field | Value |
|---|---|
| Storage | `fasting.ramadanObserved` |
| Catalog | `fastingCatalogFor` |
| Denominator | Days with a valid Ramadan-observed response |

| Canonical id | Description | Colour kind |
|---|---|---|
| `fasting.ramadanObserved.completed` | Completed today's fast | acted / blue |
| `fasting.ramadanObserved.inProgress` | Fasting today; not yet completed | partial / green |
| `fasting.ramadanObserved.exemption` | Did not fast due to a recognised exemption or genuine inability | constrained / light green |
| `fasting.ramadanObserved.interrupted` | Fast was interrupted or ended early | difficulty / lime |
| `fasting.ramadanObserved.otherReason` | Did not fast for another reason | difficulty / lime |
| `prefer_not` | Prefer not to record | other / grey |
| `unanswered` | Not recorded | Excluded |

Weekly Sunnah fasting is a thinner ternary row; Ramadan observed is the representative five-option activity.

---

## Character & Morals — Patience

| Field | Value |
|---|---|
| Storage | `akhlaq.patience` |
| Catalog | `akhlaqCatalogFor` (shared ids, row-specific labels) |
| Denominator | Days with a valid Patience response |

| id | Description | Colour kind |
|---|---|---|
| `practised` | Remained patient when tested | congregation blue |
| `struggled` | Tried but struggled to remain patient | green |
| `lapse_recognised` | Lost patience and recognised it | amber |
| `corrected` | Lost patience, then corrected my response | light green |
| `no_situation` | No situation requiring patience noticed | lime |
| `unanswered` | Unanswered | Excluded |

---

## Rights of Others — Parents

| Field | Value |
|---|---|
| Storage | `huquq.parents` |
| Catalog | `huquqCatalogFor` |
| Denominator | Days with a valid Parents response |

| id | Description | Colour kind |
|---|---|---|
| `practised` | Honoured my parents through care, respect, contact or du‘a | blue |
| `partial_effort` | Made an effort but could have responded better to their needs | green |
| `neglect_recognised` | Recognised that I neglected a responsibility or behaved disrespectfully | amber |
| `corrective_action` | Took steps to apologise, restore contact or fulfil a neglected responsibility | light green |
| `no_situation` | No specific action or unmet responsibility to record today | lime |
| `unanswered` | Unanswered | Excluded |

---

## Charity — Voluntary Charity

| Field | Value |
|---|---|
| Storage | `charity.voluntary` |
| Catalog | `charityCatalogFor` |
| Denominator | Days with a valid Voluntary Charity response |

Ids: `charity.voluntary.gave` / `.intended` / `.didNotGive` / `.noOpportunity` / `prefer_not`. Kind colours: cared, partial, difficulty, noSituation, preferNot.

---

## Ummah — Masjid attendance

| Field | Value |
|---|---|
| Storage | `ummah.masjidAttendance` |
| Catalog | `ummahCatalogFor` |
| Denominator | Days with a valid masjid-attendance response |

Exact current labels (full sentences) are used in tooltips.

---

## Other active Review domains (included)

Hajj excluded. Knowledge, Time, Health, Wealth, and Productivity appear on Review when enabled.

| Domain | Activity | Storage | Notes |
|---|---|---|---|
| Knowledge & Beneficial Speech | Learned something true | `knowledge.learnedSomethingTrue` | Shared observation ids with row labels |
| Time & Barakah | Intention | `time.t01` | Shared observation ids with row labels |
| Physical Health | Sleep quality | `health.sleepQuality.*` | Unique ids; kind colours |
| Wealth & Provision | Lawful earning | `wealth.halalEarning.*` | Unique ids; kind colours |
| Productivity | Action status | Independent store | **Design-only.** Status enum: Not started, In progress, Paused, Needs a look, Completed. Deleted excluded. **No calendar-dot colours.** Priority chip colours are reused only as a visual stand-in and are labelled as such. |

---

## Chart eligibility summary

- First-level options only. Nested factor dropdowns are not charted.
- `unanswered` / “Not recorded” never selected.
- Up to five options after dynamic ranking (change with evidence, then stable frequency).
- Fewer than five eligible options: show only those available (none of the representative rows here have fewer than five after excluding unanswered).
- 90-day view: no bars; existing count copy remains.

## Mapping gaps

1. Morning Adhkar formulas: no per-item dots.
2. Productivity statuses: no Review calendar colours.
3. `excused` vs `aloneOnTime`, and 5–10 vs 3–5 minute Qur’an/Hadith durations: identical lime in the live app; tooltips carry the meaning.
