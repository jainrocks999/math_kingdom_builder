import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/services/audio_service.dart';
import 'core/utils/audio_service.dart';

class MathKingdomApp extends ConsumerStatefulWidget {
  const MathKingdomApp({super.key});

  @override
  ConsumerState<MathKingdomApp> createState() => _MathKingdomAppState();
}

class _MathKingdomAppState extends ConsumerState<MathKingdomApp> {
  late final AppLifecycleListener _appLifecycleListener;
  final FlutterTts _lifecycleTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        unawaited(_handleAppLifecycleState(state));
      },
    );
  }

  Future<void> _handleAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await AppAudioService.instance.handleAppResumed();
        await AudioService().handleAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Stop any screen-owned TTS instances that may still be speaking.
        await _lifecycleTts.stop();
        await AudioService().handleAppBackgrounded();
        await AppAudioService.instance.handleAppBackgrounded();
        break;
    }
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    _lifecycleTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.tr('app.title'),
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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
