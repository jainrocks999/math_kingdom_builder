import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:math_kingdom_builder/features/StartLearning/start_learning_screen.dart';
import 'package:math_kingdom_builder/features/count_objects/count_objects_screen.dart';
import 'package:math_kingdom_builder/features/kingdom/kingdom_screen.dart';
import 'package:math_kingdom_builder/features/learn_numbers/learn_numbers_screen.dart';
import 'package:math_kingdom_builder/features/math_operations/addition_screen.dart';
import 'package:math_kingdom_builder/features/math_operations/math_operations_screen.dart';
import 'package:math_kingdom_builder/features/math_operations/division_screen.dart';
import 'package:math_kingdom_builder/features/math_operations/multiplication_screen.dart';
import 'package:math_kingdom_builder/features/math_operations/subtraction_screen.dart';
import 'package:math_kingdom_builder/features/matching/match_numbers_screen.dart';
import 'package:math_kingdom_builder/features/mini_quiz/mini_quiz_screen.dart';
import 'package:math_kingdom_builder/features/number_tracing/trace_numbers_screen.dart';
import 'package:math_kingdom_builder/features/parent_dashboard/parent_dashboard_screen.dart';
import 'package:math_kingdom_builder/features/patterns/patterns_screen.dart';
import 'package:math_kingdom_builder/features/rewards/rewards_screen.dart';
import 'package:math_kingdom_builder/features/sequencing/sequencing_screen.dart';
import 'package:math_kingdom_builder/features/settings/settings_screen.dart';
import 'package:math_kingdom_builder/onboarding_screen.dart';

import '../../features/home/home_screen.dart';
import '../../features/number_recognition/number_recognition_screen.dart';
import '../../splash_screen.dart';

final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const onboarding = '/onboarding';
  static const numberRecognition = '/number-recognition';
  static const findNumber = '/find-number';
  static const learnNumbers = '/learn-numbers';
  static const counting = '/count-objects';
  static const tracing = '/tracing';
  static const matching = '/matching';
  static const miniQuiz = '/mini-quiz';
  static const mathOperations = '/math-operations';
  static const addition = '/addition';
  static const subtraction = '/subtraction';
  static const multiplication = '/multiplication';
  static const division = '/division';
  static const sequencing = '/sequencing';
  static const patterns = '/patterns';
  static const kingdom = '/kingdom';
  static const stickers = '/stickers';
  static const parentDashboard = '/parent-dashboard';
  static const settings = '/settings';
  static const startlearning = '/start-learning';
}

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
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.numberRecognition,
      redirect: (context, state) => AppRoutes.findNumber,
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
      path: AppRoutes.mathOperations,
      builder: (context, state) => const MathOperationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.addition,
      builder: (context, state) => const AdditionScreen(),
    ),
    GoRoute(
      path: AppRoutes.subtraction,
      builder: (context, state) => const SubtractionScreen(),
    ),
    GoRoute(
      path: AppRoutes.multiplication,
      builder: (context, state) => const MultiplicationScreen(),
    ),
    GoRoute(
      path: AppRoutes.division,
      builder: (context, state) => const DivisionScreen(),
    ),
    GoRoute(
      path: AppRoutes.sequencing,
      builder: (context, state) => const SequencingScreen(),
    ),
    GoRoute(
      path: AppRoutes.patterns,
      builder: (context, state) => const PatternsScreen(),
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
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => SettingsScreen(
        showParentControls: state.uri.queryParameters['source'] == 'parent',
      ),
    ),
  ],
);
