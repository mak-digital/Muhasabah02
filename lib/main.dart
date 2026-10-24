import 'package:flutter/material.dart';

import 'app/boot.dart';
import 'debug/startup_probe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StartupProbe.mark('engine_binding');
  runApp(const MuhasabahBoot());
  StartupProbe.mark('run_app');
}
