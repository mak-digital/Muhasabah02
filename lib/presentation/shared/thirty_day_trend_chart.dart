import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/activities.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/quran_duration.dart';
import '../../domain/thirty_day_trend.dart';
import 'salah_activity_mark.dart';

class ThirtyDayTrendOption {
  const ThirtyDayTrendOption({
    required this.id,
    required this.label,
    required this.color,
    this.stripe = false,
  });

  final String id;
  final String label;
  final Color color;
  final bool stripe;
}

class ThirtyDayTrendSeries {
  const ThirtyDayTrendSeries({
    required this.activityLabel,
    required this.catalog,
    required this.idForDate,
    this.hitsForDate,
    this.dayAnswered,
  });

  final String activityLabel;
  final List<ThirtyDayTrendOption> catalog;
  final String? Function(String dateKey) idForDate;
  final Iterable<String> Function(String dateKey)? hitsForDate;
  final bool Function(String dateKey)? dayAnswered;

  List<String> get optionIds => [for (final option in catalog) option.id];

  ThirtyDayTrendOption? optionById(String id) {
    for (final option in catalog) {
      if (option.id == id) return option;
    }
    return null;
  }
}

ThirtyDayTrendSeries? thirtyDaySeriesOrNull({
  required int periodDays,
  required String activityLabel,
  required List<ActivityOption> catalog,
  required String? Function(String dateKey) idForDate,
  required bool activityColours,
  Iterable<String> Function(String dateKey)? hitsForDate,
  bool Function(String dateKey)? dayAnswered,
}) {
  if (periodDays != 30) return null;
  if (chartableCatalog(catalog).isEmpty) return null;
  return seriesFromActivityCatalog(
    activityLabel: activityLabel,
    catalog: catalog,
    idForDate: idForDate,
    activityColours: activityColours,
    hitsForDate: hitsForDate,
    dayAnswered: dayAnswered,
  );
}

const _dhikrTrendPalette = <Color>[
  Color(0xFF3F7D6A),
  Color(0xFF2F6F73),
  Color(0xFF4F7C6B),
  Color(0xFF8A7048),
  Color(0xFF5C6E7A),
];

ThirtyDayTrendSeries seriesFromActivityCatalog({
  required String activityLabel,
  required List<ActivityOption> catalog,
  required String? Function(String dateKey) idForDate,
  required bool activityColours,
  Iterable<String> Function(String dateKey)? hitsForDate,
  bool Function(String dateKey)? dayAnswered,
}) {
  final usable = chartableCatalog(catalog);
  final seen = <int>{};
  final options = <ThirtyDayTrendOption>[];
  for (var i = 0; i < usable.length; i++) {
    final option = usable[i];
    var color = activityColours
        ? SalahActivityMark.colourForId(option.id)
        : MuhasabahColors.mark;
    if (activityColours && color == MuhasabahColors.mark) {
      color = _dhikrTrendPalette[i % _dhikrTrendPalette.length];
    }
    final value = color.toARGB32();
    final stripe = activityColours
        ? seen.contains(value)
        : option.id == 'excused' || option.id == QuranDurationIds.min3to5;
    seen.add(value);
    options.add(
      ThirtyDayTrendOption(
        id: option.id,
        label: option.label,
        color: color,
        stripe: stripe,
      ),
    );
  }
  return ThirtyDayTrendSeries(
    activityLabel: activityLabel,
    catalog: options,
    idForDate: idForDate,
    hitsForDate: hitsForDate,
    dayAnswered: dayAnswered,
  );
}

class ThirtyDayTrendChart extends StatefulWidget {
  const ThirtyDayTrendChart({
    super.key,
    required this.series,
    required this.windows,
    required this.selectedIds,
    required this.calendar,
    this.anchorKey,
    this.washLink,
  });

  final ThirtyDayTrendSeries series;
  final List<TrendWindowStats> windows;
  final List<String> selectedIds;
  final DisplayCalendar calendar;
  final GlobalKey? anchorKey;
  final LayerLink? washLink;

  @override
  State<ThirtyDayTrendChart> createState() => _ThirtyDayTrendChartState();
}

class _TipSpec {
  const _TipSpec({
    required this.option,
    required this.letter,
    required this.window,
    required this.activityLabel,
    required this.calendar,
  });

  final ThirtyDayTrendOption option;
  final String letter;
  final TrendWindowStats window;
  final String activityLabel;
  final DisplayCalendar calendar;
}

/// Logical pixels for one millimetre (1 dp = 1/160 inch).
const _mm = 160 / 25.4;

class _ThirtyDayTrendChartState extends State<ThirtyDayTrendChart> {
  final _portal = OverlayPortalController();
  final _floatKey = GlobalKey();
  _TipSpec? _tip;
  Offset _drag = Offset.zero;

  @override
  void dispose() {
    if (_portal.isShowing) _portal.hide();
    super.dispose();
  }

  void _hideTip() {
    _tip = null;
    _drag = Offset.zero;
    if (_portal.isShowing) _portal.hide();
  }

  Offset _followOffset() => Offset(5 * _mm, 10 * _mm) + _drag;

  void _showTip(_TipSpec spec) {
    setState(() => _tip = spec);
    if (!_portal.isShowing) _portal.show();
  }

  Widget _line(String text, {bool bold = false}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontSize: 10,
          height: 1.15,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFloating(BuildContext overlayContext) {
    final spec = _tip;
    if (spec == null) return const SizedBox.shrink();
    final hits = spec.window.countFor(spec.option.id);
    final percent = trendPercent(hits, spec.window.denom);
    final theme = Theme.of(overlayContext);
    final card = KeyedSubtree(
      key: const Key('trend-float-tip'),
      child: Material(
        key: _floatKey,
        elevation: 0,
        color: Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.06),
          theme.colorScheme.surface.withValues(alpha: 0.42),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 4, 2, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() => _drag += details.delta);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(top: 3, right: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: spec.option.stripe
                                ? null
                                : spec.option.color,
                            border: Border.all(
                              color: spec.option.stripe
                                  ? const Color(0xFF9AA318)
                                  : spec.option.color,
                            ),
                            gradient: spec.option.stripe
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFC0CA33),
                                      Color(0xFFF4F7D4),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _line(
                                compactChoiceLabel(
                                  spec.option.label,
                                  activityLabel: spec.activityLabel,
                                  stripCatalogRowName: true,
                                  optionId: spec.option.id,
                                ),
                                bold: true,
                              ),
                              _line(
                                'Period ${spec.letter} (${formatDayMonthYear(parseDateKey(spec.window.startKey), spec.calendar)}–${formatDayMonthYear(parseDateKey(spec.window.endKey), spec.calendar)})',
                              ),
                              _line(
                                compactTrendRecordedLine(
                                  hits: hits,
                                  denom: spec.window.denom,
                                  percent: percent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('trend-tip-close'),
                  onPressed: _hideTip,
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, size: 14),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final link = widget.washLink;
    if (link == null) {
      return Positioned(left: 24, top: 72, child: card);
    }
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.bottomRight,
        offset: _followOffset(),
        child: card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedIds.isEmpty) {
      return Text(
        'No answered days to compare',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(fontSize: 11, height: 1.35),
      );
    }
    const letters = ['A', 'B', 'C'];
    final chart = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final id in widget.selectedIds)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < widget.windows.length; i++)
                          Expanded(
                            child: _TrendBar(
                              option: widget.series.optionById(id)!,
                              letter: letters[i],
                              window: widget.windows[i],
                              activityLabel: widget.series.activityLabel,
                              calendar: widget.calendar,
                              onHover: _showTip,
                              onLeave: () {},
                              onTap: _showTip,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 11,
                    child: Row(
                      children: [
                        for (final letter in letters)
                          Expanded(
                            child: Text(
                              letter,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 8,
                                    height: 1,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildFloating,
      child: chart,
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({
    required this.option,
    required this.letter,
    required this.window,
    required this.activityLabel,
    required this.calendar,
    required this.onHover,
    required this.onLeave,
    required this.onTap,
  });

  final ThirtyDayTrendOption option;
  final String letter;
  final TrendWindowStats window;
  final String activityLabel;
  final DisplayCalendar calendar;
  final ValueChanged<_TipSpec> onHover;
  final VoidCallback onLeave;
  final ValueChanged<_TipSpec> onTap;

  @override
  Widget build(BuildContext context) {
    final hits = window.countFor(option.id);
    final percent = trendPercent(hits, window.denom);
    final range =
        '${formatDayMonthYear(parseDateKey(window.startKey), calendar)}–${formatDayMonthYear(parseDateKey(window.endKey), calendar)}';
    final recorded = compactTrendRecordedLine(
      hits: hits,
      denom: window.denom,
      percent: percent,
    );
    final spoken =
        '${option.label} ($activityLabel), Period $letter ($range), $recorded';
    final spec = _TipSpec(
      option: option,
      letter: letter,
      window: window,
      activityLabel: activityLabel,
      calendar: calendar,
    );
    return Semantics(
      button: true,
      label: spoken,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerHover: (_) => onHover(spec),
        child: MouseRegion(
          opaque: true,
          hitTestBehavior: HitTestBehavior.opaque,
          cursor: SystemMouseCursors.click,
          onEnter: (_) => onHover(spec),
          onExit: (_) => onLeave(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(spec),
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = constraints.maxHeight;
                    if (percent == null) {
                      return const SizedBox.expand();
                    }
                    final h = percent == 0 ? 2.0 : maxH * (percent / 100);
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 7,
                        height: h.clamp(2.0, maxH),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: option.color,
                            border: option.stripe
                                ? Border.all(
                                    color: const Color(0xFF9AA318),
                                    width: 1,
                                  )
                                : null,
                            gradient: option.stripe
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFC0CA33),
                                      Color(0xFFF4F7D4),
                                      Color(0xFFC0CA33),
                                      Color(0xFFF4F7D4),
                                    ],
                                    stops: [0, 0.25, 0.5, 0.75],
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
