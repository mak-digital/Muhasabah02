import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/home/quick_tap_sheet.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';
import 'package:muhasabah02/presentation/shared/system_insets.dart';

import '../support/test_app.dart';

void main() {
  Future<void> pumpQuickTap(
    WidgetTester tester, {
    MemoryCheckInRepository? checkIns,
    PersonalMix? personalMix,
    Set<MonitorDomain>? visibleDomains,
    DateTime? now,
    double textScale = 1,
    double systemBottom = 0,
  }) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (systemBottom > 0) {
      tester.view.padding = FakeViewPadding(bottom: systemBottom);
      tester.view.viewPadding = FakeViewPadding(bottom: systemBottom);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
    }
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      testApp(
        checkIns: checkIns ?? MemoryCheckInRepository(),
        now: now ?? DateTime(2026, 9, 14),
        personalMix: personalMix ?? mixForKind(PersonalMixKind.firstLook),
        visibleDomains: visibleDomains,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.quickTap));
    await tester.tap(find.text(Copy.quickTap));
    await tester.pumpAndSettle();
  }

  Material tileFill(WidgetTester tester, String id) {
    return tester.widget<Material>(
      find.descendant(
        of: find.byKey(Key('quick-tap-$id')),
        matching: find.byType(Material),
      ),
    );
  }

  testWidgets('quick tap records fajr on time from Home', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await pumpQuickTap(tester, checkIns: checkIns);
    expect(find.text(Copy.quickTapNote), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-dhikr.generalDhikr')), findsNothing);
    await tester.tap(find.byKey(const Key('quick-tap-salah.fajr')));
    await tester.pumpAndSettle();
    final stored = await checkIns.getByDate('2026-09-14');
    expect(stored?.activityFor('salah.fajr').id, 'congregationOnTime');
    expect(stored?.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(stored?.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
    expect(
      stored?.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );
  });

  testWidgets('noticed Quick Tap tiles use their own domain wash', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-14')
          .withSalahActivity(
            PrayerId.fajr,
            const RecordedActivity(id: 'congregationOnTime'),
          )
          .withQuran(QuranDimension.reading, TernaryOutcome.positive)
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive),
    );
    await pumpQuickTap(tester, checkIns: checkIns);
    expect(find.text(Copy.quickTapNote), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    final salahWash = domainColorIdentity(MonitorDomain.salah)
        .washFor(Brightness.light);
    final quranWash = domainColorIdentity(MonitorDomain.quran)
        .washFor(Brightness.light);
    final dhikrWash = domainColorIdentity(MonitorDomain.dhikr)
        .washFor(Brightness.light);
    expect(tileFill(tester, 'salah.fajr').color, salahWash);
    final scrollable = find.descendant(
      of: find.byType(QuickTapSheet),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-quran.reading')),
      300,
      scrollable: scrollable,
    );
    expect(tileFill(tester, 'quran.reading').color, quranWash);
    final quranShape =
        tileFill(tester, 'quran.reading').shape! as RoundedRectangleBorder;
    expect(quranShape.borderRadius, BorderRadius.circular(18));
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-dhikr.morningAdhkar')),
      300,
      scrollable: scrollable,
    );
    expect(tileFill(tester, 'dhikr.morningAdhkar').color, dhikrWash);
    expect(quranWash, isNot(salahWash));
    expect(dhikrWash, isNot(salahWash));
    expect(quranWash, isNot(MuhasabahColors.salahWash));
    expect(dhikrWash, isNot(MuhasabahColors.salahWash));
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.textContaining('complete'), findsNothing);
  });

  testWidgets('unanswered caption and slip marker stay observational', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-14',
      ).withSalahActivity(PrayerId.fajr, const RecordedActivity(id: 'missed')),
    );
    await pumpQuickTap(tester, checkIns: checkIns);
    expect(
      find.descendant(
        of: find.byKey(const Key('quick-tap-salah.dhuhr')),
        matching: find.text('Not recorded'),
      ),
      findsOneWidget,
    );
    expect(
      tileFill(tester, 'salah.dhuhr').color,
      isNot(domainColorIdentity(MonitorDomain.salah).washFor(Brightness.light)),
    );
    expect(
      tileFill(tester, 'salah.fajr').color,
      MuhasabahColors.missedEarth.withValues(alpha: 0.12),
    );
    final marker = tester.widget<RecordedStateMarker>(
      find.descendant(
        of: find.byKey(const Key('quick-tap-salah.fajr')),
        matching: find.byType(RecordedStateMarker),
      ),
    );
    expect(marker.kind, MarkerKind.missed);
    expect(marker.size, 18);
  });

  testWidgets('empty Quick Tap copy is unchanged', (tester) async {
    await pumpQuickTap(
      tester,
      visibleDomains: <MonitorDomain>{},
      personalMix: mixForKind(PersonalMixKind.firstLook),
    );
    expect(find.text(Copy.quickTapEmpty), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsNothing);
  });

  testWidgets('Quick Tap tile speaks one button label for practice and state', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpQuickTap(tester, checkIns: checkIns);
    final unanswered = tester.getSemantics(
      find.byKey(const Key('quick-tap-salah.fajr')),
    );
    expect(unanswered.label, 'Fajr. Not recorded');
    expect(unanswered.flagsCollection.isButton, isTrue);
    await tester.tap(find.byKey(const Key('quick-tap-salah.fajr')));
    await tester.pumpAndSettle();
    final recorded = tester.getSemantics(
      find.byKey(const Key('quick-tap-salah.fajr')),
    );
    expect(recorded.label, 'Fajr. Prayed on time in congregation');
    expect(recorded.flagsCollection.isButton, isTrue);
    expect(recorded.label.contains('Not recorded'), isFalse);
  });

  testWidgets('contentBottomInset keeps an intentional MediaQuery zero inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
        child: Builder(
          builder: (context) {
            inset = contentBottomInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(inset, 16);
  });

  testWidgets(
    'presentingSystemBottom recovers View inset after MediaQuery is consumed',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 48);
      tester.view.viewPadding = const FakeViewPadding(bottom: 48);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      late double mediaInset;
      late double presenting;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: Builder(
            builder: (context) {
              mediaInset = contentBottomInset(context);
              presenting = contentBottomInset(
                context,
                systemBottom: presentingSystemBottom(context),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(mediaInset, 16);
      expect(presenting, 64);
    },
  );

  testWidgets('contentBottomInset does not stack keyboard and system inset', (
    tester,
  ) async {
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          viewPadding: EdgeInsets.only(bottom: 48),
          viewInsets: EdgeInsets.only(bottom: 280),
        ),
        child: Builder(
          builder: (context) {
            inset = contentBottomInset(context, systemBottom: 48);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(inset, 296);
  });

  testWidgets('Quick Tap last row stays above a 48dp system inset', (
    tester,
  ) async {
    await pumpQuickTap(tester, systemBottom: 48);
    final scrollable = find.descendant(
      of: find.byType(QuickTapSheet),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-zakat')),
      300,
      scrollable: scrollable,
    );
    await tester.ensureVisible(find.byKey(const Key('quick-tap-zakat')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-tap-zakat')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const Key('quick-tap-zakat'))).bottom,
      lessThanOrEqualTo(1200 - 48),
    );
  });

  testWidgets('Quick Tap renders at 1.5 text scale without exceptions', (
    tester,
  ) async {
    await pumpQuickTap(tester, textScale: 1.5);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byKey(const Key('quick-tap-salah.fajr'))).height,
      greaterThanOrEqualTo(48),
    );
  });
}
