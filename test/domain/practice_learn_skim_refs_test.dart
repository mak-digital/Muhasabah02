import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/practice_akhlaq_catalog.dart';
import 'package:muhasabah02/domain/practice_charity_catalog.dart';
import 'package:muhasabah02/domain/practice_dhikr_catalog.dart';
import 'package:muhasabah02/domain/practice_fasting_catalog.dart';
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
  void expectThreeToFivePerTopic(
    String name,
    List<PracticeDhikrItem> catalog,
  ) {
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
      expect(
        catalog.map((item) => item.id).toSet().length,
        catalog.length,
      );
    });
  }

  expectThreeToFivePerTopic('Salah', kPracticeSalahCatalog);
  expectThreeToFivePerTopic('Health', kPracticeHealthCatalog);
  expectThreeToFivePerTopic('Wealth', kPracticeWealthCatalog);
  expectThreeToFivePerTopic('Charity', kPracticeCharityCatalog);
  expectThreeToFivePerTopic('Fasting', kPracticeFastingCatalog);
  expectThreeToFivePerTopic('Hajj', kPracticeHajjCatalog);
  expectThreeToFivePerTopic('Ummah', kPracticeUmmahCatalog);
  expectThreeToFivePerTopic('Knowledge', kPracticeKnowledgeCatalog);
  expectThreeToFivePerTopic('Time', kPracticeTimeCatalog);
  expectThreeToFivePerTopic('Huquq', kPracticeHuquqCatalog);
  expectThreeToFivePerTopic('Akhlaq', kPracticeAkhlaqCatalog);
  expectThreeToFivePerTopic('Dhikr', kPracticeDhikrCatalog);
}
