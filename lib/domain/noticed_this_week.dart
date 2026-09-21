import 'daily_check_in.dart';
import 'monitor_domain.dart';
import 'personal_mix.dart';
import 'personalisation_resolver.dart';
import 'quran.dart';

class NoticedLine {
  const NoticedLine({
    required this.label,
    required this.engagementDays,
    required this.engagementByDay,
  });

  final String label;
  final int engagementDays;
  final List<bool> engagementByDay;

  String get sentence =>
      '$label on $engagementDays day${engagementDays == 1 ? '' : 's'}';
}

List<NoticedLine> noticedThisWeek({
  required List<DailyCheckIn> records,
  required List<String> weekKeys,
  Set<MonitorDomain>? visibleDomains,
  PersonalMix mix = PersonalMix.sameAsDomains,
}) {
  final visible =
      visibleDomains ?? Set<MonitorDomain>.from(MonitorDomain.values);
  final mixKeys = PersonalisationResolver(
    visibleDomains: visible,
    mix: mix,
  ).effectiveRowIds;
  final index = {for (final record in records) record.dateKey: record};
  final lines = <NoticedLine>[];

  void add(String label, TernaryOutcome Function(DailyCheckIn?) read) {
    final days = [
      for (final key in weekKeys) read(index[key]) == TernaryOutcome.positive,
    ];
    final count = days.where((day) => day).length;
    if (count > 0) {
      lines.add(
        NoticedLine(label: label, engagementDays: count, engagementByDay: days),
      );
    }
  }

  if (mixKeys.contains('quran.reflection')) {
    add(
      'Qur’anic Reflection',
      (record) =>
          record?.quranOutcome(QuranDimension.reflection) ??
          TernaryOutcome.unanswered,
    );
  }
  for (final row in homeTraceRowsForVisible(visible)) {
    if (!mixKeys.contains(row.storageKey)) continue;
    add(
      row.label,
      (record) =>
          record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered,
    );
  }
  lines.sort((a, b) => b.engagementDays.compareTo(a.engagementDays));
  return lines.take(8).toList();
}
