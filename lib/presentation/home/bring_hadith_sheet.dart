import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/bring_hadith_index.dart';
import '../../domain/hadith_fetch.dart';
import '../../domain/hadith_ref.dart';
import '../../domain/personal_hadith.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/practice_hadith_catalog.dart';
import '../shared/domain_visual.dart';
import '../shared/ui_bits.dart';

Future<void> showBringHadithSheet(BuildContext context, {String initial = ''}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => BringHadithSheet(initial: initial),
  );
}

class BringHadithSheet extends ConsumerStatefulWidget {
  const BringHadithSheet({super.key, this.initial = ''});

  final String initial;

  @override
  ConsumerState<BringHadithSheet> createState() => _BringHadithSheetState();
}

class _BringHadithSheetState extends ConsumerState<BringHadithSheet> {
  late final TextEditingController _search;
  late final TextEditingController _ref;
  late final TextEditingController _url;
  String? _message;
  var _lookingUp = false;
  var _offline = false;
  var _onLearn = false;
  HadithRef? _hadith;
  FetchedHadith? _passage;

  @override
  void initState() {
    super.initState();
    final seed = widget.initial.trim();
    final looksLikeUrl = seed.toLowerCase().contains('sunnah.com');
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

  HadithParseResult _parse() {
    final url = _url.text.trim();
    if (url.isNotEmpty) return parseHadithInput(url);
    return parseHadithInput(_ref.text);
  }

  bool _alreadyOnLearn(HadithRef hadith) {
    final shelf = ref.read(personalHadithProvider).value ?? const [];
    final pending = shelf.where(
      (item) => item.hadithKey == hadith.hadithKey && item.wordsPending,
    );
    if (pending.isNotEmpty) return false;
    return hadithKeyTaken(
      hadithKey: hadith.hadithKey,
      catalogSources: kPracticeHadithCatalog.map((item) => item.source),
      shelfKeys: shelf.map((item) => item.hadithKey),
    );
  }

  Future<void> _selectHit(BringHadithIndexItem item) async {
    _url.clear();
    _ref.text = item.ref.hadithKey;
    setState(() {
      _message = null;
      _passage = null;
      _offline = false;
      _onLearn = false;
      _hadith = null;
    });
    await _lookUp();
  }

  Future<void> _lookUp() async {
    setState(() {
      _message = null;
      _offline = false;
      _onLearn = false;
      _passage = null;
      _hadith = null;
    });
    final parsed = _parse();
    if (parsed.status == HadithParseStatus.empty ||
        parsed.status == HadithParseStatus.invalid) {
      setState(() => _message = Copy.bringHadithInvalid);
      return;
    }
    final hadith = parsed.ref!;
    final already = _alreadyOnLearn(hadith);
    setState(() => _lookingUp = true);
    try {
      final passage = await ref.read(hadithFetchProvider).load(hadith);
      if (!mounted) return;
      setState(() {
        _lookingUp = false;
        _hadith = hadith;
        _passage = passage;
        _offline = false;
        _onLearn = already;
        _message = already ? Copy.bringHadithAlreadyOnLearnCheck : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lookingUp = false;
        _hadith = hadith;
        _passage = null;
        _offline = true;
        _onLearn = already;
        _message = already
            ? Copy.bringHadithAlreadyOnLearnCheck
            : Copy.bringHadithCouldNotFetch;
      });
    }
  }

  Future<void> _save({required bool referenceOnly}) async {
    final hadith = _hadith;
    if (hadith == null) return;
    final catalogHit = hadithKeyTaken(
      hadithKey: hadith.hadithKey,
      catalogSources: kPracticeHadithCatalog.map((item) => item.source),
      shelfKeys: const [],
    );
    if (catalogHit) {
      if (!mounted) return;
      _dismiss(Copy.bringHadithKeptOnLearn);
      return;
    }
    final now = ref.read(nowProvider);
    final existing = (ref.read(personalHadithProvider).value ?? const [])
        .where((item) => item.hadithKey == hadith.hadithKey)
        .toList();
    final passage = _passage;
    final record = existing.isEmpty
        ? PersonalHadith.fromRef(
            ref: hadith,
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
    await ref.read(personalHadithProvider.notifier).save(record);
    final extra = personalHadithLearnItems(
      await ref.read(personalHadithRepositoryProvider).allHealthy(),
    );
    final list = practiceHadithLearnList(extra);
    final index = list.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      await ref.read(appPrefsProvider).setPracticeHadithBrowseIndex(index);
      ref.read(prefsTickProvider.notifier).state++;
    }
    if (!mounted) return;
    _dismiss(
      referenceOnly ? Copy.bringHadithReferenceSaved : Copy.bringHadithSaved,
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
    final hits = filterBringHadithIndex(_search.text);
    if (hits.isEmpty) {
      return Text(
        Copy.bringHadithSearchEmpty,
        key: const Key('bring-hadith-search-empty'),
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      key: const Key('bring-hadith-search-list'),
      children: [
        for (final item in hits)
          ListTile(
            key: Key('bring-hadith-hit-${item.ref.slug}-${item.ref.number}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(item.topic),
            subtitle: Text(
              _alreadyOnLearn(item.ref)
                  ? '${item.preview}\n${item.ref.citation}\n${Copy.bringHadithAlreadyOnLearn}'
                  : '${item.preview}\n${item.ref.citation}',
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
          key: const Key('bring-hadith-sheet'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Copy.bringHadithTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                Copy.bringHadithSearchHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextField(
                key: const Key('bring-hadith-search'),
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'intention, mother, anger',
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          key: const Key('bring-hadith-search-clear'),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
              ),
              if (_search.text.trim().length >= kBringHadithSearchMinChars) ...[
                const SizedBox(height: 8),
                _searchResults(),
              ],
              const SizedBox(height: 16),
              Text(
                Copy.bringHadithOrReference,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                Copy.bringHadithHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextField(
                key: const Key('bring-hadith-ref'),
                controller: _ref,
                decoration: const InputDecoration(labelText: 'Bukhari 6312'),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                Copy.bringHadithUrlHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextField(
                key: const Key('bring-hadith-url'),
                controller: _url,
                decoration: const InputDecoration(
                  labelText: 'sunnah.com/bukhari:6312',
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  key: const Key('bring-hadith-lookup'),
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
                  key: const Key('bring-hadith-message'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_passage != null) ...[
                const SizedBox(height: 12),
                if (_passage!.arabic.isNotEmpty)
                  PracticeScriptPane(
                    wash: domainColorIdentity(MonitorDomain.hadith)
                        .washFor(Theme.of(context).brightness, context),
                    child: Text(
                      _passage!.arabic,
                      key: const Key('bring-hadith-preview-arabic'),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(height: 1.9),
                    ),
                  ),
                if (_passage!.translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  BalancedProse(
                    _passage!.translation,
                    key: const Key('bring-hadith-preview-translation'),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.45),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              if (_onLearn) ...[
                OutlinedButton(
                  key: const Key('bring-hadith-dont-save'),
                  onPressed: _closeWithoutSave,
                  child: const Text(Copy.bringHadithDontSave),
                ),
                if (_passage != null) ...[
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('bring-hadith-save-anyway'),
                    onPressed: () => _save(referenceOnly: false),
                    child: const Text(Copy.bringHadithSaveAnyway),
                  ),
                ],
              ] else ...[
                if (_passage != null)
                  FilledButton(
                    key: const Key('bring-hadith-save'),
                    onPressed: () => _save(referenceOnly: false),
                    child: const Text(Copy.bringQuranSave),
                  ),
                if (_offline)
                  OutlinedButton(
                    key: const Key('bring-hadith-save-ref'),
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
