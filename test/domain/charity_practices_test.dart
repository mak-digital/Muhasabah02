import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/charity_practices.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test('Charity V1 keeps six existing rows and does not add observations', () {
    expect(charityHomeRows.map((row) => row.storageKey), [
      'charity.voluntary',
      'charity.householdGiving',
      'charity.community',
      'charity.educational',
      'charity.emergency',
      'charity.financialStress',
    ]);
    expect(
      ActivityCatalog.forHomeTrace('charity.voluntary')
          .map((item) => item.label),
      [
        'Not recorded',
        'Gave voluntary charity',
        'Intended or arranged to give',
        'Had an opportunity but did not give',
        'No relevant opportunity today',
        'Prefer not to record',
      ],
    );
    expect(ActivityCatalog.forHomeTrace('charity.financialStress').length, 7);
  });

  test('not recorded stays distinct from prefer not and no opportunity', () {
    final catalog = charityCatalogFor('charity.community');
    expect(catalog.first.id, ActivityIds.unanswered);
    expect(catalog.last.id, CharityObservationIds.preferNot);
    expect(catalog[4].id, 'charity.community.noOpportunity');
    expect(catalog[4].ternary, TernaryOutcome.positive);

    var record = writeCharityPractice(
      DailyCheckIn.empty('2026-10-17'),
      'charity.voluntary',
      const CharityPracticeCapture(primaryId: CharityObservationIds.preferNot),
    );
    expect(record.homeTrace('charity.voluntary').isRecorded, isTrue);
    expect(
      record.activityFor('charity.voluntary').id,
      CharityObservationIds.preferNot,
    );

    record = writeCharityPractice(
      record,
      'charity.voluntary',
      const CharityPracticeCapture(),
    );
    expect(record.homeTrace('charity.voluntary'), TernaryOutcome.unanswered);
  });

  test('legacy noticed without an activity id is not remapped', () {
    final legacy = DailyCheckIn.empty('2026-10-17')
        .withHomeTrace('charity.voluntary', TernaryOutcome.positive);
    expect(legacy.activityFor('charity.voluntary').id, ActivityIds.unanswered);
  });

  test('Zakat keeps stored names and distinct labels', () {
    expect(ZakatStatus.due.label, 'Zakat due but not yet paid');
    expect(ZakatStatus.planned.label, 'Arranged or initiated payment');
    expect(ZakatStatus.paid.label, 'Paid Zakat due');
    expect(ZakatStatus.notApplicable.label, 'Zakat not currently due');
    expect(ZakatStatus.reviewing.label, 'Reviewing whether Zakat is due');
    expect(ZakatStatus.preferNot.label, 'Prefer not to record');
    expect(zakatFromJson('due'), ZakatStatus.due);
    expect(zakatFromJson('planned'), ZakatStatus.planned);
    expect(ZakatStatus.preferNot.isRecorded, isTrue);
    expect(ZakatStatus.unanswered.isRecorded, isFalse);
  });

  test('Charity sits after Rights of Others and before Knowledge', () {
    expect(
      MonitorDomain.values.indexOf(MonitorDomain.charity),
      MonitorDomain.values.indexOf(MonitorDomain.huquq) + 1,
    );
    expect(
      MonitorDomain.values.indexOf(MonitorDomain.knowledge),
      MonitorDomain.values.indexOf(MonitorDomain.charity) + 1,
    );
  });
}
