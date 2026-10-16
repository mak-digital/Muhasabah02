import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/arabic_script.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/practice_dhikr_catalog.dart';
import '../../domain/personal_hadith.dart';
import '../../domain/practice_hadith.dart';
import '../../domain/practice_hadith_catalog.dart';
import '../../domain/personal_quran_verse.dart';
import '../../domain/practice_quran_catalog.dart';
import '../../domain/reflection_catalog.dart';
import 'bring_hadith_sheet.dart';
import 'bring_quran_verse_sheet.dart';
import '../shared/activity_picker.dart';
import '../shared/domain_visual.dart';
import '../shared/ui_bits.dart';
import '../shared/week_nav_strip.dart';
import 'reflection_home_cards.dart';

ButtonStyle get _compactOutlineStyle => OutlinedButton.styleFrom(
  visualDensity: VisualDensity.compact,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  minimumSize: const Size.fromHeight(32),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
);

ButtonStyle get _slimRegisterStyle => OutlinedButton.styleFrom(
  visualDensity: VisualDensity.compact,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  minimumSize: const Size.fromHeight(28),
  maximumSize: const Size(double.infinity, 28),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.1),
);

class PracticeAboutRegisterRow extends StatelessWidget {
  const PracticeAboutRegisterRow({
    super.key,
    required this.about,
    required this.register,
  });

  final Widget about;
  final Widget register;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 28, child: register),
        about,
      ],
    );
  }
}

class PracticeSkimSourceBox extends StatelessWidget {
  const PracticeSkimSourceBox({
    super.key,
    required this.sourceWashKey,
    required this.sourceWash,
    required this.prevKey,
    required this.nextKey,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.scroll,
    required this.scrollKey,
    required this.body,
    required this.citation,
    required this.indexLabel,
    required this.scriptBar,
    this.ink,
  });

  final Key sourceWashKey;
  final Color sourceWash;
  final Key prevKey;
  final Key nextKey;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ScrollController scroll;
  final Key scrollKey;
  final Widget body;
  final Widget citation;
  final String indexLabel;
  final Widget scriptBar;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final indexStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: ink ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        ColoredBox(
          key: sourceWashKey,
          color: sourceWash,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      key: prevKey,
                      tooltip: Copy.previousReflection,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      onPressed: canPrev ? onPrev : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 148,
                        child: Scrollbar(
                          controller: scroll,
                          thumbVisibility: true,
                          thickness: 5,
                          radius: const Radius.circular(8),
                          child: SingleChildScrollView(
                            key: scrollKey,
                            controller: scroll,
                            padding: const EdgeInsets.only(right: 16),
                            child: body,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      key: nextKey,
                      tooltip: Copy.nextReflection,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      onPressed: canNext ? onNext : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: citation),
                    Text(indexLabel, style: indexStyle),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
          child: scriptBar,
        ),
      ],
    );
  }
}

void _revealInHomeScroll(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!context.mounted) return;
    await Scrollable.ensureVisible(
      context,
      alignment: 0.12,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  });
}

class PracticeHadithWash extends ConsumerStatefulWidget {
  const PracticeHadithWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  ConsumerState<PracticeHadithWash> createState() => _PracticeHadithWashState();
}

class _PracticeHadithWashState extends ConsumerState<PracticeHadithWash> {
  String? _message;
  var _aboutOpen = true;
  final _scroll = ScrollController();

  void _collapseAbout() {
    if (!_aboutOpen) return;
    setState(() => _aboutOpen = false);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final records = ref.watch(practiceHadithProvider).value ?? const [];
    final extra = personalHadithLearnItems(
      ref.watch(personalHadithProvider).value ?? const [],
    );
    final learnList = practiceHadithLearnList(extra);
    final item = practiceHadithAt(prefs.practiceHadithBrowseIndex, extra);
    final already = practiceHadithAlreadyRegistered(records, item.id);
    final identity = domainColorIdentity(widget.domain);
    final wash = identity.practiceWashFor(Theme.of(context).brightness);
    final addedFill = Theme.of(context).colorScheme.secondaryContainer;
    final addedInk = Theme.of(context).colorScheme.onSecondaryContainer;
    final ink = already ? addedInk : null;
    final total = learnList.length;
    final index = wrapPracticeHadithIndex(
      prefs.practiceHadithBrowseIndex,
      total,
    );
    final chrome = already
        ? addedFill
        : weekNavStripWash(identity.family, wash);
    final sourceWash = Color.alphaBlend(
      Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
      wash,
    );

    return WashPanel(
      key: const Key('hadith-practice-panel'),
      color: wash,
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('hadith-practice-wash'),
          initiallyExpanded: false,
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 40,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
          onExpansionChanged: (open) {
            if (open) _revealInHomeScroll(context);
          },
          title: Text(
            Copy.practiceHadithTitle,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          children: [
            PracticeAboutRegisterRow(
              about: CollapsingIntroNote(
                key: const Key('hadith-practice-about'),
                title: Copy.washAboutTitle,
                note: Copy.practiceHadithNote,
                expanded: _aboutOpen,
                onExpansionChanged: (open) {
                  if (open == _aboutOpen) return;
                  setState(() => _aboutOpen = open);
                },
              ),
              register: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      key: const Key('hadith-practice-open-register'),
                      style: _slimRegisterStyle,
                      onPressed: () {
                        _collapseAbout();
                        showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (context) =>
                              const _PracticeHadithRegisterSheet(),
                        );
                      },
                      child: Text(
                        Copy.openPracticeHadithRegister,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      key: const Key('hadith-practice-bring'),
                      style: _slimRegisterStyle,
                      onPressed: () {
                        _collapseAbout();
                        showBringHadithSheet(context);
                      },
                      child: const Text(
                        Copy.bringHadith,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_message != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _message!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Material(
              color: chrome,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Text(
                      item.topic,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: ink, fontWeight: FontWeight.w600),
                    ),
                  ),
                  PracticeSkimSourceBox(
                    sourceWashKey: const Key('hadith-practice-source-wash'),
                    sourceWash: sourceWash,
                    ink: ink,
                    prevKey: const Key('hadith-practice-previous'),
                    nextKey: const Key('hadith-practice-next'),
                    canPrev: true,
                    canNext: true,
                    onPrev: () {
                      _collapseAbout();
                      _step(-1);
                    },
                    onNext: () {
                      _collapseAbout();
                      _step(1);
                    },
                    scroll: _scroll,
                    scrollKey: const Key('hadith-practice-skim'),
                    body: PracticeRemembranceCore(
                      textKey: const Key('hadith-practice-text'),
                      contextText: item.text,
                      arabic: item.arabic,
                      transliteration: item.transliteration,
                      translation: item.translation,
                      ink: ink,
                      showScriptControls: false,
                    ),
                    citation: PracticeCitationLink(
                      buttonKey: const Key('hadith-practice-source'),
                      domain: widget.domain,
                      text: item.text,
                      source: item.source,
                      sourceDetail: item.sourceDetail,
                      ink: ink,
                    ),
                    indexLabel: '${index + 1} of $total',
                    scriptBar: PracticeArabicScriptBar(
                      ink: ink,
                      compact: true,
                      compactAction: TextButton(
                        key: const Key('hadith-practice-add'),
                        onPressed: already ? null : () => _add(item),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: Text(
                          already
                              ? Copy.practiceHadithAlreadyAdded
                              : Copy.addPracticeHadith,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _step(int delta) async {
    final extra = personalHadithLearnItems(
      ref.read(personalHadithProvider).value ?? const [],
    );
    final prefs = ref.read(appPrefsProvider);
    final next = wrapPracticeHadithIndex(
      prefs.practiceHadithBrowseIndex + delta,
      practiceHadithLearnList(extra).length,
    );
    await prefs.setPracticeHadithBrowseIndex(next);
    ref.read(prefsTickProvider.notifier).state++;
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _message = null);
  }

  Future<void> _add(PracticeHadithItem item) async {
    _collapseAbout();
    final records = ref.read(practiceHadithProvider).value ?? const [];
    if (practiceHadithAlreadyRegistered(records, item.id)) return;
    final now = ref.read(nowProvider);
    await ref
        .read(practiceHadithProvider.notifier)
        .save(
          recordFromCatalog(
            item: item,
            id: newOpaqueId(),
            addedDateKey: dateKey(now),
          ),
        );
    if (!mounted) return;
    setState(() => _message = Copy.practiceHadithAdded);
  }
}

class PracticeQuranWash extends ConsumerStatefulWidget {
  const PracticeQuranWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  ConsumerState<PracticeQuranWash> createState() => _PracticeQuranWashState();
}

class _PracticeQuranWashState extends ConsumerState<PracticeQuranWash> {
  String? _message;
  var _aboutOpen = true;
  final _scroll = ScrollController();

  void _collapseAbout() {
    if (!_aboutOpen) return;
    setState(() => _aboutOpen = false);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final records = practiceRecordsForDomain(
      ref.watch(practiceHadithProvider).value ?? const [],
      MonitorDomain.quran,
    );
    final extra = personalQuranLearnItems(
      ref.watch(personalQuranVerseProvider).value ?? const [],
    );
    final learnList = practiceQuranLearnList(extra);
    final item = practiceQuranAt(prefs.practiceQuranBrowseIndex, extra);
    final already = practiceHadithAlreadyRegistered(records, item.id);
    final identity = domainColorIdentity(widget.domain);
    final wash = identity.practiceWashFor(Theme.of(context).brightness);
    final addedFill = Theme.of(context).colorScheme.secondaryContainer;
    final addedInk = Theme.of(context).colorScheme.onSecondaryContainer;
    final ink = already ? addedInk : null;
    final total = learnList.length;
    final index = wrapPracticeHadithIndex(
      prefs.practiceQuranBrowseIndex,
      total,
    );
    final chrome = already
        ? addedFill
        : weekNavStripWash(identity.family, wash);
    final sourceWash = Color.alphaBlend(
      Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
      wash,
    );

    return WashPanel(
      key: const Key('quran-practice-panel'),
      color: wash,
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('quran-practice-wash'),
          initiallyExpanded: false,
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 40,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
          onExpansionChanged: (open) {
            if (open) _revealInHomeScroll(context);
          },
          title: Text(
            Copy.practiceQuranTitle,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          children: [
            PracticeAboutRegisterRow(
              about: CollapsingIntroNote(
                key: const Key('quran-practice-about'),
                title: Copy.washAboutTitle,
                note: Copy.practiceQuranNote,
                expanded: _aboutOpen,
                onExpansionChanged: (open) {
                  if (open == _aboutOpen) return;
                  setState(() => _aboutOpen = open);
                },
              ),
              register: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      key: const Key('quran-practice-open-register'),
                      style: _slimRegisterStyle,
                      onPressed: () {
                        _collapseAbout();
                        showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (context) =>
                              const _PracticeQuranRegisterSheet(),
                        );
                      },
                      child: Text(
                        Copy.openPracticeQuranRegister,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      key: const Key('quran-practice-bring'),
                      style: _slimRegisterStyle,
                      onPressed: () {
                        _collapseAbout();
                        showBringQuranVerseSheet(context);
                      },
                      child: const Text(
                        Copy.bringQuranVerse,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_message != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _message!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Material(
              color: chrome,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Text(
                      item.topic,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: ink, fontWeight: FontWeight.w600),
                    ),
                  ),
                  PracticeSkimSourceBox(
                    sourceWashKey: const Key('quran-practice-source-wash'),
                    sourceWash: sourceWash,
                    ink: ink,
                    prevKey: const Key('quran-practice-previous'),
                    nextKey: const Key('quran-practice-next'),
                    canPrev: true,
                    canNext: true,
                    onPrev: () {
                      _collapseAbout();
                      _step(-1);
                    },
                    onNext: () {
                      _collapseAbout();
                      _step(1);
                    },
                    scroll: _scroll,
                    scrollKey: const Key('quran-practice-skim'),
                    body: PracticeRemembranceCore(
                      textKey: const Key('quran-practice-text'),
                      contextText: item.text,
                      arabic: item.arabic,
                      transliteration: item.transliteration,
                      translation: item.translation,
                      ink: ink,
                      showScriptControls: false,
                    ),
                    citation: PracticeCitationLink(
                      buttonKey: const Key('quran-practice-source'),
                      domain: widget.domain,
                      text: item.text,
                      source: item.source,
                      sourceDetail: item.sourceDetail,
                      ink: ink,
                    ),
                    indexLabel: '${index + 1} of $total',
                    scriptBar: PracticeArabicScriptBar(
                      ink: ink,
                      compact: true,
                      compactAction: TextButton(
                        key: const Key('quran-practice-add'),
                        onPressed: already ? null : () => _add(item),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: Text(
                          already
                              ? Copy.practiceQuranAlreadyAdded
                              : Copy.addPracticeQuran,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _step(int delta) async {
    final extra = personalQuranLearnItems(
      ref.read(personalQuranVerseProvider).value ?? const [],
    );
    final prefs = ref.read(appPrefsProvider);
    final next = wrapPracticeHadithIndex(
      prefs.practiceQuranBrowseIndex + delta,
      practiceQuranLearnList(extra).length,
    );
    await prefs.setPracticeQuranBrowseIndex(next);
    ref.read(prefsTickProvider.notifier).state++;
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _message = null);
  }

  Future<void> _add(PracticeHadithItem item) async {
    _collapseAbout();
    final records = practiceRecordsForDomain(
      ref.read(practiceHadithProvider).value ?? const [],
      MonitorDomain.quran,
    );
    if (practiceHadithAlreadyRegistered(records, item.id)) return;
    final now = ref.read(nowProvider);
    await ref
        .read(practiceHadithProvider.notifier)
        .save(
          recordFromQuranCatalog(
            item: item,
            id: newOpaqueId(),
            addedDateKey: dateKey(now),
          ),
        );
    if (!mounted) return;
    setState(() => _message = Copy.practiceQuranAdded);
  }
}

class PracticeCitationLink extends ConsumerWidget {
  const PracticeCitationLink({
    super.key,
    this.buttonKey,
    required this.domain,
    required this.text,
    required this.source,
    required this.sourceDetail,
    this.ink,
  });

  final Key? buttonKey;
  final MonitorDomain domain;
  final String text;
  final String source;
  final String sourceDetail;
  final Color? ink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        key: buttonKey,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          alignment: Alignment.centerLeft,
          foregroundColor: ink,
        ),
        onPressed: () => showReflectionSource(
          context,
          ref,
          ReflectionQuote(
            domain: domain,
            text: text,
            source: source,
            sourceDetail: sourceDetail,
          ),
        ),
        child: Text(
          source,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(decoration: TextDecoration.underline, color: ink),
        ),
      ),
    );
  }
}

class PracticeRegisterStatusSelect extends StatelessWidget {
  const PracticeRegisterStatusSelect({
    super.key,
    required this.domain,
    required this.value,
    required this.onChanged,
    this.dropdownKey,
  });

  final MonitorDomain domain;
  final PracticeHadithStatus value;
  final ValueChanged<PracticeHadithStatus> onChanged;
  final Key? dropdownKey;

  @override
  Widget build(BuildContext context) {
    final identity = domainColorIdentity(domain);
    final wash = identity.washFor(Theme.of(context).brightness);
    final fill = Color.lerp(wash, identity.family, switch (value) {
      PracticeHadithStatus.learning => 0.08,
      PracticeHadithStatus.learnt => 0.28,
      PracticeHadithStatus.practicing => 0.48,
      PracticeHadithStatus.habit => 0.68,
    })!;
    return CheckInSelect<PracticeHadithStatus>(
      dropdownKey: dropdownKey,
      value: value,
      sortLabels: false,
      fillColor: fill,
      entries: [
        for (final status in PracticeHadithStatus.values)
          CheckInSelectEntry(value: status, label: status.labelFor(domain)),
      ],
      onChanged: onChanged,
    );
  }
}

class PracticeRemembranceCore extends ConsumerWidget {
  const PracticeRemembranceCore({
    super.key,
    required this.contextText,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.ink,
    this.textKey,
    this.showScriptControls = true,
  });

  final String contextText;
  final String arabic;
  final String transliteration;
  final String translation;
  final Color? ink;
  final Key? textKey;
  final bool showScriptControls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final face = prefs.arabicScriptFace;
    final size = clampArabicScriptSize(prefs.arabicScriptSize);
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink);
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: ink ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contextText.isNotEmpty) ...[
          Text(contextText, style: small),
          const SizedBox(height: 6),
        ],
        if (arabic.isNotEmpty) ...[
          if (showScriptControls) ...[
            PracticeArabicScriptBar(ink: ink),
            const SizedBox(height: 4),
          ],
          Text(
            arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ink,
              height: 1.85,
              fontSize: size,
              fontFamily: face.family,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (transliteration.isNotEmpty) ...[
          Text(
            transliteration,
            style: small?.copyWith(fontStyle: FontStyle.italic, height: 1.4),
          ),
          const SizedBox(height: 4),
        ],
        if (translation.isNotEmpty)
          Text(key: textKey, translation, style: body?.copyWith(height: 1.4)),
      ],
    );
  }
}

class PracticeArabicScriptBar extends ConsumerWidget {
  const PracticeArabicScriptBar({
    super.key,
    this.ink,
    this.compact = false,
    this.faceKey = const Key('arabic-script-face'),
    this.smallerKey = const Key('arabic-script-smaller'),
    this.largerKey = const Key('arabic-script-larger'),
    this.compactAction,
  });

  final Color? ink;
  final bool compact;
  final Key faceKey;
  final Key smallerKey;
  final Key largerKey;
  final Widget? compactAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final size = clampArabicScriptSize(prefs.arabicScriptSize);
    final canSmaller = size > kArabicScriptSizes.first;
    final canLarger = size < kArabicScriptSizes.last;
    final inkColor = ink ?? Theme.of(context).colorScheme.onSurface;
    final face = DropdownButtonHideUnderline(
      child: DropdownButton<ArabicScriptFace>(
        key: faceKey,
        isExpanded: true,
        isDense: compact,
        value: prefs.arabicScriptFace,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: inkColor,
          fontSize: compact ? 12 : null,
        ),
        items: [
          for (final option in ArabicScriptFace.values)
            DropdownMenuItem(
              value: option,
              child: Text(option.label),
            ),
        ],
        onChanged: (next) async {
          if (next == null) return;
          await prefs.setArabicScriptFace(next);
          ref.read(prefsTickProvider.notifier).state++;
        },
      ),
    );
    Widget sizeButton({
      required Key key,
      required String tooltip,
      required String label,
      required bool enabled,
      required int delta,
    }) {
      return TextButton(
        key: key,
        onPressed: enabled
            ? () async {
                await prefs.setArabicScriptSize(
                  stepArabicScriptSize(size, delta),
                );
                ref.read(prefsTickProvider.notifier).state++;
              }
            : null,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: const Size(36, 32),
          foregroundColor: inkColor,
        ),
        child: Text(label),
      );
    }

    if (compact) {
      return Row(
        children: [
          Expanded(child: Center(child: SizedBox(width: 108, child: face))),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sizeButton(
                    key: smallerKey,
                    tooltip: Copy.arabicScriptSmaller,
                    label: '-',
                    enabled: canSmaller,
                    delta: -1,
                  ),
                  Text(
                    'A',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: inkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  sizeButton(
                    key: largerKey,
                    tooltip: Copy.arabicScriptLarger,
                    label: '+',
                    enabled: canLarger,
                    delta: 1,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(child: compactAction ?? const SizedBox.shrink()),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: face),
        IconButton(
          key: smallerKey,
          tooltip: Copy.arabicScriptSmaller,
          visualDensity: VisualDensity.compact,
          onPressed: canSmaller
              ? () async {
                  await prefs.setArabicScriptSize(
                    stepArabicScriptSize(size, -1),
                  );
                  ref.read(prefsTickProvider.notifier).state++;
                }
              : null,
          icon: const Icon(Icons.text_decrease),
        ),
        IconButton(
          key: largerKey,
          tooltip: Copy.arabicScriptLarger,
          visualDensity: VisualDensity.compact,
          onPressed: canLarger
              ? () async {
                  await prefs.setArabicScriptSize(
                    stepArabicScriptSize(size, 1),
                  );
                  ref.read(prefsTickProvider.notifier).state++;
                }
              : null,
          icon: const Icon(Icons.text_increase),
        ),
      ],
    );
  }
}

class PracticeTopicSkimCard extends StatefulWidget {
  const PracticeTopicSkimCard({
    super.key,
    required this.specKeyPrefix,
    required this.domain,
    required this.items,
    required this.addLabel,
    required this.alreadyFor,
    required this.onAdd,
    this.onOpen,
    this.addedFill,
    this.addedInk,
  });

  final String specKeyPrefix;
  final MonitorDomain domain;
  final List<PracticeDhikrItem> items;
  final String addLabel;
  final bool Function(PracticeDhikrItem item) alreadyFor;
  final Future<void> Function(PracticeDhikrItem item) onAdd;
  final VoidCallback? onOpen;
  final Color? addedFill;
  final Color? addedInk;

  @override
  State<PracticeTopicSkimCard> createState() => _PracticeTopicSkimCardState();
}

class _PracticeTopicSkimCardState extends State<PracticeTopicSkimCard> {
  var _index = 0;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final item = items[_index.clamp(0, items.length - 1)];
    final already = widget.alreadyFor(item);
    final ink = already ? widget.addedInk : null;
    final canPrev = _index > 0;
    final canNext = _index < items.length - 1;
    final prefix = widget.specKeyPrefix;
    final identity = domainColorIdentity(widget.domain);
    final wash = identity.washFor(Theme.of(context).brightness);
    final chrome = already
        ? widget.addedFill ?? weekNavStripWash(identity.family, wash)
        : weekNavStripWash(identity.family, wash);
    final sourceWash = Color.alphaBlend(
      Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
      wash,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: chrome,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: Key('$prefix-practice-item-${items.first.id}'),
            initiallyExpanded: false,
            dense: true,
            visualDensity: VisualDensity.compact,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            childrenPadding: EdgeInsets.zero,
            onExpansionChanged: (open) {
              if (open) widget.onOpen?.call();
            },
            title: Text(
              item.topic,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              PracticeSkimSourceBox(
                sourceWashKey: Key(
                  '$prefix-practice-source-wash-${items.first.id}',
                ),
                sourceWash: sourceWash,
                ink: ink,
                prevKey: Key('$prefix-practice-prev-${items.first.id}'),
                nextKey: Key('$prefix-practice-next-${items.first.id}'),
                canPrev: canPrev,
                canNext: canNext,
                onPrev: () => setState(() {
                  _index--;
                  if (_scroll.hasClients) _scroll.jumpTo(0);
                }),
                onNext: () => setState(() {
                  _index++;
                  if (_scroll.hasClients) _scroll.jumpTo(0);
                }),
                scroll: _scroll,
                scrollKey: Key('$prefix-practice-skim-${items.first.id}'),
                body: PracticeRemembranceCore(
                  contextText: item.text,
                  arabic: item.arabic,
                  transliteration: item.transliteration,
                  translation: item.translation,
                  ink: ink,
                  showScriptControls: false,
                ),
                citation: PracticeCitationLink(
                  buttonKey: Key('$prefix-practice-source-${item.id}'),
                  domain: widget.domain,
                  text: item.text,
                  source: item.source,
                  sourceDetail: item.sourceDetail,
                  ink: ink,
                ),
                indexLabel: '${_index + 1} of ${items.length}',
                scriptBar: PracticeArabicScriptBar(
                  ink: ink,
                  compact: true,
                  faceKey: Key('$prefix-script-face-${items.first.id}'),
                  smallerKey: Key('$prefix-script-smaller-${items.first.id}'),
                  largerKey: Key('$prefix-script-larger-${items.first.id}'),
                  compactAction: TextButton(
                    key: Key('$prefix-practice-add-${item.id}'),
                    onPressed: already ? null : () => widget.onAdd(item),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text(
                      already
                          ? Copy.practiceHadithAlreadyAdded
                          : widget.addLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeHadithRegisterSheet extends ConsumerStatefulWidget {
  const _PracticeHadithRegisterSheet();

  @override
  ConsumerState<_PracticeHadithRegisterSheet> createState() =>
      _PracticeHadithRegisterSheetState();
}

class _PracticeHadithRegisterSheetState
    extends ConsumerState<_PracticeHadithRegisterSheet> {
  final _selected = <String>{};
  String? _message;

  @override
  Widget build(BuildContext context) {
    final records = orderedPracticeHadithRegister(
      practiceRecordsForDomain(
        ref.watch(practiceHadithProvider).value ?? const [],
        MonitorDomain.hadith,
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Copy.practiceHadithRegisterTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            Copy.practiceHadithRegisterNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                key: const Key('hadith-practice-select-all'),
                onPressed: records.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _selected
                            ..clear()
                            ..addAll(records.map((record) => record.id));
                        });
                      },
                child: const Text(Copy.actionSelectAll),
              ),
              TextButton(
                key: const Key('hadith-practice-delete-selected'),
                onPressed: () => _deleteSelected(),
                child: const Text(Copy.actionDeleteSelected),
              ),
            ],
          ),
          if (records.isEmpty)
            Text(
              Copy.practiceHadithRegisterEmpty,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final record in records)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              key: Key('hadith-practice-check-${record.id}'),
                              value: _selected.contains(record.id),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selected.add(record.id);
                                  } else {
                                    _selected.remove(record.id);
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record.topic} · ${formatDayMonthYear(record.addedDateKey)}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                PracticeCitationLink(
                                  domain: MonitorDomain.hadith,
                                  text: record.content,
                                  source: record.source,
                                  sourceDetail: '',
                                ),
                                PracticeRemembranceCore(
                                  contextText: practiceHadithCore(record).text,
                                  arabic: practiceHadithCore(record).arabic,
                                  transliteration: practiceHadithCore(record)
                                      .transliteration,
                                  translation: practiceHadithCore(record)
                                      .translation,
                                ),
                                PracticeRegisterStatusSelect(
                                  dropdownKey: Key(
                                    'hadith-practice-status-${record.id}',
                                  ),
                                  domain: MonitorDomain.hadith,
                                  value: record.status,
                                  onChanged: (status) async {
                                    await ref
                                        .read(practiceHadithProvider.notifier)
                                        .save(record.copyWith(status: status));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: Theme.of(context).textTheme.bodySmall),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Copy.closeActionRegister),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) {
      setState(() => _message = Copy.practiceHadithNothingSelected);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(Copy.practiceHadithConfirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(Copy.closeActionRegister),
            ),
            FilledButton(
              key: const Key('hadith-practice-delete-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.actionConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final ids = [..._selected];
    await ref.read(practiceHadithProvider.notifier).deleteMany(ids);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _message = null;
    });
  }
}

class _PracticeQuranRegisterSheet extends ConsumerStatefulWidget {
  const _PracticeQuranRegisterSheet();

  @override
  ConsumerState<_PracticeQuranRegisterSheet> createState() =>
      _PracticeQuranRegisterSheetState();
}

class _PracticeQuranRegisterSheetState
    extends ConsumerState<_PracticeQuranRegisterSheet> {
  final _selected = <String>{};
  String? _message;

  @override
  Widget build(BuildContext context) {
    final records = orderedPracticeHadithRegister(
      practiceRecordsForDomain(
        ref.watch(practiceHadithProvider).value ?? const [],
        MonitorDomain.quran,
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Copy.practiceQuranRegisterTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            Copy.practiceQuranRegisterNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                key: const Key('quran-practice-select-all'),
                onPressed: records.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _selected
                            ..clear()
                            ..addAll(records.map((record) => record.id));
                        });
                      },
                child: const Text(Copy.actionSelectAll),
              ),
              TextButton(
                key: const Key('quran-practice-delete-selected'),
                onPressed: () => _deleteSelected(),
                child: const Text(Copy.actionDeleteSelected),
              ),
            ],
          ),
          if (records.isEmpty)
            Text(
              Copy.practiceQuranRegisterEmpty,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final record in records)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              key: Key('quran-practice-check-${record.id}'),
                              value: _selected.contains(record.id),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selected.add(record.id);
                                  } else {
                                    _selected.remove(record.id);
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record.topic} · ${formatDayMonthYear(record.addedDateKey)}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                PracticeCitationLink(
                                  domain: MonitorDomain.quran,
                                  text: record.content,
                                  source: record.source,
                                  sourceDetail: '',
                                ),
                                PracticeRemembranceCore(
                                  contextText: practiceHadithCore(record).text,
                                  arabic: practiceHadithCore(record).arabic,
                                  transliteration: practiceHadithCore(record)
                                      .transliteration,
                                  translation: practiceHadithCore(record)
                                      .translation,
                                ),
                                PracticeRegisterStatusSelect(
                                  dropdownKey: Key(
                                    'quran-practice-status-${record.id}',
                                  ),
                                  domain: MonitorDomain.quran,
                                  value: record.status,
                                  onChanged: (status) async {
                                    await ref
                                        .read(practiceHadithProvider.notifier)
                                        .save(record.copyWith(status: status));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: Theme.of(context).textTheme.bodySmall),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Copy.closeActionRegister),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) {
      setState(() => _message = Copy.practiceQuranNothingSelected);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(Copy.practiceQuranConfirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(Copy.closeActionRegister),
            ),
            FilledButton(
              key: const Key('quran-practice-delete-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.actionConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final ids = [..._selected];
    await ref.read(practiceHadithProvider.notifier).deleteMany(ids);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _message = null;
    });
  }
}
