import 'daily_check_in.dart';
import 'date_key.dart';
import 'home_traces.dart';
import 'quran.dart';

class NoticedPattern {
  const NoticedPattern({
    required this.sentence,
    required this.dateKeys,
    required this.subjectLabel,
  });

  final String sentence;
  final List<String> dateKeys;
  final String subjectLabel;
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
}) {
  final keys = periodDateKeys(90, now: now);
  final index = {for (final record in records) record.dateKey: record};
  final patterns = <NoticedPattern>[];

  void consider(String label, TernaryOutcome Function(DailyCheckIn?) read) {
    final byWeekday = List<int>.filled(8, 0);
    final dates = <String>[];
    final weeks = <String>{};
    for (final key in keys) {
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
        ),
      );
    }
  }

  consider(
    'Qur’anic Reflection',
    (record) =>
        record?.quranOutcome(QuranDimension.reflection) ??
        TernaryOutcome.unanswered,
  );
  for (final row in allHomeTraceRows) {
    consider(
      row.label,
      (record) =>
          record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered,
    );
  }
  return patterns.take(6).toList();
}
