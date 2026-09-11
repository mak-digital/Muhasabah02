import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/dimensions.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/weekly_calendar.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 9, 3);

  Future<void> pumpHome(
    WidgetTester tester, {
    required List<DailyCheckIn> days,
    FirstDayOfWeekPref firstDay = FirstDayOfWeekPref.monday,
    DisplayCalendar calendar = DisplayCalendar.gregorian,
  }) async {
    tester.view.physicalSize = const Size(400, 2200);
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
        displayCalendar: calendar,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Monday first places Monday as the first Salah column', (
    tester,
  ) async {
    await pumpHome(tester, days: const []);
    expect(
      tester.getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-31'))).dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('salah-home-fajr-2026-09-01')))
            .dx,
      ),
    );
  });

  testWidgets('Sunday first places Sunday as the first Salah column', (
    tester,
  ) async {
    await pumpHome(tester, days: const [], firstDay: FirstDayOfWeekPref.sunday);
    expect(
      tester.getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-30'))).dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-31')))
            .dx,
      ),
    );
  });

  testWidgets('Saturday first places Saturday as the first Salah column', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: const [],
      firstDay: FirstDayOfWeekPref.saturday,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-29'))).dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-30')))
            .dx,
      ),
    );
  });

  testWidgets('device locale en_US places Sunday as the first Salah column', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: const [],
      firstDay: FirstDayOfWeekPref.deviceLocale,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-30'))).dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('salah-home-fajr-2026-08-31')))
            .dx,
      ),
    );
  });

  testWidgets('Jumu‘ah is blank off Friday and active on Friday', (
    tester,
  ) async {
    await pumpHome(tester, days: const []);
    expect(
      find.byKey(const Key('salah-home-jumuah-2026-09-03')),
      findsOneWidget,
    );
    expect(
      tester.widget(find.byKey(const Key('salah-home-jumuah-2026-09-03'))),
      isA<SizedBox>(),
    );
    expect(
      tester.widget(find.byKey(const Key('salah-home-jumuah-2026-09-04'))),
      isA<RecordedStateMarker>(),
    );
  });

  testWidgets('Friday Dhuhr shows a star only when congregation is recorded', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty('2026-09-04')
            .withPrayer(PrayerId.dhuhr, PrayerStatus.onTime)
            .copyWith(jumuahCongregation: true, jumuah: PrayerStatus.onTime),
        DailyCheckIn.empty('2026-09-03')
            .withPrayer(PrayerId.dhuhr, PrayerStatus.onTime),
      ],
    );
    final starred = tester.widget<RecordedStateMarker>(
      find.byKey(const Key('salah-home-dhuhr-2026-09-04')),
    );
    expect(starred.symbol, Icons.star);
    expect(starred.symbolSize, AppDimensions.progressMarkerStar);
    final plain = tester.widget<RecordedStateMarker>(
      find.byKey(const Key('salah-home-dhuhr-2026-09-03')),
    );
    expect(plain.symbol, isNull);
  });

  testWidgets('Late outline is not the missed slash', (tester) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty('2026-08-31')
            .withPrayer(PrayerId.fajr, PrayerStatus.late),
        DailyCheckIn.empty('2026-09-01')
            .withPrayer(PrayerId.fajr, PrayerStatus.missed),
        DailyCheckIn.empty('2026-09-02'),
      ],
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('salah-home-fajr-2026-08-31')),
          )
          .kind,
      MarkerKind.outlined,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('salah-home-fajr-2026-09-01')),
          )
          .kind,
      MarkerKind.missed,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('salah-home-fajr-2026-09-02')),
          )
          .kind,
      MarkerKind.unanswered,
    );
  });

  testWidgets(
    'Tahajjud and Ishraq map performed / not performed / unanswered',
    (tester) async {
      await pumpHome(
        tester,
        days: [
          DailyCheckIn.empty('2026-08-31').copyWith(
            tahajjud: TernaryOutcome.positive,
            ishraq: TernaryOutcome.negative,
          ),
          DailyCheckIn.empty('2026-09-01')
              .copyWith(tahajjud: TernaryOutcome.unanswered),
        ],
      );
      expect(
        tester
            .widget<RecordedStateMarker>(
              find.byKey(const Key('salah-home-tahajjud-2026-08-31')),
            )
            .kind,
        MarkerKind.filled,
      );
      expect(
        tester
            .widget<RecordedStateMarker>(
              find.byKey(const Key('salah-home-ishraq-2026-08-31')),
            )
            .kind,
        MarkerKind.outlined,
      );
      expect(
        tester
            .widget<RecordedStateMarker>(
              find.byKey(const Key('salah-home-tahajjud-2026-09-01')),
            )
            .kind,
        MarkerKind.unanswered,
      );
    },
  );

  testWidgets('Salah title opens Salah entry only', (tester) async {
    await pumpHome(tester, days: const []);
    await tester.tap(find.text(MonitorDomain.salah.label).first);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} ·'),
      findsOneWidget,
    );
    expect(
      find.text('Was my heart present when I stood before Allah?'),
      findsWidgets,
    );
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Recitation'), findsNothing);
    expect(find.text('Morning Adhkar'), findsNothing);
  });

  testWidgets('Dhuhr cell opens Obligatory Salah and Ishraq opens Voluntary', (
    tester,
  ) async {
    await pumpHome(tester, days: const []);
    await tester.tap(find.byKey(const Key('salah-home-dhuhr-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Ishraq'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('salah-home-ishraq-2026-08-31')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} · 31 Aug 2026'),
      findsOneWidget,
    );
    expect(find.text('Ishraq'), findsOneWidget);
    expect(find.text('Fajr'), findsNothing);
  });

  testWidgets('today Salah cell opens that day’s entry ready to save', (
    tester,
  ) async {
    await pumpHome(tester, days: const []);
    await tester.tap(find.byKey(const Key('salah-home-fajr-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(find.text(Copy.edit), findsNothing);
  });

  testWidgets('past Salah cell opens that day locked until Edit', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty('2026-08-31')
            .withPrayer(PrayerId.fajr, PrayerStatus.onTime),
      ],
    );
    await tester.tap(find.byKey(const Key('salah-home-fajr-2026-08-31')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} · 31 Aug 2026'),
      findsOneWidget,
    );
    expect(find.text(Copy.edit), findsWidgets);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text(Copy.edit).last);
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('future Salah cell does not open entry', (tester) async {
    await pumpHome(tester, days: const []);
    await tester.tap(find.byKey(const Key('salah-home-fajr-2026-09-04')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
  });

  testWidgets('Islamic calendar shows Hijri dates on the Salah week range', (
    tester,
  ) async {
    await pumpHome(tester, days: const [], calendar: DisplayCalendar.islamic);
    final range = weekRangeLabel(
      DateTime(2026, 8, 31),
      calendar: DisplayCalendar.islamic,
    );
    expect(find.text(range), findsWidgets);
    expect(find.textContaining('Aug'), findsNothing);
    expect(find.textContaining('Sep'), findsNothing);
  });
}
