import 'dart:async';

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
  int _retryAttempt = 0;
  Timer? _retryTimer;

  static const Duration _retryDelay = Duration(seconds: 8);
  static const int _maxRetries = 6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width;
    if (_requestedWidth != width) {
      _requestedWidth = width;
      _retryAttempt = 0;
      _loadAd(width);
    }
  }

  Future<void> _loadAd(double width) async {
    _retryTimer?.cancel();

    final adWidth = width.truncate();
    if (adWidth <= 0) return;

    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth);
    if (!mounted || size == null) {
      _scheduleRetry(width);
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
            _scheduleRetry(width);
          }
        },
      ),
    );

    _bannerAd = banner;
    await banner.load();
  }

  void _scheduleRetry(double width) {
    if (_retryAttempt >= _maxRetries || !mounted) return;
    _retryAttempt += 1;
    _retryTimer = Timer(_retryDelay, () {
      if (mounted) _loadAd(width);
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
