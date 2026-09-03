import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/recorded_days/day_evidence_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('home navigation and check-in save persist', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await tester.pumpWidget(testApp(checkIns: checkIns));
    await tester.pumpAndSettle();
    expect(find.text(Copy.appName), findsWidgets);
    expect(find.text(Copy.homeCheckIn), findsOneWidget);
    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();
    expect(find.text('Salah'), findsWidgets);
    await tester.tap(find.text('Prayed alone on time').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();
    final stored = await checkIns.allHealthy();
    expect(stored, isNotEmpty);
    expect(stored.single.answeredRecordableCount, greaterThan(0));
  });

  testWidgets('history is editable management not scored', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-01'));
    await tester.pumpWidget(testApp(checkIns: checkIns));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text(Copy.historyTitle), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.text('2026-09-01'), findsOneWidget);
  });

  testWidgets('review has 7/30/90 and no generated recommendations', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Period summary'), findsOneWidget);
    expect(find.text('7 days'), findsWidgets);
    expect(find.text('For the coming days'), findsNothing);
    await tester.ensureVisible(find.text('Salah Progress'));
    expect(find.text('Salah Progress'), findsOneWidget);
    expect(find.text('Qur’an Progress'), findsOneWidget);
    await tester.tap(find.text('30 days'));
  });

  testWidgets('ponder copy is static and my response empty state is frozen', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Qur’an Progress'));
    await tester.tap(find.text('Qur’an Progress'));
    await tester.pumpAndSettle();
    expect(find.text(Copy.ponderPrompt), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.myResponse));
    await tester.pumpAndSettle();
    expect(find.textContaining(Copy.emptyResponses), findsOneWidget);
    expect(find.text(Copy.addAResponse), findsWidgets);
  });

  testWidgets('response editor rejects empty text and saves unicode', (
    tester,
  ) async {
    final responses = MemoryResponseRepository();
    await tester.pumpWidget(testApp(responses: responses));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.myResponse));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.addAResponse).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    expect(find.text('A response needs some text.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'الحمد لله and ধন্যবাদ');
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    final saved = await responses.allHealthy();
    expect(saved, hasLength(1));
    expect(saved.single.text, contains('الحمد لله'));
  });

  testWidgets('salah late and missed have the same add-response CTA', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-01'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(checkIns),
          responseRepositoryProvider.overrideWithValue(
            MemoryResponseRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(applicationReflectionAcknowledged: true),
          ),
        ],
        child: const MaterialApp(
          home: DayEvidenceScreen(dateKey: '2026-09-01'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Prayed late'), findsOneWidget);
    expect(find.text('Missed'), findsOneWidget);
    expect(find.text(Copy.addAResponse), findsWidgets);
    await tester.scrollUntilVisible(
      find.text(Copy.applicationReflectionNote),
      300,
    );
    expect(find.text(Copy.applicationReflectionNote), findsOneWidget);
  });

  testWidgets('malformed route does not crash', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed('/this-route-does-not-exist');
    await tester.pumpAndSettle();
    expect(find.textContaining('not available'), findsOneWidget);
  });

  testWidgets('dark theme and 1.5 text scale layout', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: testApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Theme'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text(Copy.homeCheckIn));
    expect(find.text(Copy.homeCheckIn), findsOneWidget);
  });
}
