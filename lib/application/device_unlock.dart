import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:local_auth/local_auth.dart';

abstract class DeviceUnlock {
  Future<bool> canAuthenticate();

  Future<bool> authenticate({required String reason});
}

class LocalAuthDeviceUnlock implements DeviceUnlock {
  LocalAuthDeviceUnlock({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> canAuthenticate() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final deviceUnlockProvider = Provider<DeviceUnlock>(
  (ref) => LocalAuthDeviceUnlock(),
);

final appSessionUnlockedProvider = StateProvider<bool>((ref) => false);
