import 'date_key.dart';
import 'display_calendar.dart';

const int kCalendarWeekdayCount = 7;

class WeeklyCalendarLayout {
  const WeeklyCalendarLayout({
    required this.weekCount,
    required this.weekStarts,
    required this.keysByRowCol,
    required this.rowWeekdays,
  });

  final int weekCount;
  final List<DateTime> weekStarts;
  final List<List<String?>> keysByRowCol;
  final List<int> rowWeekdays;

  String? keyAt({required int row, required int week}) {
    if (row < 0 ||
        week < 0 ||
        row >= keysByRowCol.length ||
        week >= weekCount) {
      return null;
    }
    return keysByRowCol[row][week];
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime addCalendarDays(DateTime date, int days) {
  final local = _dateOnly(date);
  return DateTime(local.year, local.month, local.day + days);
}

int _sundayBasedWeekday(DateTime date) => date.weekday % 7;

DateTime startOfWeek(DateTime date, {required int firstDayOfWeekIndex}) {
  final local = _dateOnly(date);
  final offset = (_sundayBasedWeekday(local) - firstDayOfWeekIndex + 7) % 7;
  return addCalendarDays(local, -offset);
}

int dartWeekdayForRow(int row, {required int firstDayOfWeekIndex}) {
  final sundayBased = (firstDayOfWeekIndex + row) % 7;
  return sundayBased == 0 ? DateTime.sunday : sundayBased;
}

WeeklyCalendarLayout weeklyCalendarLayout({
  required List<String> periodKeys,
  required int firstDayOfWeekIndex,
}) {
  final firstIndex = firstDayOfWeekIndex.clamp(0, 6);
  if (periodKeys.isEmpty) {
    return WeeklyCalendarLayout(
      weekCount: 0,
      weekStarts: const [],
      keysByRowCol: List.generate(kCalendarWeekdayCount, (_) => const []),
      rowWeekdays: [
        for (var row = 0; row < kCalendarWeekdayCount; row++)
          dartWeekdayForRow(row, firstDayOfWeekIndex: firstIndex),
      ],
    );
  }

  final inPeriod = periodKeys.toSet();
  final first = parseDateKey(periodKeys.first);
  final last = parseDateKey(periodKeys.last);
  final gridStart = startOfWeek(first, firstDayOfWeekIndex: firstIndex);
  final lastWeekStart = startOfWeek(last, firstDayOfWeekIndex: firstIndex);
  final weekCount = lastWeekStart.difference(gridStart).inDays ~/ 7 + 1;
  final weekStarts = [
    for (var week = 0; week < weekCount; week++)
      addCalendarDays(gridStart, week * 7),
  ];
  final keysByRowCol = <List<String?>>[];
  for (var row = 0; row < kCalendarWeekdayCount; row++) {
    final cols = <String?>[];
    for (var week = 0; week < weekCount; week++) {
      final date = addCalendarDays(gridStart, week * 7 + row);
      final key = dateKey(date);
      cols.add(inPeriod.contains(key) ? key : null);
    }
    keysByRowCol.add(cols);
  }
  return WeeklyCalendarLayout(
    weekCount: weekCount,
    weekStarts: weekStarts,
    keysByRowCol: keysByRowCol,
    rowWeekdays: [
      for (var row = 0; row < kCalendarWeekdayCount; row++)
        dartWeekdayForRow(row, firstDayOfWeekIndex: firstIndex),
    ],
  );
}

List<List<String>> progressCalendarChunks(
  List<String> keys, {
  required int periodDays,
}) {
  if (keys.isEmpty || periodDays <= 0) return const [];
  return [keys];
}

List<String> progressCalendarChunkLabels(int periodDays) {
  if (periodDays <= 0) return const [];
  return const [];
}

int monthBandIndex(
  String dateKey,
  String periodStartKey, {
  DisplayCalendar calendar = DisplayCalendar.gregorian,
}) {
  final date = displayParts(parseDateKey(dateKey), calendar);
  final start = displayParts(parseDateKey(periodStartKey), calendar);
  final months = (date.year - start.year) * 12 + (date.month - start.month);
  return months.abs() % 2;
}

class WeekStartMonthSpan {
  const WeekStartMonthSpan({required this.label, required this.span});

  final String label;
  final int span;
}

List<WeekStartMonthSpan> weekStartMonthSpans(
  List<DateTime> weekStarts, {
  DisplayCalendar calendar = DisplayCalendar.gregorian,
}) {
  final spans = <WeekStartMonthSpan>[];
  for (final start in weekStarts) {
    final label = displayMonthLabel(start, calendar);
    if (spans.isNotEmpty && spans.last.label == label) {
      spans[spans.length - 1] = WeekStartMonthSpan(
        label: label,
        span: spans.last.span + 1,
      );
    } else {
      spans.add(WeekStartMonthSpan(label: label, span: 1));
    }
  }
  return spans;
}

String weekRangeLabel(
  DateTime weekStart, {
  DisplayCalendar calendar = DisplayCalendar.gregorian,
}) {
  final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final end = DateTime(start.year, start.month, start.day + 6);
  return '${formatDayMonth(start, calendar)} – ${formatDayMonth(end, calendar)}';
}

DateTime weekStartForKey(String key, {required int firstDayOfWeekIndex}) {
  return startOfWeek(
    parseDateKey(key),
    firstDayOfWeekIndex: firstDayOfWeekIndex,
  );
}

List<String> weekDateKeys(DateTime weekStart) {
  return [
    for (var day = 0; day < kCalendarWeekdayCount; day++)
      dateKey(addCalendarDays(weekStart, day)),
  ];
}
