import 'dart:io';
import 'package:flutter/foundation.dart';

class AdUnitIds {
  AdUnitIds._();

  static const String _androidBannerId =
      'ca-app-pub-6121378252341914/9765908409';

  static const String _androidInterstitialId =
      'ca-app-pub-6121378252341914/6289697820';

  static const String _iosBannerId = 'ca-app-pub-6121378252341914/6328033338';

  static const String _iosInterstitialId =
      'ca-app-pub-6121378252341914/3297333865';

  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111testing';

  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712testing';

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
}
