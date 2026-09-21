import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../domain/activities.dart';

enum MarkerKind { filled, outlined, unanswered, selected, missed, filledSquare }

class RecordedStateMarker extends StatelessWidget {
  const RecordedStateMarker({
    super.key,
    this.color = MuhasabahColors.mark,
    required this.kind,
    this.symbol,
    this.symbolColor,
    this.symbolSize,
    this.letter,
    this.size,
    required this.semanticLabel,
  });

  final Color color;
  final MarkerKind kind;
  final IconData? symbol;
  final Color? symbolColor;
  final double? symbolSize;
  final String? letter;
  final double? size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final side = size ?? AppDimensions.progressMarker;
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: side,
        height: side,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            CustomPaint(
              size: Size(side, side),
              painter: _MarkerPainter(
                color: color,
                kind: kind,
                letter: letter,
                letterColor: symbolColor ?? Colors.white,
              ),
            ),
            if (symbol != null && (letter == null || letter!.isEmpty))
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
  _MarkerPainter({
    required this.color,
    required this.kind,
    this.letter,
    this.letterColor,
  });

  final Color color;
  final MarkerKind kind;
  final String? letter;
  final Color? letterColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - AppDimensions.progressMarkerStroke) / 2;
    switch (kind) {
      case MarkerKind.filled:
        canvas.drawCircle(center, radius, Paint()..color = color);
        break;
      case MarkerKind.filledSquare:
        final side = radius * 1.7;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: side, height: side),
            const Radius.circular(2),
          ),
          Paint()..color = color,
        );
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
    if (kind == MarkerKind.filled ||
        kind == MarkerKind.filledSquare ||
        kind == MarkerKind.selected) {
      _drawCenteredLetter(canvas, center, radius * 2);
    }
  }

  void _drawCenteredLetter(Canvas canvas, Offset center, double diameter) {
    final glyph = letter;
    if (glyph == null || glyph.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          color: letterColor ?? Colors.white,
          fontSize: diameter * 0.72,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
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
      oldDelegate.color != color ||
      oldDelegate.kind != kind ||
      oldDelegate.letter != letter ||
      oldDelegate.letterColor != letterColor;
}

class ZakatStateMarker extends StatelessWidget {
  const ZakatStateMarker({
    super.key,
    required this.status,
    this.color = MuhasabahColors.mark,
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
    this.onTap,
  });

  final Widget marker;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
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
    );
    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: body,
    );
  }
}
