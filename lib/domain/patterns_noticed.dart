import 'daily_check_in.dart';
import 'date_key.dart';
import 'monitor_domain.dart';
import 'personal_mix.dart';
import 'personalisation_resolver.dart';
import 'quran.dart';

enum PatternKind { weekdayPeak, weekend, multiWeek }

class NoticedPattern {
  const NoticedPattern({
    required this.sentence,
    required this.dateKeys,
    required this.subjectLabel,
    required this.kind,
    required this.highlightedWeekdays,
    this.domain,
  });

  final String sentence;
  final List<String> dateKeys;
  final String subjectLabel;
  final PatternKind kind;
  final Set<int> highlightedWeekdays;
  final MonitorDomain? domain;
}

String _weekdayName(int weekday) {
  return const [
    'Mondays',
    'Tuesdays',
    'Wednesdays',
    'Thursdays',
    'Fridays',
    'Saturdays',
    'Sundays',
  ][weekday - 1];
}

List<NoticedPattern> noticedPatterns({
  required List<DailyCheckIn> records,
  required DateTime now,
  Set<MonitorDomain>? visibleDomains,
  PersonalMix mix = PersonalMix.sameAsDomains,
}) {
  final visible =
      visibleDomains ?? Set<MonitorDomain>.from(MonitorDomain.values);
  final mixKeys = PersonalisationResolver(
    visibleDomains: visible,
    mix: mix,
  ).effectiveRowIds;
  final periodKeys = periodDateKeys(90, now: now);
  final index = {for (final record in records) record.dateKey: record};
  final patterns = <NoticedPattern>[];

  void consider(
    String label,
    MonitorDomain domain,
    TernaryOutcome Function(DailyCheckIn?) read,
  ) {
    final byWeekday = List<int>.filled(8, 0);
    final dates = <String>[];
    final weeks = <String>{};
    for (final key in periodKeys) {
      if (read(index[key]) != TernaryOutcome.positive) continue;
      dates.add(key);
      final date = parseDateKey(key);
      byWeekday[date.weekday]++;
      weeks.add(
        dateKey(DateTime(date.year, date.month, date.day - (date.weekday - 1))),
      );
    }
    if (dates.length >= 3) {
      var peak = 1;
      var peakCount = 0;
      var second = 0;
      for (var day = 1; day <= 7; day++) {
        if (byWeekday[day] > peakCount) {
          second = peakCount;
          peakCount = byWeekday[day];
          peak = day;
        } else if (byWeekday[day] > second) {
          second = byWeekday[day];
        }
      }
      if (peakCount >= 3 && peakCount >= second * 2 && second >= 0) {
        patterns.add(
          NoticedPattern(
            sentence:
                '$label records appear more frequently on ${_weekdayName(peak)}.',
            dateKeys: dates,
            subjectLabel: label,
            kind: PatternKind.weekdayPeak,
            highlightedWeekdays: {peak},
            domain: domain,
          ),
        );
      }
      final weekend = byWeekday[DateTime.saturday] + byWeekday[DateTime.sunday];
      final weekday = dates.length - weekend;
      if (weekend >= 3 && weekend >= weekday) {
        patterns.add(
          NoticedPattern(
            sentence: '$label records appear mostly on weekends.',
            dateKeys: dates,
            subjectLabel: label,
            kind: PatternKind.weekend,
            highlightedWeekdays: {DateTime.saturday, DateTime.sunday},
            domain: domain,
          ),
        );
      }
    }
    if (weeks.length >= 3) {
      patterns.add(
        NoticedPattern(
          sentence: '$label appears across multiple weeks.',
          dateKeys: dates,
          subjectLabel: label,
          kind: PatternKind.multiWeek,
          highlightedWeekdays: const {},
          domain: domain,
        ),
      );
    }
  }

  if (mixKeys.contains('quran.meaning')) {
    consider(
      'Understanding & reflection',
      MonitorDomain.quran,
      (record) =>
          record?.quranOutcome(QuranDimension.meaning) ??
          TernaryOutcome.unanswered,
    );
  }
  for (final row in homeTraceRowsForVisible(visible)) {
    if (!mixKeys.contains(row.storageKey)) continue;
    consider(
      row.label,
      monitorDomainForStorageKey(row.storageKey) ?? MonitorDomain.quran,
      (record) =>
          record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered,
    );
  }
  return patterns.take(6).toList();
}
