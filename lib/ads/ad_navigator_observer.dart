import 'package:flutter/widgets.dart';

import 'ad_service.dart';

/// Shows interstitial ads when users leave learning/game screens.
class AdNavigatorObserver extends NavigatorObserver {
  String? _routeLocation(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      return name.startsWith('/') ? name : '/$name';
    }
    return null;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final exitedRoute = _routeLocation(route);
    AdService.instance.showInterstitialOnGameExit(exitedRoute);
  }
}
