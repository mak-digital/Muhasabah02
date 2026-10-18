import 'home_traces.dart';
import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kPracticeHajjGroups = [
  kHajjLearnBand,
  kHajjReadinessBand,
  kHajjAfterBand,
];

/// Educational catalog, always available. Not gated by standing or journey.
final List<PracticeDhikrItem> kPracticeHajjCatalog = [
  _item(
    id: 'hj.prep.noticed',
    group: kHajjLearnBand,
    topic: 'Standing',
    text: 'Pilgrimage is a duty for those who are able:',
    arabic: 'وَلِلَّهِ عَلَى النَّاسِ حِجُّ الْبَيْتِ مَنِ اسْتَطَاعَ إِلَيْهِ سَبِيلًا',
    transliteration:
        'Wa-li-llāhi ʿalā n-nāsi ḥijju l-bayti mani staṭāʿa ilayhi sabīlā.',
    translation: 'Pilgrimage to the House is a duty owed to Allah by people who are able to undertake it.',
    source: 'Qur’an 3:97',
    detail: 'Learn at any time. The app does not calculate whether Hajj is obligatory, does not set a year, and does not treat unanswered as missed. Umrah is not this standing. Performed is a record, not a trophy.',
  ),
  _item(
    id: 'hj.prep.noticed.2_196',
    group: kHajjLearnBand,
    topic: 'Completing',
    text: 'Complete the Hajj and the Umrah for Allah:',
    arabic: 'وَأَتِمُّوا الْحَجَّ وَالْعُمْرَةَ لِلَّهِ',
    transliteration: 'Wa-atimmū l-ḥajja wa-l-ʿumrata li-llāh.',
    translation: 'And complete the Hajj and the Umrah for Allah.',
    source: 'Qur’an 2:196',
    detail: 'Learn at any time. Umrah is not this standing. The app does not set a year.',
  ),
  _item(
    id: 'hj.prep.noticed.2_197',
    group: kHajjReadinessBand,
    topic: 'Known months',
    text: 'Hajj is in well-known months:',
    arabic: 'الْحَجُّ أَشْهُرٌ مَّعْلُومَاتٌ',
    transliteration: 'Al-ḥajju ashhurun maʿlūmāt.',
    translation: 'Hajj is in well-known months.',
    source: 'Qur’an 2:197',
    detail: 'Readiness is a checklist on a journey you choose, not a daily score. The app does not calculate whether Hajj is obligatory.',
  ),
  _item(
    id: 'hj.prep.noticed.bukhari_1513',
    group: kHajjAfterBand,
    topic: 'After Hajj',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَنْ حَجَّ فَلَمْ يَرْفُثْ وَلَمْ يَفْسُقْ رَجَعَ كَيَوْمِ وَلَدَتْهُ أُمُّهُ',
    transliteration: 'Man ḥajja fa-lam yarfuth wa-lam yafsuq rajaʿa ka-yawmi waladathu ummuh.',
    translation: 'Whoever performs Hajj and does not engage in sexual talk or sin returns like the day his mother bore him.',
    source: 'Ṣaḥīḥ al-Bukhārī 1521',
    detail: 'Optional after-Hajj reflection and continuing practice. Performed is a record, not a trophy. Unanswered is not missed Hajj.',
  ),
];

PracticeDhikrItem _item({
  required String id,
  required String group,
  required String topic,
  required String text,
  required String arabic,
  required String transliteration,
  required String translation,
  required String source,
  required String detail,
}) {
  return PracticeDhikrItem(
    id: id,
    group: group,
    subgroup: kDhikrSubHighly,
    topic: topic,
    text: text,
    arabic: arabic,
    transliteration: transliteration,
    translation: translation,
    source: source,
    sourceDetail: detail,
  );
}

PracticeHadithRecord recordFromHajjCatalog({
  required PracticeDhikrItem item,
  required String id,
  required String addedDateKey,
}) {
  return PracticeHadithRecord(
    id: id,
    catalogId: item.id,
    addedDateKey: addedDateKey,
    topic: item.topic,
    content: item.text,
    source: item.source,
    arabic: item.arabic,
    transliteration: item.transliteration,
    translation: item.translation,
    domain: MonitorDomain.hajj,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
