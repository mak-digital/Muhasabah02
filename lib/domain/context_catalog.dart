class ContextFactor {
  const ContextFactor({required this.id, required this.label});

  final String id;
  final String label;
}

class ContextCatalog {
  static const positive = <ContextFactor>[
    ContextFactor(id: 'time_available', label: 'Time available'),
    ContextFactor(id: 'quiet_space', label: 'Quiet space'),
    ContextFactor(id: 'dedicated_time', label: 'Dedicated time'),
    ContextFactor(id: 'reminder', label: 'Reminder'),
    ContextFactor(
      id: 'quran.translationAvailable',
      label: 'Translation available',
    ),
    ContextFactor(id: 'quran.tafsirAvailable', label: 'Tafsir available'),
    ContextFactor(id: 'quran.communityProgramme', label: 'Community programme'),
    ContextFactor(id: 'quran.studyCircle', label: 'Study circle'),
    ContextFactor(id: 'quran.teacherGuidance', label: 'Teacher guidance'),
    ContextFactor(
      id: 'quran.familyParticipation',
      label: 'Family participation',
    ),
    ContextFactor(
      id: 'quran.friendParticipation',
      label: 'Friend participation',
    ),
    ContextFactor(id: 'routine', label: 'Existing routine'),
    ContextFactor(
      id: 'quran.dedicatedStudySession',
      label: 'Dedicated study session',
    ),
    ContextFactor(id: 'quran.travelOpportunity', label: 'Travel opportunity'),
    ContextFactor(id: 'other', label: 'Other'),
  ];

  static const negative = <ContextFactor>[
    ContextFactor(id: 'time_limited', label: 'Limited time'),
    ContextFactor(id: 'fatigue', label: 'Fatigue'),
    ContextFactor(id: 'quran.workCommitments', label: 'Work commitments'),
    ContextFactor(id: 'quran.familyCommitments', label: 'Family commitments'),
    ContextFactor(id: 'travel', label: 'Travel'),
    ContextFactor(id: 'quran.health', label: 'Health'),
    ContextFactor(
      id: 'quran.socialMediaDistraction',
      label: 'Social media distraction',
    ),
    ContextFactor(id: 'quran.deviceDistraction', label: 'Device distraction'),
    ContextFactor(id: 'quran.lackOfRoutine', label: 'Lack of routine'),
    ContextFactor(id: 'competing_priority', label: 'Competing priorities'),
    ContextFactor(
      id: 'quran.unexpectedInterruption',
      label: 'Unexpected interruption',
    ),
    ContextFactor(id: 'other', label: 'Other'),
  ];

  static List<ContextFactor> forPolarity(String polarity) {
    return polarity == 'negative' ? negative : positive;
  }

  static String labelFor(String id, String polarity) {
    final list = forPolarity(polarity);
    for (final factor in list) {
      if (factor.id == id) return factor.label;
    }
    if (id == 'energy') return 'Energy felt sufficient';
    if (id == 'company') return 'Company or family setting';
    if (id == 'illness') return 'Health';
    if (id == 'distraction') return 'Distraction';
    if (id == 'forgot') return 'Forgot';
    return id;
  }

  static bool isKnown(String id, String polarity) {
    if (forPolarity(polarity).any((factor) => factor.id == id)) return true;
    return id == 'energy' ||
        id == 'company' ||
        id == 'illness' ||
        id == 'distraction' ||
        id == 'forgot';
  }
}
