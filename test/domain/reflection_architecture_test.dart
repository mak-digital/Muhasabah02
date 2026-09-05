import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/noticed_this_week.dart';
import 'package:muhasabah02/domain/patterns_noticed.dart';
import 'package:muhasabah02/domain/personal_baseline.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quotation_cadence.dart';
import 'package:muhasabah02/domain/weekly_quotes.dart';

void main() {
  test('home traces do not change recordable field count', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive);
    expect(record.answeredRecordableCount, 0);
    expect(record.hasAnyRecordedEvidence, isTrue);
    expect(record.schemaVersion, 6);
  });

  test('quote rotation ignores recorded activity', () {
    final now = DateTime(2026, 9, 3);
    final withRecords = quoteFor(now: now, cadence: QuotationCadence.weekly);
    final empty = quoteFor(now: now, cadence: QuotationCadence.weekly);
    expect(withRecords?.text, empty?.text);
    expect(withRecords?.source, isNotEmpty);
    expect(quoteFor(now: now, cadence: QuotationCadence.hidden), isNull);
  });

  test('baselines store day counts not percentages', () {
    final records = [
      DailyCheckIn.empty('2026-09-01')
          .withHomeTrace('family.familyContact', TernaryOutcome.positive),
      DailyCheckIn.empty('2026-09-03')
          .withQuran(QuranDimension.reflection, TernaryOutcome.positive),
    ];
    final baseline = buildBaseline(
      id: 'b1',
      now: DateTime(2026, 9, 3),
      source: BaselineSource.days30,
      records: records,
    );
    final encoded = '${baseline.toJson()}';
    expect(encoded.toLowerCase(), isNot(contains('percent')));
    expect(encoded.toLowerCase(), isNot(contains('score')));
    expect(baseline.counts['Sibling Contact']?.engagementDays, 1);
  });

  test('noticed this week lists engagement days without judgment', () {
    final records = [
      DailyCheckIn.empty('2026-08-31')
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive),
      DailyCheckIn.empty('2026-09-01')
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive),
      DailyCheckIn.empty('2026-09-02')
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.unanswered),
    ];
    final lines = noticedThisWeek(
      records: records,
      weekKeys: const [
        '2026-08-31',
        '2026-09-01',
        '2026-09-02',
        '2026-09-03',
        '2026-09-04',
        '2026-09-05',
        '2026-09-06',
      ],
    );
    expect(lines.single.sentence, 'Morning Adhkar on 2 days');
  });

  test('missing homeTraces json stays unanswered', () {
    final record = DailyCheckIn.fromJson({
      'schemaVersion': 6,
      'dateKey': '2026-09-03',
      'salah': {},
      'quran': {},
    });
    expect(record.homeTrace('dhikr.morningAdhkar'), TernaryOutcome.unanswered);
  });

  test(
    'patterns noticed describe weekday clustering without judgment words',
    () {
      final records = [
        for (final day in [4, 11, 18, 25])
          DailyCheckIn.empty('2026-09-${day.toString().padLeft(2, '0')}')
              .withHomeTrace('family.parentsContact', TernaryOutcome.positive),
      ];
      final patterns = noticedPatterns(
        records: records,
        now: DateTime(2026, 9, 25),
      );
      expect(
        patterns.any(
          (pattern) =>
              pattern.sentence ==
              'Parent Contact records appear more frequently on Fridays.',
        ),
        isTrue,
      );
      final blob = patterns
          .map((pattern) => pattern.sentence)
          .join(' ')
          .toLowerCase();
      expect(blob, isNot(contains('improved')));
      expect(blob, isNot(contains('declined')));
      expect(blob, isNot(contains('better')));
      expect(blob, isNot(contains('worse')));
    },
  );
}
