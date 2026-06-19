import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';
import '../../data/models/kingdom_state.dart';

class KingdomZoneData {
  const KingdomZoneData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.route,
    required this.ctaLabel,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.rect,
    required this.progress,
    required this.goal,
    required this.unlocked,
    required this.playable,
    required this.itemCount,
    this.sunshine = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String hint;
  final String route;
  final String ctaLabel;
  final String emoji;
  final IconData icon;
  final Color color;
  final Color softColor;
  final Rect rect;
  final int progress;
  final int goal;
  final bool unlocked;
  final bool playable;
  final int itemCount;
  final bool sunshine;

  double get progressFraction => (progress / math.max(goal, 1)).clamp(0.0, 1.0);

  bool get isComplete => progress >= goal;
}

List<KingdomZoneData> buildKingdomZones(
  KingdomState storedState,
  RewardProgressSnapshot? progress,
) {
  final learnProgress =
      (progress?.completionCountFor(RewardModuleIds.learnNumbers) ?? 0) +
          (progress?.completionCountFor(RewardModuleIds.findNumber) ?? 0);
  final countingProgress =
      progress?.completionCountFor(RewardModuleIds.countObjects) ?? 0;
  final tracingProgress =
      progress?.completionCountFor(RewardModuleIds.traceNumbers) ?? 0;
  final matchingProgress =
      progress?.completionCountFor(RewardModuleIds.matchNumbers) ?? 0;
  final patternsProgress =
      progress?.completionCountFor(RewardModuleIds.patterns) ?? 0;
  final sequencingProgress =
      progress?.completionCountFor(RewardModuleIds.sequencing) ?? 0;

  final gardenProgress =
      math.max(storedState.gardenItems.length, learnProgress);
  final meadowProgress =
      math.max(storedState.meadowItems.length, countingProgress);
  final castleProgress =
      math.max(storedState.castleItems.length, tracingProgress);
  final pathProgress = math.max(
    storedState.patternDecorations.length,
    math.max(matchingProgress, patternsProgress),
  );

  return [
    KingdomZoneData(
      id: 'garden',
      title: 'Number Garden',
      subtitle: 'Flowers bloom when number lessons are done.',
      hint: 'Practice number recognition to grow brighter flowers.',
      route: AppRoutes.findNumber,
      ctaLabel: 'Play Number Quest',
      emoji: '🌷',
      icon: Icons.local_florist_rounded,
      color: AppColors.gardenGreen,
      softColor: const Color(0xFFE2F7E5),
      rect: const Rect.fromLTWH(80, 360, 270, 180),
      progress: gardenProgress,
      goal: 8,
      unlocked: true,
      playable: true,
      itemCount: gardenProgress,
    ),
    KingdomZoneData(
      id: 'meadow',
      title: 'Counting Meadow',
      subtitle: 'Animals gather here after counting adventures.',
      hint: 'Count objects to invite more meadow friends.',
      route: AppRoutes.counting,
      ctaLabel: 'Play Counting Quest',
      emoji: '🐑',
      icon: Icons.pets_rounded,
      color: AppColors.meadowYellow,
      softColor: const Color(0xFFFFF1BF),
      rect: const Rect.fromLTWH(395, 250, 285, 190),
      progress: meadowProgress,
      goal: 6,
      unlocked: storedState.gardenItems.isNotEmpty || learnProgress > 0,
      playable: true,
      itemCount: meadowProgress,
    ),
    KingdomZoneData(
      id: 'castle',
      title: 'Shape Castle',
      subtitle: 'Trace carefully and the castle rises stone by stone.',
      hint: 'Tracing numbers builds stronger walls and towers.',
      route: AppRoutes.tracing,
      ctaLabel: 'Play Tracing Quest',
      emoji: '🏰',
      icon: Icons.castle_rounded,
      color: AppColors.castleGray,
      softColor: const Color(0xFFF0F0F0),
      rect: const Rect.fromLTWH(760, 120, 270, 230),
      progress: castleProgress,
      goal: 6,
      unlocked: storedState.meadowItems.isNotEmpty || countingProgress > 0,
      playable: true,
      itemCount: castleProgress,
    ),
    KingdomZoneData(
      id: 'path',
      title: 'Pattern Pathway',
      subtitle: 'Pattern quests add shining tiles to the walkway.',
      hint: 'Complete pattern adventures to decorate the path.',
      route: AppRoutes.patterns,
      ctaLabel: 'Play Patterns',
      emoji: '🔷',
      icon: Icons.auto_awesome_mosaic_rounded,
      color: AppColors.pathwayPeach,
      softColor: const Color(0xFFFFE5D6),
      rect: const Rect.fromLTWH(420, 540, 335, 120),
      progress: pathProgress,
      goal: 5,
      unlocked: storedState.castleItems.isNotEmpty || tracingProgress > 0,
      playable: true,
      itemCount: pathProgress,
    ),
    KingdomZoneData(
      id: 'bridge',
      title: 'Math Bridge',
      subtitle: 'Add and take away to grow bridge stones.',
      hint: 'Play addition and subtraction here.',
      route: AppRoutes.mathOperations,
      ctaLabel: 'Play Math Ops',
      emoji: '🌉',
      icon: Icons.architecture_rounded,
      color: AppColors.bridgeBlue,
      softColor: const Color(0xFFD8F6F3),
      rect: const Rect.fromLTWH(780, 470, 250, 150),
      progress: storedState.bridgeLength,
      goal: 6,
      unlocked:
          storedState.patternDecorations.isNotEmpty || matchingProgress > 0,
      playable: true,
      itemCount: storedState.bridgeLength,
      sunshine: storedState.bridgeSunshine,
    ),
    KingdomZoneData(
      id: 'stairs',
      title: 'Sequence Stairs',
      subtitle: 'Sequencing adventures raise the glowing steps here.',
      hint: 'Put numbers in order to climb higher.',
      route: AppRoutes.sequencing,
      ctaLabel: 'Open Sequencing',
      emoji: '🪜',
      icon: Icons.stairs_rounded,
      color: AppColors.stairsLavender,
      softColor: const Color(0xFFF0E8FF),
      rect: const Rect.fromLTWH(105, 115, 220, 160),
      progress: math.max(storedState.staircaseSteps, sequencingProgress),
      goal: 6,
      unlocked: storedState.bridgeLength > 0,
      playable: true,
      itemCount: math.max(storedState.staircaseSteps, sequencingProgress),
    ),
  ];
}

KingdomZoneData recommendedKingdomZone(List<KingdomZoneData> zones) {
  for (final zone in zones) {
    if (zone.playable && zone.unlocked && zone.progress < zone.goal) {
      return zone;
    }
  }

  return zones.firstWhere(
    (zone) => zone.playable && zone.unlocked,
    orElse: () => zones.first,
  );
}
