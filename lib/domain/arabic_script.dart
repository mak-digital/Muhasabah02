enum ArabicScriptFace { system, uthmani, naskh, amiri, scheherazade, lateef }

extension ArabicScriptFaceX on ArabicScriptFace {
  String get id => name;

  String get label => switch (this) {
    ArabicScriptFace.system => 'Device',
    ArabicScriptFace.uthmani => 'Uthmani',
    ArabicScriptFace.naskh => 'Naskh',
    ArabicScriptFace.amiri => 'Amiri',
    ArabicScriptFace.scheherazade => 'Scheherazade',
    ArabicScriptFace.lateef => 'Lateef',
  };

  /// Bundled family, or null to keep the theme face.
  String? get family => switch (this) {
    ArabicScriptFace.system => null,
    ArabicScriptFace.uthmani => 'AmiriQuran',
    ArabicScriptFace.naskh => 'NotoNaskhArabic',
    ArabicScriptFace.amiri => 'Amiri',
    ArabicScriptFace.scheherazade => 'ScheherazadeNew',
    ArabicScriptFace.lateef => 'Lateef',
  };

  static ArabicScriptFace fromId(String? id) {
    return ArabicScriptFace.values
            .where((value) => value.id == id)
            .firstOrNull ??
        ArabicScriptFace.uthmani;
  }
}

const kArabicScriptSizes = [18.0, 22.0, 26.0, 32.0, 40.0];
const kDefaultArabicScriptSize = 26.0;

double clampArabicScriptSize(double size) {
  if (size <= kArabicScriptSizes.first) return kArabicScriptSizes.first;
  if (size >= kArabicScriptSizes.last) return kArabicScriptSizes.last;
  return kArabicScriptSizes.reduce(
    (best, value) => (value - size).abs() < (best - size).abs() ? value : best,
  );
}

double stepArabicScriptSize(double size, int delta) {
  final current = clampArabicScriptSize(size);
  final index = kArabicScriptSizes.indexOf(current);
  final next = (index + delta).clamp(0, kArabicScriptSizes.length - 1);
  return kArabicScriptSizes[next];
}
