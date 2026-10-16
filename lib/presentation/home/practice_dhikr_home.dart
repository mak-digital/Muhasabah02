import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/home_traces.dart';
import '../../domain/date_key.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/practice_akhlaq_catalog.dart';
import '../../domain/practice_dhikr_catalog.dart';
import '../../domain/practice_salah_catalog.dart';
import '../../domain/practice_huquq_catalog.dart';
import '../../domain/practice_health_catalog.dart';
import '../../domain/practice_knowledge_catalog.dart';
import '../../domain/practice_time_catalog.dart';
import '../../domain/practice_charity_catalog.dart';
import '../../domain/practice_fasting_catalog.dart';
import '../../domain/practice_hajj_catalog.dart';
import '../../domain/practice_ummah_catalog.dart';
import '../../domain/practice_wealth_catalog.dart';
import '../../domain/practice_hadith.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/practice_learn_focus.dart';
import '../shared/domain_visual.dart';
import '../shared/home_band_heading.dart';
import '../shared/ui_bits.dart';
import 'practice_hadith_home.dart';

class PracticeLearnSpec {
  const PracticeLearnSpec({
    required this.domain,
    required this.keyPrefix,
    required this.title,
    required this.note,
    required this.addLabel,
    required this.openRegister,
    required this.registerTitle,
    required this.registerNote,
    required this.registerEmpty,
    required this.confirmDelete,
    required this.groups,
    required this.catalog,
    required this.recordFrom,
  });

  final MonitorDomain domain;
  final String keyPrefix;
  final String title;
  final String note;
  final String addLabel;
  final String openRegister;
  final String registerTitle;
  final String registerNote;
  final String registerEmpty;
  final String confirmDelete;
  final List<String> groups;
  final List<PracticeDhikrItem> catalog;
  final PracticeHadithRecord Function({
    required PracticeDhikrItem item,
    required String id,
    required String addedDateKey,
  })
  recordFrom;

  List<PracticeDhikrItem> itemsInGroup(String group) {
    return [
      for (final item in catalog)
        if (item.group == group) item,
    ];
  }

  PracticeLearnSpec focused(PersonalisationResolver resolver) {
    final nextCatalog = focusedPracticeCatalog(
      domain: domain,
      catalog: catalog,
      resolver: resolver,
    );
    return PracticeLearnSpec(
      domain: domain,
      keyPrefix: keyPrefix,
      title: title,
      note: note,
      addLabel: addLabel,
      openRegister: openRegister,
      registerTitle: registerTitle,
      registerNote: registerNote,
      registerEmpty: registerEmpty,
      confirmDelete: confirmDelete,
      groups: focusedPracticeGroups(groups: groups, catalog: nextCatalog),
      catalog: nextCatalog,
      recordFrom: recordFrom,
    );
  }
}

PracticeLearnSpec salahLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.salah,
    keyPrefix: 'salah',
    title: Copy.practiceSalahTitle,
    note: Copy.practiceSalahNote,
    addLabel: Copy.addPracticeSalah,
    openRegister: Copy.openPracticeSalahRegister,
    registerTitle: Copy.practiceSalahRegisterTitle,
    registerNote: Copy.practiceSalahRegisterNote,
    registerEmpty: Copy.practiceSalahRegisterEmpty,
    confirmDelete: Copy.practiceSalahConfirmDelete,
    groups: kPracticeSalahGroups,
    catalog: kPracticeSalahCatalog,
    recordFrom: recordFromSalahCatalog,
  );
}

class PracticeSalahWash extends StatelessWidget {
  const PracticeSalahWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: salahLearnSpec());
  }
}

PracticeLearnSpec dhikrLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.dhikr,
    keyPrefix: 'dhikr',
    title: Copy.practiceDhikrTitle,
    note: Copy.practiceDhikrNote,
    addLabel: Copy.addPracticeDhikr,
    openRegister: Copy.openPracticeDhikrRegister,
    registerTitle: Copy.practiceDhikrRegisterTitle,
    registerNote: Copy.practiceDhikrRegisterNote,
    registerEmpty: Copy.practiceDhikrRegisterEmpty,
    confirmDelete: Copy.practiceDhikrConfirmDelete,
    groups: kPracticeDhikrGroups,
    catalog: kPracticeDhikrCatalog,
    recordFrom: recordFromDhikrCatalog,
  );
}

class PracticeDhikrWash extends StatelessWidget {
  const PracticeDhikrWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: dhikrLearnSpec());
  }
}

PracticeLearnSpec akhlaqLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.akhlaq,
    keyPrefix: 'akhlaq',
    title: Copy.practiceAkhlaqTitle,
    note: Copy.practiceAkhlaqNote,
    addLabel: Copy.addPracticeAkhlaq,
    openRegister: Copy.openPracticeAkhlaqRegister,
    registerTitle: Copy.practiceAkhlaqRegisterTitle,
    registerNote: Copy.practiceAkhlaqRegisterNote,
    registerEmpty: Copy.practiceAkhlaqRegisterEmpty,
    confirmDelete: Copy.practiceAkhlaqConfirmDelete,
    groups: kPracticeAkhlaqGroups,
    catalog: kPracticeAkhlaqCatalog,
    recordFrom: recordFromAkhlaqCatalog,
  );
}

class PracticeAkhlaqWash extends StatelessWidget {
  const PracticeAkhlaqWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: akhlaqLearnSpec());
  }
}

PracticeLearnSpec huquqLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.huquq,
    keyPrefix: 'huquq',
    title: Copy.practiceHuquqTitle,
    note: Copy.practiceHuquqNote,
    addLabel: Copy.addPracticeHuquq,
    openRegister: Copy.openPracticeHuquqRegister,
    registerTitle: Copy.practiceHuquqRegisterTitle,
    registerNote: Copy.practiceHuquqRegisterNote,
    registerEmpty: Copy.practiceHuquqRegisterEmpty,
    confirmDelete: Copy.practiceHuquqConfirmDelete,
    groups: kPracticeHuquqGroups,
    catalog: kPracticeHuquqCatalog,
    recordFrom: recordFromHuquqCatalog,
  );
}

class PracticeHuquqWash extends StatelessWidget {
  const PracticeHuquqWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: huquqLearnSpec());
  }
}

PracticeLearnSpec knowledgeLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.knowledge,
    keyPrefix: 'knowledge',
    title: Copy.practiceKnowledgeTitle,
    note: Copy.practiceKnowledgeNote,
    addLabel: Copy.addPracticeKnowledge,
    openRegister: Copy.openPracticeKnowledgeRegister,
    registerTitle: Copy.practiceKnowledgeRegisterTitle,
    registerNote: Copy.practiceKnowledgeRegisterNote,
    registerEmpty: Copy.practiceKnowledgeRegisterEmpty,
    confirmDelete: Copy.practiceKnowledgeConfirmDelete,
    groups: kPracticeKnowledgeGroups,
    catalog: kPracticeKnowledgeCatalog,
    recordFrom: recordFromKnowledgeCatalog,
  );
}

class PracticeKnowledgeWash extends StatelessWidget {
  const PracticeKnowledgeWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: knowledgeLearnSpec());
  }
}

PracticeLearnSpec timeLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.time,
    keyPrefix: 'time',
    title: Copy.practiceTimeTitle,
    note: Copy.practiceTimeNote,
    addLabel: Copy.addPracticeTime,
    openRegister: Copy.openPracticeTimeRegister,
    registerTitle: Copy.practiceTimeRegisterTitle,
    registerNote: Copy.practiceTimeRegisterNote,
    registerEmpty: Copy.practiceTimeRegisterEmpty,
    confirmDelete: Copy.practiceTimeConfirmDelete,
    groups: kPracticeTimeGroups,
    catalog: kPracticeTimeCatalog,
    recordFrom: recordFromTimeCatalog,
  );
}

class PracticeTimeWash extends StatelessWidget {
  const PracticeTimeWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: timeLearnSpec());
  }
}

PracticeLearnSpec healthLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.health,
    keyPrefix: 'health',
    title: Copy.practiceHealthTitle,
    note: Copy.practiceHealthNote,
    addLabel: Copy.addPracticeHealth,
    openRegister: Copy.openPracticeHealthRegister,
    registerTitle: Copy.practiceHealthRegisterTitle,
    registerNote: Copy.practiceHealthRegisterNote,
    registerEmpty: Copy.practiceHealthRegisterEmpty,
    confirmDelete: Copy.practiceHealthConfirmDelete,
    groups: kPracticeHealthGroups,
    catalog: kPracticeHealthCatalog,
    recordFrom: recordFromHealthCatalog,
  );
}

class PracticeHealthWash extends StatelessWidget {
  const PracticeHealthWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: healthLearnSpec());
  }
}

PracticeLearnSpec wealthLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.wealth,
    keyPrefix: 'wealth',
    title: Copy.practiceWealthTitle,
    note: Copy.practiceWealthNote,
    addLabel: Copy.addPracticeWealth,
    openRegister: Copy.openPracticeWealthRegister,
    registerTitle: Copy.practiceWealthRegisterTitle,
    registerNote: Copy.practiceWealthRegisterNote,
    registerEmpty: Copy.practiceWealthRegisterEmpty,
    confirmDelete: Copy.practiceWealthConfirmDelete,
    groups: kPracticeWealthGroups,
    catalog: kPracticeWealthCatalog,
    recordFrom: recordFromWealthCatalog,
  );
}

class PracticeWealthWash extends StatelessWidget {
  const PracticeWealthWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: wealthLearnSpec());
  }
}

PracticeLearnSpec ummahLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.ummah,
    keyPrefix: 'ummah',
    title: Copy.practiceUmmahTitle,
    note: Copy.practiceUmmahNote,
    addLabel: Copy.addPracticeUmmah,
    openRegister: Copy.openPracticeUmmahRegister,
    registerTitle: Copy.practiceUmmahRegisterTitle,
    registerNote: Copy.practiceUmmahRegisterNote,
    registerEmpty: Copy.practiceUmmahRegisterEmpty,
    confirmDelete: Copy.practiceUmmahConfirmDelete,
    groups: kPracticeUmmahGroups,
    catalog: kPracticeUmmahCatalog,
    recordFrom: recordFromUmmahCatalog,
  );
}

class PracticeUmmahWash extends StatelessWidget {
  const PracticeUmmahWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: ummahLearnSpec());
  }
}

PracticeLearnSpec fastingLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.fasting,
    keyPrefix: 'fasting',
    title: Copy.practiceFastingTitle,
    note: Copy.practiceFastingNote,
    addLabel: Copy.addPracticeFasting,
    openRegister: Copy.openPracticeFastingRegister,
    registerTitle: Copy.practiceFastingRegisterTitle,
    registerNote: Copy.practiceFastingRegisterNote,
    registerEmpty: Copy.practiceFastingRegisterEmpty,
    confirmDelete: Copy.practiceFastingConfirmDelete,
    groups: kPracticeFastingGroups,
    catalog: kPracticeFastingCatalog,
    recordFrom: recordFromFastingCatalog,
  );
}

class PracticeFastingWash extends StatelessWidget {
  const PracticeFastingWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: fastingLearnSpec());
  }
}

PracticeLearnSpec hajjLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.hajj,
    keyPrefix: 'hajj',
    title: Copy.practiceHajjTitle,
    note: Copy.practiceHajjNote,
    addLabel: Copy.addPracticeHajj,
    openRegister: Copy.openPracticeHajjRegister,
    registerTitle: Copy.practiceHajjRegisterTitle,
    registerNote: Copy.practiceHajjRegisterNote,
    registerEmpty: Copy.practiceHajjRegisterEmpty,
    confirmDelete: Copy.practiceHajjConfirmDelete,
    groups: kPracticeHajjGroups,
    catalog: kPracticeHajjCatalog,
    recordFrom: recordFromHajjCatalog,
  );
}

class PracticeHajjWash extends StatelessWidget {
  const PracticeHajjWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: hajjLearnSpec());
  }
}

PracticeLearnSpec charityLearnSpec() {
  return PracticeLearnSpec(
    domain: MonitorDomain.charity,
    keyPrefix: 'charity',
    title: Copy.practiceCharityTitle,
    note: Copy.practiceCharityNote,
    addLabel: Copy.addPracticeCharity,
    openRegister: Copy.openPracticeCharityRegister,
    registerTitle: Copy.practiceCharityRegisterTitle,
    registerNote: Copy.practiceCharityRegisterNote,
    registerEmpty: Copy.practiceCharityRegisterEmpty,
    confirmDelete: Copy.practiceCharityConfirmDelete,
    groups: kPracticeCharityGroups,
    catalog: kPracticeCharityCatalog,
    recordFrom: recordFromCharityCatalog,
  );
}

class PracticeCharityWash extends StatelessWidget {
  const PracticeCharityWash({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    return PracticeGroupedLearnWash(spec: charityLearnSpec());
  }
}

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

void _reveal(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!context.mounted) return;
    await Scrollable.ensureVisible(
      context,
      alignment: 0.08,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  });
}

class PracticeGroupedLearnWash extends ConsumerStatefulWidget {
  const PracticeGroupedLearnWash({super.key, required this.spec});

  final PracticeLearnSpec spec;

  @override
  ConsumerState<PracticeGroupedLearnWash> createState() =>
      _PracticeGroupedLearnWashState();
}

class _PracticeGroupedLearnWashState
    extends ConsumerState<PracticeGroupedLearnWash> {
  String? _message;
  var _aboutOpen = true;

  void _collapseAbout() {
    if (!_aboutOpen) return;
    setState(() => _aboutOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final spec = widget.spec.focused(
      PersonalisationResolver(
        visibleDomains: prefs.visibleDomains,
        mix: prefs.personalMix,
      ),
    );
    if (spec.groups.isEmpty) return const SizedBox.shrink();
    final records = practiceRecordsForDomain(
      ref.watch(practiceHadithProvider).value ?? const [],
      spec.domain,
    );
    final identity = domainColorIdentity(spec.domain);
    final wash = identity.practiceWashFor(Theme.of(context).brightness);
    final addedFill = Theme.of(context).colorScheme.secondaryContainer;
    final addedInk = Theme.of(context).colorScheme.onSecondaryContainer;

    return WashPanel(
      key: Key('${spec.keyPrefix}-practice-panel'),
      color: wash,
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key('${spec.keyPrefix}-practice-wash'),
          initiallyExpanded: false,
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 40,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
          onExpansionChanged: (open) {
            if (open) _reveal(context);
          },
          title: Text(
            spec.title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          children: [
            PracticeAboutRegisterRow(
              about: CollapsingIntroNote(
                key: Key('${spec.keyPrefix}-practice-about'),
                title: Copy.washAboutTitle,
                note: spec.note,
                expanded: _aboutOpen,
                onExpansionChanged: (open) {
                  if (open == _aboutOpen) return;
                  setState(() => _aboutOpen = open);
                },
              ),
              register: OutlinedButton(
                key: Key('${spec.keyPrefix}-practice-open-register'),
                style: _slimRegisterStyle,
                onPressed: () {
                  _collapseAbout();
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (context) =>
                        _PracticeGroupedRegisterSheet(spec: widget.spec),
                  );
                },
                child: Text(
                  spec.openRegister,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
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
            for (var g = 0; g < spec.groups.length; g++)
              _groupTile(
                spec: spec,
                group: spec.groups[g],
                initiallyExpanded: g == 0,
                records: records,
                addedFill: addedFill,
                addedInk: addedInk,
              ),
          ],
        ),
      ),
    );
  }

  Widget _groupTile({
    required PracticeLearnSpec spec,
    required String group,
    required bool initiallyExpanded,
    required List<PracticeHadithRecord> records,
    required Color addedFill,
    required Color addedInk,
  }) {
    final items = spec.itemsInGroup(group);
    final children = <Widget>[];
    var lastSub = '';
    final clusters = <List<PracticeDhikrItem>>[];
    for (final item in items) {
      if (clusters.isEmpty || clusters.last.last.topic != item.topic) {
        clusters.add([item]);
      } else {
        clusters.last.add(item);
      }
    }
    for (final cluster in clusters) {
      final item = cluster.first;
      if (item.subgroup.isNotEmpty &&
          item.subgroup != kDhikrSubHighly &&
          item.subgroup != lastSub) {
        lastSub = item.subgroup;
        children.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Text(
                displayHomeBand(item.subgroup),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.45,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }
      children.add(
        PracticeTopicSkimCard(
          specKeyPrefix: widget.spec.keyPrefix,
          domain: widget.spec.domain,
          items: cluster,
          addLabel: widget.spec.addLabel,
          alreadyFor: (row) =>
              practiceHadithAlreadyRegistered(records, row.id),
          onAdd: _add,
          onOpen: _collapseAbout,
          addedFill: addedFill,
          addedInk: addedInk,
        ),
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: Key('${widget.spec.keyPrefix}-practice-group-$group'),
        initiallyExpanded: initiallyExpanded,
        dense: true,
        tilePadding: EdgeInsets.zero,
        title: HomeBandHeading(
          band: group,
          family: domainColorIdentity(widget.spec.domain).family,
          baseWash: domainColorIdentity(widget.spec.domain)
              .washFor(Theme.of(context).brightness),
        ),
        children: children,
      ),
    );
  }

  Future<void> _add(PracticeDhikrItem item) async {
    _collapseAbout();
    final records = practiceRecordsForDomain(
      ref.read(practiceHadithProvider).value ?? const [],
      widget.spec.domain,
    );
    if (practiceHadithAlreadyRegistered(records, item.id)) return;
    final now = ref.read(nowProvider);
    await ref
        .read(practiceHadithProvider.notifier)
        .save(
          widget.spec.recordFrom(
            item: item,
            id: newOpaqueId(),
            addedDateKey: dateKey(now),
          ),
        );
    if (!mounted) return;
    setState(() => _message = Copy.practiceHadithAdded);
  }
}

class _PracticeGroupedRegisterSheet extends ConsumerStatefulWidget {
  const _PracticeGroupedRegisterSheet({required this.spec});

  final PracticeLearnSpec spec;

  @override
  ConsumerState<_PracticeGroupedRegisterSheet> createState() =>
      _PracticeGroupedRegisterSheetState();
}

class _PracticeGroupedRegisterSheetState
    extends ConsumerState<_PracticeGroupedRegisterSheet> {
  final _selected = <String>{};
  String? _message;

  @override
  Widget build(BuildContext context) {
    final records = orderedPracticeHadithRegister(
      practiceRecordsForDomain(
        ref.watch(practiceHadithProvider).value ?? const [],
        widget.spec.domain,
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
            widget.spec.registerTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.spec.registerNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              TextButton(
                key: Key('${widget.spec.keyPrefix}-practice-select-all'),
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
                key: Key('${widget.spec.keyPrefix}-practice-delete-selected'),
                onPressed: _deleteSelected,
                child: const Text(Copy.actionDeleteSelected),
              ),
            ],
          ),
          if (records.isEmpty)
            Text(
              widget.spec.registerEmpty,
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
                              key: Key(
                                '${widget.spec.keyPrefix}-practice-check-${record.id}',
                              ),
                              value: _selected.contains(record.id),
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
                                  '${record.group.isEmpty ? record.topic : record.group} · ${record.topic} · ${formatDayMonthYear(record.addedDateKey)}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                PracticeCitationLink(
                                  domain: widget.spec.domain,
                                  text: record.content,
                                  source: record.source,
                                  sourceDetail: '',
                                ),
                                PracticeRemembranceCore(
                                  contextText: record.content,
                                  arabic: record.arabic,
                                  transliteration: record.transliteration,
                                  translation: record.translation,
                                ),
                                PracticeRegisterStatusSelect(
                                  dropdownKey: Key(
                                    '${widget.spec.keyPrefix}-practice-status-${record.id}',
                                  ),
                                  domain: widget.spec.domain,
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
          if (_message != null) Text(_message!),
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
          content: Text(widget.spec.confirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(Copy.closeActionRegister),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.actionConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await ref.read(practiceHadithProvider.notifier).deleteMany([..._selected]);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _message = null;
    });
  }
}
