import '../data/app_prefs.dart';
import '../data/privacy_log.dart';
import '../data/repositories.dart';
import 'synthetic_check_ins.dart';

class SyntheticSeedResult {
  const SyntheticSeedResult({
    required this.written,
    required this.skippedUserOwned,
    required this.missingDays,
    required this.responsesWritten,
  });

  final int written;
  final int skippedUserOwned;
  final int missingDays;
  final int responsesWritten;
}

class SyntheticCheckInSeeder {
  const SyntheticCheckInSeeder();

  Future<SyntheticSeedResult> generateInto(
    CheckInRepository repository, {
    required DateTime now,
    ResponseRepository? responses,
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
    var responsesWritten = 0;
    if (responses != null) {
      for (final item in plan.responses) {
        final existing = await responses.getById(item.id);
        if (existing != null && !existing.synthetic) continue;
        await responses.save(item);
        responsesWritten++;
      }
    }
    logAppEvent('synthetic_checkins_generated');
    return SyntheticSeedResult(
      written: written,
      skippedUserOwned: skipped,
      missingDays: plan.missingDays,
      responsesWritten: responsesWritten,
    );
  }

  Future<int> clearFrom(
    CheckInRepository repository, {
    ResponseRepository? responses,
  }) async {
    final all = await repository.allHealthy();
    var removed = 0;
    for (final record in all) {
      if (!record.synthetic) continue;
      final ok = await repository.delete(record.dateKey);
      if (ok) removed++;
    }
    if (responses != null) {
      final items = await responses.allHealthy();
      for (final item in items) {
        if (!item.synthetic) continue;
        await responses.delete(item.id);
      }
    }
    logAppEvent('synthetic_checkins_cleared');
    return removed;
  }
}

Future<void> ensureFirstInstallSampleData({
  required CheckInRepository checkIns,
  required ResponseRepository responses,
  required AppPrefs prefs,
  required DateTime now,
}) async {
  if (prefs.sampleRemovedByUser) return;
  if (prefs.sampleSeeded) return;
  final existing = await checkIns.allHealthy();
  if (existing.any((record) => !record.synthetic)) {
    await prefs.setSampleSeeded(true);
    return;
  }
  await const SyntheticCheckInSeeder().generateInto(
    checkIns,
    now: now,
    responses: responses,
  );
  await prefs.setSampleSeeded(true);
  await prefs.setSampleRemovedByUser(false);
}
