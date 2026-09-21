import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/quran.dart';

/// Highest recorded Qur’an stage for a day. Used on compact Home weeks.
enum QuranStage { none, engagement, understanding, reflection, application }

extension QuranStageX on QuranStage {
  String get label => switch (this) {
    QuranStage.none => 'None',
    QuranStage.engagement => 'Engaged',
    QuranStage.understanding => 'Understood',
    QuranStage.reflection => 'Reflected',
    QuranStage.application => 'Applied',
  };

  String get purpose => switch (this) {
    QuranStage.none => 'No activity',
    QuranStage.engagement => 'Contact with Qur’an',
    QuranStage.understanding => 'Comprehension',
    QuranStage.reflection => 'Internalization',
    QuranStage.application => 'Transformation',
  };

  String get band => switch (this) {
    QuranStage.none => kQuranEngagementBand,
    QuranStage.engagement => kQuranEngagementBand,
    QuranStage.understanding => kQuranUnderstandingBand,
    QuranStage.reflection => kQuranReflectionBand,
    QuranStage.application => kQuranApplicationBand,
  };

  QuranJourneyRow? get journeyRow => switch (this) {
    QuranStage.none => null,
    QuranStage.engagement => QuranJourneyRow.engaged,
    QuranStage.understanding => QuranJourneyRow.understood,
    QuranStage.reflection => QuranJourneyRow.reflected,
    QuranStage.application => QuranJourneyRow.applied,
  };
}

/// Home matrix rows. Applied is first (ladder). Observational, not a rank.
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

  String get purpose => switch (this) {
    QuranJourneyRow.applied => 'Transformation',
    QuranJourneyRow.reflected => 'Internalization',
    QuranJourneyRow.understood => 'Comprehension',
    QuranJourneyRow.engaged => 'Contact with Qur’an',
  };

  QuranStage get stage => switch (this) {
    QuranJourneyRow.applied => QuranStage.application,
    QuranJourneyRow.reflected => QuranStage.reflection,
    QuranJourneyRow.understood => QuranStage.understanding,
    QuranJourneyRow.engaged => QuranStage.engagement,
  };

  List<QuranDimension> get dimensions => switch (this) {
    QuranJourneyRow.applied => applicationHomeRows,
    QuranJourneyRow.reflected => reflectionHomeRows,
    QuranJourneyRow.understood => understandingHomeRows,
    QuranJourneyRow.engaged => engagementHomeRows,
  };

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

/// Application > Reflection > Understanding > Engagement > None.
QuranStage quranStageFor(
  DailyCheckIn? record, {
  List<QuranDimension>? only,
}) {
  if (record == null) return QuranStage.none;
  bool engaged(QuranDimension dimension) {
    if (only != null && !only.contains(dimension)) return false;
    return record.quranOutcome(dimension) == TernaryOutcome.positive;
  }

  if (engaged(QuranDimension.consciousApplication)) {
    return QuranStage.application;
  }
  if (engaged(QuranDimension.reflection)) {
    return QuranStage.reflection;
  }
  if (engaged(QuranDimension.meaning) || engaged(QuranDimension.tafsir)) {
    return QuranStage.understanding;
  }
  if (engaged(QuranDimension.reading) ||
      engaged(QuranDimension.memorisation) ||
      engaged(QuranDimension.revision)) {
    return QuranStage.engagement;
  }
  return QuranStage.none;
}

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
    final id = record.activityFor(ActivityCatalog.quranKey(option.dimension)).id;
    if (id == option.activityId) return option.code;
  }
  if (row == QuranJourneyRow.understood) {
    if (record.quranOutcome(QuranDimension.meaning) == TernaryOutcome.positive) {
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

DailyCheckIn applyQuranJourneyNone(
  DailyCheckIn record,
  QuranJourneyRow row,
) {
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

List<String> quranStageActivityLabels(DailyCheckIn record) {
  final labels = <String>[];
  for (final dimension in QuranDimension.values) {
    if (dimension == QuranDimension.applicationReflection) continue;
    if (record.quranOutcome(dimension) != TernaryOutcome.positive) continue;
    final activity = record.activityFor(ActivityCatalog.quranKey(dimension));
    final option = ActivityCatalog.findQuran(dimension, activity.id);
    var label = option?.label ?? dimension.label;
    if (activity.id == ActivityIds.other &&
        (activity.customText?.trim().isNotEmpty ?? false)) {
      label = activity.customText!.trim();
    }
    labels.add(label);
  }
  return labels;
}

String? quranStageNote(DailyCheckIn record) {
  final personal = record.personalReflectionText?.trim();
  if (personal != null && personal.isNotEmpty) return personal;
  final situation = record.situationNotes.customText?.trim();
  if (situation != null && situation.isNotEmpty) return situation;
  return null;
}

extension QuranDimensionJourneyX on QuranDimension {
  QuranJourneyRow get journeyRow => switch (this) {
    QuranDimension.consciousApplication ||
    QuranDimension.applicationReflection => QuranJourneyRow.applied,
    QuranDimension.reflection => QuranJourneyRow.reflected,
    QuranDimension.meaning || QuranDimension.tafsir =>
      QuranJourneyRow.understood,
    QuranDimension.reading ||
    QuranDimension.memorisation ||
    QuranDimension.revision => QuranJourneyRow.engaged,
  };

  /// 30/90 Progress title — same L1 name as Home / 7-day.
  String get progressCalendarTitle => journeyRow.label;

  /// Purpose, plus the Home L2 name when one stage has several stored rows.
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
