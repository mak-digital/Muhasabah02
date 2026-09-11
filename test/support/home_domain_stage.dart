import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

Future<void> showStagedDomain(
  WidgetTester tester,
  MonitorDomain domain, {
  String prefix = 'home-domain',
}) async {
  final pill = find.byKey(Key('$prefix-pill-${domain.id}'));
  if (pill.evaluate().isEmpty) return;
  await tester.ensureVisible(pill);
  await tester.tap(pill);
  await tester.pumpAndSettle();
}

Future<void> showHomeDomain(WidgetTester tester, MonitorDomain domain) {
  return showStagedDomain(tester, domain);
}

Future<void> showCheckInDomain(WidgetTester tester, MonitorDomain domain) {
  return showStagedDomain(tester, domain, prefix: 'checkin-domain');
}
