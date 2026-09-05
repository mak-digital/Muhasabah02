import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test('unanswered salah is not missed', () {
    final record = DailyCheckIn.empty('2026-09-03');
    for (final id in PrayerId.values) {
      expect(record.prayer(id), PrayerStatus.unanswered);
      expect(record.prayer(id), isNot(PrayerStatus.missed));
    }
  });

  test('missing json salah field stays unanswered', () {
    final record = DailyCheckIn.fromJson({
      'schemaVersion': 5,
      'dateKey': '2026-09-03',
      'salah': {'fajr': 'onTime'},
    });
    expect(record.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(record.prayer(PrayerId.isha), PrayerStatus.unanswered);
  });

  test('five prayers remain independent', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withPrayer(PrayerId.fajr, PrayerStatus.missed);
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
    expect(record.prayer(PrayerId.fajr), PrayerStatus.missed);
  });

  test('each salah status is stored independently', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withPrayer(PrayerId.fajr, PrayerStatus.onTime)
        .withPrayer(PrayerId.dhuhr, PrayerStatus.late)
        .withPrayer(PrayerId.asr, PrayerStatus.missed)
        .withPrayer(PrayerId.maghrib, PrayerStatus.unanswered)
        .withPrayer(PrayerId.isha, PrayerStatus.onTime);

    expect(record.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.late);
    expect(record.prayer(PrayerId.asr), PrayerStatus.missed);
    expect(record.prayer(PrayerId.maghrib), PrayerStatus.unanswered);
    expect(record.prayer(PrayerId.isha), PrayerStatus.onTime);
    expect(record.answeredRecordableCount, 4);
  });

  test('salah extras do not change recordable-field count', () {
    final record = DailyCheckIn.empty('2026-09-04').copyWith(
      jumuah: PrayerStatus.onTime,
      tahajjud: TernaryOutcome.positive,
      ishraq: TernaryOutcome.negative,
      jumuahCongregation: true,
    );
    expect(record.answeredRecordableCount, 0);
    expect(record.hasAnyRecordedEvidence, isTrue);
    final restored = DailyCheckIn.fromJson(record.toJson());
    expect(restored.jumuah, PrayerStatus.onTime);
    expect(restored.tahajjud, TernaryOutcome.positive);
    expect(restored.ishraq, TernaryOutcome.negative);
    expect(restored.jumuahCongregation, isTrue);
  });

  test('missing salahTrace stays unanswered and is not missed', () {
    final record = DailyCheckIn.fromJson({
      'schemaVersion': 6,
      'dateKey': '2026-09-03',
      'salah': {'fajr': 'onTime'},
    });
    expect(record.jumuah, PrayerStatus.unanswered);
    expect(record.tahajjud, TernaryOutcome.unanswered);
    expect(record.jumuahCongregation, isFalse);
    expect(record.jumuah, isNot(PrayerStatus.missed));
  });

  test('round-trip json never turns unanswered into missed', () {
    final original = DailyCheckIn.empty('2026-09-03')
        .withPrayer(PrayerId.fajr, PrayerStatus.onTime);
    final restored = DailyCheckIn.fromJson(original.toJson());
    expect(restored.prayer(PrayerId.fajr), PrayerStatus.onTime);
    for (final id in [
      PrayerId.dhuhr,
      PrayerId.asr,
      PrayerId.maghrib,
      PrayerId.isha,
    ]) {
      expect(restored.prayer(id), PrayerStatus.unanswered);
      expect(restored.prayer(id), isNot(PrayerStatus.missed));
    }
  });
}
