import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/dashboard_summary.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/review_period.dart';
import 'package:muhasabah02/presentation/progress/salah_progress_screen.dart';

import '../support/test_app.dart';

void main() {
  test(
    'dashboard snapshot stays factual and excludes missing from outcomes',
    () {
      final today = DateTime(2026, 9, 3);
      final records = [
        DailyCheckIn.empty('2026-09-03')
            .withPrayer(PrayerId.fajr, PrayerStatus.onTime),
        DailyCheckIn.empty('2026-09-02')
            .withPrayer(PrayerId.fajr, PrayerStatus.unanswered),
      ];
      final snapshot = buildHomeDashboard(
        records: records,
        now: today,
        period: ReviewPeriod.days7,
        recognitionCount: 0,
      );
      expect(snapshot.salah.title, 'Salah');
      expect(snapshot.salah.unansweredLine, contains('unanswered'));
      expect(snapshot.salah.periodLine, contains('missing excluded'));
      expect(snapshot.recognitionLine, contains('30-day'));
      expect(snapshot.reviewLine, contains('recorded'));
    },
  );

  testWidgets('home dashboard shows domain cards and ponder without scores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    expect(find.text('Salah'), findsWidgets);
    expect(find.text('Qur’an'), findsWidgets);
    expect(find.text('Dhikr'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('Charity'), findsOneWidget);
    expect(find.text('Fasting'), findsOneWidget);
    expect(find.text(Copy.ponderPrompt), findsWidgets);
    expect(find.text('Recognition'), findsWidgets);
    expect(find.text(Copy.addAResponse), findsWidgets);
    expect(find.text(Copy.homeCheckIn), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);

    await tester.ensureVisible(find.text('Salah').first);
    await tester.tap(find.text('Salah').first);
    await tester.pumpAndSettle();
    expect(find.byType(SalahProgressScreen), findsOneWidget);
  });
}
