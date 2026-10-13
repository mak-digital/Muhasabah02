import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_charity_catalog.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Charity catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeCharityCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeCharityCatalog, isNotEmpty);
    expect(
      kPracticeCharityCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeCharityGroups, bandsFor(charityHomeRows));
    expect(
      kPracticeCharityCatalog.map((item) => item.topic).toSet(),
      charityHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeCharityCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Charity reminders stay giving without amounts or a leaderboard', () {
    expect(
      kPracticeCharityCatalog.first.sourceDetail,
      contains('A smile is sadaqah'),
    );
    expect(
      kPracticeCharityCatalog.any(
        (item) => item.sourceDetail.contains('Ordinary household nafaqa'),
      ),
      isTrue,
    );
    expect(
      kPracticeCharityCatalog.any(
        (item) => item.sourceDetail.contains('no zakat calculator'),
      ),
      isTrue,
    );
  });

  test('Charity register records stay on the Charity domain', () {
    final item = kPracticeCharityCatalog.first;
    final record = recordFromCharityCatalog(
      item: item,
      id: 'c1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.charity);
    expect(record.group, kCharityGroupGiving);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.wealth), isEmpty);
  });
}
