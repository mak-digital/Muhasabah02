import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/codecs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';

void main() {
  test('corrupt check-in is isolated from healthy records', () async {
    final repo = MemoryCheckInRepository();
    await repo.save(
      DailyCheckIn.empty('2026-09-01')
          .withPrayer(PrayerId.fajr, PrayerStatus.onTime),
    );
    repo.putRaw('2026-09-02', '{not-json');
    final healthy = await repo.allHealthy();
    expect(healthy, hasLength(1));
    expect(healthy.single.dateKey, '2026-09-01');
    expect(repo.corruptKeys, contains('2026-09-02'));
  });

  test('decode never manufactures missed from empty map', () {
    final parsed = decodeCheckIn('{"dateKey":"2026-09-03","schemaVersion":5}');
    expect(parsed.corrupt, isFalse);
    expect(parsed.record!.prayer(PrayerId.maghrib), PrayerStatus.unanswered);
  });

  test('unknown future schema still reads known fields', () {
    final record = DailyCheckIn.fromJson({
      'schemaVersion': 99,
      'dateKey': '2026-09-03',
      'salah': {'fajr': 'late'},
      'futureField': {'nested': true},
    });
    expect(record.schemaVersion, 99);
    expect(record.prayer(PrayerId.fajr), PrayerStatus.late);
  });
}
