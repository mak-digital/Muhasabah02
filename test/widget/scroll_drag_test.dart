import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('check-in list scrolls when dragging from a dropdown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    await tester.drag(
      find.byKey(const Key('salah-fajr')),
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('home list scrolls past the first card', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 6)));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('home-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(find.byKey(const Key('home-scroll')).hitTestable(), findsOneWidget);

    await tester.drag(
      find.descendant(
        of: find.byKey(const Key('home-scroll')),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('Input page hosts the folder tabs', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 6)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-check-in')), findsNothing);

    await openInputTab(tester);
    expect(find.text(Copy.inputTitle), findsWidgets);
    expect(find.byKey(const Key('home-check-in')).hitTestable(), findsOneWidget);
    expect(
      find.byKey(const Key('today-active-domain-mix')).hitTestable(),
      findsOneWidget,
    );
  });
}
