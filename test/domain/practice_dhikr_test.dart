import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_dhikr_catalog.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';

void main() {
  test(
    'Dhikr catalog is grouped with unique ids and recommended sets first',
    () {
      final ids = kPracticeDhikrCatalog.map((item) => item.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(
        kPracticeDhikrCatalog.every(
          (item) =>
              item.arabic.isNotEmpty &&
              item.transliteration.isNotEmpty &&
              item.translation.isNotEmpty,
        ),
        isTrue,
      );
      expect(kPracticeDhikrCatalog.map((item) => item.group).toSet(), {
        kDhikrGroupPost,
        kDhikrGroupMorning,
        kDhikrGroupEvening,
        kDhikrGroupOther,
      });
      expect(
        dhikrItemsInGroup(kDhikrGroupPost).first.subgroup,
        kDhikrSubHighly,
      );
      expect(
        dhikrItemsInGroup(kDhikrGroupMorning).first.subgroup,
        kDhikrSubHighly,
      );
      expect(
        dhikrItemsInGroup(kDhikrGroupEvening).first.subgroup,
        kDhikrSubHighly,
      );
      expect(
        dhikrItemsInGroup(kDhikrGroupOther)
            .map((item) => item.subgroup)
            .toSet(),
        {
          kDhikrSubGeneral,
          kDhikrSubGratitude,
          kDhikrSubTravel,
          kDhikrSubPersonal,
          kDhikrSubOther,
        },
      );
      expect(
        dhikrItemsInGroup(kDhikrGroupPost).length,
        greaterThanOrEqualTo(8),
      );
      expect(
        dhikrItemsInGroup(kDhikrGroupMorning).length,
        greaterThanOrEqualTo(8),
      );
    },
  );

  test('Dhikr register records stay on the Dhikr domain', () {
    final item = kPracticeDhikrCatalog.first;
    final record = recordFromDhikrCatalog(
      item: item,
      id: 'd1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.dhikr);
    expect(record.group, kDhikrGroupPost);
    expect(practiceRecordsForDomain([record], MonitorDomain.hadith), isEmpty);
    expect(
      practiceRecordsForDomain([record], MonitorDomain.dhikr).single.id,
      'd1',
    );
  });
}
