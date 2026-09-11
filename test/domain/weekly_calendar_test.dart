import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/weekly_calendar.dart';

void main() {
  test('dateCellKind follows the local calendar day', () {
    final now = DateTime(2026, 9, 4, 21, 15);
    expect(dateCellKind('2026-09-03', now), DateCellKind.past);
    expect(dateCellKind('2026-09-04', now), DateCellKind.today);
    expect(dateCellKind('2026-09-05', now), DateCellKind.future);
  });

  test('Monday-first week has seven weekday rows and week columns', () {
    final keys = periodDateKeys(30, now: DateTime(2026, 9, 3));
    final layout = weeklyCalendarLayout(
      periodKeys: keys,
      firstDayOfWeekIndex: DateTime.monday % 7,
    );
    expect(layout.keysByRowCol, hasLength(kCalendarWeekdayCount));
    expect(layout.weekCount, inInclusiveRange(5, 6));
    expect(layout.rowWeekdays.first, DateTime.monday);
    expect(layout.rowWeekdays.last, DateTime.sunday);

    var inPeriod = 0;
    var padding = 0;
    for (final row in layout.keysByRowCol) {
      expect(row, hasLength(layout.weekCount));
      for (final key in row) {
        if (key == null) {
          padding++;
        } else {
          inPeriod++;
          expect(keys, contains(key));
        }
      }
    }
    expect(inPeriod, 30);
    expect(padding, greaterThan(0));
  });

  test('Saturday-first week starts on Saturday', () {
    final start = startOfWeek(DateTime(2026, 9, 3), firstDayOfWeekIndex: 6);
    expect(start.weekday, DateTime.saturday);
    expect(dateKey(start), '2026-08-29');
  });

  test('weekDateKeys follows the week start', () {
    final start = startOfWeek(DateTime(2026, 9, 3), firstDayOfWeekIndex: 1);
    expect(weekDateKeys(start), [
      '2026-08-31',
      '2026-09-01',
      '2026-09-02',
      '2026-09-03',
      '2026-09-04',
      '2026-09-05',
      '2026-09-06',
    ]);
  });

  test('Sunday-first week starts on Sunday', () {
    final start = startOfWeek(DateTime(2026, 9, 3), firstDayOfWeekIndex: 0);
    expect(start.weekday, DateTime.sunday);
    expect(dateKey(start), '2026-08-30');
  });

  test('padding days are not treated as period keys', () {
    final layout = weeklyCalendarLayout(
      periodKeys: const ['2026-08-05'],
      firstDayOfWeekIndex: 1,
    );
    expect(layout.keyAt(row: 2, week: 0), '2026-08-05');
    expect(layout.keyAt(row: 0, week: 0), isNull);
  });

  test('90-day view is one calendar window', () {
    final keys = periodDateKeys(90, now: DateTime(2026, 9, 3));
    expect(progressCalendarChunks(keys, periodDays: 90), [keys]);
    expect(progressCalendarChunkLabels(90), isEmpty);
    expect(progressCalendarChunks(keys.take(30).toList(), periodDays: 30), [
      keys.take(30).toList(),
    ]);
    expect(
      shiftedPeriodDateKeys(90, now: DateTime(2026, 9, 3), periodsBack: 0),
      keys,
    );
    expect(
      shiftedPeriodDateKeys(90, now: DateTime(2026, 9, 3), periodsBack: 1).last,
      dateKey(DateTime(2026, 9, 3).subtract(const Duration(days: 90))),
    );
  });

  test('monthBandIndex alternates by calendar month from period start', () {
    expect(monthBandIndex('2026-06-06', '2026-06-06'), 0);
    expect(monthBandIndex('2026-07-01', '2026-06-06'), 1);
    expect(monthBandIndex('2026-08-15', '2026-06-06'), 0);
  });

  test('weekStartMonthSpans groups consecutive week-start months', () {
    final spans = weekStartMonthSpans([
      DateTime(2026, 5, 31),
      DateTime(2026, 6, 7),
      DateTime(2026, 6, 14),
      DateTime(2026, 7, 5),
    ]);
    expect(spans, hasLength(3));
    expect(spans[0].label, 'May');
    expect(spans[0].span, 1);
    expect(spans[1].label, 'Jun');
    expect(spans[1].span, 2);
    expect(spans[2].label, 'Jul');
    expect(spans[2].span, 1);
  });

  test('weekRangeLabel uses Islamic month names when asked', () {
    final label = weekRangeLabel(
      DateTime(2026, 8, 31),
      calendar: DisplayCalendar.islamic,
    );
    expect(label.contains('Aug'), isFalse);
    expect(label.contains('Sep'), isFalse);
    expect(label.contains('–'), isTrue);
  });

  test('dayMonthYear uses day month year without padding', () {
    expect(dayMonthYear(DateTime(2026, 8, 31)), '31 Aug 2026');
  });
}
