import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_hajj_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Hajj catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeHajjCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeHajjCatalog, isNotEmpty);
    expect(
      kPracticeHajjCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeHajjGroups, bandsFor(hajjHomeRows));
    expect(
      kPracticeHajjCatalog.map((item) => item.topic).toSet(),
      hajjHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeHajjCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Hajj reminders stay preparation noticing, not a due-date', () {
    expect(
      kPracticeHajjCatalog.any(
        (item) =>
            item.sourceDetail.contains('does not calculate whether Hajj is obligatory'),
      ),
      isTrue,
    );
    expect(
      kPracticeHajjCatalog.any(
        (item) => item.sourceDetail.contains('Umrah is not this status'),
      ),
      isTrue,
    );
  });

  test('Hajj register records stay on the Hajj domain', () {
    final item = kPracticeHajjCatalog.first;
    final record = recordFromHajjCatalog(
      item: item,
      id: 'j1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.hajj);
    expect(record.group, kHajjPreparationBand);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.charity), isEmpty);
  });
}
