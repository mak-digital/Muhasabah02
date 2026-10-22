import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/copy.dart';

const kBrandWash = Color(0xFFD7ECEB);
const kBrandMark = Color(0xFF2F6F73);
const kBrandHalo = Color(0xFFF3ECC0);

/// Adaptive-icon / Android 12 splash circle is ~66dp of a 108dp canvas.
const kBrandMarkSafeRadius = 0.30;

class BrandMarkGeometry {
  const BrandMarkGeometry({
    required this.filledCenter,
    required this.filledRadius,
    required this.haloRadius,
    required this.haloStroke,
    required this.dots,
    required this.dotRadius,
  });

  final Offset filledCenter;
  final double filledRadius;
  final double haloRadius;
  final double haloStroke;
  final List<Offset> dots;
  final double dotRadius;
}

BrandMarkGeometry brandMarkGeometry(double s) {
  const origin = Offset(0.5, 0.5);
  const filledC = Offset(0.42, 0.40);
  const filledR = 0.22;
  const haloExtra = 0.018;
  const haloStroke = 0.028;
  const dottedC = Offset(0.66, 0.66);
  const dottedR = 0.155;
  const dotR = 0.012;
  const count = 20;
  final haloOuter = filledR + haloExtra + haloStroke / 2;

  var maxDist = (filledC - origin).distance + haloOuter;
  final dottedDist = (dottedC - origin).distance + dottedR + dotR;
  if (dottedDist > maxDist) maxDist = dottedDist;
  final scale = maxDist == 0
      ? 1.0
      : math.min(1.0, kBrandMarkSafeRadius / maxDist);

  Offset map(Offset unit) {
    return Offset(
      s * (origin.dx + (unit.dx - origin.dx) * scale),
      s * (origin.dy + (unit.dy - origin.dy) * scale),
    );
  }

  return BrandMarkGeometry(
    filledCenter: map(filledC),
    filledRadius: filledR * scale * s,
    haloRadius: (filledR + haloExtra) * scale * s,
    haloStroke: haloStroke * scale * s,
    dots: [
      for (var i = 0; i < count; i++)
        map(
          Offset(
            dottedC.dx + dottedR * math.cos((math.pi * 2 * i) / count),
            dottedC.dy + dottedR * math.sin((math.pi * 2 * i) / count),
          ),
        ),
    ],
    dotRadius: math.max(1.0, dotR * scale * s),
  );
}

void paintBrandMark(Canvas canvas, Size size, {required bool background}) {
  if (background) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kBrandWash);
  }
  final s = size.shortestSide;
  canvas.save();
  canvas.clipRect(Offset.zero & Size(s, s));
  final g = brandMarkGeometry(s);
  canvas.drawCircle(
    g.filledCenter,
    g.haloRadius,
    Paint()
      ..color = kBrandHalo
      ..style = PaintingStyle.stroke
      ..strokeWidth = g.haloStroke
      ..isAntiAlias = true,
  );
  canvas.drawCircle(
    g.filledCenter,
    g.filledRadius,
    Paint()
      ..color = kBrandMark
      ..isAntiAlias = true,
  );
  final dotPaint = Paint()
    ..color = kBrandMark
    ..isAntiAlias = true;
  for (final dot in g.dots) {
    canvas.drawCircle(dot, g.dotRadius, dotPaint);
  }
  canvas.restore();
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Copy.appName,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: CustomPaint(
          size: Size.square(size),
          painter: const _BrandMarkPainter(),
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    paintBrandMark(canvas, size, background: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
