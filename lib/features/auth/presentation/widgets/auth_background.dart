import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom painted blurred modern office background with perspective depth,
/// architectural glass windows, pillars, and desk lighting.
class ModernOfficeBlurredBackground extends StatelessWidget {
  const ModernOfficeBlurredBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OfficeAtmospherePainter(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: const Color(0xFFC3D4E4).withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _OfficeAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base background gradient: cool airy office atmosphere
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEAF0F6),
          Color(0xFFD6E3EE),
          Color(0xFFB8CBDC),
          Color(0xFF9FB7CD),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Left window light zone (bright daylight from floor-to-ceiling windows)
    final windowGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.85),
          const Color(0xFFDCEAF5).withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, windowGlow);

    // Perspective window mullions / architectural frames on the left
    final framePaint = Paint()
      ..color = const Color(0xFF3B566E).withValues(alpha: 0.45)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width * 0.18, size.height);
    canvas.drawPath(path1, framePaint);

    final path2 = Path()
      ..moveTo(size.width * 0.22, 0)
      ..lineTo(size.width * 0.28, size.height);
    canvas.drawPath(path2, framePaint);

    // Horizontal window beams
    final beamPaint = Paint()
      ..color = const Color(0xFF4A6882).withValues(alpha: 0.35)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.22),
      Offset(size.width * 0.38, size.height * 0.28),
      beamPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width * 0.38, size.height * 0.62),
      beamPaint,
    );

    // Desks, partitions & monitors silhouettes in the background
    final furniturePaint = Paint()..style = PaintingStyle.fill;

    // Far desk row
    furniturePaint.color = const Color(0xFF2C4356).withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.60, size.width * 0.32, size.height * 0.25),
        const Radius.circular(8),
      ),
      furniturePaint,
    );

    // Right glass conference room & dark modern monitors/chairs
    furniturePaint.color = const Color(0xFF1E3345).withValues(alpha: 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.72, size.height * 0.50, size.width * 0.26, size.height * 0.45),
        const Radius.circular(12),
      ),
      furniturePaint,
    );

    // Ceiling linear lights
    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.04),
      Offset(size.width * 0.42, size.height * 0.08),
      lightPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.05),
      Offset(size.width * 0.78, size.height * 0.09),
      lightPaint,
    );

    // Subtle blue atmospheric depth wash on right
    final rightAtmosphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.85, 0.4),
        radius: 0.8,
        colors: [
          const Color(0xFF2B475D).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, rightAtmosphere);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
