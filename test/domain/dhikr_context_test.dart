import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/dhikr_context.dart';
import 'package:muhasabah02/domain/dhikr_source_registry.dart';
import 'package:muhasabah02/domain/practice_dhikr_catalog.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quick_tap.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('context catalogue ids are unique and cover Dhikr check-in rows', () {
    final ids = kDhikrContextCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(
      kDhikrContextCatalog.map((item) => item.rowKey).toSet(),
      kDhikrContextRowKeys,
    );
    expect(dhikrContextItemsFor(kDhikrGeneralKey).length, 10);
    expect(dhikrContextItemsFor(kDhikrGratitudeKey).length, 6);
    expect(dhikrContextItemsFor(kDhikrTravelKey).length, 7);
    expect(dhikrContextItemsFor(kDhikrPersonalKey).length, 10);
    expect(dhikrContextItemsFor(kDhikrOtherKey).length, 10);
    expect(
      dhikrContextItemsFor(kDhikrMorningKey).length,
      practiceDhikrPrimaryForGroup(kDhikrGroupMorning).length,
    );
    expect(
      dhikrContextItemsFor(kDhikrEveningKey).length,
      practiceDhikrPrimaryForGroup(kDhikrGroupEvening).length,
    );
    expect(
      dhikrContextItemsFor('dhikr.postFardFajr').length,
      practiceDhikrPrimaryForGroup(kDhikrGroupPost).length,
    );
    final fajrIstighfar =
        dhikrContextItemById['dhikr.postFardFajr.dh.post.istighfar3']!;
    expect(dhikrHasVerifiedWording(fajrIstighfar), isTrue);
    expect(fajrIstighfar.seedCount, 3);
    expect(
      dhikrContextItemById['dhikr.morningAdhkar.dh.morn.subhan100']!.seedCount,
      100,
    );
  });

  test(
    'source registry ids are unique and verified formulas have citations',
    () {
      final ids = kDhikrSourceRegistry.map((item) => item.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final source in kDhikrSourceRegistry) {
        if (source.verification != DhikrVerificationStatus.verified) continue;
        expect(source.citation, isNotEmpty);
        expect(reflectionSourceUris(source.citation), isNotEmpty);
        if (source.showFormula && source.kind == DhikrSourceKind.formula) {
          expect(source.arabic, isNotEmpty);
          expect(source.meaning, isNotEmpty);
        }
      }
      expect(
        kDhikrSourceRegistry
            .where(
              (item) =>
                  item.verification == DhikrVerificationStatus.pendingReview,
            )
            .map((item) => item.id),
        ['src.dhikr.istikharaPending'],
      );
    },
  );

  test('linked source ids exist on the registry', () {
    for (final item in kDhikrContextCatalog) {
      if (item.sourceId == null) continue;
      expect(
        dhikrSourceById.containsKey(item.sourceId),
        isTrue,
        reason: item.id,
      );
    }
  });

  test('multiple selections persist without converting unanswered', () {
    var record = DailyCheckIn.empty('2026-10-20');
    expect(record.homeTrace(kDhikrGeneralKey), TernaryOutcome.unanswered);
    record = record.withDhikrContextCaptures(kDhikrGeneralKey, [
      const DhikrContextCapture(
        activityId: 'dhikr.general.tasbih',
        response: DhikrContextResponse.practised,
        repetitions: 33,
      ),
      const DhikrContextCapture(
        activityId: 'dhikr.general.istighfar',
        response: DhikrContextResponse.notToday,
      ),
    ]);
    expect(record.answeredRecordableCount, 0);
    expect(record.homeTrace(kDhikrGeneralKey), TernaryOutcome.positive);
    expect(record.dhikrContextFor(kDhikrGeneralKey), hasLength(2));
    final restored = DailyCheckIn.fromJson(record.toJson());
    expect(restored.dhikrContextFor(kDhikrGeneralKey), hasLength(2));
    expect(restored.dhikrContextFor(kDhikrGeneralKey).first.repetitions, 33);
    expect(
      DailyCheckIn.fromJson({'schemaVersion': 6, 'dateKey': '2026-10-19'})
          .homeTrace(kDhikrGeneralKey),
      TernaryOutcome.unanswered,
    );
  });

  test('legacy ternary stays until a context selection is saved', () {
    final legacy = DailyCheckIn.empty('2026-10-18')
        .withHomeTrace(kDhikrGratitudeKey, TernaryOutcome.positive);
    expect(legacy.dhikrContextFor(kDhikrGratitudeKey), isEmpty);
    expect(legacy.homeTrace(kDhikrGratitudeKey), TernaryOutcome.positive);
    final json = legacy.toJson();
    expect(json.containsKey('dhikrContext'), isFalse);
    final restored = DailyCheckIn.fromJson(json);
    expect(restored.homeTrace(kDhikrGratitudeKey), TernaryOutcome.positive);
    expect(restored.dhikrContextFor(kDhikrGratitudeKey), isEmpty);
  });

  test('prefer-not is recorded and is not unanswered', () {
    final record = DailyCheckIn.empty('2026-10-20')
        .withDhikrContextCaptures(kDhikrPersonalKey, const [
          DhikrContextCapture(
            activityId: 'dhikr.personal.guidance',
            response: DhikrContextResponse.preferNot,
            note: 'topic only',
          ),
        ]);
    expect(record.homeTrace(kDhikrPersonalKey), TernaryOutcome.negative);
    expect(
      record.homeTrace(kDhikrPersonalKey),
      isNot(TernaryOutcome.unanswered),
    );
    expect(record.dhikrContextFor(kDhikrPersonalKey).single.note, 'topic only');
  });

  test('not-today-only rollup is negative, not unanswered', () {
    final record = DailyCheckIn.empty('2026-10-20')
        .withDhikrContextCaptures(kDhikrTravelKey, const [
          DhikrContextCapture(
            activityId: 'dhikr.travel.leavingHome',
            response: DhikrContextResponse.notToday,
          ),
        ]);
    expect(record.homeTrace(kDhikrTravelKey), TernaryOutcome.negative);
  });

  test('ternary write does not clear saved context activities', () {
    final record = DailyCheckIn.empty('2026-10-20')
        .withDhikrContextCaptures(kDhikrGeneralKey, const [
          DhikrContextCapture(
            activityId: 'dhikr.general.tasbih',
            response: DhikrContextResponse.practised,
          ),
        ]);
    final afterTap = record.withHomeTrace(
      kDhikrGeneralKey,
      TernaryOutcome.negative,
    );
    expect(afterTap.dhikrContextFor(kDhikrGeneralKey), hasLength(1));
    expect(afterTap.homeTrace(kDhikrGeneralKey), TernaryOutcome.positive);
    final item = quickTapItemsFor({kDhikrGeneralKey}).single;
    final cycled = applyQuickTapChoice(
      afterTap,
      item,
      nextQuickTapChoice(afterTap, item),
    );
    expect(cycled.dhikrContextFor(kDhikrGeneralKey), hasLength(1));
  });

  test('resolved count prefers recorded then remembered then seed', () {
    const tasbih = DhikrContextItem(
      id: 'dhikr.general.tasbih',
      rowKey: kDhikrGeneralKey,
      label: 'SubhanAllah — Tasbih',
      kind: DhikrSourceKind.activity,
      seedCount: 33,
    );
    expect(resolvedDhikrCount(item: tasbih, recorded: 100, remembered: 7), 100);
    expect(resolvedDhikrCount(item: tasbih, remembered: 7), 7);
    expect(resolvedDhikrCount(item: tasbih), 33);
    expect(dhikrPerformedSummary(const []), 'Not recorded');
    expect(
      dhikrPerformedSummary(const [
        DhikrContextCapture(
          activityId: 'dhikr.general.tasbih',
          response: DhikrContextResponse.practised,
        ),
      ]),
      '1 performed',
    );
  });

  test('verified wording links to related Learn & Practice items', () {
    final tasbih = dhikrContextItemById['dhikr.general.tasbih']!;
    expect(dhikrHasVerifiedWording(tasbih), isTrue);
    expect(
      dhikrPracticeReferencesFor(tasbih).map((item) => item.id),
      contains('dh.gen.adheem'),
    );
    expect(
      practiceDhikrMatchingCitation('Ṣaḥīḥ Muslim 597').map((item) => item.id),
      contains('dh.post.tasbih33'),
    );
    expect(
      dhikrHasVerifiedWording(dhikrContextItemById['dhikr.general.other']!),
      isFalse,
    );
    expect(
      dhikrShowsWordingLink(dhikrContextItemById['dhikr.general.other']!),
      isTrue,
    );
    expect(
      dhikrWordingLinkLabel(
        dhikrContextItemById['dhikr.personal.forgiveness']!,
      ),
      Copy.relatedWordingAvailable,
    );
    expect(
      dhikrShowsWordingLink(
        dhikrContextItemById['dhikr.personal.forgiveness']!,
      ),
      isTrue,
    );
    expect(
      dhikrShowsWordingLink(dhikrContextItemById['dhikr.personal.istikhara']!),
      isFalse,
    );
  });

  test('waking mosque distress and illness have verified citations', () {
    for (final id in [
      'src.dhikr.waking',
      'src.dhikr.mosque',
      'src.dhikr.distress',
      'src.dhikr.illness',
    ]) {
      final source = dhikrSourceById[id]!;
      expect(source.verification, DhikrVerificationStatus.verified);
      expect(source.citation, isNotEmpty);
      expect(reflectionSourceUris(source.citation), isNotEmpty);
      expect(source.arabic, isNotEmpty);
    }
  });
}
