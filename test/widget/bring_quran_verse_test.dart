import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_quran_catalog.dart';
import 'package:muhasabah02/domain/quran_verse_fetch.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpQuranLearn(
    WidgetTester tester, {
    QuranVerseFetch? fetch,
  }) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 12),
        quranVerseFetch: fetch ?? const FakeQuranVerseFetch(),
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.quran);
    await tester.tap(find.text(Copy.practiceQuranTitle));
    await tester.pumpAndSettle();
  }

  testWidgets('Bring a verse sits beside the Qur’an register on one slim row', (
    tester,
  ) async {
    await pumpQuranLearn(tester);
    final register = tester.getRect(
      find.byKey(const Key('quran-practice-open-register')),
    );
    final bring = tester.getRect(find.byKey(const Key('quran-practice-bring')));
    expect(register.height, lessThanOrEqualTo(32));
    expect(bring.height, lessThanOrEqualTo(32));
    expect((register.center.dy - bring.center.dy).abs(), lessThan(1));
    expect(bring.left, greaterThan(register.right));
    expect(bring.width / register.width, closeTo(2 / 3, 0.08));
  });

  testWidgets('Bring a verse fetches preview and appends it after the catalog', (
    tester,
  ) async {
    await pumpQuranLearn(tester);
    expect(find.text('1 of ${kPracticeQuranCatalog.length}'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranVerseTitle), findsOneWidget);
    await tester.enterText(find.byKey(const Key('bring-quran-ref')), '3:16');
    await tester.tap(find.byKey(const Key('bring-quran-lookup')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bring-quran-preview-arabic')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bring-quran-save')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranSaved), findsOneWidget);
    expect(
      find.text(
        '${kPracticeQuranCatalog.length + 1} of ${kPracticeQuranCatalog.length + 1}',
      ),
      findsOneWidget,
    );
    expect(find.text('Qur’an 3:16'), findsWidgets);
  });

  testWidgets('Bring a verse from a pasted quran.com link', (tester) async {
    await pumpQuranLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-quran-url')),
      'quran.com/3/16',
    );
    await tester.tap(find.byKey(const Key('bring-quran-lookup')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bring-quran-save')));
    await tester.pumpAndSettle();
    expect(find.text('Qur’an 3:16'), findsWidgets);
  });

  testWidgets('built-in verse keys are not added again', (tester) async {
    await pumpQuranLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('bring-quran-ref')), '2:255');
    await tester.tap(find.byKey(const Key('bring-quran-lookup')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranAlreadyOnLearnCheck), findsOneWidget);
    expect(find.byKey(const Key('bring-quran-preview-arabic')), findsOneWidget);
    expect(find.byKey(const Key('bring-quran-dont-save')), findsOneWidget);
    expect(find.byKey(const Key('bring-quran-save-anyway')), findsOneWidget);
    expect(find.byKey(const Key('bring-quran-save')), findsNothing);
    await tester.tap(find.byKey(const Key('bring-quran-save-anyway')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranKeptOnLearn), findsOneWidget);
    expect(find.text('1 of ${kPracticeQuranCatalog.length}'), findsOneWidget);
  });

  testWidgets('a passage longer than 7 verses is refused', (tester) async {
    await pumpQuranLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('bring-quran-ref')), '2:1-20');
    await tester.tap(find.byKey(const Key('bring-quran-lookup')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranTooLong), findsOneWidget);
  });

  testWidgets('offline lookup offers a reference-only save', (tester) async {
    await pumpQuranLearn(tester, fetch: const FailingQuranVerseFetch());
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('bring-quran-ref')), '3:16');
    await tester.tap(find.byKey(const Key('bring-quran-lookup')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranCouldNotFetch), findsOneWidget);
    await tester.tap(find.byKey(const Key('bring-quran-save-ref')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranReferenceSaved), findsOneWidget);
    expect(find.text('Qur’an 3:16'), findsWidgets);
  });

  testWidgets('topic search lists hits and bringing one appends it', (
    tester,
  ) async {
    await pumpQuranLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('bring-quran-search')), 'near');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('bring-quran-hit-2-186')));
    await tester.tap(find.byKey(const Key('bring-quran-hit-2-186')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bring-quran-preview-arabic')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bring-quran-save')));
    await tester.pumpAndSettle();
    expect(find.text('Qur’an 2:186'), findsWidgets);
  });

  testWidgets('searching a built-in verse marks it already on Learn', (
    tester,
  ) async {
    await pumpQuranLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-bring')));
    await tester.tap(find.byKey(const Key('quran-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-quran-search')),
      'kursi',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('bring-quran-hit-2-255')));
    await tester.tap(find.byKey(const Key('bring-quran-hit-2-255')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranAlreadyOnLearnCheck), findsWidgets);
    expect(find.byKey(const Key('bring-quran-preview-arabic')), findsOneWidget);
    expect(find.byKey(const Key('bring-quran-dont-save')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bring-quran-dont-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bring-quran-sheet')), findsNothing);
    expect(find.text('1 of ${kPracticeQuranCatalog.length}'), findsOneWidget);
  });

  testWidgets('citation chrome can bring the open Qur’an verse', (
    tester,
  ) async {
    await pumpQuranLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('quran-practice-source')));
    await tester.tap(find.byKey(const Key('quran-practice-source')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reflection-open-citation')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citation-reader')), findsOneWidget);
    expect(find.byKey(const Key('citation-bring-quran')), findsOneWidget);
    await tester.tap(find.byKey(const Key('citation-bring-quran')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringQuranVerseTitle), findsOneWidget);
    expect(find.byKey(const Key('bring-quran-ref')), findsOneWidget);
  });
}
