import '../domain/daily_check_in.dart';
import '../domain/dev_feedback.dart';
import '../domain/domain_action.dart';
import '../domain/personal_hadith.dart';
import '../domain/personal_quran_verse.dart';
import '../domain/personal_response.dart';
import '../domain/practice_hadith.dart';
import '../domain/hajj_planning.dart';
import '../domain/productivity_planning.dart';
import 'codecs.dart';
import 'repositories.dart';

class MemoryCheckInRepository implements CheckInRepository {
  MemoryCheckInRepository({Map<String, String>? raw}) : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<DailyCheckIn>> allHealthy() async {
    final batch = await decodeStoredCheckIns(
      keys: _raw.keys,
      read: (key) => _raw['$key'],
    );
    _corrupt
      ..clear()
      ..addAll(batch.corruptKeys);
    return batch.healthy;
  }

  @override
  Future<DailyCheckIn?> getByDate(String dateKey) async {
    final raw = _raw[dateKey];
    if (raw == null) return null;
    final parsed = decodeCheckIn(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(dateKey)) _corrupt.add(dateKey);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(DailyCheckIn record) async {
    _raw[record.dateKey] = encodeCheckIn(
      record.copyWith(savedAt: DateTime.now()),
    );
    _corrupt.remove(record.dateKey);
  }

  @override
  Future<bool> delete(String dateKey) async {
    if (!_raw.containsKey(dateKey)) return true;
    try {
      _raw.remove(dateKey);
      _corrupt.remove(dateKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  void putRaw(String key, String value) => _raw[key] = value;
}

class MemoryResponseRepository implements ResponseRepository {
  MemoryResponseRepository({Map<String, String>? raw}) : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PersonalResponse>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PersonalResponse>[];
    for (final entry in _raw.entries) {
      final parsed = decodeResponse(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return healthy;
  }

  @override
  Future<PersonalResponse?> getById(String id) async {
    final raw = _raw[id];
    if (raw == null) return null;
    final parsed = decodeResponse(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PersonalResponse record) async {
    _raw[record.id] = encodeResponse(record);
    _corrupt.remove(record.id);
  }

  @override
  Future<bool> delete(String id) async {
    if (!_raw.containsKey(id)) return true;
    try {
      _raw.remove(id);
      _corrupt.remove(id);
      return true;
    } catch (_) {
      return false;
    }
  }

  void putRaw(String key, String value) => _raw[key] = value;
}

class MemoryDomainActionRepository implements DomainActionRepository {
  MemoryDomainActionRepository({Map<String, String>? raw}) : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<DomainAction>> allHealthy() async {
    _corrupt.clear();
    final healthy = <DomainAction>[];
    for (final entry in _raw.entries) {
      final parsed = decodeDomainAction(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return healthy;
  }

  @override
  Future<DomainAction?> getById(String id) async {
    final raw = _raw[id];
    if (raw == null) return null;
    final parsed = decodeDomainAction(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(DomainAction record) async {
    _raw[record.id] = encodeDomainAction(record);
    _corrupt.remove(record.id);
  }

  @override
  Future<bool> delete(String id) async {
    if (!_raw.containsKey(id)) return true;
    _raw.remove(id);
    _corrupt.remove(id);
    return true;
  }
}

class MemoryDevFeedbackRepository implements DevFeedbackRepository {
  MemoryDevFeedbackRepository({
    Map<String, String>? raw,
    this._nextSerial = 1,
  }) : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];
  int _nextSerial;

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<DevFeedback>> allHealthy() async {
    _corrupt.clear();
    final healthy = <DevFeedback>[];
    for (final entry in _raw.entries) {
      if (entry.key.startsWith('__')) continue;
      final parsed = decodeDevFeedback(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => a.serial.compareTo(b.serial));
    return healthy;
  }

  @override
  Future<DevFeedback?> getById(String id) async {
    final raw = _raw[id];
    if (raw == null) return null;
    final parsed = decodeDevFeedback(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(DevFeedback record) async {
    _raw[record.id] = encodeDevFeedback(record);
    _corrupt.remove(record.id);
    if (record.serial >= _nextSerial) _nextSerial = record.serial + 1;
  }

  @override
  Future<bool> delete(String id) async {
    if (!_raw.containsKey(id)) return true;
    _raw.remove(id);
    _corrupt.remove(id);
    return true;
  }

  @override
  Future<int> nextSerial() async {
    final n = _nextSerial;
    _nextSerial += 1;
    return n;
  }
}

class MemoryPersonalQuranVerseRepository
    implements PersonalQuranVerseRepository {
  MemoryPersonalQuranVerseRepository({Map<String, String>? raw})
    : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PersonalQuranVerse>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PersonalQuranVerse>[];
    for (final entry in _raw.entries) {
      final parsed = decodePersonalQuranVerse(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) {
      final byDate = a.addedDateKey.compareTo(b.addedDateKey);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return healthy;
  }

  @override
  Future<PersonalQuranVerse?> getById(String id) async {
    final raw = _raw[id];
    if (raw == null) return null;
    final parsed = decodePersonalQuranVerse(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PersonalQuranVerse record) async {
    _raw[record.id] = encodePersonalQuranVerse(record);
    _corrupt.remove(record.id);
  }

  @override
  Future<bool> delete(String id) async {
    if (!_raw.containsKey(id)) return true;
    _raw.remove(id);
    _corrupt.remove(id);
    return true;
  }
}

class MemoryPersonalHadithRepository implements PersonalHadithRepository {
  MemoryPersonalHadithRepository({Map<String, String>? raw}) : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PersonalHadith>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PersonalHadith>[];
    for (final entry in _raw.entries) {
      final parsed = decodePersonalHadith(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) {
      final byDate = a.addedDateKey.compareTo(b.addedDateKey);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return healthy;
  }

  @override
  Future<PersonalHadith?> getById(String id) async {
    final raw = _raw[id];
    if (raw == null) return null;
    final parsed = decodePersonalHadith(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PersonalHadith record) async {
    _raw[record.id] = encodePersonalHadith(record);
    _corrupt.remove(record.id);
  }

  @override
  Future<bool> delete(String id) async {
    if (!_raw.containsKey(id)) return true;
    _raw.remove(id);
    _corrupt.remove(id);
    return true;
  }
}

class MemoryPracticeHadithRepository implements PracticeHadithRepository {
  MemoryPracticeHadithRepository({Map<String, String>? raw}) : _raw = raw ?? {};

  final Map<String, String> _raw;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PracticeHadithRecord>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PracticeHadithRecord>[];
    for (final entry in _raw.entries) {
      final parsed = decodePracticeHadith(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    return orderedPracticeHadithRegister(healthy);
  }

  @override
  Future<PracticeHadithRecord?> getById(String id) async {
    final raw = _raw[id];
    if (raw == null) return null;
    final parsed = decodePracticeHadith(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PracticeHadithRecord record) async {
    _raw[record.id] = encodePracticeHadith(record);
    _corrupt.remove(record.id);
  }

  @override
  Future<bool> delete(String id) async {
    if (!_raw.containsKey(id)) return true;
    _raw.remove(id);
    _corrupt.remove(id);
    return true;
  }
}

class MemoryHajjStoreRepository implements HajjStoreRepository {
  MemoryHajjStoreRepository({
    HajjStore? store,
    String? raw,
    this.legacyHajjStatusPresent = false,
  }) : _raw = raw,
       store = store ?? const HajjStore(),
       loadKind = HajjStoreDecodeKind.missing {
    if (raw != null) {
      final decoded = decodeHajjStore(raw);
      loadKind = decoded.kind;
      if (decoded.store != null) {
        this.store = decoded.store!;
        _raw = encodeHajjStore(this.store);
      }
    } else if (store != null) {
      loadKind = HajjStoreDecodeKind.ok;
      _raw = encodeHajjStore(store);
    }
  }

  String? _raw;
  var initializeCount = 0;
  bool legacyHajjStatusPresent;

  @override
  HajjStore store;

  @override
  HajjStoreDecodeKind loadKind;

  @override
  bool get hasUnknownSchema => loadKind == HajjStoreDecodeKind.unknownVersion;

  @override
  Future<void> save(HajjStore next) async {
    if (hasUnknownSchema) return;
    store = next;
    loadKind = HajjStoreDecodeKind.ok;
    _raw = encodeHajjStore(next);
  }

  @override
  Future<HajjStore> initializeIfNeeded() async {
    initializeCount++;
    if (legacyHajjStatusPresent) {
      legacyHajjStatusPresent = false;
    }
    if (hasUnknownSchema) return store;
    if (_raw != null &&
        (loadKind == HajjStoreDecodeKind.ok ||
            loadKind == HajjStoreDecodeKind.corrupt)) {
      return store;
    }
    if (_raw == null) {
      store = const HajjStore();
      loadKind = HajjStoreDecodeKind.ok;
      _raw = encodeHajjStore(store);
    }
    return store;
  }

  String? get persistedRaw => _raw;
}

class MemoryProductivityStoreRepository implements ProductivityStoreRepository {
  MemoryProductivityStoreRepository({ProductivityStore? store})
    : store = store ?? const ProductivityStore(),
      loadKind = ProductivityStoreDecodeKind.ok;

  @override
  ProductivityStore store;

  @override
  ProductivityStoreDecodeKind loadKind;

  @override
  bool get hasUnknownSchema =>
      loadKind == ProductivityStoreDecodeKind.unknownVersion;

  @override
  Future<void> save(ProductivityStore next) async {
    if (hasUnknownSchema) return;
    store = next;
    loadKind = ProductivityStoreDecodeKind.ok;
  }

  @override
  Future<ProductivityStore> initializeIfNeeded() async => store;
}
