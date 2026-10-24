import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../domain/app_appearance.dart';
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

  /// Readable ink for recorded choice labels. Activity colour stays on the mark.
  static const recordedLabel = Color(0xFF1565C0);
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
  static const productivityFamily = Color(0xFF4A6A7A);

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
  static const productivityWash = Color(0xFFDCE6EC);
  static const summaryWash = Color(0xFFEEF2F4);

  /// Shared Learn & Practice panel. Not a domain family and not a grade.
  static const practiceWash = Color(0xFFE4E0EC);
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
  static const productivityWashDark = Color(0xFF2A3844);
  static const summaryWashDark = Color(0xFF2A3336);
  static const practiceWashDark = Color(0xFF322E3C);
  static const sampleBannerWashDark = Color(0xFF3A3424);
  static const todayMarkWashDark = Color(0xFF5A5238);
  static const todayMarkRingDark = Color(0xFF8A8058);

  static Color wash(
    Color light,
    Color dark,
    Brightness brightness, [
    BuildContext? context,
  ]) {
    final base = brightness == Brightness.dark ? dark : light;
    return MuhasabahWashTheme.harmonizeOf(context, base);
  }

  /// Paper-harmonized wash when a [BuildContext] is available.
  static Color themeWash(BuildContext context, Color light, Color dark) {
    return wash(light, dark, Theme.of(context).brightness, context);
  }

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

/// Paper, ink seed, and cards for one named look. Domain washes are blended
/// toward this paper. Salah activity mark colours are not retinted.
class MuhasabahPalette {
  const MuhasabahPalette({
    required this.brightness,
    required this.seed,
    required this.surface,
    required this.card,
    this.lockCard = true,
    this.washBlend = 0,
    this.familyBlend = 0,
    this.containerBlend = 0,
  });

  final Brightness brightness;
  final Color seed;
  final Color surface;
  final Color card;

  /// When false, dark Material container colour is kept (current Dark).
  final bool lockCard;

  /// How far domain washes move toward [surface]. 0 keeps the Light/Dark set.
  final double washBlend;

  /// How far domain family ink moves toward [seed].
  final double familyBlend;

  /// How far Material containers move toward [surface].
  final double containerBlend;

  static const light = MuhasabahPalette(
    brightness: Brightness.light,
    seed: Color(0xFF2F6F73),
    surface: Color(0xFFF4F1EA),
    card: Color(0xFFFFFCF8),
  );

  static const dark = MuhasabahPalette(
    brightness: Brightness.dark,
    seed: Color(0xFF2F6F73),
    surface: Color(0xFF141C1D),
    card: Color(0xFF1E2829),
    lockCard: false,
  );

  static const warmPaper = MuhasabahPalette(
    brightness: Brightness.light,
    seed: Color(0xFF8A5A28),
    surface: Color(0xFFF6EAD6),
    card: Color(0xFFFFF6E8),
    washBlend: 0.58,
    familyBlend: 0.42,
    containerBlend: 0.28,
  );

  static const quietSlate = MuhasabahPalette(
    brightness: Brightness.light,
    seed: Color(0xFF2C5D72),
    surface: Color(0xFFE7EEF2),
    card: Color(0xFFF7FBFD),
    washBlend: 0.38,
    familyBlend: 0.28,
    containerBlend: 0.18,
  );

  static const midnight = MuhasabahPalette(
    brightness: Brightness.dark,
    seed: Color(0xFF7EB8C4),
    surface: Color(0xFF0D1524),
    card: Color(0xFF172235),
    washBlend: 0.42,
    familyBlend: 0.22,
    containerBlend: 0.22,
  );

  static MuhasabahPalette lightFor(AppAppearance appearance) =>
      switch (appearance) {
        AppAppearance.warmPaper => warmPaper,
        AppAppearance.quietSlate => quietSlate,
        _ => light,
      };

  static MuhasabahPalette darkFor(AppAppearance appearance) =>
      switch (appearance) {
        AppAppearance.midnight => midnight,
        _ => dark,
      };
}

/// Blends domain washes and family ink toward the selected paper.
class MuhasabahWashTheme extends ThemeExtension<MuhasabahWashTheme> {
  const MuhasabahWashTheme({
    required this.paper,
    required this.seed,
    required this.washBlend,
    required this.familyBlend,
  });

  final Color paper;
  final Color seed;
  final double washBlend;
  final double familyBlend;

  factory MuhasabahWashTheme.fromPalette(MuhasabahPalette palette) {
    return MuhasabahWashTheme(
      paper: palette.surface,
      seed: palette.seed,
      washBlend: palette.washBlend,
      familyBlend: palette.familyBlend,
    );
  }

  static Color harmonizeOf(BuildContext? context, Color color) {
    if (context == null) return color;
    final theme = Theme.of(context).extension<MuhasabahWashTheme>();
    return theme?.harmonize(color) ?? color;
  }

  static Color harmonizeFamilyOf(BuildContext? context, Color family) {
    if (context == null) return family;
    final theme = Theme.of(context).extension<MuhasabahWashTheme>();
    return theme?.harmonizeFamily(family) ?? family;
  }

  Color harmonize(Color wash) {
    if (washBlend <= 0) return wash;
    return Color.lerp(wash, paper, washBlend) ?? wash;
  }

  Color harmonizeFamily(Color family) {
    if (familyBlend <= 0) return family;
    return Color.lerp(family, seed, familyBlend) ?? family;
  }

  @override
  MuhasabahWashTheme copyWith({
    Color? paper,
    Color? seed,
    double? washBlend,
    double? familyBlend,
  }) {
    return MuhasabahWashTheme(
      paper: paper ?? this.paper,
      seed: seed ?? this.seed,
      washBlend: washBlend ?? this.washBlend,
      familyBlend: familyBlend ?? this.familyBlend,
    );
  }

  @override
  MuhasabahWashTheme lerp(ThemeExtension<MuhasabahWashTheme>? other, double t) {
    if (other is! MuhasabahWashTheme) return this;
    return MuhasabahWashTheme(
      paper: Color.lerp(paper, other.paper, t) ?? paper,
      seed: Color.lerp(seed, other.seed, t) ?? seed,
      washBlend: lerpDouble(washBlend, other.washBlend, t) ?? washBlend,
      familyBlend: lerpDouble(familyBlend, other.familyBlend, t) ?? familyBlend,
    );
  }
}

ThemeData buildMuhasabahTheme({
  Brightness? brightness,
  MuhasabahPalette? palette,
}) {
  final resolved =
      palette ??
      ((brightness ?? Brightness.light) == Brightness.dark
          ? MuhasabahPalette.dark
          : MuhasabahPalette.light);
  final isDark = resolved.brightness == Brightness.dark;
  var scheme = ColorScheme.fromSeed(
    seedColor: resolved.seed,
    brightness: resolved.brightness,
    surface: resolved.surface,
  );
  if (resolved.containerBlend > 0) {
    scheme = scheme.copyWith(
      primaryContainer: Color.lerp(
        scheme.primaryContainer,
        resolved.surface,
        resolved.containerBlend,
      ),
      secondaryContainer: Color.lerp(
        scheme.secondaryContainer,
        resolved.surface,
        resolved.containerBlend,
      ),
    );
  }
  final canvas = resolved.surface;
  final card = (!resolved.lockCard && isDark)
      ? scheme.surfaceContainerLow
      : resolved.card;
  final radius = BorderRadius.circular(18);
  final text = Typography.englishLike2021
      .merge(
        isDark ? Typography.whiteMountainView : Typography.blackMountainView,
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [MuhasabahWashTheme.fromPalette(resolved)],
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: canvas,
    canvasColor: canvas,
    splashFactory: InkSparkle.splashFactory,
    textTheme: text.copyWith(
      headlineSmall: text.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      titleSmall: text.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: text.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: text.bodyMedium?.copyWith(height: 1.45),
      bodySmall: text.bodySmall?.copyWith(height: 1.4),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: canvas,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: card,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 74,
      elevation: 0,
      backgroundColor: canvas,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          letterSpacing: 0.1,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: text.labelLarge,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.7),
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      titleTextStyle: text.titleSmall?.copyWith(color: scheme.onSurface),
      subtitleTextStyle: text.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.35,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? scheme.surfaceContainerHighest : resolved.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
