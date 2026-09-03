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
      }
    });
  }

  @override
  void dispose() {
    _gratitude.dispose();
    _reflection.dispose();
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
            'Reading/listening is the daily item. Other Qur’an dimensions are independent observations.',
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
          const SizedBox(height: 8),
          ActivityPicker(
            options: ActivityCatalog.forQuran(dimension),
            selectedId: selected.id,
            accent: MuhasabahColors.quran(dimension),
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
          const Text('Personal reflection'),
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
                '${dimension.label} context',
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
              'Recorded context (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'These notes describe what you recorded. They are not causes.',
            ),
            const SizedBox(height: 12),
            ...blocks,
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
