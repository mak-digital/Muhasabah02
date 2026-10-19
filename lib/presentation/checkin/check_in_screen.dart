import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../data/privacy_log.dart';
import '../../domain/activities.dart';
import '../../domain/akhlaq_practices.dart';
import '../../domain/huquq_practices.dart';
import '../../domain/knowledge_practices.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/domain_briefing.dart';
import '../../domain/factor_groups.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/other_domains.dart';
import '../../domain/personal_mix.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/recorded_context.dart';
import '../../domain/salah_extras.dart';
import '../../domain/salah_factors.dart';
import '../../domain/situation_notes.dart';
import '../../domain/health_practices.dart';
import '../../domain/charity_practices.dart';
import '../../domain/fasting_practices.dart';
import '../shared/hajj_standing_editor.dart';
import '../../domain/ummah_practices.dart';
import '../../domain/wealth_practices.dart';
import '../../domain/time_practices.dart';
import '../shared/activity_picker.dart';
import '../shared/akhlaq_follow_up_fields.dart';
import '../shared/huquq_follow_up_fields.dart';
import '../shared/knowledge_follow_up_fields.dart';
import '../shared/time_practice_fields.dart';
import '../shared/domain_briefing_note.dart';
import '../shared/domain_stage.dart';
import '../shared/domain_visual.dart';
import '../shared/home_band_heading.dart';
import '../shared/ui_bits.dart';

enum CheckInFocus { full, salah, quran, traces }

void openFocusedCheckIn(
  BuildContext context, {
  required String dateKey,
  required CheckInFocus focus,
  String? domainTitle,
  String? domainFocus,
  String? focusBand,
  String? focusRowId,
  List<HomeTraceRow> traceRows = const [],
  bool includeZakat = false,
  bool includeHadithFocus = false,
  bool includeHajjStatus = false,
  bool includeStruggleNote = false,
  Color? familyColor,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CheckInScreen(
        date: parseDateKey(dateKey),
        focus: focus,
        domainTitle: domainTitle,
        domainFocus: domainFocus,
        focusBand: focusBand,
        focusRowId: focusRowId,
        traceRows: traceRows,
        includeZakat: includeZakat,
        includeHadithFocus: includeHadithFocus,
        includeHajjStatus: includeHajjStatus,
        includeStruggleNote: includeStruggleNote,
        familyColor: familyColor,
      ),
    ),
  );
}

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({
    super.key,
    this.date,
    this.focus = CheckInFocus.full,
    this.domainTitle,
    this.domainFocus,
    this.focusBand,
    this.focusRowId,
    this.traceRows = const [],
    this.includeZakat = false,
    this.includeHadithFocus = false,
    this.includeHajjStatus = false,
    this.includeStruggleNote = false,
    this.familyColor,
  });

  final DateTime? date;
  final CheckInFocus focus;
  final String? domainTitle;
  final String? domainFocus;
  final String? focusBand;
  final String? focusRowId;
  final List<HomeTraceRow> traceRows;
  final bool includeZakat;
  final bool includeHadithFocus;
  final bool includeHajjStatus;
  final bool includeStruggleNote;
  final Color? familyColor;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  late DailyCheckIn _draft;
  late final TextEditingController _gratitude;
  late final TextEditingController _reflection;
  late final TextEditingController _situationCustom;
  late final TextEditingController _akhlaqStruggle;
  final Map<String, TextEditingController> _custom = {};
  var _loaded = false;
  var _editing = true;
  var _saving = false;
  var _confirmOpen = false;
  var _allowPop = false;
  String? _error;
  late final String _openedDateKey;
  DailyCheckIn? _original;
  final _focusAnchor = GlobalKey(debugLabel: 'checkin-focus-anchor');
  final _focusListController = ScrollController();
  var _focusScrollAttempts = 0;
  late bool _briefingOpen;

  String get _key => _openedDateKey;

  bool get _startsLocked {
    if (widget.focus == CheckInFocus.full) return false;
    return dateCellKind(_key, ref.read(nowProvider)) == DateCellKind.past;
  }

  @override
  void initState() {
    super.initState();
    _openedDateKey = dateKey(widget.date ?? ref.read(nowClockProvider)());
    _draft = DailyCheckIn.empty(_openedDateKey);
    _gratitude = TextEditingController();
    _reflection = TextEditingController();
    _situationCustom = TextEditingController();
    _akhlaqStruggle = TextEditingController();
    _briefingOpen = widget.focusBand == null && widget.focusRowId == null;
    Future<void>.microtask(_hydrate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToFocusedRow();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _editing = !_startsLocked;
    }
  }

  Future<void> _hydrate() async {
    if (_loaded) return;
    final records = await ref.read(checkInsProvider.future);
    DailyCheckIn? existing;
    for (final record in records) {
      if (record.dateKey == _key) existing = record;
    }
    if (!mounted) return;
    final snapshot = existing ?? DailyCheckIn.empty(_openedDateKey);
    final empty = DailyCheckIn.empty(_openedDateKey);
    final pending = _pendingRecord();
    final userStarted = !sameCheckInContent(pending, empty);
    setState(() {
      _original = snapshot;
      _loaded = true;
      _editing = !_startsLocked;
      if (existing != null) {
        final merged = userStarted
            ? overlayCheckInUserEdits(
                baseline: existing,
                userPending: pending,
                empty: empty,
              )
            : existing;
        _draft = merged;
        _gratitude.text = merged.gratitudeText ?? '';
        _reflection.text = merged.personalReflectionText ?? '';
        _situationCustom.text = merged.situationNotes.customText ?? '';
        _akhlaqStruggle.text = merged.akhlaqStruggleNote ?? '';
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToFocusedRow();
    });
  }

  @override
  void dispose() {
    _gratitude.dispose();
    _reflection.dispose();
    _situationCustom.dispose();
    _akhlaqStruggle.dispose();
    _focusListController.dispose();
    for (final c in _custom.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _appBarTitle(String shown) {
    return switch (widget.focus) {
      CheckInFocus.full => 'Check-in · $shown',
      CheckInFocus.salah => '${MonitorDomain.salah.label} · $shown',
      CheckInFocus.quran => '${MonitorDomain.quran.label} · $shown',
      CheckInFocus.traces => '${widget.domainTitle ?? 'Record'} · $shown',
    };
  }

  Set<String> _mixKeysForCards() {
    final prefs = ref.read(appPrefsProvider);
    return PersonalisationResolver(
      visibleDomains: prefs.visibleDomains,
      mix: prefs.personalMix,
    ).effectiveRowIds;
  }

  Widget _anchorIfFocused(String id, Widget child) {
    if (widget.focusRowId != id) return child;
    return KeyedSubtree(key: _focusAnchor, child: child);
  }

  void _scrollToFocusedRow() {
    if (widget.focusRowId == null || widget.focusRowId!.isEmpty) return;
    final target = _focusAnchor.currentContext;
    if (target != null && _focusListController.hasClients) {
      final box = target.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        final offset =
            _focusListController.offset +
            box.localToGlobal(Offset.zero).dy -
            120;
        final max = _focusListController.position.maxScrollExtent;
        _focusListController.jumpTo(offset.clamp(0, max));
        return;
      }
    }
    if (_focusScrollAttempts >= 8) return;
    _focusScrollAttempts++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToFocusedRow();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final shown = formatStoredDateKey(
      _key,
      ref.read(appPrefsProvider).displayCalendar,
    );
    return PopScope(
      canPop: _allowPop || (!_saving && !_isDirty),
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _appBarTitle(shown),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (_startsLocked && !_editing)
              TextButton(
                onPressed: () => setState(() => _editing = true),
                child: const Text(Copy.edit),
              ),
          ],
        ),
        body: widget.focus == CheckInFocus.full
            ? IgnorePointer(
                ignoring: !_editing,
                child: _fullCheckInStage(shown),
              )
            : ListView(
                controller: _focusListController,
                primary: false,
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  IgnorePointer(
                    ignoring: !_editing,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._checkInIntro(shown),
                        ..._focusBody(),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(
              key: const Key('checkin-save'),
              onPressed: !_editing
                  ? () => setState(() => _editing = true)
                  : (_saving || !_loaded)
                  ? null
                  : _save,
              child: Text(
                !_editing
                    ? Copy.edit
                    : widget.focus == CheckInFocus.full
                    ? 'Save check-in'
                    : 'Save',
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _checkInIntro(String shown) {
    return [
      Text(
        _startsLocked && !_editing
            ? Copy.pastSalahEntryNote
            : Copy.unansweredNotMissed,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
      Text(
        shown,
        key: const Key('checkin-recording-date'),
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
    ];
  }

  Widget _fullCheckInStage(String shown) {
    final prefs = ref.read(appPrefsProvider);
    final resolver = PersonalisationResolver(
      visibleDomains: prefs.visibleDomains,
      mix: prefs.personalMix,
    );
    final mixKeys = resolver.effectiveRowIds;
    return DomainStage(
      domains: resolver.homeDomains,
      cardFor: (domain) =>
          _widgetForDomain(domain, expandFirst: true, mixKeys: mixKeys),
      stageProvider: checkInDomainStageProvider,
      keyPrefix: 'checkin-domain',
      pillsNote: Copy.checkInDomainPillsNote,
      fillViewport: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      aboveCard: _checkInIntro(shown),
      belowCard: [
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        _otherCard(),
        const SizedBox(height: 12),
        _situationNotesCard(),
      ],
    );
  }

  List<Widget> _focusBody() {
    final mixKeys = _mixKeysForCards();
    switch (widget.focus) {
      case CheckInFocus.salah:
        return [_salahCard(mixKeys: mixKeys)];
      case CheckInFocus.quran:
        return [_quranCard(mixKeys: mixKeys)];
      case CheckInFocus.traces:
        return _tracesBody(mixKeys);
      case CheckInFocus.full:
        return const [];
    }
  }

  String? get _effectiveFocusBand {
    if (widget.focusBand != null && widget.focusBand!.isNotEmpty) {
      return widget.focusBand;
    }
    final id = widget.focusRowId;
    if (id == null || id.isEmpty) return null;
    if (id == kZakatMixKey) return kZakatTraceBand;
    for (final row in widget.traceRows) {
      if (row.storageKey == id) return row.band;
    }
    return mixItemById[id]?.band;
  }

  bool _sectionStartsOpen(
    String band, {
    required String firstBand,
    required bool expandFirst,
  }) {
    if (widget.focus == CheckInFocus.full) {
      return expandFirst && band == firstBand;
    }
    final focus = _effectiveFocusBand;
    if (focus == null || focus.isEmpty) return band == firstBand;
    return band == focus;
  }

  bool _mixAllows(Set<String> mixKeys, String id) {
    if (mixKeys.isEmpty) return true;
    return mixKeys.contains(id);
  }

  Widget _salahCard({bool expandFirst = true, Set<String> mixKeys = const {}}) {
    final title = MonitorDomain.salah.label;
    final obligatory = [
      for (final id in PrayerId.values)
        if (_mixAllows(mixKeys, 'salah.${id.name}')) id,
    ];
    final showJumuah = _mixAllows(mixKeys, 'salah.jumuah');
    final showTahajjud = _mixAllows(mixKeys, 'salah.tahajjud');
    final showIshraq = _mixAllows(mixKeys, 'salah.ishraq');
    final showVoluntary = showTahajjud || showIshraq;
    final firstBand = obligatory.isNotEmpty
        ? kSalahObligatoryBand
        : showJumuah
        ? kSalahFridayBand
        : kSalahVoluntaryBand;
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.salahWash,
        MuhasabahColors.salahWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInDomainTitle(title, focus: MonitorDomain.salah.focusQuestion),
          const SizedBox(height: 4),
          const Text(
            'Each prayer is recorded independently. Absence is not missed.',
          ),
          const SizedBox(height: 12),
          if (obligatory.isNotEmpty)
            _collapsibleTraceBand(
              title: title,
              band: kSalahObligatoryBand,
              family: MuhasabahColors.salahFamily,
              initiallyExpanded: _sectionStartsOpen(
                kSalahObligatoryBand,
                firstBand: firstBand,
                expandFirst: expandFirst,
              ),
              children: [
                for (final id in obligatory)
                  _anchorIfFocused('salah.${id.name}', _prayerRow(id)),
              ],
            ),
          if (showJumuah)
            _collapsibleTraceBand(
              title: title,
              band: kSalahFridayBand,
              family: MuhasabahColors.salahFamily,
              initiallyExpanded: _sectionStartsOpen(
                kSalahFridayBand,
                firstBand: firstBand,
                expandFirst: expandFirst,
              ),
              children: [
                const Text(
                  'These stay off the recordable-field count. Unanswered is not missed.',
                ),
                const SizedBox(height: 8),
                _anchorIfFocused('salah.jumuah', _jumuahRow()),
              ],
            ),
          if (showVoluntary)
            _collapsibleTraceBand(
              title: title,
              band: kSalahVoluntaryBand,
              family: MuhasabahColors.salahFamily,
              initiallyExpanded: _sectionStartsOpen(
                kSalahVoluntaryBand,
                firstBand: firstBand,
                expandFirst: expandFirst,
              ),
              children: [
                const Text(
                  'These stay off the recordable-field count. Unanswered is not missed.',
                ),
                const SizedBox(height: 8),
                if (showTahajjud)
                  _anchorIfFocused(
                    'salah.tahajjud',
                    _voluntaryRow(SalahTraceRow.tahajjud),
                  ),
                if (showIshraq)
                  _anchorIfFocused(
                    'salah.ishraq',
                    _voluntaryRow(SalahTraceRow.ishraq),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _prayerRow(PrayerId id) {
    final key = ActivityCatalog.salahKey(id);
    final selected = _draft.activityFor(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(
            id.label,
            semanticsLabel: '${id.label}, currently ${_draft.prayer(id).label}',
          ),
          const SizedBox(height: 6),
          ActivityPicker(
            options: ActivityCatalog.salah,
            selectedId: selected.id,
            statusKeyPrefix: 'salah-${id.name}',
            onSelected: (option) => setState(() {
              var next = _draft.withSalahActivity(
                id,
                RecordedActivity(
                  id: option.id,
                  customText: option.isOther ? _note(key).text : null,
                ),
              );
              final groups = factorGroupsForSalahActivity(option.id);
              final existing =
                  next.salahFactors[id.name] ?? const SalahFactorCapture();
              _draft = next.withSalahFactors(
                id.name,
                SalahFactorCapture(
                  supportIds: groups.showHelping
                      ? existing.supportIds.take(1).toList()
                      : const [],
                  challengeIds: groups.showDistracting
                      ? existing.challengeIds.take(1).toList()
                      : const [],
                  otherText: existing.otherText,
                ),
              );
            }),
          ),
          if (selected.id == ActivityIds.other)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: checkInValueIndent),
              child: TextField(
                controller: _note(key, selected.customText),
                decoration: const InputDecoration(
                  hintText: 'Describe the other activity',
                ),
                onChanged: (value) {
                  _draft = _draft.withSalahActivity(
                    id,
                    RecordedActivity(id: ActivityIds.other, customText: value),
                  );
                },
              ),
            ),
          if (factorGroupsForSalahActivity(selected.id).isVisible)
            _salahFactors(id.name, factorGroupsForSalahActivity(selected.id)),
        ],
      ),
    );
  }

  Widget _jumuahRow() {
    const key = ActivityCatalog.jumuahKey;
    final selected = _draft.activityFor(key);
    final friday = parseDateKey(_key).weekday == DateTime.friday;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(
            'Jumu‘ah',
            semanticsLabel: 'Jumu‘ah, currently ${selected.id}',
          ),
          if (!friday)
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'Friday only. Other days stay blank, not unanswered.',
              ),
            ),
          const SizedBox(height: 6),
          ActivityPicker(
            options: ActivityCatalog.jumuah,
            selectedId: selected.id,
            statusKeyPrefix: 'salah-jumuah',
            enabled: friday,
            onSelected: (option) => setState(() {
              var next = _draft.withJumuahActivity(
                RecordedActivity(
                  id: option.id,
                  customText: option.isOther ? _note(key).text : null,
                ),
              );
              final groups = factorGroupsForSalahActivity(option.id);
              final existing =
                  next.salahFactors['jumuah'] ?? const SalahFactorCapture();
              _draft = next.withSalahFactors(
                'jumuah',
                SalahFactorCapture(
                  supportIds: groups.showHelping
                      ? existing.supportIds.take(1).toList()
                      : const [],
                  challengeIds: groups.showDistracting
                      ? existing.challengeIds.take(1).toList()
                      : const [],
                  otherText: existing.otherText,
                ),
              );
            }),
          ),
          if (selected.id == ActivityIds.other)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: checkInValueIndent),
              child: TextField(
                controller: _note(key, selected.customText),
                decoration: const InputDecoration(
                  hintText: 'Describe the other activity',
                ),
                onChanged: (value) {
                  _draft = _draft.withJumuahActivity(
                    RecordedActivity(id: ActivityIds.other, customText: value),
                  );
                },
              ),
            ),
          if (factorGroupsForSalahActivity(selected.id).isVisible)
            _salahFactors('jumuah', factorGroupsForSalahActivity(selected.id)),
        ],
      ),
    );
  }

  Widget _voluntaryRow(SalahTraceRow row) {
    final key = ActivityCatalog.voluntarySalahKey(row);
    final selected = _draft.activityFor(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(row.label),
          const SizedBox(height: 6),
          ActivityPicker(
            options: ActivityCatalog.forVoluntarySalah(row),
            selectedId: selected.id,
            statusKeyPrefix: 'salah-${row.name}',
            onSelected: (option) => setState(() {
              _draft = _draft.withVoluntarySalahActivity(
                row,
                RecordedActivity(id: option.id),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _salahFactors(String subject, FactorGroups groups) {
    final existing = _draft.salahFactors[subject] ?? const SalahFactorCapture();
    return CheckInFactorSelects(
      groups: groups,
      helping: [
        for (final factor in SalahFactorCatalog.withExisting(
          SalahFactorCatalog.supportFor(subject),
          existing.supportIds,
        ))
          NamedFactor(id: factor.id, label: factor.label),
      ],
      distracting: [
        for (final factor in SalahFactorCatalog.withExisting(
          SalahFactorCatalog.challengeFor(subject),
          existing.challengeIds,
        ))
          NamedFactor(id: factor.id, label: factor.label),
      ],
      helpingId: selectedFactorId(existing.supportIds),
      distractingId: selectedFactorId(existing.challengeIds),
      helpingKey: Key('salah-$subject-helping'),
      distractingKey: Key('salah-$subject-distracting'),
      onHelpingChanged: (id) => setState(() {
        _draft = _draft.withSalahFactors(
          subject,
          SalahFactorCapture(
            supportIds: idsFromFactorChoice(id),
            challengeIds: existing.challengeIds.take(1).toList(),
            otherText: existing.otherText,
          ),
        );
      }),
      onDistractingChanged: (id) => setState(() {
        _draft = _draft.withSalahFactors(
          subject,
          SalahFactorCapture(
            supportIds: existing.supportIds.take(1).toList(),
            challengeIds: idsFromFactorChoice(id),
            otherText: existing.otherText,
          ),
        );
      }),
    );
  }

  Widget _quranCard({bool expandFirst = true, Set<String> mixKeys = const {}}) {
    final title = MonitorDomain.quran.label;
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.quranWash,
        MuhasabahColors.quranWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInDomainTitle(title, focus: MonitorDomain.quran.focusQuestion),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const Key('quran-checkin-intro'),
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text(
                Copy.quranCheckInIntroTitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Copy.quranCheckInIntro),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Copy.quranCheckInFactorsIntro),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final entry in quranHomeBandsFor([
            for (final dimension in quranDailyDimensions)
              if (_mixAllows(mixKeys, 'quran.${dimension.name}')) dimension,
          ])) ...[
            HomeBandHeading(
              band: entry.$1,
              family: MuhasabahColors.quranFamily,
              baseWash: MuhasabahColors.wash(
                MuhasabahColors.quranWash,
                MuhasabahColors.quranWashDark,
                Theme.of(context).brightness,
              ),
            ),
            const SizedBox(height: 8),
            for (final dimension in entry.$2)
              _anchorIfFocused(
                'quran.${dimension.name}',
                _quranBlock(dimension),
              ),
          ],
        ],
      ),
    );
  }

  Widget _quranBlock(QuranDimension dimension) {
    final key = ActivityCatalog.quranKey(dimension);
    final selected = _draft.activityFor(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(dimension.label),
          const SizedBox(height: 4),
          Text(dimension.question),
          const SizedBox(height: 8),
          ActivityPicker(
            options: ActivityCatalog.forQuran(dimension),
            selectedId: selected.id,
            statusKeyPrefix: 'quran-${dimension.name}',
            onSelected: (option) => setState(() {
              _draft = _draft.withQuranActivity(
                dimension,
                RecordedActivity(
                  id: option.id,
                  customText: option.isOther ? _note(key).text : null,
                ),
              );
            }),
          ),
          if (selected.id == ActivityIds.other)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: checkInValueIndent),
              child: TextField(
                controller: _note(key, selected.customText),
                decoration: const InputDecoration(
                  hintText: 'Describe the other activity',
                ),
                onChanged: (value) {
                  _draft = _draft.withQuranActivity(
                    dimension,
                    RecordedActivity(id: ActivityIds.other, customText: value),
                  );
                },
              ),
            ),
          if (_quranFactorGroups(dimension).isVisible) _quranFactors(dimension),
        ],
      ),
    );
  }

  FactorGroups _quranFactorGroups(QuranDimension dimension) {
    final selected = _draft.activityFor(ActivityCatalog.quranKey(dimension));
    if (selected.id == ActivityIds.other ||
        selected.id == ActivityIds.unanswered) {
      return FactorGroups.none;
    }
    return factorGroupsForTernary(_draft.quranOutcome(dimension));
  }

  Widget _quranFactors(QuranDimension dimension) {
    final groups = _quranFactorGroups(dimension);
    final outcome = _draft.quranOutcome(dimension);
    final polarity = outcome == TernaryOutcome.positive
        ? 'positive'
        : 'negative';
    final existing = _draft.contextFor(dimension, polarity);
    return CheckInFactorSelects(
      groups: groups,
      helping: [
        for (final factor in ContextCatalog.positive)
          NamedFactor(id: factor.id, label: factor.label),
      ],
      distracting: [
        for (final factor in ContextCatalog.negative)
          NamedFactor(id: factor.id, label: factor.label),
      ],
      helpingId: safeFactorId(
        selectedFactorId(existing?.factorIds ?? const []),
        ContextCatalog.positive.map((factor) => factor.id),
      ),
      distractingId: safeFactorId(
        selectedFactorId(existing?.factorIds ?? const []),
        ContextCatalog.negative.map((factor) => factor.id),
      ),
      helpingKey: Key('quran-${dimension.name}-helping'),
      distractingKey: Key('quran-${dimension.name}-distracting'),
      onHelpingChanged: (id) => setState(() {
        _draft = _draft.withContext(
          RecordedContext(
            subject: dimension,
            polarity: polarity,
            factorIds: idsFromFactorChoice(id),
            freeText: existing?.freeText,
          ),
        );
      }),
      onDistractingChanged: (id) => setState(() {
        _draft = _draft.withContext(
          RecordedContext(
            subject: dimension,
            polarity: polarity,
            factorIds: idsFromFactorChoice(id),
            freeText: existing?.freeText,
          ),
        );
      }),
    );
  }

  TextEditingController _note(String key, [String? seed]) {
    return _custom.putIfAbsent(
      key,
      () => TextEditingController(text: seed ?? ''),
    );
  }

  void _collapseBriefing() {
    if (!_briefingOpen) return;
    setState(() => _briefingOpen = false);
  }

  bool _traceBandStartsOpen(String band) {
    final focus = _effectiveFocusBand;
    if (focus == null || focus.isEmpty) {
      final bands = bandsFor(widget.traceRows);
      return bands.isNotEmpty && band == bands.first;
    }
    return band == focus;
  }

  DomainBriefing? _focusedBriefing() {
    if (widget.includeStruggleNote) return akhlaqBriefing;
    return briefingForLabel(widget.domainTitle);
  }

  List<Widget> _tracesBody(Set<String> mixKeys) {
    final accent = widget.familyColor ?? MuhasabahColors.dhikr;
    var visible = widget.traceRows;
    if (visible.any((row) => row.storageKey.startsWith('fasting.'))) {
      final prefs = ref.watch(appPrefsProvider);
      visible = gatedFastingHomeRows(
        visible,
        date: parseDateKey(_openedDateKey),
        offsetDays: prefs.ramadanCalendarOffsetDays,
        showHistory: prefs.showFastingRamadanHistory,
        records: [_draft],
      );
    }
    final rows = [
      for (final row in visible)
        if (mixKeys.isEmpty || mixKeys.contains(row.storageKey)) row,
    ];
    final bands = bandsFor(rows);
    final includeZakat =
        widget.includeZakat &&
        (mixKeys.isEmpty || mixKeys.contains(kZakatMixKey));
    return [
      CheckInDomainTitle(
        widget.domainTitle ?? 'Record',
        focus: widget.domainFocus,
      ),
      const SizedBox(height: 4),
      if (_focusedBriefing() != null)
        CollapsingDomainBriefingNote(
          _focusedBriefing()!,
          expanded: _briefingOpen,
          onExpansionChanged: (open) {
            if (open == _briefingOpen) return;
            setState(() => _briefingOpen = open);
          },
        )
      else
        const Text(
          'Only this domain is shown. Other records for the day stay unchanged.',
        ),
      const SizedBox(height: 12),
      if (widget.includeHajjStatus) const HajjStandingEditor(bottomPadding: 12),
      for (var i = 0; i < bands.length; i++)
        _collapsibleTraceBand(
          title: widget.domainTitle ?? 'Record',
          band: bands[i],
          family: accent,
          initiallyExpanded: _traceBandStartsOpen(bands[i]),
          children: [
            for (final row in rows)
              if (row.band == bands[i])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WashPanel(
                    color: Color.alphaBlend(
                      accent.withValues(alpha: 0.16),
                      Theme.of(context).colorScheme.surface,
                    ),
                    child: _anchorIfFocused(row.storageKey, _traceEditor(row)),
                  ),
                ),
          ],
        ),
      if (includeZakat)
        _collapsibleTraceBand(
          title: widget.domainTitle ?? 'Record',
          band: kZakatTraceBand,
          family: accent,
          initiallyExpanded: _effectiveFocusBand == kZakatTraceBand,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WashPanel(
                color: Color.alphaBlend(
                  accent.withValues(alpha: 0.16),
                  Theme.of(context).colorScheme.surface,
                ),
                child: _anchorIfFocused(kZakatMixKey, _zakatEditor()),
              ),
            ),
          ],
        ),
      if (widget.includeHadithFocus) _hadithFocusEditor(),
      if (widget.includeStruggleNote) ...[
        const SizedBox(height: 8),
        _akhlaqStruggleEditor(),
      ],
    ];
  }

  Widget _traceEditor(HomeTraceRow row, {bool includeFactors = true}) {
    final catalog = ActivityCatalog.forHomeTrace(row.storageKey);
    if (catalog.isNotEmpty) {
      return _activityTraceEditor(row, catalog, includeFactors: includeFactors);
    }
    final outcome = _draft.homeTrace(row.storageKey);
    final factors =
        _draft.homeTraceFactors[row.storageKey] ?? const SalahFactorCapture();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(row.label),
          const SizedBox(height: 6),
          CheckInSelect<TernaryOutcome>(
            dropdownKey: Key('trace-${row.storageKey}'),
            value: outcome,
            sortLabels: false,
            entries: [
              for (final option in TernaryOutcome.values)
                CheckInSelectEntry(
                  value: option,
                  label: traceOutcomeLabel(row.storageKey, option),
                  itemKey: Key('trace-${row.storageKey}-${option.name}'),
                ),
            ],
            onChanged: (option) => setState(() {
              var next = _draft.withHomeTrace(row.storageKey, option);
              if (!hidesHomeTraceFactors(row.storageKey)) {
                next = next.withHomeTraceFactors(
                  row.storageKey,
                  nextHomeTraceFactors(
                    storageKey: row.storageKey,
                    outcome: option,
                    existing: factors,
                  ),
                );
              }
              _draft = next;
            }),
          ),
          if (includeFactors && !hidesHomeTraceFactors(row.storageKey))
            CheckInFactorSelects.forHomeTrace(
              storageKey: row.storageKey,
              outcome: outcome,
              factors: factors,
              helpingKey: Key('trace-${row.storageKey}-helping'),
              distractingKey: Key('trace-${row.storageKey}-distracting'),
              onHelpingChanged: (id) => setState(() {
                _draft = _draft.withHomeTraceFactors(
                  row.storageKey,
                  SalahFactorCapture(
                    supportIds: idsFromFactorChoice(id),
                    challengeIds: factors.challengeIds.take(1).toList(),
                    otherText: factors.otherText,
                  ),
                );
              }),
              onDistractingChanged: (id) => setState(() {
                _draft = _draft.withHomeTraceFactors(
                  row.storageKey,
                  SalahFactorCapture(
                    supportIds: factors.supportIds.take(1).toList(),
                    challengeIds: idsFromFactorChoice(id),
                    otherText: factors.otherText,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _activityTraceEditor(
    HomeTraceRow row,
    List<ActivityOption> catalog, {
    required bool includeFactors,
  }) {
    final key = row.storageKey;
    final selected = _draft.activityFor(key);
    final outcome = _draft.homeTrace(key);
    final factors = _draft.homeTraceFactors[key] ?? const SalahFactorCapture();
    final timePractice = timePracticeByKey(key);
    final timeCapture = isTimeTrace(key)
        ? readTimePractice(_draft, key)
        : const TimePracticeCapture();
    final akhlaqCapture = isAkhlaqTrace(key)
        ? readAkhlaqFollowUp(_draft, key)
        : const AkhlaqFollowUpCapture();
    final huquqCapture = isHuquqTrace(key)
        ? readHuquqFollowUp(_draft, key)
        : const HuquqFollowUpCapture();
    final knowledgeCapture = isKnowledgeTrace(key)
        ? readKnowledgeFollowUp(_draft, key)
        : const KnowledgeFollowUpCapture();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(row.label),
          const SizedBox(height: 6),
          ActivityPicker(
            options: catalog,
            selectedId: selected.id,
            statusKeyPrefix: 'trace-$key',
            namedSubject:
                isDhikrPostFardTrace(key) ||
                    isAkhlaqTrace(key) ||
                    isHuquqTrace(key) ||
                    isKnowledgeTrace(key) ||
                    isTimeTrace(key) ||
                    isHealthTrace(key) ||
                    isWealthTrace(key) ||
                    isUmmahTrace(key)
                ? row.label
                : null,
            onSelected: (option) => setState(() {
              if (isTimeTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    const TimePracticeCapture(),
                  );
                  return;
                }
                final existing = readTimePractice(_draft, key);
                _draft = writeTimePractice(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (isAkhlaqTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeAkhlaqFollowUp(
                    _draft,
                    key,
                    const AkhlaqFollowUpCapture(),
                  );
                  return;
                }
                final existing = readAkhlaqFollowUp(_draft, key);
                _draft = writeAkhlaqFollowUp(
                  _draft,
                  key,
                  AkhlaqFollowUpCapture(
                    primaryId: option.id,
                    contextId: existing.contextId,
                    helpId: existing.helpId,
                    note: existing.note,
                  ),
                );
                return;
              }
              if (isHuquqTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeHuquqFollowUp(
                    _draft,
                    key,
                    const HuquqFollowUpCapture(),
                  );
                  return;
                }
                final existing = readHuquqFollowUp(_draft, key);
                _draft = writeHuquqFollowUp(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (isKnowledgeTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeKnowledgeFollowUp(
                    _draft,
                    key,
                    const KnowledgeFollowUpCapture(),
                  );
                  return;
                }
                final existing = readKnowledgeFollowUp(_draft, key);
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (isHealthTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeHealthPractice(
                    _draft,
                    key,
                    const HealthPracticeCapture(),
                  );
                  return;
                }
                final existing = readHealthPractice(_draft, key);
                _draft = writeHealthPractice(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (isWealthTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeWealthPractice(
                    _draft,
                    key,
                    const WealthPracticeCapture(),
                  );
                  return;
                }
                final existing = readWealthPractice(_draft, key);
                _draft = writeWealthPractice(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (isUmmahTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeUmmahPractice(
                    _draft,
                    key,
                    const UmmahPracticeCapture(),
                  );
                  return;
                }
                final existing = readUmmahPractice(_draft, key);
                _draft = writeUmmahPractice(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (key.startsWith('charity.')) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeCharityPractice(
                    _draft,
                    key,
                    const CharityPracticeCapture(),
                  );
                  return;
                }
                final existing = readCharityPractice(_draft, key);
                _draft = writeCharityPractice(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              if (isFastingPracticeTrace(key)) {
                if (option.id == ActivityIds.unanswered) {
                  _draft = writeFastingPractice(
                    _draft,
                    key,
                    const FastingPracticeCapture(),
                  );
                  return;
                }
                final existing = readFastingPractice(_draft, key);
                _draft = writeFastingPractice(
                  _draft,
                  key,
                  existing.copyWith(primaryId: option.id),
                );
                return;
              }
              var next = _draft.withHomeTraceActivity(
                key,
                RecordedActivity(
                  id: option.id,
                  customText: option.isOther ? _note(key).text : null,
                ),
              );
              if (!hidesHomeTraceFactors(key)) {
                next = next.withHomeTraceFactors(
                  key,
                  nextHomeTraceFactors(
                    storageKey: key,
                    outcome: option.ternary ?? TernaryOutcome.unanswered,
                    existing: factors,
                  ),
                );
              }
              _draft = next;
            }),
          ),
          if (timePractice != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, left: checkInValueIndent),
              child: Text(
                timePractice.detail,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (selected.id != ActivityIds.unanswered)
              TimePracticeFields(
                storageKey: key,
                contextId: timeCapture.contextId,
                challengeId: timeCapture.challengeId,
                helpId: timeCapture.helpId,
                outcomeId: timeCapture.outcomeId,
                quantityId: timeCapture.quantityId,
                quantityText: timeCapture.quantityText,
                quantityController: _note(
                  '$key-time-amount',
                  timeCapture.quantityText,
                ),
                onContextChanged: (id) => setState(() {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    timeCapture.copyWith(primaryId: selected.id, contextId: id),
                  );
                }),
                onChallengeChanged: (id) => setState(() {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    timeCapture.copyWith(
                      primaryId: selected.id,
                      challengeId: id,
                    ),
                  );
                }),
                onHelpChanged: (id) => setState(() {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    timeCapture.copyWith(primaryId: selected.id, helpId: id),
                  );
                }),
                onOutcomeChanged: (id) => setState(() {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    timeCapture.copyWith(primaryId: selected.id, outcomeId: id),
                  );
                }),
                onQuantityChanged: (id) => setState(() {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    timeCapture.copyWith(
                      primaryId: selected.id,
                      quantityId: id,
                    ),
                  );
                }),
                onQuantityTextChanged: (value) {
                  _draft = writeTimePractice(
                    _draft,
                    key,
                    timeCapture.copyWith(
                      primaryId: selected.id,
                      quantityText: value,
                    ),
                  );
                },
              ),
          ],
          if (isKnowledgeTrace(key) && selected.id != ActivityIds.unanswered)
            KnowledgeFollowUpFields(
              storageKey: key,
              areaId: knowledgeCapture.areaId,
              sourceId: knowledgeCapture.sourceId,
              verificationId: knowledgeCapture.verificationId,
              understandingId: knowledgeCapture.understandingId,
              applicationId: knowledgeCapture.applicationId,
              quantityId: knowledgeCapture.quantityId,
              minutes: knowledgeCapture.minutes,
              note: knowledgeCapture.note,
              minutesController: _note(
                '$key-knowledge-minutes',
                knowledgeCapture.minutes,
              ),
              noteController: _note(
                '$key-knowledge-note',
                knowledgeCapture.note,
              ),
              onAreaChanged: (id) => setState(() {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(primaryId: selected.id, areaId: id),
                );
              }),
              onSourceChanged: (id) => setState(() {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    sourceId: id,
                  ),
                );
              }),
              onVerificationChanged: (id) => setState(() {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    verificationId: id,
                  ),
                );
              }),
              onUnderstandingChanged: (id) => setState(() {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    understandingId: id,
                  ),
                );
              }),
              onApplicationChanged: (id) => setState(() {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    applicationId: id,
                  ),
                );
              }),
              onQuantityChanged: (id) => setState(() {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    quantityId: id,
                  ),
                );
              }),
              onMinutesChanged: (value) {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    minutes: value,
                  ),
                );
              },
              onNoteChanged: (value) {
                _draft = writeKnowledgeFollowUp(
                  _draft,
                  key,
                  knowledgeCapture.copyWith(
                    primaryId: selected.id,
                    note: value,
                  ),
                );
              },
            ),
          if (isHuquqTrace(key) && selected.id != ActivityIds.unanswered)
            HuquqFollowUpFields(
              storageKey: key,
              engagementId: huquqCapture.engagementId,
              outcomeId: huquqCapture.outcomeId,
              occasions: huquqCapture.occasions,
              timeSpent: huquqCapture.timeSpent,
              note: huquqCapture.note,
              occasionsController: _note(
                '$key-huquq-occasions',
                huquqCapture.occasions,
              ),
              timeSpentController: _note(
                '$key-huquq-time',
                huquqCapture.timeSpent,
              ),
              noteController: _note('$key-huquq-note', huquqCapture.note),
              onEngagementChanged: (id) => setState(() {
                _draft = writeHuquqFollowUp(
                  _draft,
                  key,
                  huquqCapture.copyWith(
                    primaryId: selected.id,
                    engagementId: id,
                  ),
                );
              }),
              onOutcomeChanged: (id) => setState(() {
                _draft = writeHuquqFollowUp(
                  _draft,
                  key,
                  huquqCapture.copyWith(primaryId: selected.id, outcomeId: id),
                );
              }),
              onOccasionsChanged: (value) {
                _draft = writeHuquqFollowUp(
                  _draft,
                  key,
                  huquqCapture.copyWith(
                    primaryId: selected.id,
                    occasions: value,
                  ),
                );
              },
              onTimeSpentChanged: (value) {
                _draft = writeHuquqFollowUp(
                  _draft,
                  key,
                  huquqCapture.copyWith(
                    primaryId: selected.id,
                    timeSpent: value,
                  ),
                );
              },
              onNoteChanged: (value) {
                _draft = writeHuquqFollowUp(
                  _draft,
                  key,
                  huquqCapture.copyWith(primaryId: selected.id, note: value),
                );
              },
            ),
          if (isAkhlaqTrace(key) && selected.id != ActivityIds.unanswered)
            AkhlaqFollowUpFields(
              storageKey: key,
              contextId: akhlaqCapture.contextId,
              helpId: akhlaqCapture.helpId,
              note: akhlaqCapture.note,
              noteController: _note('$key-akhlaq-note', akhlaqCapture.note),
              onContextChanged: (id) => setState(() {
                _draft = writeAkhlaqFollowUp(
                  _draft,
                  key,
                  AkhlaqFollowUpCapture(
                    primaryId: selected.id,
                    contextId: id,
                    helpId: akhlaqCapture.helpId,
                    note: akhlaqCapture.note,
                  ),
                );
              }),
              onHelpChanged: (id) => setState(() {
                _draft = writeAkhlaqFollowUp(
                  _draft,
                  key,
                  AkhlaqFollowUpCapture(
                    primaryId: selected.id,
                    contextId: akhlaqCapture.contextId,
                    helpId: id,
                    note: akhlaqCapture.note,
                  ),
                );
              }),
              onNoteChanged: (value) {
                _draft = writeAkhlaqFollowUp(
                  _draft,
                  key,
                  AkhlaqFollowUpCapture(
                    primaryId: selected.id,
                    contextId: akhlaqCapture.contextId,
                    helpId: akhlaqCapture.helpId,
                    note: value,
                  ),
                );
              },
            ),
          if (selected.id == ActivityIds.other)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: checkInValueIndent),
              child: TextField(
                controller: _note(key, selected.customText),
                decoration: const InputDecoration(
                  hintText: 'Describe the other activity',
                ),
                onChanged: (value) {
                  _draft = _draft.withHomeTraceActivity(
                    key,
                    RecordedActivity(id: ActivityIds.other, customText: value),
                  );
                },
              ),
            ),
          if (includeFactors && !hidesHomeTraceFactors(key))
            CheckInFactorSelects.forHomeTrace(
              storageKey: key,
              outcome: outcome,
              factors: factors,
              helpingKey: Key('trace-$key-helping'),
              distractingKey: Key('trace-$key-distracting'),
              onHelpingChanged: (id) => setState(() {
                _draft = _draft.withHomeTraceFactors(
                  key,
                  SalahFactorCapture(
                    supportIds: idsFromFactorChoice(id),
                    challengeIds: factors.challengeIds.take(1).toList(),
                    otherText: factors.otherText,
                  ),
                );
              }),
              onDistractingChanged: (id) => setState(() {
                _draft = _draft.withHomeTraceFactors(
                  key,
                  SalahFactorCapture(
                    supportIds: factors.supportIds.take(1).toList(),
                    challengeIds: idsFromFactorChoice(id),
                    otherText: factors.otherText,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _zakatEditor() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckInRowLabel('Zakat'),
          const SizedBox(height: 6),
          CheckInSelect<ZakatStatus>(
            dropdownKey: const Key('zakat-status'),
            value: _draft.zakat,
            sortLabels: false,
            entries: [
              for (final status in kZakatPickerOrder)
                CheckInSelectEntry(value: status, label: status.label),
            ],
            onChanged: (status) => setState(() {
              _draft = _draft.copyWith(zakat: status);
            }),
          ),
        ],
      ),
    );
  }

  Widget _hadithFocusEditor() {
    final prefs = ref.watch(appPrefsProvider);
    final current = prefs.hadithMemorisationFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckInRowLabel(Copy.hadithMemorisationFocus),
        CheckInSelect<HadithMemorisationFocus>(
          dropdownKey: const Key('hadith-memorisation-focus'),
          value: current,
          entries: [
            for (final option in HadithMemorisationFocus.values)
              CheckInSelectEntry(value: option, label: option.label),
          ],
          onChanged: (option) async {
            await prefs.setHadithMemorisationFocus(option);
            ref.read(prefsTickProvider.notifier).state++;
          },
        ),
      ],
    );
  }

  Widget _akhlaqStruggleEditor() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckInRowLabel(Copy.akhlaqStruggleNote),
          const SizedBox(height: 4),
          Text(
            Copy.akhlaqStruggleHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _akhlaqStruggle,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'I was impatient today, but I caught myself',
            ),
          ),
        ],
      ),
    );
  }

  Widget _otherCard() {
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.dhikrWash,
        MuhasabahColors.dhikrWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckInDomainTitle('Other observations'),
          const SizedBox(height: 12),
          const CheckInRowLabel('Dhikr / Istighfar'),
          ActivityPicker(
            options: ActivityCatalog.dhikr,
            selectedId: _draft.activityFor(ActivityCatalog.dhikrKey).id,
            statusKeyPrefix: 'other-dhikr',
            onSelected: (option) => setState(() {
              _draft = _draft
                  .copyWith(dhikr: option.dhikr ?? DhikrStatus.unanswered)
                  .withActivity(
                    ActivityCatalog.dhikrKey,
                    RecordedActivity(id: option.id),
                  );
            }),
          ),
          const SizedBox(height: 16),
          const CheckInRowLabel('Gratitude'),
          CheckInSelect<EntryStatus>(
            dropdownKey: const Key('gratitude-status'),
            value: _draft.gratitudeStatus,
            entries: const [
              CheckInSelectEntry(
                value: EntryStatus.recorded,
                label: 'Wrote an entry',
              ),
              CheckInSelectEntry(
                value: EntryStatus.noneToday,
                label: 'No entry today',
              ),
              CheckInSelectEntry(
                value: EntryStatus.unanswered,
                label: 'Not recorded',
              ),
            ],
            onChanged: (status) => setState(() {
              if (status == EntryStatus.recorded) {
                _draft = _draft.copyWith(gratitudeStatus: EntryStatus.recorded);
              } else if (status == EntryStatus.noneToday) {
                _draft = _draft.copyWith(
                  gratitudeStatus: EntryStatus.noneToday,
                  clearGratitudeText: true,
                );
                _gratitude.clear();
              } else {
                _draft = _draft.copyWith(
                  gratitudeStatus: EntryStatus.unanswered,
                );
              }
            }),
          ),
          if (_draft.gratitudeStatus == EntryStatus.recorded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: checkInValueIndent),
              child: TextField(
                controller: _gratitude,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Optional private gratitude notes',
                ),
              ),
            ),
          const SizedBox(height: 16),
          const CheckInRowLabel(Copy.personalReflection),
          CheckInSelect<EntryStatus>(
            dropdownKey: const Key('personal-reflection-status'),
            value: _draft.personalReflectionStatus,
            entries: const [
              CheckInSelectEntry(
                value: EntryStatus.recorded,
                label: 'Wrote an entry',
              ),
              CheckInSelectEntry(
                value: EntryStatus.noneToday,
                label: 'No entry today',
              ),
              CheckInSelectEntry(
                value: EntryStatus.unanswered,
                label: 'Not recorded',
              ),
            ],
            onChanged: (status) => setState(() {
              if (status == EntryStatus.recorded) {
                _draft = _draft.copyWith(
                  personalReflectionStatus: EntryStatus.recorded,
                );
              } else if (status == EntryStatus.noneToday) {
                _draft = _draft.copyWith(
                  personalReflectionStatus: EntryStatus.noneToday,
                  clearPersonalReflectionText: true,
                );
                _reflection.clear();
              } else {
                _draft = _draft.copyWith(
                  personalReflectionStatus: EntryStatus.unanswered,
                );
              }
            }),
          ),
          if (_draft.personalReflectionStatus == EntryStatus.recorded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: checkInValueIndent),
              child: TextField(
                controller: _reflection,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Optional private reflection',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _widgetForDomain(
    MonitorDomain domain, {
    required bool expandFirst,
    required Set<String> mixKeys,
  }) {
    return switch (domain) {
      MonitorDomain.salah => _salahCard(
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.quran => _quranCard(
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.hadith => _homeTraceDomainCard(
        title: MonitorDomain.hadith.label,
        focus: MonitorDomain.hadith.focusQuestion,
        rows: hadithHomeRows,
        washLight: MuhasabahColors.hadithWash,
        washDark: MuhasabahColors.hadithWashDark,
        extraNote: Copy.hadithObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.dhikr => _homeTraceDomainCard(
        title: MonitorDomain.dhikr.label,
        focus: MonitorDomain.dhikr.focusQuestion,
        rows: dhikrHomeRows,
        washLight: MuhasabahColors.dhikrWash,
        washDark: MuhasabahColors.dhikrWashDark,
        extraNote: Copy.dhikrPostFardNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.akhlaq => _homeTraceDomainCard(
        title: MonitorDomain.akhlaq.label,
        focus: MonitorDomain.akhlaq.focusQuestion,
        rows: akhlaqHomeRows,
        washLight: MuhasabahColors.akhlaqWash,
        washDark: MuhasabahColors.akhlaqWashDark,
        extraNote: Copy.akhlaqObservationNote,
        includeStruggleNote: true,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.huquq => _homeTraceDomainCard(
        title: MonitorDomain.huquq.label,
        focus: MonitorDomain.huquq.focusQuestion,
        rows: huquqHomeRows,
        washLight: MuhasabahColors.huquqWash,
        washDark: MuhasabahColors.huquqWashDark,
        extraNote: Copy.huquqObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.knowledge => _homeTraceDomainCard(
        title: MonitorDomain.knowledge.label,
        focus: MonitorDomain.knowledge.focusQuestion,
        rows: knowledgeHomeRows,
        washLight: MuhasabahColors.knowledgeWash,
        washDark: MuhasabahColors.knowledgeWashDark,
        extraNote: Copy.knowledgeObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.time => _homeTraceDomainCard(
        title: MonitorDomain.time.label,
        focus: MonitorDomain.time.focusQuestion,
        rows: timeHomeRows,
        washLight: MuhasabahColors.timeWash,
        washDark: MuhasabahColors.timeWashDark,
        extraNote: Copy.timeObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.health => _homeTraceDomainCard(
        title: MonitorDomain.health.label,
        focus: MonitorDomain.health.focusQuestion,
        rows: healthHomeRows,
        washLight: MuhasabahColors.healthWash,
        washDark: MuhasabahColors.healthWashDark,
        extraNote: Copy.healthObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.wealth => _homeTraceDomainCard(
        title: MonitorDomain.wealth.label,
        focus: MonitorDomain.wealth.focusQuestion,
        rows: wealthHomeRows,
        washLight: MuhasabahColors.wealthWash,
        washDark: MuhasabahColors.wealthWashDark,
        extraNote: Copy.wealthObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.ummah => _homeTraceDomainCard(
        title: MonitorDomain.ummah.label,
        focus: MonitorDomain.ummah.focusQuestion,
        rows: ummahHomeRows,
        washLight: MuhasabahColors.ummahWash,
        washDark: MuhasabahColors.ummahWashDark,
        extraNote: Copy.ummahObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.fasting => _homeTraceDomainCard(
        title: MonitorDomain.fasting.label,
        focus: MonitorDomain.fasting.focusQuestion,
        rows: gatedFastingHomeRows(
          fastingHomeRows,
          date: parseDateKey(_openedDateKey),
          offsetDays: ref.watch(appPrefsProvider).ramadanCalendarOffsetDays,
          showHistory: ref.watch(appPrefsProvider).showFastingRamadanHistory,
          records: [_draft],
        ),
        washLight: MuhasabahColors.fastingWash,
        washDark: MuhasabahColors.fastingWashDark,
        extraNote: Copy.fastingObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.hajj => _homeTraceDomainCard(
        title: MonitorDomain.hajj.label,
        focus: MonitorDomain.hajj.focusQuestion,
        rows: hajjHomeRows,
        washLight: MuhasabahColors.hajjWash,
        washDark: MuhasabahColors.hajjWashDark,
        extraNote: Copy.hajjObservationNote,
        includeHajjStatus: true,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.productivity => _homeTraceDomainCard(
        title: MonitorDomain.productivity.label,
        focus: MonitorDomain.productivity.focusQuestion,
        rows: productivityHomeRows,
        washLight: MuhasabahColors.productivityWash,
        washDark: MuhasabahColors.productivityWashDark,
        extraNote: Copy.productivityObservationNote,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.charity => _homeTraceDomainCard(
        title: 'Charity',
        rows: charityHomeRows,
        washLight: MuhasabahColors.charityWash,
        washDark: MuhasabahColors.charityWashDark,
        extraNote: Copy.charityObservationNote,
        includeZakat: mixKeys.isEmpty || mixIncludesZakat(mixKeys),
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
    };
  }

  Widget _collapsibleTraceBand({
    required String title,
    required String band,
    required Color family,
    required bool initiallyExpanded,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: Key('checkin-band-$title-$band'),
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: HomeBandHeading(
          band: band,
          family: family,
          baseWash: Theme.of(context).colorScheme.surface,
        ),
        onExpansionChanged: (open) {
          if (open) _collapseBriefing();
        },
        children: children,
      ),
    );
  }

  Widget _homeTraceDomainCard({
    required String title,
    required List<HomeTraceRow> rows,
    required Color washLight,
    required Color washDark,
    String? focus,
    String? extraNote,
    bool includeZakat = false,
    bool includeHadithFocus = false,
    bool includeHajjStatus = false,
    bool includeStruggleNote = false,
    bool expandFirst = true,
    Set<String> mixKeys = const {},
  }) {
    final visibleRows = rows;
    final mixVisible = [
      for (final row in visibleRows)
        if (mixKeys.isEmpty || mixKeys.contains(row.storageKey)) row,
    ];
    final bands = bandsFor(mixVisible);
    return WashPanel(
      color: MuhasabahColors.wash(
        washLight,
        washDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInDomainTitle(title, focus: focus),
          const SizedBox(height: 4),
          if (briefingForLabel(title) != null)
            CollapsingDomainBriefingNote(
              briefingForLabel(title)!,
              expanded: _briefingOpen,
              onExpansionChanged: (open) {
                if (open == _briefingOpen) return;
                setState(() => _briefingOpen = open);
              },
            )
          else
            Text(
              extraNote ??
                  'Same rows as Home. Independent. Missing is not missed.',
            ),
          if (title == MonitorDomain.akhlaq.label) ...[
            const SizedBox(height: 8),
            Text(
              Copy.akhlaqCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (title == MonitorDomain.huquq.label) ...[
            const SizedBox(height: 8),
            Text(
              Copy.huquqCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          if (includeHajjStatus) const HajjStandingEditor(bottomPadding: 12),
          for (var i = 0; i < bands.length; i++)
            _collapsibleTraceBand(
              title: title,
              band: bands[i],
              family: domainColorIdentity(
                MonitorDomain.values
                        .where((domain) => domain.label == title)
                        .firstOrNull ??
                    MonitorDomain.dhikr,
              ).family,
              initiallyExpanded: _sectionStartsOpen(
                bands[i],
                firstBand: bands.first,
                expandFirst: expandFirst,
              ),
              children: [
                if (title == MonitorDomain.time.label &&
                    timeSectionQuestion(bands[i]) != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      timeSectionQuestion(bands[i])!,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic, height: 1.35),
                    ),
                  ),
                for (final row in mixVisible)
                  if (row.band == bands[i]) _traceEditor(row),
              ],
            ),
          if (includeZakat) _zakatEditor(),
          if (includeHadithFocus) _hadithFocusEditor(),
          if (includeStruggleNote) _akhlaqStruggleEditor(),
        ],
      ),
    );
  }

  Widget _situationNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Copy.situationNotesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              Copy.situationNotesNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in SituationNoteCatalog.options)
                  if (option.id != 'custom')
                    FilterChip(
                      label: Text(option.label),
                      selected: _draft.situationNotes.ids.contains(option.id),
                      onSelected: (selected) {
                        final ids = [..._draft.situationNotes.ids];
                        if (selected) {
                          if (!ids.contains(option.id)) ids.add(option.id);
                        } else {
                          ids.remove(option.id);
                        }
                        setState(() {
                          _draft = _draft.copyWith(
                            situationNotes: SituationNotes(
                              ids: ids,
                              customText: _situationCustom.text.trim().isEmpty
                                  ? null
                                  : _situationCustom.text.trim(),
                            ),
                          );
                        });
                      },
                    ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('checkin-situation-custom'),
              controller: _situationCustom,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Custom note (optional)',
              ),
              onChanged: (value) {
                setState(() {
                  _draft = _draft.copyWith(
                    situationNotes: SituationNotes(
                      ids: _draft.situationNotes.ids,
                      customText: value.trim().isEmpty ? null : value.trim(),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || !_loaded) return;
    final next = _pendingRecord();
    if (next.dateKey != _openedDateKey) {
      setState(() {
        _error = 'The check-in could not be saved. Your draft is still here.';
      });
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(checkInsProvider.notifier).save(next);
      logAppEvent('checkin_saved');
      if (!mounted) return;
      _allowPop = true;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'The check-in could not be saved. Your draft is still here.';
      });
    }
  }

  DailyCheckIn _pendingRecord() {
    var next = _draft;
    if (next.gratitudeStatus == EntryStatus.recorded) {
      next = next.copyWith(
        gratitudeText: _gratitude.text.trim().isEmpty ? null : _gratitude.text,
      );
    }
    if (next.personalReflectionStatus == EntryStatus.recorded) {
      next = next.copyWith(
        personalReflectionText: _reflection.text.trim().isEmpty
            ? null
            : _reflection.text,
      );
    }
    return next.copyWith(
      situationNotes: SituationNotes(
        ids: next.situationNotes.ids,
        customText: _situationCustom.text.trim().isEmpty
            ? null
            : _situationCustom.text.trim(),
      ),
      akhlaqStruggleNote: _akhlaqStruggle.text.trim().isEmpty
          ? null
          : _akhlaqStruggle.text.trim(),
      clearAkhlaqStruggleNote: _akhlaqStruggle.text.trim().isEmpty,
    );
  }

  bool get _isDirty {
    final pending = _pendingRecord();
    if (!_loaded) {
      return !sameCheckInContent(pending, DailyCheckIn.empty(_openedDateKey));
    }
    final original = _original ?? DailyCheckIn.empty(_openedDateKey);
    return !sameCheckInContent(pending, original);
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    if (_saving || _confirmOpen) return;
    if (!_isDirty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _confirmOpen = true);
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final date = formatStoredDateKey(_openedDateKey, calendar);
    final action = await showDialog<_UnsavedCheckInAction>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          key: const Key('unsaved-check-in-dialog'),
          title: const Text(Copy.unsavedCheckInTitle),
          content: Text(Copy.unsavedCheckInBody(date)),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _UnsavedCheckInAction.discard),
              child: const Text(Copy.unsavedCheckInDiscard),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _UnsavedCheckInAction.continueEditing),
              child: const Text(Copy.unsavedCheckInContinue),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _UnsavedCheckInAction.save),
              child: const Text(Copy.unsavedCheckInSave),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    setState(() => _confirmOpen = false);
    switch (action) {
      case _UnsavedCheckInAction.save:
        await _save();
      case _UnsavedCheckInAction.discard:
        _allowPop = true;
        Navigator.of(context).pop();
      case _UnsavedCheckInAction.continueEditing:
      case null:
        break;
    }
  }
}

enum _UnsavedCheckInAction { save, continueEditing, discard }
