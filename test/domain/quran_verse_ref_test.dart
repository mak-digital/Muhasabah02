import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/bring_quran_index.dart';
import 'package:muhasabah02/domain/personal_quran_verse.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_quran_catalog.dart';
import 'package:muhasabah02/domain/quran_verse_fetch.dart';
import 'package:muhasabah02/domain/quran_verse_ref.dart';

void main() {
  test('surah verse counts cover 114 chapters', () {
    expect(kQuranSurahVerseCounts, hasLength(114));
    expect(kQuranSurahVerseCounts[0], 7);
    expect(kQuranSurahVerseCounts[1], 286);
    expect(kQuranSurahVerseCounts[111], 4);
    expect(kQuranSurahVerseCounts[113], 6);
  });

  test('parses chapter:verse, ranges, and quran.com links', () {
    expect(parseQuranVerseInput('2:255').range?.verseKey, '2:255');
    expect(parseQuranVerseInput('2:255–257').range?.verseKey, '2:255-257');
    expect(parseQuranVerseInput('Qur’an 2:255').range?.catalogId, 'uq.2.255');
    expect(
      parseQuranVerseInput('https://quran.com/2/255').range?.verseKey,
      '2:255',
    );
    expect(parseQuranVerseInput('quran.com/2/255-257').range?.verseKey, '2:255-257');
    expect(parseQuranVerseInput('quran.com/2?startingVerse=255').range?.verseKey, '2:255');
  });

  test('rejects invalid, whole-surah, and long passages', () {
    expect(parseQuranVerseInput('').status, QuranVerseParseStatus.empty);
    expect(parseQuranVerseInput('al-baqarah/255').status, QuranVerseParseStatus.invalid);
    expect(parseQuranVerseInput('quran.com/2').status, QuranVerseParseStatus.invalid);
    expect(parseQuranVerseInput('2:999').status, QuranVerseParseStatus.invalid);
    expect(parseQuranVerseInput('2:1-20').status, QuranVerseParseStatus.tooLong);
    expect(parseQuranVerseInput('2:255-261').range?.verseCount, 7);
    expect(parseQuranVerseInput('2:255-262').status, QuranVerseParseStatus.tooLong);
    expect(parseQuranVerseInput('2:255–257').range?.verseCount, 3);
    expect(parseQuranVerseInput('2:255-262').range, isNull);
  });

  test('built-in Ayat al-Kursi is already on Learn by verse key', () {
    expect(
      quranVerseKeyTaken(
        verseKey: '2:255',
        catalogSources: kPracticeQuranCatalog.map((item) => item.source),
        shelfKeys: const [],
      ),
      isTrue,
    );
    expect(
      quranVerseKeyTaken(
        verseKey: '3:16',
        catalogSources: kPracticeQuranCatalog.map((item) => item.source),
        shelfKeys: const [],
      ),
      isFalse,
    );
  });

  test('quran.com verse JSON is parsed without inventing Arabic', () {
    const raw = '''
{
  "verses": [
    {
      "verse_key": "3:16",
      "text_uthmani": "رَبَّنَا إِنَّنَا آمَنَّا",
      "translations": [
        {"text": "Our Lord, indeed we have believed<sup foot_note=1>1</sup>"}
      ]
    }
  ]
}
''';
    final passage = parseQuranComVersesResponse(
      raw,
      const QuranVerseRange(surah: 3, start: 16, end: 16),
    );
    expect(passage.arabic, 'رَبَّنَا إِنَّنَا آمَنَّا');
    expect(passage.translation, 'Our Lord, indeed we have believed 1');
  });

  test('Learn skim appends personal verses after the built-in list', () {
    const extra = [
      PracticeHadithItem(
        id: 'uq.3.16',
        topic: 'Qur’an 3:16',
        text: kPersonalQuranBroughtNote,
        arabic: 'ا',
        transliteration: '',
        translation: 't',
        source: 'Qur’an 3:16',
        sourceDetail: kPersonalQuranSkimDetail,
      ),
    ];
    final list = practiceQuranLearnList(extra);
    expect(list.length, kPracticeQuranCatalog.length + 1);
    expect(list.last.id, 'uq.3.16');
    expect(practiceQuranAt(kPracticeQuranCatalog.length, extra).id, 'uq.3.16');
    expect(kPracticeQuranCatalog.any((item) => item.id == 'uq.3.16'), isFalse);
  });

  test('topic and keyword search filters the on-device verse list', () {
    final keys = kBringQuranIndex.map((item) => item.range.verseKey).toList();
    expect(keys.toSet().length, keys.length);
    expect(filterBringQuranIndex('k'), isEmpty);
    expect(
      filterBringQuranIndex('kursi').map((item) => item.range.verseKey),
      contains('2:255'),
    );
    expect(
      filterBringQuranIndex('parents').map((item) => item.topic),
      contains('Parents'),
    );
    expect(filterBringQuranIndex('xyznotatopic'), isEmpty);
  });
}
