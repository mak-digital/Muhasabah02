import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quran_stage.dart';

void main() {
  DailyCheckIn empty() => DailyCheckIn.empty('2026-09-03');

  QuranJourneyCellKind kind(DailyCheckIn? record, QuranJourneyRow row) {
    return quranJourneyCell(record, row).kind;
  }

  test('journey groups stay independent of each other', () {
    final engagedOnly = empty().withQuran(
      QuranDimension.reading,
      TernaryOutcome.positive,
    );
    expect(
      kind(engagedOnly, QuranJourneyRow.engaged),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(engagedOnly, QuranJourneyRow.understood),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(engagedOnly, QuranJourneyRow.reflected),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(engagedOnly, QuranJourneyRow.applied),
      QuranJourneyCellKind.unanswered,
    );

    final understoodOnly = empty().withQuran(
      QuranDimension.tafsir,
      TernaryOutcome.positive,
    );
    expect(
      kind(understoodOnly, QuranJourneyRow.understood),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(understoodOnly, QuranJourneyRow.reflected),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(understoodOnly, QuranJourneyRow.applied),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(understoodOnly, QuranJourneyRow.engaged),
      QuranJourneyCellKind.unanswered,
    );

    final reflectedOnly = empty().withQuran(
      QuranDimension.reflection,
      TernaryOutcome.positive,
    );
    expect(
      kind(reflectedOnly, QuranJourneyRow.reflected),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(reflectedOnly, QuranJourneyRow.understood),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(reflectedOnly, QuranJourneyRow.engaged),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(reflectedOnly, QuranJourneyRow.applied),
      QuranJourneyCellKind.unanswered,
    );

    final appliedOnly = empty().withQuran(
      QuranDimension.consciousApplication,
      TernaryOutcome.positive,
    );
    expect(
      kind(appliedOnly, QuranJourneyRow.applied),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(appliedOnly, QuranJourneyRow.reflected),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(appliedOnly, QuranJourneyRow.understood),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(appliedOnly, QuranJourneyRow.engaged),
      QuranJourneyCellKind.unanswered,
    );
  });

  test('multiple journey groups remain simultaneously observable', () {
    final record = empty()
        .withQuran(QuranDimension.reading, TernaryOutcome.positive)
        .withQuran(QuranDimension.tafsir, TernaryOutcome.positive)
        .withQuran(QuranDimension.reflection, TernaryOutcome.positive)
        .withQuran(
          QuranDimension.consciousApplication,
          TernaryOutcome.positive,
        );
    expect(
      kind(record, QuranJourneyRow.engaged),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(record, QuranJourneyRow.understood),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(record, QuranJourneyRow.reflected),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(record, QuranJourneyRow.applied),
      QuranJourneyCellKind.recorded,
    );
  });

  test('unanswered remains unanswered', () {
    final record = empty();
    for (final row in QuranJourneyRow.values) {
      expect(kind(record, row), QuranJourneyCellKind.unanswered);
    }
  });

  test('explicit none is not converted to unanswered', () {
    final record = applyQuranJourneyNone(empty(), QuranJourneyRow.engaged);
    expect(kind(record, QuranJourneyRow.engaged), QuranJourneyCellKind.none);
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.negative,
    );
    expect(
      kind(record, QuranJourneyRow.understood),
      QuranJourneyCellKind.unanswered,
    );
  });

  test('recitation with meaning still writes recitation for the same date', () {
    final record = empty().withQuran(
      QuranDimension.meaning,
      TernaryOutcome.positive,
    );
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.positive,
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    expect(
      kind(record, QuranJourneyRow.understood),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(record, QuranJourneyRow.engaged),
      QuranJourneyCellKind.recorded,
    );
  });

  test('recitation does not write meaning', () {
    final record = empty().withQuran(
      QuranDimension.reading,
      TernaryOutcome.positive,
    );
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
  });

  test('no other cross-group auto-fill is introduced', () {
    final reflection = empty().withQuran(
      QuranDimension.reflection,
      TernaryOutcome.positive,
    );
    expect(
      reflection.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
    expect(
      reflection.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );
    expect(
      reflection.quranOutcome(QuranDimension.consciousApplication),
      TernaryOutcome.unanswered,
    );

    final application = empty().withQuran(
      QuranDimension.consciousApplication,
      TernaryOutcome.positive,
    );
    expect(
      application.quranOutcome(QuranDimension.reflection),
      TernaryOutcome.unanswered,
    );
    expect(
      application.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
    expect(
      application.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );

    final tafsir = empty().withQuran(
      QuranDimension.tafsir,
      TernaryOutcome.positive,
    );
    expect(
      tafsir.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );
    expect(
      tafsir.quranOutcome(QuranDimension.reflection),
      TernaryOutcome.unanswered,
    );
  });

  test('DailyCheckIn v6 round-trip keeps independent quran outcomes', () {
    final original = empty()
        .withQuran(QuranDimension.reading, TernaryOutcome.positive)
        .withQuran(QuranDimension.reflection, TernaryOutcome.negative)
        .withQuran(
          QuranDimension.consciousApplication,
          TernaryOutcome.positive,
        );
    expect(original.schemaVersion, 6);
    expect(kDailyCheckInSchemaVersion, 6);
    final restored = DailyCheckIn.fromJson(original.toJson());
    expect(restored.schemaVersion, 6);
    expect(restored.toJson(), original.toJson());
    expect(
      kind(restored, QuranJourneyRow.engaged),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(restored, QuranJourneyRow.understood),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      kind(restored, QuranJourneyRow.reflected),
      QuranJourneyCellKind.none,
    );
    expect(
      kind(restored, QuranJourneyRow.applied),
      QuranJourneyCellKind.recorded,
    );
  });

  test('occupancy is a union of independent groups, not a winning stage', () {
    final rows = QuranJourneyRow.values;
    final both = empty()
        .withQuran(QuranDimension.reading, TernaryOutcome.positive)
        .withQuran(
          QuranDimension.consciousApplication,
          TernaryOutcome.positive,
        );
    expect(
      quranVisibleJourneyOccupancy(both, rows).kind,
      QuranJourneyCellKind.recorded,
    );
    expect(kind(both, QuranJourneyRow.engaged), QuranJourneyCellKind.recorded);
    expect(kind(both, QuranJourneyRow.applied), QuranJourneyCellKind.recorded);
    expect(quranVisibleJourneyOccupancy(both, rows).code, isNull);

    final noneEngaged = applyQuranJourneyNone(empty(), QuranJourneyRow.engaged);
    expect(
      quranVisibleJourneyOccupancy(noneEngaged, rows).kind,
      QuranJourneyCellKind.none,
    );
    expect(
      quranVisibleJourneyOccupancy(empty(), rows).kind,
      QuranJourneyCellKind.unanswered,
    );
  });

  test('journey L2 writes one letter without a schema bump', () {
    final worship = QuranJourneyRow.applied.l2Options.first;
    final record = applyQuranJourneyL2(
      empty(),
      QuranJourneyRow.applied,
      worship,
    );
    expect(quranJourneyCell(record, QuranJourneyRow.applied).code, 'W');
    expect(
      record.quranOutcome(QuranDimension.consciousApplication),
      TernaryOutcome.positive,
    );
    expect(record.schemaVersion, 6);
  });

  test('journey unanswered clears every item in that row only', () {
    final worship = QuranJourneyRow.applied.l2Options.first;
    final afterApplied = applyQuranJourneyL2(
      empty(),
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
      kind(cleared, QuranJourneyRow.applied),
      QuranJourneyCellKind.unanswered,
    );
    expect(
      cleared.quranOutcome(QuranDimension.consciousApplication),
      TernaryOutcome.unanswered,
    );
    expect(kind(cleared, QuranJourneyRow.engaged), QuranJourneyCellKind.none);
  });

  test('Home Journey dimensions follow the R1 ontology groups', () {
    expect(QuranJourneyRow.engaged.dimensions, engagementHomeRows);
    expect(QuranJourneyRow.understood.dimensions, understandingHomeRows);
    expect(QuranJourneyRow.reflected.dimensions, reflectionHomeRows);
    expect(QuranJourneyRow.applied.dimensions, applicationHomeRows);
  });

  test('30/90 Progress titles follow Home Journey groups', () {
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
