import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/router/app_router.dart';
import 'ad_request_config.dart';
import 'interstitial_ad_manager.dart';

/// Central ad API — same pattern most production apps use:
/// preload once, show interstitial with cooldown, banner on eligible screens.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  static const Duration minInterstitialInterval = Duration(seconds: 90);

  DateTime? _lastInterstitialAt;

  static const Set<String> _blockedInterstitialRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.parentDashboard,
    AppRoutes.settings,
  };

  static const Set<String> _gameRoutes = {
    AppRoutes.learnNumbers,
    AppRoutes.counting,
    AppRoutes.findNumber,
    AppRoutes.tracing,
    AppRoutes.matching,
    AppRoutes.miniQuiz,
    AppRoutes.mathOperations,
    AppRoutes.addition,
    AppRoutes.subtraction,
    AppRoutes.multiplication,
    AppRoutes.division,
    AppRoutes.sequencing,
    AppRoutes.patterns,
    AppRoutes.stickers,
    AppRoutes.kingdom,
  };

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await AdRequestConfig.applyGlobalSettings();
    loadInterstitial();
  }

  bool shouldShowBannerForRoute(String? route) {
    if (route == null || route.isEmpty) return false;
    return route != AppRoutes.splash;
  }

  bool isGameRoute(String? route) {
    if (route == null) return false;
    return _gameRoutes.contains(route);
  }

  bool isInterstitialBlocked(String? route) {
    if (route == null) return true;
    return _blockedInterstitialRoutes.contains(route);
  }

  void loadInterstitial() {
    InterstitialAdManager.instance.preload();
  }

  bool get canShowInterstitial {
    final last = _lastInterstitialAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= minInterstitialInterval;
  }

  /// Shows a full-screen ad when available, then runs [onFinished].
  /// If no ad is loaded or cooldown is active, [onFinished] runs immediately.
  Future<void> showInterstitialThen(VoidCallback onFinished) async {
    if (!canShowInterstitial) {
      onFinished();
      loadInterstitial();
      return;
    }

    final shown = InterstitialAdManager.instance.showIfAvailable(
      onDismissed: () {
        _lastInterstitialAt = DateTime.now();
        onFinished();
      },
    );

    if (!shown) {
      onFinished();
    }
  }

  /// Standard hook: user left a learning/game screen via back navigation.
  void showInterstitialOnGameExit(String? route) {
    if (route == null || !isGameRoute(route) || !canShowInterstitial) {
      loadInterstitial();
      return;
    }

    final shown = InterstitialAdManager.instance.showIfAvailable(
      onDismissed: () {
        _lastInterstitialAt = DateTime.now();
        loadInterstitial();
      },
    );

    if (!shown) {
      loadInterstitial();
    }
  }

  /// Standard hook: activity finished and user continues to next screen.
  Future<void> showInterstitialAfterActivity(VoidCallback onContinue) async {
    await showInterstitialThen(onContinue);
  }
}
