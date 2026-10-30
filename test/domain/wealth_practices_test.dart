import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/wealth_practices.dart';

void main() {
  test('Wealth V1 keeps three existing rows and adds lawful management', () {
    expect(wealthHomeRows.map((row) => row.storageKey), [
      'wealth.halalEarning',
      'wealth.avoidedRiba',
      'wealth.avoidedWaste',
      'wealth.lawfulManagement',
    ]);
    expect(wealthHomeRows.map((row) => row.band).toSet(), {
      'Earning',
      'Restraint',
      'Lawful wealth management',
    });
    expect(
      ActivityCatalog.forHomeTrace('wealth.halalEarning').first.label,
      'My income or work today came from a source I reasonably understand to be lawful.',
    );
    expect(ActivityCatalog.forHomeTrace('wealth.lawfulManagement').length, 8);
    expect(ActivityCatalog.forHomeTrace('wealth.gaveSadaqah'), isEmpty);
  });

  test(
    'unanswered stays distinct from prefer not and no relevant activity',
    () {
      final catalog = wealthCatalogFor('wealth.avoidedRiba');
      expect(catalog.length, 7);
      expect(catalog[5].id, WealthObservationIds.preferNot);
      expect(catalog[4].id, 'wealth.avoidedRiba.noTransaction');
      expect(catalog[4].ternary, TernaryOutcome.positive);
      expect(catalog.last.id, ActivityIds.unanswered);

      var record = writeWealthPractice(
        DailyCheckIn.empty('2026-10-17'),
        'wealth.avoidedWaste',
        const WealthPracticeCapture(primaryId: WealthObservationIds.preferNot),
      );
      expect(record.homeTrace('wealth.avoidedWaste').isRecorded, isTrue);
      expect(
        record.activityFor('wealth.avoidedWaste').id,
        WealthObservationIds.preferNot,
      );

      record = writeWealthPractice(
        record,
        'wealth.avoidedWaste',
        const WealthPracticeCapture(),
      );
      expect(
        record.homeTrace('wealth.avoidedWaste'),
        TernaryOutcome.unanswered,
      );
    },
  );

  test('unresolved concern is recorded and is not a lapse', () {
    expect(
      wealthKindFor('wealth.halalEarning.unresolvedConcern'),
      WealthResponseKind.difficulty,
    );
    final option = ActivityCatalog.forHomeTrace(
      'wealth.halalEarning',
    ).firstWhere((item) => item.id == 'wealth.halalEarning.unresolvedConcern');
    expect(option.ternary, TernaryOutcome.positive);
  });

  test('Wealth primary catalog does not require a note', () {
    final record = writeWealthPractice(
      DailyCheckIn.empty('2026-10-17'),
      'wealth.lawfulManagement',
      const WealthPracticeCapture(
        primaryId: 'wealth.lawfulManagement.managedResponsibly',
      ),
    );
    expect(
      record.homeTrace('wealth.lawfulManagement'),
      TernaryOutcome.positive,
    );
    expect(record.homeTraceFactors['wealth.lawfulManagement'], isNull);
  });
}
