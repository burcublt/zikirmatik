import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_colors.dart';

class TasbihPainter extends CustomPainter {
  const TasbihPainter({
    required this.totalBeads,
    required this.filledBeads,
    required this.progress,
  });
  final int totalBeads;
  final int filledBeads;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalBeads <= 0 || size.isEmpty) return;
    final side = math.min(size.width, size.height);
    // Leave room below the ring for the imame and tassel.
    final center = Offset(size.width / 2, size.height / 2 - side * 0.09);
    final radius = side * 0.37;
    final beadRadius = math.min(
      side * 0.027,
      radius * math.sin(math.pi / totalBeads) * 0.94,
    );
    final goldStroke = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(center, radius - beadRadius * 1.8, goldStroke);

    void bead(Offset position, double r, List<Color> colors) {
      canvas.drawCircle(
        position.translate(1, 2),
        r,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(
        position,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.5),
            radius: 1,
            colors: colors,
          ).createShader(Rect.fromCircle(center: position, radius: r)),
      );
      canvas.drawCircle(
        position,
        r,
        Paint()
          ..color = AppColors.softGold.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    for (var i = 0; i < totalBeads; i++) {
      // Half-step offset leaves an opening exactly at six o'clock.
      final angle = math.pi / 2 + 2 * math.pi * (i + 0.5) / totalBeads;
      bead(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        beadRadius,
        i < filledBeads
            ? [const Color(0xFFFFF6CC), AppColors.gold, const Color(0xFF8E6A22)]
            : [
                const Color(0xFFF0F5CF),
                const Color(0xFFAFCB92),
                const Color(0xFF3D7852),
              ],
      );
    }
    final bottom = center + Offset(0, radius);
    bead(bottom + Offset(0, beadRadius * 0.9), beadRadius, [
      AppColors.softGold,
      AppColors.gold,
      const Color(0xFF9B6A20),
    ]);
    bead(bottom + Offset(0, beadRadius * 3), beadRadius * 0.9, [
      AppColors.softGold,
      AppColors.gold,
      const Color(0xFF9B6A20),
    ]);
    final neck = bottom + Offset(0, beadRadius * 4.1);
    canvas.drawLine(
      neck,
      neck + Offset(0, side * 0.025),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = beadRadius * 0.8,
    );
    final tassel = neck + Offset(0, side * 0.025);
    for (var i = -5; i <= 5; i++) {
      canvas.drawLine(
        tassel + Offset(i * side * 0.001, 0),
        tassel + Offset(i * side * 0.004, side * 0.08 - i.abs() * side * 0.001),
        Paint()
          ..color = i.isEven ? const Color(0xFF9FCB8A) : const Color(0xFF3B8053)
          ..strokeWidth = side * 0.004
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(TasbihPainter oldDelegate) =>
      oldDelegate.totalBeads != totalBeads ||
      oldDelegate.filledBeads != filledBeads ||
      oldDelegate.progress != progress;
}
