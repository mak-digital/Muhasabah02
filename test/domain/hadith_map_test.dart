import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hadith_map.dart';
import 'package:muhasabah02/domain/personal_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';

PracticeHadithItem _item(String id, String topic) {
  return PracticeHadithItem(
    id: id,
    topic: topic,
    text: 't',
    arabic: 'ا',
    transliteration: 'a',
    translation: 'en',
    source: 'src',
    sourceDetail: 'd',
  );
}

void main() {
  test('Hadith Map keeps one unique list and groups by shape', () {
    final extras = [
      _item('fetch.wudu', 'Wudu'),
      _item('fetch.guest', 'Hospitality'),
    ];
    final marks = buildHadithMapMarks(
      catalog: [
        _item('ph.wudu', 'Wudu'),
        _item('ph.guest', 'Hospitality'),
        _item('ph.wudu', 'Wudu'),
      ],
      extras: extras,
      todayKey: '2026-10-23',
    );
    expect(marks.map((mark) => mark.id).toList(), [
      'ph.wudu',
      'fetch.wudu',
      'ph.guest',
      'fetch.guest',
    ]);
    expect(marks.map((mark) => mark.family).toSet(), {
      HadithMapFamily.prayer,
      HadithMapFamily.character,
    });
  });

  test('fetched copies sit at the end of their shape group', () {
    final marks = buildHadithMapMarks(
      catalog: [
        _item('ph.wudu', 'Wudu'),
        _item('ph.mosque.enter', 'Entering the mosque'),
        _item('ph.guest', 'Hospitality'),
      ],
      extras: [_item('fetch.istikhara', 'Istikhara')],
      todayKey: '2026-10-23',
    );
    final prayer = [
      for (final mark in marks)
        if (mark.family == HadithMapFamily.prayer) mark.id,
    ];
    expect(prayer, ['ph.wudu', 'ph.mosque.enter', 'fetch.istikhara']);
    expect(marks.last.id, 'ph.guest');
  });

  test('register status is Learning, Shared, or Living it — not a grade', () {
    final catalog = [
      _item('ph.wudu', 'Wudu'),
      _item('ph.guest', 'Hospitality'),
    ];
    final records = [
      recordFromCatalog(
        item: catalog[0],
        id: 'r1',
        addedDateKey: '2026-10-20',
      ).copyWith(status: PracticeHadithStatus.learnt),
      recordFromCatalog(
        item: catalog[1],
        id: 'r2',
        addedDateKey: '2026-09-01',
      ).copyWith(status: PracticeHadithStatus.habit),
    ];
    final marks = buildHadithMapMarks(
      catalog: catalog,
      records: records,
      todayKey: '2026-10-23',
    );
    expect(marks[0].fill, HadithMapFill.shared);
    expect(marks[1].fill, HadithMapFill.living);
  });

  test('a share date marks Shared without treating it as a grade', () {
    final catalog = [_item('ph.wudu', 'Wudu')];
    final records = [
      recordAfterShare(
        recordFromCatalog(
          item: catalog[0],
          id: 'r1',
          addedDateKey: '2026-10-20',
        ),
        '2026-10-23',
      ),
    ];
    final marks = buildHadithMapMarks(
      catalog: catalog,
      records: records,
      todayKey: '2026-10-23',
    );
    expect(marks[0].fill, HadithMapFill.shared);
    expect(records[0].sharedDateKeys, ['2026-10-23']);
  });

  test('Shared is skipped until a share date exists', () {
    expect(
      nextHadithMapFill(HadithMapFill.notMet, canShare: false),
      HadithMapFill.learning,
    );
    expect(
      nextHadithMapFill(HadithMapFill.learning, canShare: false),
      HadithMapFill.living,
    );
    expect(
      nextHadithMapFill(HadithMapFill.living, canShare: false),
      HadithMapFill.notMet,
    );
    expect(
      nextHadithMapFill(HadithMapFill.living, canShare: true),
      HadithMapFill.shared,
    );
    expect(hadithSpeechLanguageCode(arabic: false), 'en-US');
    expect(
      pickHadithTtsLanguage(['eng-GBR', 'en_US', 'en'], arabic: false),
      'en_US',
    );
    expect(
      hadithSpeechText(_item('ph.guest', 'Hospitality'), arabic: false),
      'en',
    );
  });

  test(
    'recent fetched copies are New and the period table does not hide marks',
    () {
      final extras = [_item('fetch.patience', 'Anger')];
      final shelf = [
        PersonalHadith(
          id: 'fetch.patience',
          hadithKey: 'tirmidhi:2035',
          slug: 'tirmidhi',
          number: 2035,
          addedDateKey: '2026-10-22',
        ),
      ];
      final marks = buildHadithMapMarks(
        catalog: kPracticeHadithCatalog,
        extras: extras,
        shelf: shelf,
        todayKey: '2026-10-23',
      );
      expect(marks.length, kPracticeHadithCatalog.length + 1);
      final fetched = marks.singleWhere((mark) => mark.id == 'fetch.patience');
      expect(fetched.fill, HadithMapFill.recentlyFetched);
      expect(fetched.family, HadithMapFamily.character);
      final character = [
        for (final mark in marks)
          if (mark.family == HadithMapFamily.character) mark,
      ];
      expect(character.last.id, 'fetch.patience');
      final week = hadithMapStats(
        marks,
        todayKey: '2026-10-23',
        period: HadithMapPeriod.week,
      );
      final month = hadithMapStats(
        marks,
        todayKey: '2026-10-23',
        period: HadithMapPeriod.month,
      );
      expect(week.total, marks.length);
      expect(month.total, marks.length);
      expect(week.periodByFill[HadithMapFill.recentlyFetched], 1);
      expect(week.byFill[HadithMapFill.notMet], greaterThan(0));
    },
  );
}
