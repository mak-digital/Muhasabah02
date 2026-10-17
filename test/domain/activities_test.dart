import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/akhlaq_practices.dart';
import 'package:muhasabah02/domain/huquq_practices.dart';
import 'package:muhasabah02/domain/knowledge_practices.dart';
import 'package:muhasabah02/domain/health_practices.dart';
import 'package:muhasabah02/domain/time_practices.dart';
import 'package:muhasabah02/domain/ummah_practices.dart';
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

  test('knowledge rows use item-specific wording and salah colour twins', () {
    expect(
      ActivityCatalog.forHomeTrace(
        'knowledge.learnedSomethingTrue',
      ).map((o) => o.id).toList(),
      [
        KnowledgeObservationIds.engaged,
        KnowledgeObservationIds.progress,
        KnowledgeObservationIds.gapRecognised,
        KnowledgeObservationIds.corrected,
        KnowledgeObservationIds.noSituation,
        ActivityIds.unanswered,
      ],
    );
    expect(
      ActivityCatalog.forHomeTrace('knowledge.learnedSomethingTrue').first.label,
      'Learned something new and verified its reliability',
    );
    expect(
      ActivityCatalog.forHomeTrace('knowledge.heldBackUselessSpeech')[2].label,
      'Engaged in unnecessary or harmful speech and recognised it',
    );
    expect(
      ActivityCatalog.forHomeTrace('knowledge.beneficialCreating')[0].label,
      'Completed useful content or work with a clear beneficial purpose',
    );
    expect(
      SalahActivityMark.colourForId(KnowledgeObservationIds.engaged),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(KnowledgeObservationIds.progress),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(KnowledgeObservationIds.corrected),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(KnowledgeObservationIds.noSituation),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(KnowledgeObservationIds.gapRecognised),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(KnowledgeObservationIds.noSituation),
      MarkerKind.filled,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(KnowledgeObservationIds.gapRecognised),
      MarkerKind.outlined,
    );
    var record = DailyCheckIn.empty('2026-09-03');
    expect(
      record.activityFor('knowledge.learnedSomethingTrue').id,
      ActivityIds.unanswered,
    );
    record = writeKnowledgeFollowUp(
      record,
      'knowledge.learnedSomethingTrue',
      const KnowledgeFollowUpCapture(
        primaryId: KnowledgeObservationIds.engaged,
        areaId: 'knowledge.area.professional',
        sourceId: 'knowledge.source.course',
        verificationId: 'knowledge.verification.pending',
        understandingId: 'knowledge.understanding.mainIdea',
        applicationId: 'knowledge.application.identified',
        quantityId: 'knowledge.quantity.oneOccasion',
        note: 'I noted a method to apply',
      ),
    );
    expect(
      record.homeTrace('knowledge.learnedSomethingTrue'),
      TernaryOutcome.positive,
    );
    var capture = readKnowledgeFollowUp(
      record,
      'knowledge.learnedSomethingTrue',
    );
    expect(capture.areaId, 'knowledge.area.professional');
    expect(capture.verificationId, 'knowledge.verification.pending');
    expect(capture.applicationId, 'knowledge.application.identified');
    expect(
      knowledgeEvidenceNote(record, 'knowledge.learnedSomethingTrue'),
      contains('Professional or vocational knowledge'),
    );
    record = writeKnowledgeFollowUp(
      record,
      'knowledge.learnedSomethingTrue',
      capture.copyWith(primaryId: KnowledgeObservationIds.gapRecognised),
    );
    expect(
      record.homeTrace('knowledge.learnedSomethingTrue'),
      TernaryOutcome.negative,
    );
    expect(
      SalahActivityMark.forHadithTrace(
        record: record,
        row: homeTraceRowByKey('knowledge.learnedSomethingTrue')!,
        activityColours: true,
      ).kind,
      MarkerKind.outlined,
    );
    record = writeKnowledgeFollowUp(
      record,
      'knowledge.learnedSomethingTrue',
      const KnowledgeFollowUpCapture(),
    );
    expect(
      record.homeTrace('knowledge.learnedSomethingTrue'),
      TernaryOutcome.unanswered,
    );
    expect(
      readKnowledgeFollowUp(record, 'knowledge.learnedSomethingTrue').note,
      isEmpty,
    );
    final legacy = DailyCheckIn.empty('2026-09-03').withHomeTrace(
      'knowledge.taughtSomeone',
      TernaryOutcome.negative,
    );
    expect(
      legacy.activityFor('knowledge.taughtSomeone').id,
      KnowledgeObservationIds.noSituation,
    );
  });

  test('time rows use item-specific wording and salah colour twins', () {
    expect(
      ActivityCatalog.forHomeTrace('time.t01').map((o) => o.id).toList(),
      [
        TimeObservationIds.acted,
        TimeObservationIds.partialEffort,
        TimeObservationIds.lapseRecognised,
        TimeObservationIds.corrected,
        TimeObservationIds.noSituation,
        ActivityIds.unanswered,
      ],
    );
    expect(
      ActivityCatalog.forHomeTrace('time.t01').first.label,
      'Began an activity with a clear beneficial intention',
    );
    expect(
      ActivityCatalog.forHomeTrace('time.t04')[2].label,
      'Recognised that unnecessary screen use displaced something important',
    );
    expect(
      ActivityCatalog.forHomeTrace('time.t08')[0].label,
      'Took appropriate rest or recovery when needed',
    );
    expect(
      SalahActivityMark.colourForId(TimeObservationIds.acted),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(TimeObservationIds.partialEffort),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(TimeObservationIds.corrected),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(TimeObservationIds.noSituation),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(TimeObservationIds.lapseRecognised),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(TimeObservationIds.noSituation),
      MarkerKind.filled,
    );
    expect(
      SalahActivityMark.kindForAkhlaq(TimeObservationIds.lapseRecognised),
      MarkerKind.outlined,
    );
    var record = DailyCheckIn.empty('2026-09-03');
    expect(record.activityFor('time.t01').id, ActivityIds.unanswered);
    record = writeTimePractice(
      record,
      'time.t01',
      const TimePracticeCapture(
        primaryId: TimeObservationIds.acted,
        contextId: 'time.context.worship',
        helpId: 'time.help.clarifiedIntention',
        outcomeId: 'time.outcome.meaningfulProgress',
        note: 'I started with a purpose',
      ),
    );
    expect(record.homeTrace('time.t01'), TernaryOutcome.positive);
    var capture = readTimePractice(record, 'time.t01');
    expect(capture.contextId, 'time.context.worship');
    expect(capture.helpId, 'time.help.clarifiedIntention');
    expect(
      timeEvidenceNote(record, 'time.t01'),
      contains('Worship'),
    );
    record = writeTimePractice(
      record,
      'time.t01',
      capture.copyWith(primaryId: TimeObservationIds.lapseRecognised),
    );
    expect(record.homeTrace('time.t01'), TernaryOutcome.negative);
    expect(
      SalahActivityMark.forHadithTrace(
        record: record,
        row: homeTraceRowByKey('time.t01')!,
        activityColours: true,
      ).kind,
      MarkerKind.outlined,
    );
    record = writeTimePractice(
      record,
      'time.t01',
      const TimePracticeCapture(),
    );
    expect(record.homeTrace('time.t01'), TernaryOutcome.unanswered);
    expect(readTimePractice(record, 'time.t01').note, isEmpty);
    final legacy = DailyCheckIn.empty('2026-09-03').withHomeTrace(
      'time.t08',
      TernaryOutcome.negative,
    );
    expect(
      legacy.activityFor('time.t08').id,
      TimeObservationIds.lapseRecognised,
    );
  });

  test('health rows use item-specific wording and salah colour twins', () {
    expect(ActivityCatalog.forHomeTrace('health.sleepQuality').length, 7);
    expect(
      ActivityCatalog.forHomeTrace('health.sleepQuality').first.label,
      'I slept well and felt reasonably refreshed.',
    );
    expect(
      ActivityCatalog.forHomeTrace('health.sleepQuality')[5].id,
      HealthObservationIds.preferNot,
    );
    expect(
      SalahActivityMark.colourForId('health.sleepQuality.refreshed'),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId('health.sleepQuality.sleptPoorly'),
      SalahActivityMark.excused,
    );
    expect(
      SalahActivityMark.colourForId('health.illnessCare.delayedCare'),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.kindForAkhlaq('health.illnessCare.delayedCare'),
      MarkerKind.outlined,
    );
    expect(
      SalahActivityMark.kindForAkhlaq('health.sleepQuality.sleptPoorly'),
      MarkerKind.filled,
    );
    var record = writeHealthPractice(
      DailyCheckIn.empty('2026-10-17'),
      'health.illnessCare',
      const HealthPracticeCapture(
        primaryId: 'health.illnessCare.noIllness',
      ),
    );
    expect(record.homeTrace('health.illnessCare'), TernaryOutcome.positive);
    expect(
      SalahActivityMark.forHadithTrace(
        record: record,
        row: homeTraceRowByKey('health.illnessCare')!,
        activityColours: true,
      ).kind,
      MarkerKind.filled,
    );
  });

  test('wealth rows use item-specific wording and salah colour twins', () {
    expect(
      ActivityCatalog.forHomeTrace('wealth.avoidedRiba').first.label,
      'I avoided entering a transaction involving prohibited riba.',
    );
    expect(
      ActivityCatalog.forHomeTrace('wealth.lawfulManagement')[5].id,
      'wealth.lawfulManagement.noDecision',
    );
    expect(
      SalahActivityMark.colourForId('wealth.halalEarning.lawfulSource'),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId('wealth.halalEarning.unresolvedConcern'),
      SalahActivityMark.excused,
    );
    expect(
      SalahActivityMark.kindForAkhlaq('wealth.halalEarning.unresolvedConcern'),
      MarkerKind.filled,
    );
  });

  test('ummah rows use item-specific wording and salah colour twins', () {
    expect(ActivityCatalog.forHomeTrace('ummah.masjidAttendance').length, 6);
    expect(
      ActivityCatalog.forHomeTrace('ummah.masjidAttendance')[1].label,
      'I participated remotely in a masjid-led learning or community gathering.',
    );
    expect(
      ActivityCatalog.forHomeTrace('ummah.masjidAttendance')[4].id,
      UmmahObservationIds.preferNot,
    );
    expect(
      SalahActivityMark.colourForId('ummah.masjidAttendance.attended'),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId('ummah.masjidAttendance.remote'),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId('ummah.supportedOppressed.didNotAct'),
      SalahActivityMark.excused,
    );
    expect(
      SalahActivityMark.kindForAkhlaq('ummah.supportedOppressed.didNotAct'),
      MarkerKind.filled,
    );
  });

  test('charity rows use item-specific wording without leftover names', () {
    expect(
      ActivityCatalog.forHomeTrace('charity.voluntary').first.label,
      'Not recorded',
    );
    expect(
      ActivityCatalog.forHomeTrace('charity.voluntary')[1].label,
      'Gave voluntary charity',
    );
    expect(
      ActivityCatalog.forHomeTrace('charity.emergency')[3].label,
      'Recognised an emergency but could not help',
    );
    expect(
      SalahActivityMark.colourForId('charity.voluntary.gave'),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.kindForAkhlaq('charity.voluntary.didNotGive'),
      MarkerKind.filled,
    );
  });
}
