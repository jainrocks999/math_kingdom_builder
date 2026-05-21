import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/router/app_router.dart';

class MathKingdomApp extends ConsumerWidget {
  const MathKingdomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Math Kingdom Builder',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surfaceBright: AppColors.background,
          surface: AppColors.surface,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.hero,
          headlineLarge: AppTypography.h1,
          headlineMedium: AppTypography.h2,
          bodyMedium: AppTypography.body,
          labelSmall: AppTypography.caption,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            textStyle: AppTypography.button,
            minimumSize: const Size(72, 72), // Min tap target from doc
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
