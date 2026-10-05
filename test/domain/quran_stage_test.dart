import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
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

  test('understanding sitting does not write engagement', () {
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
      TernaryOutcome.unanswered,
    );
    expect(
      kind(record, QuranJourneyRow.understood),
      QuranJourneyCellKind.recorded,
    );
    expect(
      kind(record, QuranJourneyRow.engaged),
      QuranJourneyCellKind.unanswered,
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

  test('compact occupancy tap uses listing order, not semantic priority', () {
    final rows = QuranJourneyRow.values;
    expect(rows.first, QuranJourneyRow.applied);
    expect(rows.last, QuranJourneyRow.engaged);

    final appliedAndEngaged = empty()
        .withQuran(QuranDimension.reading, TernaryOutcome.positive)
        .withQuran(
          QuranDimension.consciousApplication,
          TernaryOutcome.positive,
        );
    expect(
      quranVisibleJourneyOpenRow(appliedAndEngaged, rows),
      QuranJourneyRow.applied,
    );
    expect(
      quranVisibleJourneyOpenRow(appliedAndEngaged, rows),
      isNot(QuranJourneyRow.engaged),
    );

    final engagedOnly = empty().withQuran(
      QuranDimension.reading,
      TernaryOutcome.positive,
    );
    expect(
      quranVisibleJourneyOpenRow(engagedOnly, rows),
      QuranJourneyRow.engaged,
    );

    expect(quranVisibleJourneyOpenRow(empty(), rows), QuranJourneyRow.applied);
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
    expect(QuranJourneyRow.engaged.dimensions, [
      QuranDimension.reading,
      QuranDimension.memorisation,
      QuranDimension.revision,
    ]);
    expect(QuranJourneyRow.understood.dimensions, [
      QuranDimension.meaning,
      QuranDimension.tafsir,
    ]);
    expect(QuranJourneyRow.reflected.dimensions, [
      QuranDimension.reflection,
    ]);
    expect(QuranJourneyRow.applied.dimensions, applicationHomeRows);
  });

  test('30/90 Progress titles follow daily duration rows', () {
    expect(QuranDimension.reading.progressCalendarTitle, 'Engagement');
    expect(
      QuranDimension.reading.progressCalendarSubtitle,
      'Recitation, memorisation and/or revision sitting',
    );
    expect(
      QuranDimension.meaning.progressCalendarTitle,
      'Understanding & reflection',
    );
    expect(
      QuranDimension.meaning.progressCalendarSubtitle,
      'Meaning and/or tafsir plus pondering',
    );
    expect(
      QuranDimension.consciousApplication.progressCalendarTitle,
      'Practical relevance',
    );
    expect(
      QuranDimension.consciousApplication.progressCalendarSubtitle,
      'Noticed implications or use of learnt verses',
    );
  });

  test('Journey copy does not claim attained spiritual states', () {
    for (final row in QuranJourneyRow.values) {
      expect(row.purpose.toLowerCase(), isNot(contains('transformation')));
      expect(row.purpose.toLowerCase(), isNot(contains('internalization')));
      expect(row.purpose.toLowerCase(), isNot(contains('comprehension')));
      expect(row.label, isNot(equals('Applied')));
      expect(row.label, isNot(equals('Understood')));
      expect(row.label, isNot(equals('Reflected')));
      expect(row.label, isNot(equals('Engaged')));
    }
    expect(QuranJourneyRow.engaged.label, 'Engagement');
    expect(QuranJourneyRow.understood.label, 'Understanding');
    expect(QuranJourneyRow.reflected.label, 'Reflection');
    expect(QuranJourneyRow.applied.label, 'Practical relevance');
  });

  test('conscious-application visible labels stay observational', () {
    final byId = {
      for (final option in ActivityCatalog.quranConsciousApplication)
        option.id: option.label,
    };
    expect(byId['improvedWorship'], 'Connected to worship');
    expect(byId['improvedCharacter'], 'Connected to character');
    expect(byId['improvedRelationship'], 'Connected to relationships');
    expect(byId['avoidedSin'], 'Avoided something I considered wrong');
    expect(byId['performedGoodDeed'], 'Did something I considered good');
    for (final label in byId.values) {
      expect(label.toLowerCase(), isNot(contains('improved')));
    }
    expect(
      QuranJourneyRow.applied.l2Options.map((option) => option.activityId),
      [
        'improvedWorship',
        'improvedCharacter',
        'improvedRelationship',
        'avoidedSin',
        'performedGoodDeed',
      ],
    );
  });

  test('persisted quran identifiers remain unchanged after copy changes', () {
    expect(kDailyCheckInSchemaVersion, 6);
    expect(QuranDimension.values.map((d) => d.name).toList(), [
      'reading',
      'meaning',
      'memorisation',
      'revision',
      'tafsir',
      'reflection',
      'consciousApplication',
      'applicationReflection',
    ]);
    expect(
      ActivityCatalog.quranConsciousApplication.map((o) => o.id),
      containsAll([
        'improvedWorship',
        'improvedCharacter',
        'improvedRelationship',
        'avoidedSin',
        'performedGoodDeed',
      ]),
    );
  });
}
