import 'package:muhasabah02/application/device_unlock.dart';

class FakeDeviceUnlock implements DeviceUnlock {
  FakeDeviceUnlock({this.available = true, this.succeeds = true});

  bool available;
  bool succeeds;
  var authenticateCalls = 0;

  @override
  Future<bool> canAuthenticate() async => available;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    return succeeds;
  }
}
