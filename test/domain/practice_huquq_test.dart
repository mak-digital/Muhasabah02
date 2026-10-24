import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_huquq_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Huquq catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeHuquqCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeHuquqCatalog, isNotEmpty);
    expect(
      kPracticeHuquqCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeHuquqCatalog.map((item) => item.group).toSet(), {
      kHuquqGroupHousehold,
      kHuquqGroupExtended,
      kHuquqGroupNeighbours,
      kHuquqGroupPeople,
      kHuquqGroupRepair,
      kHuquqGroupHardship,
    });
    expect(kPracticeHuquqCatalog.first.group, kHuquqGroupHousehold);
    expect(kPracticeHuquqGroups, bandsFor(huquqHomeRows));
    expect(
      kPracticeHuquqCatalog.map((item) => item.topic).toSet(),
      huquqHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeHuquqCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Huquq register records stay on the Huquq domain', () {
    final item = kPracticeHuquqCatalog.first;
    final record = recordFromHuquqCatalog(
      item: item,
      id: 'h1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.huquq);
    expect(record.group, kHuquqGroupHousehold);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.akhlaq), isEmpty);
  });
}
