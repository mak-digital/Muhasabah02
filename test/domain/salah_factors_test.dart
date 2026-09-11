import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/salah_factors.dart';

void main() {
  test('Fajr includes sleep and waking cues', () {
    expect(
      SalahFactorCatalog.supportFor('fajr').map((factor) => factor.id),
      containsAll(['salah.sleptEarly', 'salah.alarmWorked']),
    );
    expect(
      SalahFactorCatalog.challengeFor('fajr').map((factor) => factor.id),
      contains('salah.overslept'),
    );
    expect(
      SalahFactorCatalog.challengeFor('fajr').map((factor) => factor.id),
      isNot(contains('salah.workCommitment')),
    );
  });

  test('daytime prayers omit Fajr-specific sleep cues', () {
    expect(
      SalahFactorCatalog.supportFor('dhuhr').map((factor) => factor.id),
      isNot(contains('salah.sleptEarly')),
    );
    expect(
      SalahFactorCatalog.supportFor('asr').map((factor) => factor.id),
      isNot(contains('salah.alarmWorked')),
    );
    expect(
      SalahFactorCatalog.challengeFor('isha').map((factor) => factor.id),
      isNot(contains('salah.overslept')),
    );
    expect(
      SalahFactorCatalog.challengeFor('dhuhr').map((factor) => factor.id),
      contains('salah.workCommitment'),
    );
  });
}
