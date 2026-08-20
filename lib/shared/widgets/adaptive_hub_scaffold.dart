import 'package:flutter/material.dart';
import 'package:math_kingdom_builder/ads/mobile_banner_ads.dart';

import '../../core/utils/responsive_layout.dart';

/// Background + safe area wrapper for hub screens (home, start learning, etc.).
class AdaptiveHubScaffold extends StatelessWidget {
  const AdaptiveHubScaffold({
    super.key,
    required this.body,
    this.backgroundAsset = 'assets/images/backround.png',
  });

  final Widget body;
  final String backgroundAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF87CEEB).withValues(alpha: 0.55),
                  const Color(0xFFB8E4FF).withValues(alpha: 0.30),
                  Theme.of(context)
                      .scaffoldBackgroundColor
                      .withValues(alpha: 0.25),
                  const Color(0xFFF0F4FF).withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
          SafeArea(
              child: Stack(children: [
            AdaptiveContentWidth(
              padding: ResponsiveLayout.hubPadding(context),
              child: body,
            ),
           Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: BannerAdWidget(),
      ),
          ])),
        ],
      ),
    );
  }
}
