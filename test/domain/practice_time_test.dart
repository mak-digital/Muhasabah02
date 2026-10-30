import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_time_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';
import 'package:muhasabah02/domain/time_practices.dart';

void main() {
  test('Time catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeTimeCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeTimeCatalog, isNotEmpty);
    expect(
      kPracticeTimeCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(kPracticeTimeCatalog.map((item) => item.group).toSet(), {
      kTimeIntentionBand,
      kTimeAttentionBand,
      kTimeActionBand,
      kTimeBalanceBand,
    });
    expect(kPracticeTimeCatalog.first.group, kTimeIntentionBand);
    expect(kPracticeTimeGroups, bandsFor(timeHomeRows));
    expect(
      kPracticeTimeCatalog.map((item) => item.topic).toSet(),
      timeHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeTimeCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test(
    'Time reminders stay observational and not a productivity programme',
    () {
      expect(
        kPracticeTimeCatalog.any(
          (item) => item.sourceDetail.contains('not whether it was accepted'),
        ),
        isTrue,
      );
      expect(
        kPracticeTimeCatalog.any(
          (item) => item.sourceDetail.contains('not a claim of barakah'),
        ),
        isTrue,
      );
      expect(
        kPracticeTimeCatalog.any(
          (item) => item.sourceDetail.contains(
            'sleep amount and quality stay on Physical Health',
          ),
        ),
        isTrue,
      );
    },
  );

  test('Time register records stay on the Time domain', () {
    final item = kPracticeTimeCatalog.first;
    final record = recordFromTimeCatalog(
      item: item,
      id: 't1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.time);
    expect(record.group, kTimeIntentionBand);
    expect(record.status, PracticeHadithStatus.learning);
    expect(
      practiceRecordsForDomain([record], MonitorDomain.knowledge),
      isEmpty,
    );
  });
}
