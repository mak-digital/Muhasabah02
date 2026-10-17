import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/faq.dart';
import 'package:muhasabah02/presentation/settings/faq_screen.dart';

import '../support/test_app.dart';

void main() {
  test('faq copy does not score or prescribe', () {
    final blob = [
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
    expect(faqPaddedNumberForId(kFaqManualBaseline), '03');
  });

  testWidgets('settings open FAQ clarifications', (tester) async {
    tester.view.physicalSize = const Size(400, 8200);
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
    expect(find.text(Copy.faqNote), findsOneWidget);
    expect(find.textContaining('01. What is missing'), findsOneWidget);
    expect(find.textContaining('02. What are Baselines'), findsOneWidget);
    expect(
      find.textContaining('03. How do I write a Manual baseline?'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'What are Baselines compared with Personal Aspirations?',
      ),
      findsOneWidget,
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
      find.textContaining('11. Can I show Islamic dates?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('12. Can I hide domains I do not want to monitor?'),
      findsOneWidget,
    );
    expect(find.textContaining('13. What is a Personal mix?'), findsOneWidget);
    expect(
      find.textContaining('14. What is Manage past check-ins'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.textContaining('14. What is Manage past check-ins'),
    );
    await tester.tap(find.textContaining('14. What is Manage past check-ins'));
    await tester.pumpAndSettle();
    expect(find.textContaining('housekeeping of saved days'), findsOneWidget);
    expect(find.text('Correct or remove a saved day'), findsOneWidget);
    expect(find.text('Look at what was recorded'), findsOneWidget);
    await tester.ensureVisible(
      find.textContaining('23. Does Ummah grade my social life?'),
    );
    expect(
      find.textContaining('15. Does Character & Morals grade me?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('16. Does Rights of Others score my relationships?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('17. Does Charity score my giving?'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        '18. Does Knowledge & Beneficial Speech grade how learned I am?',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        '19. Does Hadith & Living Sunnah score my revival of the Sunnah?',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('20. Does Time & Barakah score my productivity?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('21. Does Physical Health & Energy grade my body?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('22. Does Wealth & Stewardship score my money?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('23. Does Ummah grade my social life?'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.textContaining('24. Does Dhikr & Dua score my remembrance?'),
    );
    expect(
      find.textContaining('24. Does Dhikr & Dua score my remembrance?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('25. Does Fasting score my sawm?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('26. Does Hajj tell me I must go this year?'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.textContaining('27. Are my records private if the phone is lost?'),
    );
    expect(
      find.textContaining('27. Are my records private if the phone is lost?'),
      findsOneWidget,
    );
  });
}
