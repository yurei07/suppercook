import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Serif display for dish names and editorial headlines, Inter for everything
/// functional. This pairing is the core of the reference's premium feel.
abstract final class AppTypography {
  static const serif = 'DMSerifDisplay';
  static const sans = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: serif,
      fontSize: 48,
      height: 1.04,
      letterSpacing: -0.8,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: serif,
      fontSize: 40,
      height: 1.06,
      letterSpacing: -0.6,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: serif,
      fontSize: 34,
      height: 1.1,
      letterSpacing: -0.4,
      color: AppColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: serif,
      fontSize: 30,
      height: 1.12,
      letterSpacing: -0.3,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: serif,
      fontSize: 26,
      height: 1.14,
      letterSpacing: -0.2,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: serif,
      fontSize: 22,
      height: 1.18,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: sans,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: sans,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: sans,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: sans,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
    bodyMedium: TextStyle(
      fontFamily: sans,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: sans,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textTertiary,
    ),
    labelLarge: TextStyle(
      fontFamily: sans,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: sans,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: sans,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.9,
      color: AppColors.textTertiary,
    ),
  );
}
