import 'package:flutter/material.dart';
import 'package:zikirmatik/app/theme/app_colors.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const p = AppPalette.light;
    final base = dark();
    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: p.gold,
        onPrimary: p.surfaceGreen,
        secondary: p.softGold,
        surface: p.surfaceGreen,
        onSurface: p.cream,
        outline: p.outline,
        error: p.error,
      ),
      scaffoldBackgroundColor: p.deepGreen,
      canvasColor: p.deepGreen,
      textTheme: base.textTheme.apply(
        bodyColor: p.cream,
        displayColor: p.cream,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: p.deepGreen,
        foregroundColor: p.cream,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: p.softGold,
        ),
      ),
      dividerTheme: DividerThemeData(color: p.outline),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.deepGreen,
      secondary: AppColors.softGold,
      onSecondary: AppColors.deepGreen,
      surface: AppColors.surfaceGreen,
      onSurface: AppColors.cream,
      error: AppColors.error,
      onError: AppColors.deepGreen,
      outline: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.deepGreen,
      canvasColor: AppColors.deepGreen,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.cream,
          fontSize: 42,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.cream,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.cream,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.cream, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.mutedText, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: AppColors.cream,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.softGold,
          fontFamily: 'NotoSerif',
          fontSize: 23,
          fontWeight: FontWeight.w700,
        ),
        shape: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5)),
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surfaceGreen,
        indicatorColor: AppColors.elevatedGreen,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: AppColors.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: AppColors.mutedText, size: 22),
        ),
      ),
    );
  }
}
