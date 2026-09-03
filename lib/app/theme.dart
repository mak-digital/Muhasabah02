import 'package:flutter/material.dart';

import '../domain/prayer.dart';
import '../domain/quran.dart';

class MuhasabahColors {
  static const fajr = Color(0xFF5B6ABF);
  static const dhuhr = Color(0xFFC49A3C);
  static const asr = Color(0xFFD17A45);
  static const maghrib = Color(0xFFB85C6E);
  static const isha = Color(0xFF6A5B8F);

  static const reading = Color(0xFF2F6F73);
  static const meaning = Color(0xFF3D6B99);
  static const memorisation = Color(0xFF5A7A9A);
  static const revision = Color(0xFF4F7C6B);
  static const tafsir = Color(0xFF6B6A8D);
  static const reflection = Color(0xFF7A6580);
  static const application = Color(0xFF5E7380);

  static const dhikr = Color(0xFF3F7D6A);
  static const conduct = Color(0xFF7A6A55);
  static const gratitude = Color(0xFF8A7048);
  static const journal = Color(0xFF5C6E7A);

  static Color prayer(PrayerId id) => switch (id) {
    PrayerId.fajr => fajr,
    PrayerId.dhuhr => dhuhr,
    PrayerId.asr => asr,
    PrayerId.maghrib => maghrib,
    PrayerId.isha => isha,
  };

  static Color quran(QuranDimension dimension) => switch (dimension) {
    QuranDimension.reading => reading,
    QuranDimension.meaning => meaning,
    QuranDimension.memorisation => memorisation,
    QuranDimension.revision => revision,
    QuranDimension.tafsir => tafsir,
    QuranDimension.reflection => reflection,
    QuranDimension.applicationReflection => application,
  };
}

ThemeData buildMuhasabahTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F6F73),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? scheme.surfaceContainerHighest : scheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
