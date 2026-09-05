import 'quran.dart';

class HomeTraceRow {
  const HomeTraceRow({
    required this.storageKey,
    required this.label,
    required this.band,
  });

  final String storageKey;
  final String label;
  final String band;
}

const dhikrHomeRows = [
  HomeTraceRow(
    storageKey: 'dhikr.morningAdhkar',
    label: 'Morning Adhkar',
    band: 'Timed adhkar',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.eveningAdhkar',
    label: 'Evening Adhkar',
    band: 'Timed adhkar',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.generalDhikr',
    label: 'General Dhikr',
    band: 'Other remembrance',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.gratitudeDhikr',
    label: 'Gratitude Dhikr',
    band: 'Other remembrance',
  ),
  HomeTraceRow(
    storageKey: 'dhikr.travelDhikr',
    label: 'Travel Remembrance',
    band: 'Other remembrance',
  ),
];

const familyHomeRows = [
  HomeTraceRow(
    storageKey: 'family.parentsContact',
    label: 'Parent Contact',
    band: 'Parents',
  ),
  HomeTraceRow(
    storageKey: 'family.parentsVisit',
    label: 'Parent Visit',
    band: 'Parents',
  ),
  HomeTraceRow(
    storageKey: 'family.familyContact',
    label: 'Sibling Contact',
    band: 'Siblings',
  ),
  HomeTraceRow(
    storageKey: 'family.siblingSupport',
    label: 'Sibling Support',
    band: 'Siblings',
  ),
  HomeTraceRow(
    storageKey: 'family.relativeContact',
    label: 'Relative Contact',
    band: 'Kinship',
  ),
  HomeTraceRow(
    storageKey: 'family.kinshipCare',
    label: 'Kinship Support',
    band: 'Kinship',
  ),
  HomeTraceRow(
    storageKey: 'family.sickVisit',
    label: 'Sick Visit',
    band: 'Community care',
  ),
  HomeTraceRow(
    storageKey: 'family.sickContact',
    label: 'Sick Contact',
    band: 'Community care',
  ),
  HomeTraceRow(
    storageKey: 'family.supportUnderStress',
    label: 'Support Under Stress',
    band: 'Community care',
  ),
];

const charityHomeRows = [
  HomeTraceRow(
    storageKey: 'charity.voluntary',
    label: 'Voluntary Charity',
    band: 'Giving',
  ),
  HomeTraceRow(
    storageKey: 'charity.householdGiving',
    label: 'Family Support',
    band: 'Giving',
  ),
  HomeTraceRow(
    storageKey: 'charity.community',
    label: 'Community Support',
    band: 'Giving',
  ),
  HomeTraceRow(
    storageKey: 'charity.educational',
    label: 'Educational Support',
    band: 'Care',
  ),
  HomeTraceRow(
    storageKey: 'charity.emergency',
    label: 'Emergency Support',
    band: 'Care',
  ),
  HomeTraceRow(
    storageKey: 'charity.financialStress',
    label: 'Support Under Financial Stress',
    band: 'Care',
  ),
];

const fastingHomeRows = [
  HomeTraceRow(
    storageKey: 'fasting.weeklySunnah',
    label: 'Weekly Sunnah Fast',
    band: 'Voluntary and make-up',
  ),
  HomeTraceRow(
    storageKey: 'fasting.monthly',
    label: 'White Days (Ayyam Al-Bid)',
    band: 'Voluntary and make-up',
  ),
  HomeTraceRow(
    storageKey: 'fasting.makeup',
    label: 'Make-up Fast',
    band: 'Voluntary and make-up',
  ),
  HomeTraceRow(
    storageKey: 'fasting.ramadanPrep',
    label: 'Ramadan Preparation',
    band: 'Voluntary and make-up',
  ),
];

const hadithHomeRows = [
  HomeTraceRow(
    storageKey: 'hadith.reading',
    label: 'Reading',
    band: 'Encounter',
  ),
  HomeTraceRow(
    storageKey: 'hadith.listening',
    label: 'Listening',
    band: 'Encounter',
  ),
  HomeTraceRow(
    storageKey: 'hadith.memorisation',
    label: 'Memorisation',
    band: 'Retention',
  ),
  HomeTraceRow(
    storageKey: 'hadith.revision',
    label: 'Revision',
    band: 'Retention',
  ),
  HomeTraceRow(
    storageKey: 'hadith.studyCircle',
    label: 'Study Circle',
    band: 'Learning',
  ),
  HomeTraceRow(
    storageKey: 'hadith.teachingDiscussion',
    label: 'Teaching / Discussion',
    band: 'Learning',
  ),
  HomeTraceRow(
    storageKey: 'hadith.reflection',
    label: 'Hadith Reflection',
    band: 'Notice',
  ),
];

const allHomeTraceRows = [
  ...dhikrHomeRows,
  ...familyHomeRows,
  ...charityHomeRows,
  ...fastingHomeRows,
  ...hadithHomeRows,
];

HomeTraceRow? homeTraceRowByKey(String storageKey) {
  for (final row in allHomeTraceRows) {
    if (row.storageKey == storageKey) return row;
  }
  return null;
}

List<String> bandsFor(List<HomeTraceRow> rows) {
  final seen = <String>[];
  for (final row in rows) {
    if (!seen.contains(row.band)) seen.add(row.band);
  }
  return seen;
}

Map<String, TernaryOutcome> tracesFromJson(Object? json) {
  final traces = <String, TernaryOutcome>{};
  if (json is! Map) return traces;
  for (final entry in json.entries) {
    traces['${entry.key}'] = ternaryFromJson(entry.value);
  }
  return traces;
}

Map<String, String> tracesToJson(Map<String, TernaryOutcome> traces) {
  return {
    for (final entry in traces.entries)
      if (entry.value != TernaryOutcome.unanswered)
        entry.key: entry.value == TernaryOutcome.positive
            ? 'positive'
            : 'didNot',
  };
}

enum HadithMemorisationFocus { unanswered, reviewing, memorising, memorised }

extension HadithMemorisationFocusX on HadithMemorisationFocus {
  String get label => switch (this) {
    HadithMemorisationFocus.unanswered => 'Not recorded',
    HadithMemorisationFocus.reviewing => 'Reviewing',
    HadithMemorisationFocus.memorising => 'Memorising',
    HadithMemorisationFocus.memorised => 'Memorised',
  };

  static HadithMemorisationFocus fromId(String? id) {
    return HadithMemorisationFocus.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HadithMemorisationFocus.unanswered,
    );
  }
}
