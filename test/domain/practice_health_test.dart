import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_health_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Health catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeHealthCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeHealthCatalog, isNotEmpty);
    expect(
      kPracticeHealthCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeHealthGroups, bandsFor(healthHomeRows));
    expect(
      kPracticeHealthCatalog.map((item) => item.topic).toSet(),
      healthHomeRows.map((row) => row.label).toSet(),
    );
    for (final row in healthHomeRows) {
      expect(
        kPracticeHealthCatalog.where((item) => item.topic == row.label).length,
        inInclusiveRange(3, 5),
        reason: row.label,
      );
    }
    expect(
      kPracticeHealthCatalog.every((item) => item.subgroup.isEmpty),
      isTrue,
    );
    expect(
      kPracticeHealthCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test(
    'Health reminders stay a trust of the body, not a fitness programme',
    () {
      expect(
        kPracticeHealthCatalog.any(
          (item) => item.sourceDetail.contains('Not Time & Barakah'),
        ),
        isTrue,
      );
      expect(
        kPracticeHealthCatalog.any(
          (item) => item.sourceDetail.contains('Not calorie counting'),
        ),
        isTrue,
      );
      expect(
        kPracticeHealthCatalog.any(
          (item) => item.sourceDetail.contains('not failings'),
        ),
        isTrue,
      );
    },
  );

  test('Health register records stay on the Health domain', () {
    final item = kPracticeHealthCatalog.first;
    final record = recordFromHealthCatalog(
      item: item,
      id: 'h1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.health);
    expect(record.group, kHealthGroupSleep);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.wealth), isEmpty);
  });
}
