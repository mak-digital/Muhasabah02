import 'monitor_domain.dart';

enum FaqSection {
  purpose,
  flexibility,
  recording,
  domains,
  lookingBack,
  preferences,
}

String faqSectionTitle(FaqSection section) => switch (section) {
  FaqSection.purpose => 'Purpose',
  FaqSection.flexibility => 'Your mix',
  FaqSection.recording => 'Recording',
  FaqSection.domains => 'Live domains',
  FaqSection.lookingBack => 'Looking back',
  FaqSection.preferences => 'Preferences',
};

class FaqEntry {
  const FaqEntry({
    this.id,
    this.domain,
    this.section,
    required this.question,
    required this.answer,
    this.compare,
  });

  final String? id;
  final MonitorDomain? domain;
  final FaqSection? section;
  final String question;
  final String answer;
  final FaqCompareTable? compare;

  /// General topics and live-season domains. Dormant-domain items stay listed.
  bool get isCurrentVersion =>
      domain == null || !isDormantMonitorDomain(domain!);
}

class FaqCompareTable {
  const FaqCompareTable({
    required this.leftHeader,
    required this.rightHeader,
    required this.rows,
  });

  final String leftHeader;
  final String rightHeader;
  final List<FaqCompareRow> rows;
}

class FaqCompareRow {
  const FaqCompareRow({
    required this.label,
    required this.left,
    required this.right,
  });

  final String label;
  final String left;
  final String right;
}

const baselineAspirationCompare = FaqCompareTable(
  leftHeader: 'Baselines',
  rightHeader: 'Aspirations',
  rows: [
    FaqCompareRow(
      label: 'Based on',
      left: 'Your check-in records, or a memory note',
      right: 'Your own wording or checkboxes',
    ),
    FaqCompareRow(
      label: 'Answers',
      left: 'What did I record in that period?',
      right: 'What do I personally hope for?',
    ),
    FaqCompareRow(
      label: 'Updates',
      left: 'Frozen when you create it',
      right: 'Until you change or remove it',
    ),
    FaqCompareRow(label: 'Judged?', left: 'No', right: 'No'),
  ],
);

const manageCheckInsCompare = FaqCompareTable(
  leftHeader: 'Manage past check-ins',
  rightHeader: 'Recorded days',
  rows: [
    FaqCompareRow(
      label: 'Purpose',
      left: 'Correct or remove a saved day',
      right: 'Look at what was recorded',
    ),
    FaqCompareRow(label: 'Changes records?', left: 'Yes', right: 'No'),
    FaqCompareRow(
      label: 'Typical path',
      left: 'Registry → History, or Settings → Account & data',
      right: 'Review → Recorded days',
    ),
  ],
);

const kFaqManualBaseline = 'manual-baseline';

String faqItemNumber(int index) => (index + 1).toString().padLeft(2, '0');

const faqEntries = <FaqEntry>[
  FaqEntry(
    section: FaqSection.purpose,
    question: 'Does the app score me or keep streaks?',
    answer: 'No. Private Muhasabah is a recorder, not a judge. It does not assign scores, ranks, streaks, badges, or success percentages. It stores what you enter and lets you look at it later.',
  ),
  FaqEntry(
    section: FaqSection.purpose,
    question: 'What is missing compared with missed?',
    answer: 'Not recorded is not the same as missed. An unanswered day or row stays unanswered. The app never fills missed for you, and missing records are not treated as failure.',
  ),
  FaqEntry(
    section: FaqSection.purpose,
    question: 'Are my records private if the phone is lost?',
    answer: 'Days stay on this device. There is no account and no cloud copy. Android backup of this app is off.\n\nThe phone lock is the main protection if the device is lost. Settings → Privacy → Unlock with this device can ask for this phone’s PIN, pattern, or biometrics before the app is shown. Muhasabah does not store a separate password.\n\nThat lock does not encrypt the files. Anyone who can open an unlocked phone can read the days if Unlock with this device is off. Removing a saved day is not forensic erasure.',
  ),
  FaqEntry(
    section: FaqSection.flexibility,
    question: 'Can I hide domains I do not want to monitor?',
    answer: 'Settings → Preferences → Domains in Focus chooses which live domains belong in this profile. Leave a domain off if it does not apply. The first look is Salah, Qur’an & Dhikr. Hadith, Character, Rights, Charity, and Fasting stay available if you add them. All domains is one tap for the eight live domains this season.\n\nKnowledge, Time, Health, Wealth, Ummah, Hajj, and Productivity stay listed so you can find them, but they are grayed and not selectable. Hidden domains keep any saved records. Showing them again does not rewrite those records.',
  ),
  FaqEntry(
    section: FaqSection.flexibility,
    question: 'What is a Personal mix?',
    answer: 'The mix, on the same Domains in Focus screen, is which bands and rows you want to notice. It is a subset of the live domains you show — not a score, a programme, or a second hide-list. Named starting points copy a set you can edit. Same as Domains follows whatever is already shown.\n\nHome, Review, Progress, today’s check-in, and Quick Tap follow that mix. Unanswered mix rows are not missed. A mix row on a hidden live domain is kept and appears when that domain is shown. Mix rows for domains not in this version stay stored and grayed.',
  ),
  FaqEntry(
    section: FaqSection.recording,
    question: 'Where is the meaning of the week-grid marks?',
    answer: 'Home → Guide explains the circles and diamonds. Missing is not missed. Factors you noticed do not change those marks.',
  ),
  FaqEntry(
    section: FaqSection.recording,
    question: 'Why do the colours differ?',
    answer: 'The card wash names the domain, such as Salah or Qur’an. Marks share one colour by default. Settings → Preferences → Activities & legend may colour Salah, Qur’an, Dhikr, Hadith, Fasting, Character, Rights, and Charity by the recorded choice. Colour names what was recorded. It does not rank spirituality, success, or worth.',
  ),
  FaqEntry(
    section: FaqSection.recording,
    question: 'How do Salah marks and the Salah list work?',
    answer: 'Settings → Preferences → Activities & legend can colour Salah marks (and the other live-domain marks above) by the recorded choice. Shared colour remains the default. A demonstrated virtue uses the same blue as congregation on time. Colour names what was recorded. It does not rank spirituality.\n\nSettings → Preferences → Salah list for me may record Female, Male, Prefer not to say, or Not recorded. This only changes whether Excused appears on obligatory Salah and Jumu‘ah. It is not a ruling. Not recorded keeps Excused visible. Male hides it. Excused is for days those prayers are not required (such as hayd or nifas), and is never treated as missed. Saved days are not rewritten.\n\nSalah & Prayer Quality Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home. You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a khushu’ score or daily grade. Unanswered is not missed.',
  ),
  FaqEntry(
    section: FaqSection.recording,
    question: 'What do Helping and Distracting factors mean?',
    answer: 'Optional notes of what you noticed around a recorded choice. They never cause an outcome, complete a day, or create a score. You may leave them as Not recorded.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.quran,
    question: 'How do Qur’an rows and notes work?',
    answer: 'Three independent duration rows sit under ENGAGEMENT with Qur’an: Engagement (recitation, memorisation and/or revision), Understanding & reflection (meaning and/or tafsir plus pondering), and Practical relevance (noticing implications or use of learnt verses). They are not a khushu’ score. Unanswered is not “not engaged”.\n\nQur’an to learn & practice is a built-in verse list you may add to a private register. It is not a recitation streak.\n\nOptional notes from a check-in save in My Notes, linked to that day. Application Reflection is first-install framing and Settings → About — not a daily field or evidence of action.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.hadith,
    question: 'Does Hadith & Living Sunnah score my revival of the Sunnah?',
    answer: 'No. Four rows under ENGAGED with Hadith: read and/or listened, memorization/revision, study circle/discussion, and lived or noticed in others. The first three use the same duration steps as Qur’an. Lived /Noticed others is one observation — not a revival programme or a completed checklist.\n\nCharacter stays who you were. The same afternoon may be both. The app does not fill Living Sunnah from Character. Hadith to learn & practice is a private register you may add to. Unanswered is not a failed revival.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.dhikr,
    question: 'Does Dhikr & Dua score my remembrance?',
    answer: 'No. Post-fard Salah Adhkar, Morning, Evening, General, Gratitude, Travel, Personal, and Other Adhkars each use a performed list. Tick a formula as practised, with an optional count. Unticked stays unanswered, not missed. Not today and Prefer not to record are explicit. Personal dua records a topic without requiring the words.\n\nOn Review → 30 days, those rows can show A/B/C bars of practised formulas on answered days only. 7-day Progress stays the week grid. 90-day Progress stays a calendar. Dhikr Learn & Practice is a reminder list, not a target count. Unanswered is not missed dhikr.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.fasting,
    question: 'Does Fasting score my sawm?',
    answer: 'No. Two sections: Ramadan fasting & excellence, and voluntary and make-up. Not recorded is empty, not a missed fast. Prefer not to record is a privacy choice. The app does not judge validity, exemption, make-up, or fidyah. An exemption is not a failure. Fasting today is not auto-completed after iftar.\n\nCivil Hijri 13–15 on Progress is orientation only. Settings → Calendar can shift Ramadan by a day for local moon sighting. Shawwal six fasts are voluntary; an actual make-up stays on Make-up Fast. Fasting Learn & Practice is not a countdown or a prescription to fast.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.akhlaq,
    question: 'Does Character & Morals grade me?',
    answer: 'No. Record what you noticed in yourself — not someone else’s flaw, and not a good/bad verdict. Each row has its own wording. Corrective action is not the same as avoiding the original lapse. Unanswered on the habit row is not a relapse.\n\nPatience may be silence or firmness. Guarded how I spoke is tone. Thankfulness in how I acted is character; Gratitude Dhikr is remembrance. Optional context and a private struggle note are provenance, not a grade.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.huquq,
    question: 'Does Rights of Others score my relationships?',
    answer: 'No. This is what you owe others, not a chore list, a relationship score, or a ledger of what they owe you. Lack of daily contact is not neglect. Do not name others’ faults here. Safety and justice come first — the app does not tell anyone to endure harm, and reconciliation is never required where it would be unsafe.\n\nCare in hardship (sick visit, sick contact, support under stress) is a right of brotherhood, not a sadaqah channel. Ordinary household support stays here; extra gifts sit on Charity. Learn & Practice is a reminder list, not a to-do. Unanswered is not neglect.',
  ),
  FaqEntry(
    section: FaqSection.domains,
    domain: MonitorDomain.charity,
    question: 'Does Charity score my giving?',
    answer: 'No. Record giving and care you noticed — without amounts, names, or a generosity rank. Prefer not to record is not the same as not recorded. No relevant opportunity is not withheld charity. A smile is sadaqah. Poverty is not a failing.\n\nOrdinary household nafaqa stays on Rights of Others. Zakat is a separate status (paid, arranged, reviewing, not currently due, or due but not yet paid) — not a calculator and not a daily missed obligation. Charity Learn & Practice is not a daily grade.',
  ),
  FaqEntry(
    section: FaqSection.lookingBack,
    question: 'What do the 30-day Progress graphs show?',
    answer: 'Review → a domain → 30 days. Each Home row can compare three windows: A (older), B, and C (current). Bars describe answered days only. Unanswered days are left out — not missed, and not treated as zero.\n\nChecklist rows such as Morning Adhkar can count more than one practised formula on the same day. 7-day Progress stays the week grid. 90-day Progress stays a calendar, not this graph.\n\nIf you load sample days, later windows can look busier than earlier ones so you can try the graphs. That is a demonstration, not a target, and not a verdict that you improved.',
  ),
  FaqEntry(
    section: FaqSection.lookingBack,
    question: 'What is Recognition?',
    answer: 'Recognition lives on Review for 30- and 90-day views. It describes what you recorded, with a way to view the evidence. It does not say you improved or declined, and it does not prescribe what to do next.',
  ),
  FaqEntry(
    section: FaqSection.lookingBack,
    question: 'What is Manage past check-ins compared with Recorded days?',
    answer: 'Manage past check-ins is housekeeping: tap a date to edit, or long-press to remove the app’s record. Removal is not forensic erasure.\n\nRecorded days (Historical Reflection) is read-only. It shows exactly what was recorded so you can look without changing it. After you edit or remove a day, Home, Review, and Progress read the updated records.',
    compare: manageCheckInsCompare,
  ),
  FaqEntry(
    section: FaqSection.lookingBack,
    question: 'What are Baselines compared with Personal Aspirations?',
    answer: 'A baseline looks back at what you already recorded. A personal aspiration looks forward as a hope you name. Neither is a score. Neither currently changes Home, Review, or check-in.',
    compare: baselineAspirationCompare,
  ),
  FaqEntry(
    id: kFaqManualBaseline,
    section: FaqSection.lookingBack,
    question: 'How do I write a Manual baseline?',
    answer: 'A short note about a pattern you already noticed. It is not counted from check-ins, and it is not a score. A hope for later belongs under Personal Aspirations. It does not change Home, Review, or check-in.\n\nFits: “Morning Adhkar showed up more on weekdays than on Friday last season.” Does not fit: a percentage, a streak, a weekly quota, or “must improve.”',
  ),
  FaqEntry(
    section: FaqSection.preferences,
    question: 'Can I show Islamic dates?',
    answer: 'Settings → Preferences → Calendar can show Gregorian or Islamic (Hijri) dates. This only changes how dates are displayed. Saved days stay on the civil calendar day they were stored. The Islamic option uses the civil (tabular) Hijri calendar; moon sighting may differ by a day.\n\nFasting Progress also highlights civil Hijri 13, 14 and 15 so White Days are easier to locate. That highlight is orientation only. It does not record a fast or tell you to fast.',
  ),
  FaqEntry(
    section: FaqSection.preferences,
    question: 'Where do Home quotes come from?',
    answer: 'Home quotations rotate by calendar in Settings → Preferences → Quotation cadence. Weekly keeps one quote for the week. Daily uses a new quote each local day. Hidden removes the card. You can step to the next or previous quote; the one you stop on stays until the next day or week.\n\nEach domain has cited Qur’an verses and well-known authentic hadith. Open citation loads the public page in this app. This app does not send your records. Quotes are not chosen from your records.',
  ),
  FaqEntry(
    domain: MonitorDomain.knowledge,
    question: 'Does Knowledge & Beneficial Speech grade how learned I am?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved records stay. Home, Review, and check-in do not use it yet.\n\nNo. Each row has its own wording for a beneficial activity, partial engagement, a recognised gap, a correction, no relevant situation, or unanswered. Colour names the recorded choice when activity colours are on. It is not a knowledge grade, intelligence score, or religious ranking. A single new fact is enough. Hours studied and the number of sources consulted are not a quality measure. Debate is not knowledge engagement, and controversial content is not logged here. Reading, asking, teaching, or creating does not prove the information is correct. AI-assisted learning is not treated as verified.\n\nQur’an Engagement and Hadith & Living Sunnah have their own cards. This is other learning and speech. Held back useless speech is usefulness, not Character & Morals’ tone. The app never congratulates anyone for being learned. Optional type, source, verification, understanding, application, quantity, and private reflection are provenance only.\n\nKnowledge & Beneficial Speech Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Seeking truth, Sharing, Beneficial speech). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a study-hour badge. Unanswered is not ignorance.',
  ),
  FaqEntry(
    domain: MonitorDomain.time,
    question: 'Does Time & Barakah score my productivity?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved records stay. Home, Review, and check-in do not use it yet.\n\nNo. It stores independent observations of intention, attention, action, and balance (eight optional practices). Each row records one descriptive observation: beneficial action, partial effort, a recognised lapse, a corrective adjustment, no relevant situation, or unanswered. Corrected is not ranked above acted. Optional context, challenge, what helped, outcome, and a quantity are stored as you report them — not as a spiritual grade, a productivity score, or an estimate of barakah. Needed rest is not wasted time. Recreation is not automatically wasted. Illness, caregiving, and unavoidable interruptions are not failings. The fard stays on Salah. Sleep stays on Physical Health. Hours and hustle badges are not recorded. Unanswered is not wasted time. The app never congratulates anyone for being productive, and does not prescribe a schedule.\n\nTime & Barakah Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Intention & Priority, Attention & Presence, Responsibility & Action, Balance & Renewal). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a timetable, or a claim of barakah. Unanswered is not wasted time.',
  ),
  FaqEntry(
    domain: MonitorDomain.health,
    question: 'Does Physical Health & Energy grade my body?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved records stay. Home, Review, and check-in do not use it yet.\n\nNo. It stores independent observations of sleep, movement for worship and service, nutrition, hydration, seeking care in illness, avoiding harm, and energy for ibadah. Each row records one descriptive observation, including prefer not to record, which is not unanswered. Sleeping poorly is not a failure. Seeking medical care is not ranked as better health than having no illness. Sleep quality and amount are not hour badges and not Time & Barakah’s rest from work. Calories, weight, and body metrics are not recorded. Illness, disability, ageing, fatigue, and prescribed treatment are not failings. Physical and mental health are intertwined. This is not a fitness app, and the app never shames a body.\n\nPhysical Health & Energy Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Sleep, Strength, Sustenance, Illness & harm). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a fitness programme, or a body score. Unanswered is not a failing of the body.',
  ),
  FaqEntry(
    domain: MonitorDomain.wealth,
    question: 'Does Wealth & Stewardship score my money?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved records stay. Home, Review, and check-in do not use it yet.\n\nNo. It stores independent observations of a lawful source, staying clear of riba, avoiding waste, and managing wealth as a trust. Each row records one descriptive observation, including no relevant activity and prefer not to record, which is not unanswered. An unresolved concern is not a legal ruling. No relevant activity is not a failure. Giving — sadaqah, family or community support, and zakat due, planned, or paid — is on Charity. Amounts, accounts, and creditor names are not recorded. A smile is sadaqah.\n\nNet worth and savings are not spiritual metrics. Poverty and debt are not failings. Wealth is not a sign of Allah’s pleasure. There is no charity leaderboard, no most-generous badge, and no zakat calculator.\n\nWealth & Stewardship Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Earning, Restraint, Lawful wealth management). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a money score. Unanswered is not a failing of provision.',
  ),
  FaqEntry(
    domain: MonitorDomain.ummah,
    question: 'Does Ummah grade my social life?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved records stay. Home, Review, and check-in do not use it yet.\n\nNo. It stores independent observations of a masjid class or gathering (not the fard), da’wah by character, supporting the oppressed, unity, praying for the Ummah, and care for the earth. Each row records one descriptive observation, including no relevant opportunity and prefer not to record, which is not unanswered. Remote participation is not recorded as being physically present. Du’a is distinct from practical help. The fard and Jumu‘ah stay on Salah. Help to a neighbour, community giving, and sick care stay on Rights of Others and Charity. Masjid marks here are private, not a public check-in.\n\nPolitical rants and sectarian arguments are not logged here. Introversion and social anxiety are not failings. Isolation is not a failing. The Ummah is global, not an ethnic group.\n\nUmmah Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Masjid, Witness, Solidarity, Earth). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a public check-in, or an ethnic log. Unanswered is not neglect of the Ummah.',
  ),
  FaqEntry(
    domain: MonitorDomain.hajj,
    question: 'Does Hajj tell me I must go this year?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved records stay. Home, Review, and check-in do not use it yet.\n\nNo. Hajj standing is a lifetime record you set: not recorded, unsure, I believe it is due, preparing, performed, not planning, not applicable, or prefer not to record. The app does not calculate whether Hajj is obligatory, does not set a year, and does not treat an empty mark as missed. A journey is optional and separate; you may have performed Hajj without planning another journey. Readiness is a checklist on a journey, not a daily score. Umrah is not this standing. Performed is a record, not a trophy.\n\nHajj Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped as Learn, Readiness, and After Hajj. It is available at all times, independent of journey status. You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a due-date, or a trophy. Unanswered is not missed Hajj.',
  ),
  FaqEntry(
    domain: MonitorDomain.productivity,
    question: 'Does Productivity score my output?',
    answer: 'This domain is not active in this version. It stays listed in Settings → Domains in Focus, grayed and not selectable. Saved Productivity items stay in their own store. Home, Review, and check-in do not use it yet.\n\nNo. When later available, Productivity is a private board of today’s listed actions (at most five), effort versus plan, and carry-forward of unfinished work. Carry-forward is not a fail. Effort versus plan is not a score, streak, or quota. Extra nominated items stay in the Productivity register. It does not import Hajj. Learn & Practice is not part of this domain. Unfinished work is not missed.',
  ),
];

String faqPaddedNumberForId(String id) {
  final index = faqEntries.indexWhere((entry) => entry.id == id);
  return faqItemNumber(index < 0 ? -1 : index);
}

String get manualBaselineHint =>
    'Describe a pattern you noticed. Not a target score. See FAQ ${faqPaddedNumberForId(kFaqManualBaseline)} for details.';
