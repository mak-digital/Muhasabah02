/// Cloudflare Workers **Free** plan ceilings used as the deployment target.
/// Sources: developers.cloudflare.com/workers/platform/limits and
/// developers.cloudflare.com/workers/platform/pricing (checked 2026-10-18).
///
/// These are **usage refusals**, not a USD spending cap. Staying on Free and
/// never enabling Workers Paid / Workers AI is what keeps the bill at USD 0.
library;

class HajjCloudflareFreePlan {
  const HajjCloudflareFreePlan();

  static const workerRequestsPerDay = 100000;
  static const cpuMsPerRequest = 10;
  static const kvReadsPerDay = 100000;
  static const kvWritesPerDay = 1000;
  static const kvSameKeyWritesPerSecond = 1;
  static const kvStorageGb = 1;
  static const subrequestsPerRequest = 50;
}

/// Application quotas. Sized so KV writes stay under the Free 1,000/day cap
/// with headroom for three daily cache refreshes.
class HajjWorkerQuotaConfig {
  const HajjWorkerQuotaConfig({
    this.perInstallDaily = 5,
    this.globalAcceptedDaily = 800,
    this.globalIncomingDaily = 20000,
    this.burstPerMinute = 5,
    this.originGetsPerAdapterDaily = 2,
    this.originGetsGlobalDaily = 8,
    this.cacheTtl = const Duration(hours: 24),
    this.fetchTimeout = const Duration(seconds: 8),
    this.maxBodyBytes = 8000,
  });

  /// Opaque installation / IP hint. Not an authenticated person.
  final int perInstallDaily;
  final int globalAcceptedDaily;
  final int globalIncomingDaily;
  final int burstPerMinute;
  final int originGetsPerAdapterDaily;
  final int originGetsGlobalDaily;
  final Duration cacheTtl;
  final Duration fetchTimeout;
  final int maxBodyBytes;

  static const freePlanDefaults = HajjWorkerQuotaConfig();
}

const kHajjQuotaUserMessage =
    'Live lookup has reached today’s limit for this installation. Official pages can still be opened by hand. Offline planning is unchanged.';

const kHajjQuotaGlobalMessage =
    'Live lookup has reached today’s shared limit. Try again after midnight UTC, or confirm sources by hand. Offline planning is unchanged.';

const kHajjQuotaBurstMessage =
    'Live lookup is temporarily limited. Wait a minute. Offline planning is unchanged.';

const kHajjFreePlanExhaustedMessage =
    'The Free-plan Worker limit was reached (Cloudflare error). Live lookup is paused until midnight UTC. Offline planning is unchanged.';
