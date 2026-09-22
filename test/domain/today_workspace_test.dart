import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personalisation_resolver.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recorded_context.dart';
import 'package:muhasabah02/domain/today_workspace.dart';

void main() {
  const friday = '2026-09-18';
  const tuesday = '2026-09-22';

  PersonalisationResolver resolver({
    Set<MonitorDomain>? visible,
    PersonalMix? mix,
  }) {
    return PersonalisationResolver(
      visibleDomains: visible ?? kBasicAkhlaqVisibleDomains,
      mix: mix ?? PersonalMix.sameAsDomains,
    );
  }

  TodayWorkspace workspace({
    String dateKey = tuesday,
    Set<MonitorDomain>? visible,
    PersonalMix? mix,
    DailyCheckIn? record,
    HajjStatus hajjStatus = HajjStatus.unanswered,
  }) {
    return deriveTodayWorkspace(
      dateKey: dateKey,
      resolver: resolver(visible: visible, mix: mix),
      record: record,
      hajjStatus: hajjStatus,
    );
  }

  List<String> mixIds(TodayWorkspace subject, MonitorDomain domain) {
    return [
      for (final group in subject.domains)
        if (group.domain == domain)
          for (final row in group.rows) row.mixId,
    ];
  }

  TodayRow? rowOf(TodayWorkspace subject, String mixId) {
    for (final group in subject.domains) {
      for (final row in group.rows) {
        if (row.mixId == mixId) return row;
      }
    }
    return null;
  }

  test('absent daily record leaves permitted rows as no-response', () {
    final subject = workspace();
    expect(subject.dateKey, tuesday);
    expect(subject.domains.map((group) => group.domain), [
      MonitorDomain.salah,
      MonitorDomain.quran,
      MonitorDomain.hadith,
      MonitorDomain.akhlaq,
      MonitorDomain.huquq,
      MonitorDomain.charity,
    ]);
    expect(subject.domains.every((group) => group.rows.isNotEmpty), isTrue);
    expect(
      subject.domains.every((group) => group.recordedRows.isEmpty),
      isTrue,
    );
    expect(
      subject.domains.every(
        (group) => group.noResponseRows.length == group.rows.length,
      ),
      isTrue,
    );
  });

  test('record for another date is ignored and does not mark recorded', () {
    final otherDay = DailyCheckIn.empty('2026-09-21')
        .withPrayer(PrayerId.fajr, PrayerStatus.onTime);
    final subject = workspace(record: otherDay);
    expect(
      rowOf(subject, 'salah.fajr')?.recordedState,
      TodayRecordedState.noResponse,
    );
  });

  test('explicit salah response is recorded including missed and excused', () {
    var record = DailyCheckIn.empty(tuesday)
        .withPrayer(PrayerId.fajr, PrayerStatus.onTime);
    record = record.withPrayer(PrayerId.dhuhr, PrayerStatus.missed);
    record = record.withPrayer(PrayerId.asr, PrayerStatus.excused);
    final subject = workspace(record: record);
    expect(
      rowOf(subject, 'salah.fajr')?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(
      rowOf(subject, 'salah.dhuhr')?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(
      rowOf(subject, 'salah.asr')?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(
      rowOf(subject, 'salah.maghrib')?.recordedState,
      TodayRecordedState.noResponse,
    );
  });

  test('stored Other on salah counts as recorded', () {
    final record = DailyCheckIn.empty(tuesday).withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: ActivityIds.other),
    );
    final subject = workspace(record: record);
    expect(record.prayer(PrayerId.fajr), PrayerStatus.other);
    expect(
      rowOf(subject, 'salah.fajr')?.recordedState,
      TodayRecordedState.recorded,
    );
  });

  test('unanswered salah is no-response, not missed', () {
    final subject = workspace(record: DailyCheckIn.empty(tuesday));
    expect(
      rowOf(subject, 'salah.isha')?.recordedState,
      TodayRecordedState.noResponse,
    );
    expect(rowOf(subject, 'salah.isha')?.kind, TodayRowKind.salah);
  });

  test('salah mix order is catalog order', () {
    final subject = workspace();
    expect(mixIds(subject, MonitorDomain.salah).take(5), [
      'salah.fajr',
      'salah.dhuhr',
      'salah.asr',
      'salah.maghrib',
      'salah.isha',
    ]);
  });

  test('Jumu‘ah appears on Friday when in the mix and is absent otherwise', () {
    final fridayWorkspace = workspace(dateKey: friday);
    final tuesdayWorkspace = workspace(dateKey: tuesday);
    expect(rowOf(fridayWorkspace, 'salah.jumuah'), isNotNull);
    expect(rowOf(tuesdayWorkspace, 'salah.jumuah'), isNull);
    expect(rowOf(fridayWorkspace, 'salah.fajr'), isNotNull);
    expect(rowOf(tuesdayWorkspace, 'salah.fajr'), isNotNull);
  });

  test('hidden domain is absent even when mix names its rows', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final visible = {...kBasicAkhlaqVisibleDomains}
      ..remove(MonitorDomain.quran);
    final subject = workspace(visible: visible, mix: mix);
    expect(
      subject.domains.map((group) => group.domain),
      isNot(contains(MonitorDomain.quran)),
    );
    expect(rowOf(subject, 'quran.reading'), isNull);
  });

  test('mix-excluded row is absent; custom mix is respected', () {
    final mix = PersonalMix(
      kind: PersonalMixKind.custom,
      keys: {'quran.reading', 'salah.fajr'},
    );
    final subject = workspace(mix: mix);
    expect(rowOf(subject, 'quran.reading'), isNotNull);
    expect(rowOf(subject, 'salah.fajr'), isNotNull);
    expect(rowOf(subject, 'quran.tafsir'), isNull);
    expect(rowOf(subject, 'quran.meaning'), isNull);
    expect(subject.domains.map((group) => group.domain), [
      MonitorDomain.salah,
      MonitorDomain.quran,
    ]);
  });

  test('unknown and retired ids are not emitted', () {
    final mix = PersonalMix(
      kind: PersonalMixKind.custom,
      keys: {'salah.fajr', 'family.parentsContact', 'not.a.row'},
    );
    final subject = workspace(mix: mix);
    expect(rowOf(subject, 'salah.fajr'), isNotNull);
    expect(rowOf(subject, 'family.parentsContact'), isNull);
    expect(rowOf(subject, 'not.a.row'), isNull);
  });

  test('empty custom mix does not invent default rows', () {
    const mix = PersonalMix(kind: PersonalMixKind.custom, keys: {});
    final subject = workspace(mix: mix);
    expect(subject.domains.every((group) => group.rows.isEmpty), isTrue);
  });

  test('selected quran dimension appears; negative is recorded', () {
    final mix = PersonalMix(
      kind: PersonalMixKind.custom,
      keys: {'quran.reading', 'quran.tafsir'},
    );
    final record = DailyCheckIn.empty(tuesday)
        .withQuran(QuranDimension.reading, TernaryOutcome.negative);
    final subject = workspace(mix: mix, record: record);
    expect(rowOf(subject, 'quran.reading')?.kind, TodayRowKind.quran);
    expect(
      rowOf(subject, 'quran.reading')?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(
      rowOf(subject, 'quran.tafsir')?.recordedState,
      TodayRecordedState.noResponse,
    );
    expect(rowOf(subject, 'quran.meaning'), isNull);
  });

  test('Application Reflection is not a Today row', () {
    final same = workspace();
    final firstLook = workspace(mix: mixForKind(PersonalMixKind.firstLook));
    expect(rowOf(same, 'quran.applicationReflection'), isNull);
    expect(rowOf(firstLook, 'quran.applicationReflection'), isNull);
    expect(
      mixIds(same, MonitorDomain.quran),
      isNot(contains('quran.applicationReflection')),
    );
  });

  test('Today quran rows are dimensions, not Journey stages', () {
    final ids = mixIds(workspace(), MonitorDomain.quran);
    expect(ids, [
      'quran.reading',
      'quran.meaning',
      'quran.memorisation',
      'quran.revision',
      'quran.tafsir',
      'quran.reflection',
      'quran.consciousApplication',
    ]);
  });

  test('home-trace positive and negative are recorded; unanswered is not', () {
    var record = DailyCheckIn.empty(tuesday)
        .withHomeTrace('akhlaq.patience', TernaryOutcome.positive);
    record = record.withHomeTrace(
      'akhlaq.truthfulness',
      TernaryOutcome.negative,
    );
    final subject = workspace(
      mix: mixForKind(PersonalMixKind.firstLook),
      record: record,
    );
    expect(rowOf(subject, 'akhlaq.patience')?.kind, TodayRowKind.homeTrace);
    expect(
      rowOf(subject, 'akhlaq.patience')?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(
      rowOf(subject, 'akhlaq.truthfulness')?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(
      rowOf(subject, 'huquq.parents')?.recordedState,
      TodayRecordedState.noResponse,
    );
  });

  test('Hajj standing mix id is not a daily row', () {
    final visible = {MonitorDomain.salah, MonitorDomain.hajj};
    final mix = PersonalMix(
      kind: PersonalMixKind.custom,
      keys: {'salah.fajr', kHajjMixKey, kHajjPreparationKey},
    );
    final hiddenPrep = workspace(
      visible: visible,
      mix: mix,
      hajjStatus: HajjStatus.notDue,
    );
    expect(rowOf(hiddenPrep, kHajjMixKey), isNull);
    expect(rowOf(hiddenPrep, kHajjPreparationKey), isNull);
    expect(
      hiddenPrep.domains.any((group) => group.domain == MonitorDomain.hajj),
      isTrue,
    );

    final shownPrep = workspace(
      visible: visible,
      mix: mix,
      hajjStatus: HajjStatus.preparing,
    );
    expect(rowOf(shownPrep, kHajjMixKey), isNull);
    expect(rowOf(shownPrep, kHajjPreparationKey)?.kind, TodayRowKind.homeTrace);
    expect(
      rowOf(shownPrep, kHajjPreparationKey)?.recordedState,
      TodayRecordedState.noResponse,
    );
  });

  test('Zakat is a status row; explicit status is recorded', () {
    final mix = PersonalMix(kind: PersonalMixKind.custom, keys: {kZakatMixKey});
    final visible = {MonitorDomain.charity};
    final unanswered = workspace(visible: visible, mix: mix);
    expect(rowOf(unanswered, kZakatMixKey)?.kind, TodayRowKind.zakatStatus);
    expect(
      rowOf(unanswered, kZakatMixKey)?.recordedState,
      TodayRecordedState.noResponse,
    );

    final recorded = workspace(
      visible: visible,
      mix: mix,
      record: DailyCheckIn.empty(tuesday)
          .copyWith(zakat: ZakatStatus.notApplicable),
    );
    expect(
      rowOf(recorded, kZakatMixKey)?.recordedState,
      TodayRecordedState.recorded,
    );
    expect(rowOf(recorded, kZakatMixKey)?.kind, isNot(TodayRowKind.homeTrace));
  });

  test('recorded and no-response splits keep catalog order', () {
    final record = DailyCheckIn.empty(tuesday)
        .withPrayer(PrayerId.dhuhr, PrayerStatus.late)
        .withPrayer(PrayerId.isha, PrayerStatus.missed);
    final salah = workspace(record: record).domains
        .firstWhere((group) => group.domain == MonitorDomain.salah);
    expect(salah.recordedRows.map((row) => row.mixId), [
      'salah.dhuhr',
      'salah.isha',
    ]);
    expect(salah.noResponseRows.map((row) => row.mixId).take(3), [
      'salah.fajr',
      'salah.asr',
      'salah.maghrib',
    ]);
  });

  test('quran context alone does not create a recorded Today row', () {
    final record = DailyCheckIn.empty(tuesday).withContext(
      const RecordedContext(
        subject: QuranDimension.reading,
        polarity: 'positive',
        factorIds: ['quietPlace'],
      ),
    );
    final subject = workspace(record: record);
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );
    expect(
      rowOf(subject, 'quran.reading')?.recordedState,
      TodayRecordedState.noResponse,
    );
  });

  test('empty visible domains yield an empty workspace', () {
    final subject = workspace(visible: {});
    expect(subject.domains, isEmpty);
  });
}
