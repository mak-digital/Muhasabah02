import 'package:flutter/foundation.dart';

void logAppEvent(String event, {String? opaqueId}) {
  assert(() {
    final suffix = opaqueId == null ? '' : ' id=$opaqueId';
    debugPrint('muhasabah:$event$suffix');
    return true;
  }());
}
