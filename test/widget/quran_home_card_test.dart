import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/dimensions.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quran_stage.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/quran_stage_mark.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 9, 3);

  Future<void> pumpHome(
    WidgetTester tester, {
    List<DailyCheckIn> days = const [],
    FirstDayOfWeekPref firstDay = FirstDayOfWeekPref.monday,
    bool salahActivityColours = false,
  }) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final checkIns = MemoryCheckInRepository();
    for (final day in days) {
      await checkIns.save(day);
    }
    await tester.pumpWidget(
      testApp(
        checkIns: checkIns,
        now: now,
        firstDayOfWeek: firstDay,
        salahActivityColours: salahActivityColours,
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.quran);
  }

  testWidgets('Monday first places Monday as the first Qur’an column', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('quran-home-applied-2026-08-31')))
          .dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('quran-home-applied-2026-09-01')))
            .dx,
      ),
    );
  });

  testWidgets('Sunday first places Sunday as the first Qur’an column', (
    tester,
  ) async {
    await pumpHome(tester, firstDay: FirstDayOfWeekPref.sunday);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('quran-home-applied-2026-08-30')))
          .dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('quran-home-applied-2026-08-31')))
            .dx,
      ),
    );
  });

  testWidgets('Qur’an Home shows journey rows and not Application Reflection', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text(Copy.quranJourney.toUpperCase()), findsOneWidget);
    expect(find.text(Copy.quranStageNote), findsNothing);
    expect(find.text('Applied'), findsWidgets);
    expect(find.text('Reflected'), findsWidgets);
    expect(find.text('Understood'), findsWidgets);
    expect(find.text('Engaged'), findsWidgets);
    expect(find.text('Transformation'), findsWidgets);
    expect(find.text('Recitation with Meaning'), findsNothing);
    expect(find.text('Application Reflection'), findsNothing);
  });

  testWidgets('meaning engagement marks Understood M and Engaged R', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty(
          '2026-08-31',
        ).withQuran(QuranDimension.meaning, TernaryOutcome.positive),
      ],
    );
    expect(
      tester
          .widget<QuranJourneyMarker>(
            find.byKey(const Key('quran-home-understood-2026-08-31')),
          )
          .cell
          .code,
      'M',
    );
    expect(
      tester
          .widget<QuranJourneyMarker>(
            find.byKey(const Key('quran-home-engaged-2026-08-31')),
          )
          .cell
          .code,
      'R',
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-understood-2026-08-31')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .kind,
      MarkerKind.filled,
    );
  });

  testWidgets('Qur’an title opens Qur’an entry only', (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(find.text(MonitorDomain.quran.label).first);
    await tester.tap(find.text(MonitorDomain.quran.label).first);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.quran.label} ·'),
      findsOneWidget,
    );
    expect(find.text('Did I let the Qur’an speak to me today?'), findsWidgets);
    expect(find.text('ENGAGEMENT'), findsOneWidget);
    expect(find.text('Recitation'), findsOneWidget);
    expect(find.text('Fajr'), findsNothing);
    expect(find.text('Morning Adhkar'), findsNothing);
    expect(find.text('Memorisation'), findsWidgets);
  });

  testWidgets('Qur’an cell records L2 from the journey sheet', (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(
      find.byKey(const Key('quran-home-applied-2026-09-03')),
    );
    await tester.tap(find.byKey(const Key('quran-home-applied-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(find.text('Applied'), findsWidgets);
    expect(find.text(Copy.quranDayNone), findsOneWidget);
    expect(find.text(Copy.quranDayUnanswered), findsOneWidget);
    expect(find.text('W = Worship'), findsNothing);
    await tester.tap(find.byKey(const Key('quran-journey-l1-stage')));
    await tester.pumpAndSettle();
    expect(find.text('W = Worship'), findsOneWidget);
    expect(find.text(Copy.quranDayNoActivity), findsOneWidget);
    expect(find.text(Copy.quranDayUnanswered), findsWidgets);
    await tester.tap(find.byKey(const Key('quran-journey-l2-W')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<QuranJourneyMarker>(
            find.byKey(const Key('quran-home-applied-2026-09-03')),
          )
          .cell
          .code,
      'W',
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-applied-2026-09-03')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .color,
      MuhasabahColors.mark,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-applied-2026-09-03')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .size,
      AppDimensions.progressMarker,
    );
  });

  testWidgets('Qur’an Understood cell lists only Understood L2', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('quran-home-understood-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.quranDayUnanswered), findsOneWidget);
    await tester.tap(find.byKey(const Key('quran-journey-l1-stage')));
    await tester.pumpAndSettle();
    expect(find.text('T = Translation'), findsOneWidget);
    expect(find.text('M = Meaning'), findsOneWidget);
    expect(find.text('F = Tafsir'), findsOneWidget);
    expect(find.text(Copy.quranDayNoActivity), findsOneWidget);
    expect(find.text(Copy.quranDayUnanswered), findsWidgets);
    expect(find.text('W = Worship'), findsNothing);
    expect(find.text('R = Recitation'), findsNothing);
  });

  testWidgets('activity colours use Qur’an Journey L1 mix', (tester) async {
    await pumpHome(
      tester,
      salahActivityColours: true,
      days: [
        DailyCheckIn.empty(
          '2026-08-31',
        ).withQuran(QuranDimension.meaning, TernaryOutcome.positive),
      ],
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-understood-2026-08-31')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .color,
      QuranStageMark.understanding,
    );
  });

  testWidgets('Qur’an L2 none records no activity', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('quran-home-applied-2026-09-03')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-journey-l1-stage')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-journey-l2-none')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<QuranJourneyMarker>(
            find.byKey(const Key('quran-home-applied-2026-09-03')),
          )
          .cell
          .kind,
      QuranJourneyCellKind.none,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-applied-2026-09-03')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .kind,
      MarkerKind.outlined,
    );
  });

  testWidgets('Qur’an L2 unanswered clears that row only', (tester) async {
    await pumpHome(
      tester,
      days: [
        applyQuranJourneyL2(
          DailyCheckIn.empty('2026-09-03'),
          QuranJourneyRow.applied,
          QuranJourneyRow.applied.l2Options.first,
        ),
      ],
    );
    await tester.tap(find.byKey(const Key('quran-home-applied-2026-09-03')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-journey-l2-unanswered')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-applied-2026-09-03')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .kind,
      MarkerKind.unanswered,
    );
  });

  testWidgets('Qur’an L1 unanswered clears that row only', (tester) async {
    await pumpHome(
      tester,
      days: [
        applyQuranJourneyL2(
          DailyCheckIn.empty('2026-09-03'),
          QuranJourneyRow.applied,
          QuranJourneyRow.applied.l2Options.first,
        ),
      ],
    );
    await tester.tap(find.byKey(const Key('quran-home-applied-2026-09-03')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-journey-l1-unanswered')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.descendant(
              of: find.byKey(const Key('quran-home-applied-2026-09-03')),
              matching: find.byType(RecordedStateMarker),
            ),
          )
          .kind,
      MarkerKind.unanswered,
    );
  });

  testWidgets('future Qur’an cell does not open entry', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('quran-home-applied-2026-09-04')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(find.text('W = Worship'), findsNothing);
  });

  testWidgets('Marks Guide opens without card legends', (tester) async {
    await pumpHome(tester);
    expect(find.textContaining('On time / performed'), findsNothing);
    await tester.tap(find.byTooltip(Copy.marksGuideTitle));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('These marks show what was recorded'),
      findsOneWidget,
    );
    expect(find.text(Copy.quranStageNote), findsOneWidget);
    expect(find.text('On time'), findsOneWidget);
    expect(find.textContaining('do not measure spirituality'), findsOneWidget);
    expect(find.text('Close'), findsWidgets);
    final close = find.byKey(const Key('marks-guide-close'));
    await tester.ensureVisible(close);
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text(Copy.marksGuideTitle), findsNothing);
    expect(find.text(Copy.appName), findsOneWidget);
  });
}
