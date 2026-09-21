import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/device_unlock.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../shared/brand_mark.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  var _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlockIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final enabled = ref.read(appPrefsProvider).appLockEnabled;
    if (!enabled) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (!_authenticating) {
        ref.read(appSessionUnlockedProvider.notifier).state = false;
      }
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _unlockIfNeeded();
    }
  }

  Future<void> _unlockIfNeeded() async {
    final prefs = ref.read(appPrefsProvider);
    if (!prefs.appLockEnabled) return;
    if (ref.read(appSessionUnlockedProvider)) return;
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final ok = await ref
        .read(deviceUnlockProvider)
        .authenticate(reason: Copy.appLockReason);
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (ok) {
      ref.read(appSessionUnlockedProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final locked =
        ref.watch(appPrefsProvider).appLockEnabled &&
        !ref.watch(appSessionUnlockedProvider);
    if (!locked) return widget.child;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const BrandMark(size: 88),
              const SizedBox(height: 24),
              Text(
                Copy.appLockTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                Copy.appLockBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _authenticating ? null : _unlockIfNeeded,
                child: Text(
                  _authenticating ? Copy.appLockWaiting : Copy.appLockUnlock,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
