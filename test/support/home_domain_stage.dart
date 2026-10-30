import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

Future<void> showStagedDomain(
  WidgetTester tester,
  MonitorDomain domain, {
  String prefix = 'home-domain',
}) async {
  for (final kind in ['tab', 'pill']) {
    final control = find.byKey(Key('$prefix-$kind-${domain.id}'));
    if (control.evaluate().isEmpty) continue;
    await tester.ensureVisible(control);
    await tester.tap(control);
    await tester.pumpAndSettle();
    return;
  }
}

Future<void> showHomeDomain(WidgetTester tester, MonitorDomain domain) {
  return showStagedDomain(tester, domain);
}

Future<void> showCheckInDomain(WidgetTester tester, MonitorDomain domain) {
  return showStagedDomain(tester, domain, prefix: 'checkin-domain');
}

/// Opens the Input bottom-nav tab that hosts Check-in / Quick tap / Quick select.
Future<void> openInputTab(WidgetTester tester) async {
  final nav = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(Copy.inputTab),
  );
  if (nav.evaluate().isEmpty) return;
  await tester.tap(nav);
  await tester.pumpAndSettle();
}

/// Opens the Home bottom-nav tab.
Future<void> openHomeTab(WidgetTester tester) async {
  final nav = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text('Home'),
  );
  if (nav.evaluate().isEmpty) return;
  await tester.tap(nav);
  await tester.pumpAndSettle();
}

/// Shows the Quick select folder body with domain chips.
Future<void> expandActiveDomainMix(WidgetTester tester) async {
  await openInputTab(tester);
  final chips = find.byKey(const Key('today-active-domain-mix-chips'));
  if (chips.evaluate().isNotEmpty) return;
  final tab = find.byKey(const Key('today-input-tab-quick-select'));
  if (tab.evaluate().isNotEmpty) {
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }
}

/// Opens today’s check-in from the Input Check-in folder tab.
Future<void> openHomeCheckIn(WidgetTester tester) async {
  await openInputTab(tester);
  final tab = find.byKey(const Key('home-check-in'));
  if (tab.evaluate().isNotEmpty) {
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await tester.pumpAndSettle();
    return;
  }
  await tester.ensureVisible(find.text(Copy.homeCheckIn));
  await tester.tap(find.text(Copy.homeCheckIn));
  await tester.pumpAndSettle();
}

/// Opens the Quick tap sheet from the Input Quick tap folder tab.
Future<void> openHomeQuickTap(WidgetTester tester) async {
  await openInputTab(tester);
  final tab = find.byKey(const Key('home-quick-tap'));
  if (tab.evaluate().isNotEmpty) {
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await tester.pumpAndSettle();
    // Selecting an already-active Quick tap tab re-opens the sheet.
    if (find.byKey(const Key('quick-tap-header')).evaluate().isEmpty) {
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }
    return;
  }
  await tester.ensureVisible(find.text(Copy.quickTap));
  await tester.tap(find.text(Copy.quickTap));
  await tester.pumpAndSettle();
}
