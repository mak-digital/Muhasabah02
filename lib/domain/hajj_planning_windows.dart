import 'date_key.dart';
import 'display_calendar.dart';
import 'hajj_pathway.dart';

const kHajjDhulHijjahMonth = 12;
const kHajjRitesStartDay = 8;
const kHajjRitesEndDay = 13;

const kHajjPlanningEstimateNote =
    'Civil (tabular) planning estimate. Not an official announcement. Confirm on the source when you can.';

class HajjLunarDay {
  const HajjLunarDay({required this.gregorian, required this.hijri});

  final DateTime gregorian;
  final CivilDateParts hijri;

  String get dateKeyValue => dateKey(gregorian);
}

class HajjLunarSpan {
  const HajjLunarSpan({required this.start, required this.end});

  final HajjLunarDay start;
  final HajjLunarDay end;

  bool contains(DateTime day) {
    final key = dateKey(day);
    return key.compareTo(start.dateKeyValue) >= 0 &&
        key.compareTo(end.dateKeyValue) <= 0;
  }
}

class HajjRegistrationEstimate {
  const HajjRegistrationEstimate({
    required this.family,
    required this.typicalWindow,
    required this.suggestedOpen,
    required this.suggestedClose,
    required this.suggestedPackageDeadline,
  });

  final HajjPathwayFamily family;
  final HajjLunarSpan typicalWindow;
  final HajjLunarDay suggestedOpen;
  final HajjLunarDay suggestedClose;
  final HajjLunarDay suggestedPackageDeadline;
}

HajjLunarDay hajjLunarDay(int hijriYear, int month, int day) {
  final gregorian = gregorianFromHijri(hijriYear, month, day);
  return HajjLunarDay(gregorian: gregorian, hijri: hijriParts(gregorian));
}

/// Next civil Hajj season (Dhul-Hijjah) on or after [today].
int upcomingHajjHijriYear(DateTime today) {
  final parts = hijriParts(today);
  if (parts.month < kHajjDhulHijjahMonth) return parts.year;
  if (parts.month == kHajjDhulHijjahMonth && parts.day <= kHajjRitesEndDay) {
    return parts.year;
  }
  return parts.year + 1;
}

int resolveHajjPlanningHijriYear({
  required DateTime today,
  int? storedHijriYear,
  required bool seasonUndecided,
}) {
  if (!seasonUndecided &&
      storedHijriYear != null &&
      storedHijriYear >= 1400 &&
      storedHijriYear <= 1600) {
    return storedHijriYear;
  }
  return upcomingHajjHijriYear(today);
}

/// Civil 8–13 Dhul-Hijjah of [hijriYear]. Initial planning only.
HajjLunarSpan hajjRitesPlanningWindow(int hijriYear) {
  return HajjLunarSpan(
    start: hajjLunarDay(hijriYear, kHajjDhulHijjahMonth, kHajjRitesStartDay),
    end: hajjLunarDay(hijriYear, kHajjDhulHijjahMonth, kHajjRitesEndDay),
  );
}

/// Typical registration windows from civil-calendar historical pattern.
/// Not a quota, Nusuk ruling, or live feed.
HajjRegistrationEstimate hajjRegistrationEstimate({
  required HajjPathwayFamily family,
  required int hijriYear,
}) {
  final window = switch (family) {
    HajjPathwayFamily.saudiDomestic => HajjLunarSpan(
      start: hajjLunarDay(hijriYear, 11, 1),
      end: hajjLunarDay(hijriYear, 11, 20),
    ),
    HajjPathwayFamily.officialDirect ||
    HajjPathwayFamily.expatriate => HajjLunarSpan(
      start: hajjLunarDay(hijriYear, 10, 1),
      end: hajjLunarDay(hijriYear, 11, 10),
    ),
    HajjPathwayFamily.nationalMission => HajjLunarSpan(
      start: hajjLunarDay(hijriYear, 6, 1),
      end: hajjLunarDay(hijriYear, 9, 15),
    ),
    HajjPathwayFamily.licensedOperator => HajjLunarSpan(
      start: hajjLunarDay(hijriYear, 8, 1),
      end: hajjLunarDay(hijriYear, 10, 15),
    ),
    HajjPathwayFamily.mixedFamily => HajjLunarSpan(
      start: hajjLunarDay(hijriYear, 6, 1),
      end: hajjLunarDay(hijriYear, 11, 10),
    ),
  };
  final suggested = switch (family) {
    HajjPathwayFamily.saudiDomestic => (
      open: hajjLunarDay(hijriYear, 11, 1),
      close: hajjLunarDay(hijriYear, 11, 15),
      pack: hajjLunarDay(hijriYear, 11, 20),
    ),
    HajjPathwayFamily.officialDirect || HajjPathwayFamily.expatriate => (
      open: hajjLunarDay(hijriYear, 10, 10),
      close: hajjLunarDay(hijriYear, 11, 1),
      pack: hajjLunarDay(hijriYear, 11, 10),
    ),
    HajjPathwayFamily.nationalMission => (
      open: hajjLunarDay(hijriYear, 7, 1),
      close: hajjLunarDay(hijriYear, 8, 15),
      pack: hajjLunarDay(hijriYear, 9, 1),
    ),
    HajjPathwayFamily.licensedOperator => (
      open: hajjLunarDay(hijriYear, 8, 15),
      close: hajjLunarDay(hijriYear, 10, 1),
      pack: hajjLunarDay(hijriYear, 10, 15),
    ),
    HajjPathwayFamily.mixedFamily => (
      open: hajjLunarDay(hijriYear, 7, 1),
      close: hajjLunarDay(hijriYear, 10, 15),
      pack: hajjLunarDay(hijriYear, 11, 1),
    ),
  };
  return HajjRegistrationEstimate(
    family: family,
    typicalWindow: window,
    suggestedOpen: suggested.open,
    suggestedClose: suggested.close,
    suggestedPackageDeadline: suggested.pack,
  );
}

HajjPathwayFamily? hajjPathwayFamilyFromAuthority(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return null;
  for (final family in HajjPathwayFamily.values) {
    if (family.name == text || family.label == text) return family;
  }
  final lower = text.toLowerCase();
  if (lower.contains('nusuk') || lower.contains('direct')) {
    return HajjPathwayFamily.officialDirect;
  }
  if (lower.contains('mission') || lower.contains('ministry')) {
    return HajjPathwayFamily.nationalMission;
  }
  if (lower.contains('operator') || lower.contains('licensed')) {
    return HajjPathwayFamily.licensedOperator;
  }
  if (lower.contains('saudi') || lower.contains('domestic')) {
    return HajjPathwayFamily.saudiDomestic;
  }
  if (lower.contains('expat')) return HajjPathwayFamily.expatriate;
  if (lower.contains('family') || lower.contains('mixed')) {
    return HajjPathwayFamily.mixedFamily;
  }
  return null;
}
