import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/dhikr_context.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/fasting_practices.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/home/quick_tap_sheet.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/salah_activity_mark.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';
import 'package:muhasabah02/presentation/shared/system_insets.dart';

import '../support/home_domain_stage.dart';
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
    MonitorDomain? homeDomain,
  }) async {
    tester.view.physicalSize = Size(400, homeDomain == null ? 1200 : 2400);
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
    if (homeDomain != null) {
      await showHomeDomain(tester, homeDomain);
    }
    await openHomeQuickTap(tester);
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
    final toggle = find.byKey(const Key('quick-tap-note-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
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
    expect(find.byKey(const Key('quick-tap-domain-group')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-salah')), findsOneWidget);
    expect(find.text('SALAH'), findsNothing);
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
    expect(fajrMark.size, 12);
    final salahWash = domainColorIdentity(MonitorDomain.salah)
        .washFor(Brightness.light);
    final quranWash = domainColorIdentity(MonitorDomain.quran)
        .washFor(Brightness.light);
    final dhikrWash = domainColorIdentity(MonitorDomain.dhikr)
        .washFor(Brightness.light);
    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(const Key('quick-tap-domain-rail-salah')),
          )
          .color,
      domainColorIdentity(MonitorDomain.salah).family,
    );
    expect(
      tester
          .widget<Material>(find.byKey(const Key('quick-tap-domain-group')))
          .color,
      Theme.of(tester.element(find.byType(QuickTapSheet))).colorScheme.surface,
    );
    final fajrFill = tileFill(tester, 'salah.fajr').color;
    expect(fajrFill, isNot(salahWash));
    expect(fajrFill, isNot(ThemeData.light().colorScheme.surface));
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
      tester
          .widget<ColoredBox>(
            find.byKey(const Key('quick-tap-domain-rail-quran')),
          )
          .color,
      domainColorIdentity(MonitorDomain.quran).family,
    );
    final quranFill = tileFill(tester, 'quran.reading').color;
    expect(quranFill, isNot(quranWash));
    expect(quranFill, isNot(fajrFill));
    final quranShape =
        tileFill(tester, 'quran.reading').shape! as RoundedRectangleBorder;
    expect(quranShape.borderRadius, BorderRadius.circular(10));
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
          .widget<ColoredBox>(
            find.byKey(const Key('quick-tap-domain-rail-dhikr')),
          )
          .color,
      domainColorIdentity(MonitorDomain.dhikr).family,
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
      tester
          .widget<ColoredBox>(
            find.byKey(const Key('quick-tap-domain-rail-salah')),
          )
          .color,
      domainColorIdentity(MonitorDomain.salah).family,
    );
    expect(
      tileFill(tester, 'salah.dhuhr').color,
      isNot(tileFill(tester, 'salah.fajr').color),
    );
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
    expect(marker.size, 12);
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('quick-tap-salah.fajr')),
              matching: find.text('Missed'),
            ),
          )
          .style
          ?.color,
      MuhasabahColors.recordedLabel,
    );
    expect(MuhasabahColors.recordedLabel, isNot(SalahActivityMark.prayedLate));
  });

  testWidgets(
    'Quick Tap choice labels stay readable blue; colour stays on the mark',
    (tester) async {
      final checkIns = MemoryCheckInRepository();
      await checkIns.save(
        DailyCheckIn.empty('2026-09-14')
            .withSalahActivity(
              PrayerId.fajr,
              const RecordedActivity(id: 'prayedLate'),
            )
            .withSalahActivity(
              PrayerId.dhuhr,
              const RecordedActivity(id: 'joinedCongregationLate'),
            ),
      );
      await pumpQuickTap(tester, checkIns: checkIns);
      await expandQuickTapDomain(tester, MonitorDomain.salah);

      Color captionColor(String tileId, String caption) {
        return tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(Key('quick-tap-$tileId')),
                matching: find.text(caption),
              ),
            )
            .style!
            .color!;
      }

      Color markColor(String tileId) {
        return tester
            .widget<RecordedStateMarker>(
              find.descendant(
                of: find.byKey(Key('quick-tap-$tileId')),
                matching: find.byType(RecordedStateMarker),
              ),
            )
            .color;
      }

      expect(
        captionColor('salah.fajr', 'Prayed late'),
        MuhasabahColors.recordedLabel,
      );
      expect(markColor('salah.fajr'), SalahActivityMark.prayedLate);
      expect(
        captionColor('salah.dhuhr', 'Joined congregation late'),
        MuhasabahColors.recordedLabel,
      );
      expect(
        markColor('salah.dhuhr'),
        SalahActivityMark.joinedCongregationLate,
      );
    },
  );

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
    tester.takeException();
    await expandQuickTapDomain(tester, MonitorDomain.salah);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byKey(const Key('quick-tap-salah.fajr'))).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('Quick Tap opens the Home domain in view', (tester) async {
    await pumpQuickTap(tester);
    expect(find.byKey(const Key('quick-tap-domain-group')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-quran')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-domain-dhikr')), findsOneWidget);
    expect(find.text('Salah'), findsWidgets);
    expect(find.text('SALAH'), findsNothing);
    expect(
      find.byKey(const Key('quick-tap-domain-tiles-salah')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('quick-tap-domain-tiles-quran')), findsNothing);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    await expandQuickTapDomain(tester, MonitorDomain.quran);
    expect(find.byKey(const Key('quick-tap-domain-tiles-salah')), findsNothing);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsNothing);
    expect(find.byKey(const Key('quick-tap-quran.reading')), findsOneWidget);
  });

  testWidgets('Quick Tap focuses Fasting when Home is on Fasting', (
    tester,
  ) async {
    await pumpQuickTap(
      tester,
      visibleDomains: allVisibleDomains(),
      personalMix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {
          'salah.fajr',
          'quran.reading',
          kFastingWeeklySunnahKey,
          kFastingMonthlyKey,
          kFastingMakeupKey,
        },
      ),
      homeDomain: MonitorDomain.fasting,
    );
    expect(
      find.byKey(const Key('quick-tap-domain-tiles-fasting')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('quick-tap-domain-tiles-salah')), findsNothing);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsNothing);
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
    expect(
      find.byKey(const Key('quick-tap-domain-tiles-salah')),
      findsOneWidget,
    );
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
    final title = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('quick-tap-header')),
        matching: find.text(Copy.quickTapTitle),
      ),
    );
    final busy = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('quick-tap-note-toggle')),
        matching: find.text(Copy.quickTapNoteTitle),
      ),
    );
    expect(title.style?.fontSize, 14);
    expect(busy.style?.fontSize, 14);
    expect(title.style?.fontWeight, busy.style?.fontWeight);
    final titleBox = tester.getRect(
      find.descendant(
        of: find.byKey(const Key('quick-tap-header')),
        matching: find.text(Copy.quickTapTitle),
      ),
    );
    final busyBox = tester.getRect(
      find.byKey(const Key('quick-tap-note-toggle')),
    );
    expect(titleBox.center.dy, closeTo(busyBox.center.dy, 2));
    expect(
      titleBox.left - header.left,
      closeTo(header.right - busyBox.right, 2),
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('quick-tap-next-day')))
          .onPressed,
      isNull,
    );
    await expandQuickTapNote(tester);
    expect(find.text(Copy.quickTapNote), findsOneWidget);
  });

  testWidgets('Quick Tap previous and next day stay on recorded dates', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-13').withSalahActivity(
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

  testWidgets('Time Quick Tap cards show the full practice names', (
    tester,
  ) async {
    await pumpQuickTap(
      tester,
      visibleDomains: {MonitorDomain.time},
      personalMix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {
          'time.t01',
          'time.t02',
          'time.t03',
          'time.t04',
          'time.t05',
          'time.t06',
          'time.t07',
          'time.t08',
        },
      ),
    );
    await expandQuickTapDomain(tester, MonitorDomain.time);
    const labels = [
      'Began with a worthwhile intention',
      'Chose what mattered first',
      'Gave focused attention',
      'Put aside a digital distraction',
      'Took a step on something delayed',
      'Used time for something beneficial',
      'Gave someone needed attention',
      'Took needed rest',
    ];
    for (final label in labels) {
      final title = find.descendant(
        of: find.byKey(Key('quick-tap-domain-tiles-time')),
        matching: find.text(label),
      );
      expect(title, findsOneWidget);
      final text = tester.widget<Text>(title);
      expect(text.maxLines, isNull);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
    }
  });

  testWidgets(
    'Other Adhkar Quick Tap opens the activity list and keeps selections',
    (tester) async {
      final checkIns = MemoryCheckInRepository();
      await checkIns.save(
        DailyCheckIn.empty('2026-09-14')
            .withDhikrContextCaptures('dhikr.generalDhikr', const [
              DhikrContextCapture(
                activityId: 'dhikr.general.tasbih',
                response: DhikrContextResponse.practised,
              ),
            ]),
      );
      await pumpQuickTap(
        tester,
        checkIns: checkIns,
        visibleDomains: {MonitorDomain.dhikr},
        personalMix: mixForKind(
          PersonalMixKind.custom,
          customKeys: {'dhikr.generalDhikr'},
        ),
      );
      await expandQuickTapDomain(tester, MonitorDomain.dhikr);
      await tester.tap(find.byKey(const Key('quick-tap-dhikr.generalDhikr')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.dhikrPerformedHint), findsOneWidget);
      expect(find.text('Add a General Dhikr activity'), findsNothing);
      expect(find.text('SubhanAllah — Tasbih'), findsOneWidget);
      final stored = await checkIns.getByDate('2026-09-14');
      expect(stored?.dhikrContextFor('dhikr.generalDhikr'), hasLength(1));
    },
  );
  testWidgets(
    'post-fard Quick Tap cycles the choice and mark opens the Dhikr list',
    (tester) async {
      final checkIns = MemoryCheckInRepository();
      await pumpQuickTap(
        tester,
        checkIns: checkIns,
        visibleDomains: {MonitorDomain.dhikr},
        personalMix: mixForKind(
          PersonalMixKind.custom,
          customKeys: {'dhikr.postFardFajr'},
        ),
      );
      await expandQuickTapDomain(tester, MonitorDomain.dhikr);
      await tester.tap(find.byKey(const Key('quick-tap-dhikr.postFardFajr')));
      await tester.pumpAndSettle();
      expect(
        (await checkIns.getByDate('2026-09-14'))
            ?.activityFor('dhikr.postFardFajr')
            .id,
        ActivityCatalog.dhikrWithAction,
      );
      expect(find.text(Copy.dhikrPerformedHeading), findsNothing);
      // Finish the cycle so Fajr shows Not recorded.
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('quick-tap-dhikr.postFardFajr')));
        await tester.pumpAndSettle();
      }
      expect(
        find.descendant(
          of: find.byKey(const Key('quick-tap-dhikr.postFardFajr')),
          matching: find.text('Not recorded'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const Key('quick-tap-mark-dhikr.postFardFajr')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Istighfar three times'), findsOneWidget);
      expect(
        find.byKey(const Key('dhikr-legend-dhikr.postFardFajr')),
        findsOneWidget,
      );
    },
  );
}