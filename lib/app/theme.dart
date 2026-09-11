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
  static const mark = salahFamily;
  static const missedEarth = Color(0xFF8A6A62);
  static const salahObligatoryBand = Color(0xFFD2E8E6);
  static const salahFridayBand = Color(0xFFD8E2EE);
  static const salahVoluntaryBand = Color(0xFFDCEEE4);
  static const salahObligatoryBandDark = Color(0xFF2A4546);
  static const salahFridayBandDark = Color(0xFF2C3A4A);
  static const salahVoluntaryBandDark = Color(0xFF2A4438);
  static const quranFamily = Color(0xFF3D6B99);
  static const quranRecitationBand = Color(0xFFCFE0EF);
  static const quranRetentionBand = Color(0xFFD5E4EA);
  static const quranStudyBand = Color(0xFFDCE3F0);
  static const quranRecitationBandDark = Color(0xFF2A3C4C);
  static const quranRetentionBandDark = Color(0xFF2A4046);
  static const quranStudyBandDark = Color(0xFF2C3548);
  static const dhikrFamily = Color(0xFF3F7D6A);
  static const akhlaqFamily = Color(0xFF7A6A55);
  static const huquqFamily = Color(0xFF5A6B52);
  static const knowledgeFamily = Color(0xFF3D5F73);
  static const timeFamily = Color(0xFF7A6848);
  static const healthFamily = Color(0xFF4F7A5A);
  static const wealthFamily = Color(0xFF6B5344);
  static const ummahFamily = Color(0xFF5B6B7A);
  static const familyFamily = Color(0xFF7A5B8F);
  static const charityFamily = Color(0xFFC48A3C);
  static const fastingFamily = Color(0xFF3F4C8A);
  static const hajjFamily = Color(0xFF4A6B52);
  static const hadithFamily = Color(0xFF4A6D8C);

  static const salahWash = Color(0xFFD7ECEB);
  static const quranWash = Color(0xFFD7E4F2);
  static const dhikrWash = Color(0xFFD9EEDF);
  static const akhlaqWash = Color(0xFFE8E0D4);
  static const huquqWash = Color(0xFFE2E8DC);
  static const knowledgeWash = Color(0xFFD5E6EE);
  static const timeWash = Color(0xFFF0E6D2);
  static const healthWash = Color(0xFFDCECDC);
  static const wealthWash = Color(0xFFEDE6DC);
  static const ummahWash = Color(0xFFDDE4EA);
  static const familyWash = Color(0xFFEADFF2);
  static const charityWash = Color(0xFFF4E6C8);
  static const fastingWash = Color(0xFFC5CCEB);
  static const hajjWash = Color(0xFFE2EDE4);
  static const hadithWash = Color(0xFFD4E2EE);
  static const summaryWash = Color(0xFFEEF2F4);
  static const sampleBannerWash = Color(0xFFFFF8E8);
  static const todayMarkWash = Color(0xFFFFF8D6);
  static const todayMarkRing = Color(0xFFF3ECC0);
  static const lunarWhiteDayWash = Color(0xFFFFE38A);
  static const lunarWhiteDayRing = Color(0xFFB8860B);
  static const lunarWhiteDayInk = Color(0xFF5A4300);
  static const lunarWhiteDayWashDark = Color(0xFF7A6218);
  static const lunarWhiteDayRingDark = Color(0xFFE6C34A);
  static const lunarWhiteDayInkDark = Color(0xFFFFF4C8);

  static const salahWashDark = Color(0xFF243F42);
  static const quranWashDark = Color(0xFF24384A);
  static const dhikrWashDark = Color(0xFF243F36);
  static const akhlaqWashDark = Color(0xFF3A342C);
  static const huquqWashDark = Color(0xFF2E382C);
  static const knowledgeWashDark = Color(0xFF243844);
  static const timeWashDark = Color(0xFF3A3224);
  static const healthWashDark = Color(0xFF2A3A2E);
  static const wealthWashDark = Color(0xFF3A3028);
  static const ummahWashDark = Color(0xFF2C3844);
  static const familyWashDark = Color(0xFF3A2C44);
  static const charityWashDark = Color(0xFF433318);
  static const fastingWashDark = Color(0xFF2A3050);
  static const hajjWashDark = Color(0xFF2A3A2E);
  static const hadithWashDark = Color(0xFF2A3848);
  static const summaryWashDark = Color(0xFF2A3336);
  static const sampleBannerWashDark = Color(0xFF3A3424);
  static const todayMarkWashDark = Color(0xFF5A5238);
  static const todayMarkRingDark = Color(0xFF8A8058);

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
    QuranDimension.consciousApplication => application,
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
