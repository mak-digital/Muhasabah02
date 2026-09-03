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

int daysInclusiveSpan(String startKey, String endKey) {
  final start = parseDateKey(startKey);
  final end = parseDateKey(endKey);
  return end.difference(start).inDays.abs() + 1;
}

List<String> periodDateKeys(int days, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  return List<String>.generate(days, (i) {
    return dateKey(today.subtract(Duration(days: days - 1 - i)));
  });
}

List<String> priorPeriodDateKeys(int days, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final end = today.subtract(Duration(days: days));
  return List<String>.generate(days, (i) {
    return dateKey(end.subtract(Duration(days: days - 1 - i)));
  });
}
