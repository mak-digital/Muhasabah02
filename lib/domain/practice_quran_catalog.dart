import 'monitor_domain.dart';
import 'practice_hadith.dart';

PracticeHadithItem _item({
  required String id,
  required String topic,
  required String text,
  required String arabic,
  required String transliteration,
  required String translation,
  required String source,
  required String detail,
}) {
  return PracticeHadithItem(
    id: id,
    topic: topic,
    text: text,
    arabic: arabic,
    transliteration: transliteration,
    translation: translation,
    source: source,
    sourceDetail: detail,
  );
}

const _skim =
    'For daily reading and memorization. Citation only — not a khushu’ score, recitation streak, or Knowledge’s residual.';

/// Widely used passages for salah, daily reading, and memorization.
/// Openings of frequently recited surahs, Ayat al-Kursi, the close of
/// Al-Baqarah, short prayer surahs, and duas often said in worship.
/// Not every surah opening, not a hifz programme, and not a grade.
final List<PracticeHadithItem> kPracticeQuranCatalog = [
  _item(
    id: 'pq.fatiha',
    topic: 'Al-Fātiḥah',
    text: 'The opening of the Book, recited in every rakʿah:',
    arabic:
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n'
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\n'
        'الرَّحْمَٰنِ الرَّحِيمِ\n'
        'مَالِكِ يَوْمِ الدِّينِ\n'
        'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\n'
        'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\n'
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    transliteration:
        'Bismi llāhi r-raḥmāni r-raḥīm. Al-ḥamdu lillāhi rabbi l-ʿālamīn. Ar-raḥmāni r-raḥīm. Māliki yawmi d-dīn. Iyyāka naʿbudu wa iyyāka nastaʿīn. Ihdinā ṣ-ṣirāṭa l-mustaqīm. Ṣirāṭa lladhīna anʿamta ʿalayhim ghayri l-maghḍūbi ʿalayhim wa lā ḍ-ḍāllīn.',
    translation:
        'In the name of Allah, the Entirely Merciful, the Especially Merciful. All praise is for Allah, Lord of the worlds. The Entirely Merciful, the Especially Merciful. Master of the Day of Recompense. You alone we worship, and You alone we ask for help. Guide us to the straight path — the path of those You have blessed, not of those who earned wrath, nor of those who go astray.',
    source: 'Qur’an 1:1–7',
    detail: _skim,
  ),
  _item(
    id: 'pq.baqarah.open',
    topic: 'Opening of Al-Baqarah',
    text: 'The first verses of the longest surah — a widely memorized opening:',
    arabic:
        'الم\n'
        'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ\n'
        'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ\n'
        'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ\n'
        'أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ',
    transliteration:
        'Alif lām mīm. Dhālika l-kitābu lā rayba fīh, hudan li-l-muttaqīn. Alladhīna yuʾminūna bi-l-ghaybi wa yuqīmūna ṣ-ṣalāta wa mimmā razaqnāhum yunfiqūn. Wa lladhīna yuʾminūna bi-mā unzila ilayka wa mā unzila min qablika wa bi-l-ākhirati hum yūqinūn. Ulāʾika ʿalā hudan min rabbihim wa ulāʾika humu l-mufliḥūn.',
    translation:
        'Alif, Lam, Mim. This is the Book about which there is no doubt, a guidance for those mindful of Allah — who believe in the unseen, establish prayer, and spend from what We have provided them; and who believe in what was revealed to you and before you, and are certain of the Hereafter. Those are upon guidance from their Lord, and it is they who succeed.',
    source: 'Qur’an 2:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.kursi',
    topic: 'Āyat al-Kursī',
    text: 'The verse of the Throne — among the most recited and memorized verses:',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration:
        'Allāhu lā ilāha illā huwa l-ḥayyu l-qayyūm. Lā taʾkhudhuhū sinatun wa lā nawm. Lahū mā fī s-samāwāti wa mā fī l-arḍ. Man dhā lladhī yashfaʿu ʿindahū illā bi-idhnih. Yaʿlamu mā bayna aydīhim wa mā khalfahum. Wa lā yuḥīṭūna bi-shayʾin min ʿilmihī illā bi-mā shāʾ. Wasiʿa kursiyyuhu s-samāwāti wa l-arḍ. Wa lā yaʾūduhū ḥifẓuhumā. Wa huwa l-ʿaliyyu l-ʿaẓīm.',
    translation:
        'Allah — there is no god except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness nor sleep overtakes Him. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what is behind them, and they encompass nothing of His knowledge except what He wills. His Kursī extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
    source: 'Qur’an 2:255',
    detail: _skim,
  ),
  _item(
    id: 'pq.rabbana.atina',
    topic: 'Our Lord, grant us good',
    text: 'A short dua widely said in prayer after Āyat al-Kursī’s section of Al-Baqarah:',
    arabic:
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration:
        'Rabbanā ātinā fī d-dunyā ḥasanatan wa fī l-ākhirati ḥasanatan wa qinā ʿadhāba n-nār.',
    translation:
        'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
    source: 'Qur’an 2:201',
    detail: _skim,
  ),
  _item(
    id: 'pq.baqarah.close',
    topic: 'Closing of Al-Baqarah',
    text: 'The last three verses of Al-Baqarah, often recited at night:',
    arabic:
        'لِلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ وَإِن تُبْدُوا مَا فِي أَنفُسِكُمْ أَوْ تُخْفُوهُ يُحَاسِبْكُم بِهِ اللَّهُ ۖ فَيَغْفِرُ لِمَن يَشَاءُ وَيُعَذِّبُ مَن يَشَاءُ ۗ وَاللَّهُ عَلَٰى كُلِّ شَيْءٍ قَدِيرٌ\n'
        'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ\n'
        'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    transliteration:
        'Li-llāhi mā fī s-samāwāti wa mā fī l-arḍ… Āmana r-rasūlu bi-mā unzila ilayhi min rabbihī wa l-muʾminūn… Lā yukallifu llāhu nafsan illā wusʿahā… Rabbanā lā tuʾākhidhnā in nasīnā aw akhṭaʾnā… waʿfu ʿannā wa-ghfir lanā wa-rḥamnā. Anta mawlānā fa-nṣurnā ʿalā l-qawmi l-kāfirīn.',
    translation:
        'To Allah belongs whatever is in the heavens and whatever is on the earth… The Messenger has believed in what was revealed to him from his Lord, and so have the believers… Allah does not charge a soul except with its capacity… Our Lord, do not take us to task if we forget or make a mistake… pardon us, forgive us, and have mercy on us. You are our Protector, so give us victory over the disbelieving people.',
    source: 'Qur’an 2:284–286',
    detail: _skim,
  ),
  _item(
    id: 'pq.imran.open',
    topic: 'Opening of Āl ʿImrān',
    text: 'The opening of the third surah, often paired with Al-Baqarah in recitation:',
    arabic:
        'الم\n'
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ\n'
        'نَزَّلَ عَلَيْكَ الْكِتَابَ بِالْحَقِّ مُصَدِّقًا لِّمَا بَيْنَ يَدَيْهِ وَأَنزَلَ التَّوْرَاةَ وَالْإِنجِيلَ\n'
        'مِن قَبْلُ هُدًى لِّلنَّاسِ وَأَنزَلَ الْفُرْقَانَ',
    transliteration:
        'Alif lām mīm. Allāhu lā ilāha illā huwa l-ḥayyu l-qayyūm. Nazzala ʿalayka l-kitāba bi-l-ḥaqqi muṣaddiqan li-mā bayna yadayhi wa anzala t-tawrāta wa l-injīl. Min qablu hudan li-n-nāsi wa anzala l-furqān.',
    translation:
        'Alif, Lam, Mim. Allah — there is no god except Him, the Ever-Living, the Sustainer of existence. He has sent down upon you the Book in truth, confirming what was before it, and He sent down the Torah and the Gospel previously as guidance for the people, and He sent down the Criterion.',
    source: 'Qur’an 3:1–4',
    detail: _skim,
  ),
  _item(
    id: 'pq.imran.8',
    topic: 'Do not let our hearts deviate',
    text: 'A dua after hearing the Book, often said in qunūt and personal prayer:',
    arabic:
        'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
    transliteration:
        'Rabbanā lā tuzigh qulūbanā baʿda idh hadaytanā wa hab lanā min ladunka raḥmah. Innaka anta l-wahhāb.',
    translation:
        'Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from Yourself. Indeed, You are the Bestower.',
    source: 'Qur’an 3:8',
    detail: _skim,
  ),
  _item(
    id: 'pq.imran.26',
    topic: 'Owner of sovereignty',
    text: 'A verse of tawakkul often recited when asking Allah for strength:',
    arabic:
        'قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَن تَشَاءُ وَتَنزِعُ الْمُلْكَ مِمَّن تَشَاءُ وَتُعِزُّ مَن تَشَاءُ وَتُذِلُّ مَن تَشَاءُ ۖ بِيَدِكَ الْخَيْرُ ۖ إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        'Quli llāhumma mālika l-mulki tuʾtī l-mulka man tashāʾu wa tanziʿu l-mulka mimman tashāʾu wa tuʿizzu man tashāʾu wa tudhillu man tashāʾ. Bi-yadika l-khayr. Innaka ʿalā kulli shayʾin qadīr.',
    translation:
        'Say: O Allah, Owner of sovereignty, You give sovereignty to whom You will and You take it away from whom You will. You honour whom You will and You humble whom You will. In Your hand is all good. Indeed, You are over all things competent.',
    source: 'Qur’an 3:26',
    detail: _skim,
  ),
  _item(
    id: 'pq.hasbunallah',
    topic: 'Allah is sufficient for us',
    text: 'Words of trust often said in hardship and after prayer:',
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Ḥasbunā llāhu wa niʿma l-wakīl.',
    translation: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
    source: 'Qur’an 3:173',
    detail: _skim,
  ),
  _item(
    id: 'pq.anham.salat',
    topic: 'My prayer and my life',
    text: 'A verse often remembered when standing for salah:',
    arabic:
        'قُلْ إِنَّ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي لِلَّهِ رَبِّ الْعَالَمِينَ\n'
        'لَا شَرِيكَ لَهُ ۖ وَبِذَٰلِكَ أُمِرْتُ وَأَنَا أَوَّلُ الْمُسْلِمِينَ',
    transliteration:
        'Qul inna ṣalātī wa nusukī wa maḥyāya wa mamātī li-llāhi rabbi l-ʿālamīn. Lā sharīka lah. Wa bi-dhālika umirtu wa anā awwalu l-muslimīn.',
    translation:
        'Say: Indeed, my prayer, my rites, my living and my dying are for Allah, Lord of the worlds. He has no partner. And this I have been commanded, and I am the first of those who submit.',
    source: 'Qur’an 6:162–163',
    detail: _skim,
  ),
  _item(
    id: 'pq.araf.23',
    topic: 'We have wronged ourselves',
    text: 'The dua of Ādam, often used in seeking forgiveness:',
    arabic:
        'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    transliteration:
        'Rabbanā ẓalamnā anfusanā wa in lam taghfir lanā wa tarḥamnā la-nakūnanna mina l-khāsirīn.',
    translation:
        'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
    source: 'Qur’an 7:23',
    detail: _skim,
  ),
  _item(
    id: 'pq.ibrahim.7',
    topic: 'If you are grateful',
    text: 'A verse of motivation often kept in daily reading:',
    arabic:
        'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
    transliteration:
        'La-in shakartum la-azīdannakum. Wa la-in kafartum inna ʿadhābī la-shadīd.',
    translation:
        'If you are grateful, I will surely increase you; but if you deny, indeed My punishment is severe.',
    source: 'Qur’an 14:7',
    detail: _skim,
  ),
  _item(
    id: 'pq.ibrahim.40',
    topic: 'Make me steadfast in prayer',
    text: 'Ibrāhīm’s dua for salah, often said for one’s household:',
    arabic:
        'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
    transliteration:
        'Rabbi jʿalnī muqīma ṣ-ṣalāti wa min dhurriyyatī. Rabbanā wa taqabbal duʿāʾ.',
    translation:
        'My Lord, make me an establisher of prayer, and from my descendants. Our Lord, and accept my supplication.',
    source: 'Qur’an 14:40',
    detail: _skim,
  ),
  _item(
    id: 'pq.isra.80',
    topic: 'An entrance of truth',
    text: 'A short dua for beginnings and travel of the heart:',
    arabic:
        'رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل لِّي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا',
    transliteration:
        'Rabbi adkhilnī mudkhala ṣidqin wa akhrijnī mukhraja ṣidqin wa jʿal lī min ladunka sulṭānan naṣīrā.',
    translation:
        'My Lord, cause me to enter a sound entrance and to exit a sound exit, and grant me from Yourself a supporting authority.',
    source: 'Qur’an 17:80',
    detail: _skim,
  ),
  _item(
    id: 'pq.kahf.open',
    topic: 'Opening of Al-Kahf',
    text: 'The opening of the Friday surah, often kept for weekly reading:',
    arabic:
        'الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوَجًا\n'
        'قَيِّمًا لِّيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ وَيُبَشِّرَ الْمُؤْمِنِينَ الَّذِينَ يَعْمَلُونَ الصَّالِحَاتِ أَنَّ لَهُمْ أَجْرًا حَسَنًا',
    transliteration:
        'Al-ḥamdu lillāhi lladhī anzala ʿalā ʿabdihi l-kitāba wa lam yajʿal lahū ʿiwajā. Qayyiman li-yundhira baʾsan shadīdan min ladunhu wa yubashshira l-muʾminīna lladhīna yaʿmalūna ṣ-ṣāliḥāti anna lahum ajran ḥasanā.',
    translation:
        'All praise is for Allah, who sent down upon His servant the Book and did not make in it any crookedness — [He made it] straight, to warn of a severe punishment from Him and to give good tidings to the believers who do righteous deeds that they will have a good reward.',
    source: 'Qur’an 18:1–2',
    detail: _skim,
  ),
  _item(
    id: 'pq.kahf.10',
    topic: 'Grant us mercy from Yourself',
    text: 'The dua of the People of the Cave:',
    arabic:
        'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    transliteration:
        'Rabbanā ātinā min ladunka raḥmatan wa hayyiʾ lanā min amrinā rashadā.',
    translation:
        'Our Lord, grant us mercy from Yourself and prepare for us from our affair right guidance.',
    source: 'Qur’an 18:10',
    detail: _skim,
  ),
  _item(
    id: 'pq.taha.14',
    topic: 'Establish prayer for My remembrance',
    text: 'A verse that ties salah to remembering Allah:',
    arabic:
        'إِنَّنِي أَنَا اللَّهُ لَا إِلَٰهَ إِلَّا أَنَا فَاعْبُدْنِي وَأَقِمِ الصَّلَاةَ لِذِكْرِي',
    transliteration:
        'Innanī ana llāhu lā ilāha illā anā fa-ʿbudnī wa aqimi ṣ-ṣalāta li-dhikrī.',
    translation:
        'Indeed, I am Allah. There is no god except Me, so worship Me and establish prayer for My remembrance.',
    source: 'Qur’an 20:14',
    detail: _skim,
  ),
  _item(
    id: 'pq.taha.25',
    topic: 'Expand my chest',
    text: 'Mūsā’s dua before speaking — often said when beginning something hard:',
    arabic:
        'رَبِّ اشْرَحْ لِي صَدْرِي\n'
        'وَيَسِّرْ لِي أَمْرِي\n'
        'وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي\n'
        'يَفْقَهُوا قَوْلِي',
    transliteration:
        'Rabbi shraḥ lī ṣadrī. Wa yassir lī amrī. Wa ḥlul ʿuqdatan min lisānī. Yafqahū qawlī.',
    translation:
        'My Lord, expand for me my chest, and ease for me my task, and untie the knot from my tongue so they may understand my speech.',
    source: 'Qur’an 20:25–28',
    detail: _skim,
  ),
  _item(
    id: 'pq.anbiya.87',
    topic: 'There is no god except You',
    text: 'The call of Yūnus, often said in distress:',
    arabic:
        'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    transliteration:
        'Lā ilāha illā anta subḥānaka innī kuntu mina ẓ-ẓālimīn.',
    translation:
        'There is no god except You; exalted are You. Indeed, I have been of the wrongdoers.',
    source: 'Qur’an 21:87',
    detail: _skim,
  ),
  _item(
    id: 'pq.muminun.open',
    topic: 'Opening of Al-Muʾminūn',
    text: 'The opening that names the successful by their salah:',
    arabic:
        'قَدْ أَفْلَحَ الْمُؤْمِنُونَ\n'
        'الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ\n'
        'وَالَّذِينَ هُمْ عَنِ اللَّغْوِ مُعْرِضُونَ\n'
        'وَالَّذِينَ هُمْ لِلزَّكَاةِ فَاعِلُونَ\n'
        'وَالَّذِينَ هُمْ لِفُرُوجِهِمْ حَافِظُونَ',
    transliteration:
        'Qad aflaḥa l-muʾminūn. Alladhīna hum fī ṣalātihim khāshiʿūn. Wa lladhīna hum ʿani l-laghwi muʿriḍūn. Wa lladhīna hum li-z-zakāti fāʿilūn. Wa lladhīna hum li-furūjihim ḥāfiẓūn.',
    translation:
        'The believers have succeeded — those who are humble in their prayer, who turn away from idle talk, who are active in purification, and who guard their chastity.',
    source: 'Qur’an 23:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.muminun.118',
    topic: 'Forgive and have mercy',
    text: 'The closing dua of Al-Muʾminūn:',
    arabic: 'رَبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ',
    transliteration: 'Rabbi ghfir wa-rḥam wa anta khayru r-rāḥimīn.',
    translation: 'My Lord, forgive and have mercy, and You are the best of the merciful.',
    source: 'Qur’an 23:118',
    detail: _skim,
  ),
  _item(
    id: 'pq.furqan.74',
    topic: 'Grant us coolness of the eyes',
    text: 'A household dua often kept for family and salah:',
    arabic:
        'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
    transliteration:
        'Rabbanā hab lanā min azwājinā wa dhurriyyātinā qurrata aʿyunin wa jʿalnā li-l-muttaqīna imāmā.',
    translation:
        'Our Lord, grant us from our spouses and offspring comfort of the eyes, and make us leaders for those who are mindful of You.',
    source: 'Qur’an 25:74',
    detail: _skim,
  ),
  _item(
    id: 'pq.yasin.open',
    topic: 'Opening of Yā-Sīn',
    text: 'The opening of a surah widely chosen for recitation and memorization:',
    arabic:
        'يس\n'
        'وَالْقُرْآنِ الْحَكِيمِ\n'
        'إِنَّكَ لَمِنَ الْمُرْسَلِينَ\n'
        'عَلَىٰ صِرَاطٍ مُّسْتَقِيمٍ\n'
        'تَنزِيلَ الْعَزِيزِ الرَّحِيمِ',
    transliteration:
        'Yā-sīn. Wa l-qurʾāni l-ḥakīm. Innaka la-mina l-mursalīn. ʿAlā ṣirāṭin mustaqīm. Tanzīla l-ʿazīzi r-raḥīm.',
    translation:
        'Ya-Sin. By the wise Qur’an, indeed you are among the messengers, on a straight path — a revelation of the Exalted in Might, the Merciful.',
    source: 'Qur’an 36:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.saffat.close',
    topic: 'Glory to your Lord',
    text: 'Closing words often said after recitation and at the end of a sitting:',
    arabic:
        'سُبْحَانَ رَبِّكَ رَبِّ الْعِزَّةِ عَمَّا يَصِفُونَ\n'
        'وَسَلَامٌ عَلَى الْمُرْسَلِينَ\n'
        'وَالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    transliteration:
        'Subḥāna rabbika rabbi l-ʿizzati ʿammā yaṣifūn. Wa salāmun ʿalā l-mursalīn. Wa l-ḥamdu lillāhi rabbi l-ʿālamīn.',
    translation:
        'Exalted is your Lord, the Lord of might, above what they describe. And peace upon the messengers. And all praise is for Allah, Lord of the worlds.',
    source: 'Qur’an 37:180–182',
    detail: _skim,
  ),
  _item(
    id: 'pq.zumar.53',
    topic: 'Do not despair of Allah’s mercy',
    text: 'A verse of hope widely kept for motivation after a slip:',
    arabic:
        'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
    transliteration:
        'Qul yā ʿibādiya lladhīna asrafū ʿalā anfusihim lā taqnaṭū min raḥmati llāh. Inna llāha yaghfiru dh-dhunūba jamīʿā. Innahū huwa l-ghafūru r-raḥīm.',
    translation:
        'Say: O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.',
    source: 'Qur’an 39:53',
    detail: _skim,
  ),
  _item(
    id: 'pq.hujurat.13',
    topic: 'The most noble is the most mindful',
    text: 'A verse of dignity often kept for daily character:',
    arabic:
        'يَا أَيُّهَا النَّاسُ إِنَّا خَلَقْنَاكُم مِّن ذَكَرٍ وَأُنثَىٰ وَجَعَلْنَاكُمْ شُعُوبًا وَقَبَائِلَ لِتَعَارَفُوا ۚ إِنَّ أَكْرَمَكُمْ عِندَ اللَّهِ أَتْقَاكُمْ ۚ إِنَّ اللَّهَ عَلِيمٌ خَبِيرٌ',
    transliteration:
        'Yā ayyuhā n-nāsu innā khalaqnākum min dhakarin wa unthā wa jaʿalnākum shuʿūban wa qabāʾila li-taʿārafū. Inna akramakum ʿinda llāhi atqākum. Inna llāha ʿalīmun khabīr.',
    translation:
        'O mankind, We created you from a male and a female and made you peoples and tribes that you may know one another. Indeed, the most noble of you in the sight of Allah is the most mindful of Him. Indeed, Allah is Knowing and Acquainted.',
    source: 'Qur’an 49:13',
    detail: _skim,
  ),
  _item(
    id: 'pq.rahman.open',
    topic: 'Opening of Ar-Raḥmān',
    text: 'The opening of the surah of Allah’s favours:',
    arabic:
        'الرَّحْمَٰنُ\n'
        'عَلَّمَ الْقُرْآنَ\n'
        'خَلَقَ الْإِنسَانَ\n'
        'عَلَّمَهُ الْبَيَانَ',
    transliteration:
        'Ar-raḥmān. ʿAllama l-qurʾān. Khalaqa l-insān. ʿAllamahū l-bayān.',
    translation:
        'The Entirely Merciful taught the Qur’an, created man, [and] taught him eloquence.',
    source: 'Qur’an 55:1–4',
    detail: _skim,
  ),
  _item(
    id: 'pq.hashr.close',
    topic: 'Closing of Al-Ḥashr',
    text: 'The last verses of Al-Ḥashr, often recited in the evening:',
    arabic:
        'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ ۖ عَالِمُ الْغَيْبِ وَالشَّهَادَةِ ۖ هُوَ الرَّحْمَٰنُ الرَّحِيمُ\n'
        'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْمَلِكُ الْقُدُّوسُ السَّلَامُ الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ ۚ سُبْحَانَ اللَّهِ عَمَّا يُشْرِكُونَ\n'
        'هُوَ اللَّهُ الْخَالِقُ الْبَارِئُ الْمُصَوِّرُ ۖ لَهُ الْأَسْمَاءُ الْحُسْنَىٰ ۚ يُسَبِّحُ لَهُ مَا فِي السَّمَاوَاتِ وَالْأَرْضِ ۖ وَهُوَ الْعَزِيزُ الْحَكِيمُ',
    transliteration:
        'Huwa llāhu lladhī lā ilāha illā huwa ʿālimu l-ghaybi wa sh-shahādah. Huwa r-raḥmānu r-raḥīm. Huwa llāhu lladhī lā ilāha illā huwa l-maliku l-quddūsu s-salāmu l-muʾminu l-muhayminu l-ʿazīzu l-jabbāru l-mutakabbir… Huwa llāhu l-khāliqu l-bāriʾu l-muṣawwir. Lahu l-asmāʾu l-ḥusnā…',
    translation:
        'He is Allah — there is no god except Him, Knower of the unseen and the witnessed. He is the Entirely Merciful, the Especially Merciful. He is Allah — the Sovereign, the Pure, the Source of Peace, the Giver of Faith, the Overseer, the Exalted in Might, the Compeller, the Superior… To Him belong the best names. Whatever is in the heavens and earth exalts Him, and He is the Exalted in Might, the Wise.',
    source: 'Qur’an 59:22–24',
    detail: _skim,
  ),
  _item(
    id: 'pq.mulk.open',
    topic: 'Opening of Al-Mulk',
    text: 'The opening of a surah widely recited at night:',
    arabic:
        'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ\n'
        'الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ الْعَزِيزُ الْغَفُورُ',
    transliteration:
        'Tabāraka lladhī bi-yadihi l-mulku wa huwa ʿalā kulli shayʾin qadīr. Alladhī khalaqa l-mawta wa l-ḥayāta li-yabluwakum ayyukum aḥsanu ʿamalā. Wa huwa l-ʿazīzu l-ghafūr.',
    translation:
        'Blessed is He in whose hand is dominion, and He is over all things competent — who created death and life to test you [as to] which of you is best in deed. And He is the Exalted in Might, the Forgiving.',
    source: 'Qur’an 67:1–2',
    detail: _skim,
  ),
  _item(
    id: 'pq.naba.open',
    topic: 'Opening of An-Nabaʾ',
    text: 'A short Juz ʿAmma opening often used in salah:',
    arabic:
        'عَمَّ يَتَسَاءَلُونَ\n'
        'عَنِ النَّبَإِ الْعَظِيمِ\n'
        'الَّذِي هُمْ فِيهِ مُخْتَلِفُونَ\n'
        'كَلَّا سَيَعْلَمُونَ\n'
        'ثُمَّ كَلَّا سَيَعْلَمُونَ',
    transliteration:
        'ʿAmma yatasāʾalūn. ʿAni n-nabaʾi l-ʿaẓīm. Alladhī hum fīhi mukhtalifūn. Kallā sa-yaʿlamūn. Thumma kallā sa-yaʿlamūn.',
    translation:
        'About what are they asking one another? About the great news — that over which they are in disagreement. No! They will come to know. Then, no! They will come to know.',
    source: 'Qur’an 78:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.ala.open',
    topic: 'Opening of Al-Aʿlā',
    text: 'A short surah opening often recited in Friday and Eid prayer:',
    arabic:
        'سَبِّحِ اسْمَ رَبِّكَ الْأَعْلَى\n'
        'الَّذِي خَلَقَ فَسَوَّىٰ\n'
        'وَالَّذِي قَدَّرَ فَهَدَىٰ\n'
        'وَالَّذِي أَخْرَجَ الْمَرْعَىٰ\n'
        'فَجَعَلَهُ غُثَاءً أَحْوَىٰ',
    transliteration:
        'Sabbiḥi sma rabbika l-aʿlā. Alladhī khalaqa fa-sawwā. Wa lladhī qaddara fa-hadā. Wa lladhī akhraja l-marʿā. Fa-jaʿalahū ghuthāʾan aḥwā.',
    translation:
        'Exalt the name of your Lord, the Most High, who created and proportioned, who determined and guided, who brought out the pasture then made it black stubble.',
    source: 'Qur’an 87:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.duha',
    topic: 'Aḍ-Ḍuḥā',
    text: 'A short surah of consolation often kept for difficult days:',
    arabic:
        'وَالضُّحَىٰ\n'
        'وَاللَّيْلِ إِذَا سَجَىٰ\n'
        'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ\n'
        'وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ\n'
        'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
    transliteration:
        'Wa ḍ-ḍuḥā. Wa l-layli idhā sajā. Mā waddaʿaka rabbuka wa mā qalā. Wa la-l-ākhiratu khayrun laka mina l-ūlā. Wa la-sawfa yuʿṭīka rabbuka fa-tarḍā.',
    translation:
        'By the morning brightness, and by the night when it covers with darkness, your Lord has not taken leave of you, nor has He detested [you]. And the Hereafter is better for you than the first [life]. And your Lord is going to give you, and you will be satisfied.',
    source: 'Qur’an 93:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.sharh',
    topic: 'Ash-Sharḥ',
    text: 'A short complete surah of relief, often recited in salah:',
    arabic:
        'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ\n'
        'وَوَضَعْنَا عَنكَ وِزْرَكَ\n'
        'الَّذِي أَنقَضَ ظَهْرَكَ\n'
        'وَرَفَعْنَا لَكَ ذِكْرَكَ\n'
        'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا\n'
        'إِنَّ مَعَ الْعُسْرِ يُسْرًا\n'
        'فَإِذَا فَرَغْتَ فَانصَبْ\n'
        'وَإِلَىٰ رَبِّكَ فَارْغَبْ',
    transliteration:
        'A-lam nashraḥ laka ṣadrak. Wa waḍaʿnā ʿanka wizrak. Alladhī anqaḍa ẓahrak. Wa rafaʿnā laka dhikrak. Fa-inna maʿa l-ʿusri yusrā. Inna maʿa l-ʿusri yusrā. Fa-idhā faraghta fa-nṣab. Wa ilā rabbika fa-rghab.',
    translation:
        'Did We not expand for you your chest, and remove from you your burden which had weighed upon your back, and raise high for you your mention? For indeed, with hardship comes ease. Indeed, with hardship comes ease. So when you have finished, still stand, and to your Lord direct your longing.',
    source: 'Qur’an 94:1–8',
    detail: _skim,
  ),
  _item(
    id: 'pq.alaq.open',
    topic: 'Opening of Al-ʿAlaq',
    text: 'The first revealed verses, often kept as a start to reading:',
    arabic:
        'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ\n'
        'خَلَقَ الْإِنسَانَ مِنْ عَلَقٍ\n'
        'اقْرَأْ وَرَبُّكَ الْأَكْرَمُ\n'
        'الَّذِي عَلَّمَ بِالْقَلَمِ\n'
        'عَلَّمَ الْإِنسَانَ مَا لَمْ يَعْلَمْ',
    transliteration:
        'Iqraʾ bi-smi rabbika lladhī khalaq. Khalaqa l-insāna min ʿalaq. Iqraʾ wa rabbuka l-akram. Alladhī ʿallama bi-l-qalam. ʿAllama l-insāna mā lam yaʿlam.',
    translation:
        'Read in the name of your Lord who created — created man from a clinging clot. Read, and your Lord is the most Generous, who taught by the pen, taught man that which he knew not.',
    source: 'Qur’an 96:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.qadr',
    topic: 'Al-Qadr',
    text: 'A short complete surah of Laylat al-Qadr, often recited in Ramadan prayer:',
    arabic:
        'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ\n'
        'وَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ\n'
        'لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ\n'
        'تَنَزَّلُ الْمَلَائِكَةُ وَالرُّوحُ فِيهَا بِإِذْنِ رَبِّهِم مِّن كُلِّ أَمْرٍ\n'
        'سَلَامٌ هِيَ حَتَّىٰ مَطْلَعِ الْفَجْرِ',
    transliteration:
        'Innā anzalnāhu fī laylati l-qadr. Wa mā adrāka mā laylatu l-qadr. Laylatu l-qadri khayrun min alfi shahr. Tanazzalu l-malāʾikatu wa r-rūḥu fīhā bi-idhni rabbihim min kulli amr. Salāmun hiya ḥattā maṭlaʿi l-fajr.',
    translation:
        'Indeed, We sent it down on the Night of Decree. And what can make you know what is the Night of Decree? The Night of Decree is better than a thousand months. The angels and the Spirit descend therein by permission of their Lord for every matter. Peace it is until the emergence of dawn.',
    source: 'Qur’an 97:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.asr',
    topic: 'Al-ʿAṣr',
    text: 'A short complete surah often called a summary of the path:',
    arabic:
        'وَالْعَصْرِ\n'
        'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ\n'
        'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ',
    transliteration:
        'Wa l-ʿaṣr. Inna l-insāna la-fī khusr. Illā lladhīna āmanū wa ʿamilū ṣ-ṣāliḥāti wa tawāṣaw bi-l-ḥaqqi wa tawāṣaw bi-ṣ-ṣabr.',
    translation:
        'By time, indeed mankind is in loss, except those who believe, do righteous deeds, and advise one another to truth and advise one another to patience.',
    source: 'Qur’an 103:1–3',
    detail: _skim,
  ),
  _item(
    id: 'pq.kawthar',
    topic: 'Al-Kawthar',
    text: 'The shortest surah, often among the first memorized for salah:',
    arabic:
        'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ\n'
        'فَصَلِّ لِرَبِّكَ وَانْحَرْ\n'
        'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
    transliteration:
        'Innā aʿṭaynāka l-kawthar. Fa-ṣalli li-rabbika wa-nḥar. Inna shāniʾaka huwa l-abtar.',
    translation:
        'Indeed, We have granted you al-Kawthar. So pray to your Lord and sacrifice. Indeed, your enemy is the one cut off.',
    source: 'Qur’an 108:1–3',
    detail: _skim,
  ),
  _item(
    id: 'pq.kafirun',
    topic: 'Al-Kāfirūn',
    text: 'A short complete surah often recited in Sunnah prayers:',
    arabic:
        'قُلْ يَا أَيُّهَا الْكَافِرُونَ\n'
        'لَا أَعْبُدُ مَا تَعْبُدُونَ\n'
        'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ\n'
        'وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ\n'
        'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ\n'
        'لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
    transliteration:
        'Qul yā ayyuhā l-kāfirūn. Lā aʿbudu mā taʿbudūn. Wa lā antum ʿābidūna mā aʿbud. Wa lā anā ʿābidun mā ʿabattum. Wa lā antum ʿābidūna mā aʿbud. Lakum dīnukum wa liya dīn.',
    translation:
        'Say: O disbelievers, I do not worship what you worship, nor are you worshippers of what I worship, nor will I be a worshipper of what you worship, nor will you be worshippers of what I worship. For you is your religion, and for me is my religion.',
    source: 'Qur’an 109:1–6',
    detail: _skim,
  ),
  _item(
    id: 'pq.nasr',
    topic: 'An-Naṣr',
    text: 'A short complete surah of help and closing praise:',
    arabic:
        'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ\n'
        'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا\n'
        'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا',
    transliteration:
        'Idhā jāʾa naṣru llāhi wa l-fatḥ. Wa raʾayta n-nāsa yadkhulūna fī dīni llāhi afwājā. Fa-sabbiḥ bi-ḥamdi rabbika wa-staghfirh. Innahū kāna tawwābā.',
    translation:
        'When the help of Allah has come and the conquest, and you see the people entering into the religion of Allah in multitudes, then exalt [Him] with praise of your Lord and ask forgiveness of Him. Indeed, He is ever Accepting of repentance.',
    source: 'Qur’an 110:1–3',
    detail: _skim,
  ),
  _item(
    id: 'pq.ikhlas',
    topic: 'Al-Ikhlāṣ',
    text: 'A short complete surah equal in meaning to a third of the Qur’an, recited in almost every salah set:',
    arabic:
        'قُلْ هُوَ اللَّهُ أَحَدٌ\n'
        'اللَّهُ الصَّمَدُ\n'
        'لَمْ يَلِدْ وَلَمْ يُولَدْ\n'
        'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    transliteration:
        'Qul huwa llāhu aḥad. Allāhu ṣ-ṣamad. Lam yalid wa lam yūlad. Wa lam yakun lahū kufuwan aḥad.',
    translation:
        'Say: He is Allah, One. Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
    source: 'Qur’an 112:1–4',
    detail: _skim,
  ),
  _item(
    id: 'pq.falaq',
    topic: 'Al-Falaq',
    text: 'The first of the Muʿawwidhatayn, often recited in prayer and before sleep:',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\n'
        'مِن شَرِّ مَا خَلَقَ\n'
        'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ\n'
        'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ\n'
        'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    transliteration:
        'Qul aʿūdhu bi-rabbi l-falaq. Min sharri mā khalaq. Wa min sharri ghāsiqin idhā waqab. Wa min sharri n-naffāthāti fī l-ʿuqad. Wa min sharri ḥāsidin idhā ḥasad.',
    translation:
        'Say: I seek refuge in the Lord of daybreak from the evil of what He created, from the evil of darkness when it settles, from the evil of the blowers in knots, and from the evil of an envier when he envies.',
    source: 'Qur’an 113:1–5',
    detail: _skim,
  ),
  _item(
    id: 'pq.nas',
    topic: 'An-Nās',
    text: 'The last surah of the Book, often recited with Al-Falaq in salah:',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ\n'
        'مَلِكِ النَّاسِ\n'
        'إِلَٰهِ النَّاسِ\n'
        'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ\n'
        'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ\n'
        'مِنَ الْجِنَّةِ وَالنَّاسِ',
    transliteration:
        'Qul aʿūdhu bi-rabbi n-nās. Maliki n-nās. Ilāhi n-nās. Min sharri l-waswāsi l-khannās. Alladhī yuwaswisu fī ṣudūri n-nās. Mina l-jinnati wa n-nās.',
    translation:
        'Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer who whispers in the breasts of mankind — from among the jinn and mankind.',
    source: 'Qur’an 114:1–6',
    detail: _skim,
  ),
];

List<PracticeHadithItem> practiceQuranLearnList([
  List<PracticeHadithItem> extra = const [],
]) {
  return [...kPracticeQuranCatalog, ...extra];
}

PracticeHadithItem practiceQuranAt(
  int index, [
  List<PracticeHadithItem> extra = const [],
]) {
  final list = practiceQuranLearnList(extra);
  return list[wrapPracticeHadithIndex(index, list.length)];
}

PracticeHadithRecord recordFromQuranCatalog({
  required PracticeHadithItem item,
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
    domain: MonitorDomain.quran,
    status: PracticeHadithStatus.learning,
  );
}
