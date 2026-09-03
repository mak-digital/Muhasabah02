import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/sample_retirement.dart';

void main() {
  test(
    'archive offer requires 21 consecutive personal days and sample records',
    () {
      final now = DateTime(2026, 9, 3);
      final personal = [
        for (var i = 0; i < 21; i++)
          DailyCheckIn.empty(dateKey(now.subtract(Duration(days: i))))
              .withPrayer(PrayerId.fajr, PrayerStatus.onTime),
      ];
      final withSample = [
        ...personal,
        DailyCheckIn.empty('2026-01-01').copyWith(synthetic: true),
      ];
      expect(
        shouldOfferSampleArchive(
          records: withSample,
          now: now,
          dismissed: false,
        ),
        isTrue,
      );
      expect(
        shouldOfferSampleArchive(records: personal, now: now, dismissed: false),
        isFalse,
      );
      expect(
        shouldOfferSampleArchive(
          records: withSample,
          now: now,
          dismissed: true,
        ),
        isFalse,
      );
    },
  );
}
