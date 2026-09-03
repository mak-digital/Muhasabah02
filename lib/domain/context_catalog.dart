class ContextFactor {
  const ContextFactor({required this.id, required this.label});

  final String id;
  final String label;
}

class ContextCatalog {
  static const positive = <ContextFactor>[
    ContextFactor(id: 'time_available', label: 'Time was available'),
    ContextFactor(id: 'energy', label: 'Energy felt sufficient'),
    ContextFactor(id: 'quiet_space', label: 'A quieter space'),
    ContextFactor(id: 'reminder', label: 'A reminder or cue'),
    ContextFactor(id: 'company', label: 'Company or family setting'),
    ContextFactor(id: 'routine', label: 'An existing routine'),
    ContextFactor(id: 'other', label: 'Something else'),
  ];

  static const negative = <ContextFactor>[
    ContextFactor(id: 'time_limited', label: 'Limited time'),
    ContextFactor(id: 'fatigue', label: 'Fatigue'),
    ContextFactor(id: 'distraction', label: 'Distraction'),
    ContextFactor(id: 'travel', label: 'Travel or being away from usual place'),
    ContextFactor(id: 'illness', label: 'Feeling unwell'),
    ContextFactor(id: 'forgot', label: 'Forgot'),
    ContextFactor(id: 'competing_priority', label: 'Another competing demand'),
    ContextFactor(id: 'other', label: 'Something else'),
  ];

  static List<ContextFactor> forPolarity(String polarity) {
    return polarity == 'negative' ? negative : positive;
  }

  static String labelFor(String id, String polarity) {
    final list = forPolarity(polarity);
    for (final factor in list) {
      if (factor.id == id) return factor.label;
    }
    return id;
  }

  static bool isKnown(String id, String polarity) {
    return forPolarity(polarity).any((factor) => factor.id == id);
  }
}
