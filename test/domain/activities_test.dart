import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test('salah activity maps to status without scoring', () {
    var record = DailyCheckIn.empty('2026-09-03').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: 'congregationOnTime'),
    );
    expect(record.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
    record = record.withSalahActivity(
      PrayerId.dhuhr,
      const RecordedActivity(id: ActivityIds.unanswered),
    );
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
  });

  test('quran other stores custom text and remains independent', () {
    final record = DailyCheckIn.empty('2026-09-03').withQuranActivity(
      QuranDimension.reading,
      const RecordedActivity(id: ActivityIds.other, customText: 'A class'),
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    expect(
      record
          .activityFor(ActivityCatalog.quranKey(QuranDimension.reading))
          .customText,
      'A class',
    );
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
  });

  test('optional domains do not change the recordable denominator', () {
    final record = DailyCheckIn.empty('2026-09-03').copyWith(
      fasting: const DomainObservation(activityId: 'weeklySunnah'),
      zakat: ZakatStatus.paid,
    );
    expect(record.answeredRecordableCount, 0);
    expect(kRecordableFieldCount, 10);
    expect(record.hasAnyRecordedEvidence, isTrue);
  });
}
