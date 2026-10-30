import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kUmmahGroupMasjid = 'Masjid';
const kUmmahGroupWitness = 'Witness';
const kUmmahGroupSolidarity = 'Solidarity';
const kUmmahGroupEarth = 'Earth';

const kPracticeUmmahGroups = [
  kUmmahGroupMasjid,
  kUmmahGroupWitness,
  kUmmahGroupSolidarity,
  kUmmahGroupEarth,
];

/// Qur’an and authentic hadith that encourage Ummah Home rows.
/// Belonging beyond the household — not a public check-in or ethnic log.
final List<PracticeDhikrItem> kPracticeUmmahCatalog = [
  _item(
    id: 'um.masjid.class',
    group: kUmmahGroupMasjid,
    topic: 'Masjid class or gathering (not the fard)',
    text: 'Those who maintain the mosques of Allah:',
    arabic: 'إِنَّمَا يَعْمُرُ مَسَاجِدَ اللَّهِ مَنْ آمَنَ بِاللَّهِ وَالْيَوْمِ الْآخِرِ',
    transliteration:
        'Innamā yaʿmuru masājida llāhi man āmana bi-llāhi wa-l-yawmi l-ākhir.',
    translation: 'The mosques of Allah are maintained only by those who believe in Allah and the Last Day.',
    source: 'Qur’an 9:18',
    detail: 'A class or gathering, not the fard or Jumu‘ah. Private, not a public masjid check-in.',
  ),
  _item(
    id: 'um.masjid.class.9_18b',
    group: kUmmahGroupMasjid,
    topic: 'Masjid class or gathering (not the fard)',
    text: 'And established prayer, and gave zakat:',
    arabic:
        'وَأَقَامَ الصَّلَاةَ وَآتَى الزَّكَاةَ وَلَمْ يَخْشَ إِلَّا اللَّهَ',
    transliteration:
        'Wa-aqāma ṣ-ṣalāta wa-ātā z-zakāta wa-lam yakhsha illā llāh.',
    translation:
        'And who establishes prayer and gives zakat and fears none but Allah.',
    source: 'Qur’an 9:18',
    detail: 'A class or gathering, not the fard. Private, not a public masjid check-in.',
  ),
  _item(
    id: 'um.masjid.class.bukhari_477',
    group: kUmmahGroupMasjid,
    topic: 'Masjid class or gathering (not the fard)',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَنْ غَدَا إِلَى الْمَسْجِدِ أَوْ رَاحَ أَعَدَّ اللَّهُ لَهُ نُزُلَهُ مِنَ الْجَنَّةِ كُلَّمَا غَدَا أَوْ رَاحَ',
    transliteration: 'Man ghadā ilā l-masjidi aw rāḥa aʿadda llāhu lahu nuzulahu mina l-jannati kullamā ghadā aw rāḥ.',
    translation: 'Whoever goes to the mosque in the morning or the evening, Allah prepares for him a lodging in Paradise whenever he goes.',
    source: 'Ṣaḥīḥ al-Bukhārī 662',
    detail:
        'A class or gathering, not the fard or Jumu‘ah. Not a public check-in.',
  ),
  _item(
    id: 'um.masjid.class.2_114',
    group: kUmmahGroupMasjid,
    topic: 'Masjid class or gathering (not the fard)',
    text:
        'Who is more unjust than one who prevents Allah’s name in His mosques:',
    arabic: 'وَمَنْ أَظْلَمُ مِمَّن مَّنَعَ مَسَاجِدَ اللَّهِ أَن يُذْكَرَ فِيهَا اسْمُهُ',
    transliteration:
        'Wa-man aẓlamu mimman manaʿa masājida llāhi an yudhkara fīhā smuh.',
    translation: 'And who is more unjust than one who prevents the mosques of Allah from having His name remembered in them.',
    source: 'Qur’an 2:114',
    detail: 'A class or gathering. Isolation is not a failing.',
  ),
  _item(
    id: 'um.witness.character',
    group: kUmmahGroupWitness,
    topic: 'Da’wah by character',
    text: 'Invite to your Lord’s way with wisdom:',
    arabic: 'ادْعُ إِلَىٰ سَبِيلِ رَبِّكَ بِالْحِكْمَةِ وَالْمَوْعِظَةِ الْحَسَنَةِ',
    transliteration:
        'Udʿu ilā sabīli rabbika bi-l-ḥikmati wa-l-mawʿiẓati l-ḥasanah.',
    translation:
        'Invite to the way of your Lord with wisdom and good instruction.',
    source: 'Qur’an 16:125',
    detail: 'By character, not argument. Not Character & Morals’ virtue list.',
  ),
  _item(
    id: 'um.witness.character.3_104',
    group: kUmmahGroupWitness,
    topic: 'Da’wah by character',
    text: 'Let there be a community calling to good:',
    arabic: 'وَلْتَكُن مِّنكُمْ أُمَّةٌ يَدْعُونَ إِلَى الْخَيْرِ وَيَأْمُرُونَ بِالْمَعْرُوفِ وَيَنْهَوْنَ عَنِ الْمُنكَرِ',
    transliteration: 'Wa-l-takun minkum ummatun yadʿūna ilā l-khayri wa-yaʾmurūna bi-l-maʿrūfi wa-yanhawna ʿani l-munkar.',
    translation: 'And let there be from you a community inviting to good, enjoining what is right, and forbidding what is wrong.',
    source: 'Qur’an 3:104',
    detail: 'By character, not argument. Sectarian rants are not logged here.',
  ),
  _item(
    id: 'um.witness.character.41_33',
    group: kUmmahGroupWitness,
    topic: 'Da’wah by character',
    text: 'Who is better in speech than one who calls to Allah:',
    arabic:
        'وَمَنْ أَحْسَنُ قَوْلًا مِّمَّن دَعَا إِلَى اللَّهِ وَعَمِلَ صَالِحًا',
    transliteration:
        'Wa-man aḥsanu qawlan mimman daʿā ilā llāhi wa-ʿamila ṣāliḥā.',
    translation: 'And who is better in speech than one who calls to Allah and does righteous work.',
    source: 'Qur’an 41:33',
    detail: 'By character, not debate. Not Character & Morals’ virtue list.',
  ),
  _item(
    id: 'um.witness.character.bukhari_3461',
    group: kUmmahGroupWitness,
    topic: 'Da’wah by character',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'بَلِّغُوا عَنِّي وَلَوْ آيَةً',
    transliteration: 'Ballighū ʿannī wa-law āyah.',
    translation: 'Convey from me, even if it is one verse.',
    source: 'Ṣaḥīḥ al-Bukhārī 3461',
    detail: 'By character, not argument. Introversion is not a failing.',
  ),
  _item(
    id: 'um.solidarity.oppressed',
    group: kUmmahGroupSolidarity,
    topic: 'Supported the oppressed',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'انْصُرْ أَخَاكَ ظَالِمًا أَوْ مَظْلُومًا',
    transliteration: 'Unṣur akhāka ẓāliman aw maẓlūmā.',
    translation:
        'Help your brother, whether he is the oppressor or the oppressed.',
    source: 'Ṣaḥīḥ al-Bukhārī 2444',
    detail: 'Dua, awareness, or material help. Not a political rant, and not Charity’s giving row.',
  ),
  _item(
    id: 'um.solidarity.oppressed.4_75',
    group: kUmmahGroupSolidarity,
    topic: 'Supported the oppressed',
    text: 'Why should you not fight for the oppressed:',
    arabic: 'وَمَا لَكُمْ لَا تُقَاتِلُونَ فِي سَبِيلِ اللَّهِ وَالْمُسْتَضْعَفِينَ مِنَ الرِّجَالِ وَالنِّسَاءِ وَالْوِلْدَانِ',
    transliteration: 'Wa-mā lakum lā tuqātilūna fī sabīli llāhi wa-l-mustaḍʿafīna mina r-rijāli wa-n-nisāʾi wa-l-wildān.',
    translation: 'And what is [the matter] with you that you do not fight in the way of Allah, and for the oppressed among men, women, and children.',
    source: 'Qur’an 4:75',
    detail: 'Dua, awareness, or material help. Not a political rant. Safety comes first.',
  ),
  _item(
    id: 'um.solidarity.oppressed.muslim_2580',
    group: kUmmahGroupSolidarity,
    topic: 'Supported the oppressed',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'الْمُسْلِمُ أَخُو الْمُسْلِمِ، لَا يَظْلِمُهُ وَلَا يَخْذُلُهُ',
    transliteration: 'Al-muslimu akhū l-muslim, lā yaẓlimuhu wa-lā yakhdhuluh.',
    translation: 'The Muslim is the brother of the Muslim. He does not wrong him or forsake him.',
    source: 'Ṣaḥīḥ Muslim 2564',
    detail: 'Support you noticed. Not Charity’s giving row.',
  ),
  _item(
    id: 'um.solidarity.oppressed.5_2',
    group: kUmmahGroupSolidarity,
    topic: 'Supported the oppressed',
    text: 'Help one another in righteousness:',
    arabic: 'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ',
    transliteration: 'Wa-taʿāwanū ʿalā l-birri wa-t-taqwā.',
    translation: 'Help one another in righteousness and taqwa.',
    source: 'Qur’an 5:2',
    detail: 'Dua, awareness, or material help. Not a political rant.',
  ),
  _item(
    id: 'um.solidarity.unity',
    group: kUmmahGroupSolidarity,
    topic: 'Worked for unity',
    text: 'Hold fast to the rope of Allah together:',
    arabic: 'وَاعْتَصِمُوا بِحَبْلِ اللَّهِ جَمِيعًا وَلَا تَفَرَّقُوا',
    transliteration: 'Wa-ʿtaṣimū bi-ḥabli llāhi jamīʿan wa-lā tafarraqū.',
    translation: 'And hold firmly to the rope of Allah all together and do not become divided.',
    source: 'Qur’an 3:103',
    detail: 'Working for unity. Sectarian arguments are not logged here. The Ummah is global.',
  ),
  _item(
    id: 'um.solidarity.unity.49_10',
    group: kUmmahGroupSolidarity,
    topic: 'Worked for unity',
    text: 'The believers are brothers:',
    arabic: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ',
    transliteration: 'Innamā l-muʾminūna ikhwah.',
    translation: 'The believers are but brothers.',
    source: 'Qur’an 49:10',
    detail: 'Working for unity. Sectarian arguments are not logged here.',
  ),
  _item(
    id: 'um.solidarity.unity.21_92',
    group: kUmmahGroupSolidarity,
    topic: 'Worked for unity',
    text: 'This community of yours is one community:',
    arabic: 'إِنَّ هَٰذِهِ أُمَّتُكُمْ أُمَّةً وَاحِدَةً وَأَنَا رَبُّكُمْ فَاعْبُدُونِ',
    transliteration:
        'Inna hādhihi ummatukum ummatan wāḥidatan wa-anā rabbukum fa-ʿbudūn.',
    translation: 'Indeed this, your community, is one community, and I am your Lord, so worship Me.',
    source: 'Qur’an 21:92',
    detail: 'The Ummah is global, not an ethnic group.',
  ),
  _item(
    id: 'um.solidarity.unity.bukhari_13',
    group: kUmmahGroupSolidarity,
    topic: 'Worked for unity',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    transliteration:
        'Lā yuʾminu aḥadukum ḥattā yuḥibba li-akhīhi mā yuḥibbu li-nafsih.',
    translation: 'None of you believes until he loves for his brother what he loves for himself.',
    source: 'Ṣaḥīḥ al-Bukhārī 13',
    detail: 'Working for unity. Isolation is not a failing.',
  ),
  _item(
    id: 'um.solidarity.dua',
    group: kUmmahGroupSolidarity,
    topic: 'Prayed for the Ummah',
    text: 'Those who came after them say:',
    arabic: 'رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ',
    transliteration:
        'Rabbanā ighfir lanā wa-li-ikhwāninā lladhīna sabaqūnā bi-l-īmān.',
    translation:
        'Our Lord, forgive us and our brothers who preceded us in faith.',
    source: 'Qur’an 59:10',
    detail: 'Dua for the Ummah, especially in crisis. Isolation and introversion are not failings.',
  ),
  _item(
    id: 'um.solidarity.dua.14_41',
    group: kUmmahGroupSolidarity,
    topic: 'Prayed for the Ummah',
    text: 'Our Lord, forgive me and my parents and the believers:',
    arabic: 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
    transliteration: 'Rabbanā ighfir lī wa-li-wālidayya wa-li-l-muʾminīna yawma yaqūmu l-ḥisāb.',
    translation: 'Our Lord, forgive me and my parents and the believers on the Day the account is established.',
    source: 'Qur’an 14:41',
    detail: 'Dua for the Ummah. Isolation is not a failing.',
  ),
  _item(
    id: 'um.solidarity.dua.muslim_2739',
    group: kUmmahGroupSolidarity,
    topic: 'Prayed for the Ummah',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَا مِنْ عَبْدٍ مُسْلِمٍ يَدْعُو لِأَخِيهِ بِظَهْرِ الْغَيْبِ إِلَّا قَالَ الْمَلَكُ: وَلَكَ بِمِثْلٍ',
    transliteration: 'Mā min ʿabdin muslimin yadʿū li-akhīhi bi-ẓahri l-ghaybi illā qāla l-malak: wa-laka bi-mithl.',
    translation: 'There is no Muslim who prays for his brother in his absence except that the angel says: And for you the same.',
    source: 'Ṣaḥīḥ Muslim 2732',
    detail: 'Dua for the Ummah, especially in crisis.',
  ),
  _item(
    id: 'um.solidarity.dua.2_286',
    group: kUmmahGroupSolidarity,
    topic: 'Prayed for the Ummah',
    text: 'Our Lord, do not burden us as You burdened those before us:',
    arabic: 'رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا',
    transliteration: 'Rabbanā wa-lā taḥmil ʿalaynā iṣran kamā ḥamaltahu ʿalā lladhīna min qablinā.',
    translation: 'Our Lord, do not burden us with a load as You burdened those before us.',
    source: 'Qur’an 2:286',
    detail: 'Dua for the Ummah. Introversion is not a failing.',
  ),
  _item(
    id: 'um.earth.care',
    group: kUmmahGroupEarth,
    topic: 'Cared for the earth',
    text: 'Do not spread corruption on the earth:',
    arabic: 'وَلَا تُفْسِدُوا فِي الْأَرْضِ بَعْدَ إِصْلَاحِهَا',
    transliteration: 'Wa-lā tufsidū fī l-arḍi baʿda iṣlāḥihā.',
    translation: 'And do not spread corruption on the earth after it has been set right.',
    source: 'Qur’an 7:56',
    detail: 'The earth is a trust. Not an environmental score, and not a public campaign log.',
  ),
  _item(
    id: 'um.earth.care.2_60',
    group: kUmmahGroupEarth,
    topic: 'Cared for the earth',
    text: 'Do not act wickedly on the earth, spreading corruption:',
    arabic: 'كُلُوا وَاشْرَبُوا مِن رِّزْقِ اللَّهِ وَلَا تَعْثَوْا فِي الْأَرْضِ مُفْسِدِينَ',
    transliteration:
        'Kulū wa-shrabū min rizqi llāhi wa-lā taʿthaw fī l-arḍi mufsidīn.',
    translation: 'Eat and drink from the provision of Allah, and do not act wickedly on the earth, spreading corruption.',
    source: 'Qur’an 2:60',
    detail: 'The earth is a trust. Not an environmental score.',
  ),
  _item(
    id: 'um.earth.care.30_41',
    group: kUmmahGroupEarth,
    topic: 'Cared for the earth',
    text: 'Corruption has appeared on land and sea:',
    arabic: 'ظَهَرَ الْفَسَادُ فِي الْبَرِّ وَالْبَحْرِ بِمَا كَسَبَتْ أَيْدِي النَّاسِ',
    transliteration:
        'Ẓahara l-fasādu fī l-barri wa-l-baḥri bi-mā kasabat aydī n-nās.',
    translation: 'Corruption has appeared on land and sea because of what people’s hands have earned.',
    source: 'Qur’an 30:41',
    detail: 'The earth is a trust. Not a public campaign log.',
  ),
  _item(
    id: 'um.earth.care.ahmad_12902',
    group: kUmmahGroupEarth,
    topic: 'Cared for the earth',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'إِنْ قَامَتِ السَّاعَةُ وَفِي يَدِ أَحَدِكُمْ فَسِيلَةٌ، فَإِنِ اسْتَطَاعَ أَنْ لَا تَقُومَ حَتَّى يَغْرِسَهَا فَلْيَغْرِسْهَا',
    transliteration: 'In qāmati s-sāʿatu wa-fī yadi aḥadikum fasīlah, fa-ini staṭāʿa an lā taqūma ḥattā yaghrisahā fal-yaghris-hā.',
    translation: 'If the Hour is established and one of you has a seedling in his hand, if he can plant it before it is established, let him plant it.',
    source: 'Musnad Aḥmad 12902',
    detail: 'The earth is a trust. Not an environmental score.',
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

PracticeHadithRecord recordFromUmmahCatalog({
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
    domain: MonitorDomain.ummah,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
