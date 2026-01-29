import 'dart:math';

import 'package:flutter/material.dart';

class CircularRingProgress extends StatelessWidget {
  final double progress01; // 0..1
  final Color color;
  final double stroke;
  final double size;

  const CircularRingProgress({
    super.key,
    required this.progress01,
    required this.color,
    this.stroke = 10,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress01: progress01.clamp(0.0, 1.0),
          color: color,
          stroke: stroke,
          trackColor: Colors.white.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress01;
  final Color color;
  final Color trackColor;
  final double stroke;

  _RingPainter({
    required this.progress01,
    required this.color,
    required this.trackColor,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (min(size.width, size.height) / 2) - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = trackColor;

    final progPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;

    canvas.drawArc(rect, -pi / 2, 2 * pi, false, trackPaint);
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress01, false, progPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress01 != progress01 ||
        oldDelegate.color != color ||
        oldDelegate.stroke != stroke ||
        oldDelegate.trackColor != trackColor;
  }
}

