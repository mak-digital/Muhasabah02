import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/copy.dart';
import 'app_language_scope.dart';

Color weekNavStripWash(Color family, Color cardWash, [BuildContext? context]) {
  final ink = MuhasabahWashTheme.harmonizeFamilyOf(context, family);
  return Color.alphaBlend(ink.withValues(alpha: 0.22), cardWash);
}

/// Stronger shade of the same family, used only on band headings.
Color bandHeadingWash(Color family, Color base, [BuildContext? context]) {
  final ink = MuhasabahWashTheme.harmonizeFamilyOf(context, family);
  return Color.alphaBlend(ink.withValues(alpha: 0.32), base);
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
    this.leading,
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
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final family = MuhasabahWashTheme.harmonizeFamilyOf(context, this.family);
    final labelStyle =
        (prominentLabel
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleMedium)
            ?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.15,
              height: 1.1,
              fontSize: prominentLabel
                  ? (compact ? 16 : 20)
                  : compact
                  ? 13
                  : 15,
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
    var center = subtitleText == null
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
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  fontSize: compact ? 10.5 : 12,
                  color: family.withValues(alpha: 0.82),
                ),
              ),
            ],
          );
    final mark = leading;
    if (mark != null) {
      center = Row(
        mainAxisSize: MainAxisSize.min,
        children: [mark, const SizedBox(width: 8), center],
      );
    }
    final row = SizedBox(
      height: compact
          ? (subtitleText != null ? 44 : 34)
          : subtitleText != null
          ? 52
          : maxLines > 1
          ? 48
          : 40,
      child: Row(
        children: [
          _chevron(
            key: previousKey,
            icon: Icons.chevron_left_rounded,
            tooltip: previousTooltip,
            family: family,
            onPressed: previousEnabled ? onPrevious : null,
          ),
          Expanded(
            child: onLabelTap == null
                ? Center(
                    child: FittedBox(fit: BoxFit.scaleDown, child: center),
                  )
                : InkWell(
                    onTap: onLabelTap,
                    child: Center(
                      child: FittedBox(fit: BoxFit.scaleDown, child: center),
                    ),
                  ),
          ),
          _chevron(
            key: nextKey,
            icon: Icons.chevron_right_rounded,
            tooltip: nextTooltip,
            family: family,
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
    required Color family,
    required VoidCallback? onPressed,
  }) {
    final size = compact ? 32.0 : 40.0;
    final iconSize = compact ? 20.0 : 24.0;
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
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final family = MuhasabahWashTheme.harmonizeFamilyOf(context, this.family);
    final titleBlock = Column(
      children: [
        Text(
          uiText(context, title),
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
            uiText(context, question!),
            textAlign: TextAlign.center,
            maxLines: 4,
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
        const SizedBox(height: 6),
        WeekNavStrip(
          label: weekLabel,
          family: this.family,
          wash: weekNavStripWash(this.family, cardWash, context),
          onPrevious: onPreviousWeek,
          onNext: onNextWeek,
          nextEnabled: nextWeekEnabled,
          compact: true,
          maxLines: 1,
        ),
      ],
    );
  }
}

/// Sits in the weekday-header gutter so “Current week” does not steal a row.
class CurrentWeekGutter extends StatelessWidget {
  const CurrentWeekGutter({
    super.key,
    required this.width,
    required this.family,
    required this.cardWash,
    required this.enabled,
    required this.onPressed,
  });

  final double width;
  final Color family;
  final Color cardWash;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final family = MuhasabahWashTheme.harmonizeFamilyOf(context, this.family);
    final ink = enabled ? family : family.withValues(alpha: 0.45);
    return SizedBox(
      width: width,
      height: 36,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Material(
          color: weekNavStripWash(this.family, cardWash, context),
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          child: GestureDetector(
            onTap: enabled ? onPressed : null,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  Copy.currentWeek,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    fontSize: 10,
                    color: ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
