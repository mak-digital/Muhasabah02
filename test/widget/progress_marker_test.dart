import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/app/dimensions.dart';
import 'package:muhasabah02/presentation/shared/progress_calendar.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

void main() {
  Widget harness(Widget child, {DateTime? now}) {
    return ProviderScope(
      overrides: [if (now != null) nowProvider.overrideWithValue(now)],
      child: MaterialApp(
        locale: const Locale('en', 'US'),
        home: Scaffold(
          body: SingleChildScrollView(child: Center(child: child)),
        ),
      ),
    );
  }

  testWidgets(
    'recorded activity, recorded not done, and unanswered share size',
    (tester) async {
      const activity = Key('marker-activity');
      const notDone = Key('marker-not-done');
      const unanswered = Key('marker-unanswered');

      await tester.pumpWidget(
        harness(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RecordedStateMarker(
                key: activity,
                color: Colors.teal,
                kind: MarkerKind.filled,
                semanticLabel: 'recorded activity',
              ),
              RecordedStateMarker(
                key: notDone,
                color: Colors.teal,
                kind: MarkerKind.outlined,
                symbol: Icons.remove,
                semanticLabel: 'recorded as not done',
              ),
              RecordedStateMarker(
                key: unanswered,
                color: Colors.teal,
                kind: MarkerKind.unanswered,
                semanticLabel: 'unanswered',
              ),
            ],
          ),
        ),
      );

      const expected = Size(
        AppDimensions.progressMarker,
        AppDimensions.progressMarker,
      );
      expect(ProgressMarker.size, 14);
      expect(AppDimensions.progressMarker, ProgressMarker.size);
      expect(tester.getSize(find.byKey(activity)), expected);
      expect(tester.getSize(find.byKey(notDone)), expected);
      expect(tester.getSize(find.byKey(unanswered)), expected);
    },
  );

  testWidgets('late outline and missed slash share the 14px footprint', (
    tester,
  ) async {
    const late = Key('marker-late');
    const missed = Key('marker-missed');
    await tester.pumpWidget(
      harness(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RecordedStateMarker(
              key: late,
              color: Colors.teal,
              kind: MarkerKind.outlined,
              semanticLabel: 'late',
            ),
            RecordedStateMarker(
              key: missed,
              color: Color(0xFF8A6A62),
              kind: MarkerKind.missed,
              semanticLabel: 'missed',
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(late)),
      tester.getSize(find.byKey(missed)),
    );
    expect(
      tester.getSize(find.byKey(missed)),
      const Size(AppDimensions.progressMarker, AppDimensions.progressMarker),
    );
  });

  testWidgets('calendar rows are weekdays and columns are weeks', (
    tester,
  ) async {
    // Monday 3 Aug 2026 through Sunday 6 Sep 2026 covers a 5-week Monday grid
    // for a 30-day window starting Wednesday 5 Aug 2026.
    final keys = periodDateKeys(30, now: DateTime(2026, 9, 3));
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 420,
          child: ProgressCalendarGrid(
            dateKeys: keys,
            cellBuilder: (context, key) {
              final kind = switch (key) {
                '2026-08-10' => MarkerKind.filled,
                '2026-08-11' => MarkerKind.outlined,
                _ => MarkerKind.unanswered,
              };
              return RecordedStateMarker(
                key: Key('day-$key'),
                color: Colors.indigo,
                kind: kind,
                symbol: kind == MarkerKind.outlined ? Icons.remove : null,
                semanticLabel: switch (kind) {
                  MarkerKind.filled =>
                    '$key ${weekdayNameForDate(key)} recorded activity',
                  MarkerKind.outlined =>
                    '$key ${weekdayNameForDate(key)} recorded as not done',
                  _ => '$key ${weekdayNameForDate(key)} unanswered',
                },
              );
            },
          ),
        ),
      ),
    );

    const mondayA = Key('day-2026-08-10');
    const mondayB = Key('day-2026-08-17');
    const tuesdayA = Key('day-2026-08-11');

    expect(
      tester.getSize(find.byKey(mondayA)).width,
      AppDimensions.progressMarker,
    );
    expect(
      tester.getSize(find.byKey(mondayA)),
      tester.getSize(find.byKey(tuesdayA)),
    );
    expect(
      tester.getSize(find.byKey(mondayA)),
      tester.getSize(find.byKey(mondayB)),
    );

    expect(
      tester.getTopLeft(find.byKey(mondayA)).dy,
      tester.getTopLeft(find.byKey(mondayB)).dy,
    );
    expect(
      tester.getTopLeft(find.byKey(mondayA)).dx,
      tester.getTopLeft(find.byKey(tuesdayA)).dx,
    );

    expect(find.bySemanticsLabel(RegExp('Weekly calendar')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('recorded activity')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('recorded as not done')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('unanswered')), findsWidgets);
    expect(find.bySemanticsLabel('Outside this period'), findsNothing);
  });

  testWidgets('90-day calendar is one full-width grid with month labels', (
    tester,
  ) async {
    final now = DateTime(2026, 9, 3);
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 420,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 90,
            family: Colors.teal,
            cellBuilder: (context, key) => RecordedStateMarker(
              key: Key('cell-$key'),
              color: Colors.teal,
              kind: MarkerKind.unanswered,
              semanticLabel: '$key unanswered',
            ),
          ),
        ),
        now: now,
      ),
    );

    expect(find.text('Earlier 30'), findsNothing);
    expect(find.text('Middle 30'), findsNothing);
    expect(find.text('Recent 30'), findsNothing);
    expect(find.byKey(const Key('calendar-chunk-0')), findsOneWidget);
    expect(find.byKey(const Key('calendar-chunk-1')), findsNothing);
    expect(find.text('Jun'), findsWidgets);
    expect(find.text('Jul'), findsWidgets);
    expect(find.text('Aug'), findsWidgets);
    expect(find.text('(for 6 Jun 2026 – 3 Sep 2026)'), findsOneWidget);
    expect(find.byKey(const Key('calendar-today-2026-09-03')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('calendar-today-2026-09-03'))),
      const Size(AppDimensions.todayMarkHalo, AppDimensions.todayMarkHalo),
    );
    expect(AppDimensions.todayMarkHalo, AppDimensions.progressMarker + 4);
    expect(
      tester.getCenter(find.byKey(const Key('calendar-today-2026-09-03'))),
      tester.getCenter(find.byKey(const Key('cell-2026-09-03'))),
    );

    await tester.tap(find.byKey(const Key('calendar-prev-Fajr')));
    await tester.pumpAndSettle();
    expect(find.text('(for 6 Jun 2026 – 3 Sep 2026)'), findsNothing);
    expect(find.byKey(const Key('calendar-today-2026-09-03')), findsNothing);

    final next = tester.widget<IconButton>(
      find.byKey(const Key('calendar-next-Fajr')),
    );
    expect(next.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('calendar-next-Fajr')));
    await tester.pumpAndSettle();
    expect(find.text('(for 6 Jun 2026 – 3 Sep 2026)'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('calendar-next-Fajr')))
          .onPressed,
      isNull,
    );
  });
}
