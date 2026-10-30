import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../domain/app_appearance.dart';
import '../domain/app_language.dart';
import '../domain/copy.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/lock/app_lock_gate.dart';
import '../presentation/shared/app_language_scope.dart';
import '../presentation/shared/current_date_binder.dart';
import '../presentation/shared/hardware_delete_guard.dart';
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
    final appearance = AppAppearanceX.fromPrefIndex(
      ref.watch(themeModePrefProvider),
    );
    final mode = appearance.followSystem
        ? ThemeMode.system
        : appearance.usesDarkSlot
        ? ThemeMode.dark
        : ThemeMode.light;
    final language = ref.watch(appLanguageProvider);
    final locale = language == AppLanguage.bangla
        ? const Locale('bn')
        : const Locale('en');
    return MaterialApp(
      title: Copy.appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scrollBehavior: const MuhasabahScrollBehavior(),
      theme: buildMuhasabahTheme(
        palette: MuhasabahPalette.lightFor(appearance),
      ),
      darkTheme: buildMuhasabahTheme(
        palette: MuhasabahPalette.darkFor(appearance),
      ),
      themeMode: mode,
      builder: (context, child) {
        return AppLanguageScope(
          language: language,
          child: HardwareDeleteGuard(child: child ?? const SizedBox.shrink()),
        );
      },
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
