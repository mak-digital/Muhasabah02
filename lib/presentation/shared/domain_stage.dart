import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import 'domain_visual.dart';
import 'week_nav_strip.dart';

class DomainStage extends ConsumerWidget {
  const DomainStage({
    super.key,
    required this.domains,
    required this.cardFor,
    required this.stageProvider,
    required this.keyPrefix,
    required this.pillsNote,
    this.aboveCard = const [],
    this.belowCard = const [],
    this.fillViewport = false,
    this.padding = EdgeInsets.zero,
  });

  final List<MonitorDomain> domains;
  final Widget Function(MonitorDomain domain) cardFor;
  final StateProvider<MonitorDomain?> stageProvider;
  final String keyPrefix;
  final String pillsNote;
  final List<Widget> aboveCard;
  final List<Widget> belowCard;
  final bool fillViewport;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (domains.isEmpty) {
      final leftover = [...aboveCard, ...belowCard];
      if (leftover.isEmpty) return const SizedBox.shrink();
      if (fillViewport) {
        return Padding(
          padding: padding,
          child: ListView(children: leftover),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: leftover,
      );
    }
    final remembered = ref.watch(stageProvider);
    final index = homeDomainStageIndex(domains, remembered);
    final domain = domains[index];
    final showChrome = domains.length > 1;
    final card = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: showChrome
          ? (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -200) {
                _select(ref, index + 1);
              } else if (velocity > 200) {
                _select(ref, index - 1);
              }
            }
          : null,
      child: KeyedSubtree(
        key: Key('$keyPrefix-card-${domain.id}'),
        child: cardFor(domain),
      ),
    );
    final header = showChrome
        ? <Widget>[
            _chrome(context, ref, index: index),
            const SizedBox(height: 6),
            _pills(context, ref, index: index),
            const SizedBox(height: 8),
          ]
        : const <Widget>[];
    if (fillViewport) {
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...header,
            Expanded(
              child: ListView(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  ...aboveCard,
                  card,
                  ...belowCard,
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...header,
        ...aboveCard,
        card,
        ...belowCard,
      ],
    );
  }

  void _select(WidgetRef ref, int index) {
    if (index < 0 || index >= domains.length) return;
    ref.read(stageProvider.notifier).state = domains[index];
  }

  Widget _chrome(
    BuildContext context,
    WidgetRef ref, {
    required int index,
  }) {
    final previous = index > 0 ? domains[index - 1] : null;
    final next = index < domains.length - 1 ? domains[index + 1] : null;
    final identity = domainColorIdentity(domains[index]);
    final theme = Theme.of(context);
    return WeekNavStrip(
      label: domains[index].shortLabel,
      prominentLabel: true,
      labelKey: Key('$keyPrefix-current'),
      family: identity.family,
      wash: weekNavStripWash(
        identity.family,
        identity.washFor(theme.brightness),
      ),
      previousKey: Key('$keyPrefix-prev'),
      nextKey: Key('$keyPrefix-next'),
      previousEnabled: previous != null,
      nextEnabled: next != null,
      previousTooltip: previous == null
          ? Copy.noPreviousDomain
          : Copy.previousDomain(previous.shortLabel),
      nextTooltip: next == null
          ? Copy.noNextDomain
          : Copy.nextDomain(next.shortLabel),
      onPrevious: () => _select(ref, index - 1),
      onNext: () => _select(ref, index + 1),
    );
  }

  Widget _pills(
    BuildContext context,
    WidgetRef ref, {
    required int index,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: pillsNote,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < domains.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                key: Key('$keyPrefix-pill-${domains[i].id}'),
                customBorder: const StadiumBorder(),
                onTap: () => _select(ref, i),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: i == index ? 16 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == index
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
