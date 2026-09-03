import 'quran.dart';

class RecordedContext {
  const RecordedContext({
    required this.subject,
    required this.polarity,
    required this.factorIds,
    this.freeText,
  });

  final QuranDimension subject;
  final String polarity;
  final List<String> factorIds;
  final String? freeText;

  bool get hasStructuredFactor => factorIds.isNotEmpty;

  RecordedContext copyWith({
    List<String>? factorIds,
    String? freeText,
    bool clearFreeText = false,
  }) {
    return RecordedContext(
      subject: subject,
      polarity: polarity,
      factorIds: factorIds ?? this.factorIds,
      freeText: clearFreeText ? null : (freeText ?? this.freeText),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject.name,
      'polarity': polarity,
      'factorIds': factorIds,
      if (freeText != null && freeText!.trim().isNotEmpty) 'freeText': freeText,
    };
  }

  static RecordedContext? fromJson(Object? json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final subjectName = map['subject'] as String?;
    final polarity = map['polarity'] as String?;
    if (subjectName == null || polarity == null) return null;
    final subject = QuranDimension.values.where((d) => d.name == subjectName);
    if (subject.isEmpty) return null;
    final dimension = subject.first;
    if (polarity != 'positive' && polarity != 'negative') return null;
    if (polarity == 'positive' && !dimension.allowsPositiveContext) return null;
    if (polarity == 'negative' && !dimension.allowsNegativeContext) return null;
    final rawIds = map['factorIds'];
    final ids = <String>[];
    if (rawIds is List) {
      for (final id in rawIds) {
        if (id is String && id.isNotEmpty && !ids.contains(id)) {
          ids.add(id);
        }
      }
    }
    final text = map['freeText'];
    return RecordedContext(
      subject: dimension,
      polarity: polarity,
      factorIds: ids,
      freeText: text is String && text.trim().isNotEmpty ? text : null,
    );
  }
}

bool contextAllowed(QuranDimension subject, TernaryOutcome outcome) {
  if (outcome == TernaryOutcome.positive) return subject.allowsPositiveContext;
  if (outcome == TernaryOutcome.negative) return subject.allowsNegativeContext;
  return false;
}
