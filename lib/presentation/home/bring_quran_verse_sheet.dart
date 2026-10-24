import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/bring_quran_index.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/personal_quran_verse.dart';
import '../../domain/practice_quran_catalog.dart';
import '../../domain/quran_verse_fetch.dart';
import '../../domain/quran_verse_ref.dart';

Future<void> showBringQuranVerseSheet(
  BuildContext context, {
  String initial = '',
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => BringQuranVerseSheet(initial: initial),
  );
}

class BringQuranVerseSheet extends ConsumerStatefulWidget {
  const BringQuranVerseSheet({super.key, this.initial = ''});

  final String initial;

  @override
  ConsumerState<BringQuranVerseSheet> createState() =>
      _BringQuranVerseSheetState();
}

class _BringQuranVerseSheetState extends ConsumerState<BringQuranVerseSheet> {
  late final TextEditingController _search;
  late final TextEditingController _ref;
  late final TextEditingController _url;
  String? _message;
  var _lookingUp = false;
  var _offline = false;
  var _onLearn = false;
  QuranVerseRange? _range;
  FetchedQuranPassage? _passage;

  @override
  void initState() {
    super.initState();
    final seed = widget.initial.trim();
    final looksLikeUrl = seed.toLowerCase().contains('quran.com');
    _search = TextEditingController();
    _ref = TextEditingController(text: looksLikeUrl ? '' : seed);
    _url = TextEditingController(text: looksLikeUrl ? seed : '');
  }

  @override
  void dispose() {
    _search.dispose();
    _ref.dispose();
    _url.dispose();
    super.dispose();
  }

  QuranVerseParseResult _parse() {
    final url = _url.text.trim();
    if (url.isNotEmpty) return parseQuranVerseInput(url);
    return parseQuranVerseInput(_ref.text);
  }

  bool _alreadyOnLearn(QuranVerseRange range) {
    final shelf = ref.read(personalQuranVerseProvider).value ?? const [];
    final pending = shelf.where(
      (v) => v.verseKey == range.verseKey && v.wordsPending,
    );
    if (pending.isNotEmpty) return false;
    return quranVerseKeyTaken(
      verseKey: range.verseKey,
      catalogSources: kPracticeQuranCatalog.map((item) => item.source),
      shelfKeys: shelf.map((v) => v.verseKey),
    );
  }

  Future<void> _selectHit(BringQuranIndexItem item) async {
    _url.clear();
    _ref.text = item.range.verseKey;
    setState(() {
      _message = null;
      _passage = null;
      _offline = false;
      _onLearn = false;
      _range = null;
    });
    await _lookUp();
  }

  Future<void> _lookUp() async {
    setState(() {
      _message = null;
      _offline = false;
      _onLearn = false;
      _passage = null;
      _range = null;
    });
    final parsed = _parse();
    if (parsed.status == QuranVerseParseStatus.empty ||
        parsed.status == QuranVerseParseStatus.invalid) {
      setState(() => _message = Copy.bringQuranInvalid);
      return;
    }
    if (parsed.status == QuranVerseParseStatus.tooLong) {
      setState(() => _message = Copy.bringQuranTooLong);
      return;
    }
    final range = parsed.range!;
    final already = _alreadyOnLearn(range);
    setState(() => _lookingUp = true);
    try {
      final passage = await ref.read(quranVerseFetchProvider).load(range);
      if (!mounted) return;
      setState(() {
        _lookingUp = false;
        _range = range;
        _passage = passage;
        _offline = false;
        _onLearn = already;
        _message = already ? Copy.bringQuranAlreadyOnLearnCheck : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lookingUp = false;
        _range = range;
        _passage = null;
        _offline = true;
        _onLearn = already;
        _message = already
            ? Copy.bringQuranAlreadyOnLearnCheck
            : Copy.bringQuranCouldNotFetch;
      });
    }
  }

  Future<void> _save({required bool referenceOnly}) async {
    final range = _range;
    if (range == null) return;
    final catalogHit = quranVerseKeyTaken(
      verseKey: range.verseKey,
      catalogSources: kPracticeQuranCatalog.map((item) => item.source),
      shelfKeys: const [],
    );
    if (catalogHit) {
      if (!mounted) return;
      _dismiss(Copy.bringQuranKeptOnLearn);
      return;
    }
    final now = ref.read(nowProvider);
    final existing = (ref.read(personalQuranVerseProvider).value ?? const [])
        .where((v) => v.verseKey == range.verseKey)
        .toList();
    final passage = _passage;
    final record = existing.isEmpty
        ? PersonalQuranVerse.fromRange(
            range: range,
            addedDateKey: dateKey(now),
            arabic: referenceOnly ? '' : (passage?.arabic ?? ''),
            translation: referenceOnly ? '' : (passage?.translation ?? ''),
            wordsPending: referenceOnly || passage == null,
          )
        : existing.first.copyWith(
            arabic: referenceOnly
                ? existing.first.arabic
                : (passage?.arabic ?? ''),
            translation: referenceOnly
                ? existing.first.translation
                : (passage?.translation ?? ''),
            wordsPending: referenceOnly || passage == null,
          );
    await ref.read(personalQuranVerseProvider.notifier).save(record);
    final extra = personalQuranLearnItems(
      await ref.read(personalQuranVerseRepositoryProvider).allHealthy(),
    );
    final list = practiceQuranLearnList(extra);
    final index = list.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      await ref.read(appPrefsProvider).setPracticeQuranBrowseIndex(index);
      ref.read(prefsTickProvider.notifier).state++;
    }
    if (!mounted) return;
    _dismiss(
      referenceOnly ? Copy.bringQuranReferenceSaved : Copy.bringQuranSaved,
    );
  }

  void _dismiss(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _closeWithoutSave() {
    Navigator.of(context).pop();
  }

  Widget _searchResults() {
    final hits = filterBringQuranIndex(_search.text);
    if (hits.isEmpty) {
      return Text(
        Copy.bringQuranSearchEmpty,
        key: const Key('bring-quran-search-empty'),
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      key: const Key('bring-quran-search-list'),
      children: [
        for (final item in hits)
          ListTile(
            key: Key('bring-quran-hit-${item.hitKey}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(item.topic),
            subtitle: Text(
              _alreadyOnLearn(item.range)
                  ? '${item.preview}\n${item.range.citation}\n${Copy.bringQuranAlreadyOnLearn}'
                  : '${item.preview}\n${item.range.citation}',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: _lookingUp ? null : () => _selectHit(item),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: SingleChildScrollView(
          key: const Key('bring-quran-sheet'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Copy.bringQuranVerseTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                Copy.bringQuranSearchHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextField(
                key: const Key('bring-quran-search'),
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'kursi, parents, ease',
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
              ),
              if (_search.text.trim().length >= kBringQuranSearchMinChars) ...[
                const SizedBox(height: 8),
                _searchResults(),
              ],
              const SizedBox(height: 16),
              Text(
                Copy.bringQuranOrReference,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                Copy.bringQuranVerseHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextField(
                key: const Key('bring-quran-ref'),
                controller: _ref,
                decoration: const InputDecoration(labelText: '2:255'),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                Copy.bringQuranUrlHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextField(
                key: const Key('bring-quran-url'),
                controller: _url,
                decoration: const InputDecoration(labelText: 'quran.com/2/255'),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  key: const Key('bring-quran-lookup'),
                  onPressed: _lookingUp ? null : _lookUp,
                  child: _lookingUp
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(Copy.bringQuranLookUp),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Text(
                  _message!,
                  key: const Key('bring-quran-message'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_passage != null) ...[
                const SizedBox(height: 12),
                if (_passage!.arabic.isNotEmpty)
                  Text(
                    _passage!.arabic,
                    key: const Key('bring-quran-preview-arabic'),
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (_passage!.translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _passage!.translation,
                    key: const Key('bring-quran-preview-translation'),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              if (_onLearn) ...[
                OutlinedButton(
                  key: const Key('bring-quran-dont-save'),
                  onPressed: _closeWithoutSave,
                  child: const Text(Copy.bringQuranDontSave),
                ),
                if (_passage != null) ...[
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('bring-quran-save-anyway'),
                    onPressed: () => _save(referenceOnly: false),
                    child: const Text(Copy.bringQuranSaveAnyway),
                  ),
                ],
              ] else ...[
                if (_passage != null)
                  FilledButton(
                    key: const Key('bring-quran-save'),
                    onPressed: () => _save(referenceOnly: false),
                    child: const Text(Copy.bringQuranSave),
                  ),
                if (_offline)
                  OutlinedButton(
                    key: const Key('bring-quran-save-ref'),
                    onPressed: () => _save(referenceOnly: true),
                    child: const Text(Copy.bringQuranSaveReferenceOnly),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
