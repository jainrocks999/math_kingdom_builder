import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_request_config.dart';
import 'ad_units_ids.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  double? _requestedWidth;
  Orientation? _requestedOrientation;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  static const Duration _retryDelay = Duration(seconds: 8);
  static const int _maxRetries = 6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width;
    final orientation = MediaQuery.orientationOf(context);
    if (_requestedWidth != width || _requestedOrientation != orientation) {
      _requestedWidth = width;
      _requestedOrientation = orientation;
      _retryAttempt = 0;
      _loadAd(width, orientation);
    }
  }

  Future<AdSize?> _resolveBannerSize(double width, Orientation orientation) async {
    final adWidth = width.truncate();
    if (adWidth <= 0) return null;

    // iOS "large" adaptive banners are 320x100 and cover too much UI.
    // Use the standard anchored adaptive size (~50px tall) on Apple devices.
    if (!kIsWeb && Platform.isIOS) {
      // Standard ~50px banner; large adaptive is 100px and blocks UI on iPhone/iPad.
      // ignore: deprecated_member_use
      return AdSize.getAnchoredAdaptiveBannerAdSize(orientation, adWidth);
    }

    return AdSize.getLargeAnchoredAdaptiveBannerAdSize(adWidth);
  }

  Future<void> _loadAd(double width, Orientation orientation) async {
    _retryTimer?.cancel();

    final size = await _resolveBannerSize(width, orientation);
    if (!mounted || size == null) {
      _scheduleRetry(width, orientation);
      return;
    }

    await _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _adSize = size;

    final banner = BannerAd(
      adUnitId: AdUnitIds.bannerAdId,
      size: size,
      request: AdRequestConfig.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded (${AdUnitIds.bannerAdId})');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _retryAttempt = 0;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint(
            'Banner ad failed (attempt ${_retryAttempt + 1}): '
            '${error.code} ${error.message}',
          );
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
            _scheduleRetry(width, orientation);
          }
        },
      ),
    );

    _bannerAd = banner;
    await banner.load();
  }

  void _scheduleRetry(double width, Orientation orientation) {
    if (_retryAttempt >= _maxRetries || !mounted) return;
    _retryAttempt += 1;
    _retryTimer = Timer(_retryDelay, () {
      if (mounted) _loadAd(width, orientation);
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null || _adSize == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _adSize!.width.toDouble(),
      height: _adSize!.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
