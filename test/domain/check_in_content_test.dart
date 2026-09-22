import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/other_domains.dart';
import 'package:muhasabah02/domain/prayer.dart';

void main() {
  test('sameCheckInContent ignores savedAt', () {
    final first = DailyCheckIn.empty('2026-09-03').withPrayer(
      PrayerId.fajr,
      PrayerStatus.onTime,
    );
    final later = first.copyWith(savedAt: DateTime(2026, 9, 3, 12));
    expect(sameCheckInContent(first, later), isTrue);
    expect(
      sameCheckInContent(
        first,
        DailyCheckIn.empty('2026-09-03').withPrayer(
          PrayerId.dhuhr,
          PrayerStatus.late,
        ),
      ),
      isFalse,
    );
  });

  test('overlayCheckInUserEdits keeps unrelated stored fields', () {
    final stored = DailyCheckIn.empty('2026-09-03')
        .withPrayer(PrayerId.asr, PrayerStatus.missed)
        .copyWith(
          gratitudeStatus: EntryStatus.recorded,
          gratitudeText: 'Kept gratitude',
          personalReflectionStatus: EntryStatus.recorded,
          personalReflectionText: 'Kept reflection',
        );
    final empty = DailyCheckIn.empty('2026-09-03');
    final pending = empty.withPrayer(PrayerId.fajr, PrayerStatus.onTime);
    final merged = overlayCheckInUserEdits(
      baseline: stored,
      userPending: pending,
      empty: empty,
    );
    expect(merged.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(merged.prayer(PrayerId.asr), PrayerStatus.missed);
    expect(merged.gratitudeText, 'Kept gratitude');
    expect(merged.personalReflectionText, 'Kept reflection');
  });
}
