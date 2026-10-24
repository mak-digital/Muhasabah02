import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/codecs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';

void main() {
  test('decode yields to the event loop every 24 keys', () async {
    var yields = 0;
    final keys = [
      for (var i = 1; i <= 25; i++) '2026-01-${i.toString().padLeft(2, '0')}',
    ];
    final raw = {
      for (final key in keys) key: encodeCheckIn(DailyCheckIn.empty(key)),
    };
    final batch = await decodeStoredCheckIns(
      keys: keys,
      read: (key) => raw['$key'],
      yieldToUi: () async {
        yields++;
      },
    );
    expect(yields, 1);
    expect(batch.healthy, hasLength(25));
    expect(batch.healthy.first.dateKey, '2026-01-25');
    expect(batch.healthy.last.dateKey, '2026-01-01');
    expect(batch.corruptKeys, isEmpty);
  });

  test(
    'decode keeps healthy records, newest first, and isolates corrupt',
    () async {
      final batch = await decodeStoredCheckIns(
        keys: ['2026-09-01', '2026-09-02', '2026-09-03'],
        read: (key) {
          if (key == '2026-09-02') return '{not-json';
          if (key == '2026-09-03') {
            return encodeCheckIn(
              DailyCheckIn.empty('2026-09-03')
                  .withPrayer(PrayerId.fajr, PrayerStatus.onTime),
            );
          }
          return encodeCheckIn(DailyCheckIn.empty('$key'));
        },
      );
      expect(batch.healthy.map((item) => item.dateKey).toList(), [
        '2026-09-03',
        '2026-09-01',
      ]);
      expect(batch.healthy.first.prayer(PrayerId.fajr), PrayerStatus.onTime);
      expect(batch.corruptKeys, ['2026-09-02']);
    },
  );

  test('memory allHealthy uses the same decode and order', () async {
    final repo = MemoryCheckInRepository();
    await repo.save(DailyCheckIn.empty('2026-09-01'));
    await repo.save(
      DailyCheckIn.empty('2026-09-03')
          .withPrayer(PrayerId.isha, PrayerStatus.late),
    );
    repo.putRaw('2026-09-02', 'nope');
    final healthy = await repo.allHealthy();
    expect(healthy.map((item) => item.dateKey).toList(), [
      '2026-09-03',
      '2026-09-01',
    ]);
    expect(repo.corruptKeys, contains('2026-09-02'));
  });
}
