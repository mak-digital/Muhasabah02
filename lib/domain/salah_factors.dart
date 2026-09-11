import 'prayer.dart';

class SalahFactorOption {
  const SalahFactorOption({required this.id, required this.label});

  final String id;
  final String label;
}

class SalahFactorCatalog {
  static const support = [
    SalahFactorOption(id: 'salah.alarmWorked', label: 'Alarm worked'),
    SalahFactorOption(id: 'salah.sleptEarly', label: 'Slept early'),
    SalahFactorOption(id: 'salah.reminder', label: 'Reminder'),
    SalahFactorOption(
      id: 'salah.congregationNearby',
      label: 'Congregation nearby',
    ),
  ];

  static const challenge = [
    SalahFactorOption(id: 'salah.overslept', label: 'Overslept'),
    SalahFactorOption(id: 'salah.workCommitment', label: 'Work commitment'),
    SalahFactorOption(id: 'salah.travel', label: 'Travel'),
    SalahFactorOption(id: 'salah.tired', label: 'Tired'),
  ];

  /// Sleep and waking cues apply to night/early prayers, not daytime Salah.
  static bool isNightPrayer(String subject) {
    return subject == PrayerId.fajr.name || subject == 'tahajjud';
  }

  static List<SalahFactorOption> supportFor(String subject) {
    if (isNightPrayer(subject)) {
      return support;
    }
    return support
        .where(
          (factor) =>
              factor.id != 'salah.sleptEarly' &&
              factor.id != 'salah.alarmWorked',
        )
        .toList();
  }

  static List<SalahFactorOption> challengeFor(String subject) {
    if (isNightPrayer(subject)) {
      return challenge
          .where((factor) => factor.id != 'salah.workCommitment')
          .toList();
    }
    return challenge.where((factor) => factor.id != 'salah.overslept').toList();
  }

  static List<SalahFactorOption> withExisting(
    List<SalahFactorOption> catalog,
    Iterable<String> existingIds,
  ) {
    final next = [...catalog];
    for (final id in existingIds) {
      if (id.isEmpty) continue;
      if (next.any((factor) => factor.id == id)) continue;
      final known = find(id);
      if (known != null) next.add(known);
    }
    return next;
  }

  static SalahFactorOption? find(String id) {
    for (final option in [...support, ...challenge]) {
      if (option.id == id) return option;
    }
    return null;
  }
}

class SalahFactorCapture {
  const SalahFactorCapture({
    this.supportIds = const [],
    this.challengeIds = const [],
    this.otherText,
  });

  final List<String> supportIds;
  final List<String> challengeIds;
  final String? otherText;

  bool get isEmpty =>
      supportIds.isEmpty &&
      challengeIds.isEmpty &&
      (otherText == null || otherText!.trim().isEmpty);

  Map<String, dynamic> toJson() {
    return {
      if (supportIds.isNotEmpty) 'support': supportIds,
      if (challengeIds.isNotEmpty) 'challenge': challengeIds,
      if (otherText != null && otherText!.trim().isNotEmpty)
        'other': otherText!.trim(),
    };
  }

  static SalahFactorCapture? fromJson(Object? json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final support = _ids(map['support']);
    final challenge = _ids(map['challenge']);
    final other = map['other'];
    final capture = SalahFactorCapture(
      supportIds: support,
      challengeIds: challenge,
      otherText: other is String && other.trim().isNotEmpty
          ? other.trim()
          : null,
    );
    return capture.isEmpty ? null : capture;
  }

  static List<String> _ids(Object? raw) {
    if (raw is! List) return const [];
    final ids = <String>[];
    for (final item in raw) {
      if (item is String && item.isNotEmpty && !ids.contains(item)) {
        ids.add(item);
      }
    }
    return ids;
  }
}
