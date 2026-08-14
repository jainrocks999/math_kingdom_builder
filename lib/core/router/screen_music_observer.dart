import 'package:flutter/widgets.dart';

import '../services/audio_service.dart';
import 'app_router.dart';

/// Restores screen-owned background music when routes are popped.
///
/// GoRouter + [RouteAware] is unreliable for top-level routes, so this observer
/// listens to navigator transitions directly.
class ScreenMusicNavigatorObserver extends NavigatorObserver {
  static const Duration _resumeDelay = Duration(milliseconds: 220);

  int _resumeToken = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _scheduleMusicForRoute(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _scheduleMusicForRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _scheduleMusicForRoute(newRoute);
  }

  void _scheduleMusicForRoute(Route<dynamic>? route) {
    if (route == null) return;

    final location = _routeLocation(route);
    if (location == null) return;

    final token = ++_resumeToken;
    Future<void>.delayed(_resumeDelay, () {
      if (token != _resumeToken) return;
      _playMusicForLocation(location);
    });
  }

  String? _routeLocation(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      return name.startsWith('/') ? name : '/$name';
    }
    return null;
  }

  void _playMusicForLocation(String location) {
    switch (location) {
      case AppRoutes.home:
      case AppRoutes.onboarding:
        AppAudioService.instance.playHomeMusic();
        return;
      case AppRoutes.kingdom:
        AppAudioService.instance.playKingdomMusic();
        return;
      case AppRoutes.startlearning:
      case AppRoutes.learnNumbers:
      case AppRoutes.counting:
      case AppRoutes.findNumber:
      case AppRoutes.tracing:
      case AppRoutes.matching:
      case AppRoutes.miniQuiz:
      case AppRoutes.addition:
      case AppRoutes.subtraction:
      case AppRoutes.multiplication:
      case AppRoutes.division:
      case AppRoutes.sequencing:
      case AppRoutes.patterns:
      case AppRoutes.stickers:
        AppAudioService.instance.playStartCountingMusic();
        return;
      default:
        return;
    }
  }
}
