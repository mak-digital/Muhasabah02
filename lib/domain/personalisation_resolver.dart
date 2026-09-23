import 'monitor_domain.dart';
import 'personal_mix.dart';
import 'quran.dart';

/// Why a domain or mix row is included or omitted. Factual only; not a score.
enum PersonalisationReason {
  explicitDomain,
  explicitMix,
  sameAsDomains,
  hiddenDomain,
  excludedByMix,
  unknownOrRetired,
}

/// Pure resolution of explicit domain visibility and Personal Mix.
///
/// Reuses existing mix-key rules. Does not persist, score, read reflection
/// text, or consume Recognition. Convenience order may sort included rows
/// only; it cannot reintroduce excluded ones.
class PersonalisationResolver {
  const PersonalisationResolver({
    required this.visibleDomains,
    required this.mix,
  });

  final Set<MonitorDomain> visibleDomains;
  final PersonalMix mix;

  Set<String> get effectiveRowIds =>
      resolvePersonalMixKeys(mix, visibleDomains);

  bool isDomainVisible(MonitorDomain domain) => visibleDomains.contains(domain);

  bool isRowIncluded(String rowId) => effectiveRowIds.contains(rowId);

  /// Home weeks follow the mix. Hidden domains stay out.
  List<MonitorDomain> get homeDomains => homeMixDomains(visibleDomains, mix);

  /// Review lists every visible domain; mix-touched domains come first.
  List<MonitorDomain> get reviewDomains =>
      orderedVisibleDomains(visibleDomains, mix);

  PersonalisationReason domainReason(MonitorDomain domain) {
    if (!isDomainVisible(domain)) return PersonalisationReason.hiddenDomain;
    return PersonalisationReason.explicitDomain;
  }

  PersonalisationReason rowReason(String rowId) {
    final item = mixItemById[rowId];
    if (item == null) return PersonalisationReason.unknownOrRetired;
    if (!isDomainVisible(item.domain)) {
      return PersonalisationReason.hiddenDomain;
    }
    if (isRowIncluded(rowId)) {
      return mix.kind == PersonalMixKind.sameAsDomains
          ? PersonalisationReason.sameAsDomains
          : PersonalisationReason.explicitMix;
    }
    return PersonalisationReason.excludedByMix;
  }

  /// [convenienceFirst] may reorder rows that are already included.
  /// Unknown, hidden, and mix-excluded ids are dropped.
  List<String> rowsPreferringConvenience(Iterable<String> convenienceFirst) {
    final effective = effectiveRowIds;
    final seen = <String>{};
    final ordered = <String>[];
    for (final id in convenienceFirst) {
      if (effective.contains(id) && seen.add(id)) ordered.add(id);
    }
    for (final id in effective) {
      if (seen.add(id)) ordered.add(id);
    }
    return ordered;
  }

  List<QuranDimension> get includedQuranDimensions =>
      mixQuranDimensions(effectiveRowIds);

  /// Qur’an peer dimensions included in the current mix. Recitation and
  /// Application Reflection stay out. Hidden Qur’an yields an empty list.
  List<QuranDimension> get eligibleRecognitionSubjects {
    if (!isDomainVisible(MonitorDomain.quran)) return const [];
    return [
      for (final dimension in includedQuranDimensions)
        if (dimension.isNeutralPeerDimension) dimension,
    ];
  }

  bool get includesApplicationReflection =>
      isRowIncluded('quran.applicationReflection');
}
