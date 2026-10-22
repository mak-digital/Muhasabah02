import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/hajj_live_gateway.dart';
import '../../domain/hajj_online_assist.dart';
import '../../domain/hajj_online_contracts.dart';
import '../../domain/hajj_planning.dart';

class HajjOnlineAssistPanel extends ConsumerWidget {
  const HajjOnlineAssistPanel({super.key, required this.store});

  final HajjStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = store.onlineAssist;
    final style = Theme.of(context).textTheme.bodySmall;
    final open = store.pendingProposals.where((item) => !item.dismissed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Copy.hajjOnlineDefault, style: style),
        Text(
          !consent.lookupConsented
              ? Copy.hajjOfflineMode
              : hajjLiveLookupConfigured
              ? Copy.hajjLiveMode
              : Copy.hajjDemoNoLiveVerification,
          key: const Key('hajj-online-mode'),
          style: style,
        ),
        Text(
          hajjLiveLookupConfigured
              ? Copy.hajjLiveMode
              : kHajjOnlineNoLiveBackend,
          style: style,
        ),
        SwitchListTile(
          key: const Key('hajj-consent-lookup'),
          contentPadding: EdgeInsets.zero,
          title: const Text(Copy.hajjConsentLookup),
          value: consent.lookupConsented,
          onChanged: (value) => _setConsent(ref, lookup: value),
        ),
        SwitchListTile(
          key: const Key('hajj-consent-ai'),
          contentPadding: EdgeInsets.zero,
          title: const Text(Copy.hajjConsentAi),
          value: consent.aiConsented,
          onChanged: (value) => _setConsent(ref, ai: value),
        ),
        Text(Copy.hajjConsentBody, style: style),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              key: const Key('hajj-online-lookup'),
              onPressed: consent.lookupConsented
                  ? () => _runLookup(context, ref)
                  : null,
              child: const Text('Request official bookmarks'),
            ),
            OutlinedButton(
              key: const Key('hajj-online-ai'),
              onPressed: consent.aiConsented
                  ? () => _runAi(context, ref)
                  : null,
              child: const Text('Request interpretation'),
            ),
            OutlinedButton(
              key: const Key('hajj-source-manual'),
              onPressed: () => _openManualSource(context, ref),
              child: const Text('Add a source yourself'),
            ),
          ],
        ),
        for (final proposal in open) ...[
          ListTile(
            key: Key('hajj-proposal-${proposal.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(proposal.title, maxLines: 2),
            subtitle: Text(
              '${proposal.origin.label}. ${proposal.detail}',
              maxLines: 4,
            ),
            trailing: proposal.accepted
                ? const Text('Accepted')
                : TextButton(
                    key: Key('hajj-proposal-accept-${proposal.id}'),
                    onPressed: () => persistHajjStore(ref, (current) {
                      return const HajjProposedPlanChangeReviewer().accept(
                        current,
                        proposal,
                      );
                    }),
                    child: const Text('Accept'),
                  ),
          ),
          if (!proposal.accepted)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: Key('hajj-proposal-reject-${proposal.id}'),
                onPressed: () => persistHajjStore(ref, (current) {
                  return const HajjProposedPlanChangeReviewer().reject(
                    current,
                    proposal,
                  );
                }),
                child: const Text('Reject'),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _setConsent(WidgetRef ref, {bool? lookup, bool? ai}) async {
    final now = ref.read(nowProvider).toIso8601String();
    await persistHajjStore(ref, (current) {
      return current.copyWith(
        onlineAssist: const HajjConsentManager().apply(
          current: current.onlineAssist,
          lookup: lookup,
          ai: ai,
          nowIso: now,
        ),
      );
    });
  }

  Future<void> _runLookup(BuildContext context, WidgetRef ref) async {
    final store = ref.read(hajjStoreRepositoryProvider).store;
    final journey = store.selectedJourney;
    if (journey == null || !store.onlineAssist.lookupConsented) return;
    final request = buildHajjLookupRequest(
      journey: journey,
      travelers: store.travelers,
    );
    try {
      final bundle = await ref
          .read(hajjOnlineAssistGatewayProvider)
          .lookupOfficial(request);
      await persistHajjStore(ref, (current) {
        var next = current;
        for (final source in bundle.sources) {
          next = next.upsertSource(source);
        }
        for (final provider in bundle.providers) {
          next = next.upsertProvider(provider);
        }
        return next;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(bundle.message ?? kHajjOnlineNoLiveBackend)),
        );
      }
    } on HajjOnlineAssistException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _runAi(BuildContext context, WidgetRef ref) async {
    final store = ref.read(hajjStoreRepositoryProvider).store;
    final journey = store.selectedJourney;
    if (journey == null || !store.onlineAssist.aiConsented) return;
    final request = buildHajjLookupRequest(
      journey: journey,
      travelers: store.travelers,
    );
    try {
      final proposal = await ref
          .read(hajjOnlineAssistGatewayProvider)
          .interpret(
            request: request,
            todayKey: dateKey(ref.read(nowProvider)),
          );
      await persistHajjStore(ref, (current) {
        return current.copyWith(
          pendingProposals: [
            for (final item in current.pendingProposals)
              if (item.id != proposal.id) item,
            proposal,
          ],
        );
      });
    } on HajjOnlineAssistException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _openManualSource(BuildContext context, WidgetRef ref) async {
    final authority = TextEditingController();
    final uri = TextEditingController();
    final requirement = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Manual source. It stays Unverified until you say so.',
              ),
              TextField(
                key: const Key('hajj-source-authority'),
                controller: authority,
                decoration: const InputDecoration(
                  labelText: 'Issuing authority',
                ),
              ),
              TextField(
                controller: uri,
                decoration: const InputDecoration(labelText: 'Official URL'),
              ),
              TextField(
                controller: requirement,
                decoration: const InputDecoration(
                  labelText: 'Requirement or deadline note',
                ),
              ),
              FilledButton(
                key: const Key('hajj-source-save'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save as unverified'),
              ),
            ],
          ),
        );
      },
    );
    if (saved != true) return;
    final now = ref.read(nowProvider);
    await persistHajjStore(ref, (current) {
      return current.upsertSource(
        HajjOfficialSource(
          id: 'src.manual.${now.millisecondsSinceEpoch}',
          title: authority.text.trim().isEmpty
              ? 'Manual source'
              : authority.text.trim(),
          issuingAuthority: authority.text.trim().isEmpty
              ? null
              : authority.text.trim(),
          uri: uri.text.trim().isEmpty ? null : uri.text.trim(),
          requirementText: requirement.text.trim().isEmpty
              ? null
              : requirement.text.trim(),
          retrievedAt: dateKey(now),
          verificationStatus: HajjVerificationStatus.unverified,
          origin: HajjSourceOrigin.userEntered,
          provenance: HajjProvenanceKind.userEntered,
        ),
      );
    });
  }
}

class HajjSourcesBody extends ConsumerWidget {
  const HajjSourcesBody({super.key, required this.store});

  final HajjStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dateKey(ref.watch(nowProvider));
    final conflicts = hajjConflictingSourceDeadlines(store.sources);
    if (store.sources.isEmpty) {
      return Text(
        'No sources stored. Add a bookmark yourself, or opt in to the demonstration catalog.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final conflict in conflicts)
          Text(conflict, style: Theme.of(context).textTheme.bodySmall),
        for (final source in store.sources)
          ListTile(
            key: Key('hajj-source-${source.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(source.title ?? source.id, maxLines: 2),
            subtitle: Text(
              [
                hajjSourceStatusLabel(source, todayKey: today),
                source.origin.label,
                source.retrievalMode.label,
                if (source.issuingAuthority != null) source.issuingAuthority!,
                if (source.jurisdictionCountry != null)
                  source.jurisdictionCountry!,
                if (source.demonstration) kHajjDemoNoLiveVerification,
                if (source.limitations != null) source.limitations!,
              ].join(' · '),
              maxLines: 5,
            ),
            onTap: () => persistHajjStore(ref, (current) {
              final nextStatus =
                  source.verificationStatus ==
                      HajjVerificationStatus.verifiedByUser
                  ? HajjVerificationStatus.unverified
                  : HajjVerificationStatus.verifiedByUser;
              return current.upsertSource(
                source.copyWith(verificationStatus: nextStatus),
              );
            }),
          ),
      ],
    );
  }
}

class HajjProvidersBody extends StatelessWidget {
  const HajjProvidersBody({super.key, required this.store});

  final HajjStore store;

  @override
  Widget build(BuildContext context) {
    if (store.providers.isEmpty) {
      return Text(
        'No providers stored. Discovery is demonstration-only and never books.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      children: [
        for (final provider in store.providers)
          ListTile(
            key: Key('hajj-provider-${provider.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(provider.name ?? provider.id, maxLines: 2),
            subtitle: Text(
              [
                hajjProviderMayBeCalledAuthorized(provider)
                    ? 'Authorization evidence on file'
                    : 'Not labelled officially authorized',
                if (provider.independentReview != null)
                  'Review (separate): ${provider.independentReview}',
                if (provider.demonstration) kHajjDemoNoLiveVerification,
              ].join(' · '),
              maxLines: 5,
            ),
          ),
      ],
    );
  }
}
