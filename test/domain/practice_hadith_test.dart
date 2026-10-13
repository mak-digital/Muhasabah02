import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';

void main() {
  test('catalog ids are unique and wrap', () {
    final ids = kPracticeHadithCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeHadithCatalog, isNotEmpty);
    expect(
      kPracticeHadithCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      practiceHadithAt(kPracticeHadithCatalog.length).id,
      kPracticeHadithCatalog.first.id,
    );
    expect(wrapPracticeHadithIndex(-1, 4), 3);
    expect(kPracticeHadithCatalog.length, 52);
    final arabic = kPracticeHadithCatalog.map((item) => item.arabic).toList();
    expect(arabic.toSet().length, arabic.length);
  });

  test('a catalog item can be registered once', () {
    final item = kPracticeHadithCatalog.first;
    final record = recordFromCatalog(
      item: item,
      id: 'r1',
      addedDateKey: '2026-10-09',
    );
    expect(record.topic, item.topic);
    expect(record.source, item.source);
    expect(record.status, PracticeHadithStatus.learning);
    expect(practiceHadithAlreadyRegistered([record], item.id), isTrue);
    expect(
      practiceHadithAlreadyRegistered([record], kPracticeHadithCatalog[1].id),
      isFalse,
    );
  });

  test('older Know / In Practice ids map onto the four-stage list', () {
    expect(PracticeHadithStatusX.fromId('know'), PracticeHadithStatus.learnt);
    expect(
      PracticeHadithStatusX.fromId('inPractice'),
      PracticeHadithStatus.practicing,
    );
    expect(
      PracticeHadithStatus.habit.labelFor(MonitorDomain.hadith),
      'Living it',
    );
    expect(
      PracticeHadithStatus.habit.labelFor(MonitorDomain.dhikr),
      'Habit',
    );
  });
}
