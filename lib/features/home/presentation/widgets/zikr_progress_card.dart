import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';

class ZikrProgressCard extends StatelessWidget {
  const ZikrProgressCard({
    super.key,
    required this.title,
    required this.currentCount,
    required this.targetCount,
    required this.onTap,
  });

  final String title;
  final int currentCount;
  final int targetCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = targetCount > 0
        ? (currentCount / targetCount).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final percentage = NumberFormat.percentPattern(
      Localizations.localeOf(context).toString(),
    ).format(progress);
    final borderRadius = BorderRadius.circular(24);

    return Semantics(
      button: true,
      label: '$title, $percentage',
      onTap: onTap,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.palette.surfaceGreen, context.palette.deepGreen],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: context.palette.gold.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.palette.cream,
                        fontFamily: 'NotoSerif',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.palette.gold,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 14,
                        backgroundColor: context.palette.elevatedGreen,
                        valueColor: AlwaysStoppedAnimation(
                          context.palette.gold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    percentage,
                    style: TextStyle(
                      color: context.palette.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
