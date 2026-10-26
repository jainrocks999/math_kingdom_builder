import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/router/app_router.dart';
import '../core/services/audio_service.dart';
import 'ad_request_config.dart';
import 'ad_units_ids.dart';
import 'parental_ad_gate.dart';

/// iOS replacement for interstitial ads: a native ad shown on a full-screen
/// Flutter page that looks like an interstitial. Unlike a real interstitial,
/// taps can be caught first, so opening the ad goes through the parental gate.
///
/// Same API as InterstitialAdManager: [preload] and [showIfAvailable].
class NativeInterstitialManager {
  NativeInterstitialManager._();

  static final NativeInterstitialManager instance =
      NativeInterstitialManager._();

  NativeAd? _ad;
  ParentalAdGateController? _gate;
  bool _isLoading = false;
  bool _isLoaded = false;

  static final NativeTemplateStyle _templateStyle = NativeTemplateStyle(
    templateType: TemplateType.medium,
    mainBackgroundColor: Colors.white,
    cornerRadius: 16,
    callToActionTextStyle: NativeTemplateTextStyle(
      textColor: Colors.white,
      backgroundColor: AppColors.primary,
      style: NativeTemplateFontStyle.bold,
      size: 16,
    ),
    primaryTextStyle: NativeTemplateTextStyle(
      textColor: const Color(0xFF1E1060),
      style: NativeTemplateFontStyle.bold,
      size: 16,
    ),
    secondaryTextStyle: NativeTemplateTextStyle(
      textColor: const Color(0xFF5A6B7A),
      size: 14,
    ),
    tertiaryTextStyle: NativeTemplateTextStyle(
      textColor: const Color(0xFF5A6B7A),
      size: 14,
    ),
  );

  void preload() {
    if (_ad != null || _isLoading) return;
    final adUnitId = AdUnitIds.iosNativeAdId;
    if (adUnitId.isEmpty) return;

    _isLoading = true;
    final gate = ParentalAdGateController();
    final ad = NativeAd(
      adUnitId: adUnitId,
      request: AdRequestConfig.request,
      nativeTemplateStyle: _templateStyle,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          _isLoading = false;
          _isLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native full-screen ad failed to load: $error');
          ad.dispose();
          gate.dispose();
          _ad = null;
          _gate = null;
          _isLoading = false;
          _isLoaded = false;
        },
        // Each grown-up approval allows exactly one visit to the ad.
        onAdClicked: (_) => gate.relock(),
        onAdOpened: (_) => gate.relock(),
      ),
    );
    _ad = ad;
    _gate = gate;
    ad.load();
  }

  /// Returns `true` when an ad will be shown, `false` when none is ready.
  /// [onDismissed] runs after the ad page is closed.
  bool showIfAvailable({VoidCallback? onDismissed}) {
    final ad = _ad;
    final gate = _gate;
    final navigator = appRouter.routerDelegate.navigatorKey.currentState;
    if (ad == null || gate == null || !_isLoaded || navigator == null) {
      preload();
      return false;
    }

    _ad = null;
    _gate = null;
    _isLoaded = false;

    // Often called while a route is being popped; push on the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppAudioService.instance.stopBackgroundMusic();
      await navigator.push(
        PageRouteBuilder<void>(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (_, __, ___) =>
              NativeInterstitialPage(ad: ad, gate: gate),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      ad.dispose();
      gate.dispose();
      onDismissed?.call();
      preload();
    });
    WidgetsBinding.instance.scheduleFrame();
    return true;
  }
}

/// Full-screen page that presents a native ad like an interstitial.
class NativeInterstitialPage extends StatefulWidget {
  const NativeInterstitialPage({
    super.key,
    required this.ad,
    required this.gate,
  });

  final NativeAd ad;
  final ParentalAdGateController gate;

  @override
  State<NativeInterstitialPage> createState() => _NativeInterstitialPageState();
}

class _NativeInterstitialPageState extends State<NativeInterstitialPage> {
  /// Seconds before the close button appears, like an interstitial.
  static const int _closeDelaySeconds = 3;

  int _secondsLeft = _closeDelaySeconds;
  Timer? _countdown;

  bool get _canClose => _secondsLeft <= 0;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_canClose) timer.cancel();
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _close() {
    if (_canClose) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canClose,
      child: Scaffold(
        backgroundColor: const Color(0xFF14123A),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('ads.label'),
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF1E1060),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _CloseButton(
                      secondsLeft: _secondsLeft,
                      onClose: _close,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = math.min(constraints.maxWidth - 40, 400.0);
                    final height = math.min(
                      math.max(width, 320.0),
                      constraints.maxHeight - 24,
                    );
                    return Center(
                      child: Container(
                        width: width,
                        height: height,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 30,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: ParentalAdGate(
                            controller: widget.gate,
                            child: AdWidget(ad: widget.ad),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.secondsLeft, required this.onClose});

  final int secondsLeft;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final canClose = secondsLeft <= 0;
    return Semantics(
      button: canClose,
      label: canClose ? context.tr('ads.close') : null,
      child: GestureDetector(
        onTap: canClose ? onClose : null,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: canClose ? 0.95 : 0.18),
          ),
          child: canClose
              ? const Icon(Icons.close_rounded, color: Color(0xFF1E1060))
              : Text(
                  '$secondsLeft',
                  style: AppTypography.bodyStrong.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
