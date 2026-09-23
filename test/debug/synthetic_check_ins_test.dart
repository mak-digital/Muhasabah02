import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/debug/synthetic_check_in_seeder.dart';
import 'package:muhasabah02/debug/synthetic_check_ins.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recognition.dart';
import 'package:muhasabah02/domain/review_period.dart';

void main() {
  final now = DateTime(2026, 9, 3);

  test('synthetic plan covers 120 days with gaps and unanswered values', () {
    final plan = generateSyntheticCheckIns(now: now);
    expect(plan.savedDays + plan.missingDays, 120);
    expect(plan.missingDays, greaterThanOrEqualTo(12));
    expect(plan.savedDays, lessThan(120));
    expect(plan.records.every((record) => record.synthetic), isTrue);
    expect(plan.responses, isNotEmpty);
    expect(plan.responses.every((item) => item.synthetic), isTrue);

    final unansweredSalahDays = plan.records.where((record) {
      return PrayerId.values.any(
        (id) => record.prayer(id) == PrayerStatus.unanswered,
      );
    });
    expect(unansweredSalahDays, isNotEmpty);

    final mixedSalahDays = plan.records.where((record) {
      final statuses = {for (final id in PrayerId.values) record.prayer(id)};
      return statuses.length > 1;
    });
    expect(mixedSalahDays.length, greaterThan(plan.savedDays ~/ 4));

    final unansweredQuranDays = plan.records.where((record) {
      return quranDailyDimensions.any(
        (dimension) =>
            record.quranOutcome(dimension) == TernaryOutcome.unanswered,
      );
    });
    expect(unansweredQuranDays, isNotEmpty);
    expect(
      plan.records.every(
        (record) =>
            record.quranOutcome(QuranDimension.applicationReflection) ==
            TernaryOutcome.unanswered,
      ),
      isTrue,
    );

    final perfectDays = plan.records.where((record) {
      final salahPerfect = PrayerId.values.every(
        (id) => record.prayer(id) == PrayerStatus.onTime,
      );
      final quranPerfect = QuranDimension.values.every(
        (dimension) =>
            record.quranOutcome(dimension) == TernaryOutcome.positive,
      );
      return salahPerfect || quranPerfect;
    });
    expect(perfectDays, isEmpty);
  });

  test('synthetic plan includes Recognition context clusters', () {
    final plan = generateSyntheticCheckIns(now: now);
    final keys30 = periodDateKeys(30, now: now).toSet();
    final keys90 = periodDateKeys(90, now: now).toSet();
    final in30 = [
      for (final record in plan.records)
        if (keys30.contains(record.dateKey)) record,
    ];
    final in90 = [
      for (final record in plan.records)
        if (keys90.contains(record.dateKey)) record,
    ];
    final patterns30 = const RecognitionEngine().detect(
      records: in30,
      period: ReviewPeriod.days30,
      now: now,
    );
    final patterns90 = const RecognitionEngine().detect(
      records: in90,
      period: ReviewPeriod.days90,
      now: now,
    );
    expect(patterns30, isNotEmpty);
    expect(
      patterns30.any(
        (pattern) =>
            pattern.subject == QuranDimension.meaning &&
            pattern.factorId == 'routine',
      ),
      isTrue,
    );
    expect(
      patterns30.any(
        (pattern) =>
            pattern.subject == QuranDimension.revision &&
            pattern.factorId == 'fatigue',
      ),
      isTrue,
    );
    expect(patterns90, isNotEmpty);
    expect(
      patterns90.any(
        (pattern) =>
            pattern.subject == QuranDimension.tafsir &&
            pattern.factorId == 'quran.studyCircle',
      ),
      isTrue,
    );
    expect(
      patterns30.every(
        (pattern) => !pattern.factorLine.toLowerCase().contains('caused'),
      ),
      isTrue,
    );
  });

  test(
    'seeder writes through the production repository and can clear',
    () async {
      final repo = MemoryCheckInRepository();
      const seeder = SyntheticCheckInSeeder();
      final result = await seeder.generateInto(repo, now: now);
      final stored = await repo.allHealthy();
      expect(stored.length, result.written);
      expect(stored.length, lessThan(120));
      expect(result.missingDays, greaterThan(0));
      expect(stored.first.schemaVersion, kDailyCheckInSchemaVersion);

      final user = DailyCheckIn.empty('2020-01-01')
          .withPrayer(PrayerId.fajr, PrayerStatus.onTime);
      await repo.save(user);

      final removed = await seeder.clearFrom(repo);
      expect(removed, result.written);
      final remaining = await repo.allHealthy();
      expect(remaining, hasLength(1));
      expect(remaining.single.dateKey, '2020-01-01');
      expect(remaining.single.synthetic, isFalse);
    },
  );

  test('seeder does not overwrite a user-owned day', () async {
    final repo = MemoryCheckInRepository();
    final today = DailyCheckIn.empty('2026-09-03')
        .withPrayer(PrayerId.fajr, PrayerStatus.late);
    await repo.save(today);
    final result = await const SyntheticCheckInSeeder().generateInto(
      repo,
      now: now,
    );
    expect(result.skippedUserOwned, 1);
    final kept = await repo.getByDate('2026-09-03');
    expect(kept!.prayer(PrayerId.fajr), PrayerStatus.late);
    expect(kept.synthetic, isFalse);
  });
}
