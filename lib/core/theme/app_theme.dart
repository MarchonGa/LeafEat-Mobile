import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );
  }
}
