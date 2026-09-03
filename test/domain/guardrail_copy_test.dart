import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';

void main() {
  test('legacy recommendation copy is not part of product strings', () {
    const blob =
        '${Copy.appName}${Copy.homeCheckIn}${Copy.ponderPrompt}${Copy.myResponseDescription}';
    expect(blob.toLowerCase(), isNot(contains('you should')));
    expect(blob.toLowerCase(), isNot(contains('for the coming days')));
    expect(blob.toLowerCase(), isNot(contains('iman')));
    expect(blob.toLowerCase(), isNot(contains('taqwa')));
  });
}
