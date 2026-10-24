import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/other_domains.dart';
import 'package:muhasabah02/domain/review_period.dart';
import 'package:muhasabah02/domain/review_period_snapshot.dart';

void main() {
  test('period snapshot counts recorded days without scoring', () {
    final now = DateTime(2026, 10, 23);
    final records = [
      DailyCheckIn.empty('2026-10-23').copyWith(dhikr: DhikrStatus.practised),
      DailyCheckIn.empty('2026-10-22'),
      DailyCheckIn.empty('2026-09-01').copyWith(dhikr: DhikrStatus.practised),
    ];
    final week = buildReviewPeriodSnapshot(
      records: records,
      now: now,
      period: ReviewPeriod.days7,
    );
    final month = buildReviewPeriodSnapshot(
      records: records,
      now: now,
      period: ReviewPeriod.days30,
    );
    final quarter = buildReviewPeriodSnapshot(
      records: records,
      now: now,
      period: ReviewPeriod.days90,
    );
    expect(week.keys, hasLength(7));
    expect(week.recordedDays(MonitorDomain.dhikr), 1);
    expect(month.recordedDays(MonitorDomain.dhikr), 1);
    expect(quarter.recordedDays(MonitorDomain.dhikr), 2);
    expect(week.inPeriod.map((item) => item.dateKey), contains('2026-10-23'));
    expect(
      week.inPeriod.map((item) => item.dateKey),
      isNot(contains('2026-09-01')),
    );
  });
}
