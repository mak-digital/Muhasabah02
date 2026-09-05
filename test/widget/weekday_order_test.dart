import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/weekly_calendar.dart';
import 'package:muhasabah02/presentation/shared/progress_calendar.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

void main() {
  final keys = periodDateKeys(30, now: DateTime(2026, 9, 3));

  Widget harness({required FirstDayOfWeekPref pref, required Locale locale}) {
    return ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(
          MemoryAppPrefs(firstDayOfWeek: pref),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: ProgressCalendarGrid(
                dateKeys: keys,
                cellBuilder: (context, key) => RecordedStateMarker(
                  key: Key('day-$key'),
                  color: Colors.teal,
                  kind: MarkerKind.unanswered,
                  semanticLabel: key,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> expectFirstRowIsWeekday(
    WidgetTester tester, {
    required int dartWeekday,
    required String sampleKey,
  }) async {
    final layout = weeklyCalendarLayout(
      periodKeys: keys,
      firstDayOfWeekIndex: dartWeekday == DateTime.sunday ? 0 : dartWeekday % 7,
    );
    expect(layout.rowWeekdays.first, dartWeekday);
    final firstRowY = tester.getTopLeft(find.byKey(Key('day-$sampleKey'))).dy;
    for (final key in keys) {
      final date = parseDateKey(key);
      if (date.weekday != dartWeekday) continue;
      expect(
        tester.getTopLeft(find.byKey(Key('day-$key'))).dy,
        firstRowY,
        reason: '$key should sit on the first weekday row',
      );
    }
  }

  testWidgets('Monday first places Mondays on the first row', (tester) async {
    await tester.pumpWidget(
      harness(
        pref: FirstDayOfWeekPref.monday,
        locale: const Locale('en', 'US'),
      ),
    );
    await expectFirstRowIsWeekday(
      tester,
      dartWeekday: DateTime.monday,
      sampleKey: '2026-08-10',
    );
  });

  testWidgets('Sunday first places Sundays on the first row', (tester) async {
    await tester.pumpWidget(
      harness(
        pref: FirstDayOfWeekPref.sunday,
        locale: const Locale('en', 'GB'),
      ),
    );
    await expectFirstRowIsWeekday(
      tester,
      dartWeekday: DateTime.sunday,
      sampleKey: '2026-08-09',
    );
  });

  testWidgets('Saturday first places Saturdays on the first row', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        pref: FirstDayOfWeekPref.saturday,
        locale: const Locale('en', 'US'),
      ),
    );
    await expectFirstRowIsWeekday(
      tester,
      dartWeekday: DateTime.saturday,
      sampleKey: '2026-08-08',
    );
  });

  testWidgets('device locale en_US places Sundays on the first row', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        pref: FirstDayOfWeekPref.deviceLocale,
        locale: const Locale('en', 'US'),
      ),
    );
    await expectFirstRowIsWeekday(
      tester,
      dartWeekday: DateTime.sunday,
      sampleKey: '2026-08-09',
    );
  });
}
