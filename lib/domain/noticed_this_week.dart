import 'daily_check_in.dart';
import 'home_traces.dart';
import 'quran.dart';

class NoticedLine {
  const NoticedLine({required this.label, required this.engagementDays});

  final String label;
  final int engagementDays;

  String get sentence =>
      '$label on $engagementDays day${engagementDays == 1 ? '' : 's'}';
}

List<NoticedLine> noticedThisWeek({
  required List<DailyCheckIn> records,
  required List<String> weekKeys,
}) {
  final index = {for (final record in records) record.dateKey: record};
  final lines = <NoticedLine>[];

  void add(String label, TernaryOutcome Function(DailyCheckIn?) read) {
    var count = 0;
    for (final key in weekKeys) {
      if (read(index[key]) == TernaryOutcome.positive) count++;
    }
    if (count > 0) {
      lines.add(NoticedLine(label: label, engagementDays: count));
    }
  }

  add(
    'Qur’anic Reflection',
    (record) =>
        record?.quranOutcome(QuranDimension.reflection) ??
        TernaryOutcome.unanswered,
  );
  for (final row in allHomeTraceRows) {
    add(
      row.label,
      (record) =>
          record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered,
    );
  }
  lines.sort((a, b) => b.engagementDays.compareTo(a.engagementDays));
  return lines.take(8).toList();
}
