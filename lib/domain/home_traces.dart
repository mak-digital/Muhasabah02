import 'quran.dart';

class HomeTraceRow {
  const HomeTraceRow({
    required this.storageKey,
    required this.label,
    required this.band,
    this.matrixColumn,
    this.matrixColumnVertical = false,
  });

  final String storageKey;
  final String label;
  final String band;
  final String? matrixColumn;
  final bool matrixColumnVertical;

  String get progressColumn => matrixColumn ?? label;
}

const kZakatTraceBand = 'Zakat status';
const kHajjPreparationKey = 'hajj.preparation';
const kHajjPreparationBand = 'Preparation';

String progressBandTitle(String band) => switch (band) {
  'Morning and evening' => 'Morning & Evening Adhkar',
  'Other remembrance' => 'Other Adhkar',
  'Community care' => 'Community Care',
  'Care in hardship' => 'Care in Hardship',
  'Extended family' => 'Extended Family',
  'Neighbours & work' => 'Neighbours & Work',
  'The people' => 'The People',
  'Seeking truth' => 'Seeking Truth',
  'Beneficial speech' => 'Beneficial Speech',
  'Illness & harm' => 'Illness & Harm',
  'Zakat status' => 'Zakat Status',
  'Preparation' => 'Preparation',
  _ => band,
};

const dhikrHomeRows = [
  HomeTraceRow(
    storageKey: 'dhikr.postFardFajr',
    label: 'Fajr',
    band: 'Post-fard Salah Adhkar',
    matrixColumn: 'Faj',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.postFardDhuhr',
    label: 'Dhuhr',
    band: 'Post-fard Salah Adhkar',
    matrixColumn: 'Dhr',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.postFardAsr',
    label: 'Asr',
    band: 'Post-fard Salah Adhkar',
    matrixColumn: 'Asr',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.postFardMaghrib',
    label: 'Maghrib',
    band: 'Post-fard Salah Adhkar',
    matrixColumn: 'Mag',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.postFardIsha',
    label: 'Isha',
    band: 'Post-fard Salah Adhkar',
    matrixColumn: 'Isa',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.morningAdhkar',
    label: 'Morning Adhkar',
    band: 'Morning and evening',
    matrixColumn: 'Mor-Adk',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'dhikr.eveningAdhkar',
    label: 'Evening Adhkar',
    band: 'Morning and evening',
    matrixColumn: 'Eve-Adk',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'dhikr.generalDhikr',
    label: 'General Dhikr',
    band: 'Other remembrance',
    matrixColumn: 'General',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'dhikr.gratitudeDhikr',
    label: 'Gratitude Dhikr',
    band: 'Other remembrance',
    matrixColumn: 'Gratitude',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'dhikr.travelDhikr',
    label: 'Travel Remembrance',
    band: 'Other remembrance',
    matrixColumn: 'Travel',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'dhikr.personalDhikr',
    label: 'Personal',
    band: 'Other remembrance',
    matrixColumn: 'Personal',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'dhikr.otherAdhkar',
    label: 'Other Adhkars',
    band: 'Other remembrance',
    matrixColumn: 'Other',
    matrixColumnVertical: true,
  ),
];

/// Retired Family traces kept so stored keys still have labels.
/// They are not shown on Home, check-in, or Progress.
const familyRetiredHomeRows = [
  HomeTraceRow(
    storageKey: 'family.parentsContact',
    label: 'Parent Contact',
    band: 'Parents',
    matrixColumn: 'Contact',
  ),
  HomeTraceRow(
    storageKey: 'family.parentsVisit',
    label: 'Parent Visit',
    band: 'Parents',
    matrixColumn: 'Visit',
  ),
  HomeTraceRow(
    storageKey: 'family.familyContact',
    label: 'Sibling Contact',
    band: 'Siblings',
    matrixColumn: 'Contact',
  ),
  HomeTraceRow(
    storageKey: 'family.siblingSupport',
    label: 'Sibling Support',
    band: 'Siblings',
    matrixColumn: 'Support',
  ),
  HomeTraceRow(
    storageKey: 'family.relativeContact',
    label: 'Relative Contact',
    band: 'Kinship',
    matrixColumn: 'Contact',
  ),
  HomeTraceRow(
    storageKey: 'family.kinshipCare',
    label: 'Kinship Support',
    band: 'Kinship',
    matrixColumn: 'Support',
  ),
  HomeTraceRow(
    storageKey: 'family.sickVisit',
    label: 'Sick Visit',
    band: 'Community care',
    matrixColumn: 'Visit',
  ),
  HomeTraceRow(
    storageKey: 'family.sickContact',
    label: 'Sick Contact',
    band: 'Community care',
    matrixColumn: 'Contact',
  ),
  HomeTraceRow(
    storageKey: 'family.supportUnderStress',
    label: 'Support Under Stress',
    band: 'Community care',
    matrixColumn: 'Stress',
  ),
];

const charityHomeRows = [
  HomeTraceRow(
    storageKey: 'charity.voluntary',
    label: 'Voluntary Charity',
    band: 'Giving',
    matrixColumn: 'Voluntary',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'charity.householdGiving',
    label: 'Family Support',
    band: 'Giving',
    matrixColumn: 'Family',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'charity.community',
    label: 'Community Support',
    band: 'Giving',
    matrixColumn: 'Community',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'charity.educational',
    label: 'Educational Support',
    band: 'Care',
    matrixColumn: 'Educational',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'charity.emergency',
    label: 'Emergency Support',
    band: 'Care',
    matrixColumn: 'Emergency',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'charity.financialStress',
    label: 'Support Under Financial Stress',
    band: 'Care',
    matrixColumn: 'Financial',
    matrixColumnVertical: true,
  ),
];

const hajjHomeRows = [
  HomeTraceRow(
    storageKey: kHajjPreparationKey,
    label: 'Noticed preparation',
    band: kHajjPreparationBand,
    matrixColumn: 'Prep',
  ),
];

const fastingHomeRows = [
  HomeTraceRow(
    storageKey: 'fasting.weeklySunnah',
    label: 'Weekly Sunnah Fast',
    band: 'Voluntary and make-up',
    matrixColumn: 'Sunnah',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'fasting.monthly',
    label: 'White Days (Ayyam Al-Bid)',
    band: 'Voluntary and make-up',
    matrixColumn: 'White Days',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'fasting.makeup',
    label: 'Make-up Fast',
    band: 'Voluntary and make-up',
    matrixColumn: 'Make-up',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'fasting.ramadanPrep',
    label: 'Ramadan Preparation',
    band: 'Voluntary and make-up',
    matrixColumn: 'Ramadan',
    matrixColumnVertical: true,
  ),
];

const hadithHomeRows = [
  HomeTraceRow(
    storageKey: 'hadith.reading',
    label: 'Reading',
    band: 'Encounter',
    matrixColumn: 'Read',
  ),
  HomeTraceRow(
    storageKey: 'hadith.listening',
    label: 'Listening',
    band: 'Encounter',
    matrixColumn: 'Listen',
  ),
  HomeTraceRow(
    storageKey: 'hadith.memorisation',
    label: 'Memorisation',
    band: 'Retention',
    matrixColumn: 'Memorise',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'hadith.revision',
    label: 'Revision',
    band: 'Retention',
    matrixColumn: 'Revise',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'hadith.studyCircle',
    label: 'Study Circle',
    band: 'Learning',
    matrixColumn: 'Circle',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'hadith.teachingDiscussion',
    label: 'Teaching / Discussion',
    band: 'Learning',
    matrixColumn: 'Teach',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'hadith.reflection',
    label: 'Hadith Reflection',
    band: 'Notice',
    matrixColumn: 'Reflect',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'hadith.livedSunnah',
    label: 'Noticed a sunnah in how I lived today',
    band: 'Live',
    matrixColumn: 'Lived',
    matrixColumnVertical: true,
  ),
];

const akhlaqHomeRows = [
  HomeTraceRow(
    storageKey: 'akhlaq.patience',
    label: 'Patience',
    band: 'Virtues I noticed',
    matrixColumn: 'Patience',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.humility',
    label: 'Humility',
    band: 'Virtues I noticed',
    matrixColumn: 'Humility',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.truthfulness',
    label: 'Truthfulness',
    band: 'Virtues I noticed',
    matrixColumn: 'Truth',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.gentleness',
    label: 'Gentleness',
    band: 'Virtues I noticed',
    matrixColumn: 'Gentle',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.courage',
    label: 'Courage',
    band: 'Virtues I noticed',
    matrixColumn: 'Courage',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.gratitude',
    label: 'Thankfulness in how I acted',
    band: 'Virtues I noticed',
    matrixColumn: 'Thanks',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.contentment',
    label: 'Contentment',
    band: 'Virtues I noticed',
    matrixColumn: 'Content',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.pausedBeforeReacting',
    label: 'Paused before reacting',
    band: 'Anger, honesty, forgiveness',
    matrixColumn: 'Pause',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.honestyInSmallMatters',
    label: 'Honesty in small matters',
    band: 'Anger, honesty, forgiveness',
    matrixColumn: 'Honesty',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.letGoOfGrudge',
    label: 'Let go of a grudge',
    band: 'Anger, honesty, forgiveness',
    matrixColumn: 'Forgive',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.modestSpeech',
    label: 'Guarded how I spoke (tone)',
    band: 'Modesty',
    matrixColumn: 'Tone',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.modestDress',
    label: 'Modest dress',
    band: 'Modesty',
    matrixColumn: 'Dress',
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.modestGaze',
    label: 'Guarded my gaze',
    band: 'Modesty',
    matrixColumn: 'Gaze',
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.walkedAwayFromArgument',
    label: 'Walked away from an argument',
    band: 'Restraint',
    matrixColumn: 'Walk away',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'akhlaq.heldBackFromAHabit',
    label: 'Held back from a habit I am trying to leave',
    band: 'Restraint',
    matrixColumn: 'Habit',
    matrixColumnVertical: true,
  ),
];

/// Glance row kept for stored records and Historical Reflection.
/// Home, check-in, and Progress use Guarded my gaze (`akhlaq.modestGaze`).
const akhlaqRetiredHomeRows = [
  HomeTraceRow(
    storageKey: 'akhlaq.guardedMyGlance',
    label: 'Guarded my glance',
    band: 'Restraint',
    matrixColumn: 'Glance',
    matrixColumnVertical: true,
  ),
];

const akhlaqAllHomeRows = [...akhlaqRetiredHomeRows, ...akhlaqHomeRows];

const huquqHomeRows = [
  HomeTraceRow(
    storageKey: 'huquq.parents',
    label: 'Parents',
    band: 'Household',
    matrixColumn: 'Parents',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.spouse',
    label: 'Spouse',
    band: 'Household',
    matrixColumn: 'Spouse',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.children',
    label: 'Children',
    band: 'Household',
    matrixColumn: 'Children',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.siblings',
    label: 'Siblings',
    band: 'Household',
    matrixColumn: 'Siblings',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.grandparents',
    label: 'Grandparents',
    band: 'Household',
    matrixColumn: 'Grandparents',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.otherRelatives',
    label: 'Other relatives',
    band: 'Extended family',
    matrixColumn: 'Relatives',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.neighbours',
    label: 'Neighbours',
    band: 'Neighbours & work',
    matrixColumn: 'Neighbours',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.colleaguesFriends',
    label: 'Colleagues & friends',
    band: 'Neighbours & work',
    matrixColumn: 'Friends',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.muslims',
    label: 'Fellow Muslims',
    band: 'The people',
    matrixColumn: 'Muslims',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.nonMuslims',
    label: 'Non-Muslims',
    band: 'The people',
    matrixColumn: 'Non-Muslims',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.reconciliation',
    label: 'A step toward reconciliation',
    band: 'Repair',
    matrixColumn: 'Sulh',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.returnedFromNeglect',
    label: 'Turned back over a neglected right',
    band: 'Repair',
    matrixColumn: 'Return',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'huquq.sickVisit',
    label: 'Sick Visit',
    band: 'Care in hardship',
    matrixColumn: 'Visit',
  ),
  HomeTraceRow(
    storageKey: 'huquq.sickContact',
    label: 'Sick Contact',
    band: 'Care in hardship',
    matrixColumn: 'Contact',
  ),
  HomeTraceRow(
    storageKey: 'huquq.supportUnderStress',
    label: 'Support Under Stress',
    band: 'Care in hardship',
    matrixColumn: 'Stress',
  ),
];

const knowledgeHomeRows = [
  HomeTraceRow(
    storageKey: 'knowledge.learnedSomethingTrue',
    label: 'Learned something true',
    band: 'Seeking truth',
    matrixColumn: 'Learned',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'knowledge.beneficialReading',
    label: 'Beneficial reading (not Qur’an or Hadith)',
    band: 'Seeking truth',
    matrixColumn: 'Reading',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'knowledge.askedToRemoveIgnorance',
    label: 'Asked to remove ignorance',
    band: 'Seeking truth',
    matrixColumn: 'Asked',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'knowledge.taughtSomeone',
    label: 'Taught someone',
    band: 'Sharing',
    matrixColumn: 'Taught',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'knowledge.sincereAdvice',
    label: 'Sincere advice',
    band: 'Sharing',
    matrixColumn: 'Advice',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'knowledge.beneficialCreating',
    label: 'Wrote or created something beneficial',
    band: 'Sharing',
    matrixColumn: 'Created',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'knowledge.heldBackUselessSpeech',
    label: 'Held back useless speech',
    band: 'Beneficial speech',
    matrixColumn: 'Restraint',
    matrixColumnVertical: true,
  ),
];

/// Prayer-window row kept for stored records and Historical Reflection.
/// The fard is on Salah; Time Home does not show a second prayer log.
const timeRetiredHomeRows = [
  HomeTraceRow(
    storageKey: 'time.guardedPrayerWindow',
    label: 'Guarded a prayer window from waste',
    band: 'Presence',
    matrixColumn: 'Prayer',
    matrixColumnVertical: true,
  ),
];

const timeHomeRows = [
  HomeTraceRow(
    storageKey: 'time.presentInWhatIWasDoing',
    label: 'Present in what I was doing',
    band: 'Presence',
    matrixColumn: 'Present',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'time.didWhatIDelayed',
    label: 'Did something I had delayed',
    band: 'Trust',
    matrixColumn: 'Delayed',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'time.steppedAwayFromIdleTime',
    label: 'Stepped away from idle time',
    band: 'Trust',
    matrixColumn: 'Idle',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'time.restedAsNeeded',
    label: 'Rested from work as needed',
    band: 'Rest',
    matrixColumn: 'Rested',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'time.beganWithIntention',
    label: 'Began with intention',
    band: 'Rest',
    matrixColumn: 'Intention',
    matrixColumnVertical: true,
  ),
];

const timeAllHomeRows = [...timeRetiredHomeRows, ...timeHomeRows];

const healthHomeRows = [
  HomeTraceRow(
    storageKey: 'health.sleepQuality',
    label: 'Sleep quality',
    band: 'Sleep',
    matrixColumn: 'Quality',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.sleepAmount',
    label: 'Sleep amount',
    band: 'Sleep',
    matrixColumn: 'Amount',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.movement',
    label: 'Movement for worship and service',
    band: 'Strength',
    matrixColumn: 'Movement',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.energyForIbadah',
    label: 'Energy for ibadah',
    band: 'Strength',
    matrixColumn: 'Energy',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.nutrition',
    label: 'Nutrition',
    band: 'Sustenance',
    matrixColumn: 'Nutrition',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.hydration',
    label: 'Hydration',
    band: 'Sustenance',
    matrixColumn: 'Hydration',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.illnessCare',
    label: 'Sought care in illness',
    band: 'Illness & harm',
    matrixColumn: 'Illness',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'health.avoidedHarm',
    label: 'Avoided a harm to the body',
    band: 'Illness & harm',
    matrixColumn: 'Harm',
    matrixColumnVertical: true,
  ),
];

const wealthRetiredHomeRows = [
  HomeTraceRow(
    storageKey: 'wealth.gaveSadaqah',
    label: 'Gave sadaqah',
    band: 'Giving',
    matrixColumn: 'Sadaqah',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'wealth.zakatAttention',
    label: 'Attended to zakat',
    band: 'Giving',
    matrixColumn: 'Zakat',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'wealth.generosity',
    label: 'Hosted, gifted, or spent on family',
    band: 'Giving',
    matrixColumn: 'Generosity',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'wealth.sadaqahJariyah',
    label: 'Ongoing charity (sadaqah jariyah)',
    band: 'Giving',
    matrixColumn: 'Jariyah',
    matrixColumnVertical: true,
  ),
];

const wealthHomeRows = [
  HomeTraceRow(
    storageKey: 'wealth.halalEarning',
    label: 'Earned from a halal source',
    band: 'Earning',
    matrixColumn: 'Halal',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'wealth.avoidedRiba',
    label: 'Stayed clear of riba',
    band: 'Earning',
    matrixColumn: 'Riba',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'wealth.avoidedWaste',
    label: 'Avoided waste',
    band: 'Restraint',
    matrixColumn: 'Waste',
    matrixColumnVertical: true,
  ),
];

const wealthAllHomeRows = [...wealthRetiredHomeRows, ...wealthHomeRows];

const ummahRetiredHomeRows = [
  HomeTraceRow(
    storageKey: 'ummah.communityService',
    label: 'Served beyond myself',
    band: 'Service',
    matrixColumn: 'Service',
    matrixColumnVertical: true,
  ),
];

const ummahHomeRows = [
  HomeTraceRow(
    storageKey: 'ummah.masjidAttendance',
    label: 'Masjid class or gathering (not the fard)',
    band: 'Masjid',
    matrixColumn: 'Masjid',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'ummah.dawahByCharacter',
    label: 'Da’wah by character',
    band: 'Witness',
    matrixColumn: 'Character',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'ummah.supportedOppressed',
    label: 'Supported the oppressed',
    band: 'Solidarity',
    matrixColumn: 'Oppressed',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'ummah.unityEfforts',
    label: 'Worked for unity',
    band: 'Solidarity',
    matrixColumn: 'Unity',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'ummah.prayedForUmmah',
    label: 'Prayed for the Ummah',
    band: 'Solidarity',
    matrixColumn: 'Dua',
    matrixColumnVertical: true,
  ),
  HomeTraceRow(
    storageKey: 'ummah.earthCare',
    label: 'Cared for the earth',
    band: 'Earth',
    matrixColumn: 'Earth',
    matrixColumnVertical: true,
  ),
];

const ummahAllHomeRows = [...ummahRetiredHomeRows, ...ummahHomeRows];

bool isAkhlaqTrace(String storageKey) => storageKey.startsWith('akhlaq.');

bool isHuquqTrace(String storageKey) => storageKey.startsWith('huquq.');

bool isKnowledgeTrace(String storageKey) => storageKey.startsWith('knowledge.');

bool isTimeTrace(String storageKey) => storageKey.startsWith('time.');

bool isHealthTrace(String storageKey) => storageKey.startsWith('health.');

bool isWealthTrace(String storageKey) => storageKey.startsWith('wealth.');

bool isUmmahTrace(String storageKey) => storageKey.startsWith('ummah.');

bool isLivedSunnahTrace(String storageKey) =>
    storageKey == 'hadith.livedSunnah';

bool isHajjTrace(String storageKey) => storageKey.startsWith('hajj.');

bool hidesHomeTraceFactors(String storageKey) =>
    isAkhlaqTrace(storageKey) ||
    isHuquqTrace(storageKey) ||
    isKnowledgeTrace(storageKey) ||
    isTimeTrace(storageKey) ||
    isHealthTrace(storageKey) ||
    isWealthTrace(storageKey) ||
    isUmmahTrace(storageKey) ||
    isLivedSunnahTrace(storageKey) ||
    isHajjTrace(storageKey);

String namedTraceOutcome(String phrase, String storageKey) {
  final subject = homeTraceRowByKey(storageKey)?.label;
  if (subject == null || subject.isEmpty) return phrase;
  return '$phrase — $subject';
}

String traceOutcomeLabel(String storageKey, TernaryOutcome outcome) {
  if (isHuquqTrace(storageKey)) {
    return namedTraceOutcome(switch (outcome) {
      TernaryOutcome.positive => 'I attended to a right I owe',
      TernaryOutcome.negative => 'I neglected a right I owe',
      TernaryOutcome.unanswered => 'Unanswered',
    }, storageKey);
  }
  if (isAkhlaqTrace(storageKey) ||
      isKnowledgeTrace(storageKey) ||
      isTimeTrace(storageKey) ||
      isHealthTrace(storageKey) ||
      isWealthTrace(storageKey) ||
      isHajjTrace(storageKey) ||
      isUmmahTrace(storageKey) ||
      isLivedSunnahTrace(storageKey)) {
    return namedTraceOutcome(switch (outcome) {
      TernaryOutcome.positive => 'I noticed this in myself',
      TernaryOutcome.negative => 'I did not notice this today',
      TernaryOutcome.unanswered => 'Unanswered',
    }, storageKey);
  }
  return namedTraceOutcome(outcome.legendLabel, storageKey);
}

const allHomeTraceRows = [
  ...dhikrHomeRows,
  ...akhlaqAllHomeRows,
  ...huquqHomeRows,
  ...knowledgeHomeRows,
  ...timeAllHomeRows,
  ...healthHomeRows,
  ...wealthAllHomeRows,
  ...ummahAllHomeRows,
  ...familyRetiredHomeRows,
  ...charityHomeRows,
  ...fastingHomeRows,
  ...hajjHomeRows,
  ...hadithHomeRows,
];

HomeTraceRow? homeTraceRowByKey(String storageKey) {
  for (final row in allHomeTraceRows) {
    if (row.storageKey == storageKey) return row;
  }
  return null;
}

List<String> bandsFor(List<HomeTraceRow> rows) {
  final seen = <String>[];
  for (final row in rows) {
    if (!seen.contains(row.band)) seen.add(row.band);
  }
  return seen;
}

Map<String, TernaryOutcome> tracesFromJson(Object? json) {
  final traces = <String, TernaryOutcome>{};
  if (json is! Map) return traces;
  for (final entry in json.entries) {
    traces['${entry.key}'] = ternaryFromJson(entry.value);
  }
  return traces;
}

Map<String, String> tracesToJson(Map<String, TernaryOutcome> traces) {
  return {
    for (final entry in traces.entries)
      if (entry.value != TernaryOutcome.unanswered)
        entry.key: entry.value == TernaryOutcome.positive
            ? 'positive'
            : 'didNot',
  };
}

enum HajjStatus { unanswered, notDue, due, preparing, performed, notApplicable }

extension HajjStatusX on HajjStatus {
  bool get isRecorded => this != HajjStatus.unanswered;

  bool get showsPreparation =>
      this == HajjStatus.due || this == HajjStatus.preparing;

  String get label => switch (this) {
    HajjStatus.unanswered => 'Not recorded',
    HajjStatus.notDue => 'Not due',
    HajjStatus.due => 'Due',
    HajjStatus.preparing => 'Preparing',
    HajjStatus.performed => 'Performed',
    HajjStatus.notApplicable => 'Not applicable',
  };

  static HajjStatus fromId(String? id) {
    return HajjStatus.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjStatus.unanswered,
    );
  }
}

List<HomeTraceRow> hajjRowsForStatus(
  List<HomeTraceRow> rows,
  HajjStatus status,
) {
  if (status.showsPreparation) return rows;
  return [
    for (final row in rows)
      if (row.storageKey != kHajjPreparationKey) row,
  ];
}

enum HadithMemorisationFocus { unanswered, reviewing, memorising, memorised }

extension HadithMemorisationFocusX on HadithMemorisationFocus {
  String get label => switch (this) {
    HadithMemorisationFocus.unanswered => 'Not recorded',
    HadithMemorisationFocus.reviewing => 'Reviewing',
    HadithMemorisationFocus.memorising => 'Memorising',
    HadithMemorisationFocus.memorised => 'Memorised',
  };

  static HadithMemorisationFocus fromId(String? id) {
    return HadithMemorisationFocus.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HadithMemorisationFocus.unanswered,
    );
  }
}
