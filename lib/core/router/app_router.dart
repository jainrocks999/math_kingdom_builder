import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:math_kingdom_builder/features/StartLearning/start_learning_screen.dart';
import 'package:math_kingdom_builder/features/count_objects/count_objects_screen.dart';
import 'package:math_kingdom_builder/features/learn_numbers/learn_numbers_screen.dart';
import 'package:math_kingdom_builder/features/matching/match_numbers_screen.dart';
import 'package:math_kingdom_builder/features/mini_quiz/mini_quiz_screen.dart';
import 'package:math_kingdom_builder/features/number_tracing/trace_numbers_screen.dart';
import 'package:math_kingdom_builder/features/rewards/rewards_screen.dart';
import 'package:math_kingdom_builder/onboarding_screen.dart';

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
  });

  final String path;
  final String title;
  final String description;
  final IconData icon;
}

final List<PlaceholderRouteSpec> appPlaceholderRoutes = [
  const PlaceholderRouteSpec(
    path: AppRoutes.addition,
    title: 'Addition',
    description: 'Placeholder screen for simple addition activities.',
    icon: Icons.add_circle_outline_rounded,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.subtraction,
    title: 'Subtraction',
    description: 'Placeholder screen for simple subtraction activities.',
    icon: Icons.remove_circle_outline_rounded,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.sequencing,
    title: 'Sequencing',
    description: 'Placeholder screen for missing-number steps.',
    icon: Icons.stairs_rounded,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.patterns,
    title: 'Patterns',
    description: 'Placeholder screen for AB and ABB pattern play.',
    icon: Icons.auto_awesome_mosaic_rounded,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.kingdom,
    title: 'Kingdom',
    description: 'Placeholder screen for the interactive kingdom map.',
    icon: Icons.castle_rounded,
  ),
  const PlaceholderRouteSpec(
    path: AppRoutes.parentDashboard,
    title: 'Parent Dashboard',
    description:
        'Placeholder screen for parent settings, progress, and upgrades.',
    icon: Icons.lock_outline_rounded,
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
    ...appPlaceholderRoutes.map(
      (route) => GoRoute(
        path: route.path,
        builder: (context, state) => PlaceholderScreen(
          title: route.title,
          description: route.description,
          icon: route.icon,
        ),
      ),
    ),
  ],
);
