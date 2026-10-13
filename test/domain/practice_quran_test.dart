import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_quran_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Qur’an verse catalog is unique, cited, and skimmable', () {
    final ids = kPracticeQuranCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeQuranCatalog.length, greaterThanOrEqualTo(30));
    expect(
      kPracticeQuranCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.translation.isNotEmpty &&
            reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
    final sources = kPracticeQuranCatalog.map((item) => item.source).toSet();
    expect(sources, containsAll(['Qur’an 1:1–7', 'Qur’an 2:255', 'Qur’an 2:284–286']));
    expect(sources, contains('Qur’an 112:1–4'));
    expect(
      kPracticeQuranCatalog.map((item) => item.topic),
      containsAll(['Al-Fātiḥah', 'Āyat al-Kursī', 'Closing of Al-Baqarah']),
    );
  });

  test('Qur’an Learn copy has no Highly recommended heading', () {
    expect(Copy.practiceQuranTitle.toLowerCase(), isNot(contains('highly')));
    expect(Copy.practiceQuranNote.toLowerCase(), isNot(contains('highly')));
    expect(
      kPracticeQuranCatalog.every(
        (item) => !item.sourceDetail.toLowerCase().contains('highly recommended'),
      ),
      isTrue,
    );
  });

  test('Qur’an reminders stay sittings, not a khushu’ score', () {
    expect(
      kPracticeQuranCatalog.every(
        (item) => item.sourceDetail.contains('not a khushu’ score'),
      ),
      isTrue,
    );
    expect(
      kPracticeQuranCatalog.first.sourceDetail,
      contains('Knowledge’s residual'),
    );
  });

  test('Qur’an register records stay on the Qur’an domain', () {
    final item = kPracticeQuranCatalog.first;
    final record = recordFromQuranCatalog(
      item: item,
      id: 'q1',
      addedDateKey: '2026-10-11',
    );
    expect(record.domain, MonitorDomain.quran);
    expect(record.catalogId, item.id);
    expect(
      practiceRecordsForDomain([record], MonitorDomain.hadith),
      isEmpty,
    );
    expect(practiceQuranAt(kPracticeQuranCatalog.length).id, item.id);
  });
}
