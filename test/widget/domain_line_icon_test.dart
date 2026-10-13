import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/shared/domain_line_icon.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('each domain paints its own outlined mark', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            for (final domain in MonitorDomain.values)
              DomainLineIcon(domain, size: 24),
          ],
        ),
      ),
    );
    for (final domain in MonitorDomain.values) {
      expect(find.byKey(Key('domain-line-icon-${domain.id}')), findsOneWidget);
    }
  });

  test('domain titles resolve to the matching domain', () {
    expect(domainForTitle(MonitorDomain.salah.label), MonitorDomain.salah);
    expect(domainForTitle('Other observations'), isNull);
  });

  testWidgets('Home domain chrome shows the current domain mark', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('domain-line-icon-salah')), findsWidgets);
    await tester.tap(find.byKey(const Key('home-domain-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('domain-line-icon-quran')), findsWidgets);
  });

  testWidgets('Quick tap tiles use the domain line mark', (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 14)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.quickTap));
    await tester.tap(find.text(Copy.quickTap));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-tap-domain-toggle-salah')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('domain-line-icon-salah')), findsWidgets);
  });
}
