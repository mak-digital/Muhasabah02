import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/dhikr_context.dart';
import '../../domain/dhikr_source_registry.dart';
import '../../domain/practice_dhikr_catalog.dart';
import '../../domain/monitor_domain.dart';
import '../home/practice_hadith_home.dart';
import '../shared/domain_visual.dart';
import '../shared/system_insets.dart';

Future<void> openDhikrPracticeReference(
  BuildContext context, {
  required DhikrContextItem item,
  DailyCheckIn? record,
  ValueChanged<DailyCheckIn>? onChanged,
  ValueChanged<int>? onProgress,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => DhikrPracticeReferencePage(
        item: item,
        record: record,
        onChanged: onChanged,
        onProgress: onProgress,
      ),
    ),
  );
}

class DhikrPracticeReferencePage extends ConsumerStatefulWidget {
  const DhikrPracticeReferencePage({
    super.key,
    required this.item,
    this.record,
    this.onChanged,
    this.onProgress,
  });

  final DhikrContextItem item;
  final DailyCheckIn? record;
  final ValueChanged<DailyCheckIn>? onChanged;
  final ValueChanged<int>? onProgress;

  @override
  ConsumerState<DhikrPracticeReferencePage> createState() =>
      _DhikrPracticeReferencePageState();
}

class _DhikrPracticeReferencePageState
    extends ConsumerState<DhikrPracticeReferencePage> {
  late int _counted;
  Offset? _fabOffset;
  double _dragDx = 0;
  bool _draggingFab = false;

  int get _required {
    final seed = clampDhikrCount(widget.item.seedCount);
    return seed == 0 ? 1 : seed;
  }

  @override
  void initState() {
    super.initState();
    _counted = _syncedCount();
    final prefs = ref.read(appPrefsProvider);
    final dx = prefs.dhikrPracticeFabDx;
    final dy = prefs.dhikrPracticeFabDy;
    if (dx != null && dy != null) {
      _fabOffset = Offset(dx, dy);
    }
  }

  int _syncedCount() {
    final record = widget.record;
    final prefs = ref.read(appPrefsProvider);
    if (record != null) {
      final progress = prefs.dhikrProgressFor(record.dateKey, widget.item.id);
      if (progress != null) return progress;
    }
    return _recordedCount();
  }

  int _recordedCount() {
    final record = widget.record;
    if (record == null) return 0;
    for (final capture in record.dhikrContextFor(widget.item.rowKey)) {
      if (capture.activityId != widget.item.id) continue;
      if (capture.response != DhikrContextResponse.practised) return 0;
      return clampDhikrCount(capture.repetitions);
    }
    return 0;
  }

  Future<void> _saveProgress(int count) async {
    final record = widget.record;
    if (record == null) return;
    await ref
        .read(appPrefsProvider)
        .setDhikrProgress(record.dateKey, widget.item.id, count);
    widget.onProgress?.call(count);
  }

  void _persistPractised(int count) {
    final record = widget.record;
    final onChanged = widget.onChanged;
    if (record == null || onChanged == null) return;
    final captures = [
      for (final capture in record.dhikrContextFor(widget.item.rowKey))
        if (capture.activityId != widget.item.id) capture,
    ];
    if (count > 0) {
      final existing = record
          .dhikrContextFor(widget.item.rowKey)
          .where((item) => item.activityId == widget.item.id)
          .firstOrNull;
      captures.add(
        (existing ??
                DhikrContextCapture(
                  activityId: widget.item.id,
                  response: DhikrContextResponse.practised,
                ))
            .copyWith(
              response: DhikrContextResponse.practised,
              repetitions: count,
              updatedAt: DateTime.now(),
            ),
      );
    }
    onChanged(record.withDhikrContextCaptures(widget.item.rowKey, captures));
  }

  void _increment() {
    final next = _counted >= 999 ? 999 : _counted + 1;
    setState(() => _counted = next);
    _saveProgress(next);
    if (next >= _required) {
      _persistPractised(next);
    }
  }

  void _pop() => Navigator.of(context).pop();

  bool get _reachedRecommended => _counted >= _required;

  /// Primary while counting; lighter primary-container wash once the
  /// recommended count is reached (follows the selected theme).
  (Color fill, Color onFill) _counterColors(ColorScheme scheme) {
    if (_reachedRecommended) {
      return (scheme.primaryContainer, scheme.onPrimaryContainer);
    }
    return (scheme.primary, scheme.onPrimary);
  }

  Widget _countBadge(ColorScheme scheme) {
    final colors = _counterColors(scheme);
    return Material(
      key: const Key('dhikr-practice-counter'),
      color: colors.$1,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          '[$_counted of $_required]',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.$2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.item.sourceId == null
        ? null
        : dhikrSourceById[widget.item.sourceId];
    final practices = dhikrPracticeReferencesFor(widget.item);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    // Right-hand thumb pad: tall oval in the lower-right reach zone.
    const fabWidth = 58.0;
    const fabHeight = 78.0;
    final defaultThumbZone = Offset(
      size.width - fabWidth - 10,
      size.height - padding.bottom - fabHeight - 88,
    );
    final offset = _fabOffset ?? defaultThumbZone;
    final wash = domainColorIdentity(
      MonitorDomain.dhikr,
    ).washFor(theme.brightness, context);
    var badgePlaced = false;
    Widget? takeBadge() {
      if (badgePlaced) return null;
      badgePlaced = true;
      return _countBadge(scheme);
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) => _dragDx += details.delta.dx,
      onHorizontalDragEnd: (_) {
        if (_dragDx.abs() > 64) _pop();
        _dragDx = 0;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Copy.practiceDhikrTitle),
          leading: IconButton(
            key: const Key('dhikr-practice-close'),
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: _pop,
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: pageListPadding(context),
              children: [
                Text(widget.item.label, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Learn & Practice · ${dhikrPracticeSectionLabel(widget.item.rowKey)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (practices.isEmpty && source != null) ...[
                  PracticeRemembranceCore(
                    contextText: '',
                    arabic: source.arabic,
                    transliteration: source.transliteration,
                    translation: source.meaning,
                    wash: wash,
                    showScriptControls: source.arabic.isNotEmpty,
                    scriptFaceKey: const Key('dhikr-practice-script-face'),
                    scriptSmallerKey: const Key(
                      'dhikr-practice-script-smaller',
                    ),
                    scriptLargerKey: const Key('dhikr-practice-script-larger'),
                    scriptCornerBadge: source.arabic.isNotEmpty
                        ? takeBadge()
                        : null,
                  ),
                  if (source.arabic.isEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: takeBadge() ?? const SizedBox.shrink(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  PracticeCitationLink(
                    buttonKey: Key('dhikr-practice-citation-${widget.item.id}'),
                    domain: MonitorDomain.dhikr,
                    text: source.meaning,
                    source: source.citation,
                    sourceDetail: source.occasion,
                  ),
                ],
                for (final practice in practices) ...[
                  Text(
                    '${practice.group} · ${practice.subgroup}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(practice.topic, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  PracticeRemembranceCore(
                    contextText: practice.text,
                    arabic: practice.arabic,
                    transliteration: practice.transliteration,
                    translation: practice.translation,
                    wash: wash,
                    showScriptControls: practice.arabic.isNotEmpty,
                    scriptFaceKey: const Key('dhikr-practice-script-face'),
                    scriptSmallerKey: const Key(
                      'dhikr-practice-script-smaller',
                    ),
                    scriptLargerKey: const Key('dhikr-practice-script-larger'),
                    scriptCornerBadge: practice.arabic.isNotEmpty
                        ? takeBadge()
                        : null,
                  ),
                  if (practice.arabic.isEmpty && !badgePlaced) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: takeBadge() ?? const SizedBox.shrink(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  PracticeCitationLink(
                    buttonKey: Key('dhikr-practice-citation-${practice.id}'),
                    domain: MonitorDomain.dhikr,
                    text: practice.text,
                    source: practice.source,
                    sourceDetail: practice.sourceDetail,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'This is not a target, score, or ruling. Close returns to the check-in you were recording.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Positioned(
              left: offset.dx.clamp(4.0, size.width - fabWidth - 4),
              top: offset.dy.clamp(
                padding.top + 8,
                size.height - fabHeight - 40 - padding.bottom - 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    key: const Key('dhikr-practice-tap'),
                    onTap: _draggingFab ? null : _increment,
                    onPanStart: (_) => _draggingFab = true,
                    onPanUpdate: (details) {
                      setState(() {
                        _fabOffset = Offset(
                          (offset.dx + details.delta.dx).clamp(
                            4.0,
                            size.width - fabWidth - 4,
                          ),
                          (offset.dy + details.delta.dy).clamp(
                            padding.top + 8,
                            size.height - fabHeight - 40 - padding.bottom - 4,
                          ),
                        );
                      });
                    },
                    onPanEnd: (_) {
                      _draggingFab = false;
                      final saved = _fabOffset;
                      if (saved != null) {
                        ref
                            .read(appPrefsProvider)
                            .setDhikrPracticeFabOffset(saved.dx, saved.dy);
                      }
                    },
                    // Tilt matches a right thumb coming up from the lower-right grip.
                    child: Transform.rotate(
                      angle: -0.22,
                      child: Material(
                        elevation: 4,
                        shadowColor: _counterColors(
                          scheme,
                        ).$1.withValues(alpha: 0.45),
                        color: _counterColors(scheme).$1,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(38),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                        child: SizedBox(
                          width: fabWidth,
                          height: fabHeight,
                          child: Icon(
                            Icons.add,
                            color: _counterColors(scheme).$2,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Copy.dhikrPracticeCounter,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _counterColors(scheme).$1,
                      fontWeight: FontWeight.w700,
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
}
