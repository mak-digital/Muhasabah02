import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/progress/optional_domain_progress_screen.dart';
import 'package:muhasabah02/presentation/progress/salah_progress_screen.dart';
import 'package:muhasabah02/presentation/recognition/recognition_screen.dart';
import 'package:muhasabah02/presentation/recorded_days/recorded_days_screen.dart';
import 'package:muhasabah02/presentation/review/review_screen.dart';

import '../support/test_app.dart';

void main() {
  Future<void> pumpReview(
    WidgetTester tester, {
    double systemBottom = 48,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(bottom: systemBottom);
    tester.view.viewPadding = FakeViewPadding(bottom: systemBottom);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 6),
        visibleDomains: allVisibleDomains(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
  }

  EdgeInsets listPadding(WidgetTester tester, Finder host) {
    return tester
        .widget<ListView>(
          find.descendant(of: host, matching: find.byType(ListView)).first,
        )
        .padding!
        .resolve(TextDirection.ltr);
  }

  testWidgets('Review pages keep list content above a 48dp system inset', (
    tester,
  ) async {
    await pumpReview(tester);
    expect(listPadding(tester, find.byType(ReviewScreen)).bottom, 16);

    await tester.tap(find.byKey(const Key('review-domain-salah')));
    await tester.pumpAndSettle();
    expect(listPadding(tester, find.byType(SalahProgressScreen)).bottom, 64);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('review-domain-quran')));
    await tester.pumpAndSettle();
    expect(listPadding(tester, find.byType(QuranProgressScreen)).bottom, 64);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-dhikr')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-dhikr')));
    await tester.pumpAndSettle();
    expect(
      listPadding(tester, find.byType(OptionalDomainProgressScreen)).bottom,
      64,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(Copy.recordedDaysTitle),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text(Copy.recordedDaysTitle));
    await tester.pumpAndSettle();
    expect(listPadding(tester, find.byType(RecordedDaysScreen)).bottom, 64);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Recognition'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Recognition'));
    await tester.pumpAndSettle();
    expect(listPadding(tester, find.byType(RecognitionScreen)).bottom, 64);
  });
}
