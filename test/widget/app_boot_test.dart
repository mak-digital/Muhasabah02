import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/boot.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/registry/registry_screen.dart';
import 'package:muhasabah02/presentation/review/review_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('first frame is the launch hold before records open', (
    tester,
  ) async {
    final opened = Completer<List<Override>>();
    await tester.pumpWidget(MuhasabahBoot(loader: () => opened.future));
    expect(find.byKey(const Key('app-boot-hold')), findsOneWidget);
    expect(find.text(Copy.quickTap), findsNothing);
    opened.complete(const []);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-boot-hold')), findsNothing);
    expect(find.text(Copy.quickTap), findsOneWidget);
  });

  testWidgets(
    'Review and Registry wait until their tab is opened in AppShell',
    (tester) async {
      await tester.pumpWidget(testApp());
      await tester.pumpAndSettle();
      expect(find.byType(ReviewScreen), findsNothing);
      expect(find.byType(RegistryScreen), findsNothing);
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(find.byType(ReviewScreen), findsOneWidget);
      expect(find.byType(RegistryScreen), findsNothing);
    },
  );
}
