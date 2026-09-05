import 'daily_check_in.dart';
import 'date_key.dart';
import 'home_traces.dart';
import 'quran.dart';

enum BaselineSource { days30, days90, snapshot, manual }

extension BaselineSourceX on BaselineSource {
  String get label => switch (this) {
    BaselineSource.days30 => 'Last 30 days',
    BaselineSource.days90 => 'Last 90 days',
    BaselineSource.snapshot => 'Current snapshot',
    BaselineSource.manual => 'Manual baseline',
  };
}

class PatternCount {
  const PatternCount({
    required this.engagementDays,
    required this.notDoneDays,
    required this.unansweredDays,
  });

  final int engagementDays;
  final int notDoneDays;
  final int unansweredDays;

  Map<String, int> toJson() => {
    'engagementDays': engagementDays,
    'notDoneDays': notDoneDays,
    'unansweredDays': unansweredDays,
  };

  static PatternCount fromJson(Object? json) {
    if (json is! Map) {
      return const PatternCount(
        engagementDays: 0,
        notDoneDays: 0,
        unansweredDays: 0,
      );
    }
    return PatternCount(
      engagementDays: (json['engagementDays'] as num?)?.toInt() ?? 0,
      notDoneDays: (json['notDoneDays'] as num?)?.toInt() ?? 0,
      unansweredDays: (json['unansweredDays'] as num?)?.toInt() ?? 0,
    );
  }
}

class PersonalBaseline {
  const PersonalBaseline({
    required this.id,
    required this.createdAt,
    required this.source,
    required this.windowStart,
    required this.windowEnd,
    required this.counts,
    this.manualNote,
  });

  final String id;
  final DateTime createdAt;
  final BaselineSource source;
  final String windowStart;
  final String windowEnd;
  final Map<String, PatternCount> counts;
  final String? manualNote;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'source': source.name,
    'windowStart': windowStart,
    'windowEnd': windowEnd,
    'counts': {
      for (final entry in counts.entries) entry.key: entry.value.toJson(),
    },
    if (manualNote != null && manualNote!.trim().isNotEmpty)
      'manualNote': manualNote,
  };

  static PersonalBaseline? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'] as String?;
    final created = DateTime.tryParse('${json['createdAt']}');
    if (id == null || created == null) return null;
    final source = BaselineSource.values.firstWhere(
      (item) => item.name == json['source'],
      orElse: () => BaselineSource.snapshot,
    );
    final rawCounts = json['counts'];
    final counts = <String, PatternCount>{};
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        counts['${entry.key}'] = PatternCount.fromJson(entry.value);
      }
    }
    return PersonalBaseline(
      id: id,
      createdAt: created,
      source: source,
      windowStart: '${json['windowStart'] ?? ''}',
      windowEnd: '${json['windowEnd'] ?? ''}',
      counts: counts,
      manualNote: json['manualNote'] as String?,
    );
  }
}

List<String> _keysForSource(BaselineSource source, DateTime now) {
  return switch (source) {
    BaselineSource.days30 => periodDateKeys(30, now: now),
    BaselineSource.days90 => periodDateKeys(90, now: now),
    BaselineSource.snapshot => periodDateKeys(7, now: now),
    BaselineSource.manual => const [],
  };
}

PersonalBaseline buildBaseline({
  required String id,
  required DateTime now,
  required BaselineSource source,
  required List<DailyCheckIn> records,
  String? manualNote,
}) {
  final keys = _keysForSource(source, now);
  final start = keys.isEmpty ? dateKey(now) : keys.first;
  final end = keys.isEmpty ? dateKey(now) : keys.last;
  final index = {for (final record in records) record.dateKey: record};
  final counts = <String, PatternCount>{};

  void tally(String label, TernaryOutcome Function(DailyCheckIn?) outcomeOf) {
    var engagement = 0;
    var notDone = 0;
    var unanswered = 0;
    for (final key in keys) {
      final outcome = outcomeOf(index[key]);
      switch (outcome) {
        case TernaryOutcome.positive:
          engagement++;
        case TernaryOutcome.negative:
          notDone++;
        case TernaryOutcome.unanswered:
          unanswered++;
      }
    }
    counts[label] = PatternCount(
      engagementDays: engagement,
      notDoneDays: notDone,
      unansweredDays: unanswered,
    );
  }

  if (source != BaselineSource.manual) {
    tally('Qur’anic Reflection', (record) {
      return record?.quranOutcome(QuranDimension.reflection) ??
          TernaryOutcome.unanswered;
    });
    for (final row in allHomeTraceRows) {
      tally(row.label, (record) {
        return record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
      });
    }
  }

  return PersonalBaseline(
    id: id,
    createdAt: now,
    source: source,
    windowStart: start,
    windowEnd: end,
    counts: counts,
    manualNote: manualNote,
  );
}
