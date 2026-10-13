import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';
import 'salah_extras.dart';

const kPracticeSalahGroups = [
  kSalahObligatoryBand,
  kSalahFridayBand,
  kSalahVoluntaryBand,
];

/// Qur’an and authentic hadith that encourage Salah Home rows.
/// Presence of heart is not scored. Unanswered is not missed.
final List<PracticeDhikrItem> kPracticeSalahCatalog = [
  _item(
    id: 'sl.obligatory.fajr',
    group: kSalahObligatoryBand,
    topic: 'Fajr',
    text: 'Establish the prayer, and the recitation of dawn:',
    arabic:
        'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ وَقُرْآنَ الْفَجْرِ ۖ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
    transliteration:
        'Aqimi ṣ-ṣalāta li-dulūki sh-shamsi ilā ghasaqi l-layli wa-qur’āna l-fajr. Inna qur’āna l-fajri kāna mashhūdā.',
    translation:
        'Establish prayer at the decline of the sun until the darkness of the night, and the recitation of dawn. The recitation of dawn is witnessed.',
    source: 'Qur’an 17:78',
    detail:
        'A Fajr sitting you recorded. Unanswered is not missed. Not a khushu’ score.',
  ),
  _item(
    id: 'sl.obligatory.fajr.20_130',
    group: kSalahObligatoryBand,
    topic: 'Fajr',
    text: 'Glorify your Lord before the rising of the sun:',
    arabic: 'وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا',
    transliteration:
        'Wa-sabbiḥ bi-ḥamdi rabbika qabla ṭulūʿi sh-shamsi wa-qabla ghurūbihā.',
    translation:
        'And glorify the praise of your Lord before the rising of the sun and before its setting.',
    source: 'Qur’an 20:130',
    detail:
        'A Fajr sitting you recorded. Unanswered is not missed. Not a khushu’ score.',
  ),
  _item(
    id: 'sl.obligatory.fajr.11_114',
    group: kSalahObligatoryBand,
    topic: 'Fajr',
    text: 'Establish prayer at the two ends of the day:',
    arabic: 'وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ',
    transliteration:
        'Wa-aqimi ṣ-ṣalāta ṭarafayi n-nahāri wa-zulafan mina l-layl.',
    translation:
        'Establish prayer at the two ends of the day and in the early hours of the night.',
    source: 'Qur’an 11:114',
    detail:
        'A Fajr sitting you recorded. Colour names the choice. Not a congregation requirement.',
  ),
  _item(
    id: 'sl.obligatory.fajr.muslim_656',
    group: kSalahObligatoryBand,
    topic: 'Fajr',
    text: 'The Messenger of Allah ﷺ said of the two rak‘ahs of Fajr:',
    arabic: 'رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا',
    transliteration: 'Rakʿatā l-fajri khayrun mina d-dunyā wa-mā fīhā.',
    translation: 'The two rak‘ahs of Fajr are better than the world and what is in it.',
    source: 'Ṣaḥīḥ Muslim 725',
    detail:
        'A Fajr sitting you recorded. This is not a sunnah-quota or a daily grade.',
  ),
  _item(
    id: 'sl.obligatory.dhuhr',
    group: kSalahObligatoryBand,
    topic: 'Dhuhr',
    text: 'Praise in the heavens and the earth, and at midday:',
    arabic:
        'وَلَهُ الْحَمْدُ فِي السَّمَاوَاتِ وَالْأَرْضِ وَعَشِيًّا وَحِينَ تُظْهِرُونَ',
    transliteration:
        'Wa-lahu l-ḥamdu fī s-samāwāti wa-l-arḍi wa-ʿashiyyan wa-ḥīna tuẓhirūn.',
    translation:
        'To Him belongs praise in the heavens and the earth, and at nightfall, and when you are at midday.',
    source: 'Qur’an 30:18',
    detail:
        'A Dhuhr sitting you recorded. Colour names the choice. Not a congregation requirement.',
  ),
  _item(
    id: 'sl.obligatory.dhuhr.17_78',
    group: kSalahObligatoryBand,
    topic: 'Dhuhr',
    text: 'Establish the prayer at the decline of the sun:',
    arabic:
        'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ',
    transliteration: 'Aqimi ṣ-ṣalāta li-dulūki sh-shamsi ilā ghasaqi l-layl.',
    translation:
        'Establish prayer at the decline of the sun until the darkness of the night.',
    source: 'Qur’an 17:78',
    detail:
        'A Dhuhr sitting you recorded. Unanswered is not missed. Not a khushu’ score.',
  ),
  _item(
    id: 'sl.obligatory.dhuhr.30_17',
    group: kSalahObligatoryBand,
    topic: 'Dhuhr',
    text: 'Glory to Allah when you enter the evening and the morning:',
    arabic: 'فَسُبْحَانَ اللَّهِ حِينَ تُمْسُونَ وَحِينَ تُصْبِحُونَ',
    transliteration: 'Fa-subḥāna llāhi ḥīna tumsūna wa-ḥīna tuṣbiḥūn.',
    translation: 'So glory to Allah when you reach the evening and when you reach the morning.',
    source: 'Qur’an 30:17',
    detail:
        'A Dhuhr sitting you recorded. Colour names the choice. Not a congregation requirement.',
  ),
  _item(
    id: 'sl.obligatory.dhuhr.bukhari_541',
    group: kSalahObligatoryBand,
    topic: 'Dhuhr',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'صَلِّ الصَّلَاةَ لِوَقْتِهَا',
    transliteration: 'Ṣalli ṣ-ṣalāta li-waqtihā.',
    translation: 'Pray the prayer at its time.',
    source: 'Ṣaḥīḥ al-Bukhārī 527',
    detail:
        'A Dhuhr sitting you recorded. Unanswered is not missed. Not a punctuality score.',
  ),
  _item(
    id: 'sl.obligatory.asr',
    group: kSalahObligatoryBand,
    topic: 'Asr',
    text: 'Guard the prayers, and the middle prayer:',
    arabic:
        'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ',
    transliteration:
        'Ḥāfiẓū ʿalā ṣ-ṣalawāti wa-ṣ-ṣalāti l-wusṭā wa-qūmū li-llāhi qānitīn.',
    translation:
        'Guard the prayers, and the middle prayer, and stand before Allah devoutly obedient.',
    source: 'Qur’an 2:238',
    detail:
        'An Asr sitting you recorded. Unanswered is not missed. Presence of heart is not graded.',
  ),
  _item(
    id: 'sl.obligatory.asr.20_130',
    group: kSalahObligatoryBand,
    topic: 'Asr',
    text: 'Glorify your Lord before the setting of the sun:',
    arabic: 'وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا',
    transliteration:
        'Wa-sabbiḥ bi-ḥamdi rabbika qabla ṭulūʿi sh-shamsi wa-qabla ghurūbihā.',
    translation:
        'And glorify the praise of your Lord before the rising of the sun and before its setting.',
    source: 'Qur’an 20:130',
    detail:
        'An Asr sitting you recorded. Unanswered is not missed. Not a khushu’ score.',
  ),
  _item(
    id: 'sl.obligatory.asr.50_39',
    group: kSalahObligatoryBand,
    topic: 'Asr',
    text: 'Be patient, and glorify before sunrise and before sunset:',
    arabic:
        'فَاصْبِرْ عَلَىٰ مَا يَقُولُونَ وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ الْغُرُوبِ',
    transliteration:
        'Fa-ṣbir ʿalā mā yaqūlūna wa-sabbiḥ bi-ḥamdi rabbika qabla ṭulūʿi sh-shamsi wa-qabla l-ghurūb.',
    translation:
        'So be patient over what they say, and glorify the praise of your Lord before the rising of the sun and before its setting.',
    source: 'Qur’an 50:39',
    detail:
        'An Asr sitting you recorded. Presence of heart is not graded.',
  ),
  _item(
    id: 'sl.obligatory.asr.4_103',
    group: kSalahObligatoryBand,
    topic: 'Asr',
    text: 'The prayer is a timed duty:',
    arabic: 'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
    transliteration: 'Inna ṣ-ṣalāta kānat ʿalā l-muʾminīna kitāban mawqūtā.',
    translation: 'Indeed, the prayer is a timed obligation upon the believers.',
    source: 'Qur’an 4:103',
    detail:
        'An Asr sitting you recorded. Unanswered is not missed. Presence of heart is not graded.',
  ),
  _item(
    id: 'sl.obligatory.maghrib',
    group: kSalahObligatoryBand,
    topic: 'Maghrib',
    text: 'Establish prayer at the two ends of the day, and in the night:',
    arabic:
        'وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ',
    transliteration:
        'Wa-aqimi ṣ-ṣalāta ṭarafayi n-nahāri wa-zulafan mina l-layl.',
    translation:
        'Establish prayer at the two ends of the day and in the early hours of the night.',
    source: 'Qur’an 11:114',
    detail:
        'A Maghrib sitting you recorded. Not a makeup prescription. Unanswered is not missed.',
  ),
  _item(
    id: 'sl.obligatory.maghrib.17_78',
    group: kSalahObligatoryBand,
    topic: 'Maghrib',
    text: 'Until the darkness of the night:',
    arabic: 'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ',
    transliteration: 'Aqimi ṣ-ṣalāta li-dulūki sh-shamsi ilā ghasaqi l-layl.',
    translation:
        'Establish prayer at the decline of the sun until the darkness of the night.',
    source: 'Qur’an 17:78',
    detail:
        'A Maghrib sitting you recorded. Unanswered is not missed. Not a khushu’ score.',
  ),
  _item(
    id: 'sl.obligatory.maghrib.20_130',
    group: kSalahObligatoryBand,
    topic: 'Maghrib',
    text: 'Glorify your Lord at the ends of the day:',
    arabic:
        'وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا',
    transliteration:
        'Wa-sabbiḥ bi-ḥamdi rabbika qabla ṭulūʿi sh-shamsi wa-qabla ghurūbihā.',
    translation:
        'And glorify the praise of your Lord before the rising of the sun and before its setting.',
    source: 'Qur’an 20:130',
    detail:
        'A Maghrib sitting you recorded. Colour names the choice. Not a congregation requirement.',
  ),
  _item(
    id: 'sl.obligatory.maghrib.30_17',
    group: kSalahObligatoryBand,
    topic: 'Maghrib',
    text: 'Glory to Allah when you enter the evening:',
    arabic: 'فَسُبْحَانَ اللَّهِ حِينَ تُمْسُونَ وَحِينَ تُصْبِحُونَ',
    transliteration: 'Fa-subḥāna llāhi ḥīna tumsūna wa-ḥīna tuṣbiḥūn.',
    translation: 'So glory to Allah when you reach the evening and when you reach the morning.',
    source: 'Qur’an 30:17',
    detail:
        'A Maghrib sitting you recorded. Unanswered is not missed.',
  ),
  _item(
    id: 'sl.obligatory.isha',
    group: kSalahObligatoryBand,
    topic: 'Isha',
    text: 'After the night prayer is named among the times of privacy:',
    arabic: 'وَمِن بَعْدِ صَلَاةِ الْعِشَاءِ',
    transliteration: 'Wa-min baʿdi ṣalāti l-ʿishā’.',
    translation: 'And after the night prayer.',
    source: 'Qur’an 24:58',
    detail:
        'An Isha sitting you recorded. Unanswered is not missed. Not a congregation score.',
  ),
  _item(
    id: 'sl.obligatory.isha.17_78',
    group: kSalahObligatoryBand,
    topic: 'Isha',
    text: 'Until the darkness of the night:',
    arabic: 'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ',
    transliteration: 'Aqimi ṣ-ṣalāta li-dulūki sh-shamsi ilā ghasaqi l-layl.',
    translation:
        'Establish prayer at the decline of the sun until the darkness of the night.',
    source: 'Qur’an 17:78',
    detail:
        'An Isha sitting you recorded. Unanswered is not missed. Not a khushu’ score.',
  ),
  _item(
    id: 'sl.obligatory.isha.11_114',
    group: kSalahObligatoryBand,
    topic: 'Isha',
    text: 'And in the early hours of the night:',
    arabic: 'وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ',
    transliteration:
        'Wa-aqimi ṣ-ṣalāta ṭarafayi n-nahāri wa-zulafan mina l-layl.',
    translation:
        'Establish prayer at the two ends of the day and in the early hours of the night.',
    source: 'Qur’an 11:114',
    detail:
        'An Isha sitting you recorded. Colour names the choice. Not a congregation requirement.',
  ),
  _item(
    id: 'sl.obligatory.isha.17_79',
    group: kSalahObligatoryBand,
    topic: 'Isha',
    text: 'And from the night, keep vigil with it as extra:',
    arabic: 'وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَّكَ',
    transliteration: 'Wa-mina l-layli fa-tahajjad bihi nāfilatan lak.',
    translation: 'And from the night, pray with it as extra for you.',
    source: 'Qur’an 17:79',
    detail:
        'An Isha sitting you recorded. Night extra stays on Tahajjud. Unanswered is not missed.',
  ),
  _item(
    id: 'sl.friday.jumuah',
    group: kSalahFridayBand,
    topic: 'Jumu‘ah',
    text: 'When the call is made for prayer on Friday:',
    arabic:
        'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا نُودِيَ لِلصَّلَاةِ مِن يَوْمِ الْجُمُعَةِ فَاسْعَوْا إِلَىٰ ذِكْرِ اللَّهِ',
    transliteration:
        'Yā ayyuhā lladhīna āmanū idhā nūdiya li-ṣ-ṣalāti min yawmi l-jumuʿati fa-sʿaw ilā dhikri llāh.',
    translation:
        'O you who believe, when the call is made for prayer on Friday, hasten to the remembrance of Allah.',
    source: 'Qur’an 62:9',
    detail:
        'Friday-only on the week. Other days are blank, not unanswered. Not Ummah’s masjid class.',
  ),
  _item(
    id: 'sl.friday.jumuah.62_10',
    group: kSalahFridayBand,
    topic: 'Jumu‘ah',
    text: 'When the prayer is finished, spread through the land:',
    arabic:
        'فَإِذَا قُضِيَتِ الصَّلَاةُ فَانتَشِرُوا فِي الْأَرْضِ وَابْتَغُوا مِن فَضْلِ اللَّهِ',
    transliteration:
        'Fa-idhā quḍiyati ṣ-ṣalātu fa-ntashirū fī l-arḍi wa-btaghū min faḍli llāh.',
    translation:
        'And when the prayer has been concluded, disperse in the land and seek of Allah’s bounty.',
    source: 'Qur’an 62:10',
    detail:
        'Friday-only on the week. Other days are blank, not unanswered. Not a work-hour badge.',
  ),
  _item(
    id: 'sl.friday.jumuah.62_11',
    group: kSalahFridayBand,
    topic: 'Jumu‘ah',
    text: 'When they see trade or diversion they break away to it:',
    arabic:
        'وَإِذَا رَأَوْا تِجَارَةً أَوْ لَهْوًا انفَضُّوا إِلَيْهَا وَتَرَكُوكَ قَائِمًا',
    transliteration:
        'Wa-idhā raʾaw tijāratan aw lahwan infaḍḍū ilayhā wa-tarakūka qāʾimā.',
    translation:
        'But when they see a transaction or a diversion, they break away to it and leave you standing.',
    source: 'Qur’an 62:11',
    detail:
        'Friday-only on the week. This is not a shop-closing score.',
  ),
  _item(
    id: 'sl.friday.jumuah.bukhari_877',
    group: kSalahFridayBand,
    topic: 'Jumu‘ah',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'إِذَا جَاءَ أَحَدُكُمُ الْجُمُعَةَ فَلْيَغْتَسِلْ',
    transliteration: 'Idhā jāʾa aḥadukumu l-jumuʿata fal-yaghtasil.',
    translation: 'When one of you comes to Jumu‘ah, let him take a ghusl.',
    source: 'Ṣaḥīḥ al-Bukhārī 877',
    detail:
        'Friday-only on the week. Not Ummah’s masjid class, and not a purity score.',
  ),
  _item(
    id: 'sl.voluntary.tahajjud',
    group: kSalahVoluntaryBand,
    topic: 'Tahajjud',
    text: 'And from the night, keep vigil with it as extra:',
    arabic: 'وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَّكَ',
    transliteration: 'Wa-mina l-layli fa-tahajjad bihi nāfilatan lak.',
    translation:
        'And from the night, pray with it as extra for you.',
    source: 'Qur’an 17:79',
    detail:
        'A night extra you noticed. Unanswered is not missed. Not a missed-red row.',
  ),
  _item(
    id: 'sl.voluntary.tahajjud.73_2',
    group: kSalahVoluntaryBand,
    topic: 'Tahajjud',
    text: 'Stand the night, except a little:',
    arabic: 'قُمِ اللَّيْلَ إِلَّا قَلِيلًا',
    transliteration: 'Qumi l-layla illā qalīlā.',
    translation: 'Stand the night, except a little.',
    source: 'Qur’an 73:2',
    detail:
        'A night extra you noticed. Unanswered is not missed. Not a missed-red row.',
  ),
  _item(
    id: 'sl.voluntary.tahajjud.32_16',
    group: kSalahVoluntaryBand,
    topic: 'Tahajjud',
    text: 'Their sides forsake their beds:',
    arabic:
        'تَتَجَافَىٰ جُنُوبُهُمْ عَنِ الْمَضَاجِعِ يَدْعُونَ رَبَّهُمْ خَوْفًا وَطَمَعًا',
    transliteration:
        'Tatajāfā junūbuhum ʿani l-maḍājiʿi yadʿūna rabbahum khawfan wa-ṭamaʿā.',
    translation:
        'Their sides forsake their beds as they call upon their Lord, in fear and hope.',
    source: 'Qur’an 32:16',
    detail:
        'A night extra you noticed. Unanswered is not missed. Not a revival programme.',
  ),
  _item(
    id: 'sl.voluntary.tahajjud.25_64',
    group: kSalahVoluntaryBand,
    topic: 'Tahajjud',
    text: 'Those who spend the night before their Lord:',
    arabic: 'وَالَّذِينَ يَبِيتُونَ لِرَبِّهِمْ سُجَّدًا وَقِيَامًا',
    transliteration: 'Wa-lladhīna yabītūna li-rabbihim sujjadan wa-qiyāmā.',
    translation:
        'And those who spend the night before their Lord, prostrating and standing.',
    source: 'Qur’an 25:64',
    detail:
        'A night extra you noticed. Unanswered is not missed.',
  ),
  _item(
    id: 'sl.voluntary.ishraq',
    group: kSalahVoluntaryBand,
    topic: 'Ishraq',
    text: 'The Messenger of Allah ﷺ said that two rak‘ahs of Duha suffice as charity from the joints:',
    arabic: 'وَيُجْزِئُ مِنْ ذَلِكَ رَكْعَتَانِ يَرْكَعُهُمَا مِنَ الضُّحَى',
    transliteration:
        'Wa-yujzi’u min dhālika rakʿatāni yarkaʿuhumā mina ḍ-ḍuḥā.',
    translation: 'Two rak‘ahs which one prays in the forenoon suffice for that.',
    source: 'Ṣaḥīḥ Muslim 720',
    detail:
        'A morning extra you noticed. Unanswered is not missed. Not the fard of Dhuhr.',
  ),
  _item(
    id: 'sl.voluntary.ishraq.93_1',
    group: kSalahVoluntaryBand,
    topic: 'Ishraq',
    text: 'By the morning brightness:',
    arabic: 'وَالضُّحَىٰ وَاللَّيْلِ إِذَا سَجَىٰ',
    transliteration: 'Wa-ḍ-ḍuḥā wa-l-layli idhā sajā.',
    translation: 'By the morning brightness, and the night when it grows still.',
    source: 'Qur’an 93:1–2',
    detail:
        'A morning extra you noticed. Unanswered is not missed. Not the fard of Dhuhr.',
  ),
  _item(
    id: 'sl.voluntary.ishraq.tirmidhi_478',
    group: kSalahVoluntaryBand,
    topic: 'Ishraq',
    text: 'The Messenger of Allah ﷺ said:',
    arabic:
        'مَنْ صَلَّى الْفَجْرَ فِي جَمَاعَةٍ ثُمَّ قَعَدَ يَذْكُرُ اللَّهَ حَتَّى تَطْلُعَ الشَّمْسُ ثُمَّ صَلَّى رَكْعَتَيْنِ كَانَتْ لَهُ كَأَجْرِ حَجَّةٍ وَعُمْرَةٍ',
    transliteration:
        'Man ṣallā l-fajra fī jamāʿatin thumma qaʿada yadhkurullāha ḥattā taṭluʿa sh-shamsu thumma ṣallā rakʿatayni kānat lahu ka-ajri ḥajjatin wa-ʿumrah.',
    translation:
        'Whoever prays Fajr in congregation, then sits remembering Allah until the sun rises, then prays two rak‘ahs, it is for him like the reward of Hajj and Umrah.',
    source: 'Jāmiʿ al-Tirmidhī 586',
    detail:
        'A morning extra you noticed. Unanswered is not missed. Not a Hajj score, and not the fard of Dhuhr.',
  ),
  _item(
    id: 'sl.voluntary.ishraq.20_130',
    group: kSalahVoluntaryBand,
    topic: 'Ishraq',
    text: 'And in the hours of the night, glorify, and at the ends of the day:',
    arabic: 'وَمِنْ آنَاءِ اللَّيْلِ فَسَبِّحْ وَأَطْرَافَ النَّهَارِ لَعَلَّكَ تَرْضَىٰ',
    transliteration:
        'Wa-min ānāʾi l-layli fa-sabbiḥ wa-aṭrāfa n-nahāri laʿallaka tarḍā.',
    translation:
        'And in the hours of the night glorify, and at the ends of the day, that you may be satisfied.',
    source: 'Qur’an 20:130',
    detail:
        'A morning extra you noticed. Unanswered is not missed.',
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

PracticeHadithRecord recordFromSalahCatalog({
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
    domain: MonitorDomain.salah,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
