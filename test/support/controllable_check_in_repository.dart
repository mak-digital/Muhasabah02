import 'dart:async';

import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/data/repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';

class ControllableCheckInRepository implements CheckInRepository {
  ControllableCheckInRepository({MemoryCheckInRepository? inner})
    : inner = inner ?? MemoryCheckInRepository();

  final MemoryCheckInRepository inner;
  Completer<void>? hydrateGate;
  Completer<void>? saveGate;
  var throwOnSave = false;
  var saveCount = 0;

  @override
  List<String> get corruptKeys => inner.corruptKeys;

  @override
  Future<List<DailyCheckIn>> allHealthy() async {
    final gate = hydrateGate;
    if (gate != null) await gate.future;
    return inner.allHealthy();
  }

  @override
  Future<DailyCheckIn?> getByDate(String dateKey) {
    return inner.getByDate(dateKey);
  }

  @override
  Future<void> save(DailyCheckIn record) async {
    saveCount++;
    final gate = saveGate;
    if (gate != null) await gate.future;
    if (throwOnSave) throw StateError('save failed');
    return inner.save(record);
  }

  @override
  Future<bool> delete(String dateKey) {
    return inner.delete(dateKey);
  }
}
