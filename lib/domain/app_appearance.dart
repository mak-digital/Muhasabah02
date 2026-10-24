/// Named paper/ink looks. Not a score, rank, or worship grade.
/// System follows the device. Activity mark colours stay observational.
enum AppAppearance { system, light, dark, warmPaper, quietSlate, midnight }

extension AppAppearanceX on AppAppearance {
  String get id => name;

  /// Stable int used by the session theme provider. 0–2 stay System/Light/Dark.
  int get prefIndex => index;

  String get label => switch (this) {
    AppAppearance.system => 'System',
    AppAppearance.light => 'Light',
    AppAppearance.dark => 'Dark',
    AppAppearance.warmPaper => 'Warm paper',
    AppAppearance.quietSlate => 'Quiet slate',
    AppAppearance.midnight => 'Midnight',
  };

  bool get followSystem => this == AppAppearance.system;

  bool get usesDarkSlot =>
      this == AppAppearance.dark || this == AppAppearance.midnight;

  static AppAppearance fromId(String? raw) {
    return AppAppearance.values.firstWhere(
      (value) => value.id == raw,
      orElse: () => AppAppearance.system,
    );
  }

  static AppAppearance fromPrefIndex(int index) {
    if (index < 0 || index >= AppAppearance.values.length) {
      return AppAppearance.system;
    }
    return AppAppearance.values[index];
  }
}
