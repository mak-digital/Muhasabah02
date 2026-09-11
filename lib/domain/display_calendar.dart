import 'date_key.dart';

enum DisplayCalendar { gregorian, islamic }

class CivilDateParts {
  const CivilDateParts({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

extension DisplayCalendarX on DisplayCalendar {
  String get id => name;

  String get label => switch (this) {
    DisplayCalendar.gregorian => 'Gregorian',
    DisplayCalendar.islamic => 'Islamic (Hijri)',
  };

  static DisplayCalendar fromId(String? raw) {
    return DisplayCalendar.values.firstWhere(
      (value) => value.id == raw,
      orElse: () => DisplayCalendar.gregorian,
    );
  }
}

const _gregorianMonths = [
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

const _hijriMonths = [
  'Muharram',
  'Safar',
  'Rabi I',
  'Rabi II',
  'Jumada I',
  'Jumada II',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  "Dhul-Qa'dah",
  'Dhul-Hijjah',
];

const _hijriMonthsShort = [
  'Muh',
  'Saf',
  'RbI',
  'RbII',
  'JmI',
  'JmII',
  'Raj',
  'Sha',
  'Ram',
  'Shaw',
  'Qad',
  'Hij',
];

/// Civil (tabular) Islamic calendar. Sighting may differ by a day.
CivilDateParts hijriParts(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final jd = _gregorianToJd(local.year, local.month, local.day);
  return _jdToIslamic(jd);
}

CivilDateParts displayParts(DateTime date, DisplayCalendar calendar) {
  final local = DateTime(date.year, date.month, date.day);
  if (calendar == DisplayCalendar.gregorian) {
    return CivilDateParts(year: local.year, month: local.month, day: local.day);
  }
  return hijriParts(local);
}

String displayMonthLabel(DateTime date, DisplayCalendar calendar) {
  final parts = displayParts(date, calendar);
  if (calendar == DisplayCalendar.gregorian) {
    return _gregorianMonths[parts.month - 1];
  }
  return _hijriMonthsShort[parts.month - 1];
}

String formatDayMonth(DateTime date, DisplayCalendar calendar) {
  final parts = displayParts(date, calendar);
  final month = calendar == DisplayCalendar.gregorian
      ? _gregorianMonths[parts.month - 1]
      : _hijriMonths[parts.month - 1];
  return '${parts.day} $month';
}

String formatDayMonthYear(DateTime date, DisplayCalendar calendar) {
  final parts = displayParts(date, calendar);
  final month = calendar == DisplayCalendar.gregorian
      ? _gregorianMonths[parts.month - 1]
      : _hijriMonths[parts.month - 1];
  return '${parts.day} $month ${parts.year}';
}

String formatStoredDateKey(String key, DisplayCalendar calendar) {
  return formatDayMonthYear(parseDateKey(key), calendar);
}

/// Ayyam al-bid: 13–15 of the civil (tabular) Hijri month.
bool isLunarWhiteDay(DateTime date) {
  final day = hijriParts(date).day;
  return day == 13 || day == 14 || day == 15;
}

bool isLunarWhiteDayKey(String key) => isLunarWhiteDay(parseDateKey(key));

int _gregorianToJd(int year, int month, int day) {
  final a = ((14 - month) ~/ 12);
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      ((153 * m + 2) ~/ 5) +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

CivilDateParts _jdToIslamic(int jd) {
  final l = jd - 1948440 + 10632;
  final n = (l - 1) ~/ 10631;
  var rest = l - 10631 * n + 354;
  final j =
      ((10985 - rest) ~/ 5316) * ((50 * rest) ~/ 17719) +
      (rest ~/ 5670) * ((43 * rest) ~/ 15238);
  rest =
      rest -
      ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
      (j ~/ 16) * ((15238 * j) ~/ 43) +
      29;
  var month = (24 * rest) ~/ 709;
  var day = rest - (709 * month) ~/ 24;
  var year = 30 * n + j - 30;
  if (month < 1) {
    month = 12;
    year -= 1;
  } else if (month > 12) {
    month = 1;
    year += 1;
  }
  if (day < 1) day = 1;
  if (day > 30) day = 30;
  return CivilDateParts(year: year, month: month, day: day);
}
