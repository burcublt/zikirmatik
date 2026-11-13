import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    super.key,
    required this.currentCount,
    required this.targetCount,
    required this.isComplete,
    this.hasActiveZikr = true,
  });
  final int currentCount;
  final int targetCount;
  final bool isComplete;
  final bool hasActiveZikr;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome, size: 15, color: context.palette.gold),
        SizedBox(height: 10),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          child: Text(
            l10n.formattedCount(currentCount),
            key: ValueKey(currentCount),
            style: TextStyle(
              color: isComplete ? context.palette.gold : context.palette.cream,
              fontSize: 56,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        SizedBox(height: 3),
        Text(
          '/ ${l10n.formattedCount(targetCount)}',
          style: TextStyle(color: context.palette.cream, fontSize: 17),
        ),
        SizedBox(height: 10),
        Icon(
          isComplete ? Icons.check_circle_outline : Icons.touch_app_outlined,
          size: 21,
          color: context.palette.gold,
        ),
        SizedBox(height: 5),
        SizedBox(
          width: 110,
          child: Text(
            isComplete
                ? l10n.completed
                : hasActiveZikr
                ? l10n.tapToCount
                : l10n.selectZikr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.palette.softGold,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
