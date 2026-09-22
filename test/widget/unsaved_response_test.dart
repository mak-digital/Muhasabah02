import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/personal_response.dart';
import 'package:muhasabah02/presentation/response/response_editor_screen.dart';

import '../support/controllable_response_repository.dart';
import '../support/test_app.dart';

void main() {
  final createdAt = DateTime(2026, 9, 3, 8);
  const provenance = ResponseProvenance(
    originType: ProvenanceOrigin.completedCheckIn,
    dateKey: '2026-09-01',
    labelSnapshot: '1 Sep 2026',
  );
  final existing = PersonalResponse(
    id: 'resp-1',
    text: 'Kept note',
    createdAt: createdAt,
    provenance: provenance,
  );

  Widget editorApp({
    required ResponseRepository responses,
    PersonalResponse? current,
    String? initialText,
    ResponseProvenance? noteProvenance,
  }) {
    return ProviderScope(
      overrides: [
        responseRepositoryProvider.overrideWithValue(responses),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ResponseEditorScreen(
                        existing: current,
                        initialText: initialText,
                        provenance: noteProvenance,
                      ),
                    ),
                  );
                },
                child: const Text('open-editor'),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('open-editor'));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
  }

  Future<void> typeDraft(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  testWidgets('unchanged new editor closes without warning', (tester) async {
    final repo = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect(await repo.inner.allHealthy(), isEmpty);
  });

  testWidgets('unchanged quote prefill closes without warning', (tester) async {
    final repo = ControllableResponseRepository();
    const quote = 'Establish prayer.\n\n— Qur’an 29:45';
    await tester.pumpWidget(
      editorApp(responses: repo, initialText: quote),
    );
    await tester.pumpAndSettle();
    await openEditor(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect(await repo.inner.allHealthy(), isEmpty);
  });

  testWidgets('edited new response prompts on AppBar and system Back', (
    tester,
  ) async {
    final repo = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'A private note');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsOneWidget);
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsOneWidget);
  });

  testWidgets('Continue editing preserves draft', (tester) async {
    final repo = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'A private note');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedResponseContinue));
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.text('A private note'), findsOneWidget);
  });

  testWidgets('Discard exits without saving', (tester) async {
    final repo = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'A private note');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedResponseDiscard));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect(await repo.inner.allHealthy(), isEmpty);
  });

  testWidgets('dialog Save and ordinary Save persist once', (tester) async {
    final dialogRepo = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: dialogRepo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Saved from dialog');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedResponseSave));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect(dialogRepo.saveCount, 1);
    expect((await dialogRepo.inner.allHealthy()).single.text, 'Saved from dialog');

    final ordinary = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: ordinary));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Saved from button');
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect(ordinary.saveCount, 1);
    expect((await ordinary.inner.allHealthy()).single.text, 'Saved from button');
  });

  testWidgets('failed dialog Save keeps draft and allows retry', (tester) async {
    final repo = ControllableResponseRepository()..throwOnSave = true;
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Keep this draft');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedResponseSave));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.byKey(const Key('unsaved-response-dialog')), findsNothing);
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(
      find.text('Saving failed. Your draft is still in this editor.'),
      findsOneWidget,
    );
    expect(await repo.inner.allHealthy(), isEmpty);
    repo.throwOnSave = false;
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect((await repo.inner.allHealthy()).single.text, 'Keep this draft');
    expect(repo.saveCount, 2);
  });

  testWidgets('duplicate Save while pending writes once', (tester) async {
    final repo = ControllableResponseRepository()..saveGate = Completer<void>();
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Only once');
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pump();
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pump();
    await tester.pageBack();
    await tester.pump();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect(repo.saveCount, 1);
    repo.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
    expect((await repo.inner.allHealthy()).length, 1);
  });

  testWidgets('failed Save preserves draft and allows retry', (tester) async {
    final repo = ControllableResponseRepository()..throwOnSave = true;
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Keep this draft');
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(
      find.text('Saving failed. Your draft is still in this editor.'),
      findsOneWidget,
    );
    expect(await repo.inner.allHealthy(), isEmpty);
    repo.throwOnSave = false;
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    expect((await repo.inner.allHealthy()).single.text, 'Keep this draft');
  });

  testWidgets('unchanged existing response closes without warning', (
    tester,
  ) async {
    final repo = ControllableResponseRepository();
    await repo.inner.save(existing);
    await tester.pumpWidget(editorApp(responses: repo, current: existing));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsNothing);
    expect((await repo.inner.getById('resp-1'))!.text, 'Kept note');
  });

  testWidgets('modified existing response warns and Discard keeps stored text', (
    tester,
  ) async {
    final repo = ControllableResponseRepository();
    await repo.inner.save(existing);
    await tester.pumpWidget(editorApp(responses: repo, current: existing));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Changed note');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsOneWidget);
    await tester.tap(find.text(Copy.unsavedResponseDiscard));
    await tester.pumpAndSettle();
    expect((await repo.inner.getById('resp-1'))!.text, 'Kept note');
  });

  testWidgets('editing existing response retains id createdAt and provenance', (
    tester,
  ) async {
    final repo = ControllableResponseRepository();
    await repo.inner.save(existing);
    await tester.pumpWidget(editorApp(responses: repo, current: existing));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Updated note');
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    final stored = (await repo.inner.allHealthy()).single;
    expect(stored.id, 'resp-1');
    expect(stored.createdAt, createdAt);
    expect(stored.provenance!.dateKey, '2026-09-01');
    expect(stored.provenance!.originType, ProvenanceOrigin.completedCheckIn);
    expect(stored.text, 'Updated note');
    expect(stored.editedAt, isNotNull);
  });

  testWidgets('clearing existing text warns then fails empty Save', (
    tester,
  ) async {
    final repo = ControllableResponseRepository();
    await repo.inner.save(existing);
    await tester.pumpWidget(editorApp(responses: repo, current: existing));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, '');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsOneWidget);
    await tester.tap(find.text(Copy.unsavedResponseSave));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.text('A response needs some text.'), findsOneWidget);
    expect((await repo.inner.getById('resp-1'))!.text, 'Kept note');
  });

  testWidgets('whitespace-only new text cannot be saved', (tester) async {
    final repo = ControllableResponseRepository();
    await tester.pumpWidget(editorApp(responses: repo));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, '   \n');
    await tester.tap(find.text(Copy.saveResponse));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    expect(find.text('A response needs some text.'), findsOneWidget);
    expect(await repo.inner.allHealthy(), isEmpty);
  });

  testWidgets('whitespace and formatting edits to existing text are dirty', (
    tester,
  ) async {
    final repo = ControllableResponseRepository();
    await repo.inner.save(existing);
    await tester.pumpWidget(editorApp(responses: repo, current: existing));
    await tester.pumpAndSettle();
    await openEditor(tester);
    await typeDraft(tester, 'Kept note ');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsOneWidget);
    await tester.tap(find.text(Copy.unsavedResponseContinue));
    await tester.pumpAndSettle();
    await typeDraft(tester, 'Kept note\n');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedResponseTitle), findsOneWidget);
  });

  testWidgets('Home Add a response uses the same protection', (tester) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 22)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.addAResponse).first);
    await tester.tap(find.text(Copy.addAResponse).first);
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ResponseEditorScreen), findsNothing);
  });
}
