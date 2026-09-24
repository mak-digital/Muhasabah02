import 'home_traces.dart';
import 'monitor_domain.dart';
import 'quran.dart';
import 'salah_extras.dart';

const kZakatMixKey = 'zakat';
const kHajjMixKey = 'hajj';

enum PersonalMixKind {
  sameAsDomains,
  firstLook,
  worship,
  characterRights,
  trusts,
  people,
  custom,
}

extension PersonalMixKindX on PersonalMixKind {
  String get label => switch (this) {
    PersonalMixKind.sameAsDomains => 'Same as Domains',
    PersonalMixKind.firstLook => 'First season',
    PersonalMixKind.worship => 'Worship I notice',
    PersonalMixKind.characterRights => 'Character & rights',
    PersonalMixKind.trusts => 'Trusts I notice',
    PersonalMixKind.people => 'People I notice',
    PersonalMixKind.custom => 'Custom',
  };
}

class MixItem {
  const MixItem({
    required this.id,
    required this.domain,
    required this.band,
    required this.label,
  });

  final String id;
  final MonitorDomain domain;
  final String band;
  final String label;
}

class PersonalMix {
  const PersonalMix({required this.kind, required this.keys});

  final PersonalMixKind kind;
  final Set<String> keys;

  static const sameAsDomains = PersonalMix(
    kind: PersonalMixKind.sameAsDomains,
    keys: {},
  );

  PersonalMix copyWith({PersonalMixKind? kind, Set<String>? keys}) {
    return PersonalMix(kind: kind ?? this.kind, keys: keys ?? this.keys);
  }
}

List<HomeTraceRow> homeTraceRowsFor(MonitorDomain domain) {
  return switch (domain) {
    MonitorDomain.hadith => hadithHomeRows,
    MonitorDomain.dhikr => dhikrHomeRows,
    MonitorDomain.akhlaq => akhlaqHomeRows,
    MonitorDomain.huquq => huquqHomeRows,
    MonitorDomain.knowledge => knowledgeHomeRows,
    MonitorDomain.time => timeHomeRows,
    MonitorDomain.health => healthHomeRows,
    MonitorDomain.wealth => wealthHomeRows,
    MonitorDomain.ummah => ummahHomeRows,
    MonitorDomain.fasting => fastingHomeRows,
    MonitorDomain.hajj => hajjHomeRows,
    MonitorDomain.charity => charityHomeRows,
    MonitorDomain.salah || MonitorDomain.quran => const [],
  };
}

List<HomeTraceRow> homeTraceRowsForVisible(Set<MonitorDomain> visible) {
  return [
    for (final domain in MonitorDomain.values)
      if (visible.contains(domain)) ...homeTraceRowsFor(domain),
  ];
}

final mixCatalog = _buildMixCatalog();

final mixItemById = {for (final item in mixCatalog) item.id: item};

List<MixItem> _buildMixCatalog() {
  final items = <MixItem>[];
  for (final row in SalahTraceRow.values) {
    final band = row.isObligatory
        ? 'Obligatory Salah'
        : row.isFridayPrayer
        ? 'Friday Prayer'
        : 'Voluntary Prayers';
    items.add(
      MixItem(
        id: 'salah.${row.name}',
        domain: MonitorDomain.salah,
        band: band,
        label: row.label,
      ),
    );
  }
  for (final dimension in quranDailyDimensions) {
    items.add(
      MixItem(
        id: 'quran.${dimension.name}',
        domain: MonitorDomain.quran,
        band: dimension.homeBand,
        label: dimension.label,
      ),
    );
  }
  for (final domain in MonitorDomain.values) {
    for (final row in homeTraceRowsFor(domain)) {
      items.add(
        MixItem(
          id: row.storageKey,
          domain: domain,
          band: row.band,
          label: row.label,
        ),
      );
    }
  }
  items.add(
    const MixItem(
      id: kZakatMixKey,
      domain: MonitorDomain.charity,
      band: 'Zakat status',
      label: 'Zakat',
    ),
  );
  items.add(
    const MixItem(
      id: kHajjMixKey,
      domain: MonitorDomain.hajj,
      band: 'Hajj status',
      label: 'Hajj',
    ),
  );
  return items;
}

Set<String> mixKeysWhere(bool Function(MixItem item) test) {
  return {
    for (final item in mixCatalog)
      if (test(item)) item.id,
  };
}

final kWorshipMixKeys = mixKeysWhere(
  (item) =>
      (item.domain == MonitorDomain.salah && item.band == 'Obligatory Salah') ||
      item.id == 'quran.reading' ||
      item.id == 'quran.meaning' ||
      item.id == 'quran.reflection' ||
      (item.domain == MonitorDomain.hadith &&
          (item.band == 'Encounter' || item.id == 'hadith.livedSunnah')) ||
      (item.domain == MonitorDomain.dhikr &&
          item.band == 'Post-fard Salah Adhkar') ||
      item.id == kHajjMixKey ||
      item.id == kHajjPreparationKey,
);

final kCharacterRightsMixKeys = mixKeysWhere(
  (item) =>
      item.domain == MonitorDomain.akhlaq ||
      (item.domain == MonitorDomain.huquq &&
          (item.band == 'Household' || item.band == 'Repair')) ||
      (item.domain == MonitorDomain.knowledge &&
          item.band == 'Beneficial speech'),
);

final kTrustsMixKeys = mixKeysWhere(
  (item) =>
      item.domain == MonitorDomain.time ||
      item.domain == MonitorDomain.health ||
      item.domain == MonitorDomain.wealth ||
      (item.domain == MonitorDomain.charity &&
          (item.band == 'Giving' || item.id == kZakatMixKey)),
);

final kPeopleMixKeys = mixKeysWhere(
  (item) =>
      item.domain == MonitorDomain.huquq ||
      item.domain == MonitorDomain.ummah ||
      (item.domain == MonitorDomain.charity && item.band == 'Care'),
);

/// First-season mix for the Salah, Qur’an & Dhikr look: obligatory Salah,
/// selected Qur’an Journey rows, lived Sunnah, two Dhikr rows, Parents, giving, and Zakat.
final kFirstLookMixKeys = mixKeysWhere(
  (item) =>
      (item.domain == MonitorDomain.salah && item.band == 'Obligatory Salah') ||
      item.id == 'quran.reading' ||
      item.id == 'quran.meaning' ||
      item.id == 'quran.reflection' ||
      item.id == 'quran.consciousApplication' ||
      item.id == 'hadith.livedSunnah' ||
      item.id == 'dhikr.postFardFajr' ||
      item.id == 'dhikr.morningAdhkar' ||
      item.id == 'huquq.parents' ||
      item.id == 'charity.voluntary' ||
      item.id == kZakatMixKey,
);

Set<String> namedMixKeys(PersonalMixKind kind) {
  return switch (kind) {
    PersonalMixKind.firstLook => kFirstLookMixKeys,
    PersonalMixKind.worship => kWorshipMixKeys,
    PersonalMixKind.characterRights => kCharacterRightsMixKeys,
    PersonalMixKind.trusts => kTrustsMixKeys,
    PersonalMixKind.people => kPeopleMixKeys,
    PersonalMixKind.sameAsDomains || PersonalMixKind.custom => const {},
  };
}

PersonalMix mixForKind(PersonalMixKind kind, {Set<String>? customKeys}) {
  if (kind == PersonalMixKind.custom) {
    return PersonalMix(kind: kind, keys: {...?customKeys});
  }
  if (kind == PersonalMixKind.sameAsDomains) {
    return PersonalMix.sameAsDomains;
  }
  return PersonalMix(kind: kind, keys: namedMixKeys(kind));
}

Set<String> keysForVisibleDomains(Set<MonitorDomain> visible) {
  return {
    for (final item in mixCatalog)
      if (visible.contains(item.domain)) item.id,
  };
}

Set<String> editableMixKeys(PersonalMix mix, Set<MonitorDomain> visible) {
  if (mix.kind == PersonalMixKind.sameAsDomains) {
    return keysForVisibleDomains(visible);
  }
  if (mix.kind == PersonalMixKind.custom) return {...mix.keys};
  return {...namedMixKeys(mix.kind)};
}

Set<String> resolvePersonalMixKeys(
  PersonalMix mix,
  Set<MonitorDomain> visible,
) {
  if (mix.kind == PersonalMixKind.sameAsDomains) {
    return keysForVisibleDomains(visible);
  }
  return {
    for (final id in mix.keys)
      if (mixItemById.containsKey(id) &&
          visible.contains(mixItemById[id]!.domain))
        id,
  };
}

bool mixTouchesDomain(Set<String> keys, MonitorDomain domain) {
  for (final id in keys) {
    if (mixItemById[id]?.domain == domain) return true;
  }
  return false;
}

bool mixUsesCompactHomeWeek(
  MonitorDomain domain,
  PersonalMix mix,
  Set<MonitorDomain> visible,
) {
  if (mix.kind == PersonalMixKind.sameAsDomains) {
    return usesCompactHomeWeek(domain);
  }
  return !mixTouchesDomain(resolvePersonalMixKeys(mix, visible), domain);
}

List<MonitorDomain> orderedVisibleDomains(
  Set<MonitorDomain> visible,
  PersonalMix mix,
) {
  final keys = resolvePersonalMixKeys(mix, visible);
  if (mix.kind == PersonalMixKind.sameAsDomains) {
    return [
      for (final domain in MonitorDomain.values)
        if (visible.contains(domain)) domain,
    ];
  }
  final mixFirst = <MonitorDomain>[];
  final rest = <MonitorDomain>[];
  for (final domain in MonitorDomain.values) {
    if (!visible.contains(domain)) continue;
    if (mixTouchesDomain(keys, domain)) {
      mixFirst.add(domain);
    } else {
      rest.add(domain);
    }
  }
  return [...mixFirst, ...rest];
}

/// Home week grids follow the mix. Review still uses [orderedVisibleDomains].
List<MonitorDomain> homeMixDomains(
  Set<MonitorDomain> visible,
  PersonalMix mix,
) {
  final keys = resolvePersonalMixKeys(mix, visible);
  if (mix.kind == PersonalMixKind.sameAsDomains || keys.isEmpty) {
    return orderedVisibleDomains(visible, PersonalMix.sameAsDomains);
  }
  return [
    for (final domain in MonitorDomain.values)
      if (visible.contains(domain) && mixTouchesDomain(keys, domain)) domain,
  ];
}

bool mixIncludesQuran(Set<String> keys) =>
    mixTouchesDomain(keys, MonitorDomain.quran);

List<SalahTraceRow> mixSalahRows(Set<String> keys) {
  return [
    for (final row in SalahTraceRow.values)
      if (keys.contains('salah.${row.name}')) row,
  ];
}

List<QuranDimension> mixQuranDimensions(Set<String> keys) {
  return [
    for (final dimension in quranDailyDimensions)
      if (keys.contains('quran.${dimension.name}')) dimension,
  ];
}

List<HomeTraceRow> mixTraceRows(MonitorDomain domain, Set<String> keys) {
  return [
    for (final row in homeTraceRowsFor(domain))
      if (keys.contains(row.storageKey)) row,
  ];
}

bool mixIncludesZakat(Set<String> keys) => keys.contains(kZakatMixKey);

bool mixIncludesHajj(Set<String> keys) =>
    keys.contains(kHajjMixKey) || keys.contains(kHajjPreparationKey);

Set<MonitorDomain> hiddenDomainsInMix(
  PersonalMix mix,
  Set<MonitorDomain> visible,
) {
  if (mix.kind == PersonalMixKind.sameAsDomains) return {};
  final ids = mix.kind == PersonalMixKind.custom
      ? mix.keys
      : namedMixKeys(mix.kind);
  return {
    for (final id in ids)
      if (mixItemById[id] != null && !visible.contains(mixItemById[id]!.domain))
        mixItemById[id]!.domain,
  };
}

String domainsSettingsSubtitle(Set<MonitorDomain> visible, PersonalMix mix) {
  return '${visibleDomainsSummary(visible)} · Mix: ${personalMixSummary(mix)}';
}

String personalMixSummary(PersonalMix mix) => mix.kind.label;

String? personalMixSeasonLine(PersonalMix mix, Set<MonitorDomain> visible) {
  if (mix.kind == PersonalMixKind.sameAsDomains) return null;
  final keys = resolvePersonalMixKeys(mix, visible);
  if (keys.isEmpty) return null;
  final labels = <String>[];
  for (final item in mixCatalog) {
    if (!keys.contains(item.id)) continue;
    labels.add(item.label);
    if (labels.length == 8) break;
  }
  final more = keys.length > labels.length;
  final joined = labels.join(', ');
  return more ? '$joined…' : joined;
}

PersonalMix decodePersonalMix(String? raw) {
  if (raw == null || raw.isEmpty) return PersonalMix.sameAsDomains;
  final parts = raw.split('|');
  final kindName = parts.first;
  final kind = PersonalMixKind.values.firstWhere(
    (item) => item.name == kindName,
    orElse: () => PersonalMixKind.custom,
  );
  if (kind == PersonalMixKind.sameAsDomains) return PersonalMix.sameAsDomains;
  if (kind != PersonalMixKind.custom) return mixForKind(kind);
  final keys = <String>{};
  if (parts.length > 1) {
    for (final id in parts[1].split(',')) {
      final trimmed = id.trim();
      if (mixItemById.containsKey(trimmed)) keys.add(trimmed);
    }
  }
  return PersonalMix(kind: PersonalMixKind.custom, keys: keys);
}

String encodePersonalMix(PersonalMix mix) {
  if (mix.kind == PersonalMixKind.sameAsDomains) return mix.kind.name;
  if (mix.kind != PersonalMixKind.custom) return mix.kind.name;
  final ids = [
    for (final item in mixCatalog)
      if (mix.keys.contains(item.id)) item.id,
  ];
  return '${mix.kind.name}|${ids.join(',')}';
}
