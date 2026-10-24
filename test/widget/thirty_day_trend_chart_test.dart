import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/salah_extras.dart';
import 'package:muhasabah02/presentation/shared/progress_calendar.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';
import 'package:muhasabah02/presentation/shared/thirty_day_trend_chart.dart';

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

  testWidgets('30-day chart sits in the wash without moving the calendar', (
    tester,
  ) async {
    final now = DateTime(2026, 10, 23);
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 30,
            summaryLines: const [
              'Recorded on 10 of 30 days',
              'Activity days 9',
              'Recorded as not done 1',
            ],
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Fajr',
              catalog: ActivityCatalog.salah,
              activityColours: true,
              idForDate: (key) =>
                  key.compareTo('2026-10-23') <= 0 ? 'prayedLate' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.teal,
              kind: MarkerKind.unanswered,
              semanticLabel: '$key unanswered',
            ),
          ),
        ),
        now: now,
      ),
    );

    final grid = tester.getRect(find.byKey(const Key('calendar-chunk-0')));
    final wash = tester.getRect(
      find.byKey(const Key('progress-thirty-summary')),
    );
    expect(wash.left, greaterThan(grid.right - 1));
    expect(wash.bottom, closeTo(grid.bottom, 1));
    expect(find.text('Recorded on 10 of 30 days'), findsNothing);
    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);
    expect(find.text('C'), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp(r'Prayed late \(Fajr\)')),
      findsWidgets,
    );
  });

  testWidgets('missing periods leave the wash clear of hatch noise', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 30,
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Fajr',
              catalog: ActivityCatalog.salah,
              activityColours: true,
              idForDate: (key) =>
                  key.compareTo('2026-10-01') >= 0 ? 'prayedLate' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.teal,
              kind: MarkerKind.unanswered,
              semanticLabel: '$key unanswered',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);
    expect(find.text('C'), findsWidgets);
  });

  testWidgets('7-day calendar does not grow a trend wash', (tester) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 7,
            trend: thirtyDaySeriesOrNull(
              periodDays: 7,
              activityLabel: 'Fajr',
              catalog: ActivityCatalog.salah,
              activityColours: true,
              idForDate: (_) => 'prayedLate',
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.teal,
              kind: MarkerKind.unanswered,
              semanticLabel: '$key unanswered',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    expect(find.byKey(const Key('progress-thirty-summary')), findsNothing);
  });

  testWidgets('Jumu‘ah 30-day chart sits in the wash', (tester) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Jumu‘ah',
            periodDays: 30,
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Jumu‘ah',
              catalog: ActivityCatalog.jumuah,
              activityColours: true,
              idForDate: (key) =>
                  isFridayDateKey(key) ? 'congregationOnTime' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.teal,
              kind: MarkerKind.filled,
              semanticLabel: '$key jumuah',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    expect(find.byKey(const Key('progress-thirty-summary')), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp(r'Prayed on time in congregation \(Jumu')),
      findsWidgets,
    );
  });

  testWidgets('Tahajjud 30-day chart sits in the wash', (tester) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Tahajjud',
            periodDays: 30,
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Tahajjud',
              catalog: ActivityCatalog.tahajjud,
              activityColours: true,
              idForDate: (key) => key.compareTo('2026-10-23') <= 0
                  ? ActivityCatalog.tahajjudEarlyMid
                  : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.teal,
              kind: MarkerKind.filled,
              semanticLabel: '$key tahajjud',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    expect(find.byKey(const Key('progress-thirty-summary')), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp(r'Prayed early/mid night \(Tahajjud\)')),
      findsWidgets,
    );
  });

  testWidgets('practical relevance note sits below the chart wash', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Practical relevance',
            periodDays: 30,
            belowTitle: const Text(Copy.consciousApplicationNote),
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Practical relevance',
              catalog: ActivityCatalog.quranRelevanceDuration,
              activityColours: true,
              idForDate: (key) =>
                  key.compareTo('2026-10-23') <= 0 ? 'over20' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.teal,
              kind: MarkerKind.unanswered,
              semanticLabel: '$key unanswered',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    expect(find.text(Copy.consciousApplicationNote), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    final note = tester.getRect(find.byKey(const Key('progress-below-title')));
    final wash = tester.getRect(
      find.byKey(const Key('progress-thirty-summary')),
    );
    expect(note.top, greaterThanOrEqualTo(wash.bottom - 1));
  });

  testWidgets('tapping a bar shows recorded counts in brackets', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 30,
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Fajr',
              catalog: ActivityCatalog.salah,
              activityColours: true,
              idForDate: (key) =>
                  key.compareTo('2026-10-23') <= 0 ? 'prayedLate' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.amber,
              kind: MarkerKind.filled,
              semanticLabel: '$key prayed late',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    await tester.tap(
      find.bySemanticsLabel(RegExp(r'Prayed late \(Fajr\)')).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Recorded:'), findsOneWidget);
    expect(find.textContaining('answered days ('), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Close'), findsNothing);
    final tip = tester.getRect(find.byKey(const Key('trend-float-tip')));
    final wash = tester.getRect(
      find.byKey(const Key('progress-thirty-summary')),
    );
    const mm = 160 / 25.4;
    expect(tip.bottom, closeTo(wash.top + 10 * mm, 8));
    expect(tip.right, closeTo(wash.right + 5 * mm, 8));
  });

  testWidgets('hovering a bar shows the recorded line', (tester) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 30,
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Fajr',
              catalog: ActivityCatalog.salah,
              activityColours: true,
              idForDate: (key) =>
                  key.compareTo('2026-10-23') <= 0 ? 'prayedLate' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.amber,
              kind: MarkerKind.filled,
              semanticLabel: '$key prayed late',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    final bar = find.bySemanticsLabel(RegExp(r'Prayed late \(Fajr\)')).first;
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(bar));
    await tester.pump();
    expect(find.textContaining('Recorded:'), findsOneWidget);
    expect(find.textContaining('Prayed late (Fajr)'), findsOneWidget);
    expect(find.byKey(const Key('trend-float-tip')), findsOneWidget);
  });

  testWidgets('floating tip can be dragged and closed', (tester) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 400,
          child: ProgressCalendarSection(
            title: 'Fajr',
            periodDays: 30,
            trend: thirtyDaySeriesOrNull(
              periodDays: 30,
              activityLabel: 'Fajr',
              catalog: ActivityCatalog.salah,
              activityColours: true,
              idForDate: (key) =>
                  key.compareTo('2026-10-23') <= 0 ? 'prayedLate' : null,
            ),
            cellBuilder: (context, key) => RecordedStateMarker(
              color: Colors.amber,
              kind: MarkerKind.filled,
              semanticLabel: '$key prayed late',
            ),
          ),
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    await tester.tap(
      find.bySemanticsLabel(RegExp(r'Prayed late \(Fajr\)')).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trend-float-tip')), findsOneWidget);
    tester
        .widget<IconButton>(find.byKey(const Key('trend-tip-close')))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trend-float-tip')), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('floating tip stays with its wash when the page scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        Column(
          children: [
            const SizedBox(height: 280),
            SizedBox(
              width: 400,
              child: ProgressCalendarSection(
                title: 'Fajr',
                periodDays: 30,
                trend: thirtyDaySeriesOrNull(
                  periodDays: 30,
                  activityLabel: 'Fajr',
                  catalog: ActivityCatalog.salah,
                  activityColours: true,
                  idForDate: (key) =>
                      key.compareTo('2026-10-23') <= 0 ? 'prayedLate' : null,
                ),
                cellBuilder: (context, key) => RecordedStateMarker(
                  color: Colors.amber,
                  kind: MarkerKind.filled,
                  semanticLabel: '$key prayed late',
                ),
              ),
            ),
            const SizedBox(height: 800),
          ],
        ),
        now: DateTime(2026, 10, 23),
      ),
    );
    await tester.tap(
      find.bySemanticsLabel(RegExp(r'Prayed late \(Fajr\)')).first,
    );
    await tester.pumpAndSettle();
    final tipBefore = tester.getTopLeft(
      find.byKey(const Key('trend-float-tip')),
    );
    final washBefore = tester.getTopLeft(
      find.byKey(const Key('progress-thirty-summary')),
    );
    tester.state<ScrollableState>(find.byType(Scrollable)).position.jumpTo(120);
    await tester.pump();
    final tipAfter = tester.getTopLeft(
      find.byKey(const Key('trend-float-tip')),
    );
    final washAfter = tester.getTopLeft(
      find.byKey(const Key('progress-thirty-summary')),
    );
    expect(washAfter.dy, closeTo(washBefore.dy - 120, 2));
    expect(
      tipAfter.dy - tipBefore.dy,
      closeTo(washAfter.dy - washBefore.dy, 2),
    );
    expect(
      tipAfter.dx - tipBefore.dx,
      closeTo(washAfter.dx - washBefore.dx, 2),
    );
  });
}
