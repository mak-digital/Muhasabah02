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
    'This records rights others have over you. It is an investment in people Allah placed in your life — not a chore list, and not what they owe you.',
    'Use each row for whether you attended to that right, or neglected it. Unanswered is not neglect, and is not a relationship score.',
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
      title: 'Neighbours and work',
      items: [
        'Neighbour — a check-in, a gift, not harming, helping',
        'Colleagues and friends — trustworthiness, keeping a confidence, sincere advice, not backbiting',
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
      title: 'Care in hardship',
      items: [
        'Sick visit, sick contact, or support under stress — a right of brotherhood, not a sadaqah channel',
      ],
    ),
  ],
  bounds: [
    'Record only yourself. Do not log what others owe you, or name their faults.',
    'Family conflict is not a shame mark. A step toward reconciliation is optional. The app does not prescribe or complete tawbah or sulh.',
    'Safety and justice come first. Patience is not required in harm or abuse.',
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
    'Time is a trust from Allah. Record whether you noticed presence, keeping a trust, or rest — not how many hours you clocked.',
  ],
  items: [
    'The fard stays on Salah. Sleep stays on Physical Health.',
    'Presence is attention in what you were doing.',
    'Trust may be doing something you had delayed, or stepping away from idle time.',
    'Rest from work as needed is part of the trust; it is not failure and it is not a sleep log.',
    'Older prayer-window marks on this domain stay stored and still appear on Historical Reflection.',
    'Hours, productivity scores, and hustle badges are not recorded.',
    'Unanswered is not wasted time.',
    'The app never congratulates anyone for being productive, and does not prescribe a schedule.',
  ],
);

const healthBriefing = DomainBriefing(
  lead: [
    'The body is a trust from Allah. Record care you noticed — sleep, movement for worship and service, halal and moderate food, simple hydration, seeking treatment in illness, avoiding harm, and whether your body supported ibadah.',
  ],
  items: [
    'Sleep quality and amount are observations, not hour badges, and not Time & Barakah’s rest from work.',
    'A nap that cares for the body may be noticed here. The same day may be both. The app does not fill sleep from Time, or Time from sleep.',
    'Movement is for strength to worship and serve, not aesthetics or “gains”.',
    'Nutrition is halal, healthy, and in moderation — not calorie counting. Hydration is simple, not obsessive.',
    'Illness and disability are not failings. Seeking treatment, patience, and gratitude may all be care.',
    'Physical and mental health are intertwined.',
    'This is not a fitness app: no weight, body metrics, body-shaming, or beauty-as-spiritual-goal.',
    'Extreme fasting outside Ramadan is not encouraged here.',
  ],
);

const wealthBriefing = DomainBriefing(
  lead: [
    'Wealth is a trust. Record whether earning and spending pleased Allah — not how much you have.',
  ],
  items: [
    'Earning may be noticing a halal source, or staying clear of riba.',
    'Avoiding waste is part of stewardship.',
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
    'A masjid class or gathering (not the fard) may be noticed here.',
    'Da’wah here is by character, not argument, and not Character & Morals’ virtue list.',
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
    'Qur’an Engagement has its own card. This is the Prophet’s teaching ﷺ: reading, listening, retention, study, and whether a teaching reached how you lived today.',
  ],
  items: [
    'Noticed a sunnah in how I lived today is one observation, not a revival programme or a completed sunnah checklist.',
    'Character & Morals stays who you were. The same afternoon may be both. The app does not fill this from Akhlaq.',
    'Current Memorisation Focus is a standing preference, not a daily grade.',
    'Unanswered is not a failed revival.',
  ],
);

const hajjBriefing = DomainBriefing(
  lead: [
    'Hajj is a standing status you set: not due, due as you see it, preparing, performed, or not applicable.',
  ],
  items: [
    'The app does not calculate whether Hajj is obligatory, does not set a year, and does not treat an empty mark as missed.',
    'Daily preparation is optional noticing — saving, health, learning rites, or travel — not a countdown and not a visa checklist score.',
    'Umrah is not this status. Performed is a record, not a trophy.',
  ],
);

DomainBriefing? briefingForDomain(MonitorDomain domain) => switch (domain) {
  MonitorDomain.hadith => hadithBriefing,
  MonitorDomain.akhlaq => akhlaqBriefing,
  MonitorDomain.huquq => huquqBriefing,
  MonitorDomain.knowledge => knowledgeBriefing,
  MonitorDomain.time => timeBriefing,
  MonitorDomain.health => healthBriefing,
  MonitorDomain.wealth => wealthBriefing,
  MonitorDomain.ummah => ummahBriefing,
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
