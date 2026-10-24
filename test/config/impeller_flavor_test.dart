import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Impeller is disabled for Android debug and release', () {
    for (final path in [
      'android/app/src/debug/AndroidManifest.xml',
      'android/app/src/main/AndroidManifest.xml',
    ]) {
      final xml = File(path).readAsStringSync();
      expect(
        xml.contains('io.flutter.embedding.android.EnableImpeller'),
        isTrue,
        reason: path,
      );
      expect(xml.contains('android:value="false"'), isTrue, reason: path);
    }
  });
}
