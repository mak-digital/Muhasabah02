# Privacy

Default: local-first and offline. No telemetry, ads, cloud AI, or remote analytics in core functionality. Opening a Reflection citation may load a public page in the in-app reader or, if asked, another app on this device; Qur’an Play recitation may fetch a public audio file so playback is not the site’s WebView player. Records stay here.

Never log Response text, gratitude text, personal-reflection text, contextual free text, domain-action titles, developer-note bodies, practice-hadith register content, or serialized private records. `logAppEvent` records event names and opaque ids only.

Developer notes and domain actions stay in local Hive boxes. Download copies a file on the device; the app does not send mail.

Android backup is disabled (`allowBackup=false`) with exclude rules for cloud backup and device transfer.

Optional Unlock with this device uses the phone PIN, pattern, or biometrics before the app is shown. Private Muhasabah does not store a separate password. That lock does not encrypt Hive files.

The app does not claim encryption-at-rest, forensic deletion, or absolute confidentiality.

Tests use synthetic/sample data only. First-install sample records are tagged `synthetic` and are not treated as telemetry.
