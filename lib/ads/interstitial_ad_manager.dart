import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_units_ids.dart';

class InterstitialAdManager {
  InterstitialAdManager._();

  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  VoidCallback? _pendingOnDismissed;

  void preload() {
    if (_interstitialAd != null || _isLoading) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitialAd = ad;
          _attachFullScreenCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  void _attachFullScreenCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        final callback = _pendingOnDismissed;
        _pendingOnDismissed = null;
        callback?.call();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        debugPrint('Interstitial failed to show: $error');
        final callback = _pendingOnDismissed;
        _pendingOnDismissed = null;
        callback?.call();
        preload();
      },
    );
  }

  /// Returns `true` when an ad was shown, `false` when nothing was available.
  bool showIfAvailable({VoidCallback? onDismissed}) {
    final ad = _interstitialAd;
    if (ad == null) {
      preload();
      return false;
    }

    _interstitialAd = null;
    _pendingOnDismissed = onDismissed;
    _attachFullScreenCallbacks(ad);
    ad.show();
    return true;
  }
}
