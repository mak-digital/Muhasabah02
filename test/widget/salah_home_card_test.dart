import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/dimensions.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/progress/salah_progress_screen.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 9, 3);

  Future<void> pumpHome(
    WidgetTester tester, {
    required List<DailyCheckIn> days,
    FirstDayOfWeekPref firstDay = FirstDayOfWeekPref.monday,
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
      testApp(checkIns: checkIns, now: now, firstDayOfWeek: firstDay),
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

  testWidgets('Salah title still opens progress', (tester) async {
    await pumpHome(tester, days: const []);
    await tester.tap(find.text('Salah').first);
    await tester.pumpAndSettle();
    expect(find.byType(SalahProgressScreen), findsOneWidget);
  });
}
