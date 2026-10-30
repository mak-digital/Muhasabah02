import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_fasting_catalog.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Fasting catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeFastingCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeFastingCatalog, isNotEmpty);
    expect(
      kPracticeFastingCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeFastingGroups, bandsFor(fastingHomeRows));
    expect(
      kPracticeFastingCatalog.map((item) => item.topic).toSet(),
      fastingHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeFastingCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Fasting reminders stay noticing, not a prescription to fast', () {
    expect(
      kPracticeFastingCatalog.any(
        (item) => item.sourceDetail.contains('Not a weekly quota'),
      ),
      isTrue,
    );
    expect(
      kPracticeFastingCatalog.any(
        (item) => item.sourceDetail.contains('does not record a fast'),
      ),
      isTrue,
    );
    expect(
      kPracticeFastingCatalog.any(
        (item) => item.sourceDetail.contains('not a Ramadan fard tracker'),
      ),
      isTrue,
    );
  });

  test('Fasting register records stay on the Fasting domain', () {
    final item = kPracticeFastingCatalog.first;
    final record = recordFromFastingCatalog(
      item: item,
      id: 'f1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.fasting);
    expect(record.group, kFastingGroupFastConduct);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.health), isEmpty);
  });
}
