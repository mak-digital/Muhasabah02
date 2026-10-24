import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/hadith_archive.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';
import 'package:muhasabah02/domain/quotation_cadence.dart';
import 'package:muhasabah02/domain/weekly_quotes.dart';

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
    expect(record.sharedDateKeys, isEmpty);
    final shared = recordAfterShare(record, '2026-10-23');
    expect(shared.status, PracticeHadithStatus.learnt);
    expect(shared.sharedDateKeys, ['2026-10-23']);
    final parsed = PracticeHadithRecord.fromJson(record.toJson());
    expect(parsed.sharedDateKeys, isEmpty);
    expect(PracticeHadithRecord.fromJson(shared.toJson()).sharedDateKeys, [
      '2026-10-23',
    ]);
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
    expect(PracticeHadithStatus.habit.labelFor(MonitorDomain.dhikr), 'Habit');
  });

  test(
    'archive keeps the catalog and skips matching reflections when possible',
    () {
      final item = kPracticeHadithCatalog.first;
      final record = recordFromCatalog(
        item: item,
        id: 'r-archive',
        addedDateKey: '2026-10-22',
      ).copyWith(archivedAt: DateTime(2026, 10, 22));
      expect(
        kPracticeHadithCatalog.any((entry) => entry.id == item.id),
        isTrue,
      );
      expect(practiceHadithById(item.id)?.source, item.source);
      final keys = archivedHadithCitationKeys(
        records: [record],
        archivedCatalogIds: {item.id},
      );
      final matching = ReflectionQuote(
        domain: MonitorDomain.hadith,
        text: item.translation,
        source: item.source,
        sourceDetail: item.sourceDetail,
      );
      expect(reflectionHadithIsArchived(matching, keys), isTrue);
      final verse = kReflectionQuotes.firstWhere((quote) => quote.isQuran);
      expect(reflectionHadithIsArchived(verse, keys), isFalse);

      final hadithQuote = kReflectionQuotes.firstWhere(
        (quote) => !quote.isQuran,
      );
      final skip = hadithArchiveKeys(catalogId: '', source: hadithQuote.source);
      final now = DateTime(2026, 9, 3);
      final calendar = quoteFor(now: now, cadence: QuotationCadence.weekly)!;
      final skipped = quoteFor(
        now: now,
        cadence: QuotationCadence.weekly,
        skipHadithKeys: skip,
      )!;
      if (!calendar.isQuran &&
          hadithArchiveKeys(
            catalogId: '',
            source: calendar.source,
          ).any(skip.contains)) {
        expect(skipped.source, isNot(calendar.source));
      }
      expect(kPracticeHadithCatalog.length, 52);
    },
  );
}
