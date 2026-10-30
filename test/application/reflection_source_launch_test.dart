import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/reflection_source_launch.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  test('Open in browser tries a Qur’an app before a generic browser', () async {
    final modes = <LaunchMode>[];
    await launchReflectionSource('Qur’an 2:183', (uri, {required mode}) async {
      modes.add(mode);
      return false;
    });
    expect(modes.first, LaunchMode.externalNonBrowserApplication);
    expect(modes, contains(LaunchMode.externalApplication));
    expect(modes.last, LaunchMode.inAppBrowserView);
  });
}
