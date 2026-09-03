# Architecture

Layers:

- `lib/domain/` — DailyCheckIn, PersonalResponse, analytics, recognition, copy
- `lib/data/` — JSON codecs, Hive boxes, in-memory repositories for tests
- `lib/application/` — Riverpod providers
- `lib/presentation/` — screens and shared UI
- `lib/features/` — compatibility exports for earlier milestone paths

Persistence:

- Hive box `muhasabah_checkins_v5` — one JSON document per day (`dateKey`)
- Hive box `muhasabah_responses_v1` — one JSON document per Response (opaque id)
- Corrupt documents are isolated; healthy records remain readable
- Failed writes restore the previous document when possible

DailyCheckIn schema version: **5**. Recordable field count: **10**. Response schema version: **1**.
