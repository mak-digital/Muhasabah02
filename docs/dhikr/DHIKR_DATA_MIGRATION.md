# Dhikr data migration

Schema stays **DailyCheckIn v6**. Recordable field count stays **10**.

## Additive field

Optional JSON object `dhikrContext`:

```json
{
  "dhikr.generalDhikr": [
    {
      "id": "dhikr.general.tasbih",
      "response": "practised",
      "repetitions": 33,
      "note": "optional",
      "updatedAt": "2026-10-20T18:00:00.000"
    }
  ]
}
```

Missing `dhikrContext` means no context selections. Legacy `homeTraces['dhikr.generalDhikr']` ternary values still read.

## Legacy unanswered

Unanswered is not rewritten to Not today. A day with no `dhikrContext` and no ternary stays unanswered.

## Roll-up

When context selections exist, `homeTraces[row]` is rolled up so Home and Progress marks still work:

- any Practised → positive
- otherwise (Not today and/or Prefer not) → negative
- empty list → unanswered (and the ternary key is removed)

If a context list is already saved, a later generic ternary write (including a Quick Tap cycle) is ignored so the detailed list is kept. Quick Tap on these Dhikr mix rows opens that same list instead of cycling one generic mark. Legacy days with only a ternary or post-fard remembrance-level mark still load.

## Offline

Storage remains the local Hive check-in document. No network is required.
