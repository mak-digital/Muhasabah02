import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/display_calendar.dart';

void main() {
  test('default calendar is Gregorian', () {
    expect(DisplayCalendarX.fromId(null), DisplayCalendar.gregorian);
    expect(DisplayCalendar.gregorian.label, 'Gregorian');
    expect(DisplayCalendar.islamic.label, 'Islamic (Hijri)');
  });

  test('civil Islamic conversion yields a Hijri year for 2026', () {
    final parts = hijriParts(DateTime(2026, 9, 7));
    expect(parts.year, inInclusiveRange(1447, 1448));
    expect(parts.month, inInclusiveRange(1, 12));
    expect(parts.day, inInclusiveRange(1, 30));
  });

  test('Islamic format uses Hijri month names', () {
    final shown = formatDayMonthYear(
      DateTime(2026, 9, 7),
      DisplayCalendar.islamic,
    );
    expect(shown.contains('2026'), isFalse);
    expect(shown.contains('Sep'), isFalse);
    expect(RegExp(r'\d+ .+ \d{4}').hasMatch(shown), isTrue);
  });

  test('Gregorian and Hijri format names both calendars', () {
    final shown = formatGregorianAndHijri(DateTime(2026, 9, 14));
    expect(shown.contains('14 Sep 2026'), isTrue);
    expect(shown.contains(' · '), isTrue);
    expect(shown.contains('Sep'), isTrue);
    expect(RegExp(r'14 Sep 2026 · \d+ .+ \d{4}').hasMatch(shown), isTrue);
    expect(shown.contains('2026 ·'), isTrue);
  });

  test('civil Islamic parts stay in calendar bounds', () {
    for (var i = 0; i < 400; i++) {
      final date = DateTime(2025, 1, 1).add(Duration(days: i));
      final parts = hijriParts(date);
      expect(parts.month, inInclusiveRange(1, 12), reason: '$date');
      expect(parts.day, inInclusiveRange(1, 30), reason: '$date');
      expect(parts.year, greaterThan(1400), reason: '$date');
    }
  });

  test('Hijri to Gregorian round-trips civil tabular days', () {
    for (final month in [1, 6, 9, 11, 12]) {
      for (final day in [1, 8, 13, 15, 29]) {
        final gregorian = gregorianFromHijri(1447, month, day);
        final parts = hijriParts(gregorian);
        expect(parts.year, 1447, reason: 'month $month day $day');
        expect(parts.month, month, reason: 'month $month day $day');
        expect(parts.day, day, reason: 'month $month day $day');
      }
    }
    expect(hijriMonthLength(1447, 12), inInclusiveRange(29, 30));
  });

  test('lunar white days are civil Hijri 13 to 15', () {
    var found = 0;
    for (var i = 0; i < 60; i++) {
      final date = DateTime(2026, 8, 1).add(Duration(days: i));
      final white = isLunarWhiteDay(date);
      final day = hijriParts(date).day;
      expect(white, day >= 13 && day <= 15);
      if (white) found++;
    }
    expect(found, inInclusiveRange(3, 9));
  });
}
