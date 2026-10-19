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
    overrides.add(
      domainActionRepositoryProvider.overrideWithValue(opened.domainActions),
    );
    overrides.add(
      devFeedbackRepositoryProvider.overrideWithValue(opened.devFeedback),
    );
    overrides.add(
      practiceHadithRepositoryProvider.overrideWithValue(opened.practiceHadith),
    );
    overrides.add(
      personalQuranVerseRepositoryProvider.overrideWithValue(
        opened.personalQuran,
      ),
    );
    overrides.add(
      personalHadithRepositoryProvider.overrideWithValue(opened.personalHadith),
    );
    overrides.add(appPrefsProvider.overrideWithValue(opened.prefs));
    overrides.add(hajjStoreRepositoryProvider.overrideWithValue(opened.hajj));
    overrides.add(
      productivityStoreRepositoryProvider.overrideWithValue(
        opened.productivity,
      ),
    );
    logAppEvent('persistence_ready');
  } catch (_) {
    logAppEvent('persistence_fallback_memory');
  }
  runApp(ProviderScope(overrides: overrides, child: const MuhasabahApp()));
}
