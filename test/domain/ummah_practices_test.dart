import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/ummah_practices.dart';

void main() {
  test(
    'Ummah V1 keeps the six existing rows and does not add community service',
    () {
      expect(ummahHomeRows.map((row) => row.storageKey), [
        'ummah.masjidAttendance',
        'ummah.dawahByCharacter',
        'ummah.supportedOppressed',
        'ummah.unityEfforts',
        'ummah.prayedForUmmah',
        'ummah.earthCare',
      ]);
      expect(
        ActivityCatalog.forHomeTrace('ummah.masjidAttendance').first.label,
        'I attended a beneficial masjid class or gathering.',
      );
      expect(ActivityCatalog.forHomeTrace('ummah.communityService'), isEmpty);
      expect(ActivityCatalog.forHomeTrace('ummah.prayedForUmmah').length, 6);
      expect(
        ActivityCatalog.forHomeTrace('ummah.supportedOppressed').length,
        7,
      );
    },
  );

  test(
    'unanswered stays distinct from prefer not and no relevant opportunity',
    () {
      final catalog = ummahCatalogFor('ummah.masjidAttendance');
      expect(catalog.length, 6);
      expect(catalog[4].id, UmmahObservationIds.preferNot);
      expect(catalog[3].id, 'ummah.masjidAttendance.noOpportunity');
      expect(catalog[3].ternary, TernaryOutcome.positive);
      expect(catalog.last.id, ActivityIds.unanswered);
      expect(catalog[1].id, 'ummah.masjidAttendance.remote');

      var record = writeUmmahPractice(
        DailyCheckIn.empty('2026-10-17'),
        'ummah.earthCare',
        const UmmahPracticeCapture(primaryId: UmmahObservationIds.preferNot),
      );
      expect(record.homeTrace('ummah.earthCare').isRecorded, isTrue);
      expect(
        record.activityFor('ummah.earthCare').id,
        UmmahObservationIds.preferNot,
      );

      record = writeUmmahPractice(
        record,
        'ummah.earthCare',
        const UmmahPracticeCapture(),
      );
      expect(record.homeTrace('ummah.earthCare'), TernaryOutcome.unanswered);
    },
  );

  test('did not recall dua is recorded and is not a verdict', () {
    expect(
      ummahKindFor('ummah.prayedForUmmah.didNotRecall'),
      UmmahResponseKind.noSituation,
    );
    final option = ActivityCatalog.forHomeTrace('ummah.prayedForUmmah')
        .firstWhere((item) => item.id == 'ummah.prayedForUmmah.didNotRecall');
    expect(option.ternary, TernaryOutcome.positive);
    expect(option.label, 'I did not recall making such du’a today.');
  });

  test('legacy noticed without an activity id is not remapped', () {
    final legacy = DailyCheckIn.empty('2026-10-17')
        .withHomeTrace('ummah.masjidAttendance', TernaryOutcome.positive);
    expect(
      legacy.activityFor('ummah.masjidAttendance').id,
      ActivityIds.unanswered,
    );
  });

  test('Ummah primary catalog does not require a note', () {
    final record = writeUmmahPractice(
      DailyCheckIn.empty('2026-10-17'),
      'ummah.supportedOppressed',
      const UmmahPracticeCapture(primaryId: 'ummah.supportedOppressed.madeDua'),
    );
    expect(
      record.homeTrace('ummah.supportedOppressed'),
      TernaryOutcome.positive,
    );
    expect(record.homeTraceFactors['ummah.supportedOppressed'], isNull);
    expect(ummahEvidenceNote(record, 'ummah.supportedOppressed'), isNull);
  });
}
