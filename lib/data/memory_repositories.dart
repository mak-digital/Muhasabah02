import '../domain/daily_check_in.dart';
import '../domain/personal_response.dart';
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
    _corrupt.clear();
    final healthy = <DailyCheckIn>[];
    for (final entry in _raw.entries) {
      final parsed = decodeCheckIn(entry.value);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add(entry.key);
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return healthy;
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
