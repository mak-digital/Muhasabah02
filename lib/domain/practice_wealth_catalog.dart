import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kWealthGroupEarning = 'Earning';
const kWealthGroupRestraint = 'Restraint';
const kWealthGroupManagement = 'Lawful wealth management';

const kPracticeWealthGroups = [
  kWealthGroupEarning,
  kWealthGroupRestraint,
  kWealthGroupManagement,
];

/// Qur’an and authentic hadith that encourage Wealth Home rows.
/// Earning as a trust — not net worth, giving, or a zakat calculator.
final List<PracticeDhikrItem> kPracticeWealthCatalog = [
  _item(
    id: 'wl.earning.halal',
    group: kWealthGroupEarning,
    topic: 'Earned from a halal source',
    text: 'Eat of what Allah has provided, lawful and good:',
    arabic: 'وَكُلُوا مِمَّا رَزَقَكُمُ اللَّهُ حَلَالًا طَيِّبًا',
    transliteration: 'Wa-kulū mimmā razaqakumu llāhu ḥalālan ṭayyibā.',
    translation: 'And eat of what Allah has provided you, lawful and good.',
    source: 'Qur’an 5:88',
    detail: 'A halal source you noticed. Amounts are not recorded. Poverty is not a failing.',
  ),
  _item(
    id: 'wl.earning.halal.2_168',
    group: kWealthGroupEarning,
    topic: 'Earned from a halal source',
    text: 'Eat of what is on the earth, lawful and good:',
    arabic:
        'يَا أَيُّهَا النَّاسُ كُلُوا مِمَّا فِي الْأَرْضِ حَلَالًا طَيِّبًا',
    transliteration: 'Yā ayyuhā n-nāsu kulū mimmā fī l-arḍi ḥalālan ṭayyibā.',
    translation: 'O mankind, eat of what is on the earth, lawful and good.',
    source: 'Qur’an 2:168',
    detail: 'A halal source you noticed. Amounts are not recorded. Poverty is not a failing.',
  ),
  _item(
    id: 'wl.earning.halal.2_172',
    group: kWealthGroupEarning,
    topic: 'Earned from a halal source',
    text: 'Eat of the good things We have provided you:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ',
    transliteration:
        'Yā ayyuhā lladhīna āmanū kulū min ṭayyibāti mā razaqnākum.',
    translation:
        'O you who believe, eat of the good things We have provided you.',
    source: 'Qur’an 2:172',
    detail:
        'A halal source you noticed. Wealth is not a sign of Allah’s pleasure.',
  ),
  _item(
    id: 'wl.earning.halal.bukhari_2072',
    group: kWealthGroupEarning,
    topic: 'Earned from a halal source',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَا أَكَلَ أَحَدٌ طَعَامًا قَطُّ خَيْرًا مِنْ أَنْ يَأْكُلَ مِنْ عَمَلِ يَدِهِ',
    transliteration: 'Mā akala aḥadun ṭaʿāman qaṭṭu khayran min an yaʾkula min ʿamali yadih.',
    translation: 'No one has ever eaten better food than that which he eats from the work of his own hands.',
    source: 'Ṣaḥīḥ al-Bukhārī 2072',
    detail: 'Work of the hands as you noticed it. Amounts are not recorded.',
  ),
  _item(
    id: 'wl.earning.riba',
    group: kWealthGroupEarning,
    topic: 'Stayed clear of riba',
    text: 'Trade is permitted, and riba is forbidden:',
    arabic: 'وَأَحَلَّ اللَّهُ الْبَيْعَ وَحَرَّمَ الرِّبَا',
    transliteration: 'Wa-aḥalla llāhu l-bayʿa wa-ḥarrama r-ribā.',
    translation: 'Allah has permitted trade and forbidden riba.',
    source: 'Qur’an 2:275',
    detail: 'Staying clear of riba as you report it. Not a credit-score, and not Allah’s pleasure inferred from wealth.',
  ),
  _item(
    id: 'wl.earning.riba.2_278',
    group: kWealthGroupEarning,
    topic: 'Stayed clear of riba',
    text: 'Give up what remains of riba:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَذَرُوا مَا بَقِيَ مِنَ الرِّبَا',
    transliteration:
        'Yā ayyuhā lladhīna āmanū ittaqū llāha wa-dharū mā baqiya mina r-ribā.',
    translation:
        'O you who believe, fear Allah and give up what remains of riba.',
    source: 'Qur’an 2:278',
    detail: 'Staying clear of riba as you report it. Not a credit-score.',
  ),
  _item(
    id: 'wl.earning.riba.3_130',
    group: kWealthGroupEarning,
    topic: 'Stayed clear of riba',
    text: 'Do not consume riba, doubled and multiplied:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا لَا تَأْكُلُوا الرِّبَا أَضْعَافًا مُّضَاعَفَةً',
    transliteration:
        'Yā ayyuhā lladhīna āmanū lā taʾkulū r-ribā aḍʿāfan muḍāʿafah.',
    translation:
        'O you who believe, do not consume riba, doubled and multiplied.',
    source: 'Qur’an 3:130',
    detail: 'Staying clear of riba as you report it. Amounts are not recorded.',
  ),
  _item(
    id: 'wl.earning.riba.muslim_1598',
    group: kWealthGroupEarning,
    topic: 'Stayed clear of riba',
    text: 'The Messenger of Allah ﷺ cursed the one who consumes riba:',
    arabic: 'لَعَنَ رَسُولُ اللَّهِ ﷺ آكِلَ الرِّبَا وَمُوكِلَهُ',
    transliteration: 'Laʿana rasūlu llāhi ākila r-ribā wa-mūkilah.',
    translation: 'The Messenger of Allah ﷺ cursed the one who consumes riba and the one who pays it.',
    source: 'Ṣaḥīḥ Muslim 1598',
    detail: 'Staying clear of riba as you report it. Not inferred from wealth.',
  ),
  _item(
    id: 'wl.restraint.waste',
    group: kWealthGroupRestraint,
    topic: 'Avoided waste',
    text: 'Do not spend wastefully:',
    arabic: 'وَلَا تُبَذِّرْ تَبْذِيرًا إِنَّ الْمُبَذِّرِينَ كَانُوا إِخْوَانَ الشَّيَاطِينِ',
    transliteration: 'Wa-lā tubadhdhir tabdhīrā. Inna l-mubadhdhirīna kānū ikhwāna sh-shayāṭīn.',
    translation: 'And do not spend wastefully. Indeed, the wasteful are brothers of the satans.',
    source: 'Qur’an 17:26–27',
    detail: 'Avoiding waste is stewardship. Giving and zakat stay on Charity. Amounts are not recorded.',
  ),
  _item(
    id: 'wl.restraint.waste.7_31',
    group: kWealthGroupRestraint,
    topic: 'Avoided waste',
    text: 'Eat and drink, but do not be excessive:',
    arabic: 'وَكُلُوا وَاشْرَبُوا وَلَا تُسْرِفُوا ۚ إِنَّهُ لَا يُحِبُّ الْمُسْرِفِينَ',
    transliteration:
        'Wa-kulū wa-shrabū wa-lā tusrifū. Innahu lā yuḥibbu l-musrifīn.',
    translation: 'And eat and drink, but do not be excessive. He does not love the excessive.',
    source: 'Qur’an 7:31',
    detail: 'Avoiding waste is stewardship. Not a calorie log. Health stays on Health.',
  ),
  _item(
    id: 'wl.restraint.waste.6_141',
    group: kWealthGroupRestraint,
    topic: 'Avoided waste',
    text: 'Do not be excessive. He does not love the excessive:',
    arabic: 'وَآتُوا حَقَّهُ يَوْمَ حَصَادِهِ ۖ وَلَا تُسْرِفُوا',
    transliteration: 'Wa-ātū ḥaqqahu yawma ḥaṣādih. Wa-lā tusrifū.',
    translation:
        'And give its due on the day of its harvest, and do not be excessive.',
    source: 'Qur’an 6:141',
    detail: 'Avoiding waste is stewardship. Zakat stays on Charity.',
  ),
  _item(
    id: 'wl.restraint.waste.25_67',
    group: kWealthGroupRestraint,
    topic: 'Avoided waste',
    text: 'Those who, when they spend, are neither wasteful nor stingy:',
    arabic: 'وَالَّذِينَ إِذَا أَنفَقُوا لَمْ يُسْرِفُوا وَلَمْ يَقْتُرُوا وَكَانَ بَيْنَ ذَٰلِكَ قَوَامًا',
    transliteration: 'Wa-lladhīna idhā anfaqū lam yusrifū wa-lam yaqturū wa-kāna bayna dhālika qawāmā.',
    translation: 'And those who, when they spend, are neither wasteful nor stingy, but hold a just balance between.',
    source: 'Qur’an 25:67',
    detail: 'Avoiding waste is stewardship. Amounts are not recorded.',
  ),
  _item(
    id: 'wl.management.4_29',
    group: kWealthGroupManagement,
    topic: 'Managed wealth responsibly and lawfully',
    text: 'Do not consume one another’s wealth unjustly:',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا لَا تَأْكُلُوا أَمْوَالَكُم بَيْنَكُم بِالْبَاطِلِ',
    transliteration:
        'Yā ayyuhā lladhīna āmanū lā taʾkulū amwālakum baynakum bi-l-bāṭil.',
    translation: 'O you who believe, do not consume one another’s wealth among you unjustly.',
    source: 'Qur’an 4:29',
    detail: 'Stewardship as you report it. Not a legal ruling or automatic ḥalāl certification. Amounts are not recorded.',
  ),
  _item(
    id: 'wl.management.4_58',
    group: kWealthGroupManagement,
    topic: 'Managed wealth responsibly and lawfully',
    text: 'Render trusts to those to whom they are due:',
    arabic: 'إِنَّ اللَّهَ يَأْمُرُكُمْ أَن تُؤَدُّوا الْأَمَانَاتِ إِلَىٰ أَهْلِهَا',
    transliteration: 'Inna llāha yaʾmurukum an tuʾaddū l-amānāti ilā ahlihā.',
    translation: 'Indeed, Allah commands you to render trusts to those to whom they are due.',
    source: 'Qur’an 4:58',
    detail: 'A trust you noticed. Not a bank log. Giving and zakat stay on Charity.',
  ),
  _item(
    id: 'wl.management.23_8',
    group: kWealthGroupManagement,
    topic: 'Managed wealth responsibly and lawfully',
    text: 'Those who keep their trusts and their covenant:',
    arabic: 'وَالَّذِينَ هُمْ لِأَمَانَاتِهِمْ وَعَهْدِهِمْ رَاعُونَ',
    transliteration: 'Wa-lladhīna hum li-amānātihim wa-ʿahdihim rāʿūn.',
    translation:
        'And those who are keepers of their trusts and their covenant.',
    source: 'Qur’an 23:8',
    detail: 'Stewardship of what was entrusted. Poverty and debt are not failings. Amounts are not recorded.',
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

PracticeHadithRecord recordFromWealthCatalog({
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
    domain: MonitorDomain.wealth,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
