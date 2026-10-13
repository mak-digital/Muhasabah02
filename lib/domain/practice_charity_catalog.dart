import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kCharityGroupGiving = 'Giving';
const kCharityGroupCare = 'Care';

const kPracticeCharityGroups = [kCharityGroupGiving, kCharityGroupCare];

/// Qur’an and authentic hadith that encourage Charity Home rows.
/// Giving and care as you noticed them — not amounts, a leaderboard, or zakat math.
final List<PracticeDhikrItem> kPracticeCharityCatalog = [
  _item(
    id: 'ch.giving.voluntary',
    group: kCharityGroupGiving,
    topic: 'Voluntary Charity',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
    transliteration: 'Tabassumuka fī wajhi akhīka laka ṣadaqah.',
    translation: 'Your smile in the face of your brother is a sadaqah for you.',
    source: 'Jāmiʿ al-Tirmidhī 1956',
    detail: 'A smile is sadaqah. Amounts are not recorded. Poverty is not a failing. This is not a most-generous badge.',
  ),
  _item(
    id: 'ch.giving.voluntary.2_261',
    group: kCharityGroupGiving,
    topic: 'Voluntary Charity',
    text: 'The example of those who spend their wealth in Allah’s way:',
    arabic:
        'مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ',
    transliteration:
        'Mathalu lladhīna yunfiqūna amwālahum fī sabīli llāhi ka-mathali ḥabbatin anbatat sabʿa sanābil.',
    translation:
        'The example of those who spend their wealth in the way of Allah is that of a grain that sprouts seven ears.',
    source: 'Qur’an 2:261',
    detail: 'Voluntary giving you noticed. Amounts are not recorded. Not a most-generous badge.',
  ),
  _item(
    id: 'ch.giving.voluntary.2_274',
    group: kCharityGroupGiving,
    topic: 'Voluntary Charity',
    text: 'Those who spend by night and by day:',
    arabic: 'الَّذِينَ يُنفِقُونَ أَمْوَالَهُم بِاللَّيْلِ وَالنَّهَارِ سِرًّا وَعَلَانِيَةً',
    transliteration:
        'Alladhīna yunfiqūna amwālahum bi-l-layli wa-n-nahāri sirran wa-ʿalāniyah.',
    translation:
        'Those who spend their wealth by night and by day, secretly and publicly.',
    source: 'Qur’an 2:274',
    detail: 'A gift you noticed. Poverty is not a failing. There is no leaderboard.',
  ),
  _item(
    id: 'ch.giving.voluntary.bukhari_1410',
    group: kCharityGroupGiving,
    topic: 'Voluntary Charity',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ',
    transliteration: 'Mā naqaṣat ṣadaqatun min māl.',
    translation: 'Charity does not decrease wealth.',
    source: 'Ṣaḥīḥ Muslim 2588',
    detail: 'A smile or a gift you noticed. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.giving.family',
    group: kCharityGroupGiving,
    topic: 'Family Support',
    text: 'They ask you what they should spend:',
    arabic: 'يَسْأَلُونَكَ مَاذَا يُنفِقُونَ قُلْ مَا أَنفَقْتُم مِّنْ خَيْرٍ فَلِلْوَالِدَيْنِ وَالْأَقْرَبِينَ',
    transliteration: 'Yasʾalūnaka mādhā yunfiqūn. Qul mā anfaqtum min khayrin fa-li-l-wālidayni wa-l-aqrabīn.',
    translation: 'They ask you what they should spend. Say: whatever good you spend is for parents and relatives.',
    source: 'Qur’an 2:215',
    detail: 'A gift or extra support. Ordinary household nafaqa stays on Rights of Others. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.giving.family.2_177',
    group: kCharityGroupGiving,
    topic: 'Family Support',
    text: 'Righteousness is to give wealth, despite love of it, to relatives:',
    arabic: 'وَآتَى الْمَالَ عَلَىٰ حُبِّهِ ذَوِي الْقُرْبَىٰ وَالْيَتَامَىٰ وَالْمَسَاكِينَ',
    transliteration:
        'Wa-ātā l-māla ʿalā ḥubbihi dhawī l-qurbā wa-l-yatāmā wa-l-masākīn.',
    translation:
        'And gives wealth, despite love for it, to relatives, orphans, and the needy.',
    source: 'Qur’an 2:177',
    detail: 'A gift or extra support. Ordinary household nafaqa stays on Rights of Others.',
  ),
  _item(
    id: 'ch.giving.family.bukhari_1461',
    group: kCharityGroupGiving,
    topic: 'Family Support',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'دِينَارٌ أَنْفَقْتَهُ فِي سَبِيلِ اللَّهِ، وَدِينَارٌ أَنْفَقْتَهُ فِي رَقَبَةٍ، وَدِينَارٌ تَصَدَّقْتَ بِهِ عَلَى مِسْكِينٍ، وَدِينَارٌ أَنْفَقْتَهُ عَلَى أَهْلِكَ، أَعْظَمُهَا أَجْرًا الَّذِي أَنْفَقْتَهُ عَلَى أَهْلِكَ',
    transliteration:
        'Dīnārun anfaqtahu fī sabīli llāh, wa-dīnārun anfaqtahu fī raqabah, wa-dīnārun taṣaddaqta bihi ʿalā miskīn, wa-dīnārun anfaqtahu ʿalā ahlik — aʿẓamuhā ajran alladhī anfaqtahu ʿalā ahlik.',
    translation:
        'A dinar you spend in Allah’s way, a dinar to free a slave, a dinar you give to a needy person, and a dinar you spend on your family — the greatest in reward is the one you spend on your family.',
    source: 'Ṣaḥīḥ Muslim 995',
    detail: 'A gift or extra support. Ordinary household nafaqa stays on Rights of Others.',
  ),
  _item(
    id: 'ch.giving.family.17_26',
    group: kCharityGroupGiving,
    topic: 'Family Support',
    text: 'Give the relative his right:',
    arabic: 'وَآتِ ذَا الْقُرْبَىٰ حَقَّهُ وَالْمِسْكِينَ وَابْنَ السَّبِيلِ',
    transliteration: 'Wa-āti dhā l-qurbā ḥaqqahu wa-l-miskīna wa-bna s-sabīl.',
    translation: 'And give the relative his right, and the needy, and the traveller.',
    source: 'Qur’an 17:26',
    detail: 'A gift or extra support. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.giving.community',
    group: kCharityGroupGiving,
    topic: 'Community Support',
    text: 'They give preference over themselves:',
    arabic: 'وَيُؤْثِرُونَ عَلَىٰ أَنفُسِهِمْ وَلَوْ كَانَ بِهِمْ خَصَاصَةٌ',
    transliteration: 'Wa-yuʾthirūna ʿalā anfusihim wa-law kāna bihim khaṣāṣah.',
    translation: 'And they give preference over themselves, even though they are in need.',
    source: 'Qur’an 59:9',
    detail: 'Community giving you noticed. Not a public campaign log, and not Wealth’s earning rows.',
  ),
  _item(
    id: 'ch.giving.community.2_267',
    group: kCharityGroupGiving,
    topic: 'Community Support',
    text: 'Spend from the good things you have earned:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا أَنفِقُوا مِن طَيِّبَاتِ مَا كَسَبْتُمْ',
    transliteration:
        'Yā ayyuhā lladhīna āmanū anfiqū min ṭayyibāti mā kasabtum.',
    translation: 'O you who believe, spend from the good things you have earned.',
    source: 'Qur’an 2:267',
    detail: 'Community giving you noticed. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.giving.community.9_60',
    group: kCharityGroupGiving,
    topic: 'Community Support',
    text: 'Sadaqah is for the poor and the needy:',
    arabic: 'إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ',
    transliteration: 'Innamā ṣ-ṣadaqātu li-l-fuqarāʾi wa-l-masākīn.',
    translation: 'Sadaqah is only for the poor and the needy.',
    source: 'Qur’an 9:60',
    detail: 'Community giving you noticed. This is not a zakat calculator.',
  ),
  _item(
    id: 'ch.giving.community.bukhari_1427',
    group: kCharityGroupGiving,
    topic: 'Community Support',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'الْمُسْلِمُ أَخُو الْمُسْلِمِ، لَا يَظْلِمُهُ وَلَا يُسْلِمُهُ',
    transliteration: 'Al-muslimu akhū l-muslim, lā yaẓlimuhu wa-lā yuslimuh.',
    translation:
        'The Muslim is the brother of the Muslim. He does not wrong him or abandon him.',
    source: 'Ṣaḥīḥ al-Bukhārī 2442',
    detail: 'Community giving you noticed. Not a public campaign log.',
  ),
  _item(
    id: 'ch.care.educational',
    group: kCharityGroupCare,
    topic: 'Educational Support',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'إِذَا مَاتَ الْإِنْسَانُ انْقَطَعَ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ',
    transliteration: 'Idhā māta l-insānu inqaṭaʿa ʿamaluhu illā min thalāth: ṣadaqatin jāriyah, aw ʿilmin yuntafaʿu bih, aw waladin ṣāliḥin yadʿū lah.',
    translation: 'When a person dies, his deeds end except three: ongoing charity, beneficial knowledge, or a righteous child who prays for him.',
    source: 'Ṣaḥīḥ Muslim 1631',
    detail: 'Support for learning you noticed. Not Knowledge’s residual learning row, and not a scholarship score.',
  ),
  _item(
    id: 'ch.care.educational.2_269',
    group: kCharityGroupCare,
    topic: 'Educational Support',
    text: 'He gives wisdom to whom He wills:',
    arabic: 'يُؤْتِي الْحِكْمَةَ مَن يَشَاءُ ۚ وَمَن يُؤْتَ الْحِكْمَةَ فَقَدْ أُوتِيَ خَيْرًا كَثِيرًا',
    transliteration:
        'Yuʾtī l-ḥikmata man yashāʾ. Wa-man yuʾta l-ḥikmata fa-qad ūtiya khayran kathīrā.',
    translation:
        'He gives wisdom to whom He wills, and whoever is given wisdom has been given much good.',
    source: 'Qur’an 2:269',
    detail: 'Support for learning you noticed. Not a scholarship score.',
  ),
  _item(
    id: 'ch.care.educational.96_1',
    group: kCharityGroupCare,
    topic: 'Educational Support',
    text: 'Read in the name of your Lord:',
    arabic: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
    transliteration: 'Iqraʾ bi-smi rabbika lladhī khalaq.',
    translation: 'Read in the name of your Lord who created.',
    source: 'Qur’an 96:1',
    detail: 'Support for learning you noticed. Not Knowledge’s residual learning row.',
  ),
  _item(
    id: 'ch.care.educational.bukhari_79',
    group: kCharityGroupCare,
    topic: 'Educational Support',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    transliteration: 'Khayrukum man taʿallama l-qurʾāna wa-ʿallamah.',
    translation: 'The best of you are those who learn the Qur’an and teach it.',
    source: 'Ṣaḥīḥ al-Bukhārī 5027',
    detail: 'Support for learning you noticed. Not a recitation streak.',
  ),
  _item(
    id: 'ch.care.emergency',
    group: kCharityGroupCare,
    topic: 'Emergency Support',
    text: 'They feed the food, despite love of it:',
    arabic: 'وَيُطْعِمُونَ الطَّعَامَ عَلَىٰ حُبِّهِ مِسْكِينًا وَيَتِيمًا وَأَسِيرًا',
    transliteration:
        'Wa-yuṭʿimūna ṭ-ṭaʿāma ʿalā ḥubbihi miskīnan wa-yatīman wa-asīrā.',
    translation: 'And they give food, despite their love for it, to the needy, the orphan, and the captive.',
    source: 'Qur’an 76:8',
    detail: 'Emergency care you noticed. Illness visits stay on Rights of Others. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.care.emergency.2_177',
    group: kCharityGroupCare,
    topic: 'Emergency Support',
    text: 'And to the needy, and those who ask, and to free a slave:',
    arabic: 'وَآتَى الْمَالَ عَلَىٰ حُبِّهِ ذَوِي الْقُرْبَىٰ وَالْيَتَامَىٰ وَالْمَسَاكِينَ وَابْنَ السَّبِيلِ وَالسَّائِلِينَ وَفِي الرِّقَابِ',
    transliteration:
        'Wa-ātā l-māla ʿalā ḥubbihi dhawī l-qurbā wa-l-yatāmā wa-l-masākīna wa-bna s-sabīli wa-s-sāʾilīna wa-fī r-riqāb.',
    translation:
        'And gives wealth, despite love for it, to relatives, orphans, the needy, the traveller, those who ask, and for freeing slaves.',
    source: 'Qur’an 2:177',
    detail: 'Emergency care you noticed. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.care.emergency.bukhari_5653',
    group: kCharityGroupCare,
    topic: 'Emergency Support',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'أَطْعِمُوا الْجَائِعَ وَعُودُوا الْمَرِيضَ',
    transliteration: 'Aṭʿimū l-jāʾiʿa wa-ʿūdū l-marīḍ.',
    translation: 'Feed the hungry and visit the sick.',
    source: 'Ṣaḥīḥ al-Bukhārī 5653',
    detail: 'Emergency care you noticed. Illness visits stay on Rights of Others.',
  ),
  _item(
    id: 'ch.care.emergency.90_13',
    group: kCharityGroupCare,
    topic: 'Emergency Support',
    text: 'It is the freeing of a slave, or feeding on a day of hunger:',
    arabic: 'فَكُّ رَقَبَةٍ أَوْ إِطْعَامٌ فِي يَوْمٍ ذِي مَسْغَبَةٍ',
    transliteration: 'Fakku raqabah. Aw iṭʿāmun fī yawmin dhī masghabah.',
    translation: 'It is the freeing of a slave, or feeding on a day of severe hunger.',
    source: 'Qur’an 90:13–14',
    detail: 'Emergency care you noticed. Amounts are not recorded.',
  ),
  _item(
    id: 'ch.care.stress',
    group: kCharityGroupCare,
    topic: 'Support Under Financial Stress',
    text: 'If the debtor is in hardship:',
    arabic: 'وَإِن كَانَ ذُو عُسْرَةٍ فَنَظِرَةٌ إِلَىٰ مَيْسَرَةٍ',
    transliteration: 'Wa-in kāna dhū ʿusratin fa-naẓiratun ilā maysarah.',
    translation:
        'And if the debtor is in hardship, then postpone until a time of ease.',
    source: 'Qur’an 2:280',
    detail: 'Support in hardship you noticed. Debt and poverty are not failings. There is no zakat calculator here.',
  ),
  _item(
    id: 'ch.care.stress.2_273',
    group: kCharityGroupCare,
    topic: 'Support Under Financial Stress',
    text: 'For the poor who are restricted in Allah’s way:',
    arabic: 'لِلْفُقَرَاءِ الَّذِينَ أُحْصِرُوا فِي سَبِيلِ اللَّهِ',
    transliteration: 'Li-l-fuqarāʾi lladhīna uḥṣirū fī sabīli llāh.',
    translation: 'For the poor who are restricted in the way of Allah.',
    source: 'Qur’an 2:273',
    detail: 'Support in hardship you noticed. Poverty is not a failing.',
  ),
  _item(
    id: 'ch.care.stress.bukhari_1465',
    group: kCharityGroupCare,
    topic: 'Support Under Financial Stress',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ',
    transliteration:
        'Man naffasa ʿan muʾminin kurbatan min kurabi d-dunyā naffasa llāhu ʿanhu kurbatan min kurabi yawmi l-qiyāmah.',
    translation:
        'Whoever relieves a believer of a distress of this world, Allah will relieve him of a distress of the Day of Rising.',
    source: 'Ṣaḥīḥ Muslim 2699',
    detail: 'Support in hardship you noticed. Debt is not a failing.',
  ),
  _item(
    id: 'ch.care.stress.5_2',
    group: kCharityGroupCare,
    topic: 'Support Under Financial Stress',
    text: 'Help one another in righteousness:',
    arabic: 'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ',
    transliteration: 'Wa-taʿāwanū ʿalā l-birri wa-t-taqwā.',
    translation: 'Help one another in righteousness and taqwa.',
    source: 'Qur’an 5:2',
    detail: 'Support in hardship you noticed. There is no zakat calculator here.',
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

PracticeHadithRecord recordFromCharityCatalog({
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
    domain: MonitorDomain.charity,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
