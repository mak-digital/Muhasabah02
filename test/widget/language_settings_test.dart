import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/domain/app_language.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/settings/language_settings_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets(
    'language screen lists Bangla wording and switches the home tab',
    (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final prefs = MemoryAppPrefs();
      await tester.pumpWidget(testApp(prefs: prefs));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(Copy.language));
      await tester.tap(find.text(Copy.language));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSettingsScreen), findsOneWidget);
      expect(find.text(Copy.languageReviewHeading), findsOneWidget);
      expect(find.text('প্রাইভেট মুহাসাবা'), findsWidgets);
      expect(prefs.appLanguage, AppLanguage.english);

      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();
      expect(prefs.appLanguage, AppLanguage.bangla);

      Navigator.of(tester.element(find.byType(LanguageSettingsScreen))).pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();
      expect(find.text('মূলপাতা'), findsOneWidget);
    },
  );
}
