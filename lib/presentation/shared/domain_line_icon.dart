import 'package:flutter/material.dart';

import '../../domain/monitor_domain.dart';
import 'domain_visual.dart';

/// Outlined domain mark. Colour still names the domain; this shape names it
/// at small sizes. Not a score.
class DomainLineIcon extends StatelessWidget {
  const DomainLineIcon(
    this.domain, {
    super.key,
    this.size = 22,
    this.color,
  });

  final MonitorDomain domain;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? domainColorIdentity(domain).family;
    return ExcludeSemantics(
      child: CustomPaint(
        key: Key('domain-line-icon-${domain.id}'),
        size: Size.square(size),
        painter: _DomainLinePainter(domain: domain, color: ink),
      ),
    );
  }
}

class _DomainLinePainter extends CustomPainter {
  _DomainLinePainter({required this.domain, required this.color});

  final MonitorDomain domain;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (domain) {
      case MonitorDomain.salah:
        _mosque(canvas, paint);
      case MonitorDomain.quran:
        _openMushaf(canvas, paint);
      case MonitorDomain.hadith:
        _stackedBooks(canvas, paint);
      case MonitorDomain.dhikr:
        _beads(canvas, paint);
      case MonitorDomain.akhlaq:
        _growth(canvas, paint);
      case MonitorDomain.huquq:
        _handshake(canvas, paint);
      case MonitorDomain.knowledge:
        _lamp(canvas, paint);
      case MonitorDomain.time:
        _clock(canvas, paint);
      case MonitorDomain.health:
        _pulse(canvas, paint);
      case MonitorDomain.wealth:
        _scale(canvas, paint);
      case MonitorDomain.ummah:
        _globe(canvas, paint);
      case MonitorDomain.fasting:
        _crescent(canvas, paint);
      case MonitorDomain.hajj:
        _kaaba(canvas, paint);
      case MonitorDomain.productivity:
        _checklist(canvas, paint);
      case MonitorDomain.charity:
        _openHands(canvas, paint);
    }
    canvas.restore();
  }

  void _mosque(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(4, 20)
        ..lineTo(20, 20)
        ..moveTo(6, 20)
        ..lineTo(6, 11)
        ..lineTo(12, 6)
        ..lineTo(18, 11)
        ..lineTo(18, 20)
        ..moveTo(10, 20)
        ..lineTo(10, 15)
        ..lineTo(14, 15)
        ..lineTo(14, 20)
        ..moveTo(12, 6)
        ..lineTo(12, 3),
      paint,
    );
  }

  void _openMushaf(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(4, 6)
        ..cubicTo(7, 6, 9, 7, 12, 7)
        ..cubicTo(15, 7, 17, 6, 20, 6)
        ..lineTo(20, 19)
        ..cubicTo(17, 19, 15, 20, 12, 20)
        ..cubicTo(9, 20, 7, 19, 4, 19)
        ..lineTo(4, 6)
        ..close()
        ..moveTo(12, 7)
        ..lineTo(12, 20),
      paint,
    );
  }

  void _stackedBooks(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..addRect(const Rect.fromLTWH(6, 5, 12, 4))
        ..addRect(const Rect.fromLTWH(5, 10, 12, 4))
        ..addRect(const Rect.fromLTWH(7, 15, 12, 4)),
      paint,
    );
  }

  void _beads(Canvas canvas, Paint paint) {
    canvas.drawCircle(const Offset(12, 12), 3, paint);
    const dots = <Offset>[
      Offset(12, 4.6),
      Offset(18.4, 8.1),
      Offset(18.4, 15.9),
      Offset(12, 19.4),
      Offset(5.6, 15.9),
      Offset(5.6, 8.1),
    ];
    for (final dot in dots) {
      canvas.drawCircle(dot, 1.15, paint);
    }
  }

  void _growth(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(12, 21)
        ..lineTo(12, 10)
        ..moveTo(12, 14)
        ..cubicTo(8.8, 14, 6.8, 11.8, 6.8, 8.8)
        ..moveTo(12, 12.5)
        ..cubicTo(15.2, 12.5, 17.2, 10.5, 17.2, 7.5)
        ..moveTo(9, 8.5)
        ..cubicTo(9, 7.3, 9.6, 6, 10.6, 5.3)
        ..moveTo(15, 7.8)
        ..cubicTo(15, 6.5, 14.5, 5.4, 13.5, 4.7),
      paint,
    );
  }

  void _handshake(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(7, 14)
        ..lineTo(7, 8.8)
        ..lineTo(10.2, 8.8)
        ..lineTo(12, 11)
        ..lineTo(17, 11)
        ..lineTo(17, 14.2)
        ..lineTo(7, 14.2)
        ..close()
        ..moveTo(7, 14.2)
        ..cubicTo(7.2, 16.4, 8.5, 17.8, 10.4, 17.8)
        ..lineTo(12.6, 17.8),
      paint,
    );
  }

  void _lamp(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(9, 18)
        ..lineTo(15, 18)
        ..moveTo(10.2, 21)
        ..lineTo(13.8, 21)
        ..moveTo(12, 3)
        ..arcToPoint(
          const Offset(15.4, 13.6),
          radius: const Radius.circular(6),
        )
        ..cubicTo(14.8, 14.1, 14, 15.1, 14, 16.5)
        ..lineTo(10, 16.5)
        ..cubicTo(10, 15.1, 9.2, 14.1, 8.6, 13.6)
        ..arcToPoint(
          const Offset(12, 3),
          radius: const Radius.circular(6),
        )
        ..close(),
      paint,
    );
  }

  void _checklist(Canvas canvas, Paint paint) {
    canvas.drawRRect(
      RRect.fromLTRBR(5, 4, 19, 20, const Radius.circular(2)),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(7.5, 11)
        ..lineTo(10.2, 13.6)
        ..lineTo(16.2, 8),
      paint,
    );
  }

  void _clock(Canvas canvas, Paint paint) {
    canvas.drawCircle(const Offset(12, 13), 7, paint);
    canvas.drawPath(
      Path()
        ..moveTo(12, 13)
        ..lineTo(12, 9.2)
        ..moveTo(12, 13)
        ..lineTo(15.1, 15)
        ..moveTo(9, 4)
        ..lineTo(15, 4),
      paint,
    );
  }

  void _pulse(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(3, 12)
        ..lineTo(6.5, 12)
        ..lineTo(8.5, 7.8)
        ..lineTo(11.7, 16.2)
        ..lineTo(13.9, 12)
        ..lineTo(21, 12),
      paint,
    );
  }

  void _scale(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(12, 4)
        ..lineTo(12, 7)
        ..moveTo(5, 9)
        ..lineTo(19, 9)
        ..moveTo(7.2, 9)
        ..lineTo(5.4, 16)
        ..lineTo(10.8, 16)
        ..lineTo(9, 9)
        ..moveTo(16.8, 9)
        ..lineTo(15, 16)
        ..lineTo(20.4, 16)
        ..lineTo(18, 9),
      paint,
    );
  }

  void _globe(Canvas canvas, Paint paint) {
    canvas.drawCircle(const Offset(12, 12), 8, paint);
    canvas.drawPath(
      Path()
        ..moveTo(4.4, 12)
        ..lineTo(19.6, 12)
        ..moveTo(12, 4)
        ..cubicTo(14.3, 6.5, 15.5, 9.2, 15.5, 12)
        ..cubicTo(15.5, 14.8, 14.3, 17.5, 12, 20)
        ..cubicTo(9.7, 17.5, 8.5, 14.8, 8.5, 12)
        ..cubicTo(8.5, 9.2, 9.7, 6.5, 12, 4)
        ..close(),
      paint,
    );
  }

  void _crescent(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(16, 5.2)
        ..arcToPoint(
          const Offset(19.2, 18),
          radius: const Radius.circular(8),
          largeArc: true,
          clockwise: false,
        )
        ..arcToPoint(
          const Offset(16, 5.2),
          radius: const Radius.circular(7),
        )
        ..close(),
      paint,
    );
  }

  void _kaaba(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(7, 9)
        ..lineTo(17, 9)
        ..lineTo(17, 20)
        ..lineTo(7, 20)
        ..close()
        ..moveTo(7, 9)
        ..lineTo(12, 5)
        ..lineTo(17, 9)
        ..addRect(const Rect.fromLTWH(9.6, 14.2, 4.8, 5.8)),
      paint,
    );
  }

  void _openHands(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(8, 11.2)
        ..cubicTo(8, 9.7, 9, 8.7, 10.2, 8.7)
        ..cubicTo(11.4, 8.7, 12.5, 9.7, 12.5, 11.2)
        ..lineTo(12.5, 12.6)
        ..moveTo(16, 11.2)
        ..cubicTo(16, 9.7, 15, 8.7, 13.8, 8.7)
        ..cubicTo(12.6, 8.7, 11.5, 9.7, 11.5, 11.2)
        ..lineTo(11.5, 12.6)
        ..moveTo(6.4, 13.6)
        ..lineTo(17.6, 13.6)
        ..lineTo(17.6, 16.7)
        ..cubicTo(17.6, 18.7, 16, 20, 14.1, 20)
        ..lineTo(9.9, 20)
        ..cubicTo(8, 20, 6.4, 18.7, 6.4, 16.7)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DomainLinePainter oldDelegate) {
    return oldDelegate.domain != domain || oldDelegate.color != color;
  }
}

MonitorDomain? domainForTitle(String title) {
  for (final domain in MonitorDomain.values) {
    if (domain.label == title) return domain;
  }
  return null;
}
