import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/date_key.dart';

/// Refreshes date-derived [nowProvider] on resume, locale change, and at the
/// next device-local midnight. Independent of app-lock / authentication.
class CurrentDateBinder extends ConsumerStatefulWidget {
  const CurrentDateBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CurrentDateBinder> createState() => _CurrentDateBinderState();
}

class _CurrentDateBinderState extends ConsumerState<CurrentDateBinder>
    with WidgetsBindingObserver {
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightTimer();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAndReschedule();
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _refreshAndReschedule();
  }

  void _refreshAndReschedule() {
    refreshNowIfLocalDateChanged(ref);
    _scheduleMidnightTimer();
  }

  void _scheduleMidnightTimer() {
    _midnightTimer?.cancel();
    if (!mounted) return;
    final now = ref.read(nowClockProvider)();
    _midnightTimer = Timer(delayUntilNextLocalMidnight(now), () {
      if (!mounted) return;
      _refreshAndReschedule();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
