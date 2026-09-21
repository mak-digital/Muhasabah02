import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

import '../support/check_in_select.dart';
import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('Hajj Home shows standing status and preparation only when due', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 9000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.hajj);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-status')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(MonitorDomain.hajj.label), findsWidgets);
    expect(find.text(Copy.hajjStatusNote), findsOneWidget);
    expect(find.byKey(const Key('home-compact-hajj-2026-09-03')), findsNothing);
    expect(
      find.byKey(const Key('home-hajj.preparation-2026-09-03')),
      findsNothing,
    );

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('hajj-status'),
      optionLabel: 'Due',
    );
    expect(find.byKey(const Key('home-compact-hajj-2026-09-03')), findsNothing);
    expect(
      find.byKey(const Key('home-hajj.preparation-2026-09-03')),
      findsOneWidget,
    );
    expect(find.text(Copy.hajjPonderDue), findsNothing);
    expect(find.text('Noticed preparation'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-hajj.preparation-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.text('Noticed preparation'), findsWidgets);
  });
}
