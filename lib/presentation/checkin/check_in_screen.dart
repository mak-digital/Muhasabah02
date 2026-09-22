import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../data/privacy_log.dart';
import '../../domain/activities.dart';
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
import '../../domain/personalisation_resolver.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/recorded_context.dart';
import '../../domain/salah_extras.dart';
import '../../domain/salah_factors.dart';
import '../../domain/situation_notes.dart';
import '../shared/activity_picker.dart';
import '../shared/domain_briefing_note.dart';
import '../shared/domain_stage.dart';
import '../shared/ui_bits.dart';

enum CheckInFocus { full, salah, quran, traces }

void openFocusedCheckIn(
  BuildContext context, {
  required String dateKey,
  required CheckInFocus focus,
  String? domainTitle,
  String? domainFocus,
  String? focusBand,
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
  final Map<String, TextEditingController> _contextNotes = {};
  final Map<String, TextEditingController> _custom = {};
  var _loaded = false;
  var _editing = true;
  var _saving = false;
  var _confirmOpen = false;
  var _allowPop = false;
  String? _error;
  late final String _openedDateKey;
  DailyCheckIn? _original;

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
    Future<void>.microtask(_hydrate);
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
  }

  @override
  void dispose() {
    _gratitude.dispose();
    _reflection.dispose();
    _situationCustom.dispose();
    _akhlaqStruggle.dispose();
    for (final c in _contextNotes.values) {
      c.dispose();
    }
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
                primary: true,
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
      domains: resolver.reviewDomains,
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
        if (resolver.isDomainVisible(MonitorDomain.quran)) ...[
          const SizedBox(height: 12),
          _contextCard(),
        ],
        const SizedBox(height: 12),
        _situationNotesCard(),
      ],
    );
  }

  List<Widget> _focusBody() {
    switch (widget.focus) {
      case CheckInFocus.salah:
        return [_salahCard()];
      case CheckInFocus.quran:
        return [_quranCard(), const SizedBox(height: 12), _contextCard()];
      case CheckInFocus.traces:
        return _tracesBody();
      case CheckInFocus.full:
        return const [];
    }
  }

  bool _sectionStartsOpen(
    String band, {
    required String firstBand,
    required bool expandFirst,
  }) {
    if (widget.focus == CheckInFocus.full) {
      return expandFirst && band == firstBand;
    }
    final focus = widget.focusBand;
    if (focus == null || focus.isEmpty) return band == firstBand;
    return band == focus;
  }

  Widget _salahCard({bool expandFirst = true}) {
    final title = MonitorDomain.salah.label;
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
          _collapsibleTraceBand(
            title: title,
            band: kSalahObligatoryBand,
            initiallyExpanded: _sectionStartsOpen(
              kSalahObligatoryBand,
              firstBand: kSalahObligatoryBand,
              expandFirst: expandFirst,
            ),
            children: [for (final id in PrayerId.values) _prayerRow(id)],
          ),
          _collapsibleTraceBand(
            title: title,
            band: kSalahFridayBand,
            initiallyExpanded: _sectionStartsOpen(
              kSalahFridayBand,
              firstBand: kSalahObligatoryBand,
              expandFirst: expandFirst,
            ),
            children: [
              const Text(
                'These stay off the recordable-field count. Unanswered is not missed.',
              ),
              const SizedBox(height: 8),
              if (parseDateKey(_key).weekday == DateTime.friday) ...[
                const CheckInRowLabel('Friday congregation'),
                CheckInSelect<bool>(
                  dropdownKey: const Key('salah-jumuah-congregation'),
                  value: _draft.jumuahCongregation,
                  entries: const [
                    CheckInSelectEntry(value: true, label: 'Attended'),
                    CheckInSelectEntry(value: false, label: 'Not marked'),
                  ],
                  onChanged: (selected) => setState(() {
                    _draft = _draft.copyWith(jumuahCongregation: selected);
                  }),
                ),
                const SizedBox(height: 8),
              ],
              _extraPrayerStatus(
                label: 'Jumu‘ah',
                enabled: parseDateKey(_key).weekday == DateTime.friday,
                status: _draft.jumuah,
                onChanged: (status) => setState(() {
                  _draft = _draft.copyWith(jumuah: status);
                }),
              ),
            ],
          ),
          _collapsibleTraceBand(
            title: title,
            band: kSalahVoluntaryBand,
            initiallyExpanded: _sectionStartsOpen(
              kSalahVoluntaryBand,
              firstBand: kSalahObligatoryBand,
              expandFirst: expandFirst,
            ),
            children: [
              const Text(
                'These stay off the recordable-field count. Unanswered is not missed.',
              ),
              const SizedBox(height: 8),
              _voluntaryRow(
                label: 'Tahajjud',
                outcome: _draft.tahajjud,
                onChanged: (outcome) => setState(() {
                  _draft = _draft.copyWith(tahajjud: outcome);
                }),
              ),
              _voluntaryRow(
                label: 'Ishraq',
                outcome: _draft.ishraq,
                onChanged: (outcome) => setState(() {
                  _draft = _draft.copyWith(ishraq: outcome);
                }),
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

  Widget _extraPrayerStatus({
    required String label,
    required bool enabled,
    required PrayerStatus status,
    required ValueChanged<PrayerStatus> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(label),
          if (!enabled)
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'Friday only. Other days stay blank, not unanswered.',
              ),
            ),
          CheckInSelect<PrayerStatus>(
            value: status,
            enabled: enabled,
            entries: [
              for (final option in PrayerStatus.values)
                CheckInSelectEntry(value: option, label: option.label),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _voluntaryRow({
    required String label,
    required TernaryOutcome outcome,
    required ValueChanged<TernaryOutcome> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckInRowLabel(label),
          CheckInSelect<TernaryOutcome>(
            value: outcome,
            entries: const [
              CheckInSelectEntry(
                value: TernaryOutcome.positive,
                label: 'Performed',
              ),
              CheckInSelectEntry(
                value: TernaryOutcome.negative,
                label: 'Not performed',
              ),
              CheckInSelectEntry(
                value: TernaryOutcome.unanswered,
                label: 'Not recorded',
              ),
            ],
            onChanged: onChanged,
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

  Widget _quranCard({bool expandFirst = true}) {
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
          const SizedBox(height: 4),
          const Text(Copy.quranCheckInIntro),
          const SizedBox(height: 12),
          _collapsibleTraceBand(
            title: title,
            band: kQuranEngagementBand,
            initiallyExpanded: _sectionStartsOpen(
              kQuranEngagementBand,
              firstBand: kQuranEngagementBand,
              expandFirst: expandFirst,
            ),
            children: [
              for (final dimension in engagementHomeRows)
                _quranBlock(dimension),
            ],
          ),
          _collapsibleTraceBand(
            title: title,
            band: kQuranUnderstandingBand,
            initiallyExpanded: _sectionStartsOpen(
              kQuranUnderstandingBand,
              firstBand: kQuranEngagementBand,
              expandFirst: expandFirst,
            ),
            children: [
              for (final dimension in understandingHomeRows)
                _quranBlock(dimension),
            ],
          ),
          _collapsibleTraceBand(
            title: title,
            band: kQuranReflectionBand,
            initiallyExpanded: _sectionStartsOpen(
              kQuranReflectionBand,
              firstBand: kQuranEngagementBand,
              expandFirst: expandFirst,
            ),
            children: [
              for (final dimension in reflectionHomeRows)
                _quranBlock(dimension),
            ],
          ),
          _collapsibleTraceBand(
            title: title,
            band: kQuranApplicationBand,
            initiallyExpanded: _sectionStartsOpen(
              kQuranApplicationBand,
              firstBand: kQuranEngagementBand,
              expandFirst: expandFirst,
            ),
            children: [
              for (final dimension in applicationHomeRows)
                _quranBlock(dimension),
            ],
          ),
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
          if (dimension == QuranDimension.meaning)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                Copy.meaningFillsRecitation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (dimension == QuranDimension.reading &&
              readingLockedByMeaning(_draft.quran))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                Copy.recitationLockedByMeaning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          ActivityPicker(
            options: ActivityCatalog.forQuran(dimension),
            selectedId: selected.id,
            statusKeyPrefix: 'quran-${dimension.name}',
            enabled:
                dimension != QuranDimension.reading ||
                !readingLockedByMeaning(_draft.quran),
            onSelected: (option) => setState(() {
              final outcome = option.ternary ?? TernaryOutcome.unanswered;
              if (!canSetQuranOutcome(
                quran: _draft.quran,
                dimension: dimension,
                outcome: outcome,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(Copy.recitationLockedByMeaning)),
                );
                return;
              }
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
        ],
      ),
    );
  }

  TextEditingController _note(String key, [String? seed]) {
    return _custom.putIfAbsent(
      key,
      () => TextEditingController(text: seed ?? ''),
    );
  }

  bool _traceBandStartsOpen(String band) {
    final focus = widget.focusBand;
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

  List<Widget> _tracesBody() {
    final accent = widget.familyColor ?? MuhasabahColors.dhikr;
    final hajjStatus = ref.watch(appPrefsProvider).hajjStatus;
    final rows = widget.includeHajjStatus
        ? hajjRowsForStatus(widget.traceRows, hajjStatus)
        : widget.traceRows;
    final bands = bandsFor(rows);
    return [
      CheckInDomainTitle(
        widget.domainTitle ?? 'Record',
        focus: widget.domainFocus,
      ),
      const SizedBox(height: 4),
      if (_focusedBriefing() != null)
        DomainBriefingNote(_focusedBriefing()!)
      else
        const Text(
          'Only this domain is shown. Other records for the day stay unchanged.',
        ),
      const SizedBox(height: 12),
      if (widget.includeHajjStatus) _hajjStatusEditor(),
      for (var i = 0; i < bands.length; i++)
        _collapsibleTraceBand(
          title: widget.domainTitle ?? 'Record',
          band: bands[i],
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
                    child: _traceEditor(row),
                  ),
                ),
          ],
        ),
      if (widget.includeZakat)
        _collapsibleTraceBand(
          title: widget.domainTitle ?? 'Record',
          band: kZakatTraceBand,
          initiallyExpanded: widget.focusBand == kZakatTraceBand,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WashPanel(
                color: Color.alphaBlend(
                  accent.withValues(alpha: 0.16),
                  Theme.of(context).colorScheme.surface,
                ),
                child: _zakatEditor(),
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
                final groups = factorGroupsForTernary(option);
                next = next.withHomeTraceFactors(
                  row.storageKey,
                  SalahFactorCapture(
                    supportIds: groups.showHelping
                        ? factors.supportIds.take(1).toList()
                        : const [],
                    challengeIds: groups.showDistracting
                        ? factors.challengeIds.take(1).toList()
                        : const [],
                    otherText: factors.otherText,
                  ),
                );
              }
              _draft = next;
            }),
          ),
          if (includeFactors && !hidesHomeTraceFactors(row.storageKey))
            CheckInFactorSelects(
              groups: factorGroupsForTernary(outcome),
              helping: NamedFactor.helpingForHomeTrace(
                row.storageKey,
                existingIds: factors.supportIds,
              ),
              distracting: NamedFactor.distractingForHomeTrace(
                row.storageKey,
                existingIds: factors.challengeIds,
              ),
              helpingId: selectedFactorId(factors.supportIds),
              distractingId: selectedFactorId(factors.challengeIds),
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
            entries: [
              for (final status in ZakatStatus.values)
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

  Widget _hajjStatusEditor() {
    final prefs = ref.watch(appPrefsProvider);
    final current = prefs.hajjStatus;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckInRowLabel(Copy.hajjStatusLabel),
          CheckInSelect<HajjStatus>(
            dropdownKey: const Key('hajj-status'),
            value: current,
            entries: [
              for (final option in HajjStatus.values)
                CheckInSelectEntry(value: option, label: option.label),
            ],
            onChanged: (option) async {
              await prefs.setHajjStatus(option);
              ref.read(prefsTickProvider.notifier).state++;
              setState(() {});
            },
          ),
          const SizedBox(height: 6),
          Text(
            Copy.hajjStatusNote,
            style: Theme.of(context).textTheme.bodySmall,
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
      MonitorDomain.salah => _salahCard(expandFirst: expandFirst),
      MonitorDomain.quran => _quranCard(expandFirst: expandFirst),
      MonitorDomain.hadith => _homeTraceDomainCard(
        title: MonitorDomain.hadith.label,
        focus: MonitorDomain.hadith.focusQuestion,
        rows: hadithHomeRows,
        washLight: MuhasabahColors.hadithWash,
        washDark: MuhasabahColors.hadithWashDark,
        extraNote: Copy.hadithObservationNote,
        includeHadithFocus: true,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
      MonitorDomain.dhikr => _homeTraceDomainCard(
        title: MonitorDomain.dhikr.label,
        focus: MonitorDomain.dhikr.focusQuestion,
        rows: dhikrHomeRows,
        washLight: MuhasabahColors.dhikrWash,
        washDark: MuhasabahColors.dhikrWashDark,
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
        title: 'Fasting',
        rows: fastingHomeRows,
        washLight: MuhasabahColors.fastingWash,
        washDark: MuhasabahColors.fastingWashDark,
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
      MonitorDomain.charity => _homeTraceDomainCard(
        title: 'Charity',
        rows: charityHomeRows,
        washLight: MuhasabahColors.charityWash,
        washDark: MuhasabahColors.charityWashDark,
        includeZakat: true,
        expandFirst: expandFirst,
        mixKeys: mixKeys,
      ),
    };
  }

  Widget _collapsibleTraceBand({
    required String title,
    required String band,
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
        title: Text(
          band.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w600),
        ),
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
    final status = ref.watch(appPrefsProvider).hajjStatus;
    final visibleRows = includeHajjStatus
        ? hajjRowsForStatus(rows, status)
        : rows;
    final natural = bandsFor(visibleRows);
    final mixBands = [
      for (final band in natural)
        if (visibleRows.any(
          (row) => row.band == band && mixKeys.contains(row.storageKey),
        ))
          band,
    ];
    final rest = [
      for (final band in natural)
        if (!mixBands.contains(band)) band,
    ];
    final bands = mixBands.isEmpty ? natural : [...mixBands, ...rest];
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
            DomainBriefingNote(briefingForLabel(title)!)
          else
            Text(
              extraNote ??
                  'Same rows as Home. Independent. Missing is not missed.',
            ),
          const SizedBox(height: 12),
          if (includeHajjStatus) _hajjStatusEditor(),
          for (var i = 0; i < bands.length; i++)
            _collapsibleTraceBand(
              title: title,
              band: bands[i],
              initiallyExpanded: expandFirst && i == 0,
              children: [
                for (final row in visibleRows)
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

  Widget _contextCard() {
    final blocks = <Widget>[];
    for (final dimension in quranDailyDimensions) {
      final outcome = _draft.quranOutcome(dimension);
      if (!contextAllowed(dimension, outcome)) continue;
      final polarity = outcome == TernaryOutcome.positive
          ? 'positive'
          : 'negative';
      final existing = _draft.contextFor(dimension, polarity);
      final prompt = dimension.contextPrompt(outcome);
      final noteKey = '${dimension.name}:$polarity';
      _contextNotes.putIfAbsent(
        noteKey,
        () => TextEditingController(text: existing?.freeText ?? ''),
      );
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dimension.label} · ${Copy.factorsYouNoticed}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(prompt),
              const SizedBox(height: 4),
              Text(
                '${Copy.youRecorded} ${outcome == TernaryOutcome.positive ? dimension.positiveLabel.toLowerCase() : dimension.negativeLabel.toLowerCase()}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              CheckInFactorSelects(
                groups: factorGroupsForTernary(outcome),
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
                onHelpingChanged: (id) => setState(() {
                  _draft = _draft.withContext(
                    RecordedContext(
                      subject: dimension,
                      polarity: polarity,
                      factorIds: idsFromFactorChoice(id),
                      freeText: _contextNotes[noteKey]?.text,
                    ),
                  );
                }),
                onDistractingChanged: (id) => setState(() {
                  _draft = _draft.withContext(
                    RecordedContext(
                      subject: dimension,
                      polarity: polarity,
                      factorIds: idsFromFactorChoice(id),
                      freeText: _contextNotes[noteKey]?.text,
                    ),
                  );
                }),
              ),
              TextField(
                controller: _contextNotes[noteKey],
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Optional note (stays private to this day)',
                ),
                onChanged: (value) {
                  _draft = _draft.withContext(
                    RecordedContext(
                      subject: dimension,
                      polarity: polarity,
                      factorIds: existing?.factorIds ?? const [],
                      freeText: value,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Copy.factorsYouNoticed,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Recorded factors. Things you noticed — not causes. Skipping changes nothing.',
            ),
            const SizedBox(height: 12),
            ...blocks,
          ],
        ),
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
              controller: _situationCustom,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Custom note (optional)',
              ),
              onChanged: (value) {
                _draft = _draft.copyWith(
                  situationNotes: SituationNotes(
                    ids: _draft.situationNotes.ids,
                    customText: value.trim().isEmpty ? null : value.trim(),
                  ),
                );
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
