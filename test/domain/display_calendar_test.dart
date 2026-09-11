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

  test('civil Islamic parts stay in calendar bounds', () {
    for (var i = 0; i < 400; i++) {
      final date = DateTime(2025, 1, 1).add(Duration(days: i));
      final parts = hijriParts(date);
      expect(parts.month, inInclusiveRange(1, 12), reason: '$date');
      expect(parts.day, inInclusiveRange(1, 30), reason: '$date');
      expect(parts.year, greaterThan(1400), reason: '$date');
    }
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
