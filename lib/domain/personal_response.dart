import 'monitor_domain.dart';

const int kPersonalResponseSchemaVersion = 1;
const int kResponseMaxScalars = 10000;

String normalizeResponseText(String input) {
  final unified = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  return unified.trim().isEmpty ? '' : unified;
}

int unicodeScalarCount(String input) => input.runes.length;

enum ResponseTextError { empty, tooLong }

ResponseTextError? validateResponseText(String raw) {
  final normalized = normalizeResponseText(raw);
  if (normalized.isEmpty) return ResponseTextError.empty;
  if (unicodeScalarCount(normalized) > kResponseMaxScalars) {
    return ResponseTextError.tooLong;
  }
  return null;
}

enum ProvenanceOrigin {
  periodSummary,
  progressDimension,
  progressDate,
  recordedContext,
  recognitionPattern,
  recognitionSupportingDate,
  historicalReflection,
  quranPonder,
  completedCheckIn,
  weeklyReflectionQuote,
}

class ResponseProvenance {
  const ResponseProvenance({
    required this.originType,
    this.domain,
    this.subject,
    this.dateKey,
    this.periodDays,
    this.factorId,
    this.evidenceId,
    required this.labelSnapshot,
  });

  final ProvenanceOrigin originType;
  final String? domain;
  final String? subject;
  final String? dateKey;
  final int? periodDays;
  final String? factorId;
  final String? evidenceId;
  final String labelSnapshot;

  Map<String, dynamic> toJson() {
    return {
      'originType': originType.name,
      if (domain != null) 'domain': domain,
      if (subject != null) 'subject': subject,
      if (dateKey != null) 'dateKey': dateKey,
      if (periodDays != null) 'periodDays': periodDays,
      if (factorId != null) 'factorId': factorId,
      if (evidenceId != null) 'evidenceId': evidenceId,
      'labelSnapshot': labelSnapshot,
    };
  }

  static ResponseProvenance? fromJson(Object? json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final typeName = map['originType'] as String?;
    if (typeName == null) {
      return ResponseProvenance(
        originType: ProvenanceOrigin.historicalReflection,
        labelSnapshot: (map['labelSnapshot'] as String?) ?? 'Recorded evidence',
        domain: map['domain'] as String?,
        subject: map['subject'] as String?,
        dateKey: map['dateKey'] as String?,
        periodDays: map['periodDays'] is int ? map['periodDays'] as int : null,
        factorId: map['factorId'] as String?,
        evidenceId: map['evidenceId'] as String?,
      );
    }
    final type = ProvenanceOrigin.values.where((v) => v.name == typeName);
    final origin = type.isEmpty
        ? ProvenanceOrigin.historicalReflection
        : type.first;
    final label = map['labelSnapshot'] as String?;
    return ResponseProvenance(
      originType: origin,
      domain: map['domain'] as String?,
      subject: map['subject'] as String?,
      dateKey: map['dateKey'] as String?,
      periodDays: map['periodDays'] is int ? map['periodDays'] as int : null,
      factorId: map['factorId'] as String?,
      evidenceId: map['evidenceId'] as String?,
      labelSnapshot: label ?? 'Recorded evidence',
    );
  }

  String get displayLine => 'Created while viewing: $labelSnapshot';
}

class PersonalResponse {
  const PersonalResponse({
    required this.id,
    required this.text,
    required this.createdAt,
    this.editedAt,
    this.archivedAt,
    this.provenance,
    this.noteCode,
    this.reminderDateKey,
    this.schemaVersion = kPersonalResponseSchemaVersion,
    this.synthetic = false,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? archivedAt;
  final ResponseProvenance? provenance;
  final String? noteCode;
  final String? reminderDateKey;
  final int schemaVersion;
  final bool synthetic;

  bool get isArchived => archivedAt != null;

  PersonalResponse copyWith({
    String? text,
    DateTime? editedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    ResponseProvenance? provenance,
    String? noteCode,
    String? reminderDateKey,
    bool clearReminderDateKey = false,
    bool? synthetic,
  }) {
    return PersonalResponse(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      provenance: provenance ?? this.provenance,
      noteCode: noteCode ?? this.noteCode,
      reminderDateKey: clearReminderDateKey
          ? null
          : (reminderDateKey ?? this.reminderDateKey),
      schemaVersion: schemaVersion,
      synthetic: synthetic ?? this.synthetic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      if (editedAt != null) 'editedAt': editedAt!.toIso8601String(),
      if (archivedAt != null) 'archivedAt': archivedAt!.toIso8601String(),
      if (provenance != null) 'provenance': provenance!.toJson(),
      if (noteCode != null) 'noteCode': noteCode,
      if (reminderDateKey != null) 'reminderDateKey': reminderDateKey,
      if (synthetic) 'synthetic': true,
    };
  }

  static PersonalResponse fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final text = json['text'] as String?;
    final created = json['createdAt'] as String?;
    if (id == null || id.isEmpty || text == null || created == null) {
      throw const FormatException('Malformed PersonalResponse');
    }
    return PersonalResponse(
      id: id,
      text: text,
      createdAt: DateTime.parse(created),
      editedAt: json['editedAt'] is String
          ? DateTime.tryParse(json['editedAt'] as String)
          : null,
      archivedAt: json['archivedAt'] is String
          ? DateTime.tryParse(json['archivedAt'] as String)
          : null,
      provenance: ResponseProvenance.fromJson(json['provenance']),
      noteCode: json['noteCode'] is String ? json['noteCode'] as String : null,
      reminderDateKey: json['reminderDateKey'] is String
          ? json['reminderDateKey'] as String
          : null,
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : kPersonalResponseSchemaVersion,
      synthetic: json['synthetic'] == true,
    );
  }
}

const kNoteGeneralDomain = 'GEN';

String noteYymmdd(DateTime createdAt) {
  final local = DateTime(createdAt.year, createdAt.month, createdAt.day);
  final yy = (local.year % 100).toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  return '$yy$mm$dd';
}

String formatNoteCode(DateTime createdAt, int dailyIndex) {
  return '${noteYymmdd(createdAt)}-${dailyIndex.toString().padLeft(2, '0')}';
}

int? parseNoteDailyIndex(String? code) {
  if (code == null || code.isEmpty) return null;
  final dash = code.lastIndexOf('-');
  if (dash < 0 || dash == code.length - 1) return null;
  return int.tryParse(code.substring(dash + 1));
}

int nextNoteDailyIndex(Iterable<PersonalResponse> items, DateTime createdAt) {
  final prefix = '${noteYymmdd(createdAt)}-';
  var max = 0;
  for (final item in items) {
    final code = item.noteCode;
    if (code == null || !code.startsWith(prefix)) continue;
    final n = parseNoteDailyIndex(code) ?? 0;
    if (n > max) max = n;
  }
  return max + 1;
}

List<PersonalResponse> assignMissingNoteCodes(List<PersonalResponse> items) {
  final byId = {for (final item in items) item.id: item};
  final sorted = [...items]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  for (final item in sorted) {
    final current = byId[item.id]!;
    if (current.noteCode != null && current.noteCode!.isNotEmpty) continue;
    final index = nextNoteDailyIndex(byId.values, current.createdAt);
    byId[item.id] = current.copyWith(
      noteCode: formatNoteCode(current.createdAt, index),
    );
  }
  return [for (final item in items) byId[item.id]!];
}

String noteDomainLabel(PersonalResponse item) {
  final raw = item.provenance?.domain;
  if (raw == null || raw.isEmpty) return kNoteGeneralDomain;
  final id = raw.split('.').first;
  for (final domain in MonitorDomain.values) {
    if (domain.id == id) return domain.shortLabel;
  }
  return kNoteGeneralDomain;
}

MonitorDomain? noteMonitorDomain(PersonalResponse item) {
  final raw = item.provenance?.domain;
  if (raw == null || raw.isEmpty) return null;
  final id = raw.split('.').first;
  for (final domain in MonitorDomain.values) {
    if (domain.id == id) return domain;
  }
  return null;
}

String noteSourceLabel(PersonalResponse item) {
  final provenance = item.provenance;
  if (provenance == null) return 'Independent';
  return provenance.labelSnapshot;
}
