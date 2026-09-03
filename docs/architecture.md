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
- Hive box `muhasabah_prefs_v1` — sample-data and Application Reflection flags
- Corrupt documents are isolated; healthy records remain readable
- Failed writes restore the previous document when possible

DailyCheckIn schema version: **6**. Recordable field count: **10**. Response schema version: **1**.

Sample/demo records use `synthetic: true` on check-ins and responses. First install seeds them via `ensureFirstInstallSampleData`.

