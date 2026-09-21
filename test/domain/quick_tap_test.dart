import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quick_tap.dart';

void main() {
  final fajr = quickTapItemsFor({'salah.fajr'}).single;
  final quran = quickTapItemsFor({'quran.reading'}).single;
  final speech = quickTapItemsFor({'akhlaq.modestSpeech'}).single;

  test('quick tap lists mix rows on shown domains, not a fixed seven', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final keys = resolvePersonalMixKeys(mix, kBasicAkhlaqVisibleDomains);
    final items = quickTapItemsFor(keys, friday: false);
    expect(
      items.map((item) => item.id),
      [
        'salah.fajr',
        'salah.dhuhr',
        'salah.asr',
        'salah.maghrib',
        'salah.isha',
        'quran.reading',
        'quran.meaning',
        'quran.reflection',
        'quran.consciousApplication',
        'hadith.livedSunnah',
        'akhlaq.patience',
        'akhlaq.truthfulness',
        'huquq.parents',
        'charity.voluntary',
        kZakatMixKey,
      ],
    );
    expect(items.any((item) => item.id == 'dhikr.generalDhikr'), isFalse);
    expect(
      items.any((item) => item.id == 'akhlaq.pausedBeforeReacting'),
      isFalse,
    );
    expect(items.any((item) => item.id == kHajjMixKey), isFalse);
  });

  test('quick tap hides mix rows whose domain is not shown', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final keys = resolvePersonalMixKeys(mix, {
      MonitorDomain.salah,
      MonitorDomain.quran,
    });
    final items = quickTapItemsFor(keys);
    expect(items.any((item) => item.id == 'huquq.parents'), isFalse);
    expect(items.any((item) => item.id == 'salah.fajr'), isTrue);
  });

  test('quick tap starts unanswered and first tap uses catalog order', () {
    final empty = DailyCheckIn.empty('2026-09-14');
    expect(readQuickTapChoiceId(empty, fajr), ActivityIds.unanswered);
    final next = nextQuickTapChoice(empty, fajr);
    expect(next.id, 'congregationOnTime');
    final recorded = applyQuickTapChoice(empty, fajr, next);
    expect(recorded.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(recorded.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
    expect(
      recorded.activityFor(ActivityCatalog.salahKey(PrayerId.fajr)).id,
      'congregationOnTime',
    );
  });

  test('quick tap cycles check-in salah options then unanswered', () {
    var record = DailyCheckIn.empty('2026-09-14');
    final seen = <String>[];
    for (var i = 0; i < 9; i++) {
      final next = nextQuickTapChoice(record, fajr);
      seen.add(next.id);
      record = applyQuickTapChoice(record, fajr, next);
    }
    expect(seen, [
      'congregationOnTime',
      'joinedCongregationLate',
      'smallCongregation',
      'aloneOnTime',
      'excused',
      'prayedLate',
      'missedMadeUp',
      'missed',
      ActivityIds.unanswered,
    ]);
    expect(record.prayer(PrayerId.fajr), PrayerStatus.unanswered);
  });

  test('quick tap first tap follows this person history, not a global default', () {
    final past = DailyCheckIn.empty('2026-09-10').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: 'aloneOnTime'),
    );
    final later = DailyCheckIn.empty('2026-09-11').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: 'aloneOnTime'),
    );
    final once = DailyCheckIn.empty('2026-09-12').withSalahActivity(
      PrayerId.fajr,
      const RecordedActivity(id: 'missed'),
    );
    final today = DailyCheckIn.empty('2026-09-14');
    final next = nextQuickTapChoice(
      today,
      fajr,
      history: [past, later, once],
    );
    expect(next.id, 'aloneOnTime');
    expect(today.prayer(PrayerId.fajr), PrayerStatus.unanswered);
  });

  test('quick tap skip Other and leave other traces unanswered', () {
    var record = DailyCheckIn.empty('2026-09-14');
    record = applyQuickTapChoice(
      record,
      speech,
      nextQuickTapChoice(record, speech),
    );
    record = applyQuickTapChoice(
      record,
      quran,
      nextQuickTapChoice(record, quran),
    );
    expect(record.homeTrace('akhlaq.modestSpeech'), TernaryOutcome.positive);
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    expect(
      record.activityFor(ActivityCatalog.quranKey(QuranDimension.reading)).id,
      'readIndependently',
    );
    expect(
      record.homeTrace('akhlaq.pausedBeforeReacting'),
      TernaryOutcome.unanswered,
    );
    expect(
      quickTapCatalog(quran).any((choice) => choice.id == ActivityIds.other),
      isFalse,
    );
  });
}
