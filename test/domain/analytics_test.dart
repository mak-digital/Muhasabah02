import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/analytics.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/review_period.dart';

DailyCheckIn salah(String date, PrayerStatus status) {
  return DailyCheckIn.empty(date).withPrayer(PrayerId.fajr, status);
}

void main() {
  test('missing salah is excluded from the outcome denominator', () {
    final records = [
      salah('2026-09-01', PrayerStatus.onTime),
      salah('2026-09-02', PrayerStatus.unanswered),
      DailyCheckIn.empty('2026-09-03'),
    ];
    final share = salahShare(records, PrayerId.fajr);
    expect(share.recorded, 1);
    expect(share.desirable, 1);
  });

  test('reading missing is excluded from denominator', () {
    final records = [
      DailyCheckIn.empty('a')
          .withQuran(QuranDimension.reading, TernaryOutcome.positive),
      DailyCheckIn.empty('b'),
    ];
    final share = readingShare(records);
    expect(share.recorded, 1);
    expect(share.desirable, 1);
  });

  test('7-day adequacy needs 4 recorded observations each side', () {
    expect(hasAdequacy(ReviewPeriod.days7, 4, 4), isTrue);
    expect(hasAdequacy(ReviewPeriod.days7, 3, 4), isFalse);
  });

  test('direction uses ±10 percentage points inclusive', () {
    const current = OutcomeShare(recorded: 10, desirable: 6);
    const priorLow = OutcomeShare(recorded: 10, desirable: 5);
    const priorHigh = OutcomeShare(recorded: 10, desirable: 8);
    expect(
      directionFromShares(
        period: ReviewPeriod.days7,
        current: current,
        prior: priorLow,
      ),
      PeriodNarrative.improvement,
    );
    expect(
      directionFromShares(
        period: ReviewPeriod.days7,
        current: current,
        prior: const OutcomeShare(recorded: 10, desirable: 6),
      ),
      PeriodNarrative.steady,
    );
    expect(
      directionFromShares(
        period: ReviewPeriod.days7,
        current: current,
        prior: priorHigh,
      ),
      PeriodNarrative.deterioration,
    );
  });
}
