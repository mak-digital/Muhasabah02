import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_salah_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';
import 'package:muhasabah02/domain/salah_extras.dart';

void main() {
  test('Salah catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeSalahCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeSalahCatalog, isNotEmpty);
    expect(
      kPracticeSalahCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeSalahCatalog.map((item) => item.group).toSet(), {
      kSalahObligatoryBand,
      kSalahFridayBand,
      kSalahVoluntaryBand,
    });
    expect(kPracticeSalahCatalog.first.group, kSalahObligatoryBand);
    expect(kPracticeSalahGroups, [
      kSalahObligatoryBand,
      kSalahFridayBand,
      kSalahVoluntaryBand,
    ]);
    expect(
      kPracticeSalahCatalog.map((item) => item.topic).toSet(),
      SalahTraceRow.values.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeSalahCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Salah reminders stay observational and not a khushu’ grade', () {
    expect(
      kPracticeSalahCatalog.any(
        (item) => item.sourceDetail.contains('Not a khushu’ score'),
      ),
      isTrue,
    );
    expect(
      kPracticeSalahCatalog.any(
        (item) => item.sourceDetail.contains('Friday-only'),
      ),
      isTrue,
    );
    expect(
      kPracticeSalahCatalog.any(
        (item) => item.sourceDetail.contains('Not the fard of Dhuhr'),
      ),
      isTrue,
    );
  });

  test('Salah register records stay on the Salah domain', () {
    final item = kPracticeSalahCatalog.first;
    final record = recordFromSalahCatalog(
      item: item,
      id: 's1',
      addedDateKey: '2026-10-12',
    );
    expect(record.domain, MonitorDomain.salah);
    expect(record.group, kSalahObligatoryBand);
    expect(record.status, PracticeHadithStatus.learning);
    expect(
      practiceRecordsForDomain([record], MonitorDomain.quran),
      isEmpty,
    );
  });
}
