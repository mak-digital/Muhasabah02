enum AppLanguage { english, bangla }

extension AppLanguageX on AppLanguage {
  String get id => switch (this) {
    AppLanguage.english => 'en',
    AppLanguage.bangla => 'bn',
  };

  String get endonym => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.bangla => 'বাংলা',
  };

  static AppLanguage fromId(String? raw) => switch (raw) {
    'bn' => AppLanguage.bangla,
    _ => AppLanguage.english,
  };
}
