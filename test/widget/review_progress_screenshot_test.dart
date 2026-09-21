import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';

import '../support/test_app.dart';

Future<void> _savePng(WidgetTester tester, String filename) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject(
      find.byKey(const ValueKey('review-shot')),
    ) as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/visual_review/renders/$filename');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('write Review domain Progress screenshots', skip: true, (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('review-shot'),
        child: testApp(visibleDomains: allVisibleDomains()),
      ),
    );
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    if (find.text('Continue').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
    }
    await tester.tap(find.text('Review'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text(Copy.reviewThisPeriod), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-dhikr')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump(const Duration(milliseconds: 200));
    await _savePng(tester, 'impl-17-review-domain-progress.png');

    await tester.tap(find.byKey(const Key('review-domain-dhikr')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('POST-FARD SALAH ADHKAR'), findsOneWidget);
    await _savePng(tester, 'impl-18-dhikr-progress.png');
  });
}
