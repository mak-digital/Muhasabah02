import 'hajj_planning.dart';

/// Planning categories. Never legal eligibility classifications.
enum HajjPathwayFamily {
  saudiDomestic,
  officialDirect,
  nationalMission,
  licensedOperator,
  expatriate,
  mixedFamily,
}

extension HajjPathwayFamilyX on HajjPathwayFamily {
  String get label => switch (this) {
    HajjPathwayFamily.saudiDomestic => 'Saudi domestic Hajj',
    HajjPathwayFamily.officialDirect => 'Official direct international booking',
    HajjPathwayFamily.nationalMission =>
      'National Hajj mission or government-managed allocation',
    HajjPathwayFamily.licensedOperator => 'Licensed Hajj operator arrangements',
    HajjPathwayFamily.expatriate =>
      'Expatriate or cross-border residence arrangements',
    HajjPathwayFamily.mixedFamily => 'Mixed-nationality family coordination',
  };

  String get note => switch (this) {
    HajjPathwayFamily.saudiDomestic => 'A planning category if you live and plan to go as a Saudi resident. Not an eligibility decision.',
    HajjPathwayFamily.officialDirect => 'A planning category for booking through an official channel you name. The app does not check quota.',
    HajjPathwayFamily.nationalMission => 'A planning category for a government or mission allocation you record. Not a confirmation of a place.',
    HajjPathwayFamily.licensedOperator => 'A planning category for a licensed operator you choose. The app does not search or book providers.',
    HajjPathwayFamily.expatriate => 'A planning category when nationality and legal residence differ. Confirm the route yourself.',
    HajjPathwayFamily.mixedFamily => 'A planning category when companions have different nationalities. Each person keeps their own confirmations.',
  };

  static HajjPathwayFamily? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final item in HajjPathwayFamily.values) {
      if (item.name == id) return item;
    }
    return null;
  }
}

class HajjPathwaySuggestion {
  const HajjPathwaySuggestion({required this.family, required this.reason});

  final HajjPathwayFamily family;
  final String reason;
}

String? _normCountry(String? value) {
  final trimmed = value?.trim().toUpperCase();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Suggests planning families. Never auto-selects a route.
List<HajjPathwaySuggestion> suggestHajjPathways({
  required HajjJourney journey,
  required List<HajjTravelerProfile> travelers,
}) {
  final linked = [
    for (final traveler in travelers)
      if (journey.travelerIds.isEmpty ||
          journey.travelerIds.contains(traveler.id))
        traveler,
  ];
  final people = linked.isEmpty ? travelers : linked;
  final nationalities = <String>{
    for (final traveler in people)
      if (_normCountry(traveler.nationalityCountry) != null)
        _normCountry(traveler.nationalityCountry)!,
  };
  final departure = _normCountry(journey.departureCountry);
  final suggestions = <HajjPathwayFamily, String>{};

  final saudiResident = people.any(
    (traveler) =>
        _normCountry(traveler.nationalityCountry) == 'SA' &&
        _normCountry(traveler.residenceCountry) == 'SA',
  );
  if (saudiResident && (departure == null || departure == 'SA')) {
    suggestions[HajjPathwayFamily.saudiDomestic] =
        'Nationality and legal residence are recorded as SA.';
  }

  final expatriate = people.any((traveler) {
    final nationality = _normCountry(traveler.nationalityCountry);
    final residence = _normCountry(traveler.residenceCountry);
    return nationality != null && residence != null && nationality != residence;
  });
  if (expatriate) {
    suggestions[HajjPathwayFamily.expatriate] = 'At least one traveler has a nationality different from legal residence.';
  }

  if (nationalities.length >= 2) {
    suggestions[HajjPathwayFamily.mixedFamily] =
        'Companions have more than one recorded nationality.';
  }

  final anyNonSaudi = people.any(
    (traveler) => _normCountry(traveler.nationalityCountry) != 'SA',
  );
  if (anyNonSaudi || (departure != null && departure != 'SA')) {
    suggestions[HajjPathwayFamily.officialDirect] =
        'An international booking route may be relevant. Confirm it yourself.';
    suggestions[HajjPathwayFamily.nationalMission] = 'A national mission or allocation route may be relevant. Confirm it yourself.';
    suggestions[HajjPathwayFamily.licensedOperator] = 'A licensed operator arrangement may be relevant. The app does not search providers.';
  }

  if (suggestions.isEmpty) {
    return const [];
  }
  return [
    for (final family in HajjPathwayFamily.values)
      if (suggestions.containsKey(family))
        HajjPathwaySuggestion(family: family, reason: suggestions[family]!),
  ];
}

class HajjPreparationTemplate {
  const HajjPreparationTemplate({
    required this.id,
    required this.title,
    required this.leadDaysBeforeAnchor,
    required this.processingDurationDays,
    required this.bufferDays,
    this.dependsOn = const [],
  });

  final String id;
  final String title;
  final int leadDaysBeforeAnchor;
  final int processingDurationDays;
  final int bufferDays;
  final List<String> dependsOn;
}

/// Conservative offline estimates. Not official requirements.
const kHajjPreparationTemplates = [
  HajjPreparationTemplate(
    id: 'tpl.route.verify',
    title: 'Registration route verification',
    leadDaysBeforeAnchor: 270,
    processingDurationDays: 21,
    bufferDays: 21,
  ),
  HajjPreparationTemplate(
    id: 'tpl.documents',
    title: 'Passport and residence document readiness',
    leadDaysBeforeAnchor: 240,
    processingDurationDays: 30,
    bufferDays: 21,
    dependsOn: ['tpl.route.verify'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.national.quota',
    title: 'National registration and quota procedures',
    leadDaysBeforeAnchor: 210,
    processingDurationDays: 45,
    bufferDays: 21,
    dependsOn: ['tpl.documents'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.provider.compare',
    title: 'Provider selection and package comparison',
    leadDaysBeforeAnchor: 180,
    processingDurationDays: 21,
    bufferDays: 14,
    dependsOn: ['tpl.route.verify'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.budget',
    title: 'Budget and payment readiness',
    leadDaysBeforeAnchor: 150,
    processingDurationDays: 14,
    bufferDays: 14,
    dependsOn: ['tpl.provider.compare'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.leave',
    title: 'Employment leave',
    leadDaysBeforeAnchor: 120,
    processingDurationDays: 21,
    bufferDays: 14,
  ),
  HajjPreparationTemplate(
    id: 'tpl.health',
    title: 'Health and vaccination planning',
    leadDaysBeforeAnchor: 90,
    processingDurationDays: 30,
    bufferDays: 14,
    dependsOn: ['tpl.documents'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.family',
    title: 'Family and companion coordination',
    leadDaysBeforeAnchor: 90,
    processingDurationDays: 14,
    bufferDays: 14,
  ),
  HajjPreparationTemplate(
    id: 'tpl.learning',
    title: 'Essential Hajj learning',
    leadDaysBeforeAnchor: 60,
    processingDurationDays: 21,
    bufferDays: 7,
  ),
  HajjPreparationTemplate(
    id: 'tpl.transport',
    title: 'Transport and accommodation',
    leadDaysBeforeAnchor: 45,
    processingDurationDays: 14,
    bufferDays: 14,
    dependsOn: ['tpl.provider.compare'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.departure',
    title: 'Final departure readiness',
    leadDaysBeforeAnchor: 21,
    processingDurationDays: 7,
    bufferDays: 7,
    dependsOn: ['tpl.documents', 'tpl.transport', 'tpl.health'],
  ),
  HajjPreparationTemplate(
    id: 'tpl.return',
    title: 'Return and post-Hajj arrangements',
    leadDaysBeforeAnchor: 0,
    processingDurationDays: 7,
    bufferDays: 7,
    dependsOn: ['tpl.departure'],
  ),
];
