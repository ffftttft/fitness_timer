import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.work,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08)),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        // 增强对比度，确保文字可读性
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.work,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
        thumbColor: AppColors.work,
      ),
    );
  }

  static TextStyle timerDigitsStyle(Color color) {
    // 等宽数字：tabularFigures，避免“跳动位宽”
    return TextStyle(
      fontSize: 92,
      height: 1.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

