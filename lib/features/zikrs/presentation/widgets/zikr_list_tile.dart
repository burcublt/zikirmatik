import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

class ZikrListTile extends StatelessWidget {
  const ZikrListTile({
    super.key,
    required this.zikr,
    required this.isActive,
    this.progress,
    this.progressReady = true,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });
  final ZikrDefinition zikr;
  final bool isActive;
  final CounterProgressesData? progress;
  final bool progressReady;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = progress?.currentCount ?? 0;
    final target = progress?.targetCount ?? zikr.defaultTarget;
    final ratio = target > 0
        ? (count / target).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final percentage = NumberFormat.percentPattern(
      Localizations.localeOf(context).toString(),
    ).format(ratio);
    final icons = [
      Icons.filter_vintage_outlined,
      Icons.mosque_outlined,
      Icons.star_outline,
      Icons.auto_awesome_outlined,
      Icons.brightness_5_outlined,
      Icons.local_florist_outlined,
    ];
    return Semantics(
      selected: isActive,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: context.palette.surfaceGreen.withValues(
            alpha: isActive ? 0.9 : 0.65,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? context.palette.gold : context.palette.outline,
            width: 0.75,
          ),
        ),
        child: InkWell(
          onTap: onSelect,
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 6, 4, 6),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.palette.gold.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Icon(
                    icons[zikr.sortOrder.abs() % icons.length],
                    color: context.palette.gold,
                    size: 25,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zikr.title,
                        style: TextStyle(
                          color: context.palette.cream,
                          fontSize: 15,
                          fontFamily: 'NotoSerif',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '(${l10n.repeatCount(zikr.defaultTarget)})',
                        style: TextStyle(
                          color: context.palette.cream,
                          fontSize: 12,
                        ),
                      ),
                      if (progressReady) ...[
                        const SizedBox(height: 7),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bar = ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 7,
                                backgroundColor: context.palette.elevatedGreen,
                                color: const Color(0xFF80DE9A),
                              ),
                            );
                            final label = Text(
                              '${l10n.formattedCount(count)} / ${l10n.formattedCount(target)}',
                              style: TextStyle(
                                color: context.palette.cream,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                            final percent = Text(
                              percentage,
                              style: TextStyle(
                                color: context.palette.softGold,
                                fontSize: 11,
                              ),
                            );
                            if (constraints.maxWidth < 220 ||
                                MediaQuery.textScalerOf(context).scale(1) >
                                    1.15) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  bar,
                                  const SizedBox(height: 4),
                                  Wrap(spacing: 6, children: [label, percent]),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: bar),
                                const SizedBox(width: 8),
                                label,
                                const SizedBox(width: 5),
                                percent,
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavorite,
                  tooltip: zikr.isFavorite
                      ? l10n.removeFavorite
                      : l10n.addFavorite,
                  isSelected: zikr.isFavorite,
                  icon: Icon(
                    zikr.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: context.palette.gold,
                  ),
                ),
                if (!zikr.isBuiltIn)
                  PopupMenuButton<String>(
                    tooltip: l10n.more,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 140),
                    iconSize: 18,
                    icon: Icon(
                      Icons.more_vert,
                      color: context.palette.mutedText,
                    ),
                    onSelected: (value) =>
                        value == 'edit' ? onEdit() : onDelete?.call(),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.delete),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
