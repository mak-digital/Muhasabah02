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
  static const fasting = Color(0xFF3F4C8A);
  static const charity = Color(0xFFC48A3C);
  static const family = Color(0xFF7A5B8F);
  static const hadith = Color(0xFF4A6D8C);
  static const zakat = Color(0xFFB8873A);

  static const salahFamily = Color(0xFF2F6F73);
  static const quranFamily = Color(0xFF3D6B99);
  static const dhikrFamily = Color(0xFF3F7D6A);
  static const familyFamily = Color(0xFF7A5B8F);
  static const charityFamily = Color(0xFFC48A3C);
  static const fastingFamily = Color(0xFF3F4C8A);

  static const salahWash = Color(0xFFD7ECEB);
  static const quranWash = Color(0xFFD7E4F2);
  static const dhikrWash = Color(0xFFD9EEDF);
  static const familyWash = Color(0xFFEADFF2);
  static const charityWash = Color(0xFFF4E6C8);
  static const fastingWash = Color(0xFFC5CCEB);
  static const summaryWash = Color(0xFFEEF2F4);
  static const sampleBannerWash = Color(0xFFFFF8E8);

  static const salahWashDark = Color(0xFF243F42);
  static const quranWashDark = Color(0xFF24384A);
  static const dhikrWashDark = Color(0xFF243F36);
  static const familyWashDark = Color(0xFF3A2C44);
  static const charityWashDark = Color(0xFF433318);
  static const fastingWashDark = Color(0xFF2A3050);
  static const summaryWashDark = Color(0xFF2A3336);
  static const sampleBannerWashDark = Color(0xFF3A3424);

  static Color wash(Color light, Color dark, Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

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
    scaffoldBackgroundColor: isDark ? scheme.surface : const Color(0xFFF4F1EA),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF4F1EA),
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
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
