import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/services/audio_service.dart';
import 'core/services/device_orientation_service.dart';
import 'core/utils/audio_service.dart';
import 'core/utils/responsive_layout.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        DeviceOrientationService.ensureInitialized(context).then((_) {
          if (mounted) setState(() {});
        }),
      );
    });
  }

  Future<void> _handleAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await DeviceOrientationService.applyLock();
        await AppAudioService.instance.handleAppResumed();
        await AudioService().handleAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
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

  ThemeData _buildTheme({required bool isTablet}) {
    final tapScale = isTablet ? 1.05 : 1.0;
    final tapTarget = 72.0 * tapScale;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surfaceBright: AppColors.background,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
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
          minimumSize: Size(tapTarget, tapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * tapScale),
          ),
        ),
      ),
    );
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
      theme: _buildTheme(isTablet: DeviceOrientationService.isTablet),
      builder: (context, child) {
        final isTablet = ResponsiveLayout.isTablet(context);
        final textScale = isTablet ? 1.05 : 1.0;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
