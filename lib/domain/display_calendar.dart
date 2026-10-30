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

String formatGregorianAndHijri(DateTime date) {
  return '${formatDayMonthYear(date, DisplayCalendar.gregorian)} · ${formatDayMonthYear(date, DisplayCalendar.islamic)}';
}

String hijriMonthName(int month) {
  final index = month.clamp(1, 12) - 1;
  return _hijriMonths[index];
}

/// Civil (tabular) Hijri → Gregorian. Sighting may differ by a day.
DateTime gregorianFromHijri(int year, int month, int day) {
  final safeMonth = month.clamp(1, 12);
  final first = _gregorianFromHijriExact(year, safeMonth, 1);
  final length = hijriMonthLength(year, safeMonth);
  final safeDay = day.clamp(1, length);
  if (safeDay == 1) return first;
  return DateTime(first.year, first.month, first.day + (safeDay - 1));
}

int hijriMonthLength(int year, int month) {
  final safeMonth = month.clamp(1, 12);
  final start = _gregorianFromHijriExact(year, safeMonth, 1);
  final next = safeMonth == 12
      ? _gregorianFromHijriExact(year + 1, 1, 1)
      : _gregorianFromHijriExact(year, safeMonth + 1, 1);
  final days = next.difference(start).inDays;
  if (days < 29) return 29;
  if (days > 30) return 30;
  return days;
}

DateTime _gregorianFromHijriExact(int year, int month, int day) {
  var lo = 1948084;
  var hi = 2800000;
  final target = year * 400 + month * 32 + day;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    final parts = _jdToIslamic(mid);
    final ord = parts.year * 400 + parts.month * 32 + parts.day;
    if (ord < target) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return _jdToGregorian(lo);
}

DateTime _jdToGregorian(int jd) {
  var l = jd + 68569;
  final n = (4 * l) ~/ 146097;
  l = l - (146097 * n + 3) ~/ 4;
  final i = (4000 * (l + 1)) ~/ 1461001;
  l = l - (1461 * i) ~/ 4 + 31;
  final j = (80 * l) ~/ 2447;
  final day = l - (2447 * j) ~/ 80;
  l = j ~/ 11;
  final month = j + 2 - (12 * l);
  final year = 100 * (n - 49) + i + l;
  return DateTime(year, month, day);
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

/// Civil (tabular) Ramadan is Hijri month 9. Sighting may differ by a day.
/// [offsetDays] of -1 or +1 is a local moon-sighting correction, not a ruling.
bool isCivilRamadan(DateTime date, {int offsetDays = 0}) {
  var day = DateTime(date.year, date.month, date.day);
  if (offsetDays != 0) day = day.add(Duration(days: offsetDays));
  return hijriParts(day).month == 9;
}

bool isCivilRamadanKey(String key, {int offsetDays = 0}) =>
    isCivilRamadan(parseDateKey(key), offsetDays: offsetDays);

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
