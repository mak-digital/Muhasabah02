/// Extra delay so the midnight timer fires after the local date has changed.
const Duration kLocalMidnightTimerMargin = Duration(milliseconds: 250);

/// Next local calendar midnight after [now] (device-local, not a fixed offset).
DateTime nextLocalMidnight(DateTime now) {
  final local = DateTime(now.year, now.month, now.day);
  return DateTime(local.year, local.month, local.day + 1);
}

/// Delay until [nextLocalMidnight], plus [kLocalMidnightTimerMargin].
Duration delayUntilNextLocalMidnight(DateTime now) {
  final delay =
      nextLocalMidnight(now).difference(now) + kLocalMidnightTimerMargin;
  if (delay <= Duration.zero) return kLocalMidnightTimerMargin;
  return delay;
}

String dateKey(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid date key', key);
  }
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String shiftDateKey(String key, int days) {
  final date = parseDateKey(key);
  return dateKey(DateTime(date.year, date.month, date.day + days));
}

int daysInclusiveSpan(String startKey, String endKey) {
  final start = parseDateKey(startKey);
  final end = parseDateKey(endKey);
  return end.difference(start).inDays.abs() + 1;
}

const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String dayMonthYear(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.day} ${_shortMonths[local.month - 1]} ${local.year}';
}

enum DateCellKind { past, today, future }

DateCellKind dateCellKind(String key, DateTime now) {
  final today = dateKey(now);
  if (key == today) return DateCellKind.today;
  if (key.compareTo(today) > 0) return DateCellKind.future;
  return DateCellKind.past;
}

List<String> periodDateKeys(int days, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  return List<String>.generate(days, (i) {
    return dateKey(today.subtract(Duration(days: days - 1 - i)));
  });
}

List<String> shiftedPeriodDateKeys(
  int days, {
  required DateTime now,
  required int periodsBack,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final end = today.subtract(Duration(days: periodsBack * days));
  return periodDateKeys(days, now: end);
}

List<String> priorPeriodDateKeys(int days, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final end = today.subtract(Duration(days: days));
  return List<String>.generate(days, (i) {
    return dateKey(end.subtract(Duration(days: days - 1 - i)));
  });
}
