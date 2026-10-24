import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/faq.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quotation_cadence.dart';
import 'package:muhasabah02/domain/weekly_quotes.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('settings expose baselines, aspirations, and quotation cadence', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-03')
          .withHomeTrace('family.familyContact', TernaryOutcome.positive),
    );

    await tester.pumpWidget(
      testApp(checkIns: checkIns, now: DateTime(2026, 9, 5)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.baselinesTitle));
    expect(find.text(Copy.personalAspirations), findsOneWidget);
    expect(find.text(Copy.quotationCadence), findsOneWidget);
    expect(find.text(Copy.calendar), findsOneWidget);
    expect(find.text(Copy.visibleDomains), findsOneWidget);
    expect(find.textContaining('Mix: Same as Domains'), findsOneWidget);
    expect(find.text(Copy.personalMix), findsNothing);

    await tester.ensureVisible(find.text(Copy.baselinesTitle));
    await tester.tap(find.text(Copy.baselinesTitle));
    await tester.pumpAndSettle();
    expect(find.text('Create from last 30 days'), findsOneWidget);
    expect(find.textContaining('XP'), findsNothing);
    await tester.tap(find.text('Manual baseline'));
    await tester.pumpAndSettle();
    expect(find.text(manualBaselineHint), findsOneWidget);
    expect(find.textContaining('See FAQ 21 for details'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create current snapshot baseline'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sibling Contact'), findsWidgets);
  });

  testWidgets('hidden cadence removes Reflection of the Week', (tester) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 5)));
    await tester.pumpAndSettle();
    expect(find.text(Copy.reflectionOfTheWeek), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.quotationCadence));
    await tester.tap(find.text(Copy.quotationCadence));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hidden'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.reflectionOfTheWeek), findsNothing);
    expect(find.text(Copy.reflectionOfTheDay), findsNothing);
  });

  testWidgets('daily cadence retitles Home to Reflection of the Day', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    expect(find.text(Copy.reflectionOfTheWeek), findsOneWidget);
    expect(find.text(Copy.reflectionOfTheDay), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.quotationCadence));
    await tester.tap(find.text(Copy.quotationCadence));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.reflectionOfTheDay), findsOneWidget);
    expect(find.text(Copy.reflectionOfTheWeek), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.quotationCadence));
    await tester.tap(find.text(Copy.quotationCadence));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly (default)'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.reflectionOfTheWeek), findsOneWidget);
    expect(find.text(Copy.reflectionOfTheDay), findsNothing);
  });

  testWidgets('next reflection stays as the week quote after a rebuild', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = MemoryAppPrefs();
    final now = DateTime(2026, 10, 8);
    final first = quoteFor(now: now, cadence: QuotationCadence.weekly)!;
    final second =
        kReflectionQuotes[stepReflectionCatalog(
          reflectionCatalogIndex(first),
          1,
        )];

    await tester.pumpWidget(testApp(now: now, prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text(first.text), findsOneWidget);

    await tester.tap(find.byKey(const Key('reflection-next')));
    await tester.pumpAndSettle();
    expect(find.text(second.text), findsOneWidget);
    expect(find.text(first.text), findsNothing);

    await tester.pumpWidget(testApp(now: now, prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text(second.text), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('reflection-view-source'))).height,
      lessThan(48),
    );
  });

  testWidgets('open citation keeps Close and Share in this app', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 10, 8);
    final quote = quoteFor(now: now, cadence: QuotationCadence.weekly)!;
    await tester.pumpWidget(testApp(now: now));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reflection-source-link')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.openReflectionSource), findsOneWidget);
    await tester.tap(find.byKey(const Key('reflection-open-citation')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citation-reader')), findsOneWidget);
    expect(find.byKey(const Key('citation-close')), findsOneWidget);
    expect(find.byKey(const Key('citation-share')), findsOneWidget);
    expect(find.byKey(const Key('citation-uri')), findsOneWidget);
    expect(
      (tester.widget<Text>(find.byKey(const Key('citation-uri'))).data ?? '')
          .startsWith('https://'),
      isTrue,
    );
    expect(quote.source, isNotEmpty);
    await tester.tap(find.byKey(const Key('citation-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citation-reader')), findsNothing);
    expect(find.text(Copy.reflectionOfTheWeek), findsOneWidget);
  });
}
