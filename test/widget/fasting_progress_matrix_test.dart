import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/display_calendar.dart';

import '../support/test_app.dart';

DateTime _firstWhiteDay() {
  for (var i = 0; i < 40; i++) {
    final date = DateTime(2026, 8, 20).add(Duration(days: i));
    if (isLunarWhiteDay(date)) return date;
  }
  throw StateError('no lunar white day in sample window');
}

void main() {
  testWidgets('Fasting Progress highlights civil Hijri 13 to 15', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final white = _firstWhiteDay();
    await tester.pumpWidget(
      testApp(now: white, visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-fasting')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-fasting')));
    await tester.pumpAndSettle();

    expect(find.text(Copy.lunarWhiteDaysNote), findsOneWidget);
    expect(find.byKey(Key('lunar-white-${dateKey(white)}')), findsWidgets);

    await tester.ensureVisible(find.text('90 days'));
    await tester.tap(find.text('90 days'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('lunar-white-${dateKey(white)}')), findsWidgets);
  });

  testWidgets('Dhikr Progress does not highlight lunar white days', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final white = _firstWhiteDay();
    await tester.pumpWidget(
      testApp(now: white, visibleDomains: allVisibleDomains()),
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
    expect(find.byKey(Key('lunar-white-${dateKey(white)}')), findsNothing);
    expect(find.text(Copy.lunarWhiteDaysNote), findsNothing);
  });
}
