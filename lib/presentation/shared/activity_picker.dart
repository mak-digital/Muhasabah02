import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/charity_factors.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/factor_groups.dart';
import '../../domain/home_traces.dart';
import '../../domain/quran.dart';
import '../../domain/salah_factors.dart';
import '../../domain/thirty_day_trend.dart';
import 'domain_line_icon.dart';
import 'domain_visual.dart';
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
    final domain = domainForTitle(text);
    final title = Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (domain == null)
          title
        else
          Row(
            children: [
              DomainLineIcon(
                domain,
                size: 20,
                color: domainColorIdentity(domain).family,
              ),
              const SizedBox(width: 8),
              Expanded(child: title),
            ],
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
    this.fillColor,
    this.compact = false,
  });

  final T value;
  final List<CheckInSelectEntry<T>> entries;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final Key? dropdownKey;
  final CheckInFieldDepth depth;
  final bool sortLabels;
  final Color? fillColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nested = depth == CheckInFieldDepth.nested;
    final indent = compact
        ? 0.0
        : nested
        ? checkInNestedIndent
        : checkInValueIndent;
    final fill =
        fillColor ?? scheme.surface.withValues(alpha: nested ? 0.52 : 0.9);
    final ink = nested ? scheme.onSurfaceVariant : scheme.onSurface;
    final labelStyle = compact
        ? Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ink,
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w600,
          )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink);
    final sorted = [...entries];
    if (sortLabels) {
      sorted.sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    }
    Widget labelFor(CheckInSelectEntry<T> entry) {
      final text = Text(
        entry.label,
        maxLines: compact ? 1 : 6,
        overflow: TextOverflow.ellipsis,
        style: labelStyle,
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
            borderRadius: BorderRadius.circular(compact ? 8 : 10),
            side: compact
                ? BorderSide.none
                : BorderSide(
                    color: scheme.outlineVariant.withValues(
                      alpha: nested ? 0.7 : 1,
                    ),
                  ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              key: ValueKey<T>(value),
              isExpanded: true,
              isDense: true,
              itemHeight: null,
              value: value,
              menuMaxHeight: 560,
              style: labelStyle,
              iconEnabledColor: scheme.onSurfaceVariant,
              padding: compact
                  ? const EdgeInsets.fromLTRB(6, 2, 2, 2)
                  : const EdgeInsets.fromLTRB(12, 8, 8, 8),
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

Key? activityPickerItemKey(String? statusKeyPrefix, ActivityOption option) {
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

bool activityPickerUsesColourSwatches(List<ActivityOption> options) {
  return ActivityCatalog.isObligatorySalahCatalog(options) ||
      identical(options, ActivityCatalog.tahajjud) ||
      identical(options, ActivityCatalog.ishraq) ||
      identical(options, ActivityCatalog.tawbah) ||
      ActivityCatalog.isDurationCatalog(options) ||
      identical(options, ActivityCatalog.hadithLivedNoticed) ||
      ActivityCatalog.isDhikrPostFardCatalog(options) ||
      ActivityCatalog.isAkhlaqObservationCatalog(options) ||
      ActivityCatalog.isHuquqObservationCatalog(options) ||
      ActivityCatalog.isKnowledgeObservationCatalog(options) ||
      ActivityCatalog.isTimeObservationCatalog(options) ||
      ActivityCatalog.isHealthObservationCatalog(options) ||
      ActivityCatalog.isWealthObservationCatalog(options) ||
      ActivityCatalog.isUmmahObservationCatalog(options) ||
      ActivityCatalog.isCharityObservationCatalog(options) ||
      ActivityCatalog.isFastingObservationCatalog(options);
}

/// Opens the full activity list under [anchorContext], skipping a closed
/// dropdown step. Menu top aligns just below the anchor widget.
Future<void> showAnchoredActivityMenu({
  required BuildContext anchorContext,
  required List<ActivityOption> options,
  required String selectedId,
  required ValueChanged<ActivityOption> onSelected,
  String? statusKeyPrefix,
  bool showColourSwatches = false,
}) async {
  final box = anchorContext.findRenderObject() as RenderBox?;
  final overlay =
      Overlay.maybeOf(anchorContext)?.context.findRenderObject() as RenderBox?;
  if (box == null || overlay == null || !box.hasSize) return;

  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final size = box.size;
  final position = RelativeRect.fromLTRB(
    topLeft.dx,
    topLeft.dy + size.height,
    overlay.size.width - topLeft.dx - size.width,
    overlay.size.height - topLeft.dy - size.height,
  );

  final durationList = ActivityCatalog.isDurationCatalog(options);
  final preserveOrder = ActivityCatalog.preservePickerOrder(options);
  final shown = [...options];
  if (!preserveOrder) {
    shown.sort(
      (a, b) => compactChoiceLabel(
        a.label,
        stripCatalogRowName: durationList,
        optionId: a.id,
      ).toLowerCase().compareTo(
        compactChoiceLabel(
          b.label,
          stripCatalogRowName: durationList,
          optionId: b.id,
        ).toLowerCase(),
      ),
    );
  }
  final byId = {for (final option in shown) option.id: option};

  final chosen = await showMenu<String>(
    context: anchorContext,
    position: position,
    constraints: BoxConstraints(
      minWidth: size.width.clamp(200, overlay.size.width - 16),
      maxWidth: overlay.size.width - 16,
      maxHeight: 560,
    ),
    items: [
      for (final option in shown)
        PopupMenuItem<String>(
          key: activityPickerItemKey(statusKeyPrefix, option),
          value: option.id,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (showColourSwatches) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: SalahActivityMark.colourForId(option.id),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  compactChoiceLabel(
                    option.label,
                    stripCatalogRowName: durationList,
                    optionId: option.id,
                  ),
                  style: option.id == selectedId
                      ? const TextStyle(fontWeight: FontWeight.w700)
                      : null,
                ),
              ),
              if (option.id == selectedId)
                Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(anchorContext).colorScheme.primary,
                ),
            ],
          ),
        ),
    ],
  );
  if (chosen == null) return;
  final option = byId[chosen];
  if (option != null) onSelected(option);
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
    final durationList = ActivityCatalog.isDurationCatalog(options);
    final swatches =
        activityPickerUsesColourSwatches(options) &&
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
            label: compactChoiceLabel(
              option.label,
              stripCatalogRowName: durationList,
              optionId: option.id,
            ),
            itemKey: activityPickerItemKey(statusKeyPrefix, option),
            swatch: swatches ? SalahActivityMark.colourForId(option.id) : null,
          ),
      ],
      onChanged: (id) {
        final option = byId[id];
        if (option != null) onSelected(option);
      },
    );
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
    this.helpingTitle = 'HELPING FACTORS',
    this.distractingTitle = 'DISTRACTING FACTORS',
    this.sortHelping = true,
    this.sortDistracting = true,
  });

  factory CheckInFactorSelects.forHomeTrace({
    Key? key,
    required String storageKey,
    required TernaryOutcome outcome,
    required SalahFactorCapture factors,
    required ValueChanged<String> onHelpingChanged,
    required ValueChanged<String> onDistractingChanged,
    Key? helpingKey,
    Key? distractingKey,
  }) {
    final postFard = isDhikrPostFardTrace(storageKey);
    return CheckInFactorSelects(
      key: key,
      groups: factorGroupsForHomeTrace(storageKey, outcome),
      helping: NamedFactor.helpingForHomeTrace(
        storageKey,
        existingIds: factors.supportIds,
      ),
      distracting: postFard
          ? const []
          : NamedFactor.distractingForHomeTrace(
              storageKey,
              existingIds: factors.challengeIds,
            ),
      helpingId: selectedFactorId(factors.supportIds),
      distractingId: selectedFactorId(factors.challengeIds),
      helpingKey: helpingKey,
      distractingKey: distractingKey,
      helpingTitle: postFard
          ? Copy.howAttentiveWasI.toUpperCase()
          : 'HELPING FACTORS',
      sortHelping: !postFard,
      onHelpingChanged: onHelpingChanged,
      onDistractingChanged: onDistractingChanged,
    );
  }

  final FactorGroups groups;
  final List<NamedFactor> helping;
  final List<NamedFactor> distracting;
  final String helpingId;
  final String distractingId;
  final ValueChanged<String> onHelpingChanged;
  final ValueChanged<String> onDistractingChanged;
  final Key? helpingKey;
  final Key? distractingKey;
  final String helpingTitle;
  final String distractingTitle;
  final bool sortHelping;
  final bool sortDistracting;

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
            child: Text(helpingTitle, style: labelStyle),
          ),
          CheckInSelect<String>(
            depth: CheckInFieldDepth.nested,
            dropdownKey: helpingKey,
            sortLabels: sortHelping,
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
            child: Text(distractingTitle, style: labelStyle),
          ),
          CheckInSelect<String>(
            depth: CheckInFieldDepth.nested,
            dropdownKey: distractingKey,
            sortLabels: sortDistracting,
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
