import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/noticed_this_week.dart';
import 'package:muhasabah02/domain/patterns_noticed.dart';
import 'package:muhasabah02/domain/personal_baseline.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quotation_cadence.dart';
import 'package:muhasabah02/domain/weekly_quotes.dart';

void main() {
  test('home traces do not change recordable field count', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withHomeTrace('dhikr.postFardFajr', TernaryOutcome.positive)
        .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive);
    expect(record.answeredRecordableCount, 0);
    expect(kRecordableFieldCount, 10);
    expect(record.hasAnyRecordedEvidence, isTrue);
    expect(record.schemaVersion, 6);
  });

  test('dhikr home rows put post-fard salah adhkar first', () {
    expect(bandsFor(dhikrHomeRows), [
      'Post-fard Salah Adhkar',
      'Morning and evening',
      'Other remembrance',
    ]);
    expect(dhikrHomeRows.take(5).map((row) => row.label).toList(), [
      'Fajr',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ]);
  });

  test('quote rotation ignores recorded activity', () {
    final now = DateTime(2026, 9, 3);
    final withRecords = quoteFor(now: now, cadence: QuotationCadence.weekly);
    final empty = quoteFor(now: now, cadence: QuotationCadence.weekly);
    expect(withRecords?.text, empty?.text);
    expect(withRecords?.source, isNotEmpty);
    expect(quoteFor(now: now, cadence: QuotationCadence.hidden), isNull);
  });

  test('daily cadence uses a new bucket each local day', () {
    final thursday = DateTime(2026, 9, 3);
    final friday = DateTime(2026, 9, 4);
    final weeklyThursday = quoteFor(
      now: thursday,
      cadence: QuotationCadence.weekly,
    );
    final weeklyFriday = quoteFor(
      now: friday,
      cadence: QuotationCadence.weekly,
    );
    final dailyThursday = quoteFor(
      now: thursday,
      cadence: QuotationCadence.daily,
    );
    final dailyFriday = quoteFor(now: friday, cadence: QuotationCadence.daily);
    expect(weeklyThursday?.text, weeklyFriday?.text);
    expect(dailyThursday?.text, isNot(dailyFriday?.text));
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
    expect(lines.single.engagementByDay, [
      true,
      true,
      false,
      false,
      false,
      false,
      false,
    ]);
  });

  test('noticed this week omits hidden domains and retired family rows', () {
    final weekKeys = const [
      '2026-08-31',
      '2026-09-01',
      '2026-09-02',
      '2026-09-03',
      '2026-09-04',
      '2026-09-05',
      '2026-09-06',
    ];
    final records = [
      DailyCheckIn.empty('2026-08-31')
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive)
          .withHomeTrace('huquq.parents', TernaryOutcome.positive)
          .withHomeTrace('family.parentsContact', TernaryOutcome.positive),
    ];
    final lines = noticedThisWeek(
      records: records,
      weekKeys: weekKeys,
      visibleDomains: {MonitorDomain.huquq},
    );
    expect(lines, hasLength(1));
    expect(lines.single.sentence, 'Parents on 1 day');
  });

  test('noticed this week follows Personal mix keys', () {
    final weekKeys = const [
      '2026-08-31',
      '2026-09-01',
      '2026-09-02',
      '2026-09-03',
      '2026-09-04',
      '2026-09-05',
      '2026-09-06',
    ];
    final records = [
      DailyCheckIn.empty('2026-08-31')
          .withHomeTrace('dhikr.postFardFajr', TernaryOutcome.positive)
          .withHomeTrace('huquq.parents', TernaryOutcome.positive),
    ];
    final lines = noticedThisWeek(
      records: records,
      weekKeys: weekKeys,
      visibleDomains: Set<MonitorDomain>.from(MonitorDomain.values),
      mix: mixForKind(PersonalMixKind.worship),
    );
    expect(lines.single.sentence, 'Fajr on 1 day');
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
              .withHomeTrace('huquq.parents', TernaryOutcome.positive),
      ];
      final patterns = noticedPatterns(
        records: records,
        now: DateTime(2026, 9, 25),
      );
      expect(
        patterns.any(
          (pattern) =>
              pattern.sentence ==
                  'Parents records appear more frequently on Fridays.' &&
              pattern.highlightedWeekdays.contains(DateTime.friday),
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

  test('patterns noticed omit hidden domains', () {
    final records = [
      for (final day in [4, 11, 18, 25])
        DailyCheckIn.empty('2026-09-${day.toString().padLeft(2, '0')}')
            .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive)
            .withHomeTrace('huquq.parents', TernaryOutcome.positive),
    ];
    final patterns = noticedPatterns(
      records: records,
      now: DateTime(2026, 9, 25),
      visibleDomains: {MonitorDomain.huquq},
    );
    expect(
      patterns.any((pattern) => pattern.sentence.contains('Parents')),
      isTrue,
    );
    expect(
      patterns.any((pattern) => pattern.sentence.contains('Morning Adhkar')),
      isFalse,
    );
  });
}
