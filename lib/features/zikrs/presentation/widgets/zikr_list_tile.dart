import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

class ZikrListTile extends StatelessWidget {
  const ZikrListTile({
    super.key,
    required this.zikr,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });
  final ZikrDefinition zikr;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
