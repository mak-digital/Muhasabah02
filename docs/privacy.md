# Privacy

Default: local-first and offline. No telemetry, ads, cloud AI, or remote analytics in core functionality.

Never log Response text, gratitude text, personal-reflection text, contextual free text, or serialized private records. `logAppEvent` records event names and opaque ids only.

Android backup is disabled (`allowBackup=false`) with exclude rules for cloud backup and device transfer.

Optional Unlock with this device uses the phone PIN, pattern, or biometrics before the app is shown. Private Muhasabah does not store a separate password. That lock does not encrypt Hive files.

The app does not claim encryption-at-rest, forensic deletion, or absolute confidentiality.

Tests use synthetic/sample data only. First-install sample records are tagged `synthetic` and are not treated as telemetry.
