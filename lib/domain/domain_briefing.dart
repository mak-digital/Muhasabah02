import 'monitor_domain.dart';

class BriefingGroup {
  const BriefingGroup({required this.title, required this.items});

  final String title;
  final List<String> items;
}

class DomainBriefing {
  const DomainBriefing({
    this.lead = const [],
    this.examplesTitle,
    this.groups = const [],
    this.items = const [],
    this.bounds = const [],
    this.closing = const [],
  });

  final List<String> lead;
  final String? examplesTitle;
  final List<BriefingGroup> groups;
  final List<String> items;
  final List<String> bounds;
  final List<String> closing;

  String get plainText {
    final lines = <String>[
      ...lead,
      if (examplesTitle != null && examplesTitle!.isNotEmpty) examplesTitle!,
      for (final group in groups) ...[
        group.title,
        for (final item in group.items) '• $item',
      ],
      for (final item in items) '• $item',
      for (final item in bounds) '• $item',
      ...closing,
    ];
    return lines.join('\n\n');
  }
}

const huquqBriefing = DomainBriefing(
  lead: [
    'This records rights others have over you — whether you attended to a right you owe, or neglected it. It is not a chore list, a relationship score, or a ledger of what they owe you.',
    'Rows match Home. Unanswered is not neglect. Learn & Practice reminders on Home are not a daily grade.',
  ],
  examplesTitle: 'Attending can look like',
  groups: [
    BriefingGroup(
      title: 'Household',
      items: [
        'Parents — kind speech, presence, service, dua',
        'Grandparents — honouring',
        'Spouse — patience, kind words, your own obligations, presence',
        'Children — teaching, presence in play, fairness, guarded speech',
        'Siblings — keeping ties',
      ],
    ),
    BriefingGroup(
      title: 'Extended family',
      items: ['Other relatives — keeping ties'],
    ),
    BriefingGroup(
      title: 'Neighbours & work',
      items: [
        'Neighbours — a check-in, a gift, not harming, helping',
        'Colleagues & friends — trustworthiness, keeping a confidence, sincere advice, not backbiting',
      ],
    ),
    BriefingGroup(
      title: 'The people',
      items: [
        'Fellow Muslims — salaam, help in need, dua',
        'Non-Muslims — justice, kindness, good neighbourliness, character',
      ],
    ),
    BriefingGroup(
      title: 'Repair',
      items: [
        'A step toward reconciliation — optional noticing. The app does not prescribe or complete sulh.',
        'Turned back over a neglected right — optional noticing, not completed tawbah.',
      ],
    ),
    BriefingGroup(
      title: 'Care in hardship',
      items: [
        'Sick visit, sick contact, or support under stress — a right of brotherhood, not a sadaqah channel',
      ],
    ),
  ],
  bounds: [
    'Record only yourself. Do not log what others owe you, or name their faults.',
    'Family conflict is not a shame mark. Reconciliation is optional.',
    'Safety and justice come first. Patience is not required in harm or abuse.',
    'Ordinary household support stays here. Extra gifts sit on Charity.',
  ],
);

const akhlaqBriefing = DomainBriefing(
  lead: [
    'Notice what you did. This is not a verdict of being a good or bad person, a character score, or a performance review.',
  ],
  items: [
    'Record only yourself — not someone else’s flaw.',
    'Patience may be silence or firmness.',
    'Guarded how I spoke is tone and modesty; Knowledge’s held-back speech is whether the words were useful.',
    'Thankfulness in how I acted is character; Gratitude Dhikr is remembrance.',
    'Held back from a habit I am trying to leave is noticed restraint. The habit is not named.',
    'Unanswered is not a relapse, a sin, or a failing.',
  ],
  closing: ['Perfection is not expected.'],
);

const knowledgeBriefing = DomainBriefing(
  lead: [
    'This is about learning something true and speaking only what benefits. A single new fact is enough. You do not need to be a scholar.',
    'Qur’an Engagement and Hadith & Living Sunnah have their own cards. This is other learning and speech — Islamic or beneficial worldly knowledge that is not logged there.',
  ],
  items: [
    'Teaching even one fact to a child or colleague counts.',
    'Beneficial reading here is not Qur’an or Hadith; it may be a book, article, or lecture.',
    'Held back useless speech is usefulness (gossip, argument, excessive joking), not Character & Morals’ tone and modesty.',
    'Sincere advice, asking to remove ignorance, and writing or creating something beneficial are observations, not achievements.',
    'Hours studied are not recorded and are not a badge.',
    'Debate and argument are not knowledge engagement.',
    'Controversial or divisive content is not logged here.',
    'The app never congratulates anyone for being learned.',
  ],
);

const timeBriefing = DomainBriefing(
  lead: [
    'Time is a trust from Allah. Record independent observations of intention, attention, action, and balance — not how many hours you clocked, and not a productivity score.',
  ],
  items: [
    'The eight practices are optional observations, not eight daily achievements.',
    'A first tap stores a descriptive observation: beneficial action, partial effort, a recognised lapse, a corrective adjustment, no relevant situation, or unanswered. Optional follow-ups are provenance, not a productivity score.',
    'The app records what you report. It does not infer intention, sincerity, laziness, psychological health, divine reward, or barakah.',
    'The fard stays on Salah. Sleep stays on Physical Health. Took needed rest here is recovery, not a sleep log.',
    'Hours, productivity scores, streaks, and hustle badges are not recorded.',
    'Unanswered is not wasted time and not a failure.',
    'The app never congratulates anyone for being productive, and does not prescribe a schedule.',
  ],
);

const healthBriefing = DomainBriefing(
  lead: [
    'The body is a trust from Allah. Record care you noticed — sleep, movement for worship and service, halal and moderate food, simple hydration, seeking treatment in illness, avoiding harm, and whether your body supported ibadah.',
  ],
  items: [
    'Sleep quality and amount are observations, not hour badges, and not Time & Barakah’s rest from work.',
    'A first tap stores a descriptive observation. Prefer not to record is an explicit privacy choice, distinct from unanswered.',
    'A nap that cares for the body may be noticed here. The same day may be both. The app does not fill sleep from Time, or Time from sleep.',
    'Movement is for strength to worship and serve, not aesthetics or “gains”.',
    'Nutrition is lawful, sufficient, and in moderation — not calorie counting. Hydration is simple, not obsessive.',
    'Illness, disability, ageing, fatigue, and prescribed treatment are not failings. Seeking care is not ranked above having no illness.',
    'Physical and mental health are intertwined.',
    'This is not a fitness app: no weight, body metrics, body-shaming, or beauty-as-spiritual-goal.',
    'Extreme fasting outside Ramadan is not encouraged here.',
  ],
);

const wealthBriefing = DomainBriefing(
  lead: [
    'Wealth is a trust. Record how you managed earning, spending, and what was entrusted to you — not how much you have.',
  ],
  items: [
    'Earning may be noticing a lawful source, or staying clear of riba.',
    'Avoiding waste is part of stewardship.',
    'Lawful wealth management is responsible use of money, debts, records, and trusts. It is not a bank log.',
    'A reported action is distinct from an unresolved concern. No relevant activity is not a failure.',
    'Self-report is not a legal or scholarly determination. Complex cases need qualified advice.',
    'Giving — sadaqah, family support, community care, and zakat due, planned, or paid — is on Charity. Amounts are not recorded. There is no zakat calculator.',
    'Net worth and savings are not spiritual metrics.',
    'Poverty and debt are not failings. Wealth is not a sign of Allah’s pleasure.',
    'Older giving marks on this domain stay stored and still appear on Historical Reflection.',
  ],
);

const ummahBriefing = DomainBriefing(
  lead: [
    'This is about the Ummah — privately. The fard and Jumu‘ah stay on Salah. This card is not a public masjid check-in.',
  ],
  items: [
    'A masjid class or gathering (not the fard) may be noticed here. Remote participation is recorded as remote, not as being present.',
    'Da’wah here is by character, not argument, and not Character & Morals’ virtue list. No quota, and no inference of anyone else’s faith.',
    'Solidarity may be dua, awareness, or material help for the oppressed; working for unity; or praying for the Ummah, especially in crisis.',
    'The earth is a trust.',
    'Help to a neighbour, community giving, and sick care stay on Rights of Others and Charity.',
    'Charity Family Support is a gift or extra support, not ordinary household nafaqa.',
    'Political rants and sectarian arguments are not logged here.',
    'Introversion and social anxiety are not failings. Isolation (including converts and new immigrants) is met with gentleness, not a community-organizer standard.',
    'The Ummah is global; this is not an ethnic-group log.',
  ],
);

const hadithBriefing = DomainBriefing(
  lead: [
    'Qur’an Engagement has its own card. This is the Prophet’s teaching ﷺ: engaged with Hadith (read and/or listened), memorization or revision, study circle or discussion, and whether a teaching was lived or noticed in others.',
  ],
  items: [
    'Under ENGAGED with Hadith, read and/or listened, memorization or revision, and study circle or discussion use the same duration steps as Qur’an Engagement. Time is observational, not a grade.',
    'Lived /Noticed others is one observation of living or noticing a hadith, not a revival programme or a completed sunnah checklist.',
    'Character & Morals stays who you were. The same afternoon may be both. The app does not fill this from Akhlaq.',
    'Hadith to learn & practice is a built-in list you may add to a private register. It is not a daily grade, checklist, or revival programme.',
    'Unanswered is not a failed revival.',
  ],
);

const fastingBriefing = DomainBriefing(
  lead: [
    'Two sections: Ramadan fasting & excellence, and voluntary and make-up. Not recorded is empty, not a missed fast. Prefer not to record is a privacy choice.',
  ],
  items: [
    'Ramadan rows appear on civil Ramadan dates; voluntary and make-up rows appear outside it. Settings → Calendar can shift Ramadan by a day for local moon sighting, or show all Fasting rows for review.',
    'The app does not judge validity, exemption, make-up, or fidyah. An exemption is not a failure. Fasting today can be edited after iftar; it is not auto-completed.',
    'Necessary work, care, rest, and recreation are not automatically waste. There is no screen-time monitoring.',
    'Salah validity and khushu’ are not measured here. Extra worship has no rak‘ah or minute quota. Menstruation and other valid limits are not presented as failure.',
    'Weekly sunnah, White Days, and make-up keep their existing rows. Post-Ramadan may note Shawwal planning; an actual make-up stays on Make-up Fast.',
    'Progress highlighting civil Hijri 13–15 is orientation only. Extreme fasting outside Ramadan is not encouraged.',
  ],
);

const hajjBriefing = DomainBriefing(
  lead: [
    'Hajj standing is a lifetime record you set. A journey is optional and separately stored. The app does not decide whether Hajj is obligatory.',
  ],
  items: [
    'Unanswered, unsure, not planning, not applicable, and prefer not to record stay available. Empty is not missed Hajj.',
    'Readiness is a checklist on a journey you choose to start — not a daily score and not a visa engine.',
    'Learn & Practice is always available, independent of standing or journey. After Hajj is optional reflection, not a trophy. Umrah is not this standing.',
  ],
);

const charityBriefing = DomainBriefing(
  lead: [
    'This is giving and care you noticed — privately. Amounts, recipient names, and financial circumstances are not recorded. Ordinary household nafaqa stays on Rights of Others.',
  ],
  items: [
    'Voluntary charity, family support, and community support are independent of Zakat.',
    'Zakat is a status you name, not a calculator and not a daily missed obligation.',
    'A smile is sadaqah. Poverty is not a failing.',
    'Prefer not to record is a privacy choice, distinct from not recorded.',
    'No relevant opportunity is not withheld charity.',
    'There is no charity leaderboard and no most-generous badge.',
  ],
);

DomainBriefing? briefingForDomain(MonitorDomain domain) => switch (domain) {
  MonitorDomain.hadith => hadithBriefing,
  MonitorDomain.akhlaq => akhlaqBriefing,
  MonitorDomain.huquq => huquqBriefing,
  MonitorDomain.charity => charityBriefing,
  MonitorDomain.knowledge => knowledgeBriefing,
  MonitorDomain.time => timeBriefing,
  MonitorDomain.health => healthBriefing,
  MonitorDomain.wealth => wealthBriefing,
  MonitorDomain.ummah => ummahBriefing,
  MonitorDomain.fasting => fastingBriefing,
  MonitorDomain.hajj => hajjBriefing,
  _ => null,
};

DomainBriefing? briefingForLabel(String? label) {
  if (label == null || label.isEmpty) return null;
  for (final domain in MonitorDomain.values) {
    if (domain.label == label) return briefingForDomain(domain);
  }
  return null;
}
