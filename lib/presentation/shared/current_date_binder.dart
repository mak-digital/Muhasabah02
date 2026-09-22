import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';

/// Refreshes date-derived [nowProvider] when the app resumes on a new
/// local calendar date. Independent of app-lock / authentication.
class CurrentDateBinder extends ConsumerStatefulWidget {
  const CurrentDateBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CurrentDateBinder> createState() => _CurrentDateBinderState();
}

class _CurrentDateBinderState extends ConsumerState<CurrentDateBinder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshNowIfLocalDateChanged(ref);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
