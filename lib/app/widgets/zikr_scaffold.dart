import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_colors.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';

/// Shared emerald surface; ornaments never take part in touch or semantics.
class ZikrScaffold extends StatelessWidget {
  const ZikrScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor ?? context.palette.deepGreen,
    appBar: appBar,
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
    body: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.8),
          radius: 1.6,
          colors: Theme.of(context).brightness == Brightness.dark
              ? const [
                  Color(0xFF064E34),
                  AppColors.deepGreen,
                  Color(0xFF001C15),
                ]
              : [
                  context.palette.elevatedGreen,
                  context.palette.deepGreen,
                  context.palette.surfaceGreen,
                ],
        ),
      ),
      child: CustomPaint(
        painter: _OrnamentPainter(
          light: Theme.of(context).brightness == Brightness.light,
        ),
        child: body,
      ),
    ),
  );
}

class _OrnamentPainter extends CustomPainter {
  _OrnamentPainter({required this.light});
  final bool light;
  @override
  void paint(Canvas canvas, Size size) {
    final pattern = Paint()
      ..color = AppColors.softGold.withValues(alpha: 0.018)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;
    const step = 56.0;
    for (double y = 0; y < size.height * 0.65; y += step) {
      pattern.color = (light ? AppPalette.light.gold : AppColors.softGold)
          .withValues(
            alpha: 0.018 * math.pow(1 - y / (size.height * 0.65), 2).toDouble(),
          );
      for (double x = 0; x < size.width + step; x += step) {
        final center = Offset(x, y);
        final path = Path();
        for (var i = 0; i <= 16; i++) {
          final angle = math.pi * i / 8;
          final radius = i.isEven ? 24.0 : 11.0;
          final point =
              center + Offset(math.cos(angle), math.sin(angle)) * radius;
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(path..close(), pattern);
      }
    }
    // Low-contrast skyline anchored to the bottom, behind the controls.
    final ink = Paint()
      ..color = const Color(0xFF001D15).withValues(alpha: light ? 0.06 : 0.6);
    final base = size.height * 0.93;
    for (var i = 0; i < 7; i++) {
      final x = size.width * (i - 0.2) / 6;
      final width = size.width * 0.18;
      final top = base - (i.isEven ? 94 : 62);
      final dome = Path()
        ..moveTo(x, base)
        ..lineTo(x, top + 22)
        ..quadraticBezierTo(x, top + 8, x + width / 2, top - 4)
        ..quadraticBezierTo(x + width, top + 8, x + width, top + 22)
        ..lineTo(x + width, base)
        ..close();
      canvas.drawPath(dome, ink);
      canvas.drawRect(Rect.fromLTWH(x + width / 2 - 1, top - 13, 2, 12), ink);
      final minaretX = x + width + 5;
      canvas.drawRect(
        Rect.fromLTWH(minaretX, top - 21, 5, base - top + 21),
        ink,
      );
      canvas.drawPath(
        Path()
          ..moveTo(minaretX - 2, top - 21)
          ..lineTo(minaretX + 2.5, top - 33)
          ..lineTo(minaretX + 7, top - 21)
          ..close(),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter oldDelegate) =>
      oldDelegate.light != light;
}

class GoldAddButton extends StatelessWidget {
  const GoldAddButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.size = 32,
  });
  final VoidCallback onPressed;
  final String label;
  final double size;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    icon: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.palette.gold),
        gradient: RadialGradient(
          colors: [context.palette.elevatedGreen, context.palette.deepGreen],
        ),
      ),
      child: Icon(Icons.add, color: context.palette.softGold, size: size * 0.7),
    ),
  );
}
