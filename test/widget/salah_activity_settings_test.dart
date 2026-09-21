import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('Settings Activities can turn on Salah activity colours', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.activitiesTitle));
    await tester.tap(find.text(Copy.activitiesTitle));
    await tester.pumpAndSettle();
    expect(find.text(Copy.activitiesNote), findsOneWidget);
    expect(find.text(Copy.salahMarkShared), findsWidgets);
    expect(find.text('Excused'), findsWidgets);
    expect(find.textContaining('Excellent'), findsNothing);
    expect(find.textContaining('Urgent'), findsNothing);

    await tester.tap(find.text(Copy.salahMarkActivityColours));
    await tester.pumpAndSettle();
    expect(find.text(Copy.salahMarkActivityNote), findsOneWidget);
    expect(
      find.text(ActivityCatalog.salah.first.label),
      findsWidgets,
    );
    expect(find.text(Copy.quranJourney), findsOneWidget);
    expect(find.textContaining('Applied'), findsWidgets);
  });
}
