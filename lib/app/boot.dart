import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../application/providers.dart';
import '../data/hive_repositories.dart';
import '../data/privacy_log.dart';
import '../debug/startup_probe.dart';
import '../domain/copy.dart';
import 'app.dart';

/// Opens on-device boxes. Used after the first Flutter frame so the Android
/// splash can lift instead of waiting on Hive.
Future<List<Override>> loadDevicePersistence() async {
  StartupProbe.mark('persistence_start');
  try {
    final opened = await openHiveRepositories().timeout(
      const Duration(seconds: 12),
    );
    logAppEvent('persistence_ready');
    StartupProbe.mark('persistence_ready');
    return [
      checkInRepositoryProvider.overrideWithValue(opened.checkIns),
      responseRepositoryProvider.overrideWithValue(opened.responses),
      domainActionRepositoryProvider.overrideWithValue(opened.domainActions),
      devFeedbackRepositoryProvider.overrideWithValue(opened.devFeedback),
      practiceHadithRepositoryProvider.overrideWithValue(opened.practiceHadith),
      personalQuranVerseRepositoryProvider.overrideWithValue(
        opened.personalQuran,
      ),
      personalHadithRepositoryProvider.overrideWithValue(opened.personalHadith),
      appPrefsProvider.overrideWithValue(opened.prefs),
      hajjStoreRepositoryProvider.overrideWithValue(opened.hajj),
      productivityStoreRepositoryProvider.overrideWithValue(
        opened.productivity,
      ),
    ];
  } catch (_) {
    logAppEvent('persistence_fallback_memory');
    StartupProbe.mark('persistence_fallback');
    return const [];
  }
}

/// First frame is the launch mark. Home waits until [loader] finishes.
class MuhasabahBoot extends StatefulWidget {
  const MuhasabahBoot({super.key, this.loader});

  final Future<List<Override>> Function()? loader;

  @override
  State<MuhasabahBoot> createState() => _MuhasabahBootState();
}

class _MuhasabahBootState extends State<MuhasabahBoot> {
  List<Override>? _overrides;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final load = widget.loader ?? loadDevicePersistence;
      load().then((overrides) {
        if (!mounted) return;
        StartupProbe.mark('boot_apply_overrides');
        setState(() => _overrides = overrides);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final overrides = _overrides;
    if (overrides == null) {
      StartupProbe.mark('boot_hold');
      return const BootHold();
    }
    StartupProbe.mark('app_scope');
    return ProviderScope(overrides: overrides, child: const MuhasabahApp());
  }
}

/// Same pale field and two-circle mark as the Android launch icon.
class BootHold extends StatelessWidget {
  const BootHold({super.key});

  static const background = Color(0xFFD7ECEB);
  static const family = Color(0xFF2F6F73);
  static const ring = Color(0xFFF3ECC0);

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        key: Key('app-boot-hold'),
        color: background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 168,
                height: 168,
                child: CustomPaint(painter: _BootMarkPainter()),
              ),
              Text(
                Copy.openingYourRecord,
                style: TextStyle(
                  color: family,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BootMarkPainter extends CustomPainter {
  const _BootMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 108;
    canvas.scale(scale);
    canvas.translate(-22, -22);
    canvas.drawCircle(
      const Offset(47.41, 45.76),
      19.61,
      Paint()
        ..color = BootHold.ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.31,
    );
    canvas.drawCircle(
      const Offset(47.41, 45.76),
      18.12,
      Paint()..color = BootHold.family,
    );
    final dots = Paint()..color = BootHold.family;
    const centres = <Offset>[
      Offset(79.95, 67.18),
      Offset(79.33, 71.13),
      Offset(77.51, 74.69),
      Offset(74.69, 77.51),
      Offset(71.13, 79.33),
      Offset(67.18, 79.95),
      Offset(63.24, 79.33),
      Offset(59.68, 77.51),
      Offset(56.85, 74.69),
      Offset(55.04, 71.13),
      Offset(54.41, 67.18),
      Offset(55.04, 63.24),
      Offset(56.85, 59.68),
      Offset(59.68, 56.85),
      Offset(63.24, 55.04),
      Offset(67.18, 54.41),
      Offset(71.13, 55.04),
      Offset(74.69, 56.85),
      Offset(77.51, 59.68),
      Offset(79.33, 63.24),
    ];
    for (final centre in centres) {
      canvas.drawCircle(centre, 1, dots);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
