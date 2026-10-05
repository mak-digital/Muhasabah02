import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quran_duration.dart';
import 'package:muhasabah02/presentation/shared/salah_activity_mark.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

void main() {
  test('Qur’an duration colours twin Salah activity marks', () {
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.over20),
      SalahActivityMark.congregationOnTime,
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.min15to20),
      SalahActivityMark.joinedCongregationLate,
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.min10to15),
      SalahActivityMark.smallCongregation,
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.min5to10),
      SalahActivityMark.aloneOnTime,
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.min3to5),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.notNoticed),
      SalahActivityMark.prayedLate,
    );
    expect(
      SalahActivityMark.colourForId(ActivityIds.unanswered),
      SalahActivityMark.unanswered,
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.min3to5),
      isNot(SalahActivityMark.excused),
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.notNoticed),
      isNot(SalahActivityMark.missed),
    );
    expect(
      SalahActivityMark.colourForId(QuranDurationIds.notNoticed),
      isNot(SalahActivityMark.missedMadeUp),
    );
  });

  test('not noticed is outlined prayed-late; sitting is filled', () {
    expect(
      SalahActivityMark.quranDurationKind(QuranDurationIds.min3to5),
      MarkerKind.filled,
    );
    expect(
      SalahActivityMark.quranDurationKind(QuranDurationIds.notNoticed),
      MarkerKind.outlined,
    );
    expect(
      SalahActivityMark.quranDurationKind(ActivityIds.unanswered),
      MarkerKind.unanswered,
    );
  });

  test('duration catalogs name the row and keep verbs', () {
    expect(
      ActivityCatalog.forQuran(QuranDimension.reading).first.label,
      'Engaged more than 20 minutes — Engagement',
    );
    expect(
      ActivityCatalog.forQuran(QuranDimension.meaning)
          .firstWhere((option) => option.id == QuranDurationIds.notNoticed)
          .label,
      'I did not notice this today — Understanding & reflection',
    );
    expect(
      ActivityCatalog.forQuran(QuranDimension.consciousApplication)
          .firstWhere((option) => option.id == QuranDurationIds.min3to5)
          .label,
      'Involved 3–5 minutes — Practical relevance',
    );
  });
}
