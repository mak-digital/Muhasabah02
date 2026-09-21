import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/copy.dart';

const kBrandWash = Color(0xFFD7ECEB);
const kBrandMark = Color(0xFF2F6F73);
const kBrandHalo = Color(0xFFF3ECC0);

void paintBrandMark(Canvas canvas, Size size, {required bool background}) {
  if (background) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kBrandWash);
  }
  final s = size.shortestSide;
  final filledCenter = Offset(s * 0.42, s * 0.40);
  final filledRadius = s * 0.22;
  canvas.drawCircle(
    filledCenter,
    filledRadius + s * 0.018,
    Paint()
      ..color = kBrandHalo
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.028
      ..isAntiAlias = true,
  );
  canvas.drawCircle(
    filledCenter,
    filledRadius,
    Paint()
      ..color = kBrandMark
      ..isAntiAlias = true,
  );

  final dottedCenter = Offset(s * 0.66, s * 0.66);
  final dottedRadius = s * 0.155;
  final dotRadius = math.max(1.0, s * 0.012);
  const count = 20;
  final dotPaint = Paint()
    ..color = kBrandMark
    ..isAntiAlias = true;
  for (var i = 0; i < count; i++) {
    final angle = (math.pi * 2 * i) / count;
    final dot = Offset(
      dottedCenter.dx + dottedRadius * math.cos(angle),
      dottedCenter.dy + dottedRadius * math.sin(angle),
    );
    canvas.drawCircle(dot, dotRadius, dotPaint);
  }
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
