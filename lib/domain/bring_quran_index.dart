import 'quran_verse_ref.dart';

/// A short, on-device list for topic and keyword search.
///
/// Not a complete mushaf, not a tafsir, and not a scrape of quran.com.
/// Exact chapter and verse remain available for those who have them.
class BringQuranIndexItem {
  const BringQuranIndexItem({
    required this.surah,
    required this.start,
    required this.end,
    required this.topic,
    required this.keywords,
    required this.preview,
  });

  final int surah;
  final int start;
  final int end;
  final String topic;
  final String keywords;
  final String preview;

  QuranVerseRange get range =>
      QuranVerseRange(surah: surah, start: start, end: end);

  String get hitKey => range.isRange
      ? '${range.surah}-${range.start}-${range.end}'
      : '${range.surah}-${range.start}';

  String get searchText =>
      '$topic $keywords $preview ${range.citation} ${range.verseKey}'
          .toLowerCase();
}

BringQuranIndexItem _v({
  required int surah,
  required int start,
  int? end,
  required String topic,
  required String keywords,
  required String preview,
}) {
  return BringQuranIndexItem(
    surah: surah,
    start: start,
    end: end ?? start,
    topic: topic,
    keywords: keywords,
    preview: preview,
  );
}

const int kBringQuranSearchMinChars = 2;
const int kBringQuranSearchLimit = 12;

final List<BringQuranIndexItem> kBringQuranIndex = [
  _v(
    surah: 1,
    start: 1,
    end: 7,
    topic: 'Al-Fātiḥah',
    keywords: 'opening fatiha prayer guidance',
    preview: 'The opening of the Book, recited in prayer.',
  ),
  _v(
    surah: 2,
    start: 255,
    topic: 'Āyat al-Kursī',
    keywords: 'kursi throne protection allah living',
    preview: 'Allah — there is no god except Him, the Ever-Living.',
  ),
  _v(
    surah: 2,
    start: 152,
    topic: 'Remembrance',
    keywords: 'dhikr remember me thank grateful',
    preview: 'Remember Me; I will remember you.',
  ),
  _v(
    surah: 2,
    start: 186,
    topic: 'He is near',
    keywords: 'dua prayer near respond call',
    preview: 'When My servants ask you about Me, I am near.',
  ),
  _v(
    surah: 2,
    start: 286,
    topic: 'Burden and capacity',
    keywords: 'burden hardship capacity forgive',
    preview: 'Allah does not burden a soul beyond what it can bear.',
  ),
  _v(
    surah: 3,
    start: 103,
    topic: 'Hold together',
    keywords: 'unity rope brotherhood ummah',
    preview: 'Hold firmly to the rope of Allah and do not be divided.',
  ),
  _v(
    surah: 3,
    start: 159,
    topic: 'Gentleness and consultation',
    keywords: 'gentle shura consult pardon',
    preview: 'By mercy from Allah you were lenient with them. Consult them.',
  ),
  _v(
    surah: 4,
    start: 36,
    topic: 'Parents and neighbours',
    keywords: 'parents kin neighbour orphan',
    preview: 'Worship Allah and be good to parents, relatives, and neighbours.',
  ),
  _v(
    surah: 9,
    start: 51,
    topic: 'Trust',
    keywords: 'tawakkul trust decree enough',
    preview: 'Say: Never will we be struck except what Allah has decreed.',
  ),
  _v(
    surah: 13,
    start: 28,
    topic: 'Hearts at rest',
    keywords: 'heart dhikr calm peace remember',
    preview: 'In the remembrance of Allah do hearts find rest.',
  ),
  _v(
    surah: 16,
    start: 90,
    topic: 'Justice and kindness',
    keywords: 'justice ihsan charity kinship',
    preview: 'Allah commands justice, kindness, and giving to relatives.',
  ),
  _v(
    surah: 17,
    start: 23,
    topic: 'Parents',
    keywords: 'mother father kindness honour',
    preview: 'Do not say to them “uff”, and speak to them nobly.',
  ),
  _v(
    surah: 17,
    start: 32,
    topic: 'Do not approach zina',
    keywords: 'chastity zina adultery',
    preview: 'Do not approach unlawful sexual intercourse.',
  ),
  _v(
    surah: 18,
    start: 24,
    topic: 'If Allah wills',
    keywords: 'inshallah remember forget',
    preview: 'Say: If Allah wills — and remember your Lord when you forget.',
  ),
  _v(
    surah: 21,
    start: 83,
    topic: 'Patience in harm',
    keywords: 'ayyub patience harm mercy',
    preview: 'Ayyub called: harm has touched me, and You are most merciful.',
  ),
  _v(
    surah: 24,
    start: 35,
    topic: 'Light',
    keywords: 'nur light lamp parable',
    preview: 'Allah is the Light of the heavens and the earth.',
  ),
  _v(
    surah: 25,
    start: 63,
    topic: 'Servants of the Most Merciful',
    keywords: 'humble earth walk speech',
    preview: 'The servants of the Most Merciful walk upon the earth in humility.',
  ),
  _v(
    surah: 29,
    start: 69,
    topic: 'Strive',
    keywords: 'jihad strive path guide',
    preview: 'Those who strive for Us — We will surely guide them.',
  ),
  _v(
    surah: 31,
    start: 14,
    topic: 'Parents and weaning',
    keywords: 'mother father thanks gratitude',
    preview: 'Be grateful to Me and to your parents.',
  ),
  _v(
    surah: 33,
    start: 21,
    topic: 'A fine example',
    keywords: 'prophet example uswa manners',
    preview: 'In the Messenger of Allah you have a fine example.',
  ),
  _v(
    surah: 39,
    start: 53,
    topic: 'Do not despair',
    keywords: 'mercy forgive despair sin hope',
    preview: 'Do not despair of the mercy of Allah.',
  ),
  _v(
    surah: 40,
    start: 60,
    topic: 'Call upon Me',
    keywords: 'dua pray ask respond',
    preview: 'Call upon Me; I will respond to you.',
  ),
  _v(
    surah: 41,
    start: 30,
    topic: 'Do not fear or grieve',
    keywords: 'angels steadfast fear grief',
    preview: 'Those who say “Our Lord is Allah” then remain steadfast.',
  ),
  _v(
    surah: 49,
    start: 10,
    topic: 'Believers are brothers',
    keywords: 'brotherhood make peace ummah',
    preview: 'The believers are but brothers, so make peace.',
  ),
  _v(
    surah: 49,
    start: 12,
    topic: 'Avoid suspicion',
    keywords: 'spy backbite suspicion assume',
    preview: 'Avoid much assumption. Do not spy or backbite.',
  ),
  _v(
    surah: 51,
    start: 56,
    topic: 'Worship',
    keywords: 'jinn mankind created worship',
    preview: 'I did not create jinn and mankind except to worship Me.',
  ),
  _v(
    surah: 58,
    start: 11,
    topic: 'Knowledge',
    keywords: 'ilm ranks raise sit',
    preview: 'Allah will raise those who have been given knowledge in ranks.',
  ),
  _v(
    surah: 64,
    start: 11,
    topic: 'Whatever hits you',
    keywords: 'calamity faith heart guide',
    preview: 'No disaster strikes except by permission of Allah.',
  ),
  _v(
    surah: 65,
    start: 2,
    end: 3,
    topic: 'Whoever is mindful of Allah',
    keywords: 'taqwa way out provision tawakkul',
    preview: 'Whoever is mindful of Allah — He will make a way out.',
  ),
  _v(
    surah: 94,
    start: 5,
    end: 6,
    topic: 'With hardship comes ease',
    keywords: 'hardship ease relief difficulty',
    preview: 'With hardship comes ease.',
  ),
  _v(
    surah: 103,
    start: 1,
    end: 3,
    topic: 'Time',
    keywords: 'asr time loss faith patience',
    preview: 'By time, mankind is in loss — except those who believe and do right.',
  ),
  _v(
    surah: 112,
    start: 1,
    end: 4,
    topic: 'Al-Ikhlāṣ',
    keywords: 'tawhid oneness ahad ikhlas',
    preview: 'Say: He is Allah, One.',
  ),
];

List<BringQuranIndexItem> filterBringQuranIndex(
  String query, {
  int limit = kBringQuranSearchLimit,
}) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.length < kBringQuranSearchMinChars) return const [];
  final tokens = [
    for (final part in trimmed.split(RegExp(r'\s+')))
      if (part.length >= 2) part,
  ];
  if (tokens.isEmpty) return const [];
  final hits = <BringQuranIndexItem>[];
  final seen = <String>{};
  for (final item in kBringQuranIndex) {
    if (seen.contains(item.range.verseKey)) continue;
    if (!tokens.every(item.searchText.contains)) continue;
    seen.add(item.range.verseKey);
    hits.add(item);
    if (hits.length >= limit) break;
  }
  return hits;
}
