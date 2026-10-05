import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets(
    'settings can hide Fasting while keeping its records unused on Home',
    (tester) async {
      tester.view.physicalSize = const Size(400, 12200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
      await tester.pumpAndSettle();
      expect(find.text('Weekly Sunnah Fast'), findsNothing);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(Copy.visibleDomains));
      await tester.tap(find.text(Copy.visibleDomains));
      await tester.pumpAndSettle();
      expect(find.byType(VisibleDomainsSettingsScreen), findsOneWidget);
      expect(find.text(Copy.shownDomainsNote), findsOneWidget);
      expect(find.text(Copy.thisSeasonsMix), findsOneWidget);
      expect(find.text(Copy.mixNotShownInDomains), findsOneWidget);
      expect(find.text(Copy.basicDhikrDomains), findsOneWidget);
      expect(find.text('Fasting'), findsWidgets);
      final fastingTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-fasting')),
      );
      expect(fastingTile.value, isFalse);
      final salahTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-salah')),
      );
      expect(salahTile.value, isTrue);
      final akhlaqTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-akhlaq')),
      );
      expect(akhlaqTile.value, isFalse);
      final huquqTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-huquq')),
      );
      expect(huquqTile.value, isFalse);
      final knowledgeTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-knowledge')),
      );
      expect(knowledgeTile.value, isFalse);
      final timeTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-time')),
      );
      expect(timeTile.value, isFalse);
      final healthTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-health')),
      );
      expect(healthTile.value, isFalse);
      final wealthTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-wealth')),
      );
      expect(wealthTile.value, isFalse);
      final ummahTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-ummah')),
      );
      expect(ummahTile.value, isFalse);
      expect(find.text('Family & Community Care'), findsNothing);
      final hadithTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-hadith')),
      );
      expect(hadithTile.value, isFalse);
      final charityTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-charity')),
      );
      expect(charityTile.value, isFalse);
      final dhikrTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-dhikr')),
      );
      expect(dhikrTile.value, isTrue);
      final hajjTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('domain-visible-hajj')),
      );
      expect(hajjTile.value, isFalse);
      await tester.tap(find.text(Copy.selectAllDomains));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckboxListTile>(
              find.byKey(const Key('domain-visible-fasting')),
            )
            .value,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('domain-visible-fasting')));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(VisibleDomainsSettingsScreen)))
          .pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text(Copy.settingsTitle))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Weekly Sunnah Fast'), findsNothing);
      expect(find.text(MonitorDomain.salah.label), findsWidgets);
      expect(find.text(Copy.homeCheckIn), findsOneWidget);
    },
  );

  testWidgets('Review hides progress for a hidden domain', (tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 6),
        visibleDomains: {MonitorDomain.salah, MonitorDomain.dhikr},
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('review-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('review-domain-dhikr')), findsOneWidget);
    expect(find.byKey(const Key('review-domain-fasting')), findsNothing);
    expect(find.byKey(const Key('review-domain-quran')), findsNothing);
  });
}
