import 'hajj_online_assist.dart';
import 'hajj_planning.dart';
import 'hajj_source_worker.dart';

const kHajjAiDisabled = 'AI is not enabled.';
const kHajjLiveNotConfigured =
    'Live official lookup is not configured. Demonstration records stay on this phone.';

const kHajjLiveBaseUrl = String.fromEnvironment('HAJJ_LIVE_BASE_URL');

bool get hajjLiveLookupConfigured => kHajjLiveBaseUrl.trim().isNotEmpty;

class LiveHajjOnlineAssistGateway implements HajjOnlineAssistGateway {
  const LiveHajjOnlineAssistGateway({required this.send});

  /// Posts the minimum payload and returns the Worker JSON map.
  final Future<Map<String, Object?>> Function(HajjLookupRequest request) send;

  factory LiveHajjOnlineAssistGateway.local(HajjSourceWorker worker) {
    return LiveHajjOnlineAssistGateway(
      send: (request) {
        return worker.handle(
          body: request.toPayload(),
          clientKey: 'local-test',
          now: DateTime.now().toUtc(),
        );
      },
    );
  }

  @override
  Future<HajjLookupBundle> lookupOfficial(HajjLookupRequest request) async {
    if (!hajjOnlinePayloadIsSafe(request.toPayload())) {
      throw HajjOnlineAssistException('Request contained private fields.');
    }
    try {
      final json = await send(request);
      return bundleFromWorkerJson(json);
    } on HajjWorkerException catch (error) {
      throw HajjOnlineAssistException(error.message);
    }
  }

  @override
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
  }) async {
    throw HajjOnlineAssistException(kHajjAiDisabled);
  }
}

HajjLookupBundle bundleFromWorkerJson(Map<String, Object?> json) {
  final rawSources = json['sources'];
  final sources = <HajjOfficialSource>[
    if (rawSources is List)
      for (final item in rawSources)
        if (item is Map)
          HajjOfficialSource.fromJson(Map<String, dynamic>.from(item)),
  ];
  final conflicts = json['conflicts'];
  final conflictText = conflicts is List && conflicts.isNotEmpty
      ? conflicts.join(' ')
      : null;
  return HajjLookupBundle(
    sources: sources,
    providers: const [],
    unavailable: json['unavailable'] == true,
    message: conflictText ?? json['message'] as String? ?? kHajjLiveNotVerified,
  );
}

class SelectableHajjOnlineAssistGateway implements HajjOnlineAssistGateway {
  const SelectableHajjOnlineAssistGateway({required this.demo, this.live});

  final DemoHajjOnlineAssistGateway demo;
  final LiveHajjOnlineAssistGateway? live;

  bool get usesLive => live != null;

  @override
  Future<HajjLookupBundle> lookupOfficial(HajjLookupRequest request) {
    final gateway = live;
    if (gateway == null) return demo.lookupOfficial(request);
    return gateway.lookupOfficial(request);
  }

  @override
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
  }) {
    if (live != null) {
      return live!.interpret(request: request, todayKey: todayKey);
    }
    return demo.interpret(request: request, todayKey: todayKey);
  }
}
