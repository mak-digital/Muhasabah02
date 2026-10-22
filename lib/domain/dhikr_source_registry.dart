import 'dhikr_context.dart';
import 'practice_dhikr_catalog.dart';
import 'reflection_source.dart';

class DhikrSourceRecord {
  const DhikrSourceRecord({
    required this.id,
    required this.category,
    required this.context,
    required this.label,
    required this.kind,
    required this.citation,
    required this.verification,
    this.arabic = '',
    this.transliteration = '',
    this.meaning = '',
    this.grading = '',
    this.repetitionNote = '',
    this.occasion = '',
    this.practiceCatalogId,
    this.showFormula = false,
  });

  final String id;
  final String category;
  final String context;
  final String label;
  final DhikrSourceKind kind;
  final String citation;
  final DhikrVerificationStatus verification;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String grading;
  final String repetitionNote;
  final String occasion;
  final String? practiceCatalogId;
  final bool showFormula;

  List<Uri> get sourceUris => reflectionSourceUris(citation);
}

const kDhikrSourceRegistry = <DhikrSourceRecord>[
  DhikrSourceRecord(
    id: 'src.dhikr.postPrayer',
    category: 'Post-fard Salah Adhkar',
    context: 'After the prescribed prayer',
    label: 'Post-prayer remembrance',
    kind: DhikrSourceKind.formula,
    arabic: 'سُبْحَانَ اللَّهِ  الْحَمْدُ لِلَّهِ  اللَّهُ أَكْبَرُ',
    transliteration: 'Subḥān Allāh. Al-ḥamdu lillāh. Allāhu akbar.',
    meaning: 'Glory be to Allah. All praise is for Allah. Allah is the Greatest. Recorded as thirty-three of each after the prayer.',
    citation: 'Ṣaḥīḥ Muslim 597',
    grading: 'Sahih',
    repetitionNote: 'Thirty-three of each, as in the cited report.',
    occasion: 'After obligatory Salah. Check-in for this stays on the post-fard rows.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.post.istighfar3',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.tasbih',
    category: 'General Dhikr',
    context: 'Tasbih as remembrance',
    label: 'SubhanAllah — Tasbih',
    kind: DhikrSourceKind.activity,
    meaning: 'Glory be to Allah. An activity description, not a prescribed count in this app.',
    citation: 'Ṣaḥīḥ al-Bukhārī 6405',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.gen.adheem',
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.tahmid',
    category: 'General Dhikr',
    context: 'Tahmid as remembrance',
    label: 'Alhamdulillah — Tahmid',
    kind: DhikrSourceKind.activity,
    meaning: 'All praise is for Allah. An activity description, not a prescribed count in this app.',
    citation: 'Ṣaḥīḥ Muslim 223',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.grat.hamd',
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.takbir',
    category: 'General Dhikr',
    context: 'Takbir as remembrance',
    label: 'Allahu Akbar — Takbir',
    kind: DhikrSourceKind.activity,
    meaning: 'Allah is the Greatest. An activity description, not a prescribed count in this app.',
    citation: 'Ṣaḥīḥ Muslim 597',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.post.tasbih33',
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.tahlil',
    category: 'General Dhikr',
    context: 'Tahlil as remembrance',
    label: 'La ilaha illallah — Tahlil',
    kind: DhikrSourceKind.activity,
    meaning: 'There is no god but Allah. An activity description, not a prescribed count in this app.',
    citation: 'Ṣaḥīḥ Muslim 2691',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.morn.tahlil100',
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.subhanAllahiWaBihamdihi',
    category: 'General Dhikr',
    context: 'A transmitted formula',
    label: 'SubhanAllahi wa bihamdihi',
    kind: DhikrSourceKind.formula,
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Subḥān Allāhi wa bi-ḥamdih.',
    meaning: 'Glory and praise be to Allah.',
    citation: 'Ṣaḥīḥ al-Bukhārī 6405',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.gen.adheem',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.pairedFormula',
    category: 'General Dhikr',
    context: 'Two words beloved to the Most Merciful',
    label: 'SubhanAllahil-Azim and SubhanAllahi wa bihamdihi',
    kind: DhikrSourceKind.formula,
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ  سُبْحَانَ اللَّهِ الْعَظِيمِ',
    transliteration: 'Subḥān Allāhi wa bi-ḥamdih. Subḥān Allāhi l-ʿAẓīm.',
    meaning: 'Glory and praise be to Allah. Glory be to Allah the Magnificent.',
    citation: 'Ṣaḥīḥ al-Bukhārī 6406; Ṣaḥīḥ Muslim 2694',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.gen.adheem',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.istighfar',
    category: 'General Dhikr',
    context: 'Seeking forgiveness',
    label: 'Astaghfirullah',
    kind: DhikrSourceKind.activity,
    arabic: 'أَسْتَغْفِرُ اللَّهَ',
    transliteration: 'Astaghfiru Allāh.',
    meaning: 'I seek forgiveness from Allah. An activity description, not a completed tawbah.',
    citation: 'Ṣaḥīḥ al-Bukhārī 6307',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.post.istighfar3',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.sayyidAlIstighfar',
    category: 'General Dhikr',
    context: 'Sayyid al-Istighfar',
    label: 'Sayyid al-Istighfar',
    kind: DhikrSourceKind.formula,
    arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration: 'Allāhumma anta rabbī, lā ilāha illā anta, khalaqtanī wa anā ʿabduk, wa anā ʿalā ʿahdika wa waʿdika mā’staṭaʿt, aʿūdhu bika min sharri mā ṣanaʿt, abū’u laka bi-niʿmatika ʿalayya, wa abū’u laka bi-dhanbī, fa-ghfir lī, fa-innahu lā yaghfiru dh-dhunūba illā ant.',
    meaning: 'O Allah, You are my Lord. There is no god but You. You created me and I am Your servant. I am upon Your covenant and promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge Your favour upon me, and I acknowledge my sin, so forgive me, for none forgives sins except You.',
    citation: 'Ṣaḥīḥ al-Bukhārī 6306',
    grading: 'Sahih',
    occasion: 'General remembrance. Not completed tawbah.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.morn.sayyid',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.salawat',
    category: 'General Dhikr',
    context: 'Sending blessings',
    label: 'Salawat upon the Prophet ﷺ',
    kind: DhikrSourceKind.formula,
    arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
    transliteration: 'Allāhumma ṣalli ʿalā Muḥammadin wa ʿalā āli Muḥammad.',
    meaning: 'O Allah, send blessings upon Muhammad and upon the family of Muhammad. The command to send blessings is in Qur’an 33:56.',
    citation: 'Qur’an 33:56; Ṣaḥīḥ Muslim 408',
    grading: 'Sahih',
    occasion: 'General remembrance.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.gen.salawat',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.alhamdulillah',
    category: 'Gratitude Dhikr',
    context: 'Praise',
    label: 'General Alhamdulillah',
    kind: DhikrSourceKind.formula,
    arabic: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Al-ḥamdu lillāh.',
    meaning: 'All praise is for Allah.',
    citation: 'Ṣaḥīḥ Muslim 223',
    grading: 'Sahih',
    occasion: 'Gratitude remembrance. Not a mood score.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.grat.hamd',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.afterFood',
    category: 'Gratitude Dhikr',
    context: 'After eating or drinking',
    label: 'Gratitude after eating or drinking',
    kind: DhikrSourceKind.activity,
    arabic: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Al-ḥamdu lillāh.',
    meaning: 'Allah is pleased with a servant who eats a meal and praises Him for it, or takes a drink and praises Him for it. The longer meal formulas are not attached to this citation.',
    citation: 'Ṣaḥīḥ Muslim 2734',
    grading: 'Sahih',
    occasion: 'After eating or drinking. Activity description, not a ruling.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.quran14_7',
    category: 'Gratitude Dhikr',
    context: 'Remembering blessings',
    label: 'Remembering Allah\'s blessings',
    kind: DhikrSourceKind.verse,
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    transliteration: 'La-in shakartum la-azīdannakum.',
    meaning: 'If you are grateful, I will surely increase you.',
    citation: 'Qur’an 14:7',
    occasion: 'Gratitude remembrance. A verse, not a daily quota.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.leavingHome',
    category: 'Travel Remembrance',
    context: 'Leaving home',
    label: 'Leaving home',
    kind: DhikrSourceKind.formula,
    arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'Bismi llāh, tawakkaltu ʿalā llāh, wa lā ḥawla wa lā quwwata illā billāh.',
    meaning: 'In the name of Allah. I place my trust in Allah. There is no power and no strength except with Allah.',
    citation: 'Sunan Abī Dāwūd 5095',
    grading: 'Recorded in Sunan Abī Dāwūd; this app does not assert a further grade.',
    occasion: 'Leaving home.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.beginningJourney',
    category: 'Travel Remembrance',
    context: 'Beginning a journey',
    label: 'Beginning a journey',
    kind: DhikrSourceKind.formula,
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
    transliteration: 'Subḥāna lladhī sakhkhara lanā hādhā wa mā kunnā lahu muqrinīn, wa innā ilā rabbinā la-munqalibūn.',
    meaning: 'Glory to Him who subjected this to us, and we could not have done it ourselves. And to our Lord we will return.',
    citation: 'Ṣaḥīḥ Muslim 1342',
    grading: 'Sahih',
    occasion: 'Beginning a journey or mounting transport.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.travel.mount',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.stoppingPlace',
    category: 'Travel Remembrance',
    context: 'Stopping at a place',
    label: 'Stopping at a place',
    kind: DhikrSourceKind.formula,
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'Aʿūdhu bi-kalimāti llāhi t-tāmmāti min sharri mā khalaq.',
    meaning: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    citation: 'Ṣaḥīḥ Muslim 2708',
    grading: 'Sahih',
    occasion: 'Stopping at a place while travelling.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.returningTravel',
    category: 'Travel Remembrance',
    context: 'Returning from travel',
    label: 'Returning from travel',
    kind: DhikrSourceKind.formula,
    arabic: 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
    transliteration: 'Āyibūna, tāʾibūna, ʿābidūna, li-rabbinā ḥāmidūn.',
    meaning: 'We return, repenting, worshipping, and praising our Lord.',
    citation: 'Ṣaḥīḥ al-Bukhārī 3085; Ṣaḥīḥ Muslim 1344',
    grading: 'Sahih',
    occasion: 'Returning from travel.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.travel.return',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.rabbanaAtina',
    category: 'Personal',
    context: 'A comprehensive personal dua',
    label: 'Rabbana atina fid-dunya hasanah',
    kind: DhikrSourceKind.formula,
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration: 'Rabbanā ātinā fī d-dunyā ḥasanatan wa fī l-ākhirati ḥasanatan wa qinā ʿadhāba n-nār.',
    meaning: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
    citation: 'Qur’an 2:201; Ṣaḥīḥ al-Bukhārī 6389',
    grading: 'Sahih',
    occasion: 'Personal dua. The words of the dua are optional to view; the topic can be recorded without disclosing other personal wording.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.pers.rabbana',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.beforeSleep',
    category: 'Other Adhkars',
    context: 'Before sleeping',
    label: 'Ayat al-Kursi before sleep',
    kind: DhikrSourceKind.formula,
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    transliteration: 'Allāhu lā ilāha illā huwa l-Ḥayyu l-Qayyūm.',
    meaning: 'Allah — there is no god but He, the Ever-Living, the Self-Subsisting. Full verse: Qur’an 2:255.',
    citation: 'Ṣaḥīḥ al-Bukhārī 2311; Qur’an 2:255',
    grading: 'Sahih',
    occasion: 'Before sleep. Other Adhkars, not the morning set.',
    verification: DhikrVerificationStatus.verified,
    practiceCatalogId: 'dh.other.sleep.kursi',
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.waking',
    category: 'Other Adhkars',
    context: 'Upon waking',
    label: 'Upon waking',
    kind: DhikrSourceKind.formula,
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    transliteration:
        'Al-ḥamdu lillāhi lladhī aḥyānā baʿda mā amātanā wa ilayhi n-nushūr.',
    meaning: 'All praise is for Allah, who gave us life after having taken it from us, and unto Him is the resurrection.',
    citation: 'Ṣaḥīḥ al-Bukhārī 6312',
    grading: 'Sahih',
    occasion: 'Upon waking. Other Adhkars, not the morning set.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.mosque',
    category: 'Other Adhkars',
    context: 'Entering or leaving the mosque',
    label: 'Entering or leaving the mosque',
    kind: DhikrSourceKind.formula,
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ\nاللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    transliteration: 'Entering: Allāhumma iftaḥ lī abwāba raḥmatik. Leaving: Allāhumma innī asʾaluka min faḍlik.',
    meaning: 'Entering: O Allah, open the gates of Your mercy for me. Leaving: O Allah, I ask You of Your bounty.',
    citation: 'Ṣaḥīḥ Muslim 713',
    grading: 'Sahih',
    occasion: 'Entering or leaving the mosque.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.distress',
    category: 'Other Adhkars',
    context: 'During distress or worry',
    label: 'The call of Yunus',
    kind: DhikrSourceKind.verse,
    arabic:
        'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    transliteration: 'Lā ilāha illā anta subḥānaka innī kuntu mina ẓ-ẓālimīn.',
    meaning: 'There is no god but You. Glory be to You. I have been of the wrongdoers.',
    citation: 'Qur’an 21:87',
    occasion: 'A Qur’an verse recorded in hardship. This is not a prescribed remedy or score.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.illness',
    category: 'Other Adhkars',
    context: 'During illness',
    label: 'During illness',
    kind: DhikrSourceKind.formula,
    arabic: 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِهِ وَأَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا',
    transliteration: 'Allāhumma rabba n-nās, adhhibi l-baʾs, ishfihi wa anta sh-shāfī, lā shifāʾa illā shifāʾuk, shifāʾan lā yughādiru saqamā.',
    meaning: 'O Allah, Lord of the people, remove the harm, heal him. You are the Healer. There is no healing but Yours, a healing that leaves no illness behind.',
    citation: 'Ṣaḥīḥ al-Bukhārī 5742; Ṣaḥīḥ Muslim 2191',
    grading: 'Sahih',
    occasion: 'During illness. A recorded supplication, not a medical instruction or score.',
    verification: DhikrVerificationStatus.verified,
    showFormula: true,
  ),
  DhikrSourceRecord(
    id: 'src.dhikr.istikharaPending',
    category: 'Personal',
    context: 'Istikhara',
    label: 'Istikhara',
    kind: DhikrSourceKind.activity,
    meaning: 'Topic only in this release. The transmitted istikhara wording is pending editorial review and is not shown as a sourced formula here.',
    citation: '',
    occasion: 'Personal dua. Record the topic without disclosing the words.',
    verification: DhikrVerificationStatus.pendingReview,
  ),
];

final dhikrSourceById = {
  for (final item in kDhikrSourceRegistry) item.id: item,
};

List<PracticeDhikrItem> dhikrPracticeReferencesFor(DhikrContextItem item) {
  final source = item.sourceId == null ? null : dhikrSourceById[item.sourceId];
  final seen = <String>{};
  final items = <PracticeDhikrItem>[];
  void add(PracticeDhikrItem? next) {
    if (next == null || !seen.add(next.id)) return;
    items.add(next);
  }

  add(
    item.practiceCatalogId == null
        ? null
        : practiceDhikrById(item.practiceCatalogId!),
  );
  if (source == null) return items;
  add(
    source.practiceCatalogId == null
        ? null
        : practiceDhikrById(source.practiceCatalogId!),
  );
  for (final match in practiceDhikrMatchingCitation(source.citation)) {
    add(match);
  }
  return items;
}

bool dhikrHasVerifiedWording(DhikrContextItem item) {
  final source = item.sourceId == null ? null : dhikrSourceById[item.sourceId];
  if (source != null) {
    if (source.verification != DhikrVerificationStatus.verified) return false;
    return source.citation.isNotEmpty || source.arabic.isNotEmpty;
  }
  if (item.kind == DhikrSourceKind.activity) return false;
  return item.practiceCatalogId != null &&
      practiceDhikrById(item.practiceCatalogId!) != null;
}

bool dhikrShowsWordingLink(DhikrContextItem item) {
  if (dhikrHasVerifiedWording(item)) return true;
  return item.practiceCatalogId != null &&
      practiceDhikrById(item.practiceCatalogId!) != null;
}

String dhikrWordingLinkLabel(DhikrContextItem item) {
  return dhikrHasVerifiedWording(item)
      ? 'Verified wording available'
      : 'Related wording available';
}
