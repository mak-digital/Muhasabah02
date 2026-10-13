import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kHuquqGroupHousehold = 'Household';
const kHuquqGroupExtended = 'Extended family';
const kHuquqGroupNeighbours = 'Neighbours & work';
const kHuquqGroupPeople = 'The people';
const kHuquqGroupRepair = 'Repair';
const kHuquqGroupHardship = 'Care in hardship';

const kPracticeHuquqGroups = [
  kHuquqGroupHousehold,
  kHuquqGroupExtended,
  kHuquqGroupNeighbours,
  kHuquqGroupPeople,
  kHuquqGroupRepair,
  kHuquqGroupHardship,
];

/// Qur’an and authentic hadith that encourage the Huquq rows.
/// Grouped like Home. Own obligations only — not a relationship score.
final List<PracticeDhikrItem> _kPracticeHuquqCore = [
  _item(
    id: 'hq.household.parents',
    group: kHuquqGroupHousehold,
    topic: 'Parents',
    text: 'Your Lord has decreed:',
    arabic:
        'وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا',
    transliteration:
        'Wa qaḍā rabbuka allā taʿbudū illā iyyāhu wa bi-l-wālidayni iḥsānā.',
    translation:
        'Your Lord has decreed that you worship none but Him, and that you be kind to parents.',
    source: 'Qur’an 17:23',
    detail: 'A right you owe. Not a parent score. Unanswered is not neglect.',
  ),
  _item(
    id: 'hq.household.spouse',
    group: kHuquqGroupHousehold,
    topic: 'Spouse',
    text: 'Among His signs:',
    arabic:
        'وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً',
    transliteration:
        'Wa min āyātihi an khalaqa lakum min anfusikum azwājan li-taskunū ilayhā wa jaʿala baynakum mawaddatan wa raḥmah.',
    translation:
        'And among His signs is that He created for you spouses from yourselves so that you may find rest in them, and He placed between you affection and mercy.',
    source: 'Qur’an 30:21',
    detail: 'Your own obligations. Not a marriage grade. Patience is not required in harm.',
  ),
  _item(
    id: 'hq.household.children',
    group: kHuquqGroupHousehold,
    topic: 'Children',
    text: 'The Prophet ﷺ said:',
    arabic: 'اتَّقُوا اللَّهَ وَاعْدِلُوا بَيْنَ أَوْلَادِكُمْ',
    transliteration: 'Ittaqū Allāha wa-ʿdilū bayna awlādikum.',
    translation: 'Fear Allah, and be just between your children.',
    source: 'Ṣaḥīḥ al-Bukhārī 2587',
    detail: 'Fairness and presence you owe. Not a parenting score.',
  ),
  _item(
    id: 'hq.household.siblings',
    group: kHuquqGroupHousehold,
    topic: 'Siblings',
    text: 'Keep the womb-ties:',
    arabic:
        'وَاتَّقُوا اللَّهَ الَّذِي تَسَاءَلُونَ بِهِ وَالْأَرْحَامَ',
    transliteration:
        'Wa ttaqū Allāha alladhī tasāʾalūna bihi wa-l-arḥām.',
    translation:
        'And fear Allah, through whom you ask one another, and the wombs.',
    source: 'Qur’an 4:1',
    detail: 'Keeping ties. Not a family ledger of what others owe you.',
  ),
  _item(
    id: 'hq.household.grandparents',
    group: kHuquqGroupHousehold,
    topic: 'Grandparents',
    text: 'The Prophet ﷺ said:',
    arabic:
        'لَيْسَ مِنَّا مَنْ لَمْ يَرْحَمْ صَغِيرَنَا وَيُوَقِّرْ كَبِيرَنَا',
    transliteration:
        'Laysa minnā man lam yarḥam ṣaghīranā wa yuwaqqir kabīranā.',
    translation:
        'He is not of us who does not have mercy on our young and respect our elders.',
    source: 'Jāmiʿ al-Tirmidhī 1921',
    detail: 'Honouring. Not an age-rank score.',
  ),
  _item(
    id: 'hq.extended.relatives',
    group: kHuquqGroupExtended,
    topic: 'Other relatives',
    text: 'Worship Allah, and do good:',
    arabic:
        'وَاعْبُدُوا اللَّهَ وَلَا تُشْرِكُوا بِهِ شَيْئًا وَبِالْوَالِدَيْنِ إِحْسَانًا وَبِذِي الْقُرْبَىٰ',
    transliteration:
        'Wa-ʿbudū Allāha wa lā tushrikū bihi shayʾan wa bi-l-wālidayni iḥsānan wa bi-dhī l-qurbā.',
    translation:
        'Worship Allah and associate nothing with Him, and be good to parents and to relatives.',
    source: 'Qur’an 4:36',
    detail: 'Keeping ties with other relatives. Unanswered is not neglect.',
  ),
  _item(
    id: 'hq.neighbours.neighbour',
    group: kHuquqGroupNeighbours,
    topic: 'Neighbours',
    text: 'The Prophet ﷺ said:',
    arabic:
        'مَا زَالَ جِبْرِيلُ يُوصِينِي بِالْجَارِ حَتَّى ظَنَنْتُ أَنَّهُ سَيُوَرِّثُهُ',
    transliteration:
        'Mā zāla Jibrīlu yūṣīnī bi-l-jāri ḥattā ẓanantu annahu sa-yuwarithuh.',
    translation:
        'Jibril kept advising me about the neighbour until I thought he would make him an heir.',
    source: 'Ṣaḥīḥ al-Bukhārī 6014; Ṣaḥīḥ Muslim 2624',
    detail: 'A right of neighbourliness. Not a popularity mark. Help stays here, not on Charity.',
  ),
  _item(
    id: 'hq.neighbours.colleagues',
    group: kHuquqGroupNeighbours,
    topic: 'Colleagues & friends',
    text: 'Allah commands trusts:',
    arabic: 'إِنَّ اللَّهَ يَأْمُرُكُمْ أَن تُؤَدُّوا الْأَمَانَاتِ إِلَىٰ أَهْلِهَا',
    transliteration:
        'Inna Allāha yaʾmurukum an tuʾaddū l-amānāti ilā ahlihā.',
    translation: 'Allah commands you to render trusts to those to whom they are due.',
    source: 'Qur’an 4:58',
    detail: 'Trustworthiness and keeping a confidence. Not a workplace grade.',
  ),
  _item(
    id: 'hq.people.muslims',
    group: kHuquqGroupPeople,
    topic: 'Fellow Muslims',
    text: 'The Prophet ﷺ said:',
    arabic:
        'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    transliteration:
        'Lā yuʾminu aḥadukum ḥattā yuḥibba li-akhīhi mā yuḥibbu li-nafsih.',
    translation:
        'None of you believes until he loves for his brother what he loves for himself.',
    source: 'Ṣaḥīḥ al-Bukhārī 13; Ṣaḥīḥ Muslim 45',
    detail: 'A right of brotherhood. Not an ummah score. The Ummah card stays separate.',
  ),
  _item(
    id: 'hq.people.nonmuslims',
    group: kHuquqGroupPeople,
    topic: 'Non-Muslims',
    text: 'Kindness and justice are not forbidden:',
    arabic:
        'لَا يَنْهَاكُمُ اللَّهُ عَنِ الَّذِينَ لَمْ يُقَاتِلُوكُمْ فِي الدِّينِ وَلَمْ يُخْرِجُوكُم مِّن دِيَارِكُمْ أَن تَبَرُّوهُمْ وَتُقْسِطُوا إِلَيْهِمْ',
    transliteration:
        'Lā yanhākumu Allāhu ʿani lladhīna lam yuqātilūkum fī d-dīni wa lam yukhrijūkum min diyārikum an tabarrūhum wa tuqsiṭū ilayhim.',
    translation:
        'Allah does not forbid you from those who do not fight you because of religion and do not expel you from your homes — from being kind to them and acting justly toward them.',
    source: 'Qur’an 60:8',
    detail: 'Justice and good neighbourliness. Not a conversion project.',
  ),
  _item(
    id: 'hq.repair.reconciliation',
    group: kHuquqGroupRepair,
    topic: 'A step toward reconciliation',
    text: 'The believers are brothers:',
    arabic:
        'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ',
    transliteration:
        'Innamā l-muʾminūna ikhwatun fa-aṣliḥū bayna akhawaykum.',
    translation:
        'The believers are but brothers, so make peace between your two brothers.',
    source: 'Qur’an 49:10',
    detail: 'Optional noticing. The app does not prescribe or complete sulh. Family conflict is not a shame mark.',
  ),
  _item(
    id: 'hq.repair.return',
    group: kHuquqGroupRepair,
    topic: 'Turned back over a neglected right',
    text: 'Whoever pardons and makes right:',
    arabic: 'فَمَنْ عَفَا وَأَصْلَحَ فَأَجْرُهُ عَلَى اللَّهِ',
    transliteration: 'Fa-man ʿafā wa aṣlaḥa fa-ajruhu ʿalā Allāh.',
    translation:
        'But whoever pardons and makes reconciliation — his reward is with Allah.',
    source: 'Qur’an 42:40',
    detail: 'Optional turning back. The app does not prescribe tawbah or complete it.',
  ),
  _item(
    id: 'hq.hardship.visit',
    group: kHuquqGroupHardship,
    topic: 'Sick Visit',
    text: 'The Prophet ﷺ said:',
    arabic: 'أَطْعِمُوا الْجَائِعَ وَعُودُوا الْمَرِيضَ',
    transliteration: 'Aṭʿimū l-jāʾiʿa wa ʿūdū l-marīḍ.',
    translation: 'Feed the hungry and visit the sick.',
    source: 'Ṣaḥīḥ al-Bukhārī 5653',
    detail: 'A right of brotherhood, not a sadaqah channel. Unanswered is not neglect.',
  ),
  _item(
    id: 'hq.hardship.contact',
    group: kHuquqGroupHardship,
    topic: 'Sick Contact',
    text: 'The Prophet ﷺ said:',
    arabic: 'مَنْ عَادَ مَرِيضًا لَمْ يَزَلْ فِي خُرْفَةِ الْجَنَّةِ حَتَّى يَرْجِعَ',
    transliteration:
        'Man ʿāda marīḍan lam yazal fī khurfatil-jannah ḥattā yarjiʿ.',
    translation:
        'Whoever visits a sick person remains in the harvesting of Paradise until he returns.',
    source: 'Ṣaḥīḥ Muslim 2568',
    detail: 'Reaching out. Not a second visit quota. Charity stays on Charity.',
  ),
  _item(
    id: 'hq.hardship.stress',
    group: kHuquqGroupHardship,
    topic: 'Support Under Stress',
    text: 'Help one another in righteousness:',
    arabic: 'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ ۖ وَلَا تَعَاوَنُوا عَلَى الْإِثْمِ وَالْعُدْوَانِ',
    transliteration:
        'Wa taʿāwanū ʿalā l-birri wa t-taqwā, wa lā taʿāwanū ʿalā l-ithmi wa-l-ʿudwān.',
    translation:
        'Help one another in righteousness and taqwa, and do not help one another in sin and aggression.',
    source: 'Qur’an 5:2',
    detail: 'Support under stress. Safety and justice come first. Not a venting field.',
  ),
];

final List<PracticeDhikrItem> kPracticeHuquqCatalog = [
  for (final item in _kPracticeHuquqCore) ..._huquqWithSupports(item),
];

List<PracticeDhikrItem> _huquqWithSupports(PracticeDhikrItem item) {
  return [
    item,
    _item(
      id: '${item.id}.16_90',
      group: item.group,
      topic: item.topic,
      text: 'Allah commands justice and excellence:',
      arabic: 'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ',
      transliteration: 'Inna llāha yaʾmuru bi-l-ʿadli wa-l-iḥsān.',
      translation: 'Indeed, Allah commands justice and excellence.',
      source: 'Qur’an 16:90',
      detail: item.sourceDetail,
    ),
    _item(
      id: '${item.id}.3_110',
      group: item.group,
      topic: item.topic,
      text: 'You are the best community brought out for people:',
      arabic:
          'كُنتُمْ خَيْرَ أُمَّةٍ أُخْرِجَتْ لِلنَّاسِ تَأْمُرُونَ بِالْمَعْرُوفِ وَتَنْهَوْنَ عَنِ الْمُنكَرِ',
      transliteration:
          'Kuntum khayra ummatin ukhrijat li-n-nāsi taʾmurūna bi-l-maʿrūfi wa-tanhawna ʿani l-munkar.',
      translation:
          'You are the best community brought forth for people: you enjoin what is right and forbid what is wrong.',
      source: 'Qur’an 3:110',
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

PracticeHadithRecord recordFromHuquqCatalog({
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
    domain: MonitorDomain.huquq,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
