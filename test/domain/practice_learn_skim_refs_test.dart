import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/practice_akhlaq_catalog.dart';
import 'package:muhasabah02/domain/practice_charity_catalog.dart';
import 'package:muhasabah02/domain/practice_dhikr_catalog.dart';
import 'package:muhasabah02/domain/practice_fasting_catalog.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/practice_hajj_catalog.dart';
import 'package:muhasabah02/domain/practice_health_catalog.dart';
import 'package:muhasabah02/domain/practice_huquq_catalog.dart';
import 'package:muhasabah02/domain/practice_knowledge_catalog.dart';
import 'package:muhasabah02/domain/practice_salah_catalog.dart';
import 'package:muhasabah02/domain/practice_time_catalog.dart';
import 'package:muhasabah02/domain/practice_ummah_catalog.dart';
import 'package:muhasabah02/domain/practice_wealth_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  void expectThreeToFivePerTopic(String name, List<PracticeDhikrItem> catalog) {
    test('$name Learn topics have 3–5 source refs', () {
      final keys = <String>{};
      for (final item in catalog) {
        keys.add('${item.group}\u0000${item.topic}');
      }
      expect(keys, isNotEmpty);
      for (final key in keys) {
        final parts = key.split('\u0000');
        final count = catalog
            .where((item) => item.group == parts[0] && item.topic == parts[1])
            .length;
        expect(count, inInclusiveRange(3, 5), reason: '$name $parts');
      }
      expect(
        catalog.every((item) => reflectionSourceUris(item.source).isNotEmpty),
        isTrue,
      );
      expect(catalog.map((item) => item.id).toSet().length, catalog.length);
    });
  }

  expectThreeToFivePerTopic('Salah', kPracticeSalahCatalog);
  expectThreeToFivePerTopic('Health', kPracticeHealthCatalog);
  expectThreeToFivePerTopic('Wealth', kPracticeWealthCatalog);
  expectThreeToFivePerTopic('Charity', kPracticeCharityCatalog);
  expectThreeToFivePerTopic('Ummah', kPracticeUmmahCatalog);
  expectThreeToFivePerTopic('Knowledge', kPracticeKnowledgeCatalog);
  expectThreeToFivePerTopic('Time', kPracticeTimeCatalog);
  expectThreeToFivePerTopic('Huquq', kPracticeHuquqCatalog);
  expectThreeToFivePerTopic('Akhlaq', kPracticeAkhlaqCatalog);
  expectThreeToFivePerTopic('Dhikr', kPracticeDhikrCatalog);

  test('Hajj Learn catalog spans Learn, Readiness, and After Hajj', () {
    expect(kPracticeHajjCatalog.length, 4);
    expect(kPracticeHajjCatalog.map((item) => item.group).toSet(), {
      kHajjLearnBand,
      kHajjReadinessBand,
      kHajjAfterBand,
    });
    expect(
      kPracticeHajjCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      kPracticeHajjCatalog.map((item) => item.id).toSet().length,
      kPracticeHajjCatalog.length,
    );
  });

  test('Fasting Learn bank is 20–30 verified refs without a five-cap', () {
    expect(kPracticeFastingCatalog.length, inInclusiveRange(20, 30));
    expect(
      kPracticeFastingCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      kPracticeFastingCatalog.map((item) => item.id).toSet().length,
      kPracticeFastingCatalog.length,
    );
  });
}
