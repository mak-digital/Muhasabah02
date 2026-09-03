import '../data/privacy_log.dart';
import '../data/repositories.dart';
import 'synthetic_check_ins.dart';

class SyntheticSeedResult {
  const SyntheticSeedResult({
    required this.written,
    required this.skippedUserOwned,
    required this.missingDays,
  });

  final int written;
  final int skippedUserOwned;
  final int missingDays;
}

class SyntheticCheckInSeeder {
  const SyntheticCheckInSeeder();

  Future<SyntheticSeedResult> generateInto(
    CheckInRepository repository, {
    required DateTime now,
    int seed = 20260903,
  }) async {
    final plan = generateSyntheticCheckIns(now: now, seed: seed);
    var written = 0;
    var skipped = 0;
    for (final record in plan.records) {
      final existing = await repository.getByDate(record.dateKey);
      if (existing != null && !existing.synthetic) {
        skipped++;
        continue;
      }
      await repository.save(record);
      written++;
    }
    logAppEvent('synthetic_checkins_generated');
    return SyntheticSeedResult(
      written: written,
      skippedUserOwned: skipped,
      missingDays: plan.missingDays,
    );
  }

  Future<int> clearFrom(CheckInRepository repository) async {
    final all = await repository.allHealthy();
    var removed = 0;
    for (final record in all) {
      if (!record.synthetic) continue;
      final ok = await repository.delete(record.dateKey);
      if (ok) removed++;
    }
    logAppEvent('synthetic_checkins_cleared');
    return removed;
  }
}
