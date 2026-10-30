import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kAkhlaqGroupVirtues = 'Virtues I noticed';
const kAkhlaqGroupAnger = 'Anger, honesty, forgiveness';
const kAkhlaqGroupModesty = 'Modesty';
const kAkhlaqGroupRestraint = 'Restraint';

const kPracticeAkhlaqGroups = [
  kAkhlaqGroupVirtues,
  kAkhlaqGroupAnger,
  kAkhlaqGroupModesty,
  kAkhlaqGroupRestraint,
];

/// Qur’an and authentic hadith that encourage the Akhlaq rows.
/// Grouped like Home. Not a character grade or prescription.
final List<PracticeDhikrItem> _kPracticeAkhlaqCore = [
  _item(
    id: 'ak.virtue.patience',
    group: kAkhlaqGroupVirtues,
    topic: 'Patience',
    text: 'When difficulty meets you:',
    arabic:
        'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
    transliteration: 'Yā ayyuhā lladhīna āmanū staʿīnū biṣ-ṣabri waṣ-ṣalāh.',
    translation: 'O you who believe, seek help through patience and prayer.',
    source: 'Qur’an 2:153',
    detail: 'Patience on the virtues row. Not a character score.',
  ),
  _item(
    id: 'ak.virtue.humility',
    group: kAkhlaqGroupVirtues,
    topic: 'Humility',
    text: 'The servants of the Most Merciful:',
    arabic:
        'وَعِبَادُ الرَّحْمَٰنِ الَّذِينَ يَمْشُونَ عَلَى الْأَرْضِ هَوْنًا',
    transliteration: 'Wa ʿibādu r-raḥmāni lladhīna yamshūna ʿalā l-arḍi hawnā.',
    translation: 'The servants of the Most Merciful are those who walk upon the earth in humility.',
    source: 'Qur’an 25:63',
    detail: 'Humility. Not a personality grade.',
  ),
  _item(
    id: 'ak.virtue.truth',
    group: kAkhlaqGroupVirtues,
    topic: 'Truthfulness',
    text: 'The Prophet ﷺ said:',
    arabic: 'عَلَيْكُمْ بِالصِّدْقِ، فَإِنَّ الصِّدْقَ يَهْدِي إِلَى الْبِرِّ',
    transliteration: 'ʿAlaykum biṣ-ṣidq, fa-inna ṣ-ṣidqa yahdī ilā l-birr.',
    translation:
        'Hold to truthfulness, for truthfulness leads to righteousness.',
    source: 'Ṣaḥīḥ al-Bukhārī 6094; Ṣaḥīḥ Muslim 2607',
    detail: 'Truthfulness. Not a honesty score.',
  ),
  _item(
    id: 'ak.virtue.gentleness',
    group: kAkhlaqGroupVirtues,
    topic: 'Gentleness',
    text: 'The Prophet ﷺ said to ʿĀʾishah:',
    arabic: 'إِنَّ اللَّهَ رَفِيقٌ يُحِبُّ الرِّفْقَ فِي الْأَمْرِ كُلِّهِ',
    transliteration: 'Inna Allāha rafīqun yuḥibbu r-rifqa fī l-amri kullih.',
    translation: 'Allah is Gentle and loves gentleness in all things.',
    source: 'Ṣaḥīḥ al-Bukhārī 6927; Ṣaḥīḥ Muslim 2165',
    detail: 'Gentleness. Not a temperament badge.',
  ),
  _item(
    id: 'ak.virtue.courage',
    group: kAkhlaqGroupVirtues,
    topic: 'Courage',
    text: 'Do not weaken after a setback:',
    arabic: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
    transliteration:
        'Wa lā tahinū wa lā taḥzanū wa antumu l-aʿlawna in kuntum muʾminīn.',
    translation: 'Do not weaken and do not grieve, and you will be superior if you are believers.',
    source: 'Qur’an 3:139',
    detail: 'Courage. Not bravado.',
  ),
  _item(
    id: 'ak.virtue.thanks',
    group: kAkhlaqGroupVirtues,
    topic: 'Thankfulness in how I acted',
    text: 'Gratitude is answered with increase:',
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
    transliteration: 'La-in shakartum la-azīdannakum, wa la-in kafartum inna ʿadhābī la-shadīd.',
    translation: 'If you are grateful, I will surely increase you; but if you deny, My punishment is severe.',
    source: 'Qur’an 14:7',
    detail: 'Thankfulness in action, not Gratitude Dhikr.',
  ),
  _item(
    id: 'ak.virtue.contentment',
    group: kAkhlaqGroupVirtues,
    topic: 'Contentment',
    text: 'The Prophet ﷺ said:',
    arabic: 'قَدْ أَفْلَحَ مَنْ أَسْلَمَ وَرُزِقَ كَفَافًا وَقَنَّعَهُ اللَّهُ بِمَا آتَاهُ',
    transliteration: 'Qad aflaḥa man aslama wa ruziqa kafāfan wa qannaʿahu Allāhu bimā ātāh.',
    translation: 'Successful is the one who enters Islam, is given enough provision, and Allah makes him content with what He has given.',
    source: 'Ṣaḥīḥ Muslim 1054',
    detail: 'Contentment. Not a wealth grade.',
  ),
  _item(
    id: 'ak.anger.pause',
    group: kAkhlaqGroupAnger,
    topic: 'Paused before reacting',
    text: 'The Prophet ﷺ said:',
    arabic: 'إِذَا غَضِبَ أَحَدُكُمْ وَهُوَ قَائِمٌ فَلْيَجْلِسْ، فَإِنْ ذَهَبَ عَنْهُ الْغَضَبُ وَإِلَّا فَلْيَضْطَجِعْ',
    transliteration: 'Idhā ghaḍiba aḥadukum wa huwa qāʾimun fal-yajlis, fa-in dhahaba ʿanhu l-ghaḍabu wa illā fal-yaḍṭajiʿ.',
    translation: 'If one of you becomes angry while standing, let him sit. If the anger leaves him, so; otherwise let him lie down.',
    source: 'Sunan Abī Dāwūd 4782',
    detail: 'Pause before reacting. Unanswered is not a failing.',
  ),
  _item(
    id: 'ak.anger.strong',
    group: kAkhlaqGroupAnger,
    topic: 'The strong one',
    text: 'The Prophet ﷺ said:',
    arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
    transliteration: 'Laysa sh-shadīdu biṣ-ṣuraʿah, innamā sh-shadīdu alladhī yamliku nafsahu ʿinda l-ghaḍab.',
    translation: 'The strong person is not the one who throws others down. The strong person is the one who controls himself when angry.',
    source: 'Ṣaḥīḥ al-Bukhārī 6114; Ṣaḥīḥ Muslim 2609',
    detail: 'Strength here is self-restraint, not a fight score.',
  ),
  _item(
    id: 'ak.anger.honesty',
    group: kAkhlaqGroupAnger,
    topic: 'Honesty in small matters',
    text: 'Stand with truth even against yourselves:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُونُوا قَوَّامِينَ بِالْقِسْطِ شُهَدَاءَ لِلَّهِ وَلَوْ عَلَىٰ أَنفُسِكُمْ',
    transliteration: 'Yā ayyuhā lladhīna āmanū kūnū qawwāmīna bi-l-qisṭi shuhadāʾa lillāhi wa law ʿalā anfusikum.',
    translation: 'O you who believe, be persistently standing firm in justice, witnesses for Allah, even if against yourselves.',
    source: 'Qur’an 4:135',
    detail: 'Honesty in small matters. Not a purity test.',
  ),
  _item(
    id: 'ak.anger.forgive',
    group: kAkhlaqGroupAnger,
    topic: 'Let go of a grudge',
    text: 'Those who restrain anger and pardon people:',
    arabic: 'وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ',
    transliteration: 'Wa-l-kāẓimīna l-ghayẓa wa-l-ʿāfīna ʿani n-nās, wa Allāhu yuḥibbu l-muḥsinīn.',
    translation: 'Who restrain anger and pardon people — and Allah loves those who do good.',
    source: 'Qur’an 3:134',
    detail: 'Forgiveness is optional noticing, not a required rite.',
  ),
  _item(
    id: 'ak.modesty.speech',
    group: kAkhlaqGroupModesty,
    topic: 'Guarded how I spoke (tone)',
    text: 'Tell My servants to say that which is best:',
    arabic: 'وَقُل لِّعِبَادِي يَقُولُوا الَّتِي هِيَ أَحْسَنُ',
    transliteration: 'Wa qul li-ʿibādī yaqūlū allatī hiya aḥsan.',
    translation: 'Tell My servants to say that which is best.',
    source: 'Qur’an 17:53',
    detail: 'Tone, not Knowledge’s usefulness of speech.',
  ),
  _item(
    id: 'ak.modesty.haya',
    group: kAkhlaqGroupModesty,
    topic: 'Modesty is part of faith',
    text: 'The Prophet ﷺ said:',
    arabic: 'الْحَيَاءُ شُعْبَةٌ مِنَ الْإِيمَانِ',
    transliteration: 'Al-ḥayāʾu shuʿbatun mina l-īmān.',
    translation: 'Modesty is a branch of faith.',
    source: 'Ṣaḥīḥ al-Bukhārī 9; Ṣaḥīḥ Muslim 35',
    detail: 'Ḥayāʾ. Not a dress-code score.',
  ),
  _item(
    id: 'ak.modesty.dress',
    group: kAkhlaqGroupModesty,
    topic: 'Modest dress',
    text: 'The garment of taqwa:',
    arabic: 'يَا بَنِي آدَمَ قَدْ أَنزَلْنَا عَلَيْكُمْ لِبَاسًا يُوَارِي سَوْآتِكُمْ وَرِيشًا ۖ وَلِبَاسُ التَّقْوَىٰ ذَٰلِكَ خَيْرٌ',
    transliteration: 'Yā banī Ādama qad anzalnā ʿalaykum libāsan yuwārī sawʾātikum wa rīshā, wa libāsu t-taqwā dhālika khayr.',
    translation: 'O children of Adam, We have sent down to you clothing to cover your shame and as adornment. And the clothing of taqwa — that is better.',
    source: 'Qur’an 7:26',
    detail: 'Modest dress. Not a fashion ruling in this app.',
  ),
  _item(
    id: 'ak.modesty.gaze',
    group: kAkhlaqGroupModesty,
    topic: 'Guarded my gaze',
    text: 'Tell the believing men to lower their gaze:',
    arabic: 'قُل لِّلْمُؤْمِنِينَ يَغُضُّوا مِنْ أَبْصَارِهِمْ',
    transliteration: 'Qul li-l-muʾminīna yaghuḍḍū min abṣārihim.',
    translation: 'Tell the believing men to lower their gaze.',
    source: 'Qur’an 24:30',
    detail: 'Gaze. Unanswered is not a failing.',
  ),
  _item(
    id: 'ak.restrain.walk',
    group: kAkhlaqGroupRestraint,
    topic: 'Walked away from an argument',
    text: 'When the ignorant address them:',
    arabic: 'وَإِذَا خَاطَبَهُمُ الْجَاهِلُونَ قَالُوا سَلَامًا',
    transliteration: 'Wa idhā khāṭabahumu l-jāhilūna qālū salāmā.',
    translation: 'And when the ignorant address them, they say: Peace.',
    source: 'Qur’an 25:63',
    detail: 'Walking away. Not weakness.',
  ),
  _item(
    id: 'ak.restrain.repel',
    group: kAkhlaqGroupRestraint,
    topic: 'Repel with what is better',
    text: 'Good and evil are not equal:',
    arabic: 'وَلَا تَسْتَوِي الْحَسَنَةُ وَلَا السَّيِّئَةُ ۚ ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ',
    transliteration:
        'Wa lā tastawī l-ḥasanatu wa lā s-sayyiʾah. Idfaʿ bi-llatī hiya aḥsan.',
    translation:
        'Good and evil are not equal. Repel with that which is better.',
    source: 'Qur’an 41:34',
    detail: 'Restraint in conflict. Patience is not required in abuse.',
  ),
  _item(
    id: 'ak.restrain.habit',
    group: kAkhlaqGroupRestraint,
    topic: 'Held back from a habit I am trying to leave',
    text: 'Whoever fears the standing before his Lord:',
    arabic: 'وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِ وَنَهَى النَّفْسَ عَنِ الْهَوَىٰ فَإِنَّ الْجَنَّةَ هِيَ الْمَأْوَىٰ',
    transliteration: 'Wa ammā man khāfa maqāma rabbihi wa nahā n-nafsa ʿani l-hawā, fa-inna l-jannata hiya l-maʾwā.',
    translation: 'But as for the one who feared the standing before his Lord and restrained the soul from desire, Paradise will be the home.',
    source: 'Qur’an 79:40–41',
    detail: 'Held-back habit. Unanswered is not a relapse.',
  ),
  _item(
    id: 'ak.restrain.leave',
    group: kAkhlaqGroupRestraint,
    topic: 'Leave what does not concern you',
    text: 'The Prophet ﷺ said:',
    arabic: 'مِنْ حُسْنِ إِسْلَامِ الْمَرْءِ تَرْكُهُ مَا لَا يَعْنِيهِ',
    transliteration: 'Min ḥusni islāmi l-marʾi tarkuhu mā lā yaʿnīh.',
    translation: 'Part of the excellence of a person’s Islam is leaving what does not concern him.',
    source: 'Jāmiʿ al-Tirmidhī 2317',
    detail: 'Restraint of curiosity and argument. Not a silence order.',
  ),
];

final List<PracticeDhikrItem> kPracticeAkhlaqCatalog = [
  for (final item in _kPracticeAkhlaqCore) ..._akhlaqWithSupports(item),
];

List<PracticeDhikrItem> _akhlaqWithSupports(PracticeDhikrItem item) {
  return [
    item,
    _item(
      id: '${item.id}.68_4',
      group: item.group,
      topic: item.topic,
      text: 'You are on an exalted standard of character:',
      arabic: 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ',
      transliteration: 'Wa-innaka la-ʿalā khuluqin ʿaẓīm.',
      translation: 'And indeed, you are of a great moral character.',
      source: 'Qur’an 68:4',
      detail: item.sourceDetail,
    ),
    _item(
      id: '${item.id}.33_21',
      group: item.group,
      topic: item.topic,
      text: 'You have in the Messenger of Allah a beautiful example:',
      arabic: 'لَّقَدْ كَانَ لَكُمْ فِي رَسُولِ اللَّهِ أُسْوَةٌ حَسَنَةٌ',
      transliteration: 'La-qad kāna lakum fī rasūli llāhi uswatun ḥasanah.',
      translation: 'There has certainly been for you in the Messenger of Allah a beautiful example.',
      source: 'Qur’an 33:21',
      detail: item.sourceDetail,
    ),
  ];
}

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

PracticeHadithRecord recordFromAkhlaqCatalog({
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
    domain: MonitorDomain.akhlaq,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
