import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/presentation/shared/brand_mark.dart';

void main() {
  test('write launcher icons', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final root = Directory.current.path;

    Future<void> writePng({
      required String path,
      required int size,
      required bool background,
    }) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      paintBrandMark(
        canvas,
        Size(size.toDouble(), size.toDouble()),
        background: background,
      );
      final image = await recorder.endRecording().toImage(size, size);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    }

    const mipmaps = <String, int>{
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };
    for (final entry in mipmaps.entries) {
      final path =
          '$root/android/app/src/main/res/${entry.key}/ic_launcher.png';
      await writePng(path: path, size: entry.value, background: true);
      await File(path).copy(
        '$root/android/app/src/main/res/${entry.key}/ic_launcher_round.png',
      );
    }

    await File(
      '$root/android/app/src/main/res/drawable/ic_launcher_foreground.xml',
    ).writeAsString(launcherForegroundVector());

    const ios = <String, int>{
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };
    for (final entry in ios.entries) {
      await writePng(
        path:
            '$root/ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
        size: entry.value,
        background: true,
      );
    }

    const web = <String, int>{
      'Icon-192.png': 192,
      'Icon-512.png': 512,
      'Icon-maskable-192.png': 192,
      'Icon-maskable-512.png': 512,
    };
    for (final entry in web.entries) {
      await writePng(
        path: '$root/web/icons/${entry.key}',
        size: entry.value,
        background: true,
      );
    }

    await writePng(
      path: '$root/docs/visual_review/brand/private-muhasabah-icon-1024.png',
      size: 1024,
      background: true,
    );
    await writePng(path: '$root/web/favicon.png', size: 32, background: true);
  }, timeout: const Timeout(Duration(minutes: 2)));
}

String launcherForegroundVector() {
  const s = 108.0;
  final cx = s * 0.42;
  final cy = s * 0.40;
  final r = s * 0.22;
  final haloR = r + s * 0.018;
  final dx = s * 0.66;
  final dy = s * 0.66;
  final dr = s * 0.155;
  final dotR = s * 0.012;
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="utf-8"?>')
    ..writeln(
      '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
    )
    ..writeln('    android:width="108dp"')
    ..writeln('    android:height="108dp"')
    ..writeln('    android:viewportWidth="108"')
    ..writeln('    android:viewportHeight="108">')
    ..writeln('    <path')
    ..writeln('        android:fillColor="#00000000"')
    ..writeln('        android:pathData="${_circlePath(cx, cy, haloR)}"')
    ..writeln('        android:strokeWidth="3"')
    ..writeln('        android:strokeColor="#F3ECC0"/>')
    ..writeln('    <path')
    ..writeln('        android:fillColor="#2F6F73"')
    ..writeln('        android:pathData="${_circlePath(cx, cy, r)}"/>');
  for (var i = 0; i < 20; i++) {
    final angle = (math.pi * 2 * i) / 20;
    final x = dx + dr * math.cos(angle);
    final y = dy + dr * math.sin(angle);
    buffer
      ..writeln('    <path')
      ..writeln('        android:fillColor="#2F6F73"')
      ..writeln('        android:pathData="${_circlePath(x, y, dotR)}"/>');
  }
  buffer.writeln('</vector>');
  return buffer.toString();
}

String _circlePath(double cx, double cy, double r) {
  final x = cx.toStringAsFixed(2);
  final y = cy.toStringAsFixed(2);
  final rr = r.toStringAsFixed(2);
  final d = (2 * r).toStringAsFixed(2);
  return 'M$x,$y m-$rr,0 a$rr,$rr 0 1 1 $d,0 a$rr,$rr 0 1 1 -$d,0';
}
