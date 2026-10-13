import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/akhlaq_practices.dart';
import 'package:muhasabah02/domain/huquq_practices.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/salah_extras.dart';
import 'package:muhasabah02/presentation/shared/salah_activity_mark.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

void main() {
  test('salah activity maps to status without scoring', () {
    var record = DailyCheckIn.empty('2026-09-03').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: 'congregationOnTime'),
    );
    expect(record.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
    record = record.withSalahActivity(
      PrayerId.dhuhr,
      const RecordedActivity(id: ActivityIds.unanswered),
    );
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
  });

  test('excused is recorded and is never missed', () {
    final record = DailyCheckIn.empty('2026-09-03').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: 'excused'),
    );
    expect(record.prayer(PrayerId.fajr), PrayerStatus.excused);
    expect(record.prayer(PrayerId.fajr).isRecorded, isTrue);
    expect(record.prayer(PrayerId.fajr).isDesirable, isFalse);
    expect(record.prayer(PrayerId.fajr), isNot(PrayerStatus.missed));
  });

  test('salah other is recorded and is not late', () {
    final record = DailyCheckIn.empty('2026-09-03').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: ActivityIds.other, customText: 'Travel'),
    );
    expect(record.prayer(PrayerId.fajr), PrayerStatus.other);
    expect(record.prayer(PrayerId.fajr).isRecorded, isTrue);
    expect(record.prayer(PrayerId.fajr), isNot(PrayerStatus.late));
  });

  test('quran other stores custom text and remains independent', () {
    final record = DailyCheckIn.empty('2026-09-03').withQuranActivity(
      QuranDimension.reading,
      const RecordedActivity(id: ActivityIds.other, customText: 'A class'),
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    expect(
      record
          .activityFor(ActivityCatalog.quranKey(QuranDimension.reading))
          .customText,
      'A class',
    );
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
  });

  test('optional domains do not change the recordable denominator', () {
    final record = DailyCheckIn.empty('2026-09-03').copyWith(
      fasting: const DomainObservation(activityId: 'weeklySunnah'),
      zakat: ZakatStatus.paid,
    );
    expect(record.answeredRecordableCount, 0);
    expect(kRecordableFieldCount, 10);
    expect(record.hasAnyRecordedEvidence, isTrue);
  });

  test('tahajjud and ishraq lists keep five observational choices', () {
    expect(
      ActivityCatalog.tahajjud.map((option) => option.label).toList(),
      [
        'Prayed early/mid and late at night',
        'Prayed later part of night',
        'Prayed early/mid night',
        'Not Prayed',
        'Not recorded',
      ],
    );
    expect(
      ActivityCatalog.ishraq.map((option) => option.label).toList(),
      [
        'Prayed following Fajr',
        'Prayed later in the morning',
        'Prayed',
        'Not Prayed',
        'Not recorded',
      ],
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.tahajjudEarlyMidAndLate),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.ishraqFollowingFajr),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.tahajjudLaterPart),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.ishraqLaterMorning),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.tahajjudEarlyMid),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.ishraqPrayed),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.tahajjudNotPrayed),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.ishraqNotPrayed),
      SalahActivityMark.aloneOnTime,
    );
    final notPrayed = SalahActivityMark.forVoluntary(
      record: DailyCheckIn.empty('2026-09-03').withVoluntarySalahActivity(
        SalahTraceRow.tahajjud,
        const RecordedActivity(id: ActivityCatalog.tahajjudNotPrayed),
      ),
      row: SalahTraceRow.tahajjud,
      activityColours: true,
    );
    expect(notPrayed.kind, MarkerKind.outlined);
    expect(notPrayed.color, SalahActivityMark.aloneOnTime);
  });

  test('voluntary salah stores activity id and twins ternary', () {
    var record = DailyCheckIn.empty('2026-09-03').withVoluntarySalahActivity(
      SalahTraceRow.tahajjud,
      const RecordedActivity(id: ActivityCatalog.tahajjudLaterPart),
    );
    expect(record.tahajjud, TernaryOutcome.positive);
    expect(
      record.activityFor(ActivityCatalog.tahajjudKey).id,
      ActivityCatalog.tahajjudLaterPart,
    );
    expect(record.answeredRecordableCount, 0);
    record = record.withVoluntarySalahActivity(
      SalahTraceRow.ishraq,
      const RecordedActivity(id: ActivityCatalog.ishraqNotPrayed),
    );
    expect(record.ishraq, TernaryOutcome.negative);
    expect(
      record.activityFor(ActivityCatalog.ishraqKey).id,
      ActivityCatalog.ishraqNotPrayed,
    );
  });

  test('old ternary voluntary days canonicalise without rewriting ids', () {
    final record = DailyCheckIn.empty('2026-09-03').copyWith(
      tahajjud: TernaryOutcome.positive,
      ishraq: TernaryOutcome.negative,
    );
    expect(
      record.activityFor(ActivityCatalog.tahajjudKey).id,
      ActivityCatalog.tahajjudEarlyMid,
    );
    expect(
      record.activityFor(ActivityCatalog.ishraqKey).id,
      ActivityCatalog.ishraqNotPrayed,
    );
  });

  test('post-fard dhikr stores remembrance level and twins salah colours', () {
    expect(
      ActivityCatalog.dhikrPostFard.map((option) => option.label).toList(),
      [
        'Remembrance with action (I noticed a beneficial response in my behaviour)',
        'Attentive remembrance (I consciously reflected on the words or meaning)',
        'Intentional remembrance (I deliberately made time for dhikr or du‘a)',
        'Brief remembrance (A short dhikr or du‘a during the time)',
        'Not today (I did not practise or do not recall doing so)',
        'Unanswered',
      ],
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.dhikrWithAction),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.dhikrAttentive),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.dhikrIntentional),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(ActivityCatalog.dhikrBrief),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(ActivityIds.noActivity),
      SalahActivityMark.prayedLate,
    );
    var record = DailyCheckIn.empty('2026-09-03').withHomeTraceActivity(
      'dhikr.postFardFajr',
      const RecordedActivity(id: ActivityCatalog.dhikrAttentive),
    );
    expect(record.homeTrace('dhikr.postFardFajr'), TernaryOutcome.positive);
    expect(
      record.activityFor('dhikr.postFardFajr').id,
      ActivityCatalog.dhikrAttentive,
    );
    final mark = SalahActivityMark.forHadithTrace(
      record: record,
      row: homeTraceRowByKey('dhikr.postFardFajr')!,
      activityColours: true,
    );
    expect(mark.kind, MarkerKind.filled);
    expect(mark.color, SalahActivityMark.joinedCongregationLate);
    record = record.withHomeTraceActivity(
      'dhikr.postFardAsr',
      const RecordedActivity(id: ActivityIds.noActivity),
    );
    expect(record.homeTrace('dhikr.postFardAsr'), TernaryOutcome.negative);
    expect(
      SalahActivityMark.forHadithTrace(
        record: record,
        row: homeTraceRowByKey('dhikr.postFardAsr')!,
        activityColours: true,
      ).kind,
      MarkerKind.outlined,
    );
  });

  test('akhlaq rows use item-specific wording and salah colour twins', () {
    expect(
      ActivityCatalog.forHomeTrace('akhlaq.patience').map((o) => o.id).toList(),
      [
        AkhlaqObservationIds.practised,
        AkhlaqObservationIds.struggled,
        AkhlaqObservationIds.lapseRecognised,
        AkhlaqObservationIds.corrected,
        AkhlaqObservationIds.noSituation,
        ActivityIds.unanswered,
      ],
    );
    expect(
      ActivityCatalog.forHomeTrace('akhlaq.patience').first.label,
      'Remained patient when tested',
    );
    expect(
      ActivityCatalog.forHomeTrace('akhlaq.heldBackFromAHabit')[2].label,
      'Continued the habit and recognised it',
    );
    expect(
      SalahActivityMark.colourForId(AkhlaqObservationIds.practised),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(AkhlaqObservationIds.struggled),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(AkhlaqObservationIds.corrected),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(AkhlaqObservationIds.noSituation),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(AkhlaqObservationIds.lapseRecognised),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(AkhlaqObservationIds.noSituation),
      MarkerKind.filled,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(AkhlaqObservationIds.lapseRecognised),
      MarkerKind.outlined,
    );
    var record = DailyCheckIn.empty('2026-09-03').withHomeTraceActivity(
      'akhlaq.patience',
      const RecordedActivity(id: AkhlaqObservationIds.practised),
    );
    expect(record.homeTrace('akhlaq.patience'), TernaryOutcome.positive);
    record = writeAkhlaqFollowUp(
      record,
      'akhlaq.patience',
      const AkhlaqFollowUpCapture(
        primaryId: AkhlaqObservationIds.lapseRecognised,
        contextId: 'akhlaq.context.familyHome',
        helpId: 'akhlaq.help.pausingBeforeReacting',
        note: 'I caught myself',
      ),
    );
    expect(record.homeTrace('akhlaq.patience'), TernaryOutcome.negative);
    final capture = readAkhlaqFollowUp(record, 'akhlaq.patience');
    expect(capture.note, 'I caught myself');
    expect(
      SalahActivityMark.forHadithTrace(
        record: record,
        row: homeTraceRowByKey('akhlaq.patience')!,
        activityColours: true,
      ).kind,
      MarkerKind.outlined,
    );
    final legacy = DailyCheckIn.empty('2026-09-03').withHomeTrace(
      'akhlaq.humility',
      TernaryOutcome.negative,
    );
    expect(
      legacy.activityFor('akhlaq.humility').id,
      AkhlaqObservationIds.noSituation,
    );
  });

  test('huquq rows use item-specific wording and salah colour twins', () {
    expect(
      ActivityCatalog.forHomeTrace('huquq.parents').map((o) => o.id).toList(),
      [
        HuquqObservationIds.practised,
        HuquqObservationIds.partialEffort,
        HuquqObservationIds.neglectRecognised,
        HuquqObservationIds.correctiveAction,
        HuquqObservationIds.noSituation,
        ActivityIds.unanswered,
      ],
    );
    expect(
      ActivityCatalog.forHomeTrace('huquq.parents').first.label,
      'Honoured my parents through care, respect, contact or du‘a',
    );
    expect(
      ActivityCatalog.forHomeTrace('huquq.reconciliation')[4].label,
      'No appropriate reconciliation action needed or possible today',
    );
    expect(
      ActivityCatalog.forHomeTrace('huquq.supportUnderStress')[0].label,
      'Offered practical, emotional or other appropriate support to someone in difficulty',
    );
    expect(
      SalahActivityMark.colourForId(HuquqObservationIds.practised),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(HuquqObservationIds.partialEffort),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(HuquqObservationIds.correctiveAction),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(HuquqObservationIds.noSituation),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(HuquqObservationIds.neglectRecognised),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(HuquqObservationIds.noSituation),
      MarkerKind.filled,
    );
    var record = DailyCheckIn.empty('2026-09-03');
    expect(
      record.activityFor('huquq.parents').id,
      ActivityIds.unanswered,
    );
    record = writeHuquqFollowUp(
      record,
      'huquq.parents',
      const HuquqFollowUpCapture(
        primaryId: HuquqObservationIds.practised,
        engagementId: 'huquq.engagement.dua',
        outcomeId: 'huquq.outcome.needAddressed',
        occasions: '2',
        timeSpent: '15 min',
        note: 'I called and made du‘a',
      ),
    );
    expect(record.homeTrace('huquq.parents'), TernaryOutcome.positive);
    var capture = readHuquqFollowUp(record, 'huquq.parents');
    expect(capture.occasions, '2');
    expect(capture.timeSpent, '15 min');
    expect(capture.note, 'I called and made du‘a');
    expect(
      huquqEvidenceNote(record, 'huquq.parents'),
      contains('Du‘a'),
    );
    record = writeHuquqFollowUp(
      record,
      'huquq.parents',
      capture.copyWith(primaryId: HuquqObservationIds.neglectRecognised),
    );
    expect(record.homeTrace('huquq.parents'), TernaryOutcome.negative);
    expect(
      SalahActivityMark.forHadithTrace(
        record: record,
        row: homeTraceRowByKey('huquq.parents')!,
        activityColours: true,
      ).kind,
      MarkerKind.outlined,
    );
    record = writeHuquqFollowUp(
      record,
      'huquq.parents',
      const HuquqFollowUpCapture(),
    );
    expect(record.homeTrace('huquq.parents'), TernaryOutcome.unanswered);
    expect(readHuquqFollowUp(record, 'huquq.parents').note, isEmpty);
    final legacy = DailyCheckIn.empty('2026-09-03').withHomeTrace(
      'huquq.spouse',
      TernaryOutcome.negative,
    );
    expect(
      legacy.activityFor('huquq.spouse').id,
      HuquqObservationIds.neglectRecognised,
    );
  });
}
