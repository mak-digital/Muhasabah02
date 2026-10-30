import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> chooseCheckInOption(
  WidgetTester tester, {
  required Key dropdownKey,
  required String optionLabel,
}) async {
  final field = find.byKey(dropdownKey);
  // Anchored Active Domain menus open the full list on the row tap; there is
  // no closed dropdown to open first.
  if (field.evaluate().isNotEmpty) {
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
  }
  final option = find.text(optionLabel).hitTestable();
  await tester.tap(option);
  await tester.pumpAndSettle();
}
