import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/ontology.dart';
import 'package:muhasabah02/domain/quran.dart';

/// Independent Qur'an Journey groups on Home / 7-day Progress.
///
/// Declaration order is listing order (practical-relevance first). It is not a
/// rank, score, prerequisite chain, or maturity ladder.
enum QuranJourneyRow { applied, reflected, understood, engaged }

enum QuranJourneyCellKind { unanswered, none, recorded }

class QuranJourneyL2 {
  const QuranJourneyL2({
    required this.code,
    required this.label,
    required this.dimension,
    required this.activityId,
  });

  final String code;
  final String label;
  final QuranDimension dimension;
  final String activityId;
}

class QuranJourneyCell {
  const QuranJourneyCell({required this.kind, this.code});

  final QuranJourneyCellKind kind;
  final String? code;
}

extension QuranJourneyRowX on QuranJourneyRow {
  String get label => switch (this) {
    QuranJourneyRow.applied => 'Applied',
    QuranJourneyRow.reflected => 'Reflected',
    QuranJourneyRow.understood => 'Understood',
    QuranJourneyRow.engaged => 'Engaged',
  };

  /// Home / Progress purpose copy. Broader wording review is deferred to R3.
  String get purpose => switch (this) {
    QuranJourneyRow.applied => 'Transformation',
    QuranJourneyRow.reflected => 'Internalization',
    QuranJourneyRow.understood => 'Comprehension',
    QuranJourneyRow.engaged => 'Contact with Qur’an',
  };

  Set<QuranConceptualGroup> get conceptualGroups => switch (this) {
    QuranJourneyRow.applied => {QuranConceptualGroup.practicalRelevance},
    QuranJourneyRow.reflected => {QuranConceptualGroup.reflection},
    QuranJourneyRow.understood => {
      QuranConceptualGroup.understandingActivities,
    },
    QuranJourneyRow.engaged => {
      QuranConceptualGroup.directEngagement,
      QuranConceptualGroup.memorisationRetention,
    },
  };

  /// Persisted daily dimensions for this group on Home / Progress.
  ///
  /// [QuranDimension.applicationReflection] is not a Home Journey cell.
  List<QuranDimension> get dimensions {
    return [
      for (final record in OntologyRegistry.quranDimensions)
        if (conceptualGroups.contains(record.group) &&
            record.dimension != QuranDimension.applicationReflection)
          record.dimension,
    ];
  }

  List<QuranJourneyL2> get l2Options => switch (this) {
    QuranJourneyRow.applied => const [
      QuranJourneyL2(
        code: 'W',
        label: 'Worship',
        dimension: QuranDimension.consciousApplication,
        activityId: 'improvedWorship',
      ),
      QuranJourneyL2(
        code: 'C',
        label: 'Character',
        dimension: QuranDimension.consciousApplication,
        activityId: 'improvedCharacter',
      ),
      QuranJourneyL2(
        code: 'R',
        label: 'Relationship',
        dimension: QuranDimension.consciousApplication,
        activityId: 'improvedRelationship',
      ),
      QuranJourneyL2(
        code: 'S',
        label: 'Avoided a sin',
        dimension: QuranDimension.consciousApplication,
        activityId: 'avoidedSin',
      ),
      QuranJourneyL2(
        code: 'G',
        label: 'Good deed',
        dimension: QuranDimension.consciousApplication,
        activityId: 'performedGoodDeed',
      ),
    ],
    QuranJourneyRow.reflected => const [
      QuranJourneyL2(
        code: 'R',
        label: 'Reflection',
        dimension: QuranDimension.reflection,
        activityId: 'privateReflection',
      ),
      QuranJourneyL2(
        code: 'T',
        label: 'Tadabbur',
        dimension: QuranDimension.reflection,
        activityId: 'tadabbur',
      ),
      QuranJourneyL2(
        code: 'I',
        label: 'Insight',
        dimension: QuranDimension.reflection,
        activityId: 'personalInsight',
      ),
    ],
    QuranJourneyRow.understood => const [
      QuranJourneyL2(
        code: 'T',
        label: 'Translation',
        dimension: QuranDimension.meaning,
        activityId: 'translation',
      ),
      QuranJourneyL2(
        code: 'M',
        label: 'Meaning',
        dimension: QuranDimension.meaning,
        activityId: 'recitedWithMeaning',
      ),
      QuranJourneyL2(
        code: 'F',
        label: 'Tafsir',
        dimension: QuranDimension.tafsir,
        activityId: 'readTafsir',
      ),
    ],
    QuranJourneyRow.engaged => const [
      QuranJourneyL2(
        code: 'R',
        label: 'Recitation',
        dimension: QuranDimension.reading,
        activityId: 'readIndependently',
      ),
      QuranJourneyL2(
        code: 'L',
        label: 'Listening',
        dimension: QuranDimension.reading,
        activityId: 'listened',
      ),
      QuranJourneyL2(
        code: 'M',
        label: 'Memorisation',
        dimension: QuranDimension.memorisation,
        activityId: 'newPortion',
      ),
      QuranJourneyL2(
        code: 'V',
        label: 'Revision',
        dimension: QuranDimension.revision,
        activityId: 'privateRevision',
      ),
    ],
  };
}

List<QuranJourneyRow> quranJourneyRowsFor(List<QuranDimension> display) {
  return [
    for (final row in QuranJourneyRow.values)
      if (row.dimensions.any(display.contains)) row,
  ];
}

/// Independent projection: only this group's stored dimensions are consulted.
QuranJourneyCell quranJourneyCell(DailyCheckIn? record, QuranJourneyRow row) {
  if (record == null) {
    return const QuranJourneyCell(kind: QuranJourneyCellKind.unanswered);
  }
  var anyPositive = false;
  var anyNegative = false;
  var anyRecorded = false;
  for (final dimension in row.dimensions) {
    final outcome = record.quranOutcome(dimension);
    if (outcome == TernaryOutcome.positive) anyPositive = true;
    if (outcome == TernaryOutcome.negative) anyNegative = true;
    if (outcome.isRecorded) anyRecorded = true;
  }
  if (anyPositive) {
    return QuranJourneyCell(
      kind: QuranJourneyCellKind.recorded,
      code: _letterFor(record, row),
    );
  }
  if (anyNegative || anyRecorded) {
    return const QuranJourneyCell(kind: QuranJourneyCellKind.none);
  }
  return const QuranJourneyCell(kind: QuranJourneyCellKind.unanswered);
}

/// Occupancy across independently computed groups. Not a highest-stage collapse.
QuranJourneyCell quranVisibleJourneyOccupancy(
  DailyCheckIn? record,
  Iterable<QuranJourneyRow> rows,
) {
  var anyRecorded = false;
  var anyNone = false;
  for (final row in rows) {
    switch (quranJourneyCell(record, row).kind) {
      case QuranJourneyCellKind.recorded:
        anyRecorded = true;
      case QuranJourneyCellKind.none:
        anyNone = true;
      case QuranJourneyCellKind.unanswered:
        break;
    }
  }
  if (anyRecorded) {
    return const QuranJourneyCell(kind: QuranJourneyCellKind.recorded);
  }
  if (anyNone) {
    return const QuranJourneyCell(kind: QuranJourneyCellKind.none);
  }
  return const QuranJourneyCell(kind: QuranJourneyCellKind.unanswered);
}

/// Sheet target for a compact occupancy tap. Listing order, not rank.
QuranJourneyRow quranVisibleJourneyOpenRow(
  DailyCheckIn? record,
  List<QuranJourneyRow> rows,
) {
  if (rows.isEmpty) return QuranJourneyRow.values.first;
  for (final row in rows) {
    if (quranJourneyCell(record, row).kind == QuranJourneyCellKind.recorded) {
      return row;
    }
  }
  for (final row in rows) {
    if (quranJourneyCell(record, row).kind == QuranJourneyCellKind.none) {
      return row;
    }
  }
  return rows.first;
}

String? _letterFor(DailyCheckIn record, QuranJourneyRow row) {
  if (row == QuranJourneyRow.engaged) {
    if (record.quranOutcome(QuranDimension.memorisation) ==
        TernaryOutcome.positive) {
      return 'M';
    }
    if (record.quranOutcome(QuranDimension.revision) ==
        TernaryOutcome.positive) {
      return 'V';
    }
    if (record.quranOutcome(QuranDimension.reading) ==
        TernaryOutcome.positive) {
      final id = record
          .activityFor(ActivityCatalog.quranKey(QuranDimension.reading))
          .id;
      if (id == 'listened') return 'L';
      return 'R';
    }
    return null;
  }
  for (final option in row.l2Options) {
    if (record.quranOutcome(option.dimension) != TernaryOutcome.positive) {
      continue;
    }
    final id = record
        .activityFor(ActivityCatalog.quranKey(option.dimension))
        .id;
    if (id == option.activityId) return option.code;
  }
  if (row == QuranJourneyRow.understood) {
    if (record.quranOutcome(QuranDimension.meaning) ==
        TernaryOutcome.positive) {
      return 'M';
    }
    if (record.quranOutcome(QuranDimension.tafsir) == TernaryOutcome.positive) {
      return 'F';
    }
  }
  if (row == QuranJourneyRow.reflected &&
      record.quranOutcome(QuranDimension.reflection) ==
          TernaryOutcome.positive) {
    return 'R';
  }
  if (row == QuranJourneyRow.applied &&
      record.quranOutcome(QuranDimension.consciousApplication) ==
          TernaryOutcome.positive) {
    return 'W';
  }
  return null;
}

DailyCheckIn applyQuranJourneyNone(DailyCheckIn record, QuranJourneyRow row) {
  var next = record;
  for (final dimension in row.dimensions) {
    next = next.withQuran(dimension, TernaryOutcome.negative);
  }
  return next;
}

DailyCheckIn applyQuranJourneyUnanswered(
  DailyCheckIn record,
  QuranJourneyRow row,
) {
  var next = record;
  for (final dimension in row.dimensions) {
    next = next.withQuran(dimension, TernaryOutcome.unanswered);
  }
  return next;
}

DailyCheckIn applyQuranJourneyL2(
  DailyCheckIn record,
  QuranJourneyRow row,
  QuranJourneyL2 option,
) {
  var next = record;
  for (final dimension in row.dimensions) {
    if (dimension == option.dimension) continue;
    next = next.withQuran(dimension, TernaryOutcome.unanswered);
  }
  return next.withQuranActivity(
    option.dimension,
    RecordedActivity(id: option.activityId),
  );
}

extension QuranDimensionJourneyX on QuranDimension {
  QuranJourneyRow get journeyRow {
    final group = OntologyRegistry.forQuranDimension(this).group;
    return switch (group) {
      QuranConceptualGroup.practicalRelevance ||
      QuranConceptualGroup.privatePracticalReflection =>
        QuranJourneyRow.applied,
      QuranConceptualGroup.reflection => QuranJourneyRow.reflected,
      QuranConceptualGroup.understandingActivities =>
        QuranJourneyRow.understood,
      QuranConceptualGroup.directEngagement ||
      QuranConceptualGroup.memorisationRetention => QuranJourneyRow.engaged,
    };
  }

  /// 30/90 Progress title — same L1 name as Home / 7-day.
  String get progressCalendarTitle => journeyRow.label;

  /// Purpose, plus the Home L2 name when one group has several stored rows.
  String get progressCalendarSubtitle {
    final detail = switch (this) {
      QuranDimension.reading => 'Recitation',
      QuranDimension.meaning => 'Meaning',
      QuranDimension.memorisation => 'Memorisation',
      QuranDimension.revision => 'Revision',
      QuranDimension.tafsir => 'Tafsir',
      QuranDimension.reflection ||
      QuranDimension.consciousApplication ||
      QuranDimension.applicationReflection => null,
    };
    final purpose = journeyRow.purpose;
    if (detail == null) return purpose;
    return '$purpose · $detail';
  }
}
