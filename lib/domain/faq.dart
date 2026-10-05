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
    answer: 'Qur’an check-in has three duration rows: Engagement (recitation, memorisation and/or revision), Understanding & reflection (meaning and/or tafsir plus pondering), and Practical relevance (noticing implications or use of learnt verses). Those rows are not a khushu’ score.\n\nPersonal Reflection is an optional private note on a check-in.\n\nApplication Reflection is first-install framing and Settings → About. It is not a daily field, a Home row, or evidence of action.',
  ),
  FaqEntry(
    question: 'Why do the colours differ?',
    answer: 'The background colour of a card identifies a domain, such as Salah & Prayer Quality or Qur’an Engagement. Marks share one colour by default. Settings → Preferences → Activities & legend may colour Salah and Qur’an duration marks with the same activity colours. Colour names the recorded choice. It does not rank spirituality, success, or worth.',
  ),
  FaqEntry(
    question: 'Does the app score me or keep streaks?',
    answer: 'No. Muhasabah does not assign scores, ranks, streaks, badges, or success percentages. It records what you enter and lets you inspect it.',
  ),
  FaqEntry(
    question: 'Where do Home quotes come from?',
    answer: 'Home quotations rotate by calendar in Settings → Preferences → Quotation cadence. Weekly keeps one quote for the week (Reflection of the Week). Daily uses a new quote each local day (Reflection of the Day). Hidden removes the card. Quotes are not chosen from your records.',
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
    answer: 'No. It stores observations you notice in yourself: virtues, pause before reacting, honesty in small matters, forgiveness, modesty, and restraint — including holding back from a habit you are trying to leave. It does not call you a good or bad person, keep a character score, name vices, or expect perfection.\n\nRecord yourself only, not someone else’s flaw. Patience may be silence or firmness. Guarded how I spoke is tone; Knowledge’s held-back speech is usefulness. Thankfulness in how I acted is character; Gratitude Dhikr is remembrance. Unanswered on the habit row is not a relapse. An optional struggle note is text, not a grade.',
  ),
  FaqEntry(
    question: 'Does Rights of Others score my relationships?',
    answer: 'No. It records whether you attended to a right someone has over you, or neglected a right you owe. It is not a chore list, a relationship score, or a ledger of what others owe you.\n\nDo not name others’ faults here. Family conflict is not a shame mark. A step toward reconciliation is optional and not prescribed. This domain does not tell anyone to endure harm; safety and justice come first. Care in hardship (sick visit, sick contact, support under stress) is a right of brotherhood, not a sadaqah channel and not a second family log.',
  ),
  FaqEntry(
    question: 'Does Knowledge & Beneficial Speech grade how learned I am?',
    answer: 'No. It stores whether you noticed learning something true, sharing what benefits, or holding back useless speech. A single new fact is enough. Hours studied are not recorded. Debate is not knowledge engagement, and controversial content is not logged here.\n\nQur’an Engagement and Hadith & Living Sunnah have their own cards. This is other learning and speech. Held back useless speech is usefulness, not Character & Morals’ tone. The app never congratulates anyone for being learned.',
  ),
  FaqEntry(
    question: 'Does Hadith & Living Sunnah score my revival of the Sunnah?',
    answer: 'No. It stores whether a teaching of the Prophet ﷺ reached your day: reading, listening, retention, study, reflection, and whether you noticed a sunnah in how you lived. That last row is one observation, not a revival programme, a sunnah checklist, or a completed revival.\n\nCharacter & Morals stays who you were. The same afternoon may be both. The app does not fill Living Sunnah from Akhlaq. Current Memorisation Focus is a standing preference, not a daily grade. Unanswered is not a failed revival.',
  ),
  FaqEntry(
    question: 'Does Time & Barakah score my productivity?',
    answer: 'No. It stores whether you noticed treating time as a trust: presence, doing something delayed, stepping away from idle time, or resting from work as needed. The fard stays on Salah. Sleep stays on Physical Health. Hours and hustle badges are not recorded. Unanswered is not wasted time. The app never congratulates anyone for being productive, and does not prescribe a schedule.',
  ),
  FaqEntry(
    question: 'Does Physical Health & Energy grade my body?',
    answer: 'No. It stores whether you noticed care for the body Allah entrusted to you: sleep, movement for worship and service, moderate nutrition, simple hydration, seeking care in illness, avoiding harm, and energy for ibadah.\n\nSleep quality and amount are not hour badges and not Time & Barakah’s rest from work. Calories, weight, and body metrics are not recorded. Illness and disability are not failings. Physical and mental health are intertwined. This is not a fitness app, and the app never shames a body.',
  ),
  FaqEntry(
    question: 'Does Wealth & Stewardship score my money?',
    answer: 'No. It stores whether you noticed earning as a trust: a halal source, staying clear of riba, or avoiding waste. Giving — sadaqah, family or community support, and zakat due, planned, or paid — is on Charity. Amounts are not recorded. A smile is sadaqah.\n\nNet worth and savings are not spiritual metrics. Poverty and debt are not failings. Wealth is not a sign of Allah’s pleasure. There is no charity leaderboard, no most-generous badge, and no zakat calculator.',
  ),
  FaqEntry(
    question: 'Does Ummah grade my social life?',
    answer: 'No. It stores whether you noticed the Ummah beyond your household: a masjid class or gathering (not the fard), da’wah by character, supporting the oppressed, unity, praying for the Ummah, or care for the earth. The fard and Jumu‘ah stay on Salah. Help to a neighbour, community giving, and sick care stay on Rights of Others and Charity. Masjid marks here are private, not a public check-in.\n\nPolitical rants and sectarian arguments are not logged here. Introversion and social anxiety are not failings. Isolation is not a failing. The Ummah is global, not an ethnic group.',
  ),
  FaqEntry(
    question: 'Does Hajj tell me I must go this year?',
    answer: 'No. Hajj is a standing status you set: not due, due as you see it, preparing, performed, or not applicable. The app does not calculate whether Hajj is obligatory, does not set a year, and does not treat an empty mark as missed. Daily preparation is optional noticing, not a countdown. Umrah is not this status. Performed is a record, not a trophy.',
  ),
  FaqEntry(
    question: 'Are my records private if the phone is lost?',
    answer: 'Days stay on this device. There is no account and no cloud copy. Android backup of this app is off.\n\nThe phone lock is the main protection if the device is lost. Settings → Privacy → Unlock with this device can ask for this phone’s PIN, pattern, or biometrics before the app is shown. Muhasabah does not store a separate password.\n\nThat lock does not encrypt the files. Anyone who can open an unlocked phone can read the days if Unlock with this device is off. Removing a saved day is not forensic erasure.',
  ),
  FaqEntry(
    question: 'What do Salah activity colours mean?',
    answer: 'Settings → Preferences → Activities & legend can colour Salah marks by the recorded choice. Shared colour remains the default. Colour names what was recorded. It does not rank spirituality or tell you what to do next.',
  ),
];

String faqPaddedNumberForId(String id) {
  final index = faqEntries.indexWhere((entry) => entry.id == id);
  return faqItemNumber(index < 0 ? -1 : index);
}

String get manualBaselineHint =>
    'Describe a pattern you noticed. Not a target score. See FAQ ${faqPaddedNumberForId(kFaqManualBaseline)} for details.';
