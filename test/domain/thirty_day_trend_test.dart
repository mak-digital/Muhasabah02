import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/dhikr_context.dart';
import 'package:muhasabah02/domain/thirty_day_trend.dart';

void main() {
  test('6 of 20 answered days is 30 percent', () {
    expect(trendPercent(6, 20), 30);
  });

  test('zero denominator is unavailable not 0 percent', () {
    expect(trendPercent(0, 0), isNull);
    expect(trendPercent(0, 10), 0);
    expect(
      compactTrendRecordedLine(hits: 0, denom: 0, percent: null),
      contains('unavailable'),
    );
  });

  test('unanswered days are excluded from the denominator', () {
    const ids = ['joinedCongregationLate', 'missed'];
    final stats = measureTrendWindow(
      keys: const ['2026-10-01', '2026-10-02', '2026-10-03', '2026-10-04'],
      todayKey: '2026-10-23',
      optionIds: ids,
      idForDate: (key) => switch (key) {
        '2026-10-01' => 'joinedCongregationLate',
        '2026-10-02' => 'missed',
        '2026-10-03' => 'unanswered',
        _ => null,
      },
    );
    expect(stats.denom, 2);
    expect(stats.countFor('missed'), 1);
    expect(stats.countFor('joinedCongregationLate'), 1);
  });

  test('future days are excluded from an incomplete C window', () {
    final keys = periodDateKeys(30, now: DateTime(2026, 10, 23));
    var answered = 0;
    final stats = measureTrendWindow(
      keys: keys,
      todayKey: '2026-09-28',
      optionIds: const ['congregationOnTime'],
      idForDate: (key) {
        if (key.compareTo('2026-09-28') > 0) return 'congregationOnTime';
        answered++;
        return 'congregationOnTime';
      },
    );
    expect(stats.denom, lessThan(30));
    expect(stats.denom, answered);
  });

  test('the same date keeps the same response across A B and C', () {
    String? idFor(String key) => key == '2026-10-01' ? 'prayedLate' : null;
    final a = measureTrendWindow(
      keys: const ['2026-09-24', '2026-10-01'],
      todayKey: '2026-10-23',
      optionIds: const ['prayedLate'],
      idForDate: idFor,
    );
    final shifted = measureTrendWindow(
      keys: const ['2026-10-01', '2026-10-23'],
      todayKey: '2026-10-23',
      optionIds: const ['prayedLate'],
      idForDate: idFor,
    );
    expect(a.countFor('prayedLate'), 1);
    expect(shifted.countFor('prayedLate'), 1);
  });

  test('selection prefers frequent stable options and actual change', () {
    TrendWindowStats window(Map<String, int> hits, int denom) {
      return TrendWindowStats(
        startKey: '2026-09-01',
        endKey: '2026-09-30',
        denom: denom,
        hits: hits,
      );
    }

    final stable = selectFiveTrendOptionIds(
      optionIds: const [
        'congregationOnTime',
        'joinedCongregationLate',
        'missed',
        'other',
      ],
      windows: [
        window({'congregationOnTime': 20, 'joinedCongregationLate': 4}, 28),
        window({'congregationOnTime': 19, 'joinedCongregationLate': 5}, 28),
        window({'congregationOnTime': 21, 'joinedCongregationLate': 3}, 28),
      ],
    );
    expect(stable.first, 'congregationOnTime');

    final changed = selectFiveTrendOptionIds(
      optionIds: const ['congregationOnTime', 'missed'],
      windows: [
        window({'congregationOnTime': 20, 'missed': 1}, 22),
        window({'congregationOnTime': 10, 'missed': 10}, 22),
        window({'congregationOnTime': 4, 'missed': 16}, 22),
      ],
    );
    expect(changed, isNot(orderedEquals(stable.take(2))));
    expect(changed.contains('missed'), isTrue);
  });

  test('at most five options are selected', () {
    final hits = {for (var i = 0; i < 8; i++) 'opt$i': i + 1};
    final selected = selectFiveTrendOptionIds(
      optionIds: hits.keys.toList(),
      windows: [
        TrendWindowStats(startKey: 'a', endKey: 'b', denom: 40, hits: hits),
        TrendWindowStats(startKey: 'c', endKey: 'd', denom: 40, hits: hits),
        TrendWindowStats(startKey: 'e', endKey: 'f', denom: 40, hits: hits),
      ],
    );
    expect(selected.length, 5);
  });

  test('choice labels keep relative bands and drop a repeated row name', () {
    expect(
      compactChoiceLabel(
        'Engaged more than 20 minutes — Engagement',
        activityLabel: 'Engagement',
        stripCatalogRowName: true,
      ),
      'Engaged >20 mins',
    );
    expect(
      compactChoiceLabel('Engaged 15–20 minutes — Engagement'),
      'Engaged 15–20 mins',
    );
    expect(
      compactChoiceLabel('Engaged 5–10 minutes — Engagement'),
      'Engaged 5–10 mins',
    );
    expect(
      compactChoiceLabel('Involved 3–5 minutes — Practical relevance'),
      'Involved 3–5 mins',
    );
    expect(
      compactChoiceLabel(
        'I did not notice this today — Engagement',
        stripCatalogRowName: true,
      ),
      'Did not notice',
    );
    expect(
      compactChoiceLabel('Prayed late', activityLabel: 'Fajr'),
      'Prayed late (Fajr)',
    );
    expect(
      compactChoiceLabel(
        'Intentional remembrance (I deliberately made time for dhikr or du‘a)',
        activityLabel: 'Fajr',
      ),
      'Intentional remembrance (Fajr)',
    );
    expect(
      compactChoiceLabel('Prayed on time in congregation'),
      'On time in congregation',
    );
    expect(compactChoiceLabel('Prayed late (alone)'), 'Late (alone)');
    expect(
      compactChoiceLabel(
        'Remained patient when tested',
        optionId: 'practised',
        activityLabel: 'Patience',
      ),
      'Did this (Patience)',
    );
    expect(
      compactChoiceLabel(
        'I slept well and felt reasonably refreshed.',
        optionId: 'health.sleepQuality.refreshed',
      ),
      'Did this',
    );
    expect(
      compactChoiceLabel(
        "Completed today's fast",
        optionId: 'fasting.ramadanObserved.completed',
      ),
      "Completed today's fast",
    );
    expect(
      compactChoiceLabel(
        'Not a White Day today',
        optionId: 'fasting.monthly.noSituation',
      ),
      'Not a White Day today',
    );
    expect(
      compactChoiceLabel(
        'Completed a make-up fast',
        optionId: 'fasting.makeup.completed',
        activityLabel: 'Make-up Fast',
      ),
      'Completed a make-up fast',
    );
    expect(
      compactChoiceLabel(
        'Had an opportunity but did not give',
        optionId: 'charity.voluntary.didNotGive',
      ),
      'Difficulty recognised',
    );
  });

  test('morning and evening adhkar have chartable performed-list catalogs', () {
    expect(dhikrContextTrendCatalog(kDhikrMorningKey), isNotEmpty);
    expect(dhikrContextTrendCatalog(kDhikrEveningKey), isNotEmpty);
    expect(dhikrContextTrendCatalog(kDhikrGeneralKey), isNotEmpty);
    expect(dhikrContextTrendCatalog('dhikr.postFardFajr'), isNotEmpty);
  });

  test('checklist days can count more than one practised formula', () {
    final morning = dhikrContextItemsFor(kDhikrMorningKey);
    final a = morning.first.id;
    final b = morning[1].id;
    final stats = measureTrendWindow(
      keys: const ['2026-10-01', '2026-10-02', '2026-10-03'],
      todayKey: '2026-10-23',
      optionIds: [a, b],
      idForDate: (_) => null,
      hitsForDate: (key) => switch (key) {
        '2026-10-01' => [a, b],
        '2026-10-02' => const <String>[],
        _ => [a],
      },
      dayAnswered: (key) => key != '2026-10-02',
    );
    expect(stats.denom, 2);
    expect(stats.countFor(a), 2);
    expect(stats.countFor(b), 1);
  });
}
