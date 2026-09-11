import 'context_catalog.dart';

/// One helping/distracting catalog for Charity Giving and Care traces.
/// Row-specific research tables map onto these buckets; they are not separate
/// dropdowns. Provenance only — not a score, survey, or cause.
class CharityFactorCatalog {
  static const support = <ContextFactor>[
    ContextFactor(id: 'charity.valuesBeliefs', label: 'Values & Beliefs'),
    ContextFactor(
      id: 'charity.relationshipsTrust',
      label: 'Relationships & Trust',
    ),
    ContextFactor(
      id: 'charity.responsibilityReciprocity',
      label: 'Responsibility & Reciprocity',
    ),
    ContextFactor(
      id: 'charity.socialInfluenceLeadership',
      label: 'Social Influence & Leadership',
    ),
    ContextFactor(
      id: 'charity.capacityResources',
      label: 'Capacity & Resources',
    ),
  ];

  static const challenge = <ContextFactor>[
    ContextFactor(
      id: 'charity.financialConstraints',
      label: 'Financial Constraints',
    ),
    ContextFactor(id: 'charity.trustDeficits', label: 'Trust Deficits'),
    ContextFactor(
      id: 'charity.relationshipConflicts',
      label: 'Relationship Conflicts',
    ),
    ContextFactor(
      id: 'charity.organizationalWeaknesses',
      label: 'Organizational Weaknesses',
    ),
    ContextFactor(
      id: 'charity.competingPrioritiesLowEngagement',
      label: 'Competing Priorities & Low Engagement',
    ),
  ];

  static const _legacyLabels = <String, String>{
    'charity.religiousMoralMotivation': 'Religious/Moral Motivation',
    'charity.empathyCompassion': 'Empathy & Compassion',
    'charity.trustInInstitutions': 'Trust in Institutions',
    'charity.socialCommunityInfluence': 'Social & Community Influence',
    'charity.financialCapacity': 'Financial Capacity',
    'charity.lackOfTrust': 'Lack of Trust',
    'charity.limitedAwareness': 'Limited Awareness',
    'charity.donorFatigue': 'Donor Fatigue',
    'charity.competingPriorities': 'Competing Priorities',
  };

  static List<ContextFactor> withExisting(
    List<ContextFactor> catalog,
    Iterable<String> existingIds,
    String polarity,
  ) {
    final next = [...catalog];
    for (final id in existingIds) {
      if (id.isEmpty) continue;
      if (next.any((factor) => factor.id == id)) continue;
      next.add(ContextFactor(id: id, label: labelFor(id, polarity)));
    }
    return next;
  }

  static String labelFor(String id, String polarity) {
    final list = polarity == 'negative' ? challenge : support;
    for (final factor in list) {
      if (factor.id == id) return factor.label;
    }
    return _legacyLabels[id] ?? ContextCatalog.labelFor(id, polarity);
  }
}

bool isCharityTrace(String storageKey) => storageKey.startsWith('charity.');

List<ContextFactor> helpingFactorsForHomeTrace(
  String storageKey, {
  Iterable<String> existingIds = const [],
}) {
  if (isCharityTrace(storageKey)) {
    return CharityFactorCatalog.withExisting(
      CharityFactorCatalog.support,
      existingIds,
      'positive',
    );
  }
  return ContextCatalog.positive;
}

List<ContextFactor> distractingFactorsForHomeTrace(
  String storageKey, {
  Iterable<String> existingIds = const [],
}) {
  if (isCharityTrace(storageKey)) {
    return CharityFactorCatalog.withExisting(
      CharityFactorCatalog.challenge,
      existingIds,
      'negative',
    );
  }
  return ContextCatalog.negative;
}

String homeTraceFactorLabel(
  String storageKey,
  String id, {
  required bool helping,
}) {
  final polarity = helping ? 'positive' : 'negative';
  if (isCharityTrace(storageKey)) {
    return CharityFactorCatalog.labelFor(id, polarity);
  }
  return ContextCatalog.labelFor(id, polarity);
}
