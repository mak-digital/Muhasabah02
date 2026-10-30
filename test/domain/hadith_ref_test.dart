import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/bring_hadith_index.dart';
import 'package:muhasabah02/domain/hadith_fetch.dart';
import 'package:muhasabah02/domain/hadith_ref.dart';
import 'package:muhasabah02/domain/personal_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';

void main() {
  test('parses collection number and sunnah.com links', () {
    expect(parseHadithInput('Bukhari 8').ref?.hadithKey, 'bukhari:8');
    expect(parseHadithInput('bukhari:8').ref?.catalogId, 'uh.bukhari.8');
    expect(parseHadithInput('Ṣaḥīḥ Muslim 234').ref?.hadithKey, 'muslim:234');
    expect(
      parseHadithInput('https://sunnah.com/bukhari:8').ref?.hadithKey,
      'bukhari:8',
    );
    expect(
      parseHadithInput('sunnah.com/muslim/234').ref?.hadithKey,
      'muslim:234',
    );
  });

  test('rejects empty, unnamed, and book-path links', () {
    expect(parseHadithInput('').status, HadithParseStatus.empty);
    expect(parseHadithInput('just a note').status, HadithParseStatus.invalid);
    expect(
      parseHadithInput('sunnah.com/bukhari/1/1').status,
      HadithParseStatus.invalid,
    );
  });

  test('built-in waking hadith is already on Learn by key', () {
    expect(
      hadithKeyTaken(
        hadithKey: 'bukhari:6312',
        catalogSources: kPracticeHadithCatalog.map((item) => item.source),
        shelfKeys: const [],
      ),
      isTrue,
    );
    expect(
      hadithKeyTaken(
        hadithKey: 'muslim:1',
        catalogSources: kPracticeHadithCatalog.map((item) => item.source),
        shelfKeys: const [],
      ),
      isFalse,
    );
  });

  test('public hadith JSON is parsed without inventing Arabic', () {
    const raw = '''
{
  "hadiths": [
    {"hadithnumber": 8, "text": "Actions are but by intentions."}
  ]
}
''';
    expect(parseHadithApiText(raw), 'Actions are but by intentions.');
  });

  test('Learn skim appends personal hadith after the built-in list', () {
    const extra = [
      PracticeHadithItem(
        id: 'uh.muslim.1',
        topic: 'Ṣaḥīḥ Muslim 1',
        text: kPersonalHadithBroughtNote,
        arabic: 'ا',
        transliteration: '',
        translation: 't',
        source: 'Ṣaḥīḥ Muslim 1',
        sourceDetail: kPersonalHadithSkimDetail,
      ),
    ];
    final list = practiceHadithLearnList(extra);
    expect(list.length, kPracticeHadithCatalog.length + 1);
    expect(list.last.id, 'uh.muslim.1');
    expect(
      practiceHadithAt(kPracticeHadithCatalog.length, extra).id,
      'uh.muslim.1',
    );
    expect(
      kPracticeHadithCatalog.any((item) => item.id == 'uh.muslim.1'),
      isFalse,
    );
  });

  test('topic and keyword search filters the on-device hadith list', () {
    final keys = kBringHadithIndex.map((item) => item.ref.hadithKey).toList();
    expect(keys.toSet().length, keys.length);
    expect(filterBringHadithIndex('i'), isEmpty);
    expect(
      filterBringHadithIndex('intention').map((item) => item.ref.hadithKey),
      contains('bukhari:1'),
    );
    expect(
      filterBringHadithIndex('mother').map((item) => item.topic),
      contains('Mother'),
    );
    expect(filterBringHadithIndex('xyznotatopic'), isEmpty);
  });
}
