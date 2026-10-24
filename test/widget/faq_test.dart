import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/faq.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/settings/faq_screen.dart';

import '../support/test_app.dart';

void main() {
  test('faq copy does not score or prescribe', () {
    final blob = [
      Copy.faqPurpose,
      for (final entry in faqEntries) '${entry.question} ${entry.answer}',
      for (final table in [baselineAspirationCompare, manageCheckInsCompare])
        for (final row in table.rows) '${row.label} ${row.left} ${row.right}',
    ].join(' ').toLowerCase();
    expect(blob, isNot(contains('you should')));
    expect(blob, isNot(contains('you must')));
    expect(blob, contains('not recorded is not the same as missed'));
    expect(blob, contains('manage past check-ins'));
    expect(blob, contains('recorded days'));
    expect(blob, contains('rights of others'));
    expect(blob, contains('relationship score'));
    expect(blob, contains('never congratulates anyone for being learned'));
    expect(blob, contains('never congratulates anyone for being productive'));
    expect(blob, contains('never shames a body'));
    expect(blob, contains('a smile is sadaqah'));
    expect(blob, contains('the ummah is global'));
    expect(blob, contains('not a revival programme'));
    expect(blob, contains('failed revival'));
    expect(blob, contains('not a relapse'));
    expect(blob, contains('sleep stays on physical health'));
    expect(blob, contains('physical health & energy learn & practice'));
    expect(blob, contains('wealth & stewardship learn & practice'));
    expect(blob, contains('ummah learn & practice'));
    expect(blob, contains('qur’an to learn & practice'));
    expect(blob, contains('salah & prayer quality learn & practice'));
    expect(blob, contains('fasting learn & practice'));
    expect(blob, contains('charity learn & practice'));
    expect(blob, contains('hajj learn & practice'));
    expect(blob, contains('personal mix'));
    expect(blob, contains('manual baseline'));
    expect(blob, contains('not counted from check-ins'));
    expect(blob, contains('does not encrypt the files'));
    expect(blob, contains('does not calculate whether hajj is obligatory'));
    expect(blob, contains('this domain is not active in this version'));
    expect(blob, contains('30-day progress'));
    expect(blob, contains('carry-forward is not a fail'));
    expect(blob, contains('unticked stays unanswered'));
    expect(blob, contains('private recorder'));
    expect(blob, contains('record what you noticed'));
    expect(blob, contains('factors are not causes'));
    expect(blob, contains('demonstration, not a target'));
    expect(faqPaddedNumberForId(kFaqManualBaseline), '21');
    expect(faqEntries.first.question, contains('score me or keep streaks'));
    expect(
      faqEntries
          .where((entry) => !entry.isCurrentVersion)
          .map((entry) => entry.domain),
      containsAll({
        MonitorDomain.knowledge,
        MonitorDomain.time,
        MonitorDomain.health,
        MonitorDomain.wealth,
        MonitorDomain.ummah,
        MonitorDomain.hajj,
        MonitorDomain.productivity,
      }),
    );
    expect(
      faqEntries
          .where((entry) => entry.domain == MonitorDomain.dhikr)
          .single
          .isCurrentVersion,
      isTrue,
    );
  });

  testWidgets('settings open FAQ clarifications', (tester) async {
    tester.view.physicalSize = const Size(400, 18000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.faqTitle));
    await tester.tap(find.text(Copy.faqTitle));
    await tester.pumpAndSettle();
    expect(find.byType(FaqScreen), findsOneWidget);
    expect(find.text(Copy.faqPurpose), findsOneWidget);
    expect(
      tester.widget<Text>(find.text(Copy.faqPurpose)).textAlign,
      TextAlign.justify,
    );
    expect(find.text(Copy.faqNote), findsOneWidget);
    expect(find.text(Copy.faqThisVersionHeading), findsOneWidget);
    expect(find.text('Purpose'), findsOneWidget);
    expect(find.text('Your mix'), findsOneWidget);
    expect(find.text('Live domains'), findsOneWidget);
    expect(find.text(Copy.faqNotApplicableHeading), findsOneWidget);
    expect(find.text(Copy.faqNotApplicableNote), findsOneWidget);
    expect(
      find.textContaining('01. Does the app score me or keep streaks?'),
      findsOneWidget,
    );
    expect(find.textContaining('02. What is missing'), findsOneWidget);
    expect(
      find.textContaining('03. Are my records private if the phone is lost?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('04. Can I hide domains I do not want to monitor?'),
      findsOneWidget,
    );
    expect(find.textContaining('05. What is a Personal mix?'), findsOneWidget);
    expect(
      find.textContaining(
        'What are Baselines compared with Personal Aspirations?',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.textContaining(
        'What are Baselines compared with Personal Aspirations?',
      ),
    );
    await tester.tap(
      find.textContaining(
        'What are Baselines compared with Personal Aspirations?',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('frozen snapshot'), findsNothing);
    expect(find.text('Based on'), findsOneWidget);
    expect(find.text('What did I record in that period?'), findsOneWidget);
    expect(find.text('What do I personally hope for?'), findsOneWidget);
    expect(
      find.textContaining('21. How do I write a Manual baseline?'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.textContaining('19. What is Manage past check-ins'),
    );
    await tester.tap(find.textContaining('19. What is Manage past check-ins'));
    await tester.pumpAndSettle();
    expect(find.textContaining('housekeeping'), findsOneWidget);
    expect(find.text('Correct or remove a saved day'), findsOneWidget);
    expect(find.text('Look at what was recorded'), findsOneWidget);
    expect(
      find.textContaining('11. Does Hadith & Living Sunnah'),
      findsOneWidget,
    );
    expect(
      find.textContaining('12. Does Dhikr & Dua score my remembrance?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('13. Does Fasting score my sawm?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('14. Does Character & Morals grade me?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('15. Does Rights of Others score my relationships?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('16. Does Charity score my giving?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('17. What do the 30-day Progress graphs show?'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ExpansionTile),
        matching: find.textContaining(
          '24. Does Knowledge & Beneficial Speech grade how learned I am?',
        ),
      ),
      findsNothing,
    );
    await tester.ensureVisible(
      find.textContaining(
        '24. Does Knowledge & Beneficial Speech grade how learned I am?',
      ),
    );
    expect(find.text(Copy.faqNotApplicableLabel), findsWidgets);
    for (final title in const [
      '25. Does Time & Barakah score my productivity?',
      '26. Does Physical Health & Energy grade my body?',
      '27. Does Wealth & Stewardship score my money?',
      '28. Does Ummah grade my social life?',
      '29. Does Hajj tell me I must go this year?',
      '30. Does Productivity score my output?',
    ]) {
      final finder = find.textContaining(title, skipOffstage: false);
      await tester.ensureVisible(finder);
      expect(finder, findsOneWidget);
    }
    expect(
      find.descendant(
        of: find.byType(FaqScreen),
        matching: find.byType(ExpansionTile, skipOffstage: false),
      ),
      findsNWidgets(faqEntries.where((entry) => entry.isCurrentVersion).length),
    );
  });
}
