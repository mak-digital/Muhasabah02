import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../domain/copy.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/lock/app_lock_gate.dart';
import '../presentation/shared/current_date_binder.dart';
import '../presentation/shared/ui_bits.dart';
import 'theme.dart';

class MuhasabahScrollBehavior extends MaterialScrollBehavior {
  const MuhasabahScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}

class MuhasabahApp extends ConsumerWidget {
  const MuhasabahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeIndex = ref.watch(themeModePrefProvider);
    final mode = switch (modeIndex) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp(
      title: Copy.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MuhasabahScrollBehavior(),
      theme: buildMuhasabahTheme(brightness: Brightness.light),
      darkTheme: buildMuhasabahTheme(brightness: Brightness.dark),
      themeMode: mode,
      home: const CurrentDateBinder(child: AppLockGate(child: AppShell())),
      onUnknownRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text(Copy.appName)),
            body: const EmptyState(
              title: Copy.appName,
              message: 'This screen is not available. The rest of the app is still usable.',
            ),
          ),
        );
      },
    );
  }
}
