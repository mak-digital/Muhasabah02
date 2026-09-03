import 'package:flutter/material.dart';

import '../../app/dimensions.dart';

enum MarkerKind { filled, outlined, unanswered, selected }

class RecordedStateMarker extends StatelessWidget {
  const RecordedStateMarker({
    super.key,
    required this.color,
    required this.kind,
    this.symbol,
    required this.semanticLabel,
  });

  final Color color;
  final MarkerKind kind;
  final IconData? symbol;
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
                size: AppDimensions.progressMarkerSymbol,
                color: color,
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
