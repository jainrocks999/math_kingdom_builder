import 'package:flutter/foundation.dart';

class AdUnitIds {
  AdUnitIds._();

  static const String _prodBannerId = 'ca-app-pub-6121378252341914/9765908409';
  static const String _prodInterstitialId =
      'ca-app-pub-6121378252341914/6289697820';

  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdId => kDebugMode ? _testBannerId : _prodBannerId;

  static String get interstitialAdId =>
      kDebugMode ? _testInterstitialId : _prodInterstitialId;
}
