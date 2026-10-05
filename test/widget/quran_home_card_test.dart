import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/salah_activity_mark.dart';
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
    PersonalMix? personalMix,
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
        personalMix: personalMix,
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
          .getTopLeft(
            find.byKey(const Key('quran-home-consciousApplication-2026-08-31')),
          )
          .dx,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(
                const Key('quran-home-consciousApplication-2026-09-01'),
              ),
            )
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
          .getTopLeft(
            find.byKey(const Key('quran-home-consciousApplication-2026-08-30')),
          )
          .dx,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(
                const Key('quran-home-consciousApplication-2026-08-31'),
              ),
            )
            .dx,
      ),
    );
  });

  testWidgets('Qur’an Home shows stored rows and not Application Reflection', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text(Copy.quranJourney.toUpperCase()), findsNothing);
    expect(find.text(Copy.quranStageNote), findsNothing);
    expect(find.text('ENGAGEMENT'), findsNothing);
    expect(find.text('UNDERSTANDING & REFLECTION'), findsNothing);
    expect(find.text('REFLECTION'), findsNothing);
    expect(find.text('PRACTICAL RELEVANCE'), findsNothing);
    expect(find.text('Practical relevance'), findsWidgets);
    expect(find.text('Qur’anic Reflection'), findsNothing);
    expect(find.text('Engagement'), findsWidgets);
    expect(find.text('Understanding & reflection'), findsWidgets);
    expect(find.text('Memorisation'), findsNothing);
    expect(find.text('Transformation'), findsNothing);
    expect(find.text('Internalization'), findsNothing);
    expect(find.text('Comprehension'), findsNothing);
    expect(find.text('Application Reflection'), findsNothing);
  });

  testWidgets('understanding sitting does not fill engagement', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty('2026-08-31')
            .withQuran(QuranDimension.meaning, TernaryOutcome.positive),
      ],
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-meaning-2026-08-31')),
          )
          .kind,
      MarkerKind.filled,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-reading-2026-08-31')),
          )
          .kind,
      MarkerKind.unanswered,
    );
  });

  testWidgets('Home shows Applied and Engaged independently on the same day', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty('2026-08-31')
            .withQuran(QuranDimension.reading, TernaryOutcome.positive)
            .withQuran(
              QuranDimension.consciousApplication,
              TernaryOutcome.positive,
            ),
      ],
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(
              const Key('quran-home-consciousApplication-2026-08-31'),
            ),
          )
          .kind,
      MarkerKind.filled,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-reading-2026-08-31')),
          )
          .kind,
      MarkerKind.filled,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-meaning-2026-08-31')),
          )
          .kind,
      MarkerKind.unanswered,
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
    expect(find.text('Engagement'), findsWidgets);
    expect(find.text('Fajr'), findsNothing);
    expect(find.text('Morning Adhkar'), findsNothing);
    expect(find.text('Memorisation'), findsNothing);
  });

  testWidgets('Qur’an cell opens focused check-in for that row', (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(
      find.byKey(const Key('quran-home-consciousApplication-2026-09-03')),
    );
    await tester.tap(
      find.byKey(const Key('quran-home-consciousApplication-2026-09-03')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text(Copy.quranDayNone), findsNothing);
    expect(
      find.textContaining('${MonitorDomain.quran.label} ·'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(
      find.text('Did you notice a possible practical relevance from learnt verses today?'),
      findsOneWidget,
    );
  });

  testWidgets('activity colours use the Qur’an check-in band', (tester) async {
    await pumpHome(
      tester,
      salahActivityColours: true,
      days: [
        DailyCheckIn.empty('2026-08-31')
            .withQuran(QuranDimension.meaning, TernaryOutcome.positive),
      ],
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-meaning-2026-08-31')),
          )
          .color,
      SalahActivityMark.congregationOnTime,
    );
  });

  testWidgets('future Qur’an cell does not open entry', (tester) async {
    await pumpHome(tester);
    await tester.tap(
      find.byKey(const Key('quran-home-consciousApplication-2026-09-04')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
  });

  testWidgets('First season mix omits unused Qur’an Home rows', (tester) async {
    await pumpHome(
      tester,
      personalMix: mixForKind(PersonalMixKind.firstLook),
    );
    expect(find.byKey(const Key('quran-home-reading-2026-09-03')), findsOneWidget);
    expect(find.byKey(const Key('quran-home-meaning-2026-09-03')), findsOneWidget);
    expect(
      find.byKey(const Key('quran-home-memorisation-2026-09-03')),
      findsNothing,
    );
    expect(find.byKey(const Key('quran-home-revision-2026-09-03')), findsNothing);
    expect(find.byKey(const Key('quran-home-tafsir-2026-09-03')), findsNothing);
    expect(find.byKey(const Key('quran-home-consciousApplication-2026-09-03')), findsOneWidget);
    expect(
      find.byKey(const Key('quran-home-reflection-2026-09-03')),
      findsNothing,
    );
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
