enum QuranDimension {
  reading,
  meaning,
  memorisation,
  revision,
  tafsir,
  reflection,
  consciousApplication,
  applicationReflection,
}

enum TernaryOutcome { unanswered, positive, negative }

List<QuranDimension> get quranDailyDimensions => const [
  QuranDimension.reading,
  QuranDimension.meaning,
  QuranDimension.consciousApplication,
];

const kQuranRecitationBand = 'Recitation';
const kQuranRetentionBand = 'Retention';
const kQuranStudyBand = 'Study & notice';
const kQuranEngagementBand = 'Engagement';
const kQuranUnderstandingBand = 'Understanding & reflection';
const kQuranReflectionBand = 'Reflection';
const kQuranApplicationBand = 'Practical relevance';

const recitationHomeRows = [QuranDimension.reading, QuranDimension.meaning];

const retentionHomeRows = [
  QuranDimension.memorisation,
  QuranDimension.revision,
];

const studyNoticeHomeRows = [
  QuranDimension.tafsir,
  QuranDimension.reflection,
  QuranDimension.consciousApplication,
];

const engagementHomeRows = [QuranDimension.reading];

const understandingHomeRows = [QuranDimension.meaning];

const reflectionHomeRows = <QuranDimension>[];

const applicationHomeRows = [QuranDimension.consciousApplication];

/// Mix-filtered Home / 7-day bands in check-in order.
List<(String band, List<QuranDimension> rows)> quranHomeBandsFor(
  Iterable<QuranDimension> display,
) {
  final shown = display.toSet();
  const catalog = <(String, List<QuranDimension>)>[
    (kQuranEngagementBand, engagementHomeRows),
    (kQuranUnderstandingBand, understandingHomeRows),
    (kQuranReflectionBand, reflectionHomeRows),
    (kQuranApplicationBand, applicationHomeRows),
  ];
  return [
    for (final entry in catalog)
      if ([
        for (final dimension in entry.$2)
          if (shown.contains(dimension)) dimension,
      ].isNotEmpty)
        (
          entry.$1,
          [
            for (final dimension in entry.$2)
              if (shown.contains(dimension)) dimension,
          ],
        ),
  ];
}

extension QuranDimensionX on QuranDimension {
  String get jsonKey => name;

  String get label => switch (this) {
    QuranDimension.reading => 'Engagement',
    QuranDimension.meaning => 'Understanding & reflection',
    QuranDimension.memorisation => 'Memorisation',
    QuranDimension.revision => 'Revision',
    QuranDimension.tafsir => 'Tafsir',
    QuranDimension.reflection => 'Qur’anic Reflection',
    QuranDimension.consciousApplication => 'Practical relevance',
    QuranDimension.applicationReflection => 'Application Reflection',
  };

  String get matrixColumn => switch (this) {
    QuranDimension.reading => 'Engage',
    QuranDimension.meaning => 'Understand',
    QuranDimension.memorisation => 'Memorise',
    QuranDimension.revision => 'Revise',
    QuranDimension.tafsir => 'Tafsir',
    QuranDimension.reflection => 'Reflect',
    QuranDimension.consciousApplication => 'Relevance',
    QuranDimension.applicationReflection => 'Relevance',
  };

  bool get matrixColumnVertical => true;

  String get homeBand {
    if (engagementHomeRows.contains(this)) return kQuranEngagementBand;
    if (understandingHomeRows.contains(this)) return kQuranUnderstandingBand;
    if (reflectionHomeRows.contains(this)) return kQuranReflectionBand;
    if (applicationHomeRows.contains(this)) return kQuranApplicationBand;
    return kQuranStudyBand;
  }

  String get question => switch (this) {
    QuranDimension.reading =>
      'Did you spend time with recitation, memorisation, and/or revision today?',
    QuranDimension.meaning =>
      'Did you spend time with meaning and/or tafsir, plus pondering, today?',
    QuranDimension.memorisation =>
      'Did you spend time memorising Qur’an today?',
    QuranDimension.revision =>
      'Did you spend time revising memorised Qur’an today?',
    QuranDimension.tafsir => 'Did you spend time studying tafsir or an explanation of an ayah or passage today?',
    QuranDimension.reflection => 'Did you spend time in Qur’anic Reflection — on verses, meanings, tafsir, or lessons noticed — today?',
    QuranDimension.consciousApplication =>
      'Did you notice a possible practical relevance from learnt verses today?',
    QuranDimension.applicationReflection => 'Did you spend time reflecting on how something from the Qur’an might relate to your daily life?',
  };

  String get positiveLabel => switch (this) {
    QuranDimension.reading => 'Recorded sitting',
    QuranDimension.meaning => 'Recorded sitting',
    QuranDimension.memorisation => 'Recorded engagement',
    QuranDimension.revision => 'Recorded engagement',
    QuranDimension.tafsir => 'Recorded engagement',
    QuranDimension.reflection => 'Recorded engagement',
    QuranDimension.consciousApplication => 'Recorded sitting',
    QuranDimension.applicationReflection =>
      'Reflected on possible practical relevance',
  };

  String get negativeLabel => switch (this) {
    QuranDimension.reading => 'I did not notice this today',
    QuranDimension.meaning => 'I did not notice this today',
    QuranDimension.memorisation => 'Recorded as not done',
    QuranDimension.revision => 'Recorded as not done',
    QuranDimension.tafsir => 'Recorded as not done',
    QuranDimension.reflection => 'Recorded as not done',
    QuranDimension.consciousApplication => 'I did not notice this today',
    QuranDimension.applicationReflection =>
      'Did not reflect on practical relevance',
  };

  bool get isPrimaryDailyItem => this == QuranDimension.reading;

  bool get isNeutralPeerDimension =>
      this != QuranDimension.reading && !isApplicationReflection;

  bool get allowsPositiveContext => !isApplicationReflection;

  bool get allowsNegativeContext => !isApplicationReflection;

  bool get isApplicationReflection =>
      this == QuranDimension.applicationReflection;

  String contextPrompt(TernaryOutcome outcome) {
    if (!contextAllowed(this, outcome)) return '';
    return 'Factors you noticed (optional). They are not causes.';
  }
}

bool contextAllowed(QuranDimension subject, TernaryOutcome outcome) {
  if (outcome == TernaryOutcome.positive) return subject.allowsPositiveContext;
  if (outcome == TernaryOutcome.negative) return subject.allowsNegativeContext;
  return false;
}

extension TernaryOutcomeX on TernaryOutcome {
  bool get isRecorded => this != TernaryOutcome.unanswered;

  String get legendLabel => switch (this) {
    TernaryOutcome.positive => 'Recorded sitting',
    TernaryOutcome.negative => 'I did not notice this today',
    TernaryOutcome.unanswered => 'Unanswered',
  };
}

TernaryOutcome ternaryFromJson(Object? value) {
  if (value is! String) return TernaryOutcome.unanswered;
  return switch (value) {
    'readOrListened' ||
    'engaged' ||
    'practised' ||
    'studied' ||
    'reflected' ||
    'noticed' ||
    'positive' => TernaryOutcome.positive,
    'didNot' || 'negative' => TernaryOutcome.negative,
    _ => TernaryOutcome.unanswered,
  };
}

String ternaryToJson(QuranDimension dimension, TernaryOutcome outcome) {
  if (outcome == TernaryOutcome.unanswered) return 'unanswered';
  if (outcome == TernaryOutcome.negative) return 'didNot';
  return switch (dimension) {
    QuranDimension.reading => 'readOrListened',
    QuranDimension.meaning => 'engaged',
    QuranDimension.memorisation || QuranDimension.revision => 'practised',
    QuranDimension.tafsir => 'studied',
    QuranDimension.reflection ||
    QuranDimension.applicationReflection => 'reflected',
    QuranDimension.consciousApplication => 'noticed',
  };
}

bool readingLockedByMeaning(Map<QuranDimension, TernaryOutcome> _) {
  return false;
}

bool canSetQuranOutcome({
  required Map<QuranDimension, TernaryOutcome> quran,
  required QuranDimension dimension,
  required TernaryOutcome outcome,
}) {
  if (dimension == QuranDimension.reading &&
      outcome != TernaryOutcome.positive &&
      readingLockedByMeaning(quran)) {
    return false;
  }
  return true;
}
