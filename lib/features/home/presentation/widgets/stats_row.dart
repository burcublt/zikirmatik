import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.dailyTotal,
    required this.streakDays,
    required this.totalCount,
  });

  final int dailyTotal;
  final int streakDays;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.palette.surfaceGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
              icon: Icons.local_fire_department_outlined,
              label: l10n.today,
              value: _formatNumber(dailyTotal),
            ),
            VerticalDivider(
              color: context.palette.outline,
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            _StatItem(
              icon: Icons.calendar_today_outlined,
              label: l10n.streak,
              value: '${_formatNumber(streakDays)} ${l10n.days}',
            ),
            VerticalDivider(
              color: context.palette.outline,
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            _StatItem(
              icon: Icons.bar_chart,
              label: l10n.total,
              value: _formatNumber(totalCount),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) =>
      NumberFormat.decimalPattern('tr').format(value);
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.palette.gold, size: 20),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.palette.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: context.palette.cream,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
