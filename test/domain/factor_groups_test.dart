import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/factor_groups.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test('salah activity maps to helping, distracting, both, or none', () {
    expect(factorGroupsForSalahActivity('aloneOnTime'), FactorGroups.helping);
    expect(factorGroupsForSalahActivity('missed'), FactorGroups.distracting);
    expect(factorGroupsForSalahActivity('prayedLate'), FactorGroups.both);
    expect(factorGroupsForSalahActivity('missedMadeUp'), FactorGroups.both);
    expect(factorGroupsForSalahActivity('unanswered'), FactorGroups.none);
    expect(factorGroupsForSalahActivity('other'), FactorGroups.none);
  });

  test('ternary maps to a single factor group', () {
    expect(
      factorGroupsForTernary(TernaryOutcome.unanswered),
      FactorGroups.none,
    );
    expect(
      factorGroupsForTernary(TernaryOutcome.positive),
      FactorGroups.helping,
    );
    expect(
      factorGroupsForTernary(TernaryOutcome.negative),
      FactorGroups.distracting,
    );
  });
}
