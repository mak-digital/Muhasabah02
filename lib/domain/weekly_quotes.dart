import 'quotation_cadence.dart';

enum QuoteDomain { salah, quran, family, charity, fasting, hadith }

extension QuoteDomainX on QuoteDomain {
  String get label => switch (this) {
    QuoteDomain.salah => 'Salah',
    QuoteDomain.quran => 'Qur’an',
    QuoteDomain.family => 'Family',
    QuoteDomain.charity => 'Charity',
    QuoteDomain.fasting => 'Fasting',
    QuoteDomain.hadith => 'Hadith',
  };
}

class ReflectionQuote {
  const ReflectionQuote({
    required this.domain,
    required this.text,
    required this.source,
    required this.sourceDetail,
  });

  final QuoteDomain domain;
  final String text;
  final String source;
  final String sourceDetail;
}

const kReflectionQuotes = <ReflectionQuote>[
  ReflectionQuote(
    domain: QuoteDomain.salah,
    text:
        'Establish prayer. Indeed, prayer prohibits immorality and wrongdoing.',
    source: 'Qur’an 29:45',
    sourceDetail: 'Sūrat al-ʿAnkabūt, verse 45. Citation only — not a score.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.salah,
    text: 'Successful are the believers, those who are humble in their prayer.',
    source: 'Qur’an 23:1–2',
    sourceDetail: 'Sūrat al-Mu’minūn, verses 1–2.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.quran,
    text: 'This is the Book about which there is no doubt, a guidance.',
    source: 'Qur’an 2:2',
    sourceDetail: 'Sūrat al-Baqarah, verse 2.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.quran,
    text: 'Recite what has been revealed to you of the Book, and establish prayer.',
    source: 'Qur’an 29:45',
    sourceDetail: 'Sūrat al-ʿAnkabūt, verse 45.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.family,
    text: 'Lower to them the wing of humility out of mercy and say, “My Lord, have mercy upon them as they brought me up when I was small.”',
    source: 'Qur’an 17:24',
    sourceDetail: 'Sūrat al-Isrā’, verse 24.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.family,
    text:
        'Worship Allah and associate nothing with Him, and be good to parents.',
    source: 'Qur’an 4:36',
    sourceDetail: 'Sūrat al-Nisā’, verse 36.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.charity,
    text: 'Those who spend their wealth by night and by day, secretly and publicly — they will have their reward with their Lord.',
    source: 'Qur’an 2:274',
    sourceDetail: 'Sūrat al-Baqarah, verse 274.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.charity,
    text: 'Never will you attain the good until you spend from that which you love.',
    source: 'Qur’an 3:92',
    sourceDetail: 'Sūrat Āl ʿImrān, verse 92.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.fasting,
    text: 'O you who believe, fasting is prescribed for you as it was prescribed for those before you, that you may become mindful.',
    source: 'Qur’an 2:183',
    sourceDetail: 'Sūrat al-Baqarah, verse 183.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.fasting,
    text: 'Allah intends for you ease and does not intend for you hardship.',
    source: 'Qur’an 2:185',
    sourceDetail: 'Sūrat al-Baqarah, verse 185.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.hadith,
    text: 'The Messenger of Allah ﷺ said: “The most beloved of deeds to Allah are those that are most consistent, even if they are small.”',
    source: 'Ṣaḥīḥ al-Bukhārī 6464; Ṣaḥīḥ Muslim 783',
    sourceDetail: 'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim. Shown by calendar rotation, not by your records.',
  ),
  ReflectionQuote(
    domain: QuoteDomain.hadith,
    text: 'The Prophet ﷺ said: “None of you believes until he loves for his brother what he loves for himself.”',
    source: 'Ṣaḥīḥ al-Bukhārī 13; Ṣaḥīḥ Muslim 45',
    sourceDetail: 'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
  ),
];

int _utcDayBucket(DateTime date) {
  final utc = DateTime.utc(date.year, date.month, date.day);
  return utc.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

ReflectionQuote? quoteFor({
  required DateTime now,
  required QuotationCadence cadence,
}) {
  if (cadence == QuotationCadence.hidden) return null;
  final day = _utcDayBucket(now);
  final bucket = cadence == QuotationCadence.daily ? day : day ~/ 7;
  final domains = QuoteDomain.values;
  final domain = domains[bucket % domains.length];
  final pool = [
    for (final quote in kReflectionQuotes)
      if (quote.domain == domain) quote,
  ];
  if (pool.isEmpty) return kReflectionQuotes[bucket % kReflectionQuotes.length];
  return pool[bucket % pool.length];
}
