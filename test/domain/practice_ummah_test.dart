import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_ummah_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Ummah catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeUmmahCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeUmmahCatalog, isNotEmpty);
    expect(
      kPracticeUmmahCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeUmmahGroups, bandsFor(ummahHomeRows));
    expect(
      kPracticeUmmahCatalog.map((item) => item.topic).toSet(),
      ummahHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeUmmahCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Ummah reminders stay belonging, not fard or giving', () {
    expect(kPracticeUmmahCatalog.first.sourceDetail, contains('not the fard'));
    expect(
      kPracticeUmmahCatalog.any(
        (item) => item.sourceDetail.contains('not Charity’s giving'),
      ),
      isTrue,
    );
    expect(
      kPracticeUmmahCatalog.any(
        (item) => item.sourceDetail.contains('The Ummah is global'),
      ),
      isTrue,
    );
  });

  test('Ummah register records stay on the Ummah domain', () {
    final item = kPracticeUmmahCatalog.first;
    final record = recordFromUmmahCatalog(
      item: item,
      id: 'u1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.ummah);
    expect(record.group, kUmmahGroupMasjid);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceRecordsForDomain([record], MonitorDomain.huquq), isEmpty);
  });
}
