import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static double responsiveSize(
    double width, {
    required double min,
    required double max,
    double minWidth = 320,
    double maxWidth = 430,
  }) {
    final t = ((width - minWidth) / (maxWidth - minWidth)).clamp(0.0, 1.0);
    return min + ((max - min) * t);
  }

  // Hero Text
  static const TextStyle hero = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // Heading 1
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Heading 2
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Large Number Display
  static const TextStyle numberDisplay = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 120,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.0,
  );

  static const TextStyle featurePrompt = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Body Text
  static const TextStyle body = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    height: 1.2,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    height: 1.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle parentTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle parentSection = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle parentValue = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.parentAccent,
    height: 1.3,
  );
}
