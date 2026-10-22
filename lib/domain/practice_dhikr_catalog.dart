import 'hadith_ref.dart';
import 'monitor_domain.dart';
import 'practice_hadith.dart';
import 'reflection_source.dart';

const kDhikrGroupPost = 'Post-fard Salah Adhkar';
const kDhikrGroupMorning = 'Morning Adhkar';
const kDhikrGroupEvening = 'Evening Adhkar';
const kDhikrGroupOther = 'Other Adhkar';

const kDhikrSubHighly = 'Highly recommended';
const kDhikrSubGeneral = 'General Dhikr';
const kDhikrSubGratitude = 'Gratitude Dhikr';
const kDhikrSubTravel = 'Travel Remembrance';
const kDhikrSubPersonal = 'Personal';
const kDhikrSubOther = 'Other Adhkars';

class PracticeDhikrItem {
  const PracticeDhikrItem({
    required this.id,
    required this.group,
    required this.subgroup,
    required this.topic,
    required this.text,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.sourceDetail,
  });

  final String id;
  final String group;
  final String subgroup;
  final String topic;
  final String text;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
  final String sourceDetail;
}

PracticeDhikrItem _item({
  required String id,
  required String group,
  required String subgroup,
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
    subgroup: subgroup,
    topic: topic,
    text: text,
    arabic: arabic,
    transliteration: transliteration,
    translation: translation,
    source: source,
    sourceDetail: detail,
  );
}

/// Built-in Dhikr & Dua list, grouped by occasion. Highly recommended
/// items sit first within each group. Not a target, score, or prescription.
final List<PracticeDhikrItem> _kPracticeDhikrCore = [
  // --- Post-fard: highly recommended, listed together ---
  _item(
    id: 'dh.post.istighfar3',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Istighfar three times',
    text: 'After the salam of the prescribed prayer, say three times:',
    arabic: 'أَسْتَغْفِرُ اللَّهَ  أَسْتَغْفِرُ اللَّهَ  أَسْتَغْفِرُ اللَّهَ',
    transliteration: 'Astaghfiru Allāh. Astaghfiru Allāh. Astaghfiru Allāh.',
    translation: 'I seek forgiveness from Allah (three times).',
    source: 'Ṣaḥīḥ Muslim 591',
    detail: 'Post-prayer. Not a salah score.',
  ),
  _item(
    id: 'dh.post.salam',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Allahumma anta as-salam',
    text: 'Then say:',
    arabic: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    transliteration: 'Allāhumma anta s-salām wa minka s-salām, tabārakta yā dhā l-jalāli wa l-ikrām.',
    translation: 'O Allah, You are Peace and from You is peace. Blessed are You, O Owner of majesty and honour.',
    source: 'Ṣaḥīḥ Muslim 591',
    detail: 'Immediately after the three istighfar.',
  ),
  _item(
    id: 'dh.post.tasbih33',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Tasbih, tahmid, takbir',
    text: 'After every prescribed prayer:',
    arabic: 'سُبْحَانَ اللَّهِ (٣٣)  الْحَمْدُ لِلَّهِ (٣٣)  اللَّهُ أَكْبَرُ (٣٣)  لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'Subḥān Allāh (33). Al-ḥamdu lillāh (33). Allāhu akbar (33). Lā ilāha illā Allāh, waḥdahu lā sharīka lah, lahu l-mulku wa lahu l-ḥamd, wa huwa ʿalā kulli shayʾin qadīr.',
    translation: 'Glory be to Allah (33), all praise is for Allah (33), Allah is the Greatest (33). There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things capable.',
    source: 'Ṣaḥīḥ Muslim 597',
    detail: 'The Fatimah tasbih after salah. Not a count badge in this app.',
  ),
  _item(
    id: 'dh.post.kursi',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Ayat al-Kursi after salah',
    text: 'After the prescribed prayer, recite:',
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration: 'Allāhu lā ilāha illā huwa l-Ḥayyu l-Qayyūm. Lā taʾkhudhuhu sinatun wa lā nawm. Lahu mā fī s-samāwāti wa mā fī l-arḍ. Man dhā alladhī yashfaʿu ʿindahu illā bi-idhnih. Yaʿlamu mā bayna aydīhim wa mā khalfahum, wa lā yuḥīṭūna bi-shayʾin min ʿilmihi illā bimā shāʾ. Wasiʿa kursiyyuhu s-samāwāti wa l-arḍ, wa lā yaʾūduhu ḥifẓuhumā, wa huwa l-ʿAliyyu l-ʿAẓīm.',
    translation: 'Allah — there is no god but He, the Ever-Living, the Self-Subsisting. Neither drowsiness nor sleep overtakes Him. To Him belongs what is in the heavens and what is on the earth. Who can intercede with Him except by His permission? He knows what is before them and what is behind them, and they encompass nothing of His knowledge except what He wills. His Kursi extends over the heavens and the earth, and their preservation does not tire Him. He is the Most High, the Magnificent.',
    source: 'Qur’an 2:255; Sunan an-Nasāʾī 7280',
    detail: 'After salah. Distinct from the thirty-three tasbih.',
  ),
  _item(
    id: 'dh.post.muawwidhat',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'The three Quls after salah',
    text: 'After each prescribed prayer, recite Sūrat al-Ikhlāṣ, al-Falaq, and al-Nās. After Maghrib and Fajr, do so three times.',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۞ قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    transliteration: 'Qul huwa Allāhu aḥad. Qul aʿūdhu bi-rabbi l-falaq. Qul aʿūdhu bi-rabbi n-nās.',
    translation: 'Say: He is Allah, One. Say: I seek refuge in the Lord of daybreak. Say: I seek refuge in the Lord of mankind.',
    source: 'Sunan Abī Dāwūd 1523; Jāmiʿ al-Tirmidhī 2903',
    detail: 'The Muʿawwidhāt after salah. Extra after Fajr and Maghrib.',
  ),
  _item(
    id: 'dh.post.ainni',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Help me to remember You',
    text: 'Muʿadh reported that the Prophet ﷺ took his hand and said: I love you, so do not forget to say after every prayer:',
    arabic:
        'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    transliteration:
        'Allāhumma aʿinnī ʿalā dhikrika wa shukrika wa ḥusni ʿibādatik.',
    translation: 'O Allah, help me to remember You, to thank You, and to worship You well.',
    source: 'Sunan Abī Dāwūd 1522; Sunan an-Nasāʾī 1303',
    detail: 'A post-prayer request. Not a khushu’ score.',
  ),
  _item(
    id: 'dh.post.tahlil10',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Tahlil ten times after Fajr and Maghrib',
    text: 'After Fajr and Maghrib, say ten times:',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'Lā ilāha illā Allāh, waḥdahu lā sharīka lah, lahu l-mulku wa lahu l-ḥamd, yuḥyī wa yumīt, wa huwa ʿalā kulli shayʾin qadīr.',
    translation: 'There is no god but Allah, alone, without partner. His is the dominion and His is the praise. He gives life and causes death, and He is over all things capable.',
    source: 'Jāmiʿ al-Tirmidhī 3474; Sunan an-Nasāʾī 1348',
    detail: 'Especially after Fajr and Maghrib. Not a streak.',
  ),
  _item(
    id: 'dh.post.ajirni',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Seeking protection from the Fire',
    text: 'After Maghrib and Fajr, say seven times:',
    arabic: 'اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ',
    transliteration: 'Allāhumma ajirnī mina n-nār.',
    translation: 'O Allah, protect me from the Fire.',
    source: 'Sunan Abī Dāwūd 5079',
    detail: 'After Maghrib and Fajr. Not a fear score.',
  ),
  _item(
    id: 'dh.post.qabr',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'Refuge after salah',
    text: 'After the prescribed prayer, seek refuge:',
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ وَأَعُوذُ بِكَ مِنْ أَنْ أُرَدَّ إِلَىٰ أَرْذَلِ الْعُمُرِ وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الدُّنْيَا وَعَذَابِ الْقَبْرِ',
    transliteration: 'Allāhumma innī aʿūdhu bika mina l-jubni wa l-bukhl, wa aʿūdhu bika min an uradda ilā ardhalil ʿumur, wa aʿūdhu bika min fitnati d-dunyā wa ʿadhābi l-qabr.',
    translation: 'O Allah, I seek refuge in You from cowardice and miserliness, from being returned to a feeble old age, from the trial of this world, and from the punishment of the grave.',
    source: 'Ṣaḥīḥ al-Bukhārī 6374',
    detail: 'A post-prayer refuge. Not a grade.',
  ),
  _item(
    id: 'dh.post.ilmu',
    group: kDhikrGroupPost,
    subgroup: kDhikrSubHighly,
    topic: 'After Fajr: beneficial knowledge',
    text: 'After the Fajr prayer, say:',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
    transliteration: 'Allāhumma innī asʾaluka ʿilman nāfiʿā, wa rizqan ṭayyibā, wa ʿamalan mutaqabbalā.',
    translation: 'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.',
    source: 'Sunan Ibn Mājah 925',
    detail: 'After Fajr. Knowledge & Beneficial Speech has its own card.',
  ),

  // --- Morning: highly recommended, kept together ---
  _item(
    id: 'dh.morn.kursi',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Ayat al-Kursi in the morning',
    text: 'In the morning, recite Ayat al-Kursi.',
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration: 'Allāhu lā ilāha illā huwa l-Ḥayyu l-Qayyūm. Lā taʾkhudhuhu sinatun wa lā nawm. Lahu mā fī s-samāwāti wa mā fī l-arḍ. Man dhā alladhī yashfaʿu ʿindahu illā bi-idhnih. Yaʿlamu mā bayna aydīhim wa mā khalfahum, wa lā yuḥīṭūna bi-shayʾin min ʿilmihi illā bimā shāʾ. Wasiʿa kursiyyuhu s-samāwāti wa l-arḍ, wa lā yaʾūduhu ḥifẓuhumā, wa huwa l-ʿAliyyu l-ʿAẓīm.',
    translation: 'Allah — there is no god but He, the Ever-Living, the Self-Subsisting… He is the Most High, the Magnificent.',
    source: 'Qur’an 2:255; Sunan an-Nasāʾī 7281',
    detail: 'Morning protection. Not a morning target.',
  ),
  _item(
    id: 'dh.morn.muawwidhat3',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'The three Quls, three times',
    text: 'In the morning, recite Sūrat al-Ikhlāṣ, al-Falaq, and al-Nās three times.',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۞ قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    transliteration: 'Qul huwa Allāhu aḥad. Qul aʿūdhu bi-rabbi l-falaq. Qul aʿūdhu bi-rabbi n-nās.',
    translation: 'Say: He is Allah, One. Say: I seek refuge in the Lord of daybreak. Say: I seek refuge in the Lord of mankind. (Three times.)',
    source: 'Sunan Abī Dāwūd 5082; Jāmiʿ al-Tirmidhī 3575',
    detail: 'Morning Muʿawwidhāt. Highly recommended together.',
  ),
  _item(
    id: 'dh.morn.sayyid',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Sayyid al-istighfar in the morning',
    text: 'In the morning, say the chief form of seeking forgiveness:',
    arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration: 'Allāhumma anta rabbī, lā ilāha illā ant, khalaqtanī wa anā ʿabduk, wa anā ʿalā ʿahdika wa waʿdika mā staṭaʿt. Aʿūdhu bika min sharri mā ṣanaʿt, abūʾu laka bi-niʿmatika ʿalayya, wa abūʾu bi-dhanbī, fa-ghfir lī, fa-innahu lā yaghfiru dh-dhunūba illā ant.',
    translation: 'O Allah, You are my Lord. There is no god but You. You created me and I am Your servant… so forgive me, for none forgives sins except You.',
    source: 'Ṣaḥīḥ al-Bukhārī 6306',
    detail: 'If said in the morning with certainty and one dies that day… Citation only.',
  ),
  _item(
    id: 'dh.morn.bismillah',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Nothing harms with His name',
    text: 'In the morning, say three times:',
    arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration: 'Bismillāhi alladhī lā yaḍurru maʿa ismihi shayʾun fī l-arḍi wa lā fī s-samāʾ, wa huwa s-Samīʿu l-ʿAlīm.',
    translation: 'In the name of Allah, with whose name nothing on earth or in heaven can harm, and He is the All-Hearing, the All-Knowing.',
    source: 'Sunan Abī Dāwūd 5088; Jāmiʿ al-Tirmidhī 3388',
    detail: 'Morning and evening. Highly recommended.',
  ),
  _item(
    id: 'dh.morn.kalimat',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'The perfect words of Allah',
    text: 'In the morning, say three times:',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'Aʿūdhu bi-kalimāti llāhi t-tāmmāti min sharri mā khalaq.',
    translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    source: 'Ṣaḥīḥ Muslim 2708',
    detail: 'Morning protection. Not a target count.',
  ),
  _item(
    id: 'dh.morn.bika',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'By You we enter the morning',
    text: 'In the morning, say:',
    arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    transliteration: 'Allāhumma bika aṣbaḥnā wa bika amsaynā, wa bika naḥyā wa bika namūtu wa ilayka n-nushūr.',
    translation: 'O Allah, by You we enter the morning and by You we enter the evening. By You we live and by You we die, and to You is the resurrection.',
    source: 'Sunan Abī Dāwūd 5068; Jāmiʿ al-Tirmidhī 3391',
    detail: 'A morning opening. Evening uses a parallel wording.',
  ),
  _item(
    id: 'dh.morn.fitrah',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Upon the fitrah of Islam',
    text: 'In the morning, say:',
    arabic: 'أَصْبَحْنَا عَلَىٰ فِطْرَةِ الْإِسْلَامِ وَعَلَىٰ كَلِمَةِ الْإِخْلَاصِ وَعَلَىٰ دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ وَعَلَىٰ مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
    transliteration: 'Aṣbaḥnā ʿalā fiṭrati l-islām, wa ʿalā kalimati l-ikhlāṣ, wa ʿalā dīni nabiyyinā Muḥammadin ﷺ, wa ʿalā millati abīnā Ibrāhīma ḥanīfan musliman wa mā kāna mina l-mushrikīn.',
    translation: 'We have entered the morning upon the natural way of Islam, the word of sincerity, the religion of our Prophet Muhammad ﷺ, and the way of our father Ibrahim, upright, a Muslim, and he was not of those who associate partners with Allah.',
    source: 'Sunan an-Nasāʾī 1346; Musnad Aḥmad 15351',
    detail: 'Morning identity. Not a creed quiz.',
  ),
  _item(
    id: 'dh.morn.afini',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Well-being in body, hearing, and sight',
    text: 'In the morning, say three times:',
    arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
    transliteration: 'Allāhumma ʿāfinī fī badanī. Allāhumma ʿāfinī fī samʿī. Allāhumma ʿāfinī fī baṣarī. Lā ilāha illā ant.',
    translation: 'O Allah, grant me well-being in my body. O Allah, grant me well-being in my hearing. O Allah, grant me well-being in my sight. There is no god but You.',
    source: 'Sunan Abī Dāwūd 5090',
    detail: 'Morning well-being. Physical Health has its own card.',
  ),
  _item(
    id: 'dh.morn.hayyu',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Ya Hayyu ya Qayyum',
    text: 'In the morning, say:',
    arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    transliteration: 'Yā Ḥayyu yā Qayyūm, bi-raḥmatika astaghīth. Aṣliḥ lī shaʾnī kullah, wa lā takilnī ilā nafsī ṭarfata ʿayn.',
    translation: 'O Ever-Living, O Self-Subsisting, by Your mercy I seek help. Set right all my affairs, and do not leave me to myself even for the blink of an eye.',
    source: 'Sunan an-Nasāʾī al-Kubrā 10421',
    detail: 'Morning appeal. Highly recommended.',
  ),
  _item(
    id: 'dh.morn.subhan100',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Subhan Allah wa bihamdihi, one hundred',
    text: 'In the morning, say one hundred times:',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Subḥān Allāhi wa bi-ḥamdih.',
    translation: 'Glory and praise be to Allah.',
    source: 'Ṣaḥīḥ Muslim 2692',
    detail: 'A morning hundred. Not a points system.',
  ),
  _item(
    id: 'dh.morn.tahlil100',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Tahlil one hundred times',
    text: 'In the morning, say one hundred times:',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'Lā ilāha illā Allāh, waḥdahu lā sharīka lah, lahu l-mulku wa lahu l-ḥamd, wa huwa ʿalā kulli shayʾin qadīr.',
    translation: 'There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things capable.',
    source: 'Ṣaḥīḥ al-Bukhārī 3293; Ṣaḥīḥ Muslim 2691',
    detail: 'Morning tahlil. Distinct from the ten after Fajr.',
  ),
  _item(
    id: 'dh.morn.hasbi',
    group: kDhikrGroupMorning,
    subgroup: kDhikrSubHighly,
    topic: 'Allah is sufficient for me',
    text: 'In the morning, say seven times:',
    arabic: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    transliteration: 'Ḥasbiya Allāhu lā ilāha illā huwa, ʿalayhi tawakkaltu, wa huwa rabbu l-ʿarshi l-ʿaẓīm.',
    translation: 'Allah is sufficient for me. There is no god but He. In Him I trust, and He is Lord of the Magnificent Throne.',
    source: 'Sunan Abī Dāwūd 5081',
    detail: 'Morning reliance. Highly recommended.',
  ),

  // --- Evening: highly recommended, kept together ---
  _item(
    id: 'dh.eve.kursi',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Ayat al-Kursi in the evening',
    text: 'In the evening, recite Ayat al-Kursi.',
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration: 'Allāhu lā ilāha illā huwa l-Ḥayyu l-Qayyūm… wa huwa l-ʿAliyyu l-ʿAẓīm.',
    translation: 'Allah — there is no god but He, the Ever-Living, the Self-Subsisting… He is the Most High, the Magnificent.',
    source: 'Qur’an 2:255; Sunan an-Nasāʾī 7281',
    detail: 'Evening protection. Pair of the morning recitation.',
  ),
  _item(
    id: 'dh.eve.muawwidhat3',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'The three Quls, three times',
    text: 'In the evening, recite Sūrat al-Ikhlāṣ, al-Falaq, and al-Nās three times.',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۞ قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    transliteration: 'Qul huwa Allāhu aḥad. Qul aʿūdhu bi-rabbi l-falaq. Qul aʿūdhu bi-rabbi n-nās.',
    translation: 'Say: He is Allah, One. Say: I seek refuge in the Lord of daybreak. Say: I seek refuge in the Lord of mankind. (Three times.)',
    source: 'Sunan Abī Dāwūd 5082; Jāmiʿ al-Tirmidhī 3575',
    detail: 'Evening Muʿawwidhāt. Highly recommended together.',
  ),
  _item(
    id: 'dh.eve.sayyid',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Sayyid al-istighfar in the evening',
    text: 'In the evening, say the chief form of seeking forgiveness:',
    arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration: 'Allāhumma anta rabbī, lā ilāha illā ant… fa-ghfir lī, fa-innahu lā yaghfiru dh-dhunūba illā ant.',
    translation: 'O Allah, You are my Lord. There is no god but You… so forgive me, for none forgives sins except You.',
    source: 'Ṣaḥīḥ al-Bukhārī 6306',
    detail: 'Evening counterpart of the morning sayyid.',
  ),
  _item(
    id: 'dh.eve.bismillah',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Nothing harms with His name',
    text: 'In the evening, say three times:',
    arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration: 'Bismillāhi alladhī lā yaḍurru maʿa ismihi shayʾun fī l-arḍi wa lā fī s-samāʾ, wa huwa s-Samīʿu l-ʿAlīm.',
    translation: 'In the name of Allah, with whose name nothing on earth or in heaven can harm, and He is the All-Hearing, the All-Knowing.',
    source: 'Sunan Abī Dāwūd 5088; Jāmiʿ al-Tirmidhī 3388',
    detail: 'Evening protection. Highly recommended.',
  ),
  _item(
    id: 'dh.eve.kalimat',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'The perfect words of Allah',
    text: 'In the evening, say three times:',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'Aʿūdhu bi-kalimāti llāhi t-tāmmāti min sharri mā khalaq.',
    translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    source: 'Ṣaḥīḥ Muslim 2708',
    detail: 'Evening protection.',
  ),
  _item(
    id: 'dh.eve.bika',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'By You we enter the evening',
    text: 'In the evening, say:',
    arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
    transliteration: 'Allāhumma bika amsaynā wa bika aṣbaḥnā, wa bika naḥyā wa bika namūtu wa ilayka l-maṣīr.',
    translation: 'O Allah, by You we enter the evening and by You we enter the morning. By You we live and by You we die, and to You is the return.',
    source: 'Sunan Abī Dāwūd 5068; Jāmiʿ al-Tirmidhī 3391',
    detail: 'Evening wording. Distinct from the morning nushūr.',
  ),
  _item(
    id: 'dh.eve.amsayna.mulk',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'The dominion belongs to Allah',
    text: 'In the evening, say:',
    arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    transliteration: 'Amsaynā wa amsā l-mulku lillāh, wa l-ḥamdu lillāh. Lā ilāha illā Allāh, waḥdahu lā sharīka lah.',
    translation: 'We have entered the evening and the dominion belongs to Allah, and all praise is for Allah. There is no god but Allah, alone, without partner.',
    source: 'Ṣaḥīḥ Muslim 2723',
    detail: 'Evening dominion. Highly recommended.',
  ),
  _item(
    id: 'dh.eve.afini',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Well-being in body, hearing, and sight',
    text: 'In the evening, say three times:',
    arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
    transliteration: 'Allāhumma ʿāfinī fī badanī. Allāhumma ʿāfinī fī samʿī. Allāhumma ʿāfinī fī baṣarī. Lā ilāha illā ant.',
    translation: 'O Allah, grant me well-being in my body, my hearing, and my sight. There is no god but You.',
    source: 'Sunan Abī Dāwūd 5090',
    detail: 'Evening well-being.',
  ),
  _item(
    id: 'dh.eve.hayyu',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Ya Hayyu ya Qayyum',
    text: 'In the evening, say:',
    arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    transliteration: 'Yā Ḥayyu yā Qayyūm, bi-raḥmatika astaghīth. Aṣliḥ lī shaʾnī kullah, wa lā takilnī ilā nafsī ṭarfata ʿayn.',
    translation: 'O Ever-Living, O Self-Subsisting, by Your mercy I seek help. Set right all my affairs, and do not leave me to myself even for the blink of an eye.',
    source: 'Sunan an-Nasāʾī al-Kubrā 10421',
    detail: 'Evening appeal.',
  ),
  _item(
    id: 'dh.eve.subhan100',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Subhan Allah wa bihamdihi, one hundred',
    text: 'In the evening, say one hundred times:',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Subḥān Allāhi wa bi-ḥamdih.',
    translation: 'Glory and praise be to Allah.',
    source: 'Ṣaḥīḥ Muslim 2692',
    detail: 'An evening hundred.',
  ),
  _item(
    id: 'dh.eve.hasbi',
    group: kDhikrGroupEvening,
    subgroup: kDhikrSubHighly,
    topic: 'Allah is sufficient for me',
    text: 'In the evening, say seven times:',
    arabic: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    transliteration: 'Ḥasbiya Allāhu lā ilāha illā huwa, ʿalayhi tawakkaltu, wa huwa rabbu l-ʿarshi l-ʿaẓīm.',
    translation: 'Allah is sufficient for me. There is no god but He. In Him I trust, and He is Lord of the Magnificent Throne.',
    source: 'Sunan Abī Dāwūd 5081',
    detail: 'Evening reliance.',
  ),

  // --- Other Adhkar subsets ---
  _item(
    id: 'dh.gen.hawqala',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubGeneral,
    topic: 'La hawla wa la quwwata',
    text: 'A treasure from beneath the Throne:',
    arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'Lā ḥawla wa lā quwwata illā billāh.',
    translation: 'There is no power and no strength except with Allah.',
    source: 'Ṣaḥīḥ al-Bukhārī 6384; Ṣaḥīḥ Muslim 2704',
    detail: 'General dhikr. Not a productivity badge.',
  ),
  _item(
    id: 'dh.gen.salawat',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubGeneral,
    topic: 'Sending blessings',
    text: 'A core form of sending blessings upon the Prophet ﷺ:',
    arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
    transliteration: 'Allāhumma ṣalli ʿalā Muḥammadin wa ʿalā āli Muḥammad.',
    translation: 'O Allah, send blessings upon Muhammad and upon the family of Muhammad.',
    source: 'Ṣaḥīḥ Muslim 408',
    detail: 'General remembrance. Not a revival campaign.',
  ),
  _item(
    id: 'dh.gen.adheem',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubGeneral,
    topic: 'Two words beloved to the Most Merciful',
    text: 'Say often:',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ  سُبْحَانَ اللَّهِ الْعَظِيمِ',
    transliteration: 'Subḥān Allāhi wa bi-ḥamdih. Subḥān Allāhi l-ʿAẓīm.',
    translation:
        'Glory and praise be to Allah. Glory be to Allah the Magnificent.',
    source: 'Ṣaḥīḥ al-Bukhārī 6406; Ṣaḥīḥ Muslim 2694',
    detail: 'General dhikr. Light on the tongue.',
  ),
  _item(
    id: 'dh.grat.hamd',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubGratitude,
    topic: 'All praise is for Allah',
    text: 'A word that fills the Scale:',
    arabic: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Al-ḥamdu lillāh.',
    translation: 'All praise is for Allah.',
    source: 'Ṣaḥīḥ Muslim 223',
    detail: 'Gratitude dhikr. Not a mood score.',
  ),
  _item(
    id: 'dh.grat.laka',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubGratitude,
    topic: 'Praise as befits You',
    text: 'When praising Allah, a related wording is:',
    arabic: 'اللَّهُمَّ رَبَّنَا لَكَ الْحَمْدُ مِلْءَ السَّمَاوَاتِ وَمِلْءَ الْأَرْضِ وَمِلْءَ مَا شِئْتَ مِنْ شَيْءٍ بَعْدُ',
    transliteration: 'Allāhumma rabbanā laka l-ḥamd, milʾa s-samāwāti wa milʾa l-arḍi wa milʾa mā shiʾta min shayʾin baʿd.',
    translation: 'O Allah, our Lord, to You is all praise, filling the heavens, filling the earth, and filling whatever You will besides that.',
    source: 'Ṣaḥīḥ Muslim 476',
    detail: 'Gratitude after rising from rukuʿ, also used as hamd.',
  ),
  _item(
    id: 'dh.travel.mount',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubTravel,
    topic: 'When setting out',
    text: 'When mounting for a journey, say Allahu akbar three times, then:',
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
    transliteration: 'Subḥāna lladhī sakhkhara lanā hādhā wa mā kunnā lahu muqrinīn, wa innā ilā rabbinā la-munqalibūn.',
    translation: 'Glory to Him who subjected this to us, and we could not have done it ourselves. And to our Lord we will return.',
    source: 'Ṣaḥīḥ Muslim 1342',
    detail: 'Travel remembrance. Not a trip log.',
  ),
  _item(
    id: 'dh.travel.return',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubTravel,
    topic: 'When returning',
    text: 'When returning from a journey, say:',
    arabic: 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
    transliteration: 'Āyibūna, tāʾibūna, ʿābidūna, li-rabbinā ḥāmidūn.',
    translation: 'We return, repenting, worshipping, and praising our Lord.',
    source: 'Ṣaḥīḥ al-Bukhārī 3085; Ṣaḥīḥ Muslim 1344',
    detail: 'Return remembrance.',
  ),
  _item(
    id: 'dh.pers.jannah',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubPersonal,
    topic: 'Asking for the Garden',
    text: 'A personal request:',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ',
    transliteration:
        'Allāhumma innī asʾaluka l-jannah, wa aʿūdhu bika mina n-nār.',
    translation: 'O Allah, I ask You for the Garden, and I seek refuge in You from the Fire.',
    source: 'Sunan Abī Dāwūd 792; Sunan Ibn Mājah 3847',
    detail: 'Personal dua. Not a salvation score.',
  ),
  _item(
    id: 'dh.pers.rabbana',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubPersonal,
    topic: 'Our Lord, give us good',
    text: 'A personal request:',
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration: 'Rabbanā ātinā fī d-dunyā ḥasanatan wa fī l-ākhirati ḥasanatan wa qinā ʿadhāba n-nār.',
    translation: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
    source: 'Qur’an 2:201; Ṣaḥīḥ al-Bukhārī 4522',
    detail: 'A frequent personal dua of the Prophet ﷺ.',
  ),
  _item(
    id: 'dh.other.sleep.kursi',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubOther,
    topic: 'Ayat al-Kursi before sleep',
    text: 'When you lie down, recite Ayat al-Kursi.',
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration: 'Allāhu lā ilāha illā huwa l-Ḥayyu l-Qayyūm… wa huwa l-ʿAliyyu l-ʿAẓīm.',
    translation: 'Allah — there is no god but He, the Ever-Living, the Self-Subsisting… He is the Most High, the Magnificent.',
    source: 'Ṣaḥīḥ al-Bukhārī 2311; Qur’an 2:255',
    detail: 'Before sleep. Other Adhkars, not the morning set.',
  ),
  _item(
    id: 'dh.other.majlis',
    group: kDhikrGroupOther,
    subgroup: kDhikrSubOther,
    topic: 'Leaving a gathering',
    text: 'When rising from a gathering, say:',
    arabic: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    transliteration: 'Subḥānaka Allāhumma wa bi-ḥamdik, ashhadu an lā ilāha illā ant, astaghfiruka wa atūbu ilayk.',
    translation: 'Glory and praise be to You, O Allah. I bear witness that there is no god but You. I seek Your forgiveness and turn to You in repentance.',
    source: 'Jāmiʿ al-Tirmidhī 3433',
    detail: 'Other Adhkars. Not a speech score.',
  ),
];

final List<PracticeDhikrItem> kPracticeDhikrCatalog = [
  for (final item in _kPracticeDhikrCore) ..._dhikrWithSupports(item),
];

List<PracticeDhikrItem> _dhikrWithSupports(PracticeDhikrItem item) {
  return [
    item,
    _item(
      id: '${item.id}.33_41',
      group: item.group,
      subgroup: item.subgroup,
      topic: item.topic,
      text: 'Remember Allah with much remembrance:',
      arabic:
          'يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا',
      transliteration: 'Yā ayyuhā lladhīna āmanū dhkurū llāha dhikran kathīrā.',
      translation: 'O you who believe, remember Allah with much remembrance.',
      source: 'Qur’an 33:41',
      detail: item.sourceDetail,
    ),
    _item(
      id: '${item.id}.13_28',
      group: item.group,
      subgroup: item.subgroup,
      topic: item.topic,
      text: 'It is by the remembrance of Allah that hearts find rest:',
      arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      transliteration: 'Alā bi-dhikri llāhi taṭmaʾinnu l-qulūb.',
      translation:
          'Unquestionably, by the remembrance of Allah hearts are assured.',
      source: 'Qur’an 13:28',
      detail: item.sourceDetail,
    ),
  ];
}

const kPracticeDhikrGroups = [
  kDhikrGroupPost,
  kDhikrGroupMorning,
  kDhikrGroupEvening,
  kDhikrGroupOther,
];

List<PracticeDhikrItem> dhikrItemsInGroup(String group) {
  return [
    for (final item in kPracticeDhikrCatalog)
      if (item.group == group) item,
  ];
}

List<PracticeDhikrItem> practiceDhikrPrimaryForGroup(String group) {
  return [
    for (final item in _kPracticeDhikrCore)
      if (item.group == group) item,
  ];
}

PracticeDhikrItem? practiceDhikrById(String id) {
  for (final item in kPracticeDhikrCatalog) {
    if (item.id == id) return item;
  }
  return null;
}

List<PracticeDhikrItem> practiceDhikrMatchingCitation(String citation) {
  if (citation.trim().isEmpty) return const [];
  final keys = hadithKeysFromSource(citation);
  final uris = {
    for (final uri in reflectionSourceUris(citation)) uri.toString(),
  };
  return [
    for (final item in _kPracticeDhikrCore)
      if (_practiceSourceOverlaps(item.source, keys: keys, uris: uris)) item,
  ];
}

bool _practiceSourceOverlaps(
  String source, {
  required Set<String> keys,
  required Set<String> uris,
}) {
  if (keys.isNotEmpty) {
    final found = hadithKeysFromSource(source);
    if (found.any(keys.contains)) return true;
  }
  if (uris.isEmpty) return false;
  return reflectionSourceUris(source).any((uri) => uris.contains('$uri'));
}

PracticeHadithRecord recordFromDhikrCatalog({
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
    domain: MonitorDomain.dhikr,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
