import 'hadith_ref.dart';

/// A short, on-device list for topic and keyword search.
///
/// Not a complete musnad, not a grade, and not a scrape of sunnah.com.
/// Exact collection numbers remain available for those who have them.
class BringHadithIndexItem {
  const BringHadithIndexItem({
    required this.slug,
    required this.number,
    required this.topic,
    required this.keywords,
    required this.preview,
  });

  final String slug;
  final int number;
  final String topic;
  final String keywords;
  final String preview;

  HadithRef get ref => HadithRef(slug: slug, number: number);

  String get searchText =>
      '$topic $keywords $preview ${ref.citation} ${ref.hadithKey}'.toLowerCase();
}

BringHadithIndexItem _h({
  required String slug,
  required int number,
  required String topic,
  required String keywords,
  required String preview,
}) {
  return BringHadithIndexItem(
    slug: slug,
    number: number,
    topic: topic,
    keywords: keywords,
    preview: preview,
  );
}

const int kBringHadithSearchMinChars = 2;
const int kBringHadithSearchLimit = 12;

final List<BringHadithIndexItem> kBringHadithIndex = [
  _h(
    slug: 'bukhari',
    number: 1,
    topic: 'Intention',
    keywords: 'niyyah deeds actions motives heart',
    preview: 'Actions are by intentions.',
  ),
  _h(
    slug: 'bukhari',
    number: 8,
    topic: 'Five pillars',
    keywords: 'islam salah zakat hajj ramadan fasting shahada',
    preview: 'Islam is built on five.',
  ),
  _h(
    slug: 'muslim',
    number: 8,
    topic: 'Islam, iman, and ihsan',
    keywords: 'jibril gabriel faith excellence worship',
    preview: 'The hadith of Jibril on islam, iman, and ihsan.',
  ),
  _h(
    slug: 'bukhari',
    number: 10,
    topic: 'The Muslim',
    keywords: 'tongue hand harm safety neighbour speech',
    preview: 'The Muslim is the one from whose tongue and hand people are safe.',
  ),
  _h(
    slug: 'bukhari',
    number: 13,
    topic: 'Love for your brother',
    keywords: 'faith iman wish brother sister love',
    preview: 'None of you believes until he loves for his brother what he loves for himself.',
  ),
  _h(
    slug: 'muslim',
    number: 45,
    topic: 'Love for your brother',
    keywords: 'faith iman wish brother sister love',
    preview: 'None of you believes until he loves for his brother what he loves for himself.',
  ),
  _h(
    slug: 'bukhari',
    number: 30,
    topic: 'Haya',
    keywords: 'modesty shyness branches iman faith',
    preview: 'Haya is a branch of faith.',
  ),
  _h(
    slug: 'ibnmajah',
    number: 224,
    topic: 'Seeking knowledge',
    keywords: 'ilm study learn path jannah',
    preview: 'Seeking knowledge is an obligation.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 2646,
    topic: 'Seeking knowledge',
    keywords: 'ilm study learn path jannah ease',
    preview: 'Whoever takes a path to knowledge, Allah eases a path to the Garden.',
  ),
  _h(
    slug: 'bukhari',
    number: 2442,
    topic: 'Help your brother',
    keywords: 'oppressor oppressed justice support',
    preview: 'Help your brother, whether he is the oppressor or the oppressed.',
  ),
  _h(
    slug: 'muslim',
    number: 2585,
    topic: 'The believers as one body',
    keywords: 'ummah mercy body pain unity',
    preview: 'The believers in their mutual mercy are like one body.',
  ),
  _h(
    slug: 'muslim',
    number: 2586,
    topic: 'Believers like a structure',
    keywords: 'ummah brick support strengthen one another',
    preview: 'The believer to the believer is like a structure, each part supporting the other.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 1924,
    topic: 'Mercy',
    keywords: 'rahmah compassionate kind people animals',
    preview: 'Those who are merciful will be shown mercy.',
  ),
  _h(
    slug: 'muslim',
    number: 2548,
    topic: 'Mother',
    keywords: 'parents mother father family birr kindness',
    preview: 'Your mother, then your mother, then your mother, then your father.',
  ),
  _h(
    slug: 'bukhari',
    number: 5971,
    topic: 'Kindness to parents',
    keywords: 'mother father family birr parents',
    preview: 'The pleasure of Allah is in the pleasure of the parents.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 1956,
    topic: 'Smiling',
    keywords: 'smile charity sadaqah kind face',
    preview: 'Your smiling in the face of your brother is charity.',
  ),
  _h(
    slug: 'bukhari',
    number: 6021,
    topic: 'Every good deed is charity',
    keywords: 'sadaqah charity good word help',
    preview: 'Every good deed is charity.',
  ),
  _h(
    slug: 'bukhari',
    number: 6116,
    topic: 'Anger',
    keywords: 'strong wrestler self control ghadab',
    preview: 'The strong is not the one who wrestles; the strong is the one who controls himself in anger.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 2003,
    topic: 'Good character',
    keywords: 'akhlaq manners iman faith complete',
    preview: 'The most complete in faith are those best in character.',
  ),
  _h(
    slug: 'muslim',
    number: 2581,
    topic: 'The bankrupt',
    keywords: 'qiyamah rights backbiting hitting judgement',
    preview: 'The bankrupt is the one who comes with prayer and fasting but has wronged others.',
  ),
  _h(
    slug: 'muslim',
    number: 2589,
    topic: 'Backbiting',
    keywords: 'gheebah ghiba speech mention brother',
    preview: 'Backbiting is to mention your brother with what he dislikes.',
  ),
  _h(
    slug: 'muslim',
    number: 2564,
    topic: 'Envy and hatred',
    keywords: 'hasad hate cut off spy',
    preview: 'Do not envy, do not hate, and be servants of Allah as brothers.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 2318,
    topic: 'Leave what does not concern you',
    keywords: 'silence speech extra unused',
    preview: 'Part of the goodness of a person’s islam is leaving what does not concern him.',
  ),
  _h(
    slug: 'bukhari',
    number: 6475,
    topic: 'Speak good or remain silent',
    keywords: 'speech tongue silence last day iman',
    preview: 'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
  ),
  _h(
    slug: 'bukhari',
    number: 6136,
    topic: 'Honour the guest',
    keywords: 'guest hospitality neighbour last day',
    preview: 'Whoever believes in Allah and the Last Day, let him honour his guest.',
  ),
  _h(
    slug: 'bukhari',
    number: 6005,
    topic: 'The orphan',
    keywords: 'orphan care near jannah',
    preview: 'The one who cares for an orphan and I will be like this in the Garden.',
  ),
  _h(
    slug: 'bukhari',
    number: 5653,
    topic: 'Visiting the sick',
    keywords: 'sick visit mercy garden',
    preview: 'Feed the hungry, visit the sick, and free the captive.',
  ),
  _h(
    slug: 'muslim',
    number: 2699,
    topic: 'Relieve a believer',
    keywords: 'distress hardship knowledge ease world',
    preview: 'Whoever relieves a believer’s distress, Allah will relieve him.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 1954,
    topic: 'Thanking people',
    keywords: 'shukr thanks gratitude people',
    preview: 'Whoever does not thank people has not thanked Allah.',
  ),
  _h(
    slug: 'bukhari',
    number: 2465,
    topic: 'A Muslim is a brother',
    keywords: 'harm betray despise right',
    preview: 'A Muslim is a brother of a Muslim: he does not wrong him or hand him over.',
  ),
  _h(
    slug: 'bukhari',
    number: 6064,
    topic: 'Suspicion',
    keywords: 'zann spy hate assumption',
    preview: 'Beware of suspicion, for suspicion is the falsest of speech.',
  ),
  _h(
    slug: 'muslim',
    number: 2568,
    topic: 'Do not despise',
    keywords: 'blood wealth honour muslim',
    preview: 'The blood, wealth, and honour of a Muslim are sacred.',
  ),
  _h(
    slug: 'bukhari',
    number: 5066,
    topic: 'Marriage',
    keywords: 'nikah marry youth chaste',
    preview: 'O young people, whoever is able to marry, let him marry.',
  ),
  _h(
    slug: 'muslim',
    number: 55,
    topic: 'Religion is sincere counsel',
    keywords: 'naseehah advice deen religion',
    preview: 'The religion is sincere counsel.',
  ),
  _h(
    slug: 'bukhari',
    number: 6018,
    topic: 'The neighbour',
    keywords: 'neighbor neighbour jibril right',
    preview: 'Jibril kept advising me about the neighbour until I thought he would inherit.',
  ),
  _h(
    slug: 'bukhari',
    number: 6312,
    topic: 'Waking',
    keywords: 'morning sleep praise life',
    preview: 'Praise is for Allah who gave us life after causing us to die.',
  ),
  _h(
    slug: 'tirmidhi',
    number: 1987,
    topic: 'Gentleness',
    keywords: 'rifq kind gentle harsh',
    preview: 'Allah is gentle and loves gentleness.',
  ),
  _h(
    slug: 'muslim',
    number: 2592,
    topic: 'Gentleness',
    keywords: 'rifq kind gentle harsh',
    preview: 'Gentleness is not in a thing except that it adorns it.',
  ),
  _h(
    slug: 'bukhari',
    number: 1427,
    topic: 'Charity and the upper hand',
    keywords: 'sadaqah spend give poor',
    preview: 'The upper hand is better than the lower hand.',
  ),
  _h(
    slug: 'nasai',
    number: 4998,
    topic: 'Who is the Muslim',
    keywords: 'tongue hand muhajir',
    preview: 'The Muslim is the one from whose tongue and hand the Muslims are safe.',
  ),
];

List<BringHadithIndexItem> filterBringHadithIndex(
  String query, {
  int limit = kBringHadithSearchLimit,
}) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.length < kBringHadithSearchMinChars) return const [];
  final tokens = [
    for (final part in trimmed.split(RegExp(r'\s+')))
      if (part.length >= 2) part,
  ];
  if (tokens.isEmpty) return const [];
  final hits = <BringHadithIndexItem>[];
  final seen = <String>{};
  for (final item in kBringHadithIndex) {
    if (seen.contains(item.ref.hadithKey)) continue;
    if (!tokens.every(item.searchText.contains)) continue;
    seen.add(item.ref.hadithKey);
    hits.add(item);
    if (hits.length >= limit) break;
  }
  return hits;
}
