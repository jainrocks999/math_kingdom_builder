import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const TextStyle hero = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 48,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 32,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 24,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberDisplay = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 120,
    color: AppColors.primary,
    height: 1.0,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );
}