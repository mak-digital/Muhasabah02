class FaqEntry {
  const FaqEntry({
    this.id,
    required this.question,
    required this.answer,
    this.compare,
  });

  final String? id;
  final String question;
  final String answer;
  final FaqCompareTable? compare;
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
      left: 'History tab, or Settings → Account & data',
      right: 'Review → Recorded days',
    ),
  ],
);

const kFaqManualBaseline = 'manual-baseline';

String faqItemNumber(int index) => (index + 1).toString().padLeft(2, '0');

const faqEntries = <FaqEntry>[
  FaqEntry(
    question: 'What is missing compared with missed?',
    answer: 'Not recorded is not the same as missed. An unanswered day or row stays unanswered. The app never fills missed for you, and missing records are not treated as failure.',
  ),
  FaqEntry(
    question: 'What are Baselines compared with Personal Aspirations?',
    answer: 'A baseline looks back at what you already recorded. A personal aspiration looks forward as a hope you name. Neither is a score. Neither currently changes Home, Review, or check-in.',
    compare: baselineAspirationCompare,
  ),
  FaqEntry(
    id: kFaqManualBaseline,
    question: 'How do I write a Manual baseline?',
    answer: 'A Manual baseline is a short note about a pattern you already noticed. It is not counted from check-ins. It is not a score. A hope for later belongs under Personal Aspirations. A Manual baseline does not change Home, Review, or check-in.\n\nWording that fits looks backward, without a quota: “Morning Adhkar showed up more on weekdays than on Friday last season.” “I often recorded a sick visit when a parent was ill; other Huquq rows stayed unanswered.”\n\nWording that does not fit is a percentage, a streak, a weekly quota, or “must improve.”',
  ),
  FaqEntry(
    question: 'What do Helping and Distracting factors mean?',
    answer: 'Optional factors store what you noticed around a recorded choice. They are provenance only. They never cause an outcome, complete a day, or create a score. You may leave them as Not recorded.',
  ),
  FaqEntry(
    question: 'What kinds of reflection does Muhasabah use?',
    answer: 'Qur’an check-in has three duration rows under ENGAGEMENT with Qur’an: Engagement (recitation, memorisation and/or revision), Understanding & reflection (meaning and/or tafsir plus pondering), and Practical relevance (noticing implications or use of learnt verses). Those rows are not a khushu’ score.\n\nQur’an to learn & practice is a built-in repository of widely used verses for daily reading and memorization (openings, Āyat al-Kursī, the close of Al-Baqarah, short prayer surahs). You may skim and add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a recitation streak. Unanswered is not “not engaged”.\n\nPersonal Reflection is an optional private note on a check-in.\n\nApplication Reflection is first-install framing and Settings → About. It is not a daily field, a Home row, or evidence of action.',
  ),
  FaqEntry(
    question: 'Why do the colours differ?',
    answer: 'The background colour of a card identifies a domain, such as Salah & Prayer Quality or Qur’an Engagement. Marks share one colour by default. Settings → Preferences → Activities & legend may colour Salah, Qur’an duration, post-fard Dhikr, and Character & Morals marks with the same activity colours. Colour names the recorded choice. It does not rank spirituality, success, or worth.',
  ),
  FaqEntry(
    question: 'Does the app score me or keep streaks?',
    answer: 'No. Muhasabah does not assign scores, ranks, streaks, badges, or success percentages. It records what you enter and lets you inspect it.',
  ),
  FaqEntry(
    question: 'Where do Home quotes come from?',
    answer: 'Home quotations rotate by calendar in Settings → Preferences → Quotation cadence. Weekly keeps one quote for the week (Reflection of the Week). Daily uses a new quote each local day (Reflection of the Day). Hidden removes the card. You can step to the next or previous quote; the one you stop on stays as that day’s or week’s reflection. A new day or week returns to calendar rotation until you step again. Each domain has cited Qur’an verses and well-known authentic hadith. Open citation loads the public page in this app with Close and Share. For Qur’an, Play recitation uses a public audio file in this app so the sound stays clear; the page is for reading. Open in browser is there if a site needs a full browser. This app does not send your records. Quotes are not chosen from your records.',
  ),
  FaqEntry(
    question: 'What is Recognition?',
    answer: 'Recognition lives on Review. It describes what you recorded over a longer period, with a way to view the evidence. It does not say you improved or declined, and it does not prescribe what to do next.',
  ),
  FaqEntry(
    question: 'Where is the meaning of the week-grid marks?',
    answer: 'Home → Guide explains the circles and diamonds. Missing is not missed. Factors you noticed do not change those marks.',
  ),
  FaqEntry(
    question: 'Can I show Islamic dates?',
    answer: 'Settings → Preferences → Calendar can show Gregorian or Islamic (Hijri) dates. This only changes how dates are displayed. Saved days stay on the civil calendar day they were stored. The Islamic option uses the civil (tabular) Hijri calendar; moon sighting may differ by a day.\n\nFasting Progress also highlights civil Hijri 13, 14 and 15 so White Days are easier to locate. That highlight is orientation only. It does not record a fast or tell you to fast.',
  ),
  FaqEntry(
    question: 'Can I hide domains I do not want to monitor?',
    answer: 'Settings → Preferences → Domains in Focus chooses which domains belong in this profile. The mix on the same screen is a subset: which bands and rows to notice. You can show every domain and every row, or keep a domain or row unselected if it does not apply. The first look is Salah, Qur’an & Dhikr (those three domains). All domains remains one tap. Hidden domains and unselected mix rows keep any saved records. Showing them again does not rewrite those records. Home, Review, Progress, check-in, Quick Tap, and Recorded days follow the mix among shown domains. Manage past check-ins still opens the saved day to edit.',
  ),
  FaqEntry(
    question: 'What is a Personal mix?',
    answer: 'Settings → Preferences → Domains in Focus holds shown domains and this season’s mix. The mix is a subset of those domains: which bands and rows you want to notice. Leave a domain or row unselected if it does not apply to your circumstances. Home, Review, Progress, today’s check-in, and Quick Tap follow that mix among domains that are shown. It is not a score, a programme, or a second hide-list. Named starting points copy a set you can edit. Same as Domains follows whatever is already shown. The mix does not rewrite saved days. Unanswered mix rows are not missed. A mix row on a hidden domain is kept and appears only when that domain is shown. That is stated on the mix list; it is not a block.',
  ),
  FaqEntry(
    question: 'What is Manage past check-ins compared with Recorded days?',
    answer: 'Manage past check-ins is for housekeeping of saved days: tap a date to edit that check-in, or long-press to remove the app’s record. It does not score you, and removal is not forensic erasure.\n\nRecorded days (Historical Reflection) is read-only. It shows exactly what was recorded so you can look without changing it.\n\nThe two jobs stay separate so browsing evidence is not mixed with editing. After you edit or remove a day, Home, Review, and Progress read the updated records.',
    compare: manageCheckInsCompare,
  ),
  FaqEntry(
    question: 'Does Character & Morals grade me?',
    answer: 'No. It stores observations you notice in yourself: virtues, pause before reacting, honesty in small matters, forgiveness, modesty, and restraint — including holding back from a habit you are trying to leave. Each row has its own wording for virtue demonstrated, struggled, shortcoming recognised, corrective action, no relevant situation, or unanswered. Corrective action is not the same as avoiding the original lapse. Colour names the recorded choice when activity colours are on. It does not call you a good or bad person, keep a character score, name vices, or expect perfection.\n\nRecord yourself only, not someone else’s flaw. Patience may be silence or firmness. Guarded how I spoke is tone; Knowledge’s held-back speech is usefulness. Thankfulness in how I acted is character; Gratitude Dhikr is remembrance. Unanswered on the habit row is not a relapse. Optional context, what helped, and a private struggle note are provenance, not a grade.',
  ),
  FaqEntry(
    question: 'Does Rights of Others score my relationships?',
    answer: 'No. Each row has its own wording for a positive action, partial effort, a recognised shortcoming, a corrective step, no applicable situation, or unanswered. Colour names the recorded choice when activity colours are on. It is not a chore list, a relationship score, or a ledger of what others owe you. Lack of daily contact is not neglect. A recognised shortcoming is not automatically a religious violation. Rights are not treated as equal in obligation, and the app does not score spiritual merit.\n\nDo not name others’ faults here. Family conflict is not a shame mark. A step toward reconciliation is optional and not prescribed; the app does not pressure anyone to reconcile where that would be unsafe. This domain does not tell anyone to endure harm; safety and justice come first. Care in hardship (sick visit, sick contact, support under stress) is a right of brotherhood, not a sadaqah channel and not a second family log. Optional nature, outcome, quantity, and private reflection are provenance about your own conduct only.\n\nRights of Others Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Household, Extended family, Neighbours & work, The people, Repair, Care in hardship). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a to-do list. Unanswered is not neglect.',
  ),
  FaqEntry(
    question: 'Does Charity score my giving?',
    answer: 'No. It stores independent observations of voluntary charity, family support, community support, educational support, emergency support, and support under financial stress. Each row records one descriptive observation, including no relevant opportunity and prefer not to record, which is not the same as not recorded. Amounts, recipient names, and financial circumstances are not recorded. Ordinary household nafaqa stays on Rights of Others. Zakat is a separate status — paid, arranged, reviewing, not currently due, or due but not yet paid — not a calculator and not a daily missed obligation. A smile is sadaqah. Poverty is not a failing. There is no charity leaderboard and no most-generous badge.\n\nCharity Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Giving, Care). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a generosity score. Not recorded is not withheld charity.',
  ),
  FaqEntry(
    question: 'Does Knowledge & Beneficial Speech grade how learned I am?',
    answer: 'No. Each row has its own wording for a beneficial activity, partial engagement, a recognised gap, a correction, no relevant situation, or unanswered. Colour names the recorded choice when activity colours are on. It is not a knowledge grade, intelligence score, or religious ranking. A single new fact is enough. Hours studied and the number of sources consulted are not a quality measure. Debate is not knowledge engagement, and controversial content is not logged here. Reading, asking, teaching, or creating does not prove the information is correct. AI-assisted learning is not treated as verified.\n\nQur’an Engagement and Hadith & Living Sunnah have their own cards. This is other learning and speech. Held back useless speech is usefulness, not Character & Morals’ tone. The app never congratulates anyone for being learned. Optional type, source, verification, understanding, application, quantity, and private reflection are provenance only.\n\nKnowledge & Beneficial Speech Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Seeking truth, Sharing, Beneficial speech). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a study-hour badge. Unanswered is not ignorance.',
  ),
  FaqEntry(
    question: 'Does Hadith & Living Sunnah score my revival of the Sunnah?',
    answer: 'No. It stores whether a teaching of the Prophet ﷺ reached your day on four rows under ENGAGED with Hadith: read and/or listened, memorization/revision, study circle/discussion, and lived or noticed in others. The first three use the same duration steps as Qur’an Engagement. Lived /Noticed others is one observation — starting, introducing in family, correcting a practice, or noticing it in someone else — not a revival programme, a sunnah checklist, or a completed revival.\n\nCharacter & Morals stays who you were. The same afternoon may be both. The app does not fill Living Sunnah from Akhlaq. Hadith to learn & practice is a built-in list of daily-practice hadith and related supplications (Arabic, transliteration, and translation) you may add to a private register (Learning, Learnt, Practicing, Living it). It is not a daily grade. Unanswered is not a failed revival.',
  ),
  FaqEntry(
    question: 'Does Time & Barakah score my productivity?',
    answer: 'No. It stores independent observations of intention, attention, action, and balance (eight optional practices). Each row records one descriptive observation: beneficial action, partial effort, a recognised lapse, a corrective adjustment, no relevant situation, or unanswered. Corrected is not ranked above acted. Optional context, challenge, what helped, outcome, and a quantity are stored as you report them — not as a spiritual grade, a productivity score, or an estimate of barakah. Needed rest is not wasted time. Recreation is not automatically wasted. Illness, caregiving, and unavoidable interruptions are not failings. The fard stays on Salah. Sleep stays on Physical Health. Hours and hustle badges are not recorded. Unanswered is not wasted time. The app never congratulates anyone for being productive, and does not prescribe a schedule.\n\nTime & Barakah Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Intention & Priority, Attention & Presence, Responsibility & Action, Balance & Renewal). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a timetable, or a claim of barakah. Unanswered is not wasted time.',
  ),
  FaqEntry(
    question: 'Does Physical Health & Energy grade my body?',
    answer: 'No. It stores independent observations of sleep, movement for worship and service, nutrition, hydration, seeking care in illness, avoiding harm, and energy for ibadah. Each row records one descriptive observation, including prefer not to record, which is not unanswered. Sleeping poorly is not a failure. Seeking medical care is not ranked as better health than having no illness. Sleep quality and amount are not hour badges and not Time & Barakah’s rest from work. Calories, weight, and body metrics are not recorded. Illness, disability, ageing, fatigue, and prescribed treatment are not failings. Physical and mental health are intertwined. This is not a fitness app, and the app never shames a body.\n\nPhysical Health & Energy Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Sleep, Strength, Sustenance, Illness & harm). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a fitness programme, or a body score. Unanswered is not a failing of the body.',
  ),
  FaqEntry(
    question: 'Does Wealth & Stewardship score my money?',
    answer: 'No. It stores independent observations of a lawful source, staying clear of riba, avoiding waste, and managing wealth as a trust. Each row records one descriptive observation, including no relevant activity and prefer not to record, which is not unanswered. An unresolved concern is not a legal ruling. No relevant activity is not a failure. Giving — sadaqah, family or community support, and zakat due, planned, or paid — is on Charity. Amounts, accounts, and creditor names are not recorded. A smile is sadaqah.\n\nNet worth and savings are not spiritual metrics. Poverty and debt are not failings. Wealth is not a sign of Allah’s pleasure. There is no charity leaderboard, no most-generous badge, and no zakat calculator.\n\nWealth & Stewardship Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Earning, Restraint, Lawful wealth management). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade or a money score. Unanswered is not a failing of provision.',
  ),
  FaqEntry(
    question: 'Does Ummah grade my social life?',
    answer: 'No. It stores independent observations of a masjid class or gathering (not the fard), da’wah by character, supporting the oppressed, unity, praying for the Ummah, and care for the earth. Each row records one descriptive observation, including no relevant opportunity and prefer not to record, which is not unanswered. Remote participation is not recorded as being physically present. Du’a is distinct from practical help. The fard and Jumu‘ah stay on Salah. Help to a neighbour, community giving, and sick care stay on Rights of Others and Charity. Masjid marks here are private, not a public check-in.\n\nPolitical rants and sectarian arguments are not logged here. Introversion and social anxiety are not failings. Isolation is not a failing. The Ummah is global, not an ethnic group.\n\nUmmah Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Masjid, Witness, Solidarity, Earth). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a public check-in, or an ethnic log. Unanswered is not neglect of the Ummah.',
  ),
  FaqEntry(
    question: 'Does Dhikr & Dua score my remembrance?',
    answer: 'No. After each fard prayer it stores one remembrance observation: remembrance with action, attentive, intentional, brief, or not today. Unanswered stays empty. How attentive was I (reflected on the meaning, aware of what I was saying, or mostly habitual recitation) is optional provenance, not a khushu’ score. Morning, evening, and other remembrance keep their own rows. Colour names the recorded choice when activity colours are on. It does not rank spirituality.\n\nDhikr Learn & Practice is a built-in list of authentic dhikr and dua grouped like Home. You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a target count. Unanswered is not missed dhikr.',
  ),
  FaqEntry(
    question: 'Does Fasting score my sawm?',
    answer: 'No. Fasting sits after Dhikr. It has two sections: Ramadan fasting & excellence (eight optional observations on civil Ramadan dates), and voluntary and make-up (weekly sunnah, White Days, make-up, Ramadan preparation, and post-Ramadan). Not recorded is empty, not a missed fast. Prefer not to record is a privacy choice. The app does not judge validity, exemption, make-up, or fidyah. An exemption is not a failure. Fasting today is not auto-completed after iftar.\n\nProgress highlighting civil Hijri 13–15 is orientation only. Settings → Calendar can shift Ramadan dates by a day for local moon sighting, or show all Fasting rows for review. Voluntary and make-up rows stay off during Ramadan unless that review switch is on or that day already has a mark. Shawwal six fasts are voluntary; an actual make-up stays on Make-up Fast. Extreme fasting outside Ramadan is not encouraged.\n\nFasting Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home. You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a countdown, or a prescription to fast. Unanswered is not a missed fast.',
  ),
  FaqEntry(
    question: 'Does Hajj tell me I must go this year?',
    answer: 'No. Hajj is a standing status you set: not due, due as you see it, preparing, performed, or not applicable. The app does not calculate whether Hajj is obligatory, does not set a year, and does not treat an empty mark as missed. Daily preparation is optional noticing, not a countdown. Umrah is not this status. Performed is a record, not a trophy.\n\nHajj Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Preparation). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a daily grade, a due-date, or a trophy. Unanswered is not missed Hajj.',
  ),
  FaqEntry(
    question: 'Are my records private if the phone is lost?',
    answer: 'Days stay on this device. There is no account and no cloud copy. Android backup of this app is off.\n\nThe phone lock is the main protection if the device is lost. Settings → Privacy → Unlock with this device can ask for this phone’s PIN, pattern, or biometrics before the app is shown. Muhasabah does not store a separate password.\n\nThat lock does not encrypt the files. Anyone who can open an unlocked phone can read the days if Unlock with this device is off. Removing a saved day is not forensic erasure.',
  ),
  FaqEntry(
    question: 'What do Salah activity colours mean?',
    answer: 'Settings → Preferences → Activities & legend can colour Salah marks, Qur’an duration steps, post-fard Dhikr remembrance, Character & Morals, Rights of Others, Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, and Fasting observations by the recorded choice. Shared colour remains the default. Remembrance with action and a demonstrated virtue use the same blue as congregation on time. Colour names what was recorded. It does not rank spirituality or tell you what to do next.\n\nSalah & Prayer Quality Learn & Practice is a built-in list of Qur’an verses and authentic hadith grouped like Home (Obligatory Salah, Friday Prayer, Voluntary Prayers). You may add one to a private register (Learning, Learnt, Practicing, Habit). It is not a khushu’ score, congregation requirement, or daily grade. Unanswered is not missed.',
  ),
];

String faqPaddedNumberForId(String id) {
  final index = faqEntries.indexWhere((entry) => entry.id == id);
  return faqItemNumber(index < 0 ? -1 : index);
}

String get manualBaselineHint =>
    'Describe a pattern you noticed. Not a target score. See FAQ ${faqPaddedNumberForId(kFaqManualBaseline)} for details.';
