import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../domain/activities.dart';

enum MarkerKind { filled, outlined, unanswered, selected, missed }

class RecordedStateMarker extends StatelessWidget {
  const RecordedStateMarker({
    super.key,
    required this.color,
    required this.kind,
    this.symbol,
    this.symbolColor,
    this.symbolSize,
    required this.semanticLabel,
  });

  final Color color;
  final MarkerKind kind;
  final IconData? symbol;
  final Color? symbolColor;
  final double? symbolSize;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: AppDimensions.progressMarker,
        height: AppDimensions.progressMarker,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            CustomPaint(
              size: const Size(
                AppDimensions.progressMarker,
                AppDimensions.progressMarker,
              ),
              painter: _MarkerPainter(color: color, kind: kind),
            ),
            if (symbol != null)
              Icon(
                symbol,
                size: symbolSize ?? AppDimensions.progressMarkerSymbol,
                color: symbolColor ?? color,
              ),
          ],
        ),
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter({required this.color, required this.kind});

  final Color color;
  final MarkerKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - AppDimensions.progressMarkerStroke) / 2;
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
            ..strokeWidth = AppDimensions.progressMarkerStroke
            ..color = color,
        );
        break;
      case MarkerKind.missed:
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = AppDimensions.progressMarkerStroke
            ..color = color,
        );
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(-math.pi / 4);
        canvas.drawLine(
          Offset(-radius * 0.72, 0),
          Offset(radius * 0.72, 0),
          Paint()
            ..color = color
            ..strokeWidth = AppDimensions.progressMarkerStroke
            ..strokeCap = StrokeCap.round,
        );
        canvas.restore();
        break;
      case MarkerKind.unanswered:
        _drawDotted(canvas, center, radius, color.withValues(alpha: 0.45));
        break;
      case MarkerKind.selected:
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = AppDimensions.progressMarkerStroke
            ..color = color,
        );
        canvas.drawCircle(
          center,
          radius - AppDimensions.progressMarkerStroke * 1.5,
          Paint()..color = color,
        );
        break;
    }
  }

  void _drawDotted(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.progressMarkerStroke
      ..strokeCap = StrokeCap.round
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

class ZakatStateMarker extends StatelessWidget {
  const ZakatStateMarker({
    super.key,
    required this.status,
    required this.color,
  });

  final ZakatStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: status.label,
      child: SizedBox(
        width: AppDimensions.progressMarker,
        height: AppDimensions.progressMarker,
        child: CustomPaint(
          painter: _ZakatPainter(color: color, status: status),
        ),
      ),
    );
  }
}

class _ZakatPainter extends CustomPainter {
  _ZakatPainter({required this.color, required this.status});

  final Color color;
  final ZakatStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final side = size.shortestSide * 0.42;
    if (status == ZakatStatus.notApplicable) {
      canvas.drawLine(
        Offset(center.dx - side, center.dy),
        Offset(center.dx + side, center.dy),
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = AppDimensions.progressMarkerStroke
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    final path = Path()
      ..moveTo(center.dx, center.dy - side)
      ..lineTo(center.dx + side, center.dy)
      ..lineTo(center.dx, center.dy + side)
      ..lineTo(center.dx - side, center.dy)
      ..close();
    switch (status) {
      case ZakatStatus.paid:
        canvas.drawPath(path, Paint()..color = color);
      case ZakatStatus.due:
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = AppDimensions.progressMarkerStroke
            ..color = color,
        );
      case ZakatStatus.planned:
        canvas.save();
        canvas.clipPath(path);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width / 2, size.height),
          Paint()..color = color,
        );
        canvas.restore();
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = AppDimensions.progressMarkerStroke
            ..color = color,
        );
      case ZakatStatus.unanswered:
        _drawDottedDiamond(canvas, center, side, color.withValues(alpha: 0.5));
      case ZakatStatus.notApplicable:
        break;
    }
  }

  void _drawDottedDiamond(
    Canvas canvas,
    Offset center,
    double side,
    Color color,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.progressMarkerStroke
      ..color = color;
    final points = [
      Offset(center.dx, center.dy - side),
      Offset(center.dx + side, center.dy),
      Offset(center.dx, center.dy + side),
      Offset(center.dx - side, center.dy),
      Offset(center.dx, center.dy - side),
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZakatPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.status != status;
}

MarkerKind markerForRecorded({required bool recorded, required bool positive}) {
  if (!recorded) return MarkerKind.unanswered;
  if (positive) return MarkerKind.filled;
  return MarkerKind.outlined;
}

class ProgressDayCell extends StatelessWidget {
  const ProgressDayCell({
    super.key,
    required this.marker,
    this.caption,
    required this.onTap,
  });

  final Widget marker;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          marker,
          if (caption != null)
            SizedBox(
              width: AppDimensions.progressMarker,
              height: AppDimensions.progressMarkerCaptionHeight,
              child: Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }
}
