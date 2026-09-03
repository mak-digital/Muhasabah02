enum QuranDimension {
  reading,
  meaning,
  memorisation,
  revision,
  tafsir,
  reflection,
  applicationReflection,
}

enum TernaryOutcome { unanswered, positive, negative }

extension QuranDimensionX on QuranDimension {
  String get jsonKey => name;

  String get label => switch (this) {
    QuranDimension.reading => 'Reading/listening',
    QuranDimension.meaning => 'Meaning',
    QuranDimension.memorisation => 'Memorisation',
    QuranDimension.revision => 'Revision',
    QuranDimension.tafsir => 'Tafsir',
    QuranDimension.reflection => 'Reflection',
    QuranDimension.applicationReflection => 'Application Reflection',
  };

  String get question => switch (this) {
    QuranDimension.reading =>
      'Did you spend time reading or listening to Qur’an today?',
    QuranDimension.meaning => 'Did you spend time engaging with the meaning or translation of Qur\'an today?',
    QuranDimension.memorisation =>
      'Did you spend time memorising Qur\'an today?',
    QuranDimension.revision =>
      'Did you spend time revising memorised Qur\'an today?',
    QuranDimension.tafsir => 'Did you spend time studying tafsir or an explanation of an ayah or passage today?',
    QuranDimension.reflection => 'Did you spend time reflecting on the meaning of an ayah or passage today?',
    QuranDimension.applicationReflection => 'Did you spend time reflecting on how something from the Qur’an might relate to your daily life?',
  };

  String get positiveLabel => switch (this) {
    QuranDimension.reading => 'Read or listened',
    QuranDimension.meaning => 'Engaged with meaning/translation',
    QuranDimension.memorisation => 'Practised memorisation',
    QuranDimension.revision => 'Practised revision',
    QuranDimension.tafsir => 'Studied tafsir/explanation',
    QuranDimension.reflection => 'Spent time reflecting',
    QuranDimension.applicationReflection =>
      'Reflected on possible practical relevance',
  };

  String get negativeLabel => switch (this) {
    QuranDimension.reading => 'Did not read or listen',
    QuranDimension.meaning => 'Did not engage with meaning/translation',
    QuranDimension.memorisation => 'Did not practise',
    QuranDimension.revision => 'Did not practise',
    QuranDimension.tafsir => 'Did not study tafsir/explanation',
    QuranDimension.reflection => 'Did not spend time reflecting',
    QuranDimension.applicationReflection =>
      'Did not reflect on practical relevance',
  };

  bool get isPrimaryDailyItem => this == QuranDimension.reading;

  bool get isNeutralPeerDimension => this != QuranDimension.reading;

  bool get allowsPositiveContext => switch (this) {
    QuranDimension.meaning ||
    QuranDimension.memorisation ||
    QuranDimension.revision ||
    QuranDimension.tafsir ||
    QuranDimension.reflection => true,
    QuranDimension.reading || QuranDimension.applicationReflection => false,
  };

  bool get allowsNegativeContext => switch (this) {
    QuranDimension.meaning ||
    QuranDimension.memorisation ||
    QuranDimension.revision => true,
    QuranDimension.tafsir ||
    QuranDimension.reflection ||
    QuranDimension.reading ||
    QuranDimension.applicationReflection => false,
  };

  bool get isApplicationReflection =>
      this == QuranDimension.applicationReflection;

  String contextPrompt(TernaryOutcome outcome) {
    return switch ((this, outcome)) {
      (QuranDimension.meaning, TernaryOutcome.positive) => 'What supported your engagement with meaning or translation? (Optional)',
      (QuranDimension.meaning, TernaryOutcome.negative) => 'Was there a main factor in not engaging with meaning or translation today? (Optional)',
      (QuranDimension.memorisation, TernaryOutcome.positive) =>
        'What supported your memorisation practice today? (Optional)',
      (QuranDimension.memorisation, TernaryOutcome.negative) => 'Was there a main factor in not practising memorisation today? (Optional)',
      (QuranDimension.revision, TernaryOutcome.positive) =>
        'What supported your revision practice today? (Optional)',
      (QuranDimension.revision, TernaryOutcome.negative) =>
        'Was there a main factor in not practising revision today? (Optional)',
      (QuranDimension.tafsir, TernaryOutcome.positive) =>
        'What supported your tafsir or explanation study today? (Optional)',
      (QuranDimension.reflection, TernaryOutcome.positive) =>
        'What supported or prompted your reflection today? (Optional)',
      _ => '',
    };
  }
}

extension TernaryOutcomeX on TernaryOutcome {
  bool get isRecorded => this != TernaryOutcome.unanswered;

  String get legendLabel => switch (this) {
    TernaryOutcome.positive => 'Recorded activity',
    TernaryOutcome.negative => 'Recorded as not done',
    TernaryOutcome.unanswered => 'No answer recorded',
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
  };
}
