import 'activities.dart';
import 'prayer.dart';
import 'quran.dart';

const kFactorNotRecorded = '__not_recorded__';

enum FactorGroups { none, helping, distracting, both }

extension FactorGroupsX on FactorGroups {
  bool get showHelping =>
      this == FactorGroups.helping || this == FactorGroups.both;

  bool get showDistracting =>
      this == FactorGroups.distracting || this == FactorGroups.both;

  bool get isVisible => this != FactorGroups.none;
}

FactorGroups factorGroupsForSalahActivity(String activityId) {
  switch (activityId) {
    case 'congregationOnTime':
    case 'smallCongregation':
    case 'aloneOnTime':
      return FactorGroups.helping;
    case 'joinedCongregationLate':
    case 'prayedLate':
    case 'missedMadeUp':
      return FactorGroups.both;
    case 'missed':
      return FactorGroups.distracting;
    case 'excused':
    case ActivityIds.other:
    case ActivityIds.unanswered:
      return FactorGroups.none;
    default:
      return FactorGroups.none;
  }
}

FactorGroups factorGroupsForTernary(TernaryOutcome outcome) {
  return switch (outcome) {
    TernaryOutcome.unanswered => FactorGroups.none,
    TernaryOutcome.positive => FactorGroups.helping,
    TernaryOutcome.negative => FactorGroups.distracting,
  };
}

FactorGroups factorGroupsForPrayerStatus(PrayerStatus status) {
  return switch (status) {
    PrayerStatus.unanswered => FactorGroups.none,
    PrayerStatus.onTime => FactorGroups.helping,
    PrayerStatus.late => FactorGroups.both,
    PrayerStatus.missed => FactorGroups.distracting,
    PrayerStatus.excused => FactorGroups.none,
    PrayerStatus.other => FactorGroups.none,
  };
}

String selectedFactorId(List<String> ids) {
  if (ids.isEmpty) return kFactorNotRecorded;
  return ids.first;
}

String safeFactorId(String id, Iterable<String> knownIds) {
  if (id == kFactorNotRecorded) return id;
  if (knownIds.contains(id)) return id;
  return kFactorNotRecorded;
}

List<String> idsFromFactorChoice(String id) {
  if (id.isEmpty || id == kFactorNotRecorded || id == ActivityIds.unanswered) {
    return const [];
  }
  return [id];
}
