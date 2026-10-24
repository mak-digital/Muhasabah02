import 'package:flutter/material.dart';

import 'brand_mark.dart';

/// Prose that fills a bounded text box evenly.
///
/// Uses justified wrapping only when the parent gives a finite width, so it
/// does not overflow in unbounded [Row]s or stretch short titles.
class BalancedProse extends StatelessWidget {
  const BalancedProse(this.data, {super.key, this.style, this.title = false});

  final String data;
  final TextStyle? style;
  final bool title;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: title ? TextAlign.start : TextAlign.justify,
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}

/// Outer wash for Hadith/Qur’an/Dhikr reading panes.
const kPracticeSkimBodyHeight = 196.0;
const kPracticeScriptPaneMinHeight = 104.0;

Color practiceReadingWash(BuildContext context, Color domainWash) {
  final scheme = Theme.of(context).colorScheme;
  return Color.alphaBlend(
    domainWash.withValues(alpha: 0.34),
    scheme.surfaceContainerHigh,
  );
}

/// Distinct inner pane for Arabic script so it does not sit on the page wash.
class PracticeScriptPane extends StatelessWidget {
  const PracticeScriptPane({
    super.key,
    required this.child,
    this.ink,
    this.wash,
  });

  final Widget child;
  final Color? ink;
  final Color? wash;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = wash ?? scheme.primaryContainer;
    final fill = Color.alphaBlend(tint.withValues(alpha: 0.78), scheme.surface);
    final edge = Color.alphaBlend(
      (ink ?? scheme.primary).withValues(alpha: 0.28),
      tint,
    );
    return Material(
      key: const Key('practice-script-pane'),
      color: fill,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: edge.withValues(alpha: 0.9)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: kPracticeScriptPaneMinHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
          child: Align(alignment: Alignment.centerRight, child: child),
        ),
      ),
    );
  }
}

class WashPanel extends StatelessWidget {
  const WashPanel({
    super.key,
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.clipBehavior = Clip.antiAlias,
  });

  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: clipBehavior,
      child: Padding(padding: padding, child: child),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandMark(size: 72),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: BalancedProse(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Intro copy on a Home wash. Starts open; the parent collapses it after input.
class CollapsingIntroNote extends StatelessWidget {
  const CollapsingIntroNote({
    super.key,
    required this.title,
    required this.note,
    required this.expanded,
    required this.onExpansionChanged,
  });

  final String title;
  final String note;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    return CollapsingNoteTile(
      title: title,
      expanded: expanded,
      onExpansionChanged: onExpansionChanged,
      child: BalancedProse(
        note,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
      ),
    );
  }
}

class CollapsingNoteTile extends StatelessWidget {
  const CollapsingNoteTile({
    super.key,
    required this.title,
    required this.expanded,
    required this.onExpansionChanged,
    required this.child,
  });

  final String title;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey<bool>(expanded),
        initiallyExpanded: expanded,
        dense: true,
        visualDensity: VisualDensity.compact,
        minTileHeight: 36,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 2),
        onExpansionChanged: onExpansionChanged,
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        children: [SizedBox(width: double.infinity, child: child)],
      ),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.days,
    required this.onChanged,
  });

  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final selector = Semantics(
      label: 'Period selector',
      child: SegmentedButton<int>(
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: const [
          ButtonSegment(value: 7, label: Text('7 days')),
          ButtonSegment(value: 30, label: Text('30 days')),
          ButtonSegment(value: 90, label: Text('90 days')),
        ],
        selected: {days},
        onSelectionChanged: (value) => onChanged(value.first),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: selector,
          ),
        );
      },
    );
  }
}
