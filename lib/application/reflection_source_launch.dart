import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/reflection_source.dart';

typedef ReflectionUrlLaunch =
    Future<bool> Function(Uri uri, {required LaunchMode mode});

final reflectionUrlLaunchProvider = Provider<ReflectionUrlLaunch>((ref) {
  return (uri, {required mode}) => launchUrl(uri, mode: mode);
});

Future<bool> launchReflectionSource(
  String source,
  ReflectionUrlLaunch launch,
) async {
  for (final uri in reflectionSourceUris(source)) {
    if (await launchReflectionUri(uri, launch)) return true;
  }
  return false;
}

Future<bool> launchReflectionUri(
  Uri uri,
  ReflectionUrlLaunch launch,
) async {
  for (final mode in _launchModesFor(uri)) {
    try {
      if (await launch(uri, mode: mode)) return true;
    } catch (_) {}
  }
  return false;
}

/// Fallback when the person chooses Open in browser from the citation reader.
List<LaunchMode> _launchModesFor(Uri uri) {
  if (uri.host == 'quran.com') {
    return const [
      LaunchMode.externalNonBrowserApplication,
      LaunchMode.externalApplication,
      LaunchMode.inAppBrowserView,
    ];
  }
  return const [
    LaunchMode.inAppBrowserView,
    LaunchMode.externalApplication,
  ];
}
