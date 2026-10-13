import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_akhlaq_catalog.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';

void main() {
  test('Akhlaq catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeAkhlaqCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeAkhlaqCatalog, isNotEmpty);
    expect(
      kPracticeAkhlaqCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      kPracticeAkhlaqCatalog.map((item) => item.group).toSet(),
      {
        kAkhlaqGroupVirtues,
        kAkhlaqGroupAnger,
        kAkhlaqGroupModesty,
        kAkhlaqGroupRestraint,
      },
    );
    expect(kPracticeAkhlaqCatalog.first.group, kAkhlaqGroupVirtues);
  });

  test('Akhlaq register records stay on the Akhlaq domain', () {
    final item = kPracticeAkhlaqCatalog.first;
    final record = recordFromAkhlaqCatalog(
      item: item,
      id: 'a1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.akhlaq);
    expect(record.group, kAkhlaqGroupVirtues);
    expect(record.status, PracticeHadithStatus.learning);
    expect(
      practiceRecordsForDomain([record], MonitorDomain.dhikr),
      isEmpty,
    );
  });
}
