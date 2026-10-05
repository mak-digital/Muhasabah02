import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/activity_picker.dart';

void main() {
  testWidgets('check-in uses capital domain titles and Salah catalog order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(
              visibleDomains: Set<MonitorDomain>.from(MonitorDomain.values),
            ),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SALAH & PRAYER QUALITY'), findsOneWidget);
    expect(find.byKey(const Key('checkin-domain-next')), findsOneWidget);
    expect(find.text('QUR’AN ENGAGEMENT'), findsNothing);
    expect(find.text('HADITH & LIVING SUNNAH'), findsNothing);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('No answer recorded'), findsWidgets);

    final fajrLabel = tester.getTopLeft(find.text('Fajr').first);
    final fajrDropdown = tester.getTopLeft(find.byKey(const Key('salah-fajr')));
    expect(fajrDropdown.dx - fajrLabel.dx, checkInValueIndent);

    await tester.tap(find.byKey(const Key('salah-fajr')));
    await tester.pumpAndSettle();

    final labels = tester
        .widgetList<DropdownMenuItem<String>>(
          find.byType(DropdownMenuItem<String>),
        )
        .map((item) => (item.child as Text).data)
        .toList();
    expect(
      labels,
      ActivityCatalog.salah.map((option) => option.label).toList(),
    );
  });

  testWidgets('Friday Prayer is one Jumu‘ah list, not a second congregation field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(
              visibleDomains: Set<MonitorDomain>.from(MonitorDomain.values),
              salahActivityColours: true,
            ),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 4)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 4))),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('FRIDAY PRAYER'));
    await tester.pumpAndSettle();

    expect(find.text('Friday congregation'), findsNothing);
    expect(find.text('Attended'), findsNothing);
    expect(find.text('Jumu‘ah'), findsOneWidget);
    expect(find.byKey(const Key('salah-jumuah')), findsOneWidget);

    await tester.tap(find.byKey(const Key('salah-jumuah')));
    await tester.pumpAndSettle();
    expect(find.text('Prayed late (alone)'), findsWidgets);
    expect(find.text('Prayed on time in congregation'), findsWidgets);
    expect(find.text('Prayed late'), findsNothing);
  });
}
