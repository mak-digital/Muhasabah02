import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../data/privacy_log.dart';
import '../../domain/copy.dart';
import '../../domain/ids.dart';
import '../../domain/personal_response.dart';
import '../shared/ui_bits.dart';

class ResponseEditorScreen extends ConsumerStatefulWidget {
  const ResponseEditorScreen({
    super.key,
    this.existing,
    this.provenance,
    this.initialText,
  });

  final PersonalResponse? existing;
  final ResponseProvenance? provenance;
  final String? initialText;

  @override
  ConsumerState<ResponseEditorScreen> createState() =>
      _ResponseEditorScreenState();
}

class _ResponseEditorScreenState extends ConsumerState<ResponseEditorScreen> {
  late final TextEditingController _controller;
  late final String _originalText;
  String? _error;
  var _saving = false;
  var _confirmOpen = false;
  var _allowPop = false;

  @override
  void initState() {
    super.initState();
    _originalText = widget.existing?.text ?? widget.initialText ?? '';
    _controller = TextEditingController(text: _originalText);
    _controller.addListener(_onDraftChanged);
  }

  void _onDraftChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onDraftChanged);
    _controller.dispose();
    super.dispose();
  }

  bool get _isDirty => _controller.text != _originalText;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop || (!_saving && !_isDirty),
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existing == null ? Copy.addAResponse : Copy.editResponse,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Copy.creationPrompt,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (widget.provenance != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.provenance!.displayLine,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  enabled: !_saving,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText:
                        'Write in any language. This stays on the device.',
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SafeArea(
                top: false,
                left: false,
                right: false,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('response-save'),
                    onPressed: _saving ? null : _save,
                    child: const Text(Copy.saveResponse),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final error = validateResponseText(_controller.text);
    if (error != null) {
      if (!mounted) return;
      setState(() {
        _error = error == ResponseTextError.empty
            ? 'A response needs some text.'
            : 'This response is over the length limit.';
      });
      return;
    }
    final text = normalizeResponseText(_controller.text);
    final now = DateTime.now();
    final record = widget.existing == null
        ? PersonalResponse(
            id: newOpaqueId(),
            text: text,
            createdAt: now,
            provenance: widget.provenance,
          )
        : widget.existing!.copyWith(text: text, editedAt: now);
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(responsesProvider.notifier).save(record);
      logAppEvent('response_saved', opaqueId: record.id);
      if (!mounted) return;
      _allowPop = true;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Saving failed. Your draft is still in this editor.';
      });
    }
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    if (_saving || _confirmOpen) return;
    if (!_isDirty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _confirmOpen = true);
    final action = await showDialog<_UnsavedResponseAction>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          key: const Key('unsaved-response-dialog'),
          title: const Text(Copy.unsavedResponseTitle),
          content: const Text(Copy.unsavedResponseBody),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _UnsavedResponseAction.discard),
              child: const Text(Copy.unsavedResponseDiscard),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                _UnsavedResponseAction.continueEditing,
              ),
              child: const Text(Copy.unsavedResponseContinue),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _UnsavedResponseAction.save),
              child: const Text(Copy.unsavedResponseSave),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    setState(() => _confirmOpen = false);
    switch (action) {
      case _UnsavedResponseAction.save:
        await _save();
      case _UnsavedResponseAction.discard:
        if (!mounted) return;
        _allowPop = true;
        Navigator.of(context).pop();
      case _UnsavedResponseAction.continueEditing:
      case null:
        break;
    }
  }
}

enum _UnsavedResponseAction { save, continueEditing, discard }

class ResponseDetailScreen extends ConsumerWidget {
  const ResponseDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(responsesProvider);
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(
        body: EmptyState(
          title: Copy.myResponse,
          message: 'Could not open this response.',
        ),
      ),
      data: (items) {
        PersonalResponse? found;
        for (final item in items) {
          if (item.id == id) found = item;
        }
        if (found == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(Copy.myResponse)),
            body: const EmptyState(
              title: Copy.myResponse,
              message: Copy.evidenceUnavailable,
            ),
          );
        }
        final item = found;
        return Scaffold(
          appBar: AppBar(title: const Text(Copy.myResponse)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SelectableText(
                item.text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                item.provenance?.displayLine ?? 'Independent note',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ResponseEditorScreen(existing: item),
                    ),
                  );
                },
                child: const Text(Copy.editResponse),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final next = item.isArchived
                      ? item.copyWith(clearArchivedAt: true)
                      : item.copyWith(archivedAt: DateTime.now());
                  await ref.read(responsesProvider.notifier).save(next);
                  logAppEvent(
                    item.isArchived ? 'response_restored' : 'response_archived',
                    opaqueId: item.id,
                  );
                },
                child: Text(
                  item.isArchived ? Copy.restoreResponse : Copy.archiveResponse,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final ok = await ref
                      .read(responsesProvider.notifier)
                      .delete(item.id);
                  if (!context.mounted) return;
                  if (ok) {
                    logAppEvent('response_deleted', opaqueId: item.id);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Delete failed. The response is still listed.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text(Copy.deleteResponse),
              ),
            ],
          ),
        );
      },
    );
  }
}
