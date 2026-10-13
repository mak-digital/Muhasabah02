import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';
import 'package:muhasabah02/domain/practice_knowledge_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Knowledge catalog is grouped by Home bands with unique ids', () {
    final ids = kPracticeKnowledgeCatalog.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kPracticeKnowledgeCatalog, isNotEmpty);
    expect(
      kPracticeKnowledgeCatalog.every(
        (item) =>
            item.arabic.isNotEmpty &&
            item.transliteration.isNotEmpty &&
            item.translation.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      kPracticeKnowledgeCatalog.map((item) => item.group).toSet(),
      {
        kKnowledgeGroupSeeking,
        kKnowledgeGroupSharing,
        kKnowledgeGroupSpeech,
      },
    );
    expect(kPracticeKnowledgeCatalog.first.group, kKnowledgeGroupSeeking);
    expect(kPracticeKnowledgeGroups, bandsFor(knowledgeHomeRows));
    expect(
      kPracticeKnowledgeCatalog.map((item) => item.topic).toSet(),
      knowledgeHomeRows.map((row) => row.label).toSet(),
    );
    expect(
      kPracticeKnowledgeCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Knowledge reminders stay residual of Qur’an, Hadith, and Akhlaq', () {
    expect(
      kPracticeKnowledgeCatalog.any(
        (item) => item.sourceDetail.contains('Qur’an and Hadith have their own'),
      ),
      isTrue,
    );
    expect(
      kPracticeKnowledgeCatalog.any(
        (item) => item.sourceDetail.contains('not a Qur’an or Hadith sitting'),
      ),
      isTrue,
    );
    expect(
      kPracticeKnowledgeCatalog.any(
        (item) => item.sourceDetail.contains('Not Character & Morals’ tone'),
      ),
      isTrue,
    );
  });

  test('Knowledge register records stay on the Knowledge domain', () {
    final item = kPracticeKnowledgeCatalog.first;
    final record = recordFromKnowledgeCatalog(
      item: item,
      id: 'k1',
      addedDateKey: '2026-10-10',
    );
    expect(record.domain, MonitorDomain.knowledge);
    expect(record.group, kKnowledgeGroupSeeking);
    expect(record.status, PracticeHadithStatus.learning);
    expect(
      practiceRecordsForDomain([record], MonitorDomain.huquq),
      isEmpty,
    );
  });
}
