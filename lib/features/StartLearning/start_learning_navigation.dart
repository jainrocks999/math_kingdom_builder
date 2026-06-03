import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';

class StartLearningModuleSpec {
  const StartLearningModuleSpec({
    required this.title,
    required this.route,
    required this.unlockStars,
  });

  final String title;
  final String route;
  final int unlockStars;
}

/// Navigation helpers for moving through the Start Learning adventure path.
abstract final class StartLearningNavigation {
  static const List<StartLearningModuleSpec> learningModules = [
    StartLearningModuleSpec(
      title: 'Learn Numbers',
      route: AppRoutes.learnNumbers,
      unlockStars: 0,
    ),
    StartLearningModuleSpec(
      title: 'Trace Numbers',
      route: AppRoutes.tracing,
      unlockStars: 0,
    ),
    StartLearningModuleSpec(
      title: 'Count Objects',
      route: AppRoutes.counting,
      unlockStars: 0,
    ),
    StartLearningModuleSpec(
      title: 'Find Correct Number',
      route: AppRoutes.findNumber,
      unlockStars: 4,
    ),
    StartLearningModuleSpec(
      title: 'Match Numbers',
      route: AppRoutes.matching,
      unlockStars: 8,
    ),
    StartLearningModuleSpec(
      title: 'Mini Quiz',
      route: AppRoutes.miniQuiz,
      unlockStars: 14,
    ),
  ];

  static Future<String?> resolveNextRoute(String currentRoute) async {
    final snapshot = await RewardProgressService.instance.loadSnapshot();
    final currentIndex = learningModules.indexWhere(
      (module) => module.route == currentRoute,
    );
    if (currentIndex == -1) return null;

    for (var i = currentIndex + 1; i < learningModules.length; i++) {
      final module = learningModules[i];
      if (snapshot.totalStars >= module.unlockStars) {
        return module.route;
      }
    }

    return AppRoutes.startlearning;
  }

  static Future<String> nextActionLabel(String currentRoute) async {
    final nextRoute = await resolveNextRoute(currentRoute);
    if (nextRoute == null || nextRoute == AppRoutes.startlearning) {
      return 'Back to Learning Menu';
    }

    final module = learningModules.firstWhere(
      (entry) => entry.route == nextRoute,
    );
    return 'Next: ${module.title}';
  }

  static Future<void> goToNextLearning(
    BuildContext context, {
    required String currentRoute,
    VoidCallback? beforeNavigate,
  }) async {
    beforeNavigate?.call();

    final nextRoute = await resolveNextRoute(currentRoute);
    if (!context.mounted || nextRoute == null) return;

    if (nextRoute == AppRoutes.startlearning) {
      context.pop();
      return;
    }

    context.pushReplacement(nextRoute);
  }
}
