import 'dart:convert';

import 'monitor_domain.dart';
import 'personal_mix.dart';

const kCustomSelectionSetCount = 3;
const kCustomSelectionSetNameMaxLength = 32;

class CustomSelectionSet {
  const CustomSelectionSet({
    required this.id,
    this.name = '',
    this.domains = const {},
    this.mix = PersonalMix.sameAsDomains,
  });

  final int id;
  final String name;
  final Set<MonitorDomain> domains;
  final PersonalMix mix;

  String get displayTitle {
    if (name.isEmpty) return 'Custom #$id';
    return 'Custom #$id ($name)';
  }

  CustomSelectionSet copyWith({
    String? name,
    Set<MonitorDomain>? domains,
    PersonalMix? mix,
  }) {
    return CustomSelectionSet(
      id: id,
      name: name ?? this.name,
      domains: domains ?? this.domains,
      mix: mix ?? this.mix,
    );
  }
}

class CustomSelectionSetsRecord {
  const CustomSelectionSetsRecord({this.activeSlotId, required this.slots});

  final int? activeSlotId;
  final List<CustomSelectionSet> slots;

  factory CustomSelectionSetsRecord.empty() {
    return CustomSelectionSetsRecord(
      slots: [
        for (var id = 1; id <= kCustomSelectionSetCount; id++)
          CustomSelectionSet(id: id),
      ],
    );
  }

  CustomSelectionSet slotById(int id) {
    for (final slot in slots) {
      if (slot.id == id) return slot;
    }
    return CustomSelectionSet(id: id);
  }

  CustomSelectionSetsRecord replacingSlot(CustomSelectionSet next) {
    return CustomSelectionSetsRecord(
      activeSlotId: activeSlotId,
      slots: [
        for (final slot in slots)
          if (slot.id == next.id) next else slot,
      ],
    );
  }

  CustomSelectionSetsRecord copyWithActive(int? id) {
    return CustomSelectionSetsRecord(activeSlotId: id, slots: slots);
  }
}

enum CustomSlotStatus { active, modified, saved }

String sanitizeCustomSlotName(String raw) {
  final collapsed = raw.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  if (collapsed.length <= kCustomSelectionSetNameMaxLength) return collapsed;
  return collapsed.substring(0, kCustomSelectionSetNameMaxLength).trim();
}

int? normalizeCustomSlotId(Object? value) {
  final id = value is int ? value : int.tryParse('$value');
  if (id == null || id < 1 || id > kCustomSelectionSetCount) return null;
  return id;
}

bool sameCustomFilter({
  required CustomSelectionSet slot,
  required Set<MonitorDomain> domains,
  required PersonalMix mix,
}) {
  return sameVisibleDomains(slot.domains, domains) &&
      encodePersonalMix(slot.mix) == encodePersonalMix(mix);
}

CustomSlotStatus customSlotStatus({
  required CustomSelectionSet slot,
  required int? activeSlotId,
  required Set<MonitorDomain> workingDomains,
  required PersonalMix workingMix,
}) {
  if (activeSlotId != slot.id) return CustomSlotStatus.saved;
  if (sameCustomFilter(
    slot: slot,
    domains: workingDomains,
    mix: workingMix,
  )) {
    return CustomSlotStatus.active;
  }
  return CustomSlotStatus.modified;
}

bool workingModifiedFromActive({
  required CustomSelectionSetsRecord record,
  required Set<MonitorDomain> workingDomains,
  required PersonalMix workingMix,
}) {
  final id = record.activeSlotId;
  if (id == null) return false;
  return !sameCustomFilter(
    slot: record.slotById(id),
    domains: workingDomains,
    mix: workingMix,
  );
}

CustomSelectionSetsRecord decodeCustomSelectionSets(String? raw) {
  if (raw == null || raw.isEmpty) return CustomSelectionSetsRecord.empty();
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return CustomSelectionSetsRecord.empty();
    final byId = <int, CustomSelectionSet>{};
    final list = decoded['slots'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;
        final id = normalizeCustomSlotId(item['id']);
        if (id == null) continue;
        final domainsRaw = item['domains'];
        byId[id] = CustomSelectionSet(
          id: id,
          name: sanitizeCustomSlotName('${item['name'] ?? ''}'),
          domains: decodeVisibleDomains(
            domainsRaw is String ? domainsRaw : '',
          ),
          mix: decodePersonalMix(item['mix'] is String ? item['mix'] : null),
        );
      }
    }
    return CustomSelectionSetsRecord(
      activeSlotId: normalizeCustomSlotId(decoded['activeSlotId']),
      slots: [
        for (var id = 1; id <= kCustomSelectionSetCount; id++)
          byId[id] ?? CustomSelectionSet(id: id),
      ],
    );
  } catch (_) {
    return CustomSelectionSetsRecord.empty();
  }
}

String encodeCustomSelectionSets(CustomSelectionSetsRecord record) {
  final slots = [
    for (var id = 1; id <= kCustomSelectionSetCount; id++)
      record.slotById(id),
  ];
  return jsonEncode({
    'v': 1,
    'activeSlotId': record.activeSlotId,
    'slots': [
      for (final slot in slots)
        {
          'id': slot.id,
          'name': slot.name,
          'domains': encodeVisibleDomains(slot.domains),
          'mix': encodePersonalMix(slot.mix),
        },
    ],
  });
}
