import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kFastingGroupVoluntary = 'Voluntary and make-up';

const kPracticeFastingGroups = [kFastingGroupVoluntary];

/// Qur’an and authentic hadith that encourage Fasting Home rows.
/// Noticing of voluntary and make-up fasts — not a Ramadan score or a prescription.
final List<PracticeDhikrItem> kPracticeFastingCatalog = [
  _item(
    id: 'fs.voluntary.sunnah',
    group: kFastingGroupVoluntary,
    topic: 'Weekly Sunnah Fast',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'تُعْرَضُ الْأَعْمَالُ يَوْمَ الِاثْنَيْنِ وَالْخَمِيسِ، فَأُحِبُّ أَنْ يُعْرَضَ عَمَلِي وَأَنَا صَائِمٌ',
    transliteration: 'Tuʿraḍu l-aʿmālu yawma l-ithnayni wa-l-khamīs, fa-uḥibbu an yuʿraḍa ʿamalī wa-anā ṣāʾim.',
    translation: 'Deeds are presented on Monday and Thursday, so I love that my deeds are presented while I am fasting.',
    source: 'Jāmiʿ al-Tirmidhī 747',
    detail: 'A Monday or Thursday fast you noticed. Not a weekly quota. Extreme fasting outside Ramadan is not encouraged here.',
  ),
  _item(
    id: 'fs.voluntary.sunnah.2_183',
    group: kFastingGroupVoluntary,
    topic: 'Weekly Sunnah Fast',
    text: 'Fasting is prescribed for you as it was prescribed for those before you:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ',
    transliteration:
        'Yā ayyuhā lladhīna āmanū kutiba ʿalaykumu ṣ-ṣiyāmu kamā kutiba ʿalā lladhīna min qablikum.',
    translation:
        'O you who believe, fasting is prescribed for you as it was prescribed for those before you.',
    source: 'Qur’an 2:183',
    detail: 'A Monday or Thursday fast you noticed. The fard of Ramadan is not graded here.',
  ),
  _item(
    id: 'fs.voluntary.sunnah.bukhari_1926',
    group: kFastingGroupVoluntary,
    topic: 'Weekly Sunnah Fast',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'أَحَبُّ الصِّيَامِ إِلَى اللَّهِ صِيَامُ دَاوُدَ، كَانَ يَصُومُ يَوْمًا وَيُفْطِرُ يَوْمًا',
    transliteration:
        'Aḥabbu ṣ-ṣiyāmi ilā llāhi ṣiyāmu Dāwūd, kāna yaṣūmu yawman wa-yufṭiru yawmā.',
    translation:
        'The most beloved fasting to Allah is the fasting of Dawud: he would fast a day and break a day.',
    source: 'Ṣaḥīḥ al-Bukhārī 3420',
    detail: 'A weekly sunnah fast you noticed. Extreme fasting outside Ramadan is not encouraged here.',
  ),
  _item(
    id: 'fs.voluntary.sunnah.2_184',
    group: kFastingGroupVoluntary,
    topic: 'Weekly Sunnah Fast',
    text: 'And that you fast is better for you, if you only knew:',
    arabic: 'وَأَن تَصُومُوا خَيْرٌ لَّكُمْ ۖ إِن كُنتُمْ تَعْلَمُونَ',
    transliteration: 'Wa-an taṣūmū khayrun lakum in kuntum taʿlamūn.',
    translation: 'And that you fast is better for you, if you only knew.',
    source: 'Qur’an 2:184',
    detail: 'A Monday or Thursday fast you noticed. Not a weekly quota.',
  ),
  _item(
    id: 'fs.voluntary.white',
    group: kFastingGroupVoluntary,
    topic: 'White Days (Ayyam Al-Bid)',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'إِذَا صُمْتَ مِنَ الشَّهْرِ ثَلَاثًا فَصُمْ ثَلَاثَ عَشْرَةَ وَأَرْبَعَ عَشْرَةَ وَخَمْسَ عَشْرَةَ',
    transliteration: 'Idhā ṣumta mina sh-shahri thalāthan fa-ṣum thalātha ʿashrata wa-arbaʿa ʿashrata wa-khamsa ʿashrah.',
    translation: 'If you fast three days of the month, then fast the thirteenth, fourteenth, and fifteenth.',
    source: 'Sunan Abī Dāwūd 2449',
    detail: 'White Days you noticed. Progress highlighting 13–15 is orientation only. It does not record a fast or tell you to fast.',
  ),
  _item(
    id: 'fs.voluntary.white.tirmidhi_761',
    group: kFastingGroupVoluntary,
    topic: 'White Days (Ayyam Al-Bid)',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'صَوْمُ ثَلَاثَةِ أَيَّامٍ مِنْ كُلِّ شَهْرٍ صَوْمُ الدَّهْرِ كُلِّهِ',
    transliteration:
        'Ṣawmu thalāthati ayyāmin min kulli shahrin ṣawmu d-dahri kullih.',
    translation: 'Fasting three days of every month is fasting for a lifetime.',
    source: 'Ṣaḥīḥ al-Bukhārī 1979',
    detail: 'White Days you noticed. Progress highlighting 13–15 is orientation only.',
  ),
  _item(
    id: 'fs.voluntary.white.muslim_1160',
    group: kFastingGroupVoluntary,
    topic: 'White Days (Ayyam Al-Bid)',
    text: 'The Messenger of Allah ﷺ advised fasting three days of the month:',
    arabic: 'أَوْصَانِي خَلِيلِي ﷺ بِثَلَاثٍ: صِيَامِ ثَلَاثَةِ أَيَّامٍ مِنْ كُلِّ شَهْرٍ',
    transliteration:
        'Awṣānī khalīlī bi-thalāth: ṣiyāmi thalāthati ayyāmin min kulli shahr.',
    translation:
        'My close friend ﷺ advised me with three: fasting three days of every month.',
    source: 'Ṣaḥīḥ al-Bukhārī 1981',
    detail: 'White Days you noticed. It does not record a fast or tell you to fast.',
  ),
  _item(
    id: 'fs.voluntary.white.2_185',
    group: kFastingGroupVoluntary,
    topic: 'White Days (Ayyam Al-Bid)',
    text: 'Allah intends ease, not hardship:',
    arabic: 'يُرِيدُ اللَّهُ بِكُمُ الْيُسْرَ وَلَا يُرِيدُ بِكُمُ الْعُسْرَ',
    transliteration: 'Yurīdu llāhu bikumu l-yusra wa-lā yurīdu bikumu l-ʿusr.',
    translation: 'Allah intends for you ease and does not intend for you hardship.',
    source: 'Qur’an 2:185',
    detail: 'White Days you noticed. Illness and travel are not failings.',
  ),
  _item(
    id: 'fs.voluntary.makeup',
    group: kFastingGroupVoluntary,
    topic: 'Make-up Fast',
    text: 'If one of you is ill or on a journey:',
    arabic: 'فَمَن كَانَ مِنكُم مَّرِيضًا أَوْ عَلَىٰ سَفَرٍ فَعِدَّةٌ مِّنْ أَيَّامٍ أُخَرَ',
    transliteration: 'Fa-man kāna minkum marīḍan aw ʿalā safarin fa-ʿiddatun min ayyāmin ukhar.',
    translation: 'But if any of you is ill or on a journey, then an equal number of other days.',
    source: 'Qur’an 2:184',
    detail: 'A make-up you noticed. Illness and travel are not failings. This is not a debt score.',
  ),
  _item(
    id: 'fs.voluntary.makeup.2_185',
    group: kFastingGroupVoluntary,
    topic: 'Make-up Fast',
    text: 'Whoever is ill or on a journey, then an equal number of other days:',
    arabic:
        'وَمَن كَانَ مَرِيضًا أَوْ عَلَىٰ سَفَرٍ فَعِدَّةٌ مِّنْ أَيَّامٍ أُخَرَ',
    transliteration:
        'Wa-man kāna marīḍan aw ʿalā safarin fa-ʿiddatun min ayyāmin ukhar.',
    translation:
        'And whoever is ill or on a journey — then an equal number of other days.',
    source: 'Qur’an 2:185',
    detail: 'A make-up you noticed. Illness and travel are not failings.',
  ),
  _item(
    id: 'fs.voluntary.makeup.2_184b',
    group: kFastingGroupVoluntary,
    topic: 'Make-up Fast',
    text: 'For those who can bear it, a ransom of feeding a needy person:',
    arabic: 'وَعَلَى الَّذِينَ يُطِيقُونَهُ فِدْيَةٌ طَعَامُ مِسْكِينٍ',
    transliteration: 'Wa-ʿalā lladhīna yuṭīqūnahu fidyatun ṭaʿāmu miskīn.',
    translation:
        'And upon those who can bear it, a ransom of feeding a needy person.',
    source: 'Qur’an 2:184',
    detail: 'A make-up you noticed. This is not a debt score or a fidyah calculator.',
  ),
  _item(
    id: 'fs.voluntary.makeup.bukhari_1950',
    group: kFastingGroupVoluntary,
    topic: 'Make-up Fast',
    text: 'Aisha, may Allah be pleased with her, said she would make up missed fasts in Sha‘ban.',
    arabic: 'كَانَ يَكُونُ عَلَيَّ الصَّوْمُ مِنْ رَمَضَانَ فَمَا أَسْتَطِيعُ أَنْ أَقْضِيَهُ إِلَّا فِي شَعْبَانَ',
    transliteration:
        'Kāna yakūnu ʿalayya ṣ-ṣawmu min Ramaḍāna fa-mā astaṭīʿu an aqḍiyahu illā fī Shaʿbān.',
    translation:
        'I would have fasts due from Ramadan, and I would not be able to make them up except in Sha‘ban.',
    source: 'Ṣaḥīḥ al-Bukhārī 1950',
    detail: 'A make-up you noticed. Illness and travel are not failings.',
  ),
  _item(
    id: 'fs.voluntary.ramadan',
    group: kFastingGroupVoluntary,
    topic: 'Ramadan Preparation',
    text: 'Allah intends ease, not hardship:',
    arabic: 'يُرِيدُ اللَّهُ بِكُمُ الْيُسْرَ وَلَا يُرِيدُ بِكُمُ الْعُسْرَ',
    transliteration: 'Yurīdu llāhu bikumu l-yusra wa-lā yurīdu bikumu l-ʿusr.',
    translation:
        'Allah intends for you ease and does not intend for you hardship.',
    source: 'Qur’an 2:185',
    detail: 'Preparation you noticed. Not a countdown, and not a Ramadan fard tracker. Unanswered is not a missed fast.',
  ),
  _item(
    id: 'fs.voluntary.ramadan.2_183',
    group: kFastingGroupVoluntary,
    topic: 'Ramadan Preparation',
    text: 'Fasting is prescribed for you:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ',
    transliteration: 'Yā ayyuhā lladhīna āmanū kutiba ʿalaykumu ṣ-ṣiyām.',
    translation: 'O you who believe, fasting is prescribed for you.',
    source: 'Qur’an 2:183',
    detail: 'Preparation you noticed. Not a countdown. Unanswered is not a missed fast.',
  ),
  _item(
    id: 'fs.voluntary.ramadan.bukhari_1898',
    group: kFastingGroupVoluntary,
    topic: 'Ramadan Preparation',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'إِذَا دَخَلَ رَمَضَانُ فُتِّحَتْ أَبْوَابُ الْجَنَّةِ',
    transliteration: 'Idhā dakhala Ramaḍānu futtiḥat abwābu l-jannah.',
    translation: 'When Ramadan enters, the gates of Paradise are opened.',
    source: 'Ṣaḥīḥ al-Bukhārī 1898',
    detail: 'Preparation you noticed. Not a Ramadan fard tracker.',
  ),
  _item(
    id: 'fs.voluntary.ramadan.2_186',
    group: kFastingGroupVoluntary,
    topic: 'Ramadan Preparation',
    text: 'When My servants ask you about Me, I am near:',
    arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
    transliteration: 'Wa-idhā saʾalaka ʿibādī ʿannī fa-innī qarīb.',
    translation: 'And when My servants ask you about Me, indeed I am near.',
    source: 'Qur’an 2:186',
    detail: 'Preparation you noticed. Not a countdown.',
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

PracticeHadithRecord recordFromFastingCatalog({
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
    domain: MonitorDomain.fasting,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
