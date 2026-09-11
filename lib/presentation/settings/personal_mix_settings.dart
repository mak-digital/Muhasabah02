import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_mix.dart';

class PersonalMixEditor extends ConsumerWidget {
  const PersonalMixEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final mix = prefs.personalMix;
    final visible = prefs.visibleDomains;
    final shown = [
      for (final domain in MonitorDomain.values)
        if (visible.contains(domain)) domain,
    ];
    final hidden = [
      for (final domain in MonitorDomain.values)
        if (!visible.contains(domain)) domain,
    ];

    Future<void> save(PersonalMix next) async {
      await prefs.setPersonalMix(next);
      ref.read(prefsTickProvider.notifier).state++;
      if (!context.mounted) return;
      await _maybeShowHiddenMixHint(
        context: context,
        ref: ref,
        mix: next,
        visible: visible,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Copy.personalMixNote,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          Copy.personalMixShortListNote,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in PersonalMixKind.values)
              FilterChip(
                label: Text(kind.label),
                selected: mix.kind == kind,
                onSelected: (_) async {
                  if (kind == PersonalMixKind.custom) {
                    await save(
                      mixForKind(
                        PersonalMixKind.custom,
                        customKeys: editableMixKeys(mix, visible),
                      ),
                    );
                  } else {
                    await save(mixForKind(kind));
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final domain in shown)
          _DomainMixTile(domain: domain, mix: mix, onSave: save),
        if (hidden.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            Copy.mixNotShownInDomains,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            Copy.mixNotShownNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final domain in hidden)
            _DomainMixTile(domain: domain, mix: mix, onSave: save),
        ],
      ],
    );
  }
}

Future<void> _maybeShowHiddenMixHint({
  required BuildContext context,
  required WidgetRef ref,
  required PersonalMix mix,
  required Set<MonitorDomain> visible,
}) async {
  final hidden = hiddenDomainsInMix(mix, visible);
  if (hidden.isEmpty) return;
  final prefs = ref.read(appPrefsProvider);
  if (prefs.mixHiddenDomainHintShown) return;
  await prefs.setMixHiddenDomainHintShown(true);
  ref.read(prefsTickProvider.notifier).state++;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (hidden.length == 1) {
    final domain = hidden.first;
    messenger.showSnackBar(
      SnackBar(
        content: Text(Copy.mixKeptUntilDomainShown(domain.label)),
        action: SnackBarAction(
          label: Copy.showDomainAction(domain.label),
          onPressed: () async {
            final next = {...prefs.visibleDomains, domain};
            await prefs.setVisibleDomains(next);
            ref.read(prefsTickProvider.notifier).state++;
          },
        ),
      ),
    );
    return;
  }
  messenger.showSnackBar(
    const SnackBar(content: Text(Copy.mixKeptUntilDomainsShown)),
  );
}

class _DomainMixTile extends ConsumerWidget {
  const _DomainMixTile({
    required this.domain,
    required this.mix,
    required this.onSave,
  });

  final MonitorDomain domain;
  final PersonalMix mix;
  final Future<void> Function(PersonalMix next) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(appPrefsProvider).visibleDomains;
    final selected = editableMixKeys(mix, visible);
    final items = [
      for (final item in mixCatalog)
        if (item.domain == domain) item,
    ];
    final selectedCount = items
        .where((item) => selected.contains(item.id))
        .length;
    final value = selectedCount == 0
        ? false
        : selectedCount == items.length
        ? true
        : null;
    final bands = <String>[];
    for (final item in items) {
      if (!bands.contains(item.band)) bands.add(item.band);
    }
    final shown = visible.contains(domain);

    return Card(
      key: Key('mix-domain-${domain.name}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(domain.label),
        subtitle: Text(
          shown
              ? '$selectedCount of ${items.length} in the mix'
              : Copy.mixDomainOffHome,
        ),
        leading: Checkbox(
          tristate: true,
          value: value,
          onChanged: (_) async {
            final next = {...selected};
            if (selectedCount == items.length) {
              next.removeAll(items.map((item) => item.id));
            } else {
              next.addAll(items.map((item) => item.id));
            }
            await onSave(mixForKind(PersonalMixKind.custom, customKeys: next));
          },
        ),
        children: [
          for (final band in bands) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                band.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w600),
              ),
            ),
            for (final item in items)
              if (item.band == band)
                CheckboxListTile(
                  dense: true,
                  title: Text(item.label),
                  value: selected.contains(item.id),
                  onChanged: (checked) async {
                    final next = {...selected};
                    if (checked == true) {
                      next.add(item.id);
                    } else {
                      next.remove(item.id);
                    }
                    await onSave(
                      mixForKind(PersonalMixKind.custom, customKeys: next),
                    );
                  },
                ),
          ],
        ],
      ),
    );
  }
}
