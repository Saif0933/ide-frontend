import 'package:flutter/material.dart';

class AiRobotAvatar extends StatelessWidget {
  final double size;

  const AiRobotAvatar({super.key, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE0F2FE),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.75, size * 0.75),
          painter: _AiRobotPainter(),
        ),
      ),
    );
  }
}

class _AiRobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Head Base Paint
    final headPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final headBorder = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06;

    // Ear Antennas
    final earPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;

    // Left Ear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, h * 0.35, w * 0.1, h * 0.3),
        Radius.circular(w * 0.05),
      ),
      earPaint,
    );

    // Right Ear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.88, h * 0.35, w * 0.1, h * 0.3),
        Radius.circular(w * 0.05),
      ),
      earPaint,
    );

    // Top Antenna
    final antennaStem = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawLine(Offset(w * 0.5, h * 0.18), Offset(w * 0.5, h * 0.04), antennaStem);
    canvas.drawCircle(Offset(w * 0.5, h * 0.04), w * 0.07, earPaint);

    // Head Main Body
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.18, w * 0.76, h * 0.72),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(headRect, headPaint);
    canvas.drawRRect(headRect, headBorder);

    // Dark Visor / Screen
    final visorPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.32, w * 0.56, h * 0.44),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(visorRect, visorPaint);

    // Glowing Eyes
    final eyeGlow = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    // Left Eye
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.45, w * 0.12, h * 0.18),
        Radius.circular(w * 0.06),
      ),
      eyeGlow,
    );

    // Right Eye
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.45, w * 0.12, h * 0.18),
        Radius.circular(w * 0.06),
      ),
      eyeGlow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
