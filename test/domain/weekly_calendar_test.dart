import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/weekly_calendar.dart';

void main() {
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

  test('90-day view splits into Earlier, Middle, and Recent 30-day blocks', () {
    final keys = periodDateKeys(90, now: DateTime(2026, 9, 3));
    final chunks = progressCalendarChunks(keys, periodDays: 90);
    expect(chunks, hasLength(3));
    expect(chunks[0], hasLength(30));
    expect(chunks[1], hasLength(30));
    expect(chunks[2], hasLength(30));
    expect(progressCalendarChunkLabels(90), [
      'Earlier 30',
      'Middle 30',
      'Recent 30',
    ]);
    expect(progressCalendarChunks(keys.take(30).toList(), periodDays: 30), [
      keys.take(30).toList(),
    ]);
  });
}
