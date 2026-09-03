# Muhasabah

Private, local-first Islamic self-reflection. The app helps you record practice and look at what you recorded. It does not score iman, prescribe worship, or gamify streaks.

Canonical flow: **RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND**

## Build and run (Android)

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
Release APK: `build/app/outputs/flutter-apk/app-release.apk`
Release AAB: `build/app/outputs/bundle/release/app-release.aab`

Release builds currently sign with the Android debug keystore unless you supply production credentials.

## Product

See `docs/PRODUCT_SPEC.md`. Guardrails: `docs/product_guardrails.md`. Architecture: `docs/architecture.md`. Privacy: `docs/privacy.md`. Tests: `docs/testing.md`.

## Known limitations

- No production Play signing key is configured in this repository.
- Hive stores JSON documents on-device; this is not claimed as encryption-at-rest.
- Delete removes the app-managed record only; it is not forensic secure erasure.
- Nested `muhasabah02/` copy, zip, and text dump in the tree are leftover artifacts and are not the application source.
