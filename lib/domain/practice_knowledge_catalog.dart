import 'monitor_domain.dart';
import 'practice_dhikr_catalog.dart';
import 'practice_hadith.dart';

const kKnowledgeGroupSeeking = 'Seeking truth';
const kKnowledgeGroupSharing = 'Sharing';
const kKnowledgeGroupSpeech = 'Beneficial speech';

const kPracticeKnowledgeGroups = [
  kKnowledgeGroupSeeking,
  kKnowledgeGroupSharing,
  kKnowledgeGroupSpeech,
];

/// Qur’an and authentic hadith that encourage Knowledge Home rows.
/// Residual learning and speech — not Qur’an, Hadith, or Akhlaq tone.
final List<PracticeDhikrItem> kPracticeKnowledgeCatalog = [
  _item(
    id: 'kn.seeking.learned',
    group: kKnowledgeGroupSeeking,
    topic: 'Learned something true',
    text: 'Ask for increase in knowledge:',
    arabic: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
    transliteration: 'Wa qul rabbi zidnī ʿilmā.',
    translation: 'And say: My Lord, increase me in knowledge.',
    source: 'Qur’an 20:114',
    detail:
        'A single new fact is enough. Not hours studied. Qur’an and Hadith have their own cards.',
  ),
  _item(
    id: 'kn.seeking.learned.96_1',
    group: kKnowledgeGroupSeeking,
    topic: 'Learned something true',
    text: 'Read in the name of your Lord:',
    arabic: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
    transliteration: 'Iqraʾ bi-smi rabbika lladhī khalaq.',
    translation: 'Read in the name of your Lord who created.',
    source: 'Qur’an 96:1',
    detail: 'A single new fact is enough. Not hours studied.',
  ),
  _item(
    id: 'kn.seeking.learned.58_11',
    group: kKnowledgeGroupSeeking,
    topic: 'Learned something true',
    text: 'Allah raises those who have been given knowledge:',
    arabic: 'يَرْفَعِ اللَّهُ الَّذِينَ آمَنُوا مِنكُمْ وَالَّذِينَ أُوتُوا الْعِلْمَ دَرَجَاتٍ',
    transliteration:
        'Yarfaʿi llāhu lladhīna āmanū minkum wa-lladhīna ūtū l-ʿilma darajāt.',
    translation:
        'Allah will raise those who have believed among you and those who were given knowledge, by degrees.',
    source: 'Qur’an 58:11',
    detail: 'A single new fact is enough. The app never congratulates anyone for being learned.',
  ),
  _item(
    id: 'kn.seeking.learned.bukhari_79',
    group: kKnowledgeGroupSeeking,
    topic: 'Learned something true',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَنْ يُرِدِ اللَّهُ بِهِ خَيْرًا يُفَقِّهْهُ فِي الدِّينِ',
    transliteration: 'Man yuridi llāhu bihi khayran yufaqqihhu fī d-dīn.',
    translation: 'Whoever Allah wants good for, He gives him understanding in the religion.',
    source: 'Ṣaḥīḥ al-Bukhārī 71',
    detail: 'A single new fact is enough. Not a scholar requirement.',
  ),
  _item(
    id: 'kn.seeking.reading',
    group: kKnowledgeGroupSeeking,
    topic: 'Beneficial reading (not Qur’an or Hadith)',
    text: 'The Prophet ﷺ said:',
    arabic:
        'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
    transliteration:
        'Man salaka ṭarīqan yaltamisu fīhi ʿilman sahhala Allāhu lahu bihi ṭarīqan ilā l-jannah.',
    translation:
        'Whoever travels a path seeking knowledge, Allah makes easy for him a path to Paradise.',
    source: 'Ṣaḥīḥ Muslim 2699',
    detail:
        'Book, article, or lecture — not a Qur’an or Hadith sitting. Not a study-hour badge.',
  ),
  _item(
    id: 'kn.seeking.reading.20_114',
    group: kKnowledgeGroupSeeking,
    topic: 'Beneficial reading (not Qur’an or Hadith)',
    text: 'And say: My Lord, increase me in knowledge:',
    arabic: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
    transliteration: 'Wa qul rabbi zidnī ʿilmā.',
    translation: 'And say: My Lord, increase me in knowledge.',
    source: 'Qur’an 20:114',
    detail: 'Book, article, or lecture — not a Qur’an or Hadith sitting.',
  ),
  _item(
    id: 'kn.seeking.reading.39_9',
    group: kKnowledgeGroupSeeking,
    topic: 'Beneficial reading (not Qur’an or Hadith)',
    text: 'Are those who know equal to those who do not know:',
    arabic: 'قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ',
    transliteration: 'Qul hal yastawī lladhīna yaʿlamūna wa-lladhīna lā yaʿlamūn.',
    translation: 'Say: Are those who know equal to those who do not know?',
    source: 'Qur’an 39:9',
    detail: 'Not hours studied. Not congratulations for being learned.',
  ),
  _item(
    id: 'kn.seeking.reading.abudawud_3641',
    group: kKnowledgeGroupSeeking,
    topic: 'Beneficial reading (not Qur’an or Hadith)',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    transliteration: 'Ṭalabu l-ʿilmi farīḍatun ʿalā kulli muslim.',
    translation: 'Seeking knowledge is an obligation upon every Muslim.',
    source: 'Sunan Ibn Mājah 224',
    detail: 'Book, article, or lecture. Not a study-hour badge.',
  ),
  _item(
    id: 'kn.seeking.asked',
    group: kKnowledgeGroupSeeking,
    topic: 'Asked to remove ignorance',
    text: 'If you do not know, ask:',
    arabic: 'فَاسْأَلُوا أَهْلَ الذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ',
    transliteration:
        'Fa-sʾalū ahla dh-dhikri in kuntum lā taʿlamūn.',
    translation: 'So ask the people of reminder if you do not know.',
    source: 'Qur’an 16:43',
    detail:
        'Asking is noticing, not a scholar requirement. Unanswered is not ignorance.',
  ),
  _item(
    id: 'kn.seeking.asked.21_7',
    group: kKnowledgeGroupSeeking,
    topic: 'Asked to remove ignorance',
    text: 'If you do not know, ask the people of reminder:',
    arabic: 'فَاسْأَلُوا أَهْلَ الذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ',
    transliteration: 'Fa-sʾalū ahla dh-dhikri in kuntum lā taʿlamūn.',
    translation: 'So ask the people of reminder if you do not know.',
    source: 'Qur’an 21:7',
    detail: 'Asking is noticing. Unanswered is not ignorance.',
  ),
  _item(
    id: 'kn.seeking.asked.bukhari_100',
    group: kKnowledgeGroupSeeking,
    topic: 'Asked to remove ignorance',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'إِنَّمَا شِفَاءُ الْعِيِّ السُّؤَالُ',
    transliteration: 'Innamā shifāʾu l-ʿiyyi s-suʾāl.',
    translation: 'The cure for ignorance is to ask.',
    source: 'Sunan Abī Dāwūd 337',
    detail: 'Asking is noticing, not a scholar requirement.',
  ),
  _item(
    id: 'kn.seeking.asked.2_186',
    group: kKnowledgeGroupSeeking,
    topic: 'Asked to remove ignorance',
    text: 'When My servants ask you about Me, I am near:',
    arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
    transliteration: 'Wa-idhā saʾalaka ʿibādī ʿannī fa-innī qarīb.',
    translation: 'And when My servants ask you about Me, indeed I am near.',
    source: 'Qur’an 2:186',
    detail: 'Asking is noticing. Unanswered is not ignorance.',
  ),
  _item(
    id: 'kn.sharing.taught',
    group: kKnowledgeGroupSharing,
    topic: 'Taught someone',
    text: 'The Prophet ﷺ said:',
    arabic:
        'مَنْ دَعَا إِلَى هُدًى كَانَ لَهُ مِنَ الْأَجْرِ مِثْلُ أُجُورِ مَنْ تَبِعَهُ',
    transliteration:
        'Man daʿā ilā hudan kāna lahu mina l-ajri mithlu ujūri man tabiʿah.',
    translation:
        'Whoever calls to guidance will have a reward like the rewards of those who follow it.',
    source: 'Ṣaḥīḥ Muslim 2674',
    detail:
        'Even one fact to a child or colleague. Not a teaching rank. Debate is not engagement.',
  ),
  _item(
    id: 'kn.sharing.taught.bukhari_5027',
    group: kKnowledgeGroupSharing,
    topic: 'Taught someone',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    transliteration: 'Khayrukum man taʿallama l-qurʾāna wa-ʿallamah.',
    translation: 'The best of you are those who learn the Qur’an and teach it.',
    source: 'Ṣaḥīḥ al-Bukhārī 5027',
    detail: 'Even one fact. Not a teaching rank. Qur’an has its own card.',
  ),
  _item(
    id: 'kn.sharing.taught.3_187',
    group: kKnowledgeGroupSharing,
    topic: 'Taught someone',
    text: 'You shall make it clear to people and not conceal it:',
    arabic: 'لَتُبَيِّنُنَّهُ لِلنَّاسِ وَلَا تَكْتُمُونَهُ',
    transliteration: 'La-tubayyinunnahu li-n-nāsi wa-lā taktumūnah.',
    translation: 'You shall make it clear to the people and not conceal it.',
    source: 'Qur’an 3:187',
    detail: 'Even one fact to a child or colleague. Debate is not engagement.',
  ),
  _item(
    id: 'kn.sharing.taught.16_125',
    group: kKnowledgeGroupSharing,
    topic: 'Taught someone',
    text: 'Invite to your Lord’s way with wisdom:',
    arabic: 'ادْعُ إِلَىٰ سَبِيلِ رَبِّكَ بِالْحِكْمَةِ وَالْمَوْعِظَةِ الْحَسَنَةِ',
    transliteration:
        'Udʿu ilā sabīli rabbika bi-l-ḥikmati wa-l-mawʿiẓati l-ḥasanah.',
    translation: 'Invite to the way of your Lord with wisdom and good instruction.',
    source: 'Qur’an 16:125',
    detail: 'Even one fact. Not a teaching rank.',
  ),
  _item(
    id: 'kn.sharing.advice',
    group: kKnowledgeGroupSharing,
    topic: 'Sincere advice',
    text: 'The Prophet ﷺ said:',
    arabic: 'الدِّينُ النَّصِيحَةُ',
    transliteration: 'Ad-dīnu n-naṣīḥah.',
    translation: 'The religion is sincere advice.',
    source: 'Ṣaḥīḥ Muslim 55',
    detail:
        'Sincere advice as an observation, not an achievement. Controversial content is not logged here.',
  ),
  _item(
    id: 'kn.sharing.advice.7_68',
    group: kKnowledgeGroupSharing,
    topic: 'Sincere advice',
    text: 'I am delivering to you the messages of my Lord, and I am a trustworthy adviser to you:',
    arabic: 'أُبَلِّغُكُمْ رِسَالَاتِ رَبِّي وَأَنَا لَكُمْ نَاصِحٌ أَمِينٌ',
    transliteration: 'Uballighukum risālāti rabbī wa-anā lakum nāṣiḥun amīn.',
    translation:
        'I convey to you the messages of my Lord, and I am to you a trustworthy adviser.',
    source: 'Qur’an 7:68',
    detail: 'Sincere advice as an observation. Controversial content is not logged here.',
  ),
  _item(
    id: 'kn.sharing.advice.9_91',
    group: kKnowledgeGroupSharing,
    topic: 'Sincere advice',
    text: 'There is no blame on those who give sincere advice:',
    arabic: 'إِذَا نَصَحُوا لِلَّهِ وَرَسُولِهِ',
    transliteration: 'Idhā naṣaḥū li-llāhi wa-rasūlih.',
    translation: 'When they give sincere advice for Allah and His Messenger.',
    source: 'Qur’an 9:91',
    detail: 'Sincere advice as an observation, not an achievement.',
  ),
  _item(
    id: 'kn.sharing.advice.bukhari_57',
    group: kKnowledgeGroupSharing,
    topic: 'Sincere advice',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'الدِّينُ النَّصِيحَةُ لِلَّهِ وَلِكِتَابِهِ وَلِرَسُولِهِ وَلِأَئِمَّةِ الْمُسْلِمِينَ وَعَامَّتِهِمْ',
    transliteration:
        'Ad-dīnu n-naṣīḥatu li-llāhi wa-li-kitābihi wa-li-rasūlihi wa-li-aʾimmati l-muslimīna wa-ʿāmmatihim.',
    translation:
        'The religion is sincere advice: for Allah, His Book, His Messenger, the leaders of the Muslims, and their common folk.',
    source: 'Ṣaḥīḥ Muslim 55',
    detail: 'Sincere advice as an observation. Controversial content is not logged here.',
  ),
  _item(
    id: 'kn.sharing.created',
    group: kKnowledgeGroupSharing,
    topic: 'Wrote or created something beneficial',
    text: 'The Prophet ﷺ said that when a person dies, deeds end except three:',
    arabic:
        'إِذَا مَاتَ الْإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثَةٍ: إِلَّا مِنْ صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ',
    transliteration:
        'Idhā māta l-insānu inqaṭaʿa ʿanhu ʿamaluhu illā min thalāthah: illā min ṣadaqatin jāriyah, aw ʿilmin yuntafaʿu bih, aw waladin ṣāliḥin yadʿū lah.',
    translation:
        'When a person dies, his deeds are cut off except from three: ongoing charity, knowledge that is benefited from, or a righteous child who prays for him.',
    source: 'Ṣaḥīḥ Muslim 1631',
    detail:
        'Beneficial knowledge that remains. Not a publication score, and not congratulations for being learned.',
  ),
  _item(
    id: 'kn.sharing.created.2_269',
    group: kKnowledgeGroupSharing,
    topic: 'Wrote or created something beneficial',
    text: 'He gives wisdom to whom He wills:',
    arabic: 'يُؤْتِي الْحِكْمَةَ مَن يَشَاءُ',
    transliteration: 'Yuʾtī l-ḥikmata man yashāʾ.',
    translation: 'He gives wisdom to whom He wills.',
    source: 'Qur’an 2:269',
    detail: 'Beneficial knowledge that remains. Not a publication score.',
  ),
  _item(
    id: 'kn.sharing.created.18_1',
    group: kKnowledgeGroupSharing,
    topic: 'Wrote or created something beneficial',
    text: 'Praise to Allah who sent down the Book to His servant:',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ',
    transliteration: 'Al-ḥamdu li-llāhi lladhī anzala ʿalā ʿabdihi l-kitāb.',
    translation: 'Praise is for Allah, who sent down the Book to His servant.',
    source: 'Qur’an 18:1',
    detail: 'Beneficial knowledge that remains. Not congratulations for being learned.',
  ),
  _item(
    id: 'kn.sharing.created.bukhari_3461',
    group: kKnowledgeGroupSharing,
    topic: 'Wrote or created something beneficial',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'بَلِّغُوا عَنِّي وَلَوْ آيَةً',
    transliteration: 'Ballighū ʿannī wa-law āyah.',
    translation: 'Convey from me, even if it is one verse.',
    source: 'Ṣaḥīḥ al-Bukhārī 3461',
    detail: 'Beneficial knowledge that remains. Not a publication score.',
  ),
  _item(
    id: 'kn.speech.heldback',
    group: kKnowledgeGroupSpeech,
    topic: 'Held back useless speech',
    text: 'Those who turn away from idle talk:',
    arabic: 'وَالَّذِينَ هُمْ عَنِ اللَّغْوِ مُعْرِضُونَ',
    transliteration: 'Wa-lladhīna hum ʿani l-laghwi muʿriḍūn.',
    translation: 'And those who turn away from idle talk.',
    source: 'Qur’an 23:3',
    detail:
        'Usefulness of words — gossip, argument, excessive joking. Not Character & Morals’ tone.',
  ),
  _item(
    id: 'kn.speech.heldback.17_53',
    group: kKnowledgeGroupSpeech,
    topic: 'Held back useless speech',
    text: 'Tell My servants to say that which is best:',
    arabic: 'وَقُل لِّعِبَادِي يَقُولُوا الَّتِي هِيَ أَحْسَنُ',
    transliteration: 'Wa qul li-ʿibādī yaqūlū allatī hiya aḥsan.',
    translation: 'Tell My servants to say that which is best.',
    source: 'Qur’an 17:53',
    detail: 'Usefulness of words. Not Character & Morals’ tone.',
  ),
  _item(
    id: 'kn.speech.heldback.bukhari_6018',
    group: kKnowledgeGroupSpeech,
    topic: 'Held back useless speech',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    transliteration:
        'Man kāna yuʾminu bi-llāhi wa-l-yawmi l-ākhiri fal-yaqul khayran aw li-yaṣmut.',
    translation:
        'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
    source: 'Ṣaḥīḥ al-Bukhārī 6018',
    detail: 'Usefulness of words — gossip, argument, excessive joking.',
  ),
  _item(
    id: 'kn.speech.heldback.tirmidhi_2317',
    group: kKnowledgeGroupSpeech,
    topic: 'Held back useless speech',
    text: 'The Messenger of Allah ﷺ said:',
    arabic: 'مِنْ حُسْنِ إِسْلَامِ الْمَرْءِ تَرْكُهُ مَا لَا يَعْنِيهِ',
    transliteration: 'Min ḥusni islāmi l-marʾi tarkuhu mā lā yaʿnīh.',
    translation:
        'Part of the excellence of a person’s Islam is leaving what does not concern him.',
    source: 'Jāmiʿ al-Tirmidhī 2317',
    detail: 'Usefulness of words. Not Character & Morals’ tone.',
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

PracticeHadithRecord recordFromKnowledgeCatalog({
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
    domain: MonitorDomain.knowledge,
    group: item.group,
    status: PracticeHadithStatus.learning,
  );
}
