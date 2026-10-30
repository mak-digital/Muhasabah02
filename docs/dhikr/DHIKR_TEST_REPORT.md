# Dhikr test report

## Automated

Focused domain tests: `test/domain/dhikr_context_test.dart`

- unique catalogue IDs
- unique source IDs
- verified citations resolve to public reader URIs
- multiple selections persist
- unanswered is not converted
- prefer-not and not-today are recorded, not unanswered
- legacy ternary days remain without `dhikrContext`

Focused widget tests: `test/widget/dhikr_context_editor_test.dart`

- Other Adhkar add / practised / not today / save
- Morning Adhkar stays off the new catalogue
- source sheet for a verified personal dua
- screen-reader label and 1.5 text scale on a narrow layout

Regression: existing Dhikr check-in, Progress matrix, Learn & Practice, Quick Tap, and morning/evening tests should stay green.

Quick Tap: Other Adhkar tiles open the activity list; saved selections are not cleared.

## Runtime

`emulator-5554` (Medium Phone / Android 16) is reused when present. Widget tests cover expanded categories, add sheets, source details, and saved responses.

## Outstanding

- Istikhara wording pending editorial review.
- Seeking protection and Other Sunnah remembrance still have no verified formula.
