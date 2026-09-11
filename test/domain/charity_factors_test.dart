import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/charity_factors.dart';

void main() {
  test(
    'charity Giving and Care rows share one helping and distracting catalog',
    () {
      const labels = [
        'Values & Beliefs',
        'Relationships & Trust',
        'Responsibility & Reciprocity',
        'Social Influence & Leadership',
        'Capacity & Resources',
      ];
      const barriers = [
        'Financial Constraints',
        'Trust Deficits',
        'Relationship Conflicts',
        'Organizational Weaknesses',
        'Competing Priorities & Low Engagement',
      ];
      for (final key in [
        'charity.voluntary',
        'charity.householdGiving',
        'charity.community',
        'charity.educational',
        'charity.emergency',
        'charity.financialStress',
      ]) {
        expect(
          helpingFactorsForHomeTrace(key)
              .map((factor) => factor.label)
              .toList(),
          labels,
        );
        expect(
          distractingFactorsForHomeTrace(key)
              .map((factor) => factor.label)
              .toList(),
          barriers,
        );
      }
      expect(
        helpingFactorsForHomeTrace('charity.voluntary')
            .map((factor) => factor.id),
        isNot(contains('quran.studyCircle')),
      );
      expect(
        CharityFactorCatalog.labelFor(
          'charity.religiousMoralMotivation',
          'positive',
        ),
        'Religious/Moral Motivation',
      );
      expect(
        helpingFactorsForHomeTrace('dhikr.postFardFajr')
            .any((factor) => factor.id == 'quran.studyCircle'),
        isTrue,
      );
    },
  );
}
