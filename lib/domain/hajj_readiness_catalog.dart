import 'hajj_planning.dart';

class HajjReadinessTemplate {
  const HajjReadinessTemplate({
    required this.id,
    required this.group,
    required this.title,
  });

  final String id;
  final String group;
  final String title;
}

const kHajjReadinessGroups = [
  'Passport and travel documentation',
  'Residence and return-entry documentation',
  'Official registration route',
  'Authorized provider and package arrangements',
  'Financial preparation and payments',
  'Employment leave and family arrangements',
  'Health and accessibility preparation',
  'Essential Hajj learning and practical rehearsal',
  'Departure and return logistics',
];

const kHajjReadinessCatalog = [
  HajjReadinessTemplate(
    id: 'rdy.passport.valid',
    group: 'Passport and travel documentation',
    title: 'Passport validity recorded',
  ),
  HajjReadinessTemplate(
    id: 'rdy.travel.docs',
    group: 'Passport and travel documentation',
    title: 'Travel documents listed',
  ),
  HajjReadinessTemplate(
    id: 'rdy.residence.reentry',
    group: 'Residence and return-entry documentation',
    title: 'Residence and return-entry papers noted',
  ),
  HajjReadinessTemplate(
    id: 'rdy.official.route',
    group: 'Official registration route',
    title: 'Official registration route named by you',
  ),
  HajjReadinessTemplate(
    id: 'rdy.provider.package',
    group: 'Authorized provider and package arrangements',
    title: 'Provider or package notes (user-owned)',
  ),
  HajjReadinessTemplate(
    id: 'rdy.finance.prep',
    group: 'Financial preparation and payments',
    title: 'Financial preparation noted',
  ),
  HajjReadinessTemplate(
    id: 'rdy.leave.family',
    group: 'Employment leave and family arrangements',
    title: 'Leave and family arrangements noted',
  ),
  HajjReadinessTemplate(
    id: 'rdy.health.access',
    group: 'Health and accessibility preparation',
    title: 'Health and accessibility notes',
  ),
  HajjReadinessTemplate(
    id: 'rdy.learning.rehearsal',
    group: 'Essential Hajj learning and practical rehearsal',
    title: 'Learning and rehearsal you chose',
  ),
  HajjReadinessTemplate(
    id: 'rdy.logistics.return',
    group: 'Departure and return logistics',
    title: 'Departure and return logistics noted',
  ),
];

List<HajjReadinessPrerequisite> seededHajjReadiness() {
  return [
    for (final item in kHajjReadinessCatalog)
      HajjReadinessPrerequisite(
        id: item.id,
        group: item.group,
        title: item.title,
      ),
  ];
}

const kHajjTravelerReadinessCatalog = [
  HajjReadinessTemplate(
    id: 'trv.passport.valid',
    group: 'Personal documentation',
    title: 'Passport validity',
  ),
  HajjReadinessTemplate(
    id: 'trv.residence.valid',
    group: 'Personal documentation',
    title: 'Legal residence validity',
  ),
  HajjReadinessTemplate(
    id: 'trv.registration.eligibility',
    group: 'Registration',
    title: 'Registration eligibility verification',
  ),
  HajjReadinessTemplate(
    id: 'trv.health.prep',
    group: 'Health',
    title: 'Health preparation',
  ),
  HajjReadinessTemplate(
    id: 'trv.travel.arrangements',
    group: 'Travel',
    title: 'Departure and return arrangements',
  ),
];

List<HajjReadinessPrerequisite> seededHajjTravelerReadiness(String travelerId) {
  return [
    for (final item in kHajjTravelerReadinessCatalog)
      HajjReadinessPrerequisite(
        id: '${item.id}.$travelerId',
        group: item.group,
        title: item.title,
        travelerId: travelerId,
      ),
  ];
}

HajjTravelerProfile withSeededTravelerReadiness(HajjTravelerProfile traveler) {
  if (traveler.readiness.isNotEmpty) return traveler;
  return traveler.copyWith(readiness: seededHajjTravelerReadiness(traveler.id));
}
