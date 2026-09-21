import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/progress/optional_domain_progress_screen.dart';

import '../support/test_app.dart';

const _homeWeekRange = '31 Aug – 6 Sep';

void main() {
  testWidgets('Dhikr 7-day Progress uses week matrices', (tester) async {
    tester.view.physicalSize = const Size(520, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-dhikr')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-dhikr')));
    await tester.pumpAndSettle();

    expect(find.text('POST-FARD SALAH ADHKAR'), findsOneWidget);
    expect(find.text(_homeWeekRange), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
    expect(find.text('Faj'), findsNothing);
    expect(find.text('Dhr'), findsNothing);
    expect(find.text('Isa'), findsNothing);
    expect(find.text('MORNING & EVENING ADHKAR'), findsOneWidget);
    expect(find.text('Morning Adhkar'), findsOneWidget);
    expect(find.text('Evening Adhkar'), findsOneWidget);
    expect(find.text('Mor-Adk'), findsNothing);
    expect(find.text('Eve-Adk'), findsNothing);
    expect(find.text('OTHER ADHKAR'), findsOneWidget);
    expect(find.text('Personal'), findsWidgets);
    expect(find.text('Other Adhkars'), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.byTooltip('Previous period'), findsWidgets);
    expect(find.byTooltip('Next period'), findsWidgets);
    expect(find.byKey(const Key('week-matrix-today-2026-09-06')), findsWidgets);
    expect(find.text('31'), findsWidgets);
    expect(find.text('6'), findsWidgets);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Faj'), findsNothing);

    await tester.ensureVisible(find.text('90 days'));
    await tester.tap(find.text('90 days'));
    await tester.pumpAndSettle();
    expect(find.text('Jun'), findsWidgets);
    expect(find.byTooltip('Previous period'), findsWidgets);
    expect(find.byKey(const Key('calendar-today-2026-09-06')), findsWidgets);
  });

  testWidgets('Hadith 7-day Progress uses item-row matrices', (tester) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-domain-hadith')));
    await tester.pumpAndSettle();

    expect(find.text('ENCOUNTER'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Listening'), findsOneWidget);
    expect(find.text('RETENTION'), findsOneWidget);
    expect(find.text('Memorisation'), findsOneWidget);
    expect(find.text('Revision'), findsOneWidget);
    expect(find.text('LEARNING'), findsOneWidget);
    expect(find.text('Study Circle'), findsOneWidget);
    expect(find.text('Teaching / Discussion'), findsOneWidget);
    expect(find.text('Hadith Reflection'), findsOneWidget);
    expect(find.text('Noticed a sunnah in how I lived today'), findsOneWidget);
    expect(find.text('Read'), findsNothing);
    expect(find.text('Listen'), findsNothing);
    expect(find.text('Memorise'), findsNothing);
    expect(find.text('Lived'), findsNothing);
    expect(find.text(_homeWeekRange), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Read'), findsNothing);
  });

  testWidgets('Akhlaq 7-day Progress uses item-row matrices', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-akhlaq')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-akhlaq')));
    await tester.pumpAndSettle();

    expect(find.text('VIRTUES I NOTICED'), findsOneWidget);
    expect(find.text('Patience'), findsOneWidget);
    expect(find.text('Truthfulness'), findsOneWidget);
    expect(find.text('Thankfulness in how I acted'), findsOneWidget);
    expect(find.text('Guarded my gaze'), findsOneWidget);
    expect(
      find.text('Held back from a habit I am trying to leave'),
      findsOneWidget,
    );
    expect(find.text('Truth'), findsNothing);
    expect(find.text('Thanks'), findsNothing);
    expect(find.text('Gaze'), findsNothing);
    expect(find.text('Habit'), findsNothing);
    expect(find.text(_homeWeekRange), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Patience'), findsOneWidget);
    expect(find.text('Virtues I noticed'), findsWidgets);
    expect(find.text('Truth'), findsNothing);
    expect(find.text('Thanks'), findsNothing);
  });

  testWidgets('Huquq 7-day Progress uses item-row matrices', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-huquq')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-huquq')));
    await tester.pumpAndSettle();
    expect(find.byType(OptionalDomainProgressScreen), findsOneWidget);
    expect(
      find.byKey(
        const Key('week-matrix-prev-Rights of Others (Huquq al-Ibad)'),
      ),
      findsOneWidget,
    );
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Other relatives'), findsOneWidget);
    expect(find.text('Colleagues & friends'), findsOneWidget);
    expect(find.text('Fellow Muslims'), findsOneWidget);
    expect(find.text('A step toward reconciliation'), findsOneWidget);
    expect(find.text('CARE IN HARDSHIP'), findsOneWidget);
    expect(find.text('Sick Visit'), findsOneWidget);
    expect(find.text('Sick Contact'), findsOneWidget);
    expect(find.text('Support Under Stress'), findsOneWidget);
    expect(find.text('Relatives'), findsNothing);
    expect(find.text('Friends'), findsNothing);
    expect(find.text('Muslims'), findsNothing);
    expect(find.text('Sulh'), findsNothing);
    expect(find.text('Visit'), findsNothing);
    expect(find.text('Parent Contact'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.text(_homeWeekRange), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Household'), findsWidgets);
    expect(find.text('Relatives'), findsNothing);
    expect(find.text('Sulh'), findsNothing);
  });

  testWidgets('Knowledge 7-day Progress uses item-row matrices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-knowledge')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-knowledge')));
    await tester.pumpAndSettle();

    expect(find.text('SEEKING TRUTH'), findsOneWidget);
    expect(find.text('Learned something true'), findsOneWidget);
    expect(
      find.text('Beneficial reading (not Qur’an or Hadith)'),
      findsOneWidget,
    );
    expect(find.text('Asked to remove ignorance'), findsOneWidget);
    expect(find.text('SHARING'), findsOneWidget);
    expect(find.text('Taught someone'), findsOneWidget);
    expect(find.text('Sincere advice'), findsOneWidget);
    expect(find.text('Wrote or created something beneficial'), findsOneWidget);
    expect(find.text('BENEFICIAL SPEECH'), findsOneWidget);
    expect(find.text('Held back useless speech'), findsOneWidget);
    expect(find.text('Learned'), findsNothing);
    expect(find.text('Reading'), findsNothing);
    expect(find.text('Asked'), findsNothing);
    expect(find.text('Taught'), findsNothing);
    expect(find.text('Advice'), findsNothing);
    expect(find.text('Created'), findsNothing);
    expect(find.text('Restraint'), findsNothing);
    expect(find.text(_homeWeekRange), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Learned something true'), findsOneWidget);
    expect(find.text('Seeking truth'), findsWidgets);
    expect(find.text('Learned'), findsNothing);
    expect(find.text('Created'), findsNothing);
  });

  testWidgets('Time through Hajj 7-day Progress uses item-row matrices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    Future<void> openProgress(Key tileKey) async {
      await tester.scrollUntilVisible(
        find.byKey(tileKey),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(tileKey));
      await tester.pumpAndSettle();
    }

    await openProgress(const Key('review-domain-time'));
    expect(find.text(_homeWeekRange), findsOneWidget);
    expect(find.text('Present in what I was doing'), findsOneWidget);
    expect(find.text('Did something I had delayed'), findsOneWidget);
    expect(find.text('Began with intention'), findsOneWidget);
    expect(find.text('Present'), findsNothing);
    expect(find.text('Delayed'), findsNothing);
    expect(find.text('Intention'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openProgress(const Key('review-domain-health'));
    expect(find.text('Sleep quality'), findsOneWidget);
    expect(find.text('Sought care in illness'), findsOneWidget);
    expect(find.text('Quality'), findsNothing);
    expect(find.text('Illness'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openProgress(const Key('review-domain-wealth'));
    expect(find.text('Earned from a halal source'), findsOneWidget);
    expect(find.text('Stayed clear of riba'), findsOneWidget);
    expect(find.text('Halal'), findsNothing);
    expect(find.text('Riba'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openProgress(const Key('review-domain-ummah'));
    expect(
      find.text('Masjid class or gathering (not the fard)'),
      findsOneWidget,
    );
    expect(find.text('Da’wah by character'), findsOneWidget);
    expect(find.text('Prayed for the Ummah'), findsOneWidget);
    expect(find.text('Oppressed'), findsNothing);
    expect(find.text('Dua'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openProgress(const Key('review-domain-fasting'));
    expect(find.text('Weekly Sunnah Fast'), findsOneWidget);
    expect(find.text('White Days (Ayyam Al-Bid)'), findsOneWidget);
    expect(find.text('Make-up Fast'), findsOneWidget);
    expect(find.text('Sunnah'), findsNothing);
    expect(find.text('Ramadan'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openProgress(const Key('review-domain-hajj'));
    expect(find.text('Noticed preparation'), findsOneWidget);
    expect(find.text('Prep'), findsNothing);
  });

  testWidgets('Salah 7-day Progress uses prayer-row matrices', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-domain-salah')));
    await tester.pumpAndSettle();

    expect(find.text('Obligatory Salah'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
    expect(find.text('Faj'), findsNothing);
    expect(find.text('Isa'), findsNothing);
    expect(find.text('Friday Prayer'), findsOneWidget);
    expect(find.text('Jumu‘ah'), findsOneWidget);
    expect(find.text('Voluntary Prayers'), findsOneWidget);
    expect(find.text('Tahajjud'), findsOneWidget);
    expect(find.text('Ishraq'), findsOneWidget);
    expect(find.text('(for the week starting on 31 Aug 2026)'), findsWidgets);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Faj'), findsNothing);
    expect(find.text('Jumu‘ah'), findsOneWidget);
    expect(find.text('Tahajjud'), findsOneWidget);
    expect(find.text('Ishraq'), findsOneWidget);
    expect(find.text('Friday Prayer'), findsOneWidget);
    expect(find.text('Voluntary Prayers'), findsNWidgets(2));
  });

  testWidgets('Qur’an 7-day Progress uses Journey matrix', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-domain-quran')));
    await tester.pumpAndSettle();

    expect(find.text(Copy.quranJourney), findsOneWidget);
    expect(find.text('Practical relevance'), findsOneWidget);
    expect(find.text('Reflection'), findsOneWidget);
    expect(find.text('Understanding'), findsOneWidget);
    expect(find.text('Engagement'), findsOneWidget);
    expect(find.text('Transformation'), findsNothing);
    expect(find.text('Engagement with Qur’an'), findsOneWidget);
    expect(find.text('Recite'), findsNothing);
    expect(find.text('Retention'), findsNothing);
    expect(find.text('Study & notice'), findsNothing);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Engagement'), findsWidgets);
    expect(find.text('Engagement with Qur’an · Recitation'), findsOneWidget);
    expect(
      find.text('Activities supporting understanding · Meaning'),
      findsOneWidget,
    );
    expect(find.text('Recitation with Meaning'), findsNothing);
    expect(find.text('Practical relevance'), findsOneWidget);
    expect(find.text('Noticed in daily life'), findsOneWidget);
    expect(find.text('Reflection'), findsOneWidget);
    expect(find.text('Reflection on meaning'), findsOneWidget);
    expect(find.text('Conscious Application'), findsNothing);
    expect(find.text('Qur’anic Reflection'), findsNothing);
    expect(find.text(Copy.quranJourney), findsNothing);
  });

  testWidgets('Salah and Qur’an Progress cells open focused check-in', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-domain-salah')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('progress-cell-salah-fajr-2026-09-06')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} · 6 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('review-domain-quran')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('progress-cell-quran-applied-2026-09-06')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(
      find.text('Practical relevance — Noticed in daily life'),
      findsOneWidget,
    );
    expect(find.text(Copy.quranDayUnanswered), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.byKey(const Key('quran-journey-l1-stage')));
    await tester.pumpAndSettle();
    expect(find.text('W = Connected to worship'), findsOneWidget);
  });

  testWidgets('7-day matrix opens focused check-in and keeps future inactive', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 4), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-dhikr')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-dhikr')));
    await tester.pumpAndSettle();

    expect(find.text(_homeWeekRange), findsOneWidget);
    expect(find.byKey(const Key('week-matrix-today-2026-09-04')), findsWidgets);

    await tester.tap(
      find.byKey(const Key('progress-cell-dhikr.postFardFajr-2026-09-04')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.dhikr.label} · 4 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(find.text(Copy.edit), findsNothing);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('Morning Adhkar'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('progress-cell-dhikr.postFardFajr-2026-09-03')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.dhikr.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text(Copy.edit), findsWidgets);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text(Copy.edit).last);
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('week-matrix-next-Dhikr & Dua')));
    await tester.pumpAndSettle();
    expect(find.text('7 Sep – 13 Sep'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('progress-cell-dhikr.postFardFajr-2026-09-07')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('What happened?'), findsNothing);
    expect(find.byType(CheckInScreen), findsNothing);

    final next = tester.widget<IconButton>(
      find.byKey(const Key('week-matrix-next-Dhikr & Dua')),
    );
    expect(next.onPressed, isNull);
  });
}
