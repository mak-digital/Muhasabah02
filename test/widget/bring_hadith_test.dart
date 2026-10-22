import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/hadith_fetch.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpHadithLearn(
    WidgetTester tester, {
    HadithFetch? fetch,
  }) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 12),
        hadithFetch: fetch ?? const FakeHadithFetch(),
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.hadith,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.hadith);
    await tester.tap(find.text(Copy.practiceHadithTitle));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Bring a hadith sits beside the Hadith register on one slim row',
    (tester) async {
      await pumpHadithLearn(tester);
      final register = tester.getRect(
        find.byKey(const Key('hadith-practice-open-register')),
      );
      final bring = tester.getRect(
        find.byKey(const Key('hadith-practice-bring')),
      );
      expect(register.height, lessThanOrEqualTo(32));
      expect(bring.height, lessThanOrEqualTo(32));
      expect((register.center.dy - bring.center.dy).abs(), lessThan(1));
      expect(bring.left, greaterThan(register.right));
      expect(bring.width / register.width, closeTo(2 / 3, 0.08));
    },
  );

  testWidgets('Bring a hadith fetches preview and appends it after the catalog', (
    tester,
  ) async {
    await pumpHadithLearn(tester);
    expect(find.text('1 of ${kPracticeHadithCatalog.length}'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-ref')),
      'Muslim 1',
    );
    await tester.tap(find.byKey(const Key('bring-hadith-lookup')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('bring-hadith-preview-arabic')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('bring-hadith-save')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithSaved), findsOneWidget);
    expect(
      find.text(
        '${kPracticeHadithCatalog.length + 1} of ${kPracticeHadithCatalog.length + 1}',
      ),
      findsOneWidget,
    );
    expect(find.text('Ṣaḥīḥ Muslim 1'), findsWidgets);
  });

  testWidgets('Bring a hadith from a pasted sunnah.com link', (tester) async {
    await pumpHadithLearn(tester);
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-url')),
      'sunnah.com/muslim:1',
    );
    await tester.tap(find.byKey(const Key('bring-hadith-lookup')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bring-hadith-save')));
    await tester.pumpAndSettle();
    expect(find.text('Ṣaḥīḥ Muslim 1'), findsWidgets);
  });

  testWidgets('built-in hadith keys are not added again', (tester) async {
    await pumpHadithLearn(tester);
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-ref')),
      'Bukhari 6312',
    );
    await tester.tap(find.byKey(const Key('bring-hadith-lookup')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithAlreadyOnLearnCheck), findsOneWidget);
    expect(
      find.byKey(const Key('bring-hadith-preview-arabic')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('bring-hadith-dont-save')), findsOneWidget);
    expect(find.byKey(const Key('bring-hadith-save-anyway')), findsOneWidget);
    expect(find.byKey(const Key('bring-hadith-save')), findsNothing);
    await tester.tap(find.byKey(const Key('bring-hadith-save-anyway')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithKeptOnLearn), findsOneWidget);
    expect(find.text('1 of ${kPracticeHadithCatalog.length}'), findsOneWidget);
  });

  testWidgets('offline lookup offers a reference-only save', (tester) async {
    await pumpHadithLearn(tester, fetch: const FailingHadithFetch());
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-ref')),
      'Muslim 1',
    );
    await tester.tap(find.byKey(const Key('bring-hadith-lookup')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithCouldNotFetch), findsOneWidget);
    await tester.tap(find.byKey(const Key('bring-hadith-save-ref')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithReferenceSaved), findsOneWidget);
    expect(find.text('Ṣaḥīḥ Muslim 1'), findsWidgets);
  });

  testWidgets('forward Delete in search removes a character and stays open', (
    tester,
  ) async {
    await pumpHadithLearn(tester);
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-search')),
      'intention',
    );
    await tester.pump();
    final field = tester.widget<TextField>(
      find.byKey(const Key('bring-hadith-search')),
    );
    field.controller!.selection = const TextSelection.collapsed(offset: 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();
    expect(field.controller!.text, 'ntention');
    expect(find.byKey(const Key('bring-hadith-sheet')), findsOneWidget);
    expect(find.text(Copy.appLockTitle), findsNothing);
  });

  testWidgets('topic search lists hits and bringing one appends it', (
    tester,
  ) async {
    await pumpHadithLearn(tester);
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-search')),
      'intention',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('bring-hadith-hit-bukhari-1')),
    );
    await tester.tap(find.byKey(const Key('bring-hadith-hit-bukhari-1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('bring-hadith-preview-arabic')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('bring-hadith-save')));
    await tester.pumpAndSettle();
    expect(find.text('Ṣaḥīḥ al-Bukhārī 1'), findsWidgets);
  });

  testWidgets('searching a built-in hadith marks it already on Learn', (
    tester,
  ) async {
    await pumpHadithLearn(tester);
    await tester.tap(find.byKey(const Key('hadith-practice-bring')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bring-hadith-search')),
      'waking',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('bring-hadith-hit-bukhari-6312')),
    );
    await tester.tap(find.byKey(const Key('bring-hadith-hit-bukhari-6312')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithAlreadyOnLearnCheck), findsWidgets);
    expect(
      find.byKey(const Key('bring-hadith-preview-arabic')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('bring-hadith-dont-save')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bring-hadith-dont-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bring-hadith-sheet')), findsNothing);
    expect(find.text('1 of ${kPracticeHadithCatalog.length}'), findsOneWidget);
  });

  testWidgets('citation chrome can bring the open hadith', (tester) async {
    await pumpHadithLearn(tester);
    await tester.ensureVisible(find.byKey(const Key('hadith-practice-source')));
    await tester.tap(find.byKey(const Key('hadith-practice-source')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reflection-open-citation')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citation-reader')), findsOneWidget);
    expect(find.byKey(const Key('citation-bring-hadith')), findsOneWidget);
    await tester.tap(find.byKey(const Key('citation-bring-hadith')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.bringHadithTitle), findsOneWidget);
  });
}
