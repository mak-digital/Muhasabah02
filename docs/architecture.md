# Architecture

Layers:

- `lib/domain/` — DailyCheckIn, PersonalResponse, analytics, recognition, copy
- `lib/data/` — JSON codecs, Hive boxes, in-memory repositories for tests
- `lib/application/` — Riverpod providers
- `lib/presentation/` — screens and shared UI
- `lib/features/` — compatibility exports for earlier milestone paths

Persistence:

- Hive box `muhasabah_checkins_v5` — one JSON document per day (`dateKey`); record `schemaVersion` **6**
- Hive box `muhasabah_responses_v1` — one JSON document per Response
- Hive box `muhasabah_prefs_v1` — sample-data flags, Application Reflection acknowledgement, first-day-of-week, quotation cadence, baselines, aspirations, weekly journal text, and Hadith memorisation focus
- Corrupt documents are isolated; healthy records remain readable
- Failed writes restore the previous document when possible

DailyCheckIn schema version: **6**. Recordable field count: **10**. Response schema version: **1**.

Sample/demo records use `synthetic: true` on check-ins and responses. First install seeds them via `ensureFirstInstallSampleData`.

Home week grids (`SalahHomeCard`, `QuranHomeCard`, `OptionalDomainHomeCard`) and Progress calendars read `AppPrefs.firstDayOfWeek` for presentation only. Optional domain rows are stored in `homeTraces` on DailyCheckIn schema **6** and do not count toward `recordableFieldCount`. Optional-domain cell sheets may store `homeTraceFactors`. Check-in may store `situationNotes`. Neither is treated as a cause.

Hadith **Current Memorisation Focus** (Reviewing / Memorising / Memorised / not recorded) is an AppPrefs value, not a daily trace.

`noticedPatterns` looks at the last 90 days of engagement marks. It can emit weekday clustering, weekend clustering, or appearance across multiple weeks. It does not emit improved/declined/better/worse language. View evidence lists the engagement dates.

Reflection quotes are selected with a calendar bucket (`day` or `day ~/ 7`) and domain rotation. User records are not an input. Hidden cadence removes the Home card.

Baselines store engagement / not-done / unanswered day counts per row. They do not store percentages, scores, or achievements.

Approved Qur’an same-day dependency (the only automatic write):

| If Recorded engagement | Recitation | Recitation with Meaning | Other Qur’an rows |
| --- | --- | --- | --- |
| Recitation with Meaning | Auto-fill engagement | — | Independent |
| Recitation | — | Independent | Independent |
| Memorisation, Revision, Tafsir, Qur’anic Reflection, Conscious Application | Independent | Independent | Independent |

While Recitation with Meaning is engagement, Recitation cannot be set to unanswered or recorded as not done. Application Reflection is not in this matrix.

Marks Guide copy lives in `lib/presentation/home/marks_guide_sheet.dart`. Qur’an factor catalogs are in `lib/domain/context_catalog.dart`.

