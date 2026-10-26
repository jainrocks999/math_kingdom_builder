import 'dart:io';
import 'package:flutter/foundation.dart';

class AdUnitIds {
  AdUnitIds._();

  static const String _androidBannerId =
      'ca-app-pub-3339897183017333/7430923488';

  static const String _androidInterstitialId =
      'ca-app-pub-3339897183017333/2475864297';

  static const String _iosBannerId = 'ca-app-pub-3339897183017333/2500663451';

  static const String _iosInterstitialId =
      'ca-app-pub-3339897183017333/4279367720';

  /// iOS "Native advanced" ad unit, shown full-screen in place of the
  /// interstitial. Create it in AdMob (Apps → eMath iOS → Ad units → Add ad
  static const String _iosNativeId = 'ca-app-pub-3339897183017333/7838837775';

  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  static const String _testIosNativeId =
      'ca-app-pub-3940256099942544/3986624511';

  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdId {
    if (kDebugMode) {
      return _testBannerId;
    }

    return Platform.isIOS ? _iosBannerId : _androidBannerId;
  }

  static String get interstitialAdId {
    if (kDebugMode) {
      return _testInterstitialId;
    }

    return Platform.isIOS ? _iosInterstitialId : _androidInterstitialId;
  }

  /// iOS native ad unit, or an empty string when none is configured.
  static String get iosNativeAdId =>
      kDebugMode ? _testIosNativeId : _iosNativeId;
}
