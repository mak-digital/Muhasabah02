enum PrayerId { fajr, dhuhr, asr, maghrib, isha }

enum PrayerStatus { unanswered, onTime, late, missed }

extension PrayerIdX on PrayerId {
  String get jsonKey => name;

  String get label => switch (this) {
    PrayerId.fajr => 'Fajr',
    PrayerId.dhuhr => 'Dhuhr',
    PrayerId.asr => 'Asr',
    PrayerId.maghrib => 'Maghrib',
    PrayerId.isha => 'Isha',
  };

  String get semanticsLabel => label;
}

extension PrayerStatusX on PrayerStatus {
  String get jsonValue => name;

  String get label => switch (this) {
    PrayerStatus.unanswered => 'Not recorded',
    PrayerStatus.onTime => 'Prayed on time',
    PrayerStatus.late => 'Prayed late',
    PrayerStatus.missed => 'Missed',
  };

  bool get isRecorded => this != PrayerStatus.unanswered;

  bool get isDesirable => this == PrayerStatus.onTime;
}

PrayerStatus prayerStatusFromJson(Object? value) {
  if (value is! String) return PrayerStatus.unanswered;
  return PrayerStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => PrayerStatus.unanswered,
  );
}
