enum DhikrStatus { unanswered, practised, didNot }

enum ConductStatus { unanswered, noted, didNot }

enum EntryStatus { unanswered, recorded, noneToday }

DhikrStatus dhikrFromJson(Object? value) {
  if (value is! String) return DhikrStatus.unanswered;
  return DhikrStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => DhikrStatus.unanswered,
  );
}

ConductStatus conductFromJson(Object? value) {
  if (value is! String) return ConductStatus.unanswered;
  return ConductStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ConductStatus.unanswered,
  );
}

EntryStatus entryStatusFromJson(Object? value) {
  if (value is! String) return EntryStatus.unanswered;
  return EntryStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => EntryStatus.unanswered,
  );
}

extension DhikrStatusX on DhikrStatus {
  bool get isRecorded => this != DhikrStatus.unanswered;
  String get label => switch (this) {
    DhikrStatus.unanswered => 'Not recorded',
    DhikrStatus.practised => 'Practised dhikr / istighfar',
    DhikrStatus.didNot => 'Did not practise',
  };
}

extension ConductStatusX on ConductStatus {
  bool get isRecorded => this != ConductStatus.unanswered;
  String get label => switch (this) {
    ConductStatus.unanswered => 'Not recorded',
    ConductStatus.noted => 'Noted a character observation',
    ConductStatus.didNot => 'No character observation recorded',
  };
}

extension EntryStatusX on EntryStatus {
  bool get isRecorded => this != EntryStatus.unanswered;
  bool get hasTextEntry => this == EntryStatus.recorded;
}
