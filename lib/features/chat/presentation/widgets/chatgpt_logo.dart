import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatGptLogo extends StatelessWidget {
  final double size;
  final Color color;

  const ChatGptLogo({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChatGptLogoPainter(color: color),
      ),
    );
  }
}

class _ChatGptLogoPainter extends CustomPainter {
  final Color color;

  _ChatGptLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.085;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final petalCount = 6;
    final angleStep = (2 * math.pi) / petalCount;

    for (int i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * angleStep);

      final path = Path();
      // Draw single curved knot of ChatGPT logo
      final r = radius * 0.72;
      path.moveTo(0, -r * 0.35);
      path.lineTo(r * 0.45, -r * 0.35);
      path.arcToPoint(
        Offset(r * 0.85, -r * 0.05),
        radius: Radius.circular(r * 0.3),
        clockwise: true,
      );
      path.lineTo(r * 0.85, r * 0.35);
      path.arcToPoint(
        Offset(r * 0.55, r * 0.65),
        radius: Radius.circular(r * 0.3),
        clockwise: true,
      );
      path.lineTo(r * 0.15, r * 0.65);
      path.arcToPoint(
        Offset(-r * 0.15, r * 0.45),
        radius: Radius.circular(r * 0.25),
        clockwise: true,
      );

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ChatGptLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
