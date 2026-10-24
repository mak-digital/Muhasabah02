/// On-device preference for which obligatory Salah choices apply.
/// Not a ruling, a score, or a public profile. Default keeps every choice.
enum WorshipListGender { unanswered, female, male, preferNot }

extension WorshipListGenderX on WorshipListGender {
  String get id => name;

  String get label => switch (this) {
    WorshipListGender.unanswered => 'Not recorded',
    WorshipListGender.female => 'Female',
    WorshipListGender.male => 'Male',
    WorshipListGender.preferNot => 'Prefer not to say',
  };

  /// Excused on fard Salah / Jumu‘ah is for days those prayers are not
  /// required (such as hayd or nifas). It stays visible unless Male.
  bool get showsObligatorySalahExcused => this != WorshipListGender.male;

  static WorshipListGender fromId(String? raw) {
    return WorshipListGender.values.firstWhere(
      (value) => value.id == raw,
      orElse: () => WorshipListGender.unanswered,
    );
  }
}
