import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/hadith_fetch.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';
import 'package:muhasabah02/presentation/home/hadith_map_sheet.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

class _RecordingHadithSpeech extends HadithSpeech {
  String? spoken;
  String? language;

  @override
  Future<bool> speak({
    required String text,
    required String languageCode,
    VoidCallback? onComplete,
  }) async {
    spoken = text;
    language = languageCode;
    onComplete?.call();
    return true;
  }
}

void main() {
  Future<void> pumpHadithLearn(
    WidgetTester tester, {
    HadithFetch? fetch,
    MemoryPracticeHadithRepository? practiceHadith,
    Future<bool> Function({required String subject, required String text})?
    hadithTextShare,
    HadithSpeech? hadithSpeech,
  }) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 12),
        hadithFetch: fetch ?? const FakeHadithFetch(),
        practiceHadith: practiceHadith,
        hadithTextShare: hadithTextShare,
        hadithSpeech: hadithSpeech,
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
    'Hadith Register, Fetch a Hadith, and Hadith Map sit on one slim row',
    (tester) async {
      await pumpHadithLearn(tester);
      expect(find.text(Copy.openPracticeHadithRegister), findsOneWidget);
      expect(find.text(Copy.bringHadith), findsOneWidget);
      expect(find.text(Copy.hadithMap), findsOneWidget);
      final register = tester.getRect(
        find.byKey(const Key('hadith-practice-open-register')),
      );
      final bring = tester.getRect(
        find.byKey(const Key('hadith-practice-bring')),
      );
      final map = tester.getRect(find.byKey(const Key('hadith-practice-map')));
      expect(register.height, lessThanOrEqualTo(32));
      expect(bring.height, lessThanOrEqualTo(32));
      expect(map.height, lessThanOrEqualTo(32));
      expect((register.center.dy - bring.center.dy).abs(), lessThan(1));
      expect((bring.center.dy - map.center.dy).abs(), lessThan(1));
      expect(bring.left, greaterThan(register.right - 1));
      expect(map.left, greaterThan(bring.right - 1));
      expect(bring.width / register.width, closeTo(1, 0.12));
      expect(map.width / bring.width, closeTo(1, 0.12));
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

  testWidgets('Hadith Map opens the full unique list grouped by shape', (
    tester,
  ) async {
    await pumpHadithLearn(tester);
    await tester.tap(find.byKey(const Key('hadith-practice-map')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hadith-map-sheet')), findsOneWidget);
    expect(find.text(Copy.hadithMapNote), findsNothing);
    expect(find.byKey(const Key('hadith-map-grid')), findsOneWidget);
    expect(
      find.text(Copy.hadithMapFullTitle(kPracticeHadithCatalog.length)),
      findsOneWidget,
    );
    expect(find.byKey(const Key('hadith-map-mark-ph.wudu')), findsOneWidget);
    expect(find.text(Copy.hadithMapShared), findsWidgets);
    expect(find.text(Copy.hadithMapNew), findsWidgets);
    expect(find.text(Copy.hadithMapCounts), findsOneWidget);
    expect(find.text(Copy.hadithMapByTopic.toUpperCase()), findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('hadith-map-mark-ph.guest')),
    );
    await tester.tap(find.byKey(const Key('hadith-map-mark-ph.guest')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hadith-map-grid')), findsNothing);
    expect(find.byKey(const Key('hadith-map-detail')), findsOneWidget);
    expect(find.text('Hospitality'), findsWidgets);
    expect(find.byKey(const Key('hadith-map-share')), findsOneWidget);
    expect(find.byKey(const Key('hadith-map-status')), findsOneWidget);
    expect(find.byKey(const Key('hadith-map-play')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('hadith-map-detail')),
        matching: find.textContaining(Copy.hadithMapNotMet),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('hadith-map-status')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('hadith-map-detail')),
        matching: find.textContaining(Copy.practiceStatusLearning),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('hadith-map-counts')));
    await tester.tap(find.byKey(const Key('hadith-map-counts')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.hadithMapByTopic.toUpperCase()), findsOneWidget);
    await tester.tap(find.byKey(const Key('hadith-map-period-toggle')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '${Copy.hadithMapThisPeriod} (${Copy.hadithMapMonth})'.toUpperCase(),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Hadith Map Share opens the device sheet and stores the date', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    String? sharedText;
    await pumpHadithLearn(
      tester,
      practiceHadith: register,
      hadithTextShare: ({required subject, required text}) async {
        sharedText = text;
        return true;
      },
    );
    await tester.tap(find.byKey(const Key('hadith-practice-map')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('hadith-map-mark-ph.guest')),
    );
    await tester.tap(find.byKey(const Key('hadith-map-mark-ph.guest')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hadith-map-share')));
    await tester.pumpAndSettle();
    expect(sharedText, isNotNull);
    expect(sharedText, contains('Hospitality'));
    expect(sharedText, contains('Muslim'));
    final stored = await register.allHealthy();
    expect(stored, isNotEmpty);
    expect(stored.single.catalogId, 'ph.guest');
    expect(stored.single.sharedDateKeys, ['2026-10-12']);
    expect(stored.single.status, PracticeHadithStatus.learnt);
    expect(
      find.descendant(
        of: find.byKey(const Key('hadith-map-detail')),
        matching: find.textContaining(Copy.hadithMapShared),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Hadith Map Play speaks the hadith in the device language', (
    tester,
  ) async {
    final speech = _RecordingHadithSpeech();
    await pumpHadithLearn(tester, hadithSpeech: speech);
    await tester.tap(find.byKey(const Key('hadith-practice-map')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('hadith-map-mark-ph.guest')),
    );
    await tester.tap(find.byKey(const Key('hadith-map-mark-ph.guest')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hadith-map-play')));
    await tester.pumpAndSettle();
    expect(speech.language, 'en-US');
    expect(speech.spoken, contains('honour his guest'));
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
