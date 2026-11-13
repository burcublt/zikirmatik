import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.home,
      l10n.zikrs,
      l10n.qibla,
      l10n.statistics,
      l10n.settings,
    ];
    final icons = [
      Icons.home_outlined,
      Icons.menu_book_outlined,
      Icons.explore_outlined,
      Icons.bar_chart_outlined,
      Icons.settings_outlined,
    ];
    final selectedIcons = [
      Icons.home_rounded,
      Icons.menu_book_rounded,
      Icons.explore_rounded,
      Icons.bar_chart_rounded,
      Icons.settings_rounded,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.deepGreen,
        border: Border(
          top: BorderSide(color: context.palette.gold.withValues(alpha: 0.35)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = currentIndex == index;
              final color = selected
                  ? context.palette.gold
                  : context.palette.softGold;
              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: labels[index],
                  child: Tooltip(
                    message: labels[index],
                    child: InkWell(
                      onTap: () => onTap(index),
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected ? selectedIcons[index] : icons[index],
                              color: color,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              labels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
