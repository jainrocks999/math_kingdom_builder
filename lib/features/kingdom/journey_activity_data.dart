import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';

/// An activity the child can perform, shown in the journey activity log.
class JourneyActivity {
  const JourneyActivity({
    required this.moduleId,
    required this.route,
    required this.emoji,
    required this.color,
  });

  /// Matches [RewardModuleIds] and the `modules.*` translation keys.
  final String moduleId;
  final String route;
  final String emoji;
  final Color color;
}

const List<JourneyActivity> journeyActivities = [
  JourneyActivity(
    moduleId: RewardModuleIds.learnNumbers,
    route: AppRoutes.learnNumbers,
    emoji: '🔢',
    color: AppColors.gardenGreen,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.findNumber,
    route: AppRoutes.findNumber,
    emoji: '🔍',
    color: AppColors.info,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.countObjects,
    route: AppRoutes.counting,
    emoji: '🍎',
    color: AppColors.meadowYellow,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.traceNumbers,
    route: AppRoutes.tracing,
    emoji: '✏️',
    color: AppColors.pathwayPeach,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.matchNumbers,
    route: AppRoutes.matching,
    emoji: '🃏',
    color: AppColors.bridgeBlue,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.addition,
    route: AppRoutes.addition,
    emoji: '➕',
    color: AppColors.secondary,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.subtraction,
    route: AppRoutes.subtraction,
    emoji: '➖',
    color: AppColors.primary,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.multiplication,
    route: AppRoutes.multiplication,
    emoji: '✖️',
    color: AppColors.parentAccent,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.division,
    route: AppRoutes.division,
    emoji: '➗',
    color: AppColors.stairsLavender,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.sequencing,
    route: AppRoutes.sequencing,
    emoji: '🪜',
    color: AppColors.stairsLavender,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.patterns,
    route: AppRoutes.patterns,
    emoji: '🔷',
    color: AppColors.pathwayPeach,
  ),
  JourneyActivity(
    moduleId: RewardModuleIds.miniQuiz,
    route: AppRoutes.miniQuiz,
    emoji: '🧠',
    color: AppColors.warning,
  ),
];
