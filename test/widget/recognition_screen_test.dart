import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recorded_context.dart';
import 'package:muhasabah02/presentation/recognition/recognition_screen.dart';
import 'package:muhasabah02/presentation/recorded_days/day_evidence_screen.dart';
import 'package:muhasabah02/presentation/review/review_screen.dart';

import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 7, 12);

  Future<void> pumpApp(
    WidgetTester tester, {
    MemoryCheckInRepository? checkIns,
    Set<MonitorDomain>? visibleDomains,
    PersonalMix? personalMix,
  }) async {
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: now,
        checkIns: checkIns,
        visibleDomains: visibleDomains ?? allVisibleDomains(),
        personalMix: personalMix,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openReview(WidgetTester tester) async {
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewScreen), findsOneWidget);
  }

  Future<void> openRecognition(
    WidgetTester tester, {
    int? periodDays,
  }) async {
    await openReview(tester);
    if (periodDays != null) {
      await tester.tap(find.text('$periodDays days'));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      find.text(Copy.recognitionTitle),
      240,
      scrollable: find.descendant(
        of: find.byType(ReviewScreen),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.tap(find.text(Copy.recognitionTitle));
    await tester.pumpAndSettle();
    expect(find.byType(RecognitionScreen), findsOneWidget);
  }

  DailyCheckIn meaningDay(String date) {
    return DailyCheckIn.empty(date)
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive)
        .withContext(
          const RecordedContext(
            subject: QuranDimension.meaning,
            polarity: 'positive',
            factorIds: ['routine'],
          ),
        );
  }

  testWidgets('hidden Qur’an keeps Recognition off Review', (tester) async {
    await pumpApp(
      tester,
      visibleDomains: {MonitorDomain.salah, MonitorDomain.akhlaq},
    );
    await openReview(tester);
    expect(find.text(Copy.recognitionTitle), findsNothing);
    expect(find.text(Copy.recordedDaysTitle), findsOneWidget);
  });

  testWidgets('7-day Recognition shows the 30/90 notice', (tester) async {
    await pumpApp(tester);
    await openRecognition(tester);
    expect(find.text(Copy.recognitionSevenDay), findsOneWidget);
    expect(find.byKey(const Key('recognition-coverage')), findsNothing);
    expect(find.text(Copy.recognitionNoPatternsTitle), findsNothing);
  });

  testWidgets('coverage preamble counts saved check-ins in the 30-day window', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(DailyCheckIn.empty('2026-07-12'));
    await checkIns.save(DailyCheckIn.empty('2026-07-01'));
    await checkIns.save(DailyCheckIn.empty('2026-06-01'));
    await pumpApp(tester, checkIns: checkIns);
    await openRecognition(tester, periodDays: 30);
    expect(
      find.text(Copy.recognitionCoverage(2, 30)),
      findsOneWidget,
    );
    expect(find.byKey(const Key('recognition-no-patterns')), findsOneWidget);
    expect(find.text(Copy.recognitionNoPatternsTitle), findsOneWidget);
    expect(find.textContaining('missed practices'), findsNothing);
  });

  testWidgets('mix with no eligible peer practices shows a distinct empty state', (
    tester,
  ) async {
    await pumpApp(
      tester,
      personalMix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {'quran.reading', 'salah.fajr'},
      ),
    );
    await openRecognition(tester, periodDays: 30);
    expect(find.byKey(const Key('recognition-no-eligible')), findsOneWidget);
    expect(find.text(Copy.recognitionNoEligibleTitle), findsOneWidget);
    expect(find.byKey(const Key('recognition-no-patterns')), findsNothing);
    expect(
      find.text(Copy.recognitionCoverage(0, 30)),
      findsOneWidget,
    );
  });

  testWidgets('pattern card opens a supporting date', (tester) async {
    final checkIns = MemoryCheckInRepository();
    for (var i = 1; i <= 12; i++) {
      await checkIns.save(
        meaningDay('2026-07-${i.toString().padLeft(2, '0')}'),
      );
    }
    await pumpApp(tester, checkIns: checkIns);
    await openRecognition(tester, periodDays: 30);
    expect(find.text(QuranDimension.meaning.label), findsWidgets);
    expect(find.textContaining('Context was recorded for'), findsOneWidget);
    expect(find.textContaining('appeared on'), findsOneWidget);
    expect(find.text(Copy.recognitionGuard), findsOneWidget);
    await tester.tap(find.byKey(const Key('recognition-date-2026-07-12')));
    await tester.pumpAndSettle();
    expect(find.byType(DayEvidenceScreen), findsOneWidget);
    expect(find.text(Copy.historicalReflectionGuard), findsOneWidget);
  });

  testWidgets('mix exclusion hides stored meaning patterns', (tester) async {
    final checkIns = MemoryCheckInRepository();
    for (var i = 1; i <= 12; i++) {
      await checkIns.save(
        meaningDay('2026-07-${i.toString().padLeft(2, '0')}'),
      );
    }
    await pumpApp(
      tester,
      checkIns: checkIns,
      personalMix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {'quran.revision', 'salah.fajr'},
      ),
    );
    await openRecognition(tester, periodDays: 30);
    expect(find.text(QuranDimension.meaning.label), findsNothing);
    expect(find.byKey(const Key('recognition-no-patterns')), findsOneWidget);
  });
}
