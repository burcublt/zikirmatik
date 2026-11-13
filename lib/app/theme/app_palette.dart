import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_colors.dart';

/// Semantic colors follow the inherited theme; painted beads retain their material colors.
class AppPalette {
  const AppPalette({
    required this.deepGreen,
    required this.surfaceGreen,
    required this.elevatedGreen,
    required this.gold,
    required this.softGold,
    required this.cream,
    required this.mutedText,
    required this.outline,
    required this.error,
  });
  final Color deepGreen,
      surfaceGreen,
      elevatedGreen,
      gold,
      softGold,
      cream,
      mutedText,
      outline,
      error;
  static const dark = AppPalette(
    deepGreen: AppColors.deepGreen,
    surfaceGreen: AppColors.surfaceGreen,
    elevatedGreen: AppColors.elevatedGreen,
    gold: AppColors.gold,
    softGold: AppColors.softGold,
    cream: AppColors.cream,
    mutedText: AppColors.mutedText,
    outline: AppColors.outline,
    error: AppColors.error,
  );
  static const light = AppPalette(
    deepGreen: Color(0xFFF5F0DF),
    surfaceGreen: Color(0xFFFFFCF1),
    elevatedGreen: Color(0xFFE3E9D3),
    gold: Color(0xFF92661E),
    softGold: Color(0xFF76511B),
    cream: Color(0xFF173D2C),
    mutedText: Color(0xFF4E644F),
    outline: Color(0xFFB7B998),
    error: Color(0xFFA02E25),
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).brightness == Brightness.light
      ? AppPalette.light
      : AppPalette.dark;
}
