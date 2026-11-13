import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_colors.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

/// Custom-painted vertical bar chart for weekly activity.
/// No external package — pure Canvas drawing.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.data,
    required this.dayLabels,
  });

  final List<DayCount> data;

  /// Exactly 7 short day labels (Mon–Sun or equivalent).
  final List<String> dayLabels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _BarChartPainter(data: data, dayLabels: dayLabels),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data, required this.dayLabels});

  final List<DayCount> data;
  final List<String> dayLabels;

  static const double _labelHeight = 20;
  static const double _barSpacing = 6;
  static const double _cornerRadius = 4;
  static const double _minBarHeight = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final int count = data.length;
    final double chartHeight = size.height - _labelHeight;
    final double totalSpacing = _barSpacing * (count - 1);
    final double barWidth = (size.width - totalSpacing) / count;

    final int maxCount = data
        .map((d) => d.count)
        .fold(0, (a, b) => a > b ? a : b);

    final Paint barPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    final Paint emptyPaint = Paint()
      ..color = AppColors.outline.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final TextStyle labelStyle = TextStyle(
      color: AppColors.mutedText,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    final TextStyle valueLabelStyle = TextStyle(
      color: AppColors.softGold,
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < count; i++) {
      final double x = i * (barWidth + _barSpacing);
      final DayCount item = data[i];

      // Bar height proportional to max.
      final double barHeight = maxCount > 0
          ? ((item.count / maxCount) * (chartHeight - 20)).clamp(
              item.count > 0 ? _minBarHeight : 0,
              chartHeight - 20,
            )
          : 0;

      final double barTop = chartHeight - 20 - barHeight;
      final Rect barRect = Rect.fromLTWH(x, barTop, barWidth, barHeight);

      final bool isEmpty = item.count == 0;
      final RRect rRect = RRect.fromRectAndCorners(
        isEmpty ? Rect.fromLTWH(x, chartHeight - 22, barWidth, 2) : barRect,
        topLeft: const Radius.circular(_cornerRadius),
        topRight: const Radius.circular(_cornerRadius),
      );

      canvas.drawRRect(rRect, isEmpty ? emptyPaint : barPaint);

      // Value label above bar (only if non-zero).
      if (item.count > 0) {
        final String valueText = _formatCount(item.count);
        final TextSpan valueSpan = TextSpan(
          text: valueText,
          style: valueLabelStyle,
        );
        final TextPainter valuePainter = TextPainter(
          text: valueSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: barWidth + 10);

        final double valueX = x + (barWidth - valuePainter.width) / 2;
        final double valueY = barTop - valuePainter.height - 2;
        if (valueY >= 0) {
          valuePainter.paint(canvas, Offset(valueX, valueY));
        }
      }

      // Day label below bar.
      final String dayLabel = dayLabels.length > i ? dayLabels[i] : '';
      final TextSpan labelSpan = TextSpan(text: dayLabel, style: labelStyle);
      final TextPainter labelPainter = TextPainter(
        text: labelSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barWidth + 10);

      final double labelX = x + (barWidth - labelPainter.width) / 2;
      final double labelY = size.height - _labelHeight + 2;
      labelPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.data != data || old.dayLabels != dayLabels;
}
