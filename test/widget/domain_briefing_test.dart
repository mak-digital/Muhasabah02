import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/domain_briefing.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  test('Huquq briefing keeps examples as grouped bullets', () {
    expect(huquqBriefing.lead.first, contains('not a chore list'));
    expect(huquqBriefing.groups.map((group) => group.title).toList(), [
      'Household',
      'Extended family',
      'Neighbours and work',
      'The people',
      'Care in hardship',
    ]);
    expect(
      huquqBriefing.groups.first.items.first,
      'Parents — kind speech, presence, service, dua',
    );
    expect(
      huquqBriefing.plainText,
      contains('Safety and justice come first'),
    );
    expect(briefingForDomain(MonitorDomain.huquq), same(huquqBriefing));
  });

  testWidgets('Huquq check-in shows example bullets', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start today’s check-in'));
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.huquq);

    expect(find.text('Attending can look like'), findsOneWidget);
    expect(
      find.text('Parents — kind speech, presence, service, dua'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Sick visit, sick contact, or support under stress — a right of brotherhood, not a sadaqah channel',
      ),
      findsOneWidget,
    );
    expect(find.byType(CheckInScreen), findsOneWidget);
  });
}
