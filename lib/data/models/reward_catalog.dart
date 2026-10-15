import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum RewardCategory { stickers, badges, trophies }

class RewardItem {
  const RewardItem({
    required this.id,
    required this.category,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.unlockStars,
  });

  final String id;
  final RewardCategory category;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final int unlockStars;
}

/// Every sticker, badge and trophy, unlocked by total stars earned.
const List<RewardItem> rewardCatalog = [
  RewardItem(
    id: 'sticker-sun',
    category: RewardCategory.stickers,
    emoji: '🌞',
    color: AppColors.warning,
    softColor: AppColors.premiumGoldLight,
    shadowColor: Color(0xFFD4A000),
    unlockStars: 0,
  ),
  RewardItem(
    id: 'sticker-rainbow',
    category: RewardCategory.stickers,
    emoji: '🌈',
    color: AppColors.primary,
    softColor: AppColors.primaryLight,
    shadowColor: Color(0xFFC94A18),
    unlockStars: 6,
  ),
  RewardItem(
    id: 'sticker-balloon',
    category: RewardCategory.stickers,
    emoji: '🎈',
    color: AppColors.secondary,
    softColor: AppColors.secondaryLight,
    shadowColor: Color(0xFF2AADA4),
    unlockStars: 10,
  ),
  RewardItem(
    id: 'sticker-crown',
    category: RewardCategory.stickers,
    emoji: '👑',
    color: AppColors.stairsLavender,
    softColor: AppColors.restBackground,
    shadowColor: Color(0xFFA888E8),
    unlockStars: 14,
  ),
  RewardItem(
    id: 'badge-counter',
    category: RewardCategory.badges,
    emoji: '🔢',
    color: AppColors.secondary,
    softColor: AppColors.secondaryLight,
    shadowColor: Color(0xFF2AADA4),
    unlockStars: 4,
  ),
  RewardItem(
    id: 'badge-tracer',
    category: RewardCategory.badges,
    emoji: '✏️',
    color: AppColors.pathwayPeach,
    softColor: AppColors.primaryLight,
    shadowColor: Color(0xFFD97A4D),
    unlockStars: 8,
  ),
  RewardItem(
    id: 'badge-matcher',
    category: RewardCategory.badges,
    emoji: '🃏',
    color: AppColors.bridgeBlue,
    softColor: AppColors.secondaryLight,
    shadowColor: Color(0xFF2890D0),
    unlockStars: 12,
  ),
  RewardItem(
    id: 'badge-quiz',
    category: RewardCategory.badges,
    emoji: '🧠',
    color: AppColors.warning,
    softColor: AppColors.premiumGoldLight,
    shadowColor: Color(0xFFD4A000),
    unlockStars: 16,
  ),
  RewardItem(
    id: 'trophy-bronze',
    category: RewardCategory.trophies,
    emoji: '🏆',
    color: AppColors.pathwayPeach,
    softColor: AppColors.primaryLight,
    shadowColor: Color(0xFFD97A4D),
    unlockStars: 8,
  ),
  RewardItem(
    id: 'trophy-silver',
    category: RewardCategory.trophies,
    emoji: '🥈',
    color: AppColors.bridgeBlue,
    softColor: AppColors.secondaryLight,
    shadowColor: Color(0xFF2890D0),
    unlockStars: 14,
  ),
  RewardItem(
    id: 'trophy-gold',
    category: RewardCategory.trophies,
    emoji: '🥇',
    color: AppColors.premiumGold,
    softColor: AppColors.premiumGoldLight,
    shadowColor: Color(0xFFD4A000),
    unlockStars: 20,
  ),
  RewardItem(
    id: 'trophy-royal',
    category: RewardCategory.trophies,
    emoji: '👑',
    color: AppColors.parentAccent,
    softColor: AppColors.restBackground,
    shadowColor: Color(0xFF3A58C8),
    unlockStars: 24,
  ),
];
