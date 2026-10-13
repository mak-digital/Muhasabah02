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

/// Built-in observational list of daily-practice hadith and related
/// supplications. Not a revival programme, sunnah checklist, or grade.
///
/// Add further items only with a new `id` and a distinct practice (time, place,
/// or wording). Do not repeat an existing supplication or the same essence.
final List<PracticeHadithItem> kPracticeHadithCatalog = [
  _item(
    id: 'ph.waking',
    topic: 'Waking',
    text: 'When the Prophet ﷺ woke, he would say:',
    arabic:
        'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    transliteration:
        'Al-ḥamdu lillāhi alladhī aḥyānā baʿda mā amātanā wa ilayhi n-nushūr.',
    translation:
        'All praise is for Allah who gave us life after causing us to die, and to Him is the resurrection.',
    source: 'Ṣaḥīḥ al-Bukhārī 6312',
    detail: 'A waking remembrance. Citation only — not a morning target.',
  ),
  _item(
    id: 'ph.sleep',
    topic: 'Sleep',
    text: 'When you go to your bed, say:',
    arabic: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ',
    transliteration: 'Bismika rabbī waḍaʿtu janbī wa bika arfaʿuh.',
    translation: 'In Your name, my Lord, I lie down, and in Your name I rise.',
    source: 'Ṣaḥīḥ al-Bukhārī 6320; Ṣaḥīḥ Muslim 2714',
    detail: 'A sleep supplication. Not a bedtime score.',
  ),
  _item(
    id: 'ph.wudu',
    topic: 'Wudu',
    text:
        'After completing wudu, a related supplication taught from the Prophet ﷺ is:',
    arabic:
        'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ. اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
    transliteration:
        'Ashhadu an lā ilāha illā Allāh, waḥdahu lā sharīka lah, wa ashhadu anna Muḥammadan ʿabduhu wa rasūluh. Allāhumma jʿalnī mina t-tawwābīna wa jʿalnī mina l-mutaṭahhirīn.',
    translation:
        'I bear witness that there is no god but Allah, alone, without partner, and I bear witness that Muhammad is His servant and messenger. O Allah, make me among those who repent and among those who purify themselves.',
    source: 'Ṣaḥīḥ Muslim 234; Jāmiʿ al-Tirmidhī 55',
    detail: 'A wudu remembrance. Not a purity grade.',
  ),
  _item(
    id: 'ph.toilet.enter',
    topic: 'Entering the toilet',
    text: 'When entering the place of relief, the Prophet ﷺ would say:',
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
    transliteration: 'Allāhumma innī aʿūdhu bika mina l-khubuthi wa l-khabāʾith.',
    translation:
        'O Allah, I seek refuge in You from the male and female unclean.',
    source: 'Ṣaḥīḥ al-Bukhārī 142; Ṣaḥīḥ Muslim 375',
    detail: 'A private supplication. Not a hygiene checklist.',
  ),
  _item(
    id: 'ph.home.leave',
    topic: 'Leaving home',
    text: 'When leaving the house, say:',
    arabic:
        'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration:
        'Bismillāh, tawakkaltu ʿalā Allāh, wa lā ḥawla wa lā quwwata illā billāh.',
    translation:
        'In the name of Allah, I trust in Allah; there is no power except with Allah.',
    source: 'Sunan Abī Dāwūd 5095; Jāmiʿ al-Tirmidhī 3426',
    detail: 'A leaving-home remembrance. Not a travel grade.',
  ),
  _item(
    id: 'ph.home.enter',
    topic: 'Entering home',
    text:
        'When entering the house, mention Allah. A related greeting of peace is:',
    arabic: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
    transliteration:
        'Bismillāhi walajnā, wa bismillāhi kharajnā, wa ʿalā Allāhi rabbinā tawakkalnā.',
    translation:
        'In the name of Allah we enter, in the name of Allah we leave, and upon Allah our Lord we rely.',
    source: 'Sunan Abī Dāwūd 5096',
    detail: 'Mentioning Allah at the door. Not a household score.',
  ),
  _item(
    id: 'ph.eating.bismillah',
    topic: 'Eating',
    text:
        'When one of you eats, let him mention the name of Allah. If he forgets at the beginning, let him say:',
    arabic: 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
    transliteration: 'Bismillāhi awwalahu wa ākhirah.',
    translation: 'In the name of Allah at its beginning and its end.',
    source: 'Sunan Abī Dāwūd 3767; Jāmiʿ al-Tirmidhī 1858',
    detail: 'A meal remembrance. Not a diet rule.',
  ),
  _item(
    id: 'ph.eating.right',
    topic: 'Eating',
    text: 'The Prophet ﷺ taught a boy at the table:',
    arabic: 'يَا غُلَامُ سَمِّ اللَّهَ وَكُلْ بِيَمِينِكَ وَكُلْ مِمَّا يَلِيكَ',
    transliteration: 'Yā ghulām, sammi Allāh, wa kul bi-yamīnik, wa kul mimmā yalīk.',
    translation:
        'O boy, mention the name of Allah, eat with your right hand, and eat from what is in front of you.',
    source: 'Ṣaḥīḥ al-Bukhārī 5376; Ṣaḥīḥ Muslim 2022',
    detail: 'A table manner of the Prophet ﷺ. Not a manners grade.',
  ),
  _item(
    id: 'ph.eating.thanks',
    topic: 'After eating',
    text: 'After food, say:',
    arabic:
        'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَٰذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
    transliteration:
        'Al-ḥamdu lillāhi alladhī aṭʿamanī hādhā wa razaqanīhi min ghayri ḥawlin minnī wa lā quwwah.',
    translation:
        'All praise is for Allah who fed me this and provided it for me without any power or might from me.',
    source: 'Sunan Abī Dāwūd 4023; Jāmiʿ al-Tirmidhī 3458',
    detail: 'A thanks after food. Not a calorie log.',
  ),
  _item(
    id: 'ph.drinking',
    topic: 'Drinking',
    text:
        'The Prophet ﷺ used to drink in three sips. A related remembrance when drinking is:',
    arabic: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillāh.',
    translation: 'In the name of Allah.',
    source: 'Ṣaḥīḥ al-Bukhārī 5631; Ṣaḥīḥ Muslim 2028',
    detail: 'A drinking manner. Not a health prescription.',
  ),
  _item(
    id: 'ph.greeting',
    topic: 'Greeting',
    text: 'Spread the greeting of peace. The core words are:',
    arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ',
    transliteration: 'As-salāmu ʿalaykum wa raḥmatullāhi wa barakātuh.',
    translation: 'Peace be upon you, and the mercy of Allah, and His blessings.',
    source: 'Ṣaḥīḥ Muslim 54',
    detail: 'Spreading salam. Not a social score.',
  ),
  _item(
    id: 'ph.clothing',
    topic: 'Clothing',
    text: 'When putting on a garment, the Prophet ﷺ would say:',
    arabic:
        'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ، أَسْأَلُكَ مِنْ خَيْرِهِ وَخَيْرِ مَا صُنِعَ لَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ',
    transliteration:
        'Allāhumma laka l-ḥamd, anta kasawtanīh. Asʾaluka min khayrihi wa khayri mā ṣuniʿa lah, wa aʿūdhu bika min sharrihi wa sharri mā ṣuniʿa lah.',
    translation:
        'O Allah, all praise is for You. You have clothed me with it. I ask You for its good and the good of what it was made for, and I seek refuge from its evil and the evil of what it was made for.',
    source: 'Sunan Abī Dāwūd 4020',
    detail: 'A dressing supplication. Not a fashion rule.',
  ),
  _item(
    id: 'ph.mirror',
    topic: 'Looking in the mirror',
    text: 'When looking in the mirror, say:',
    arabic: 'اللَّهُمَّ كَمَا أَحْسَنْتَ خَلْقِي فَأَحْسِنْ خُلُقِي',
    transliteration: 'Allāhumma kamā aḥsanta khalqī fa-aḥsin khuluqī.',
    translation:
        'O Allah, as You have made my appearance good, make my character good.',
    source: 'Musnad Aḥmad 3823',
    detail: 'A supplication when seeing oneself. Not an appearance grade.',
  ),
  _item(
    id: 'ph.mosque.enter',
    topic: 'Entering the mosque',
    text: 'When one of you enters the mosque, let him say:',
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    transliteration: 'Allāhumma ftaḥ lī abwāba raḥmatik.',
    translation: 'O Allah, open for me the doors of Your mercy.',
    source: 'Ṣaḥīḥ Muslim 713',
    detail: 'A mosque-entry supplication. Not an attendance mark.',
  ),
  _item(
    id: 'ph.mosque.leave',
    topic: 'Leaving the mosque',
    text: 'When leaving the mosque, say:',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    transliteration: 'Allāhumma innī asʾaluka min faḍlik.',
    translation: 'O Allah, I ask You of Your bounty.',
    source: 'Ṣaḥīḥ Muslim 713',
    detail: 'A leaving-mosque supplication.',
  ),
  _item(
    id: 'ph.after.salah',
    topic: 'After prayer',
    text: 'After every prayer, the core dhikr is:',
    arabic:
        'سُبْحَانَ اللَّهِ (٣٣)  الْحَمْدُ لِلَّهِ (٣٣)  اللَّهُ أَكْبَرُ (٣٣)  لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        'Subḥān Allāh (33). Al-ḥamdu lillāh (33). Allāhu akbar (33). Lā ilāha illā Allāh, waḥdahu lā sharīka lah, lahu l-mulku wa lahu l-ḥamd, wa huwa ʿalā kulli shayʾin qadīr.',
    translation:
        'Glory be to Allah (33), all praise is for Allah (33), Allah is the Greatest (33). There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things capable.',
    source: 'Ṣaḥīḥ Muslim 597',
    detail: 'Post-prayer dhikr. Not a salah score.',
  ),
  _item(
    id: 'ph.morning.evening',
    topic: 'Morning and evening',
    text: 'In the morning and evening, say:',
    arabic:
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    transliteration:
        'Subḥān Allāhi wa bi-ḥamdih, ʿadada khalqih, wa riḍā nafsih, wa zinata ʿarshih, wa midāda kalimātih.',
    translation:
        'Glory and praise be to Allah, as many as His creation, as much as pleases Him, as much as the weight of His Throne, and as much as the ink of His words.',
    source: 'Ṣaḥīḥ Muslim 2726',
    detail: 'A morning and evening dhikr. Not a target count in this app.',
  ),
  _item(
    id: 'ph.istighfar',
    topic: 'Seeking forgiveness',
    text: 'A core phrase of seeking forgiveness is:',
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    transliteration: 'Astaghfiru Allāha wa atūbu ilayh.',
    translation: 'I seek forgiveness from Allah and turn to Him in repentance.',
    source: 'Ṣaḥīḥ al-Bukhārī 6307',
    detail: 'Istighfar of the Prophet ﷺ. Not a tally in this app.',
  ),
  _item(
    id: 'ph.salawat',
    topic: 'Sending blessings',
    text: 'A core form of sending blessings upon the Prophet ﷺ is:',
    arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
    transliteration: 'Allāhumma ṣalli ʿalā Muḥammadin wa ʿalā āli Muḥammad.',
    translation:
        'O Allah, send blessings upon Muhammad and upon the family of Muhammad.',
    source: 'Ṣaḥīḥ Muslim 408',
    detail: 'Salawat. Not a revival campaign.',
  ),
  _item(
    id: 'ph.tasbih',
    topic: 'Dhikr',
    text:
        'Two words light on the tongue, heavy on the Scale, beloved to the Most Merciful:',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ  سُبْحَانَ اللَّهِ الْعَظِيمِ',
    transliteration: 'Subḥān Allāhi wa bi-ḥamdih. Subḥān Allāhi l-ʿAẓīm.',
    translation:
        'Glory and praise be to Allah. Glory be to Allah the Magnificent.',
    source: 'Ṣaḥīḥ al-Bukhārī 6406; Ṣaḥīḥ Muslim 2694',
    detail: 'A beloved dhikr. Not a points system.',
  ),
  _item(
    id: 'ph.travel',
    topic: 'Travel',
    text:
        'When mounting a riding animal for a journey, say Allahu akbar three times, then:',
    arabic:
        'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
    transliteration:
        'Subḥāna lladhī sakhkhara lanā hādhā wa mā kunnā lahu muqrinīn, wa innā ilā rabbinā la-munqalibūn.',
    translation:
        'Glory to Him who subjected this to us, and we could not have done it ourselves. And to our Lord we will return.',
    source: 'Ṣaḥīḥ Muslim 1342',
    detail: 'A travel supplication. Not a trip log.',
  ),
  _item(
    id: 'ph.family',
    topic: 'Family',
    text: 'A teaching about the home:',
    arabic: 'خَيْرُكُمْ خَيْرُكُمْ لِأَهْلِهِ وَأَنَا خَيْرُكُمْ لِأَهْلِي',
    transliteration: 'Khayrukum khayrukum li-ahlih, wa anā khayrukum li-ahlī.',
    translation:
        'The best of you is the best to his family, and I am the best of you to my family.',
    source: 'Jāmiʿ al-Tirmidhī 3895',
    detail: 'Kindness at home. Not a family score, and not filled from Akhlaq.',
  ),
  _item(
    id: 'ph.visiting.sick',
    topic: 'Visiting the sick',
    text: 'When visiting a sick person, a related supplication is:',
    arabic:
        'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
    transliteration:
        'Asʾalu Allāha l-ʿAẓīma, rabba l-ʿarshi l-ʿaẓīm, an yashfiyak.',
    translation:
        'I ask Allah the Magnificent, Lord of the Magnificent Throne, to heal you.',
    source: 'Ṣaḥīḥ al-Bukhārī 5675; Sunan Ibn Mājah 1441',
    detail: 'Care in hardship. Not a sadaqah channel.',
  ),
  _item(
    id: 'ph.rain',
    topic: 'Rain',
    text: 'When it rained, the Prophet ﷺ used to say:',
    arabic: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
    transliteration: 'Allāhumma ṣayyiban nāfiʿā.',
    translation: 'O Allah, make it a beneficial rain.',
    source: 'Ṣaḥīḥ al-Bukhārī 1032',
    detail: 'A rain supplication. Not a weather log.',
  ),
  _item(
    id: 'ph.sneezing',
    topic: 'Sneezing',
    text: 'When one of you sneezes, then the one who hears him, say:',
    arabic: 'الْحَمْدُ لِلَّهِ   يَرْحَمُكَ اللَّهُ   يَهْدِيكُمُ اللَّهُ وَيُصْلِحُ بَالَكُمْ',
    transliteration:
        'Al-ḥamdu lillāh. Yarḥamuk Allāh. Yahdīkumu Allāhu wa yuṣliḥu bālakum.',
    translation:
        'All praise is for Allah. May Allah have mercy on you. May Allah guide you and set your affairs right.',
    source: 'Ṣaḥīḥ al-Bukhārī 6224',
    detail: 'A greeting after a sneeze. Not a manners grade.',
  ),
  _item(
    id: 'ph.anger',
    topic: 'Anger',
    text: 'When anger rises, a related remembrance is:',
    arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    transliteration: 'Aʿūdhu billāhi mina sh-shayṭāni r-rajīm.',
    translation: 'I seek refuge in Allah from the accursed Shaytan.',
    source: 'Ṣaḥīḥ al-Bukhārī 6115; Sunan Abī Dāwūd 4782',
    detail:
        'A way of cooling anger. Character stays on Akhlaq; this is a teaching to remember.',
  ),
  _item(
    id: 'ph.market',
    topic: 'The marketplace',
    text: 'When entering the marketplace, say:',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ حَيٌّ لَا يَمُوتُ، بِيَدِهِ الْخَيْرُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        'Lā ilāha illā Allāh, waḥdahu lā sharīka lah, lahu l-mulku wa lahu l-ḥamd, yuḥyī wa yumīt, wa huwa ḥayyun lā yamūt, bi-yadihi l-khayr, wa huwa ʿalā kulli shayʾin qadīr.',
    translation:
        'There is no god but Allah, alone, without partner. His is the dominion and His is the praise. He gives life and causes death, and He is living and does not die. In His hand is all good, and He is over all things capable.',
    source: 'Jāmiʿ al-Tirmidhī 3428',
    detail: 'A marketplace remembrance. Not a shopping log.',
  ),
  _item(
    id: 'ph.guest',
    topic: 'Hospitality',
    text: 'A teaching about the guest:',
    arabic:
        'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيُكْرِمْ ضَيْفَهُ',
    transliteration:
        'Man kāna yuʾminu billāhi wa l-yawmi l-ākhir fa-l-yukrim ḍayfah.',
    translation:
        'Whoever believes in Allah and the Last Day, let him honour his guest.',
    source: 'Ṣaḥīḥ al-Bukhārī 6018; Ṣaḥīḥ Muslim 47',
    detail: 'Honouring a guest. Not a hosting score.',
  ),
  _item(
    id: 'ph.neighbour',
    topic: 'Neighbours',
    text: 'A teaching about the neighbour:',
    arabic:
        'مَا زَالَ جِبْرِيلُ يُوصِينِي بِالْجَارِ حَتَّىٰ ظَنَنْتُ أَنَّهُ سَيُوَرِّثُهُ',
    transliteration:
        'Mā zāla Jibrīlu yūṣīnī bi-l-jāri ḥattā ẓanantu annahu sa-yuwarrituh.',
    translation:
        'Jibril kept advising me about the neighbour until I thought he would make him an heir.',
    source: 'Ṣaḥīḥ al-Bukhārī 6014; Ṣaḥīḥ Muslim 2624',
    detail: 'Care for neighbours. Rights of others stay on Huquq.',
  ),
  _item(
    id: 'ph.silence',
    topic: 'Speech',
    text: 'A teaching about the tongue:',
    arabic:
        'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    transliteration:
        'Man kāna yuʾminu billāhi wa l-yawmi l-ākhir fa-l-yaqul khayran aw li-yaṣmut.',
    translation:
        'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
    source: 'Ṣaḥīḥ al-Bukhārī 6018; Ṣaḥīḥ Muslim 47',
    detail: 'Guarding speech. Knowledge & Beneficial Speech has its own card.',
  ),
  _item(
    id: 'ph.night.witr',
    topic: 'Night prayer',
    text: 'A teaching about Witr, and a related closing supplication is:',
    arabic:
        'اللَّهُمَّ إِنِّي أَعُوذُ بِرِضَاكَ مِنْ سَخَطِكَ وَبِمُعَافَاتِكَ مِنْ عُقُوبَتِكَ',
    transliteration:
        'Allāhumma innī aʿūdhu bi-riḍāka min sakhaṭik, wa bi-muʿāfātika min ʿuqūbatik.',
    translation:
        'O Allah, I seek refuge in Your pleasure from Your anger, and in Your pardon from Your punishment.',
    source: 'Ṣaḥīḥ al-Bukhārī 998; Ṣaḥīḥ Muslim 751; Ṣaḥīḥ Muslim 486',
    detail: 'A night-prayer teaching. Salah stays on the Salah card.',
  ),
  _item(
    id: 'ph.quran.daily',
    topic: 'Qur’an in the day',
    text: 'A related opening of recitation is:',
    arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ  بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    transliteration:
        'Aʿūdhu billāhi mina sh-shayṭāni r-rajīm. Bismillāhi r-Raḥmāni r-Raḥīm.',
    translation:
        'I seek refuge in Allah from the accursed Shaytan. In the name of Allah, the Most Merciful, the Especially Merciful.',
    source: 'Ṣaḥīḥ al-Bukhārī 4937; Ṣaḥīḥ Muslim 798',
    detail: 'Encouragement to recite. Qur’an Engagement has its own card.',
  ),
  _item(
    id: 'ph.toilet.leave',
    topic: 'Leaving the toilet',
    text: 'When leaving the place of relief, say:',
    arabic: 'غُفْرَانَكَ',
    transliteration: 'Ghufrānak.',
    translation: 'I ask Your forgiveness.',
    source: 'Sunan Abī Dāwūd 30; Jāmiʿ al-Tirmidhī 7',
    detail: 'Leaving, not entering. Not a hygiene checklist.',
  ),
  _item(
    id: 'ph.adhan',
    topic: 'After the adhan',
    text: 'After the call to prayer, say:',
    arabic:
        'اللَّهُمَّ رَبَّ هَٰذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
    transliteration:
        'Allāhumma rabba hādhihi d-daʿwati t-tāmmati wa ṣ-ṣalāti l-qāʾimah, āti Muḥammadani l-wasīlata wa l-faḍīlah, wa bʿath-hu maqāman maḥmūdan alladhī waʿadtah.',
    translation:
        'O Allah, Lord of this complete call and of the prayer about to be established, grant Muhammad the wasilah and virtue, and raise him to the praised station You promised him.',
    source: 'Ṣaḥīḥ al-Bukhārī 614',
    detail: 'After the adhan. Salah stays on the Salah card.',
  ),
  _item(
    id: 'ph.after.salah.kursi',
    topic: 'Ayat al-Kursi after prayer',
    text: 'After the prescribed prayer, a related recitation is:',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration:
        'Allāhu lā ilāha illā huwa l-Ḥayyu l-Qayyūm. Lā taʾkhudhuhu sinatun wa lā nawm. Lahu mā fī s-samāwāti wa mā fī l-arḍ. Man dhā alladhī yashfaʿu ʿindahu illā bi-idhnih. Yaʿlamu mā bayna aydīhim wa mā khalfahum, wa lā yuḥīṭūna bi-shayʾin min ʿilmihi illā bimā shāʾ. Wasiʿa kursiyyuhu s-samāwāti wa l-arḍ, wa lā yaʾūduhu ḥifẓuhumā, wa huwa l-ʿAliyyu l-ʿAẓīm.',
    translation:
        'Allah — there is no god but He, the Ever-Living, the Self-Subsisting. Neither drowsiness nor sleep overtakes Him. To Him belongs what is in the heavens and what is on the earth. Who can intercede with Him except by His permission? He knows what is before them and what is behind them, and they encompass nothing of His knowledge except what He wills. His Kursi extends over the heavens and the earth, and their preservation does not tire Him. He is the Most High, the Magnificent.',
    source: 'Qur’an 2:255; Sunan an-Nasāʾī 7280',
    detail:
        'Ayat al-Kursi after salah, not the thirty-three tasbih. Qur’an Engagement has its own card.',
  ),
  _item(
    id: 'ph.istighfar.sayyid',
    topic: 'Sayyid al-istighfar',
    text: 'The chief form of seeking forgiveness is:',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration:
        'Allāhumma anta rabbī, lā ilāha illā ant, khalaqtanī wa anā ʿabduk, wa anā ʿalā ʿahdika wa waʿdika mā staṭaʿt. Aʿūdhu bika min sharri mā ṣanaʿt, abūʾu laka bi-niʿmatika ʿalayya, wa abūʾu bi-dhanbī, fa-ghfir lī, fa-innahu lā yaghfiru dh-dhunūba illā ant.',
    translation:
        'O Allah, You are my Lord. There is no god but You. You created me and I am Your servant. I am upon Your covenant and promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge Your favour upon me, and I acknowledge my sin, so forgive me, for none forgives sins except You.',
    source: 'Ṣaḥīḥ al-Bukhārī 6306',
    detail: 'The longer form. The short istighfar stays its own row.',
  ),
  _item(
    id: 'ph.majlis',
    topic: 'Leaving a gathering',
    text: 'When rising from a gathering, say:',
    arabic:
        'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    transliteration:
        'Subḥānaka Allāhumma wa bi-ḥamdik, ashhadu an lā ilāha illā ant, astaghfiruka wa atūbu ilayk.',
    translation:
        'Glory and praise be to You, O Allah. I bear witness that there is no god but You. I seek Your forgiveness and turn to You in repentance.',
    source: 'Jāmiʿ al-Tirmidhī 3433',
    detail: 'Kaffārat al-majlis. Not a speech score.',
  ),
  _item(
    id: 'ph.calamity',
    topic: 'When a calamity strikes',
    text: 'When a calamity befalls you, say:',
    arabic:
        'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا',
    transliteration:
        'Innā lillāhi wa innā ilayhi rājiʿūn. Allāhumma ʾjurnī fī muṣībatī wa akhlif lī khayran minhā.',
    translation:
        'We belong to Allah and to Him we return. O Allah, reward me in my calamity and replace it with something better.',
    source: 'Ṣaḥīḥ Muslim 918',
    detail: 'A response to loss. Not a hardship score.',
  ),
  _item(
    id: 'ph.distress.yunus',
    topic: 'In distress',
    text: 'The supplication of Yunus, peace be upon him, in hardship:',
    arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    transliteration:
        'Lā ilāha illā anta, subḥānaka, innī kuntu mina ẓ-ẓālimīn.',
    translation:
        'There is no god but You. Glory be to You. I have been among the wrongdoers.',
    source: 'Jāmiʿ al-Tirmidhī 3505; Qur’an 21:87',
    detail: 'A distress remembrance. Not a mood tracker.',
  ),
  _item(
    id: 'ph.protection.words',
    topic: 'Protection in the day',
    text: 'In the morning or evening, or when stopping in a place, say:',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration:
        'Aʿūdhu bi-kalimāti llāhi t-tāmmāti min sharri mā khalaq.',
    translation:
        'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    source: 'Ṣaḥīḥ Muslim 2708',
    detail:
        'Protection by Allah’s words. Distinct from seeking refuge from Shaytan when angry.',
  ),
  _item(
    id: 'ph.iftar',
    topic: 'Breaking the fast',
    text: 'When breaking the fast, say:',
    arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
    transliteration:
        'Dhahaba ẓ-ẓamaʾu wa btalati l-ʿurūqu wa thabata l-ajru in shāʾ Allāh.',
    translation:
        'The thirst is gone, the veins are moist, and the reward is confirmed, if Allah wills.',
    source: 'Sunan Abī Dāwūd 2357',
    detail: 'Iftar. Fasting has its own domain.',
  ),
  _item(
    id: 'ph.newmoon',
    topic: 'The new moon',
    text: 'When seeing the new moon, say:',
    arabic:
        'اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالْيُمْنِ وَالْإِيمَانِ وَالسَّلَامَةِ وَالْإِسْلَامِ، رَبِّي وَرَبُّكَ اللَّهُ',
    transliteration:
        'Allāhumma ahillahu ʿalaynā bi-l-yumni wa l-īmāni wa s-salāmati wa l-islām. Rabbī wa rabbuka Allāh.',
    translation:
        'O Allah, bring it over us with blessing, faith, safety, and Islam. My Lord and your Lord is Allah.',
    source: 'Jāmiʿ al-Tirmidhī 3451',
    detail: 'Sighting the crescent. Not a calendar engine.',
  ),
  _item(
    id: 'ph.wind',
    topic: 'When the wind blows',
    text: 'When the wind blows, say:',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ مَا فِيهَا وَخَيْرَ مَا أُرْسِلَتْ بِهِ وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ مَا فِيهَا وَشَرِّ مَا أُرْسِلَتْ بِهِ',
    transliteration:
        'Allāhumma innī asʾaluka khayrahā wa khayra mā fīhā wa khayra mā ursilat bih, wa aʿūdhu bika min sharrihā wa sharri mā fīhā wa sharri mā ursilat bih.',
    translation:
        'O Allah, I ask You for its good, the good in it, and the good it was sent with, and I seek refuge in You from its evil, the evil in it, and the evil it was sent with.',
    source: 'Ṣaḥīḥ Muslim 899',
    detail: 'Wind, not the rain supplication already listed.',
  ),
  _item(
    id: 'ph.rain.received',
    topic: 'After rain',
    text: 'After rain has fallen, say:',
    arabic: 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
    transliteration: 'Muṭirnā bi-faḍli llāhi wa raḥmatih.',
    translation: 'We have been given rain by the bounty of Allah and His mercy.',
    source: 'Ṣaḥīḥ al-Bukhārī 846',
    detail: 'Gratitude after rain. Distinct from asking for beneficial rain.',
  ),
  _item(
    id: 'ph.travel.return',
    topic: 'Returning from travel',
    text: 'When returning from a journey, say:',
    arabic: 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
    transliteration: 'Āyibūna, tāʾibūna, ʿābidūna, li-rabbinā ḥāmidūn.',
    translation:
        'We return, repenting, worshipping, and praising our Lord.',
    source: 'Ṣaḥīḥ al-Bukhārī 3085; Ṣaḥīḥ Muslim 1344',
    detail: 'Return, not the mounting dua already listed.',
  ),
  _item(
    id: 'ph.graves',
    topic: 'Visiting graves',
    text: 'When visiting the graves, say:',
    arabic:
        'السَّلَامُ عَلَيْكُمْ أَهْلَ الدِّيَارِ مِنَ الْمُؤْمِنِينَ وَالْمُسْلِمِينَ وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَاحِقُونَ أَسْأَلُ اللَّهَ لَنَا وَلَكُمُ الْعَافِيَةَ',
    transliteration:
        'As-salāmu ʿalaykum ahla d-diyāri mina l-muʾminīna wa l-muslimīn, wa innā in shāʾ Allāhu bikum lāḥiqūn. Asʾalu Allāha lanā wa lakumu l-ʿāfiyah.',
    translation:
        'Peace be upon you, people of these dwellings, believers and Muslims. We will, if Allah wills, join you. I ask Allah for well-being for us and for you.',
    source: 'Ṣaḥīḥ Muslim 975',
    detail: 'A greeting at the graves. Not a funeral score.',
  ),
  _item(
    id: 'ph.affliction.seen',
    topic: 'Seeing someone in affliction',
    text: 'When you see a person in affliction, say:',
    arabic:
        'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلَاكَ بِهِ وَفَضَّلَنِي عَلَىٰ كَثِيرٍ مِمَّنْ خَلَقَ تَفْضِيلًا',
    transliteration:
        'Al-ḥamdu lillāhi alladhī ʿāfānī mimmā btalāka bih, wa faḍḍalanī ʿalā kathīrin mimman khalaqa tafḍīlā.',
    translation:
        'All praise is for Allah who spared me from what He has tested you with, and favoured me greatly over many of those He created.',
    source: 'Jāmiʿ al-Tirmidhī 3432',
    detail: 'Said quietly, not as a taunt. Not a comparison score.',
  ),
  _item(
    id: 'ph.knowledge.fajr',
    topic: 'Beneficial knowledge',
    text: 'After the Fajr prayer, a related supplication is:',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
    transliteration:
        'Allāhumma innī asʾaluka ʿilman nāfiʿā, wa rizqan ṭayyibā, wa ʿamalan mutaqabbalā.',
    translation:
        'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.',
    source: 'Sunan Ibn Mājah 925',
    detail:
        'Knowledge as a dua. Knowledge & Beneficial Speech has its own card.',
  ),
  _item(
    id: 'ph.istikhara',
    topic: 'Istikhara',
    text: 'When seeking Allah’s choice in a matter, pray two rakʿahs then say:',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ وَتَعْلَمُ وَلَا أَعْلَمُ وَأَنْتَ عَلَّامُ الْغُيُوبِ، اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَٰذَا الْأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ، وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَٰذَا الْأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاصْرِفْهُ عَنِّي وَاصْرِفْنِي عَنْهُ وَاقْدُرْ لِيَ الْخَيْرَ حَيْثُ كَانَ ثُمَّ أَرْضِنِي بِهِ',
    transliteration:
        'Allāhumma innī astakhīruka bi-ʿilmik, wa astaqdiruka bi-qudratik, wa asʾaluka min faḍlika l-ʿaẓīm, fa-innaka taqdiru wa lā aqdir, wa taʿlamu wa lā aʿlam, wa anta ʿallāmu l-ghuyūb. Allāhumma in kunta taʿlamu anna hādhā l-amra khayrun lī fī dīnī wa maʿāshī wa ʿāqibati amrī, fa-qdurhu lī wa yassirhu lī thumma bārik lī fīh. Wa in kunta taʿlamu anna hādhā l-amra sharrun lī fī dīnī wa maʿāshī wa ʿāqibati amrī, fa-ṣrifhu ʿannī wa ṣrifnī ʿanhu, wa qdur liya l-khayra ḥaythu kān, thumma arḍinī bih.',
    translation:
        'O Allah, I seek Your choice by Your knowledge, I seek ability by Your power, and I ask You from Your great bounty. You are able and I am not; You know and I do not; You are the Knower of the unseen. O Allah, if You know this matter to be good for me in my religion, my living, and the outcome of my affair, then decree it for me, make it easy, and bless me in it. And if You know it to be bad for me in my religion, my living, and the outcome of my affair, then turn it away from me and turn me away from it, decree good for me wherever it is, and make me pleased with it.',
    source: 'Ṣaḥīḥ al-Bukhārī 1166',
    detail: 'A choice sought from Allah. Not a decision engine or omen.',
  ),
  _item(
    id: 'ph.intimacy',
    topic: 'Before intimacy',
    text: 'When approaching one’s spouse, say:',
    arabic:
        'بِسْمِ اللَّهِ، اللَّهُمَّ جَنِّبْنَا الشَّيْطَانَ وَجَنِّبِ الشَّيْطَانَ مَا رَزَقْتَنَا',
    transliteration:
        'Bismillāh. Allāhumma jannibna sh-shayṭān, wa jannibi sh-shayṭāna mā razaqtanā.',
    translation:
        'In the name of Allah. O Allah, keep Shaytan away from us and keep Shaytan away from what You provide us.',
    source: 'Ṣaḥīḥ al-Bukhārī 141; Ṣaḥīḥ Muslim 1434',
    detail: 'A private supplication. Not a family log.',
  ),
  _item(
    id: 'ph.hasbunallah',
    topic: 'When relying on Allah',
    text: 'When facing a matter with reliance, say:',
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Ḥasbunā Allāhu wa niʿma l-wakīl.',
    translation: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
    source: 'Ṣaḥīḥ al-Bukhārī 4563; Qur’an 3:173',
    detail: 'Reliance. Distinct from leaving-home tawakkul.',
  ),
  _item(
    id: 'ph.host.food',
    topic: 'For the one who fed you',
    text: 'When someone feeds you, say:',
    arabic: 'اللَّهُمَّ أَطْعِمْ مَنْ أَطْعَمَنِي وَاسْقِ مَنْ سَقَانِي',
    transliteration: 'Allāhumma aṭʿim man aṭʿamanī, wa sqi man saqānī.',
    translation: 'O Allah, feed the one who fed me, and give drink to the one who gave me drink.',
    source: 'Ṣaḥīḥ Muslim 2055',
    detail: 'A dua for the host. Distinct from thanks after one’s own meal.',
  ),
];

PracticeHadithItem? practiceHadithById(String id) {
  for (final item in kPracticeHadithCatalog) {
    if (item.id == id) return item;
  }
  return null;
}

List<PracticeHadithItem> practiceHadithLearnList([
  List<PracticeHadithItem> extra = const [],
]) {
  return [...kPracticeHadithCatalog, ...extra];
}

PracticeHadithItem practiceHadithAt(
  int index, [
  List<PracticeHadithItem> extra = const [],
]) {
  final list = practiceHadithLearnList(extra);
  return list[wrapPracticeHadithIndex(index, list.length)];
}

({String arabic, String transliteration, String translation, String text})
practiceHadithCore(PracticeHadithRecord record) {
  final item = practiceHadithById(record.catalogId);
  return (
    arabic: record.arabic.isNotEmpty ? record.arabic : item?.arabic ?? '',
    transliteration: record.transliteration.isNotEmpty
        ? record.transliteration
        : item?.transliteration ?? '',
    translation: record.translation.isNotEmpty
        ? record.translation
        : item?.translation ?? '',
    text: record.content.isNotEmpty ? record.content : item?.text ?? '',
  );
}
