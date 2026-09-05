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
import '../../domain/other_domains.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/recorded_context.dart';
import '../../domain/salah_factors.dart';
import '../../domain/situation_notes.dart';
import '../shared/activity_picker.dart';
import '../shared/ui_bits.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, this.date});

  final DateTime? date;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  late DailyCheckIn _draft;
  late final TextEditingController _gratitude;
  late final TextEditingController _reflection;
  late final TextEditingController _situationCustom;
  final Map<String, TextEditingController> _contextNotes = {};
  final Map<String, TextEditingController> _custom = {};
  var _loaded = false;
  String? _error;

  String get _key => dateKey(widget.date ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _draft = DailyCheckIn.empty(_key);
    _gratitude = TextEditingController();
    _reflection = TextEditingController();
    _situationCustom = TextEditingController();
    Future<void>.microtask(_hydrate);
  }

  Future<void> _hydrate() async {
    if (_loaded) return;
    final records = await ref.read(checkInsProvider.future);
    DailyCheckIn? existing;
    for (final record in records) {
      if (record.dateKey == _key) existing = record;
    }
    if (!mounted) return;
    setState(() {
      _loaded = true;
      if (existing != null) {
        _draft = existing;
        _gratitude.text = existing.gratitudeText ?? '';
        _reflection.text = existing.personalReflectionText ?? '';
        _situationCustom.text = existing.situationNotes.customText ?? '';
      }
    });
  }

  @override
  void dispose() {
    _gratitude.dispose();
    _reflection.dispose();
    _situationCustom.dispose();
    for (final c in _contextNotes.values) {
      c.dispose();
    }
    for (final c in _custom.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check-in · $_key')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Text(
            Copy.unansweredNotMissed,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _salahCard(),
          const SizedBox(height: 12),
          _quranCard(),
          const SizedBox(height: 12),
          _otherCard(),
          const SizedBox(height: 12),
          _optionalDomainsCard(),
          const SizedBox(height: 12),
          _contextCard(),
          const SizedBox(height: 12),
          _situationNotesCard(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _save,
            child: const Text('Save check-in'),
          ),
        ),
      ),
    );
  }

  Widget _salahCard() {
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.salahWash,
        MuhasabahColors.salahWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Salah', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Each prayer is recorded independently. Absence is not missed.',
          ),
          const SizedBox(height: 12),
          for (final id in PrayerId.values) _prayerRow(id),
          if (parseDateKey(_key).weekday == DateTime.friday) ...[
            FilterChip(
              key: const Key('salah-jumuah-congregation'),
              selected: _draft.jumuahCongregation,
              label: const Text('Friday congregation attended'),
              onSelected: (selected) => setState(() {
                _draft = _draft.copyWith(jumuahCongregation: selected);
              }),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Friday prayer and voluntary prayers (optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'These stay off the recordable-field count. Unanswered is not missed.',
          ),
          const SizedBox(height: 8),
          _extraPrayerStatus(
            label: 'Jumu‘ah',
            enabled: parseDateKey(_key).weekday == DateTime.friday,
            status: _draft.jumuah,
            onChanged: (status) => setState(() {
              _draft = _draft.copyWith(jumuah: status);
            }),
          ),
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
          Text(
            id.label,
            style: Theme.of(context).textTheme.titleSmall,
            semanticsLabel: '${id.label}, currently ${_draft.prayer(id).label}',
          ),
          const SizedBox(height: 6),
          ActivityPicker(
            options: ActivityCatalog.salah,
            selectedId: selected.id,
            accent: MuhasabahColors.prayer(id),
            statusKeyPrefix: 'salah-${id.name}',
            onSelected: (option) => setState(() {
              _draft = _draft.withSalahActivity(
                id,
                RecordedActivity(
                  id: option.id,
                  customText: option.isOther ? _note(key).text : null,
                ),
              );
            }),
          ),
          if (selected.id == ActivityIds.other)
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
          if (id == PrayerId.fajr ||
              _draft.prayer(id).isRecorded ||
              (_draft.salahFactors[id.name]?.isEmpty == false))
            _salahFactors(id.name),
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
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          if (!enabled)
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'Friday only. Other days stay blank, not unanswered.',
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              for (final option in PrayerStatus.values)
                ChoiceChip(
                  selected: status == option,
                  label: Text(option.label),
                  onSelected: enabled ? (_) => onChanged(option) : null,
                ),
            ],
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
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                selected: outcome == TernaryOutcome.positive,
                label: const Text('Performed'),
                onSelected: (_) => onChanged(TernaryOutcome.positive),
              ),
              ChoiceChip(
                selected: outcome == TernaryOutcome.negative,
                label: const Text('Not performed'),
                onSelected: (_) => onChanged(TernaryOutcome.negative),
              ),
              ChoiceChip(
                selected: outcome == TernaryOutcome.unanswered,
                label: const Text('Not recorded'),
                onSelected: (_) => onChanged(TernaryOutcome.unanswered),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _salahFactors(String subject) {
    final existing = _draft.salahFactors[subject] ?? const SalahFactorCapture();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${Copy.youRecorded} (optional contributing factors)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final factor in SalahFactorCatalog.support)
                FilterChip(
                  label: Text(factor.label),
                  selected: existing.supportIds.contains(factor.id),
                  onSelected: (selected) {
                    final ids = [...existing.supportIds];
                    if (selected) {
                      if (!ids.contains(factor.id)) ids.add(factor.id);
                    } else {
                      ids.remove(factor.id);
                    }
                    setState(() {
                      _draft = _draft.withSalahFactors(
                        subject,
                        SalahFactorCapture(
                          supportIds: ids,
                          challengeIds: existing.challengeIds,
                          otherText: existing.otherText,
                        ),
                      );
                    });
                  },
                ),
              for (final factor in SalahFactorCatalog.challenge)
                FilterChip(
                  label: Text(factor.label),
                  selected: existing.challengeIds.contains(factor.id),
                  onSelected: (selected) {
                    final ids = [...existing.challengeIds];
                    if (selected) {
                      if (!ids.contains(factor.id)) ids.add(factor.id);
                    } else {
                      ids.remove(factor.id);
                    }
                    setState(() {
                      _draft = _draft.withSalahFactors(
                        subject,
                        SalahFactorCapture(
                          supportIds: existing.supportIds,
                          challengeIds: ids,
                          otherText: existing.otherText,
                        ),
                      );
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quranCard() {
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.quranWash,
        MuhasabahColors.quranWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qur’an', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Recitation is the daily item. Recitation with Meaning as engagement also records Recitation as engagement. Other Qur’an rows stay independent. Application Reflection is not recorded here.',
          ),
          const SizedBox(height: 12),
          for (final dimension in quranDailyDimensions) _quranBlock(dimension),
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
          Text(dimension.label, style: Theme.of(context).textTheme.titleSmall),
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
            accent: MuhasabahColors.quran(dimension),
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
              padding: const EdgeInsets.only(top: 8),
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
          Text(
            'Other observations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const Text('Dhikr / Istighfar'),
          ActivityPicker(
            options: ActivityCatalog.dhikr,
            selectedId: _draft.activityFor(ActivityCatalog.dhikrKey).id,
            accent: MuhasabahColors.dhikr,
            onSelected: (option) => setState(() {
              _draft = _draft
                  .copyWith(dhikr: option.dhikr ?? DhikrStatus.unanswered)
                  .withActivity(
                    ActivityCatalog.dhikrKey,
                    RecordedActivity(id: option.id),
                  );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Character / conduct'),
          ActivityPicker(
            options: ActivityCatalog.conduct,
            selectedId: _draft.activityFor(ActivityCatalog.conductKey).id,
            accent: MuhasabahColors.conduct,
            onSelected: (option) => setState(() {
              _draft = _draft
                  .copyWith(conduct: option.conduct ?? ConductStatus.unanswered)
                  .withActivity(
                    ActivityCatalog.conductKey,
                    RecordedActivity(id: option.id),
                  );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Gratitude'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                selected: _draft.gratitudeStatus == EntryStatus.recorded,
                label: const Text('Wrote an entry'),
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(
                    gratitudeStatus: EntryStatus.recorded,
                  );
                }),
              ),
              ChoiceChip(
                selected: _draft.gratitudeStatus == EntryStatus.noneToday,
                label: const Text('No entry today'),
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(
                    gratitudeStatus: EntryStatus.noneToday,
                    clearGratitudeText: true,
                  );
                  _gratitude.clear();
                }),
              ),
              ChoiceChip(
                selected: _draft.gratitudeStatus == EntryStatus.unanswered,
                label: const Text('Not recorded'),
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(
                    gratitudeStatus: EntryStatus.unanswered,
                  );
                }),
              ),
            ],
          ),
          if (_draft.gratitudeStatus == EntryStatus.recorded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _gratitude,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Optional private gratitude notes',
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(Copy.personalReflection),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                selected:
                    _draft.personalReflectionStatus == EntryStatus.recorded,
                label: const Text('Wrote an entry'),
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(
                    personalReflectionStatus: EntryStatus.recorded,
                  );
                }),
              ),
              ChoiceChip(
                selected:
                    _draft.personalReflectionStatus == EntryStatus.noneToday,
                label: const Text('No entry today'),
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(
                    personalReflectionStatus: EntryStatus.noneToday,
                    clearPersonalReflectionText: true,
                  );
                  _reflection.clear();
                }),
              ),
              ChoiceChip(
                selected:
                    _draft.personalReflectionStatus == EntryStatus.unanswered,
                label: const Text('Not recorded'),
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(
                    personalReflectionStatus: EntryStatus.unanswered,
                  );
                }),
              ),
            ],
          ),
          if (_draft.personalReflectionStatus == EntryStatus.recorded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
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

  Widget _optionalDomainsCard() {
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.summaryWash,
        MuhasabahColors.summaryWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optional domains',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Independent observations. Colour identifies the domain, not spiritual rank.',
          ),
          const SizedBox(height: 12),
          const Text('Fasting'),
          ActivityPicker(
            options: ActivityCatalog.fasting,
            selectedId: _draft.fasting.activityId,
            accent: MuhasabahColors.fasting,
            onSelected: (option) => setState(() {
              _draft = _draft.copyWith(
                fasting: DomainObservation(
                  activityId: option.id,
                  customText: option.isOther ? _note('fasting').text : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Financial charity'),
          ActivityPicker(
            options: ActivityCatalog.charity,
            selectedId: _draft.charity.activityId,
            accent: MuhasabahColors.charity,
            onSelected: (option) => setState(() {
              _draft = _draft.copyWith(
                charity: DomainObservation(activityId: option.id),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Zakat (status only, no amounts)'),
          ActivityPicker(
            options: ActivityCatalog.zakat,
            selectedId: _draft.zakat.name == 'unanswered'
                ? ActivityIds.unanswered
                : _draft.zakat.name,
            accent: MuhasabahColors.zakat,
            onSelected: (option) => setState(() {
              _draft = _draft.copyWith(
                zakat: option.zakat ?? ZakatStatus.unanswered,
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Family / kinship'),
          ActivityPicker(
            options: ActivityCatalog.family,
            selectedId: _draft.family.activityId,
            accent: MuhasabahColors.family,
            onSelected: (option) => setState(() {
              _draft = _draft.copyWith(
                family: DomainObservation(activityId: option.id),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Hadith engagement'),
          ActivityPicker(
            options: ActivityCatalog.hadith,
            selectedId: _draft.hadith.activityId,
            accent: MuhasabahColors.hadith,
            onSelected: (option) => setState(() {
              _draft = _draft.copyWith(
                hadith: DomainObservation(activityId: option.id),
              );
            }),
          ),
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
              Wrap(
                spacing: 8,
                children: [
                  for (final factor in ContextCatalog.forPolarity(polarity))
                    FilterChip(
                      label: Text(factor.label),
                      selected:
                          existing?.factorIds.contains(factor.id) ?? false,
                      onSelected: (selected) {
                        final ids = [...?existing?.factorIds];
                        if (selected) {
                          if (!ids.contains(factor.id)) ids.add(factor.id);
                        } else {
                          ids.remove(factor.id);
                        }
                        setState(() {
                          _draft = _draft.withContext(
                            RecordedContext(
                              subject: dimension,
                              polarity: polarity,
                              factorIds: ids,
                              freeText: _contextNotes[noteKey]?.text,
                            ),
                          );
                        });
                      },
                    ),
                ],
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
    next = next.copyWith(
      situationNotes: SituationNotes(
        ids: next.situationNotes.ids,
        customText: _situationCustom.text.trim().isEmpty
            ? null
            : _situationCustom.text.trim(),
      ),
    );
    try {
      await ref.read(checkInsProvider.notifier).save(next);
      logAppEvent('checkin_saved');
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = 'The check-in could not be saved. Your draft is still here.';
      });
    }
  }
}
