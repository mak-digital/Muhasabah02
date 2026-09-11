import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> chooseCheckInOption(
  WidgetTester tester, {
  required Key dropdownKey,
  required String optionLabel,
}) async {
  final field = find.byKey(dropdownKey);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  final option = find.text(optionLabel).hitTestable();
  await tester.tap(option);
  await tester.pumpAndSettle();
}
