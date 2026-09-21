import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quran_stage.dart';

void main() {
  test('highest stage wins Application over Engagement', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.reading, TernaryOutcome.positive)
        .withQuran(
          QuranDimension.consciousApplication,
          TernaryOutcome.positive,
        );
    expect(quranStageFor(record), QuranStage.application);
  });

  test('not done does not raise a stage', () {
    final record = DailyCheckIn.empty(
      '2026-09-03',
    ).withQuran(QuranDimension.reading, TernaryOutcome.negative);
    expect(quranStageFor(record), QuranStage.none);
  });

  test('meaning or tafsir is Understanding', () {
    final meaning = DailyCheckIn.empty(
      '2026-09-03',
    ).withQuran(QuranDimension.meaning, TernaryOutcome.positive);
    expect(quranStageFor(meaning), QuranStage.understanding);
    final tafsir = DailyCheckIn.empty(
      '2026-09-03',
    ).withQuran(QuranDimension.tafsir, TernaryOutcome.positive);
    expect(quranStageFor(tafsir), QuranStage.understanding);
  });

  test('journey L2 writes one letter without a schema bump', () {
    final worship = QuranJourneyRow.applied.l2Options.first;
    final record = applyQuranJourneyL2(
      DailyCheckIn.empty('2026-09-03'),
      QuranJourneyRow.applied,
      worship,
    );
    expect(
      quranJourneyCell(record, QuranJourneyRow.applied).code,
      'W',
    );
    expect(
      record.quranOutcome(QuranDimension.consciousApplication),
      TernaryOutcome.positive,
    );
  });

  test('journey None is not unanswered', () {
    final record = applyQuranJourneyNone(
      DailyCheckIn.empty('2026-09-03'),
      QuranJourneyRow.engaged,
    );
    expect(
      quranJourneyCell(record, QuranJourneyRow.engaged).kind,
      QuranJourneyCellKind.none,
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.negative,
    );
  });

  test('journey unanswered clears every item in that row', () {
    final worship = QuranJourneyRow.applied.l2Options.first;
    final afterApplied = applyQuranJourneyL2(
      DailyCheckIn.empty('2026-09-03'),
      QuranJourneyRow.applied,
      worship,
    );
    final afterEngaged = applyQuranJourneyNone(
      afterApplied,
      QuranJourneyRow.engaged,
    );
    final cleared = applyQuranJourneyUnanswered(
      afterEngaged,
      QuranJourneyRow.applied,
    );
    expect(
      quranJourneyCell(cleared, QuranJourneyRow.applied).kind,
      QuranJourneyCellKind.unanswered,
    );
    expect(
      cleared.quranOutcome(QuranDimension.consciousApplication),
      TernaryOutcome.unanswered,
    );
    expect(
      quranJourneyCell(cleared, QuranJourneyRow.engaged).kind,
      QuranJourneyCellKind.none,
    );
  });

  test('30/90 Progress titles follow Home Journey stages', () {
    expect(QuranDimension.reading.progressCalendarTitle, 'Engaged');
    expect(
      QuranDimension.reading.progressCalendarSubtitle,
      'Contact with Qur’an · Recitation',
    );
    expect(QuranDimension.meaning.progressCalendarTitle, 'Understood');
    expect(
      QuranDimension.meaning.progressCalendarSubtitle,
      'Comprehension · Meaning',
    );
    expect(QuranDimension.tafsir.progressCalendarTitle, 'Understood');
    expect(QuranDimension.reflection.progressCalendarTitle, 'Reflected');
    expect(
      QuranDimension.reflection.progressCalendarSubtitle,
      'Internalization',
    );
    expect(
      QuranDimension.consciousApplication.progressCalendarTitle,
      'Applied',
    );
    expect(
      QuranDimension.consciousApplication.progressCalendarSubtitle,
      'Transformation',
    );
    expect(QuranDimension.memorisation.progressCalendarTitle, 'Engaged');
    expect(QuranDimension.revision.progressCalendarTitle, 'Engaged');
  });
}
