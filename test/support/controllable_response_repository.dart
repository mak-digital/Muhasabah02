import 'dart:async';

import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/data/repositories.dart';
import 'package:muhasabah02/domain/personal_response.dart';

class ControllableResponseRepository implements ResponseRepository {
  ControllableResponseRepository({MemoryResponseRepository? inner})
    : inner = inner ?? MemoryResponseRepository();

  final MemoryResponseRepository inner;
  Completer<void>? saveGate;
  var throwOnSave = false;
  var saveCount = 0;

  @override
  List<String> get corruptKeys => inner.corruptKeys;

  @override
  Future<List<PersonalResponse>> allHealthy() => inner.allHealthy();

  @override
  Future<PersonalResponse?> getById(String id) => inner.getById(id);

  @override
  Future<void> save(PersonalResponse record) async {
    saveCount++;
    final gate = saveGate;
    if (gate != null) await gate.future;
    if (throwOnSave) throw StateError('save failed');
    return inner.save(record);
  }

  @override
  Future<bool> delete(String id) => inner.delete(id);
}
