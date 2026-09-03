import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'application/providers.dart';
import 'data/hive_repositories.dart';
import 'data/privacy_log.dart';
import 'debug/synthetic_check_in_seeder.dart';

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
    await ensureFirstInstallSampleData(
      checkIns: opened.checkIns,
      responses: opened.responses,
      prefs: opened.prefs,
      now: DateTime.now(),
    );
    logAppEvent('persistence_ready');
  } catch (_) {
    logAppEvent('persistence_fallback_memory');
  }
  runApp(ProviderScope(overrides: overrides, child: const MuhasabahApp()));
}
