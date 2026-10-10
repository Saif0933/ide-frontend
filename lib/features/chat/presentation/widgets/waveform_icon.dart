import 'package:flutter/material.dart';

class WaveformIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WaveformIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WaveformPainter(color: color),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final Color color;

  _WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final barWidth = w * 0.12;
    final radius = Radius.circular(barWidth / 2);

    // 4 vertical waveform bars of varying heights
    final barHeights = [0.45, 0.9, 0.65, 0.35];
    final barX = [0.15, 0.38, 0.62, 0.85];

    for (int i = 0; i < 4; i++) {
      final barH = h * barHeights[i];
      final top = (h - barH) / 2;
      final left = w * barX[i] - barWidth / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barH),
          radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.color != color;
}
