import 'date_key.dart';
import 'prayer.dart';
import 'quran.dart';

enum SalahTraceRow {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
  jumuah,
  tahajjud,
  ishraq,
  tawbah,
}

extension SalahTraceRowX on SalahTraceRow {
  String get id => name;

  String get label => switch (this) {
    SalahTraceRow.fajr => 'Fajr',
    SalahTraceRow.dhuhr => 'Dhuhr',
    SalahTraceRow.asr => 'Asr',
    SalahTraceRow.maghrib => 'Maghrib',
    SalahTraceRow.isha => 'Isha',
    SalahTraceRow.jumuah => 'Jumu‘ah',
    SalahTraceRow.tahajjud => 'Tahajjud',
    SalahTraceRow.ishraq => 'Ishraq',
    SalahTraceRow.tawbah => 'Salat At Tawbah',
  };

  bool get isObligatory => switch (this) {
    SalahTraceRow.fajr ||
    SalahTraceRow.dhuhr ||
    SalahTraceRow.asr ||
    SalahTraceRow.maghrib ||
    SalahTraceRow.isha => true,
    _ => false,
  };

  bool get isFridayPrayer => this == SalahTraceRow.jumuah;

  bool get isVoluntary =>
      this == SalahTraceRow.tahajjud ||
      this == SalahTraceRow.ishraq ||
      this == SalahTraceRow.tawbah;

  bool get fridayOnly => this == SalahTraceRow.jumuah;

  PrayerId? get prayerId => switch (this) {
    SalahTraceRow.fajr => PrayerId.fajr,
    SalahTraceRow.dhuhr => PrayerId.dhuhr,
    SalahTraceRow.asr => PrayerId.asr,
    SalahTraceRow.maghrib => PrayerId.maghrib,
    SalahTraceRow.isha => PrayerId.isha,
    _ => null,
  };
}

const kSalahObligatoryBand = 'Obligatory Salah';
const kSalahFridayBand = 'Friday Prayer';
const kSalahVoluntaryBand = 'Voluntary Prayers';

String salahHomeBand(SalahTraceRow row) {
  if (row.isObligatory) return kSalahObligatoryBand;
  if (row.isFridayPrayer) return kSalahFridayBand;
  return kSalahVoluntaryBand;
}

const obligatorySalahRows = [
  SalahTraceRow.fajr,
  SalahTraceRow.dhuhr,
  SalahTraceRow.asr,
  SalahTraceRow.maghrib,
  SalahTraceRow.isha,
];

const kSalahVoluntaryRows = [
  SalahTraceRow.tahajjud,
  SalahTraceRow.ishraq,
  SalahTraceRow.tawbah,
];

bool isFridayDateKey(String key) =>
    parseDateKey(key).weekday == DateTime.friday;

String voluntarySalahLabel(TernaryOutcome outcome) => switch (outcome) {
  TernaryOutcome.positive => 'Performed',
  TernaryOutcome.negative => 'Not performed',
  TernaryOutcome.unanswered => 'Not recorded',
};
