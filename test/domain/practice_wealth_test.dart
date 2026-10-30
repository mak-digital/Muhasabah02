import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_wealth_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Wealth catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeWealthCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeWealthCatalog, isNotEmpty);
    expect(
      kPracticeWealthCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeWealthGroups, bandsFor(wealthHomeRows));
    expect(
      kPracticeWealthCatalog.map((item) => item.topic).toSet(),
      wealthHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeWealthCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Wealth reminders stay earning as a trust, not Charity giving', () {
    expect(
      kPracticeWealthCatalog.any(
        (item) => item.sourceDetail.contains('Poverty is not a failing'),
      ),
      isTrue,
    );
    expect(
      kPracticeWealthCatalog.any(
        (item) =>
            item.sourceDetail.contains('Giving and zakat stay on Charity'),
      ),
      isTrue,
    );
  });

  test('Wealth register records stay on the Wealth domain', () {
    final item = kPracticeWealthCatalog.first;
    final record = recordFromWealthCatalog(
      item: item,
      id: 'w1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.wealth);
    expect(record.group, kWealthGroupEarning);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.health), isEmpty);
  });
}
