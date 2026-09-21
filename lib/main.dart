import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'app/app.dart';
import 'application/providers.dart';
import 'data/hive_repositories.dart';
import 'data/privacy_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = <Override>[];
  try {
    final opened = await openHiveRepositories();
    overrides.add(checkInRepositoryProvider.overrideWithValue(opened.checkIns));
    overrides.add(
      responseRepositoryProvider.overrideWithValue(opened.responses),
    );
    overrides.add(appPrefsProvider.overrideWithValue(opened.prefs));
    logAppEvent('persistence_ready');
  } catch (_) {
    logAppEvent('persistence_fallback_memory');
  }
  runApp(ProviderScope(overrides: overrides, child: const MuhasabahApp()));
}
