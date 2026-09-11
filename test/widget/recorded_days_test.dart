import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/recorded_days/day_evidence_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('Recorded days uses a compact week grid', (tester) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-03'));
    await checkIns.save(sampleDay('2026-08-31'));
    await tester.pumpWidget(
      testApp(checkIns: checkIns, now: DateTime(2026, 9, 6)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(Copy.recordedDaysTitle),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text(Copy.recordedDaysTitle));
    await tester.pumpAndSettle();

    expect(find.text(Copy.recordedDaysGuard), findsOneWidget);
    expect(find.text('Check-in saved'), findsNothing);
    expect(find.textContaining('2 of 7 saved'), findsOneWidget);
    expect(find.byKey(const Key('recorded-day-2026-09-03')), findsOneWidget);

    await tester.tap(find.byKey(const Key('recorded-day-2026-09-04')));
    await tester.pumpAndSettle();
    expect(find.byType(DayEvidenceScreen), findsNothing);

    await tester.tap(find.byKey(const Key('recorded-day-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.byType(DayEvidenceScreen), findsOneWidget);
    expect(find.text(Copy.historicalReflectionGuard), findsOneWidget);
    expect(find.text(MonitorDomain.salah.label), findsOneWidget);
    expect(find.text('Prayed on time'), findsOneWidget);
  });
}
