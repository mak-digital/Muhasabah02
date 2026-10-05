import 'package:flutter/material.dart';

import '../../domain/copy.dart';

Color weekNavStripWash(Color family, Color cardWash) {
  return Color.alphaBlend(family.withValues(alpha: 0.22), cardWash);
}

class WeekNavStrip extends StatelessWidget {
  const WeekNavStrip({
    super.key,
    required this.label,
    required this.family,
    required this.wash,
    required this.onPrevious,
    required this.onNext,
    this.previousEnabled = true,
    this.nextEnabled = true,
    this.previousTooltip = 'Previous week',
    this.nextTooltip = 'Next week',
    this.previousKey,
    this.nextKey,
    this.labelKey,
    this.onLabelTap,
    this.maxLines = 2,
    this.prominentLabel = false,
    this.subtitle,
    this.subtitleMaxLines = 2,
    this.paintBackground = true,
    this.compact = false,
  });

  final String label;
  final Color family;
  final Color wash;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final bool previousEnabled;
  final bool nextEnabled;
  final String previousTooltip;
  final String nextTooltip;
  final Key? previousKey;
  final Key? nextKey;
  final Key? labelKey;
  final VoidCallback? onLabelTap;
  final int maxLines;
  final bool prominentLabel;
  final String? subtitle;
  final int subtitleMaxLines;
  final bool paintBackground;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = (prominentLabel
            ? theme.textTheme.titleLarge
            : theme.textTheme.titleMedium)
        ?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.15,
          height: 1.1,
          fontSize: prominentLabel
              ? 20
              : compact
              ? 14
              : 16,
          color: family,
        );
    final subtitleText = subtitle;
    final labelText = Text(
      label,
      key: labelKey,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: labelStyle,
    );
    final center = subtitleText == null
        ? labelText
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              labelText,
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  fontSize: compact ? 11 : null,
                  color: family.withValues(alpha: 0.88),
                ),
              ),
            ],
          );
    final row = SizedBox(
      height: compact
          ? (subtitleText != null ? 44 : 40)
          : subtitleText != null
          ? 64
          : maxLines > 1
          ? 56
          : 48,
      child: Row(
        children: [
          _chevron(
            key: previousKey,
            icon: Icons.chevron_left_rounded,
            tooltip: previousTooltip,
            onPressed: previousEnabled ? onPrevious : null,
          ),
          Expanded(
            child: onLabelTap == null
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: center,
                    ),
                  )
                : InkWell(
                    onTap: onLabelTap,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: center,
                      ),
                    ),
                  ),
          ),
          _chevron(
            key: nextKey,
            icon: Icons.chevron_right_rounded,
            tooltip: nextTooltip,
            onPressed: nextEnabled ? onNext : null,
          ),
        ],
      ),
    );
    if (!paintBackground) return row;
    return Material(
      color: wash,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: row,
    );
  }

  Widget _chevron({
    required Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final size = compact ? 36.0 : 44.0;
    final iconSize = compact ? 22.0 : 26.0;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        key: key,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
        style: IconButton.styleFrom(
          foregroundColor: family,
          disabledForegroundColor: family.withValues(alpha: 0.28),
          padding: EdgeInsets.zero,
          minimumSize: Size(size, size),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class HomeWeekChrome extends StatelessWidget {
  const HomeWeekChrome({
    super.key,
    required this.title,
    required this.family,
    required this.cardWash,
    required this.weekLabel,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.nextWeekEnabled,
    required this.showCurrentWeek,
    required this.onCurrentWeek,
    this.question,
    this.onTitleTap,
  });

  final String title;
  final String? question;
  final Color family;
  final Color cardWash;
  final String weekLabel;
  final VoidCallback onPreviousWeek;
  final VoidCallback? onNextWeek;
  final bool nextWeekEnabled;
  final bool showCurrentWeek;
  final VoidCallback onCurrentWeek;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleBlock = Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
            height: 1.2,
            fontSize: 18,
            color: family,
          ),
        ),
        if (question != null && question!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            question!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.3,
              color: Color.alphaBlend(
                family.withValues(alpha: 0.55),
                theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onTitleTap == null)
          titleBlock
        else
          InkWell(onTap: onTitleTap, child: titleBlock),
        const SizedBox(height: 8),
        WeekNavStrip(
          label: weekLabel,
          family: family,
          wash: weekNavStripWash(family, cardWash),
          onPrevious: onPreviousWeek,
          onNext: onNextWeek,
          nextEnabled: nextWeekEnabled,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: showCurrentWeek ? onCurrentWeek : null,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(Copy.currentWeek),
          ),
        ),
      ],
    );
  }
}
