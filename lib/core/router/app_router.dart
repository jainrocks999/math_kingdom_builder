import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:math_kingdom_builder/features/StartLearning/start_learning_screen.dart';
import 'package:math_kingdom_builder/features/count_objects/count_objects_screen.dart';
import 'package:math_kingdom_builder/features/kingdom/kingdom_screen.dart';
import 'package:math_kingdom_builder/features/learn_numbers/learn_numbers_screen.dart';
import 'package:math_kingdom_builder/features/matching/match_numbers_screen.dart';
import 'package:math_kingdom_builder/features/mini_quiz/mini_quiz_screen.dart';
import 'package:math_kingdom_builder/features/number_tracing/trace_numbers_screen.dart';
import 'package:math_kingdom_builder/features/parent_dashboard/parent_dashboard_screen.dart';
import 'package:math_kingdom_builder/features/rewards/rewards_screen.dart';
import 'package:math_kingdom_builder/onboarding_screen.dart';

import '../../core/constants/app_colors.dart';
import '../../features/home/home_screen.dart';
import '../../features/number_recognition/number_recognition_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../../splash_screen.dart';

final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const onbording = '/onbording';
  static const numberRecognition = '/number-recognition';
  static const findNumber = '/find-number';
  static const learnNumbers = '/learn-numbers';
  static const counting = '/count-objects';
  static const tracing = '/tracing';
  static const matching = '/matching';
  static const miniQuiz = '/mini-quiz';
  static const addition = '/addition';
  static const subtraction = '/subtraction';
  static const sequencing = '/sequencing';
  static const patterns = '/patterns';
  static const kingdom = '/kingdom';
  static const stickers = '/stickers';
  static const parentDashboard = '/parent-dashboard';
  static const startlearning = '/start-learning';
}

class PlaceholderRouteSpec {
  const PlaceholderRouteSpec({
    required this.path,
    required this.title,
    required this.description,
    required this.icon,
    this.emoji = '✨',
    this.accentColor = AppColors.primary,
  });

  final String path;
  final String title;
  final String description;
  final IconData icon;
  final String emoji;
  final Color accentColor;
}

final List<PlaceholderRouteSpec> appPlaceholderRoutes = [
  const PlaceholderRouteSpec(
    path: AppRoutes.addition,
    title: 'Addition',
    description:
        'Add numbers with candy visuals and cheerful bear hints. This adventure is almost ready.',
    icon: Icons.add_circle_outline_rounded,
    emoji: '➕',
    accentColor: AppColors.warning,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.subtraction,
    title: 'Subtraction',
    description:
        'Take away objects gently and learn subtraction through play. Coming in the next update.',
    icon: Icons.remove_circle_outline_rounded,
    emoji: '➖',
    accentColor: AppColors.secondary,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.sequencing,
    title: 'Sequencing',
    description:
        'Climb the number stairs by finding what comes next. This quest unlocks soon.',
    icon: Icons.stairs_rounded,
    emoji: '🪜',
    accentColor: AppColors.stairsLavender,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.patterns,
    title: 'Patterns',
    description:
        'Complete AB and ABB patterns with colorful tiles. Pattern play arrives soon.',
    icon: Icons.auto_awesome_mosaic_rounded,
    emoji: '🔷',
    accentColor: AppColors.gardenGreen,
  ),
];

GoRouter get appRouter => _appRouter;

final GoRouter _appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  observers: [appRouteObserver],
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onbording,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.numberRecognition,
      builder: (context, state) => const FindCorrectNumberScreen(),
    ),
    GoRoute(
      path: AppRoutes.findNumber,
      builder: (context, state) => const FindCorrectNumberScreen(),
    ),
    GoRoute(
      path: AppRoutes.learnNumbers,
      builder: (context, state) => const LearnNumbersScreen(),
    ),
    GoRoute(
      path: AppRoutes.counting,
      builder: (context, state) => const CountObjectsScreen(),
    ),
    GoRoute(
      path: AppRoutes.tracing,
      builder: (context, state) => const TraceNumbersScreen(),
    ),
    GoRoute(
      path: AppRoutes.matching,
      builder: (context, state) => const MatchNumbersScreen(),
    ),
    GoRoute(
      path: AppRoutes.miniQuiz,
      builder: (context, state) => const MiniQuizScreen(),
    ),
    GoRoute(
      path: AppRoutes.stickers,
      builder: (context, state) => const RewardsScreen(),
    ),
    GoRoute(
      path: AppRoutes.startlearning,
      builder: (context, state) => const StartLearningScreen(),
    ),
    GoRoute(
      path: AppRoutes.kingdom,
      builder: (context, state) => const KingdomScreen(),
    ),
    GoRoute(
      path: AppRoutes.parentDashboard,
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    ...appPlaceholderRoutes.map(
      (route) => GoRoute(
        path: route.path,
        builder: (context, state) => PlaceholderScreen(
          title: route.title,
          description: route.description,
          icon: route.icon,
          emoji: route.emoji,
          accentColor: route.accentColor,
        ),
      ),
    ),
  ],
);
