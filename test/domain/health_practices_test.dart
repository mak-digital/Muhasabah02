import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/health_practices.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test('Health V1 keeps eight rows and four bands', () {
    expect(healthHomeRows.length, 8);
    expect(healthHomeRows.map((row) => row.storageKey), [
      'health.sleepQuality',
      'health.sleepAmount',
      'health.movement',
      'health.energyForIbadah',
      'health.nutrition',
      'health.hydration',
      'health.illnessCare',
      'health.avoidedHarm',
    ]);
    expect(healthHomeRows.map((row) => row.band).toSet(), {
      'Sleep',
      'Strength',
      'Sustenance',
      'Illness & harm',
    });
    expect(
      [
        for (final row in healthHomeRows)
          ActivityCatalog.forHomeTrace(row.storageKey).first.label,
      ],
      [
        'I slept well and felt reasonably refreshed.',
        'I had sufficient sleep for my circumstances.',
        'I engaged in suitable physical movement or activity.',
        'I had sufficient energy for my worship and responsibilities.',
        'I ate in a reasonably balanced and nourishing way.',
        'I maintained hydration appropriate to my needs.',
        'I sought appropriate medical advice or care when needed.',
        'I consciously avoided a foreseeable harm to my health.',
      ],
    );
  });

  test('unanswered stays distinct from prefer not to record', () {
    final catalog = healthCatalogFor('health.sleepQuality');
    expect(catalog.length, 7);
    expect(catalog[5].id, HealthObservationIds.preferNot);
    expect(catalog[5].ternary, TernaryOutcome.positive);
    expect(catalog.last.id, ActivityIds.unanswered);
    expect(catalog.last.ternary, TernaryOutcome.unanswered);

    var record = DailyCheckIn.empty('2026-10-17');
    expect(readHealthPractice(record, 'health.sleepQuality').isPrimaryRecorded, isFalse);

    record = writeHealthPractice(
      record,
      'health.sleepQuality',
      const HealthPracticeCapture(
        primaryId: HealthObservationIds.preferNot,
        note: 'Private',
      ),
    );
    expect(record.homeTrace('health.sleepQuality').isRecorded, isTrue);
    expect(
      record.activityFor('health.sleepQuality').id,
      HealthObservationIds.preferNot,
    );
    expect(readHealthPractice(record, 'health.sleepQuality').note, 'Private');

    record = writeHealthPractice(
      record,
      'health.sleepQuality',
      const HealthPracticeCapture(),
    );
    expect(record.homeTrace('health.sleepQuality'), TernaryOutcome.unanswered);
    expect(readHealthPractice(record, 'health.sleepQuality').note, isEmpty);
  });

  test('sleeping poorly is recorded and is not a lapse', () {
    expect(
      healthKindFor('health.sleepQuality.sleptPoorly'),
      HealthResponseKind.difficulty,
    );
    final option = ActivityCatalog.forHomeTrace(
      'health.sleepQuality',
    ).firstWhere((item) => item.id == 'health.sleepQuality.sleptPoorly');
    expect(option.ternary, TernaryOutcome.positive);
    expect(
      healthKindFor('health.sleepAmount.necessaryDuties'),
      HealthResponseKind.constrained,
    );
    expect(
      healthKindFor('health.illnessCare.noIllness'),
      HealthResponseKind.noSituation,
    );
    expect(
      healthKindFor('health.illnessCare.delayedCare'),
      HealthResponseKind.lapse,
    );
  });

  test('Health primary catalog does not require a note', () {
    final record = writeHealthPractice(
      DailyCheckIn.empty('2026-10-17'),
      'health.hydration',
      const HealthPracticeCapture(primaryId: 'health.hydration.appropriate'),
    );
    expect(record.homeTrace('health.hydration'), TernaryOutcome.positive);
    expect(record.homeTraceFactors['health.hydration'], isNull);
  });
}
