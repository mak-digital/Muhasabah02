import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('History lists saved days compactly without field counts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-03').copyWith(synthetic: true));
    await checkIns.save(sampleDay('2026-07-01'));
    await tester.pumpWidget(
      testApp(checkIns: checkIns, now: DateTime(2026, 9, 6)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text(Copy.historyGuard), findsOneWidget);
    expect(find.text(Copy.historyTapToEdit), findsWidgets);
    expect(find.textContaining('recordable fields'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.text(Copy.sampleRecordPill), findsOneWidget);
    expect(find.byKey(const Key('history-day-2026-09-03')), findsOneWidget);
    expect(find.byKey(const Key('history-day-2026-07-01')), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-day-2026-09-03')), findsOneWidget);
    expect(find.byKey(const Key('history-day-2026-07-01')), findsNothing);

    await tester.tap(find.text(Copy.historyFilterAll));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history-day-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
  });
}
