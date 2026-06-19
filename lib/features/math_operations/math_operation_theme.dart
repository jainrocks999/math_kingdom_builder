import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MathOperationTheme {
  const MathOperationTheme({
    required this.assetPath,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    this.accentColor,
  });

  final String assetPath;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final Color? accentColor;

  Color get secondaryColor => accentColor ?? AppColors.secondary;
}

const mathOperationThemes = [
  MathOperationTheme(
    assetPath: 'assets/images/contingobjects/apple.jpeg',
    emoji: '🍎',
    color: AppColors.primary,
    softColor: AppColors.primaryLight,
    shadowColor: Color(0xFFC94A18),
    accentColor: AppColors.secondary,
  ),
  MathOperationTheme(
    assetPath: 'assets/images/contingobjects/candy.jpeg',
    emoji: '🍬',
    color: AppColors.warning,
    softColor: AppColors.premiumGoldLight,
    shadowColor: Color(0xFFD4A000),
    accentColor: AppColors.stairsLavender,
  ),
  MathOperationTheme(
    assetPath: 'assets/images/contingobjects/start.jpeg',
    emoji: '⭐',
    color: AppColors.bridgeBlue,
    softColor: AppColors.secondaryLight,
    shadowColor: Color(0xFF2890D0),
    accentColor: AppColors.pathwayPeach,
  ),
];
