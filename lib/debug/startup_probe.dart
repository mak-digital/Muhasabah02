import 'package:flutter/foundation.dart';

/// Debug-only elapsed marks. Stage names only — never record contents.
class StartupProbe {
  StartupProbe._();

  static final Stopwatch _watch = Stopwatch()..start();
  static final Set<String> _once = <String>{};

  static int get elapsedMs => _watch.elapsedMilliseconds;

  static void mark(String stage) {
    assert(() {
      if (!_once.add(stage)) return true;
      debugPrint('muhasabah:t $stage ${elapsedMs}ms');
      return true;
    }());
  }
}
