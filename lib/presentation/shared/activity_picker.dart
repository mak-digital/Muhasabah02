import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/charity_factors.dart';
import '../../domain/context_catalog.dart';
import '../../domain/factor_groups.dart';
import 'salah_activity_mark.dart';

const checkInValueIndent = 20.0;
const checkInNestedIndent = 40.0;

enum CheckInFieldDepth { value, nested }

class CheckInDomainTitle extends StatelessWidget {
  const CheckInDomainTitle(this.text, {super.key, this.focus});

  final String text;
  final String? focus;

  @override
  Widget build(BuildContext context) {
    final question = focus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
        if (question != null && question.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            question,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontStyle: FontStyle.italic, height: 1.35),
          ),
        ],
      ],
    );
  }
}

class CheckInRowLabel extends StatelessWidget {
  const CheckInRowLabel(this.text, {super.key, this.semanticsLabel});

  final String text;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      semanticsLabel: semanticsLabel,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class CheckInSelectEntry<T> {
  const CheckInSelectEntry({
    required this.value,
    required this.label,
    this.itemKey,
    this.swatch,
  });

  final T value;
  final String label;
  final Key? itemKey;
  final Color? swatch;
}

class CheckInSelect<T> extends StatelessWidget {
  const CheckInSelect({
    super.key,
    required this.value,
    required this.entries,
    required this.onChanged,
    this.enabled = true,
    this.dropdownKey,
    this.depth = CheckInFieldDepth.value,
    this.sortLabels = true,
  });

  final T value;
  final List<CheckInSelectEntry<T>> entries;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final Key? dropdownKey;
  final CheckInFieldDepth depth;
  final bool sortLabels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nested = depth == CheckInFieldDepth.nested;
    final indent = nested ? checkInNestedIndent : checkInValueIndent;
    final fill = scheme.surface.withValues(alpha: nested ? 0.52 : 0.9);
    final ink = nested ? scheme.onSurfaceVariant : scheme.onSurface;
    final sorted = [...entries];
    if (sortLabels) {
      sorted.sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    }
    Widget labelFor(CheckInSelectEntry<T> entry) {
      final text = Text(
        entry.label,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink),
      );
      final swatch = entry.swatch;
      if (swatch == null) return text;
      return Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: text),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: KeyedSubtree(
        key: dropdownKey,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: nested ? 0.7 : 1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              key: ValueKey<T>(value),
              isExpanded: true,
              isDense: true,
              value: value,
              menuMaxHeight: 560,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ink),
              iconEnabledColor: scheme.onSurfaceVariant,
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              items: [
                for (final entry in sorted)
                  DropdownMenuItem<T>(
                    key: entry.itemKey,
                    value: entry.value,
                    child: labelFor(entry),
                  ),
              ],
              selectedItemBuilder: (context) {
                return [
                  for (final entry in sorted)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: labelFor(entry),
                    ),
                ];
              },
              onChanged: enabled
                  ? (next) {
                      if (next != null) onChanged(next);
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityPicker extends ConsumerWidget {
  const ActivityPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.statusKeyPrefix,
    this.enabled = true,
  });

  final List<ActivityOption> options;
  final String selectedId;
  final ValueChanged<ActivityOption> onSelected;
  final String? statusKeyPrefix;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final salahList =
        identical(options, ActivityCatalog.salah) ||
        identical(options, ActivityCatalog.jumuah);
    final durationList = ActivityCatalog.isQuranDurationCatalog(options);
    final swatches =
        (salahList || durationList) &&
        ref.watch(appPrefsProvider).salahActivityColours;
    final extra = options.any((option) => option.id == selectedId)
        ? null
        : ActivityCatalog.findAnyQuran(selectedId);
    final shown = extra == null ? options : [extra, ...options];
    final byId = {for (final option in shown) option.id: option};
    return CheckInSelect<String>(
      dropdownKey: statusKeyPrefix == null ? null : Key(statusKeyPrefix!),
      value: selectedId,
      enabled: enabled,
      sortLabels: !ActivityCatalog.preservePickerOrder(options),
      entries: [
        for (final option in shown)
          CheckInSelectEntry(
            value: option.id,
            label: option.label,
            itemKey: _keyFor(option),
            swatch: swatches ? SalahActivityMark.colourForId(option.id) : null,
          ),
      ],
      onChanged: (id) {
        final option = byId[id];
        if (option != null) onSelected(option);
      },
    );
  }

  Key? _keyFor(ActivityOption option) {
    if (statusKeyPrefix == null) return null;
    if (option.id == 'aloneOnTime') {
      return Key('$statusKeyPrefix-onTime');
    }
    if (option.id == 'prayedLate') {
      return Key('$statusKeyPrefix-late');
    }
    if (option.id == 'missed') {
      return Key('$statusKeyPrefix-missed');
    }
    if (option.id == ActivityIds.unanswered) {
      return Key('$statusKeyPrefix-unanswered');
    }
    return Key('$statusKeyPrefix-${option.id}');
  }
}

class NamedFactor {
  const NamedFactor({required this.id, required this.label});

  final String id;
  final String label;

  static List<NamedFactor> fromContext(List<ContextFactor> catalog) {
    return [
      for (final factor in catalog)
        NamedFactor(id: factor.id, label: factor.label),
    ];
  }

  static List<NamedFactor> helpingForHomeTrace(
    String storageKey, {
    Iterable<String> existingIds = const [],
  }) {
    return fromContext(
      helpingFactorsForHomeTrace(storageKey, existingIds: existingIds),
    );
  }

  static List<NamedFactor> distractingForHomeTrace(
    String storageKey, {
    Iterable<String> existingIds = const [],
  }) {
    return fromContext(
      distractingFactorsForHomeTrace(storageKey, existingIds: existingIds),
    );
  }
}

class CheckInFactorSelects extends StatelessWidget {
  const CheckInFactorSelects({
    super.key,
    required this.groups,
    required this.helping,
    required this.distracting,
    required this.helpingId,
    required this.distractingId,
    required this.onHelpingChanged,
    required this.onDistractingChanged,
    this.helpingKey,
    this.distractingKey,
  });

  final FactorGroups groups;
  final List<NamedFactor> helping;
  final List<NamedFactor> distracting;
  final String helpingId;
  final String distractingId;
  final ValueChanged<String> onHelpingChanged;
  final ValueChanged<String> onDistractingChanged;
  final Key? helpingKey;
  final Key? distractingKey;

  @override
  Widget build(BuildContext context) {
    if (!groups.isVisible) return const SizedBox.shrink();
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 0.4,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: checkInValueIndent, top: 8),
          child: Text(
            'Optional. Stored. Never causes, completion, or scores.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (groups.showHelping) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: checkInNestedIndent,
              top: 8,
              bottom: 6,
            ),
            child: Text('HELPING FACTORS', style: labelStyle),
          ),
          CheckInSelect<String>(
            depth: CheckInFieldDepth.nested,
            dropdownKey: helpingKey,
            value: helping.any((factor) => factor.id == helpingId)
                ? helpingId
                : kFactorNotRecorded,
            entries: [
              const CheckInSelectEntry(
                value: kFactorNotRecorded,
                label: 'Not recorded',
              ),
              for (final factor in helping)
                CheckInSelectEntry(value: factor.id, label: factor.label),
            ],
            onChanged: onHelpingChanged,
          ),
        ],
        if (groups.showDistracting) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: checkInNestedIndent,
              top: 8,
              bottom: 6,
            ),
            child: Text('DISTRACTING FACTORS', style: labelStyle),
          ),
          CheckInSelect<String>(
            depth: CheckInFieldDepth.nested,
            dropdownKey: distractingKey,
            value: distracting.any((factor) => factor.id == distractingId)
                ? distractingId
                : kFactorNotRecorded,
            entries: [
              const CheckInSelectEntry(
                value: kFactorNotRecorded,
                label: 'Not recorded',
              ),
              for (final factor in distracting)
                CheckInSelectEntry(value: factor.id, label: factor.label),
            ],
            onChanged: onDistractingChanged,
          ),
        ],
      ],
    );
  }
}
