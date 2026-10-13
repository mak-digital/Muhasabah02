import 'monitor_domain.dart';

const int kPracticeHadithSchemaVersion = 1;

enum PracticeHadithStatus { learning, learnt, practicing, habit }

extension PracticeHadithStatusX on PracticeHadithStatus {
  String get label => labelFor(MonitorDomain.dhikr);

  String labelFor(MonitorDomain domain) {
    if (domain == MonitorDomain.hadith) {
      return switch (this) {
        PracticeHadithStatus.learning => 'Learning',
        PracticeHadithStatus.learnt => 'Learnt',
        PracticeHadithStatus.practicing => 'Practicing',
        PracticeHadithStatus.habit => 'Living it',
      };
    }
    return switch (this) {
      PracticeHadithStatus.learning => 'Learning',
      PracticeHadithStatus.learnt => 'Learnt',
      PracticeHadithStatus.practicing => 'Practicing',
      PracticeHadithStatus.habit => 'Habit',
    };
  }

  static PracticeHadithStatus fromId(String? id) {
    return switch (id) {
      'know' => PracticeHadithStatus.learnt,
      'inPractice' => PracticeHadithStatus.practicing,
      'learning' => PracticeHadithStatus.learning,
      'learnt' => PracticeHadithStatus.learnt,
      'practicing' => PracticeHadithStatus.practicing,
      'habit' => PracticeHadithStatus.habit,
      _ => PracticeHadithStatus.learning,
    };
  }
}

class PracticeHadithItem {
  const PracticeHadithItem({
    required this.id,
    required this.topic,
    required this.text,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.sourceDetail,
  });

  final String id;
  final String topic;
  /// Framing of the teaching in English.
  final String text;
  final String arabic;
  final String transliteration;
  /// English of the core words (supplication or key wording).
  final String translation;
  final String source;
  final String sourceDetail;
}

class PracticeHadithRecord {
  const PracticeHadithRecord({
    required this.id,
    required this.catalogId,
    required this.addedDateKey,
    required this.topic,
    required this.content,
    required this.source,
    required this.status,
    this.domain = MonitorDomain.hadith,
    this.group = '',
    this.arabic = '',
    this.transliteration = '',
    this.translation = '',
    this.schemaVersion = kPracticeHadithSchemaVersion,
  });

  final String id;
  final String catalogId;
  final String addedDateKey;
  final String topic;
  final String content;
  final String source;
  final String arabic;
  final String transliteration;
  final String translation;
  final MonitorDomain domain;
  final String group;
  final PracticeHadithStatus status;
  final int schemaVersion;

  PracticeHadithRecord copyWith({PracticeHadithStatus? status}) {
    return PracticeHadithRecord(
      id: id,
      catalogId: catalogId,
      addedDateKey: addedDateKey,
      topic: topic,
      content: content,
      source: source,
      arabic: arabic,
      transliteration: transliteration,
      translation: translation,
      domain: domain,
      group: group,
      status: status ?? this.status,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'catalogId': catalogId,
      'addedDateKey': addedDateKey,
      'topic': topic,
      'content': content,
      'source': source,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'domain': domain.id,
      'group': group,
      'status': status.name,
    };
  }

  static PracticeHadithRecord fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final catalogId = json['catalogId'] as String?;
    final added = json['addedDateKey'] as String?;
    final topic = json['topic'] as String?;
    final content = json['content'] as String?;
    final source = json['source'] as String?;
    if (id == null ||
        id.isEmpty ||
        catalogId == null ||
        added == null ||
        topic == null ||
        content == null ||
        source == null) {
      throw const FormatException('Malformed PracticeHadithRecord');
    }
    return PracticeHadithRecord(
      id: id,
      catalogId: catalogId,
      addedDateKey: added,
      topic: topic,
      content: content,
      source: source,
      arabic: json['arabic'] is String ? json['arabic'] as String : '',
      transliteration: json['transliteration'] is String
          ? json['transliteration'] as String
          : '',
      translation: json['translation'] is String
          ? json['translation'] as String
          : '',
      domain: MonitorDomain.values
              .where((value) => value.id == json['domain'])
              .firstOrNull ??
          MonitorDomain.hadith,
      group: json['group'] is String ? json['group'] as String : '',
      status: PracticeHadithStatusX.fromId(json['status'] as String?),
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : kPracticeHadithSchemaVersion,
    );
  }
}

int wrapPracticeHadithIndex(int index, int length) {
  if (length <= 0) return 0;
  return ((index % length) + length) % length;
}

Set<String> registeredPracticeHadithIds(List<PracticeHadithRecord> records) {
  return {for (final record in records) record.catalogId};
}

bool practiceHadithAlreadyRegistered(
  List<PracticeHadithRecord> records,
  String catalogId,
) {
  return registeredPracticeHadithIds(records).contains(catalogId);
}

PracticeHadithRecord recordFromCatalog({
  required PracticeHadithItem item,
  required String id,
  required String addedDateKey,
}) {
  return PracticeHadithRecord(
    id: id,
    catalogId: item.id,
    addedDateKey: addedDateKey,
    topic: item.topic,
    content: item.text,
    source: item.source,
    arabic: item.arabic,
    transliteration: item.transliteration,
    translation: item.translation,
    domain: MonitorDomain.hadith,
    status: PracticeHadithStatus.learning,
  );
}

List<PracticeHadithRecord> practiceRecordsForDomain(
  List<PracticeHadithRecord> records,
  MonitorDomain domain,
) {
  return [
    for (final record in records)
      if (record.domain == domain) record,
  ];
}

List<PracticeHadithRecord> orderedPracticeHadithRegister(
  List<PracticeHadithRecord> records,
) {
  final copy = [...records];
  copy.sort((a, b) {
    final byDate = b.addedDateKey.compareTo(a.addedDateKey);
    if (byDate != 0) return byDate;
    return a.topic.compareTo(b.topic);
  });
  return copy;
}
