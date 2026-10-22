import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/dhikr_context.dart';
import '../../domain/dhikr_source_registry.dart';
import 'dhikr_practice_reference.dart';

class DhikrPerformedList extends ConsumerStatefulWidget {
  const DhikrPerformedList({
    super.key,
    required this.rowKey,
    required this.record,
    required this.onChanged,
  });

  final String rowKey;
  final DailyCheckIn record;
  final ValueChanged<DailyCheckIn> onChanged;

  @override
  ConsumerState<DhikrPerformedList> createState() => _DhikrPerformedListState();
}

class _DhikrPerformedListState extends ConsumerState<DhikrPerformedList> {
  final _counts = <String, TextEditingController>{};
  final _focus = <String, FocusNode>{};

  List<DhikrContextItem> get _catalog => dhikrContextItemsFor(widget.rowKey);

  List<DhikrContextCapture> get _captures =>
      widget.record.dhikrContextFor(widget.rowKey);

  @override
  void initState() {
    super.initState();
    for (final item in _catalog) {
      _focus[item.id] = FocusNode();
      _counts[item.id] = TextEditingController(text: '${_countFor(item)}');
    }
  }

  @override
  void didUpdateWidget(DhikrPerformedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record == widget.record) return;
    for (final item in _catalog) {
      final next = '${_countFor(item)}';
      final controller = _counts[item.id];
      if (controller != null &&
          controller.text != next &&
          !_focus[item.id]!.hasFocus) {
        controller.text = next;
      }
    }
  }

  @override
  void dispose() {
    for (final node in _focus.values) {
      node.dispose();
    }
    for (final controller in _counts.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int _countFor(DhikrContextItem item) {
    final recorded = _capture(item.id)?.repetitions;
    final remembered = ref.read(appPrefsProvider).dhikrCountDefaultFor(item.id);
    return resolvedDhikrCount(
      item: item,
      recorded: recorded,
      remembered: remembered,
    );
  }

  DhikrContextCapture? _capture(String id) {
    for (final item in _captures) {
      if (item.activityId == id) return item;
    }
    return null;
  }

  bool _practised(String id) =>
      _capture(id)?.response == DhikrContextResponse.practised;

  int _parsedCount(String id) {
    final item = dhikrContextItemById[id];
    if (item == null) return 1;
    return resolvedDhikrCount(
      item: item,
      recorded: int.tryParse(_counts[id]?.text ?? ''),
      remembered: ref.read(appPrefsProvider).dhikrCountDefaultFor(id),
    );
  }

  void _write(List<DhikrContextCapture> next) {
    widget.onChanged(
      widget.record.withDhikrContextCaptures(widget.rowKey, next),
    );
  }

  Future<void> _remember(String id, int count) {
    return ref.read(appPrefsProvider).setDhikrCountDefault(id, count);
  }

  void _setAll(bool on) {
    if (!on) {
      _write(const []);
      return;
    }
    final now = DateTime.now();
    _write([
      for (final item in _catalog)
        DhikrContextCapture(
          activityId: item.id,
          response: DhikrContextResponse.practised,
          repetitions: _parsedCount(item.id),
          updatedAt: now,
        ),
    ]);
    for (final item in _catalog) {
      _remember(item.id, _parsedCount(item.id));
    }
    if (_catalog.isEmpty) return;
    final first = _catalog.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final node = _focus[first.id];
      final controller = _counts[first.id];
      if (node == null || controller == null) return;
      node.requestFocus();
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    });
  }

  void _setPractised(DhikrContextItem item, bool on, {bool focusCount = true}) {
    if (!on) {
      _write([
        for (final capture in _captures)
          if (capture.activityId != item.id) capture,
      ]);
      return;
    }
    final count = _parsedCount(item.id);
    _counts[item.id]?.text = '$count';
    final existing = _capture(item.id);
    _write([
      for (final capture in _captures)
        if (capture.activityId != item.id) capture,
      (existing ??
              DhikrContextCapture(
                activityId: item.id,
                response: DhikrContextResponse.practised,
              ))
          .copyWith(
            response: DhikrContextResponse.practised,
            repetitions: count,
            updatedAt: DateTime.now(),
          ),
    ]);
    _remember(item.id, count);
    if (focusCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final node = _focus[item.id];
        final controller = _counts[item.id];
        if (node == null || controller == null) return;
        node.requestFocus();
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      });
    }
  }

  void _setCount(DhikrContextItem item, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 3 ? digits.substring(0, 3) : digits;
    final controller = _counts[item.id];
    if (controller != null && controller.text != clipped) {
      controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
    }
    if (clipped.isEmpty) return;
    final count = clampDhikrCount(int.tryParse(clipped));
    if (count <= 0) return;
    _remember(item.id, count);
    if (!_practised(item.id)) return;
    final existing = _capture(item.id);
    if (existing == null) return;
    _write([
      for (final capture in _captures)
        if (capture.activityId == item.id)
          capture.copyWith(repetitions: count, updatedAt: DateTime.now())
        else
          capture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    final practised = [
      for (final item in catalog)
        if (_practised(item.id)) item.id,
    ];
    final allOn = practised.length == catalog.length && catalog.isNotEmpty;
    final someOn = practised.isNotEmpty && !allOn;
    final theme = Theme.of(context);
    const countWidth = 80.0;
    final headingStyle = theme.textTheme.labelSmall?.copyWith(
      letterSpacing: 0.4,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final wash = Color.alphaBlend(
      MuhasabahColors.dhikrFamily.withValues(alpha: 0.18),
      theme.colorScheme.surface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: wash,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 4, 2),
            child: Row(
              children: [
                Checkbox(
                  key: Key('dhikr-select-all-${widget.rowKey}'),
                  value: allOn
                      ? true
                      : someOn
                      ? null
                      : false,
                  tristate: true,
                  onChanged: (value) => _setAll(value == true),
                ),
                Expanded(
                  child: Text(
                    Copy.dhikrPerformedHeading.toUpperCase(),
                    style: headingStyle,
                  ),
                ),
                SizedBox(
                  width: countWidth,
                  child: Text(
                    Copy.dhikrPerformedCountHeading.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: headingStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final item in catalog)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  key: Key('dhikr-pick-${item.id}'),
                  value: _practised(item.id),
                  onChanged: (value) => _setPractised(item, value == true),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: theme.textTheme.titleSmall),
                        if (dhikrShowsWordingLink(item))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              key: Key('dhikr-wording-${item.id}'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () => openDhikrPracticeReference(
                                context,
                                item: item,
                              ),
                              child: Text(
                                dhikrWordingLinkLabel(item),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: countWidth,
                  child: TextField(
                    key: Key('dhikr-count-${item.id}'),
                    controller: _counts[item.id],
                    focusNode: _focus[item.id],
                    enabled: _practised(item.id),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: theme.textTheme.titleMedium,
                    decoration: const InputDecoration(
                      isDense: true,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) => _setCount(item, value),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
