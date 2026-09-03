import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('app loads', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
