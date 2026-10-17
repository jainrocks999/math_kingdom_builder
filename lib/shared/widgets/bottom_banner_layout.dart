import 'package:emath_app/core/services/premium_service.dart';
import 'package:flutter/material.dart';

import '../../ads/mobile_banner_ads.dart';

/// Stacks screen content above a bottom banner without overlapping UI.
///
/// The banner is pinned to the very bottom of the screen and also covers the
/// system navigation area, so the content above must not add its own bottom
/// safe-area padding.
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

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          // The banner bar below handles the bottom inset.
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: PremiumService.instance.adsRemoved,
          builder: (context, adsRemoved, _) => adsRemoved
              ? SizedBox(height: bottomInset)
              : BannerAdWidget(bottomPadding: bottomInset),
        ),
      ],
    );
  }
}
