enum FirstDayOfWeekPref { monday, sunday, saturday, deviceLocale }

extension FirstDayOfWeekPrefX on FirstDayOfWeekPref {
  String get id => name;

  String get label => switch (this) {
    FirstDayOfWeekPref.monday => 'Monday',
    FirstDayOfWeekPref.sunday => 'Sunday',
    FirstDayOfWeekPref.saturday => 'Saturday',
    FirstDayOfWeekPref.deviceLocale => 'Use Device Locale',
  };

  /// Sunday-based index: 0 = Sunday … 6 = Saturday.
  int sundayBasedIndex(int localeFirstDayIndex) {
    return switch (this) {
      FirstDayOfWeekPref.monday => 1,
      FirstDayOfWeekPref.sunday => 0,
      FirstDayOfWeekPref.saturday => 6,
      FirstDayOfWeekPref.deviceLocale => localeFirstDayIndex.clamp(0, 6),
    };
  }

  static FirstDayOfWeekPref fromId(String? raw) {
    return FirstDayOfWeekPref.values.firstWhere(
      (value) => value.id == raw,
      orElse: () => FirstDayOfWeekPref.monday,
    );
  }
}
