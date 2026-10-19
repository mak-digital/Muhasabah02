import 'monitor_domain.dart';
import 'personal_mix.dart';
import 'personalisation_resolver.dart';
import 'practice_dhikr_catalog.dart';

bool practiceLearnShowsDomain(
  MonitorDomain domain,
  PersonalisationResolver resolver,
) {
  return resolver.homeDomains.contains(domain);
}

bool _isMixLabel(MonitorDomain domain, String name) {
  if (name.isEmpty) return false;
  return mixCatalog.any((item) => item.domain == domain && item.label == name);
}

/// Whether a Learn & Practice catalog row should appear for the current
/// Domains in Focus and Personal Mix. Post-fard Salah adhkar require Salah
/// to be in Domains in Focus. Same as Domains keeps every other item of a
/// shown domain. Named and custom mixes keep Home-row matches, then mix
/// subgroups (for example General Dhikr), then extra skims that sit with an
/// included group or band. Stored registers are not rewritten.
bool practiceLearnItemAllowed({
  required MonitorDomain domain,
  required String group,
  required String topic,
  String subgroup = '',
  required PersonalisationResolver resolver,
}) {
  if (!practiceLearnShowsDomain(domain, resolver)) return false;
  if (group == kDhikrGroupPost &&
      !resolver.isDomainVisible(MonitorDomain.salah)) {
    return false;
  }
  if (resolver.mix.kind == PersonalMixKind.sameAsDomains) return true;
  final keys = resolver.effectiveRowIds;
  if (keys.isEmpty) return true;

  final allowed = [
    for (final item in mixCatalog)
      if (item.domain == domain && resolver.mixFocusAllows(item.id)) item,
  ];
  if (allowed.isEmpty) return false;

  if (allowed.any((item) => item.label == topic)) return true;

  if (subgroup.isNotEmpty &&
      subgroup != kDhikrSubHighly &&
      _isMixLabel(domain, subgroup)) {
    return allowed.any((item) => item.label == subgroup);
  }

  if (_isMixLabel(domain, topic)) return false;

  if (allowed.any((item) => item.label == group)) return true;
  if (_isMixLabel(domain, group)) return false;

  if (allowed.any((item) => item.band == group)) return true;

  final hasTraceRows = allowed.any(
    (item) =>
        item.id != kZakatMixKey &&
        item.id != kHajjMixKey &&
        item.id != kProductivityMixKey,
  );
  return !hasTraceRows;
}

List<PracticeDhikrItem> focusedPracticeCatalog({
  required MonitorDomain domain,
  required List<PracticeDhikrItem> catalog,
  required PersonalisationResolver resolver,
}) {
  return [
    for (final item in catalog)
      if (practiceLearnItemAllowed(
        domain: domain,
        group: item.group,
        topic: item.topic,
        subgroup: item.subgroup,
        resolver: resolver,
      ))
        item,
  ];
}

List<String> focusedPracticeGroups({
  required List<String> groups,
  required List<PracticeDhikrItem> catalog,
}) {
  return [
    for (final group in groups)
      if (catalog.any((item) => item.group == group)) group,
  ];
}
