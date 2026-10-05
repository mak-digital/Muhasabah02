import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/home/quick_tap_sheet.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/salah_activity_mark.dart';
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

  Future<void> expandQuickTapDomain(
    WidgetTester tester,
    MonitorDomain domain,
  ) async {
    final tiles = find.byKey(Key('quick-tap-domain-tiles-${domain.id}'));
    if (tiles.evaluate().isNotEmpty) return;
    await tester.tap(find.byKey(Key('quick-tap-domain-toggle-${domain.id}')));
    await tester.pumpAndSettle();
  }

  Future<void> expandQuickTapNote(WidgetTester tester) async {
    if (find.byKey(const Key('quick-tap-note')).evaluate().isNotEmpty) {
      return;
    }
    await tester.tap(find.byKey(const Key('quick-tap-note-toggle')));
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
    expect(find.text(Copy.quickTapNote), findsNothing);
    expect(find.byKey(const Key('quick-tap-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsNothing);
    await expandQuickTapDomain(tester, MonitorDomain.salah);
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
    expect(find.text(Copy.quickTapNote), findsNothing);
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    final fajrMark = tester.widget<RecordedStateMarker>(
      find.descendant(
        of: find.byKey(const Key('quick-tap-salah.fajr')),
        matching: find.byType(RecordedStateMarker),
      ),
    );
    expect(fajrMark.kind, MarkerKind.filled);
    expect(fajrMark.color, SalahActivityMark.congregationOnTime);
    final salahWash = domainColorIdentity(MonitorDomain.salah)
        .washFor(Brightness.light);
    final quranWash = domainColorIdentity(MonitorDomain.quran)
        .washFor(Brightness.light);
    final dhikrWash = domainColorIdentity(MonitorDomain.dhikr)
        .washFor(Brightness.light);
    expect(
      tester.widget<Material>(find.byKey(const Key('quick-tap-domain-salah'))).color,
      salahWash,
    );
    expect(tileFill(tester, 'salah.fajr').color, isNot(salahWash));
    expect(tileFill(tester, 'salah.fajr').color, isNot(ThemeData.light().colorScheme.surface));
    final scrollable = find.descendant(
      of: find.byType(QuickTapSheet),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-domain-toggle-quran')),
      300,
      scrollable: scrollable,
    );
    await expandQuickTapDomain(tester, MonitorDomain.quran);
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-quran.reading')),
      300,
      scrollable: scrollable,
    );
    expect(
      tester.widget<Material>(find.byKey(const Key('quick-tap-domain-quran'))).color,
      quranWash,
    );
    expect(tileFill(tester, 'quran.reading').color, isNot(quranWash));
    expect(tileFill(tester, 'quran.reading').color, isNot(tileFill(tester, 'salah.fajr').color));
    final quranShape =
        tileFill(tester, 'quran.reading').shape! as RoundedRectangleBorder;
    expect(quranShape.borderRadius, BorderRadius.circular(14));
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-domain-toggle-dhikr')),
      300,
      scrollable: scrollable,
    );
    await expandQuickTapDomain(tester, MonitorDomain.dhikr);
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-dhikr.morningAdhkar')),
      300,
      scrollable: scrollable,
    );
    expect(
      tester
          .widget<Material>(find.byKey(const Key('quick-tap-domain-dhikr')))
          .color,
      dhikrWash,
    );
    expect(tileFill(tester, 'dhikr.morningAdhkar').color, isNot(dhikrWash));
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
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    expect(
      find.descendant(
        of: find.byKey(const Key('quick-tap-salah.dhuhr')),
        matching: find.text('Not recorded'),
      ),
      findsOneWidget,
    );
    final salahWash = domainColorIdentity(MonitorDomain.salah)
        .washFor(Brightness.light);
    expect(
      tester.widget<Material>(find.byKey(const Key('quick-tap-domain-salah'))).color,
      salahWash,
    );
    expect(tileFill(tester, 'salah.dhuhr').color, isNot(tileFill(tester, 'salah.fajr').color));
    expect(tileFill(tester, 'salah.fajr').color, isNot(salahWash));
    expect(
      tileFill(tester, 'salah.fajr').color,
      isNot(MuhasabahColors.missedEarth.withValues(alpha: 0.12)),
    );
    final marker = tester.widget<RecordedStateMarker>(
      find.descendant(
        of: find.byKey(const Key('quick-tap-salah.fajr')),
        matching: find.byType(RecordedStateMarker),
      ),
    );
    expect(marker.kind, MarkerKind.missed);
    expect(marker.color, SalahActivityMark.colourForId('missed'));
    expect(marker.size, 14);
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
    await expandQuickTapDomain(tester, MonitorDomain.salah);
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
      find.byKey(const Key('quick-tap-domain-toggle-dhikr')),
      300,
      scrollable: scrollable,
    );
    await expandQuickTapDomain(tester, MonitorDomain.dhikr);
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-tap-dhikr.morningAdhkar')),
      300,
      scrollable: scrollable,
    );
    await tester.ensureVisible(
      find.byKey(const Key('quick-tap-dhikr.morningAdhkar')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('quick-tap-dhikr.morningAdhkar')),
      findsOneWidget,
    );
    expect(
      tester
          .getRect(find.byKey(const Key('quick-tap-dhikr.morningAdhkar')))
          .bottom,
      lessThanOrEqualTo(1200 - 48),
    );
  });

  testWidgets('Quick Tap renders at 1.5 text scale without exceptions', (
    tester,
  ) async {
    await pumpQuickTap(tester, textScale: 1.5);
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byKey(const Key('quick-tap-salah.fajr'))).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('Quick Tap keeps mix domain decks collapsed until opened', (
    tester,
  ) async {
    await pumpQuickTap(tester);
    expect(find.byKey(const Key('quick-tap-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-quran')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-dhikr')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-tiles-salah')), findsNothing);
    expect(find.byKey(const Key('quick-tap-domain-tiles-quran')), findsNothing);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsNothing);
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-tiles-quran')), findsNothing);
    expect(find.byKey(const Key('quick-tap-quran.reading')), findsNothing);
  });

  testWidgets('a single Quick Tap domain opens its cards by default', (
    tester,
  ) async {
    await pumpQuickTap(
      tester,
      visibleDomains: {MonitorDomain.salah},
      personalMix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {'salah.fajr', 'salah.dhuhr'},
      ),
    );
    expect(find.byKey(const Key('quick-tap-domain-tiles-salah')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-quran')), findsNothing);
  });

  testWidgets('Quick Tap header wash holds title, day, and a collapsed note', (
    tester,
  ) async {
    await pumpQuickTap(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('quick-tap-header')),
        matching: find.text(Copy.quickTapTitle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('quick-tap-header')),
        matching: find.byKey(const Key('quick-tap-day-label')),
      ),
      findsOneWidget,
    );
    expect(find.text('Monday'), findsWidgets);
    expect(
      find.text(formatGregorianAndHijri(DateTime(2026, 9, 14))),
      findsOneWidget,
    );
    expect(find.text(Copy.quickTapNoteTitle), findsOneWidget);
    expect(find.text(Copy.quickTapNote), findsNothing);
    final header = tester.getRect(find.byKey(const Key('quick-tap-header')));
    final sheet = tester.getRect(find.byType(QuickTapSheet));
    expect(header.left - sheet.left, lessThan(24));
    expect(sheet.right - header.right, lessThan(24));
    expect(header.height, lessThan(96));
    expect(tester.widget<IconButton>(find.byKey(const Key('quick-tap-next-day'))).onPressed, isNull);
    await expandQuickTapNote(tester);
    expect(find.text(Copy.quickTapNote), findsOneWidget);
  });

  testWidgets('Quick Tap previous and next day stay on recorded dates', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-13',
      ).withSalahActivity(
        PrayerId.fajr,
        const RecordedActivity(id: 'congregationOnTime'),
      ),
    );
    await pumpQuickTap(tester, checkIns: checkIns);
    await tester.tap(find.byKey(const Key('quick-tap-prev-day')));
    await tester.pumpAndSettle();
    expect(find.text('Sunday'), findsWidgets);
    expect(
      find.text(formatGregorianAndHijri(DateTime(2026, 9, 13))),
      findsOneWidget,
    );
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    final marker = tester.widget<RecordedStateMarker>(
      find.descendant(
        of: find.byKey(const Key('quick-tap-salah.fajr')),
        matching: find.byType(RecordedStateMarker),
      ),
    );
    expect(marker.kind, MarkerKind.filled);
    await tester.tap(find.byKey(const Key('quick-tap-next-day')));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsWidgets);
    expect(
      find.text(formatGregorianAndHijri(DateTime(2026, 9, 14))),
      findsOneWidget,
    );
  });

  testWidgets('Quick Tap previous day records on that date', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await pumpQuickTap(tester, checkIns: checkIns);
    await tester.tap(find.byKey(const Key('quick-tap-prev-day')));
    await tester.pumpAndSettle();
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    await tester.tap(find.byKey(const Key('quick-tap-salah.fajr')));
    await tester.pumpAndSettle();
    expect(await checkIns.getByDate('2026-09-13'), isNotNull);
    expect(
      (await checkIns.getByDate('2026-09-13'))?.activityFor('salah.fajr').id,
      'congregationOnTime',
    );
    expect(await checkIns.getByDate('2026-09-14'), isNull);
  });
}
