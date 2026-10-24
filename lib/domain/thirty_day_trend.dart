import 'activities.dart';
import 'charity_practices.dart';
import 'dhikr_context.dart';
import 'health_practices.dart';
import 'quran.dart';
import 'ummah_practices.dart';
import 'wealth_practices.dart';

class TrendWindowStats {
  const TrendWindowStats({
    required this.startKey,
    required this.endKey,
    required this.denom,
    required this.hits,
  });

  final String startKey;
  final String endKey;
  final int denom;
  final Map<String, int> hits;

  int countFor(String id) => hits[id] ?? 0;
}

bool isChartableResponseId(String? id) {
  if (id == null || id.isEmpty) return false;
  return id != ActivityIds.unanswered;
}

double? trendPercent(int hits, int denom) {
  if (denom <= 0) return null;
  return (hits / denom) * 100;
}

TrendWindowStats measureTrendWindow({
  required List<String> keys,
  required String todayKey,
  required String? Function(String dateKey) idForDate,
  required Iterable<String> optionIds,
  Iterable<String> Function(String dateKey)? hitsForDate,
  bool Function(String dateKey)? dayAnswered,
}) {
  final hits = {for (final id in optionIds) id: 0};
  var denom = 0;
  for (final key in keys) {
    if (key.compareTo(todayKey) > 0) continue;
    final ids = <String>[];
    if (hitsForDate != null) {
      for (final id in hitsForDate(key)) {
        if (isChartableResponseId(id)) ids.add(id);
      }
    } else {
      final id = idForDate(key);
      if (isChartableResponseId(id)) ids.add(id!);
    }
    final answered = dayAnswered?.call(key) ?? ids.isNotEmpty;
    if (!answered) continue;
    denom++;
    for (final id in ids) {
      if (hits.containsKey(id)) {
        hits[id] = hits[id]! + 1;
      }
    }
  }
  return TrendWindowStats(
    startKey: keys.isEmpty ? todayKey : keys.first,
    endKey: keys.isEmpty ? todayKey : keys.last,
    denom: denom,
    hits: hits,
  );
}

/// Rank first-level options for the 30-day chart. At most five ids.
List<String> selectFiveTrendOptionIds({
  required List<String> optionIds,
  required List<TrendWindowStats> windows,
}) {
  final scored = <({String id, double score})>[];
  for (final id in optionIds) {
    final series = [
      for (final window in windows)
        (
          p: trendPercent(window.countFor(id), window.denom),
          d: window.denom,
          h: window.countFor(id),
        ),
    ];
    var change = 0.0;
    for (var i = 1; i < series.length; i++) {
      final a = series[i - 1];
      final b = series[i];
      if (a.p == null || b.p == null) continue;
      final evidence = a.d < b.d ? a.d : b.d;
      final weight = evidence < 3
          ? 0.12
          : evidence < 8
          ? 0.55
          : 1.0;
      final delta = (b.p! - a.p!).abs() * weight;
      if (delta > change) change = delta;
    }
    final defined = [
      for (final s in series)
        if (s.p != null) s.p!,
    ];
    final freq = defined.isEmpty
        ? 0.0
        : defined.reduce((a, b) => a + b) / defined.length;
    var evidence = 0;
    for (final s in series) {
      if (s.d > evidence) evidence = s.d;
    }
    final any = series.any((s) => s.h > 0);
    if (!any) continue;
    final cap = evidence > 12 ? 12 : evidence;
    scored.add((id: id, score: change + freq * 0.14 + cap * 0.04));
  }
  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.id.compareTo(b.id);
  });
  return [for (final item in scored.take(5)) item.id];
}

List<ActivityOption> chartableCatalog(List<ActivityOption> catalog) {
  return [
    for (final option in catalog)
      if (!option.isUnanswered) option,
  ];
}

/// Performed-list formulas for a Dhikr row. Unanswered is omitted.
List<ActivityOption> dhikrContextTrendCatalog(String rowKey) {
  return [
    for (final item in dhikrContextItemsFor(rowKey))
      ActivityOption(
        id: item.id,
        label: item.label,
        ternary: TernaryOutcome.positive,
      ),
  ];
}

List<String> practisedDhikrTrendIds(List<DhikrContextCapture> captures) {
  return [
    for (final capture in captures)
      if (capture.response == DhikrContextResponse.practised)
        capture.activityId,
  ];
}

String compactTrendRecordedLine({
  required int hits,
  required int denom,
  required double? percent,
}) {
  if (percent == null) {
    return 'Recorded: no answered records (unavailable — not 0%)';
  }
  return 'Recorded: $hits of $denom answered days (${percent.round()}%)';
}

/// Short display wording for pickers and the 30-day trend popup.
///
/// Relative bands stay distinct (`>20`, `15–20`, `3–5`). The row name is
/// dropped when it is already the surrounding field, so the list does not
/// repeat “Engagement (Engagement)”.
String compactChoiceLabel(
  String optionLabel, {
  String? activityLabel,
  bool stripCatalogRowName = false,
  String? optionId,
}) {
  final activity = activityLabel?.trim() ?? '';
  final fromId = _observationShort(optionId);
  var text = fromId ?? optionLabel.trim();
  if (fromId == null) {
    final split = _splitChoiceSuffix(text);
    if (split != null) {
      final head = split.$1.trim();
      final dropTail = stripCatalogRowName || _looksLikeDurationChoice(head);
      if (dropTail) text = head;
    }
    text = _compactRelativeTime(text);
    text = _phraseShort(text);
    text = _stripLongParenthetical(text);
    if (text == 'I did not notice this today') text = 'Did not notice';
  }
  if (activity.isEmpty) return text;
  if (_sameChoicePhrase(text, activity)) return text;
  if (text.toLowerCase().contains(activity.toLowerCase())) return text;
  if (_looksLikeDurationChoice(text)) return text;
  return '$text ($activity)';
}

(String, String)? _splitChoiceSuffix(String label) {
  for (final sep in [' — ', ' – ', ' - ']) {
    final at = label.lastIndexOf(sep);
    if (at <= 0) continue;
    return (label.substring(0, at), label.substring(at + sep.length));
  }
  return null;
}

bool _sameChoicePhrase(String a, String b) {
  return a.trim().toLowerCase() == b.trim().toLowerCase();
}

bool _looksLikeDurationChoice(String text) {
  final lower = text.toLowerCase();
  return lower.contains('minute') ||
      lower.contains(' mins') ||
      RegExp(r'[<>]\s*\d').hasMatch(text) ||
      RegExp(r'\d+\s*[–-]\s*\d+').hasMatch(text);
}

String _stripLongParenthetical(String text) {
  return text.replaceAllMapped(RegExp(r'\s*\(([^)]*)\)'), (match) {
    final inner = match[1] ?? '';
    final drop =
        inner.length > 18 ||
        inner.startsWith('I ') ||
        inner.startsWith('I’') ||
        inner.startsWith("I'");
    return drop ? '' : match[0]!;
  }).trim();
}

String _phraseShort(String text) {
  return switch (text) {
    'Prayed on time in congregation' => 'On time in congregation',
    'Prayed in small congregation' => 'Small congregation',
    'Prayed alone on time' => 'Alone on time',
    'Prayed late (alone)' => 'Late (alone)',
    'Missed then made up later' => 'Missed, made up later',
    'Prayed early/mid and late at night' => 'Early/mid and late night',
    'Prayed later part of night' => 'Later part of night',
    'Prayed early/mid night' => 'Early/mid night',
    'Prayed following Fajr' => 'Following Fajr',
    'Prayed later in the morning' => 'Later morning',
    'Prayed after a slip I noticed' => 'After a noticed slip',
    'Prayed two rak‘ahs' => 'Two rak‘ahs',
    _ => text,
  };
}

String? _observationShort(String? id) {
  if (id == null || id.isEmpty) return null;
  const shared = {
    'practised': 'Did this',
    'engaged': 'Did this',
    'acted': 'Did this',
    'cared': 'Did this',
    'struggled': 'Tried, incomplete',
    'partial_effort': 'Tried, incomplete',
    'progress': 'Tried, incomplete',
    'lapse_recognised': 'Lapse recognised',
    'neglect_recognised': 'Lapse recognised',
    'gap_recognised': 'Lapse recognised',
    'corrected': 'Corrected after',
    'corrective_action': 'Corrected after',
    'no_situation': 'No situation today',
    'prefer_not': 'Prefer not to record',
    'difficulty_recognised': 'Difficulty recognised',
    'constrained': 'Constrained',
  };
  final direct = shared[id];
  if (direct != null) return direct;
  final health = healthKindFor(id);
  if (health != null) {
    return switch (health) {
      HealthResponseKind.cared => 'Did this',
      HealthResponseKind.partial => 'Tried, incomplete',
      HealthResponseKind.difficulty => 'Difficulty recognised',
      HealthResponseKind.lapse => 'Lapse recognised',
      HealthResponseKind.corrected => 'Corrected after',
      HealthResponseKind.constrained => 'Constrained',
      HealthResponseKind.noSituation => 'No situation today',
      HealthResponseKind.preferNot => 'Prefer not to record',
      HealthResponseKind.unanswered => null,
    };
  }
  final wealth = wealthKindFor(id);
  if (wealth != null) {
    return switch (wealth) {
      WealthResponseKind.cared => 'Did this',
      WealthResponseKind.partial => 'Tried, incomplete',
      WealthResponseKind.difficulty => 'Difficulty recognised',
      WealthResponseKind.corrected => 'Corrected after',
      WealthResponseKind.noSituation => 'No situation today',
      WealthResponseKind.preferNot => 'Prefer not to record',
      WealthResponseKind.unanswered => null,
    };
  }
  final ummah = ummahKindFor(id);
  if (ummah != null) {
    return switch (ummah) {
      UmmahResponseKind.cared => 'Did this',
      UmmahResponseKind.partial => 'Tried, incomplete',
      UmmahResponseKind.difficulty => 'Difficulty recognised',
      UmmahResponseKind.corrected => 'Corrected after',
      UmmahResponseKind.noSituation => 'No situation today',
      UmmahResponseKind.preferNot => 'Prefer not to record',
      UmmahResponseKind.unanswered => null,
    };
  }
  final charity = charityKindFor(id);
  if (charity != null) {
    return switch (charity) {
      CharityResponseKind.cared => 'Did this',
      CharityResponseKind.partial => 'Tried, incomplete',
      CharityResponseKind.difficulty => 'Difficulty recognised',
      CharityResponseKind.noSituation => 'No situation today',
      CharityResponseKind.preferNot => 'Prefer not to record',
      CharityResponseKind.unanswered => null,
    };
  }
  return null;
}

String _compactRelativeTime(String text) {
  var next = text.replaceAllMapped(
    RegExp(r'\bmore than (\d+)\s+minutes?\b', caseSensitive: false),
    (match) => '>${match[1]} mins',
  );
  next = next.replaceAllMapped(
    RegExp(r'\bless than (\d+)\s+minutes?\b', caseSensitive: false),
    (match) => '<${match[1]} mins',
  );
  next = next.replaceAllMapped(
    RegExp(r'\b(\d+)\s*[–—-]\s*(\d+)\s+minutes?\b', caseSensitive: false),
    (match) => '${match[1]}–${match[2]} mins',
  );
  next = next.replaceAllMapped(
    RegExp(r'\b(\d+)\s+minutes?\b', caseSensitive: false),
    (match) => '${match[1]} mins',
  );
  return next;
}
