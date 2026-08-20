import 'package:flutter/material.dart';

import '../../ads/mobile_banner_ads.dart';

/// Stacks screen content above a bottom banner without overlapping UI.
class ScreenBannerHost extends StatelessWidget {
  const ScreenBannerHost({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  final Widget child;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    if (!showBanner) return child;

    return Column(
      children: [
        Expanded(child: child),
        const SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: Center(
            child: BannerAdWidget(),
          ),
        ),
      ],
    );
  }
}
