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

import '../support/test_app.dart';

void main() {
  Future<void> pumpQuickTap(
    WidgetTester tester, {
    MemoryCheckInRepository? checkIns,
    PersonalMix? personalMix,
    Set<MonitorDomain>? visibleDomains,
    DateTime? now,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
          .withHomeTrace('akhlaq.patience', TernaryOutcome.positive),
    );
    await pumpQuickTap(tester, checkIns: checkIns);
    expect(find.text(Copy.quickTapNote), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    final salahWash = domainColorIdentity(MonitorDomain.salah)
        .washFor(Brightness.light);
    final quranWash = domainColorIdentity(MonitorDomain.quran)
        .washFor(Brightness.light);
    final akhlaqWash = domainColorIdentity(MonitorDomain.akhlaq)
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
      find.byKey(const Key('quick-tap-akhlaq.patience')),
      300,
      scrollable: scrollable,
    );
    expect(tileFill(tester, 'akhlaq.patience').color, akhlaqWash);
    expect(quranWash, isNot(salahWash));
    expect(akhlaqWash, isNot(salahWash));
    expect(quranWash, isNot(MuhasabahColors.salahWash));
    expect(akhlaqWash, isNot(MuhasabahColors.salahWash));
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
