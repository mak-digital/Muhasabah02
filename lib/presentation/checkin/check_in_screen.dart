import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../data/privacy_log.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/other_domains.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/recorded_context.dart';
import '../../app/theme.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
      ),
    );
  }

  Widget _prayerRow(PrayerId id) {
    final status = _draft.prayer(id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            id.label,
            style: Theme.of(context).textTheme.titleSmall,
            semanticsLabel: '${id.label}, currently ${status.label}',
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in PrayerStatus.values)
                ChoiceChip(
                  key: Key('salah-${id.name}-${value.name}'),
                  selected: status == value,
                  label: Text(value.label),
                  selectedColor: MuhasabahColors.prayer(id)
                      .withValues(alpha: 0.22),
                  onSelected: (_) => setState(() {
                    _draft = _draft.withPrayer(id, value);
                  }),
                  avatar: Icon(
                    switch (value) {
                      PrayerStatus.onTime => Icons.circle,
                      PrayerStatus.late => Icons.schedule,
                      PrayerStatus.missed => Icons.close,
                      PrayerStatus.unanswered => Icons.more_horiz,
                    },
                    size: 16,
                    color: MuhasabahColors.prayer(id),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quranCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qur’an', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Reading/listening is the daily item. The other six dimensions are independent observations.',
            ),
            const SizedBox(height: 12),
            for (final dimension in QuranDimension.values) ...[
              _ternaryBlock(
                title: dimension.label,
                question: dimension.question,
                accent: MuhasabahColors.quran(dimension),
                outcome: _draft.quranOutcome(dimension),
                positive: dimension.positiveLabel,
                negative: dimension.negativeLabel,
                onChanged: (value) => setState(() {
                  _draft = _draft.withQuran(dimension, value);
                }),
              ),
              if (dimension.isApplicationReflection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    Copy.applicationReflectionNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ternaryBlock({
    required String title,
    required String question,
    required Color accent,
    required TernaryOutcome outcome,
    required String positive,
    required String negative,
    required ValueChanged<TernaryOutcome> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(question),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                selected: outcome == TernaryOutcome.positive,
                label: Text(positive),
                onSelected: (_) => onChanged(TernaryOutcome.positive),
                selectedColor: accent.withValues(alpha: 0.22),
              ),
              ChoiceChip(
                selected: outcome == TernaryOutcome.negative,
                label: Text(negative),
                onSelected: (_) => onChanged(TernaryOutcome.negative),
                selectedColor: accent.withValues(alpha: 0.12),
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

  Widget _otherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Other observations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text('Dhikr / Istighfar'),
            Wrap(
              spacing: 8,
              children: [
                for (final value in DhikrStatus.values)
                  ChoiceChip(
                    selected: _draft.dhikr == value,
                    label: Text(value.label),
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(dhikr: value);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Character / conduct'),
            Wrap(
              spacing: 8,
              children: [
                for (final value in ConductStatus.values)
                  ChoiceChip(
                    selected: _draft.conduct == value,
                    label: Text(value.label),
                    onSelected: (_) => setState(() {
                      _draft = _draft.copyWith(conduct: value);
                    }),
                  ),
              ],
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
      ),
    );
  }

  Widget _contextCard() {
    final blocks = <Widget>[];
    for (final dimension in QuranDimension.values) {
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
