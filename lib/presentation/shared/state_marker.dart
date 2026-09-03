import 'package:flutter/material.dart';

enum MarkerKind { filled, outlined, unanswered, selected }

class RecordedStateMarker extends StatelessWidget {
  const RecordedStateMarker({
    super.key,
    required this.color,
    required this.kind,
    this.symbol,
    this.size = 18,
    required this.semanticLabel,
  });

  final Color color;
  final MarkerKind kind;
  final IconData? symbol;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: CustomPaint(
        size: Size.square(size),
        painter: _MarkerPainter(
          color: color,
          kind: kind,
          border: Theme.of(context).colorScheme.outline,
        ),
        child: symbol == null
            ? null
            : Icon(symbol, size: size * 0.62, color: color),
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter({
    required this.color,
    required this.kind,
    required this.border,
  });

  final Color color;
  final MarkerKind kind;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 1;
    switch (kind) {
      case MarkerKind.filled:
        canvas.drawCircle(center, radius, Paint()..color = color);
        break;
      case MarkerKind.outlined:
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color,
        );
        break;
      case MarkerKind.unanswered:
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = color.withValues(alpha: 0.45)
            ..strokeCap = StrokeCap.round,
        );
        _drawDotted(canvas, center, radius, color.withValues(alpha: 0.45));
        break;
      case MarkerKind.selected:
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = color,
        );
        canvas.drawCircle(center, radius - 4, Paint()..color = color);
        break;
    }
  }

  void _drawDotted(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    const dash = 2.4;
    const gap = 2.0;
    final circumference = 6.2832 * radius;
    final count = (circumference / (dash + gap)).floor();
    for (var i = 0; i < count; i++) {
      final start = (i * (dash + gap)) / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dash / radius,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.kind != kind;
}

MarkerKind markerForRecorded({required bool recorded, required bool positive}) {
  if (!recorded) return MarkerKind.unanswered;
  if (positive) return MarkerKind.filled;
  return MarkerKind.outlined;
}
