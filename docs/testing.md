# Testing

```bash
dart format .
flutter analyze
flutter test --reporter compact
flutter build apk --debug
git diff --check
```

Starting suite (pre-implementation): 1 widget smoke test targeting a non-existent `MyApp` counter (failed).

Domain tests cover Salah independence, missing ≠ missed, Qur’an dimension independence, Application Reflection firewall, analytics denominators, recognition thresholds, Response validation, and corrupt-record isolation.

Widget tests cover navigation, check-in persistence, History without scores, Review 7/30/90 without generated recommendations, PONDER copy, My Response empty/create, equal Salah Response CTAs, unknown routes, and 1.5 text scale / theme toggle.

Debug-only synthetic seeding (`lib/debug/`) can generate 100 days of imperfect DailyCheckIn records through the production Hive/memory repository and clear tagged synthetic days without deleting user-owned records. That control is hidden in release builds.

Emulator verification is performed on a connected Android virtual device when available.
