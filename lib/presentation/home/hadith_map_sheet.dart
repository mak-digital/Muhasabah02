import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/hadith_map.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_hadith.dart';
import '../../domain/practice_hadith.dart';
import '../shared/domain_visual.dart';
import '../shared/system_insets.dart';
import '../shared/ui_bits.dart';
import 'practice_hadith_home.dart';

typedef HadithTextShare = Future<bool> Function({
  required String subject,
  required String text,
});

final hadithTextShareProvider = Provider<HadithTextShare>((ref) {
  return ({required subject, required text}) async {
    final result = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
    return result.status == ShareResultStatus.success;
  };
});

class HadithSpeech {
  Future<bool> speak({
    required String text,
    required String languageCode,
    VoidCallback? onComplete,
  }) async {
    return true;
  }

  Future<void> stop() async {}
}

class FlutterHadithSpeech implements HadithSpeech {
  FlutterTts? _tts;

  FlutterTts _player() {
    return _tts ??= FlutterTts();
  }

  @override
  Future<bool> speak({
    required String text,
    required String languageCode,
    VoidCallback? onComplete,
  }) async {
    try {
      final tts = _player();
      tts.setCompletionHandler(() => onComplete?.call());
      tts.setCancelHandler(() => onComplete?.call());
      tts.setErrorHandler((_) => onComplete?.call());
      await tts.setVolume(1);
      await tts.setSpeechRate(0.45);
      await tts.setPitch(1);
      final engines = await tts.getEngines;
      if (engines is List && engines.isNotEmpty) {
        final current = await tts.getDefaultEngine;
        await tts.setEngine('${current ?? engines.first}');
      }
      final installed = await tts.getLanguages;
      final arabic = languageCode.toLowerCase().startsWith('ar');
      final chosen = pickHadithTtsLanguage([
        if (installed is List)
          for (final item in installed) '$item',
      ], arabic: arabic);
      await tts.setLanguage(chosen);
      final result = await tts.speak(text);
      return result == 1;
    } catch (_) {
      onComplete?.call();
      return false;
    }
  }

  @override
  Future<void> stop() async {
    await _tts?.stop();
  }
}

final hadithSpeechProvider = Provider<HadithSpeech>(
  (ref) => FlutterHadithSpeech(),
);

Future<void> showHadithMapSheet(BuildContext context, WidgetRef ref) {
  final systemBottom = presentingSystemBottom(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height * 0.88;
      return SizedBox(
        height: height,
        child: HadithMapSheet(systemBottom: systemBottom),
      );
    },
  );
}

class HadithMapSheet extends ConsumerStatefulWidget {
  const HadithMapSheet({super.key, this.systemBottom = 0});

  final double systemBottom;

  @override
  ConsumerState<HadithMapSheet> createState() => _HadithMapSheetState();
}

class _HadithMapSheetState extends ConsumerState<HadithMapSheet> {
  HadithMapPeriod _period = HadithMapPeriod.week;
  String? _selectedId;
  bool _aboutOpen = false;
  bool _mapOpen = true;
  bool _countsOpen = false;
  bool _playing = false;
  HadithSpeech? _speech;

  @override
  void dispose() {
    _speech?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final todayKey = dateKey(ref.watch(nowProvider));
    final shelf =
        ref.watch(personalHadithProvider).value ?? const <PersonalHadith>[];
    final extras = personalHadithLearnItems(shelf);
    final records =
        ref.watch(practiceHadithProvider).value ??
        const <PracticeHadithRecord>[];
    final marks = buildHadithMapMarks(
      extras: extras,
      records: records,
      shelf: shelf,
      todayKey: todayKey,
    );
    final stats = hadithMapStats(marks, todayKey: todayKey, period: _period);
    final selected = _markFor(marks, _selectedId);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final family = domainColorIdentity(MonitorDomain.hadith).familyFor(context);
    final wash = Color.alphaBlend(
      family.withValues(alpha: 0.18),
      scheme.surface,
    );
    return Padding(
      padding: sheetContentPadding(context, systemBottom: widget.systemBottom),
      child: ListView(
        key: const Key('hadith-map-sheet'),
        children: [
          Material(
            color: wash,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              child: CollapsingIntroNote(
                key: const Key('hadith-map-about'),
                title: Copy.hadithMap,
                note: Copy.hadithMapNote,
                expanded: _aboutOpen,
                onExpansionChanged: (open) {
                  if (open == _aboutOpen) return;
                  setState(() => _aboutOpen = open);
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          _LegendBox(
            label: Copy.hadithMapColourCoding,
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                for (final fill in HadithMapFill.values)
                  _LegendItem(
                    mark: HadithMapMarkIcon(
                      family: HadithMapFamily.character,
                      fill: fill,
                      familyColor: family,
                    ),
                    label: Copy.hadithMapFillLabel(fill.name),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: ValueKey<bool>(_mapOpen),
                initiallyExpanded: _mapOpen,
                dense: true,
                visualDensity: VisualDensity.compact,
                minTileHeight: 32,
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                childrenPadding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                onExpansionChanged: (open) {
                  if (open == _mapOpen) return;
                  setState(() => _mapOpen = open);
                },
                title: Text(
                  Copy.hadithMapFullTitle(marks.length),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: family,
                  ),
                ),
                children: [
                  GridView.builder(
                    key: const Key('hadith-map-grid'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: marks.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final mark = marks[index];
                      final pressed = selected?.id == mark.id;
                      return Semantics(
                        button: true,
                        label:
                            '${mark.item.topic}. ${Copy.hadithMapFillLabel(mark.fill.name)}. ${Copy.hadithMapFamilyLabel(mark.family.name)}.',
                        child: InkWell(
                          key: Key('hadith-map-mark-${mark.id}'),
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onTap: () => setState(() {
                            _selectedId = mark.id;
                            _mapOpen = false;
                          }),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: pressed
                                  ? Border.all(color: family, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: HadithMapMarkIcon(
                                family: mark.family,
                                fill: mark.fill,
                                familyColor: family,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _LegendBox(
            label: Copy.hadithMapTopicShapes,
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                for (final shape in HadithMapFamily.values)
                  _LegendItem(
                    mark: HadithMapMarkIcon(
                      family: shape,
                      fill: HadithMapFill.learning,
                      familyColor: family,
                    ),
                    label: Copy.hadithMapFamilyLabel(shape.name),
                  ),
              ],
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 6),
            Material(
              key: const Key('hadith-map-detail'),
              color: Color.alphaBlend(
                family.withValues(alpha: 0.12),
                scheme.surface,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            selected.item.topic,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: family,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          key: const Key('hadith-map-share'),
                          onPressed: () => _share(selected),
                          icon: const Icon(Icons.share_outlined, size: 16),
                          label: const Text(Copy.shareCitation),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    PracticeRemembranceCore(
                      contextText: '',
                      arabic: selected.item.arabic,
                      transliteration: selected.item.transliteration,
                      translation: selected.item.translation,
                      ink: scheme.onSurface,
                      showScriptControls: false,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected.item.source,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          key: const Key('hadith-map-status'),
                          onTap: () => _cycleFill(selected),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HadithMapMarkIcon(
                                  family: selected.family,
                                  fill: selected.fill,
                                  familyColor: family,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${Copy.hadithMapFillLabel(selected.fill.name)} · ${Copy.hadithMapFamilyLabel(selected.family.name)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          key: const Key('hadith-map-play'),
                          tooltip: _playing
                              ? Copy.pauseHadith
                              : Copy.playHadith,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _togglePlay(selected),
                          icon: Icon(
                            _playing
                                ? Icons.pause_circle_filled
                                : Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Material(
            color: wash,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
              child: CollapsingNoteTile(
                key: const Key('hadith-map-counts'),
                title: Copy.hadithMapCounts,
                expanded: _countsOpen,
                onExpansionChanged: (open) {
                  if (open == _countsOpen) return;
                  setState(() => _countsOpen = open);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _CountTable(
                        caption: Copy.hadithMapByTopic,
                        labelFlex: 3.4,
                        headers: const ['Type', 'n'],
                        rows: [
                          for (final shape in HadithMapFamily.values)
                            [
                              Copy.hadithMapFamilyLabel(shape.name),
                              '${stats.byFamily[shape] ?? 0}',
                            ],
                          ['Total', '${stats.total}'],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 3,
                      child: _CountTable(
                        caption: Copy.hadithMapMetHistory,
                        labelFlex: 2.4,
                        headers: const ['State', 'n'],
                        rows: [
                          for (final fill in HadithMapFill.values)
                            [
                              Copy.hadithMapFillLabel(fill.name),
                              '${stats.byFill[fill] ?? 0}',
                            ],
                          ['Total', '${stats.total}'],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 3,
                      child: _CountTable(
                        caption:
                            '${Copy.hadithMapThisPeriod} (${_period == HadithMapPeriod.month ? Copy.hadithMapMonth : Copy.hadithMapWeek})',
                        labelFlex: 2.4,
                        headers: const ['State', 'n'],
                        onTogglePeriod: () {
                          setState(() {
                            _period = _period == HadithMapPeriod.week
                                ? HadithMapPeriod.month
                                : HadithMapPeriod.week;
                          });
                        },
                        rows: [
                          for (final fill in HadithMapFill.values)
                            [
                              Copy.hadithMapFillLabel(fill.name),
                              _periodCell(stats.periodByFill[fill] ?? 0, fill),
                            ],
                          [
                            'Total',
                            stats.periodTotal == 0
                                ? '0'
                                : '+${stats.periodTotal}',
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  HadithMapMark? _markFor(List<HadithMapMark> marks, String? id) {
    if (id == null) return null;
    for (final mark in marks) {
      if (mark.id == id) return mark;
    }
    return null;
  }

  Future<void> _share(HadithMapMark mark) async {
    final accepted = await ref.read(hadithTextShareProvider)(
      subject: mark.item.topic,
      text: hadithShareBody(mark.item),
    );
    if (!accepted || !mounted) return;
    final todayKey = dateKey(ref.read(nowProvider));
    final records =
        ref.read(practiceHadithProvider).value ??
        const <PracticeHadithRecord>[];
    final existing = practiceHadithForCatalog(records, mark.id);
    final next = existing == null
        ? recordAfterShare(
            recordFromCatalog(
              item: mark.item,
              id: newOpaqueId(),
              addedDateKey: todayKey,
            ),
            todayKey,
          )
        : recordAfterShare(existing, todayKey);
    await ref.read(practiceHadithProvider.notifier).save(next);
  }

  Future<void> _cycleFill(HadithMapMark mark) async {
    final todayKey = dateKey(ref.read(nowProvider));
    final records =
        ref.read(practiceHadithProvider).value ??
        const <PracticeHadithRecord>[];
    final existing = practiceHadithForCatalog(records, mark.id);
    final canShare = existing?.sharedDateKeys.isNotEmpty ?? false;
    final nextFill = nextHadithMapFill(mark.fill, canShare: canShare);
    if (nextFill == mark.fill) return;
    if (existing == null && nextFill == HadithMapFill.notMet) return;
    final base =
        existing ??
        recordFromCatalog(
          item: mark.item,
          id: newOpaqueId(),
          addedDateKey: todayKey,
        );
    await ref
        .read(practiceHadithProvider.notifier)
        .save(
          base.copyWith(
            status: statusForMapFill(nextFill),
            mapFillId: nextFill.name,
          ),
        );
  }

  Future<void> _togglePlay(HadithMapMark mark) async {
    final HadithSpeech speech = ref.read(hadithSpeechProvider);
    _speech = speech;
    if (_playing) {
      await speech.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final text = hadithSpeechText(mark.item, arabic: arabic);
    if (text.isEmpty) return;
    setState(() => _playing = true);
    final started = await speech.speak(
      text: text,
      languageCode: hadithSpeechLanguageCode(arabic: arabic),
      onComplete: () {
        if (mounted) setState(() => _playing = false);
      },
    );
    if (!started && mounted) {
      setState(() => _playing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Copy.hadithPlayCouldNotStart)),
      );
    }
  }

  String _periodCell(int n, HadithMapFill fill) {
    if (fill == HadithMapFill.notMet || n == 0) return '0';
    return '+$n';
  }
}

class _LegendBox extends StatelessWidget {
  const _LegendBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.mark, required this.label});

  final Widget mark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _CountTable extends StatelessWidget {
  const _CountTable({
    required this.caption,
    required this.headers,
    required this.rows,
    this.labelFlex = 2.4,
    this.onTogglePeriod,
  });

  final String caption;
  final List<String> headers;
  final List<List<String>> rows;
  final double labelFlex;
  final VoidCallback? onTogglePeriod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final family = domainColorIdentity(MonitorDomain.hadith).familyFor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        onTogglePeriod == null
            ? Text(
                caption.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.4,
                  color: scheme.onSurfaceVariant,
                ),
              )
            : InkWell(
                key: const Key('hadith-map-period-toggle'),
                onTap: onTogglePeriod,
                child: Text(
                  caption.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                    color: family,
                  ),
                ),
              ),
        const SizedBox(height: 4),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FlexColumnWidth(labelFlex),
            1: const FlexColumnWidth(0.8),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  family.withValues(alpha: 0.14),
                  scheme.surface,
                ),
              ),
              children: [
                for (var i = 0; i < headers.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      headers[i],
                      textAlign: i == 0 ? TextAlign.left : TextAlign.right,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: family,
                      ),
                    ),
                  ),
              ],
            ),
            for (var r = 0; r < rows.length; r++)
              TableRow(
                decoration: r == rows.length - 1
                    ? BoxDecoration(
                        color: Color.alphaBlend(
                          family.withValues(alpha: 0.14),
                          scheme.surface,
                        ),
                      )
                    : null,
                children: [
                  for (var c = 0; c < rows[r].length; c++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      child: Text(
                        rows[r][c],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        textAlign: c == 0 ? TextAlign.left : TextAlign.right,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: r == rows.length - 1
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class HadithMapMarkIcon extends StatelessWidget {
  const HadithMapMarkIcon({
    super.key,
    required this.family,
    required this.fill,
    required this.familyColor,
    this.size = 18,
  });

  final HadithMapFamily family;
  final HadithMapFill fill;
  final Color familyColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HadithMapMarkPainter(
        family: family,
        fill: fill,
        familyColor: familyColor,
        surface: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

class HadithMapMarkPainter extends CustomPainter {
  const HadithMapMarkPainter({
    required this.family,
    required this.fill,
    required this.familyColor,
    required this.surface,
  });

  final HadithMapFamily family;
  final HadithMapFill fill;
  final Color familyColor;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 18, size.height / 18);
    final path = _shapePath(family);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _fillColor();
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = fill == HadithMapFill.recentlyFetched
          ? const Color(0xFFC9A65A)
          : familyColor
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, fillPaint);
    if (fill == HadithMapFill.notMet) {
      _drawDashed(canvas, path, stroke);
    } else {
      canvas.drawPath(path, stroke);
    }
    if (fill == HadithMapFill.shared) {
      final tick = Path()
        ..moveTo(6.2, 9.2)
        ..lineTo(8.1, 11.2)
        ..lineTo(12.1, 6.8);
      canvas.drawPath(
        tick,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = surface,
      );
    }
    canvas.restore();
  }

  Color _fillColor() {
    return switch (fill) {
      HadithMapFill.recentlyFetched => const Color(0xFFF6E3A1),
      HadithMapFill.notMet => surface,
      HadithMapFill.learning => Color.alphaBlend(
        familyColor.withValues(alpha: 0.5),
        surface,
      ),
      HadithMapFill.shared => Color.alphaBlend(
        familyColor.withValues(alpha: 0.82),
        surface,
      ),
      HadithMapFill.living => familyColor,
    };
  }

  Path _shapePath(HadithMapFamily family) {
    return switch (family) {
      HadithMapFamily.prayer =>
        Path()
          ..addRRect(RRect.fromLTRBR(2, 2, 16, 16, const Radius.circular(2))),
      HadithMapFamily.fasting =>
        Path()
          ..moveTo(9, 1.5)
          ..lineTo(16.5, 9)
          ..lineTo(9, 16.5)
          ..lineTo(1.5, 9)
          ..close(),
      HadithMapFamily.dhikr =>
        Path()
          ..moveTo(9, 1.6)
          ..lineTo(15.4, 5.2)
          ..lineTo(15.4, 12.8)
          ..lineTo(9, 16.4)
          ..lineTo(2.6, 12.8)
          ..lineTo(2.6, 5.2)
          ..close(),
      HadithMapFamily.character =>
        Path()..addOval(Rect.fromCircle(center: const Offset(9, 9), radius: 7)),
      HadithMapFamily.family =>
        Path()
          ..moveTo(9, 1.8)
          ..lineTo(16.2, 7.1)
          ..lineTo(13.4, 16)
          ..lineTo(4.6, 16)
          ..lineTo(1.8, 7.1)
          ..close(),
      HadithMapFamily.knowledge =>
        Path()
          ..moveTo(9, 2)
          ..lineTo(16, 15.5)
          ..lineTo(2, 15.5)
          ..close(),
      HadithMapFamily.travel =>
        Path()..addRRect(
          RRect.fromLTRBR(1.5, 5, 16.5, 13, const Radius.circular(4)),
        ),
      HadithMapFamily.daily =>
        Path()..addRRect(
          RRect.fromLTRBR(2, 3.5, 16, 14.5, const Radius.circular(5)),
        ),
      HadithMapFamily.charity =>
        Path()
          ..moveTo(9, 1.4)
          ..lineTo(11.2, 6.6)
          ..lineTo(16.8, 6.8)
          ..lineTo(12.4, 10.4)
          ..lineTo(14, 16)
          ..lineTo(9, 12.8)
          ..lineTo(4, 16)
          ..lineTo(5.6, 10.4)
          ..lineTo(1.2, 6.8)
          ..lineTo(6.8, 6.6)
          ..close(),
    };
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + 2).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant HadithMapMarkPainter oldDelegate) {
    return oldDelegate.family != family ||
        oldDelegate.fill != fill ||
        oldDelegate.familyColor != familyColor ||
        oldDelegate.surface != surface;
  }
}
