import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CountingTheme {
  const CountingTheme({
    required this.id,
    required this.assetPath,
    required this.singular,
    required this.plural,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
  });

  final String id;
  final String assetPath;
  final String singular;
  final String plural;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
}

const List<CountingTheme> countingThemes = [
  CountingTheme(
    id: 'apple',
    assetPath: 'assets/images/contingobjects/apple.jpeg',
    singular: 'apple',
    plural: 'apples',
    emoji: '🍎',
    color: AppColors.primary,
    softColor: AppColors.primaryLight,
    shadowColor: Color(0xFFC94A18),
  ),
  CountingTheme(
    id: 'candy',
    assetPath: 'assets/images/contingobjects/candy.jpeg',
    singular: 'candy',
    plural: 'candies',
    emoji: '🍬',
    color: AppColors.warning,
    softColor: AppColors.premiumGoldLight,
    shadowColor: Color(0xFFD4A000),
  ),
  CountingTheme(
    id: 'car',
    assetPath: 'assets/images/contingobjects/car.jpeg',
    singular: 'car',
    plural: 'cars',
    emoji: '🚗',
    color: AppColors.bridgeBlue,
    softColor: AppColors.secondaryLight,
    shadowColor: Color(0xFF2890D0),
  ),
  CountingTheme(
    id: 'balloon',
    assetPath: 'assets/images/contingobjects/ballun.jpeg',
    singular: 'balloon',
    plural: 'balloons',
    emoji: '🎈',
    color: AppColors.stairsLavender,
    softColor: AppColors.restBackground,
    shadowColor: Color(0xFFA888E8),
  ),
  CountingTheme(
    id: 'star',
    assetPath: 'assets/images/contingobjects/start.jpeg',
    singular: 'star',
    plural: 'stars',
    emoji: '⭐',
    color: AppColors.premiumGold,
    softColor: AppColors.premiumGoldLight,
    shadowColor: Color(0xFFD4A000),
  ),
];
