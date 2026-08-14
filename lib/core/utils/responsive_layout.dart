import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared breakpoints and helpers for phone portrait + tablet landscape layouts.
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double tabletBreakpoint = 600;
  static const double largeTabletBreakpoint = 900;
  static const double hubMaxWidth = 1120;
  static const double gameMaxWidth = 980;

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isTablet(BuildContext context) =>
      sizeOf(context).shortestSide >= tabletBreakpoint;

  static bool isLargeTablet(BuildContext context) =>
      sizeOf(context).shortestSide >= largeTabletBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool isTabletLandscape(BuildContext context) => isTablet(context);

  static double uiScale(BuildContext context) {
    if (!isTablet(context)) return 1.0;
    return isLargeTablet(context) ? 1.08 : 1.05;
  }

  static double scaled(BuildContext context, double value) =>
      value * uiScale(context);

  static EdgeInsets hubPadding(BuildContext context) {
    if (isTablet(context)) {
      return const EdgeInsets.fromLTRB(28, 14, 28, 24);
    }
    return const EdgeInsets.fromLTRB(18, 12, 18, 28);
  }

  static EdgeInsets gamePadding(BuildContext context) {
    if (isTablet(context)) {
      return const EdgeInsets.fromLTRB(24, 10, 24, 14);
    }
    return const EdgeInsets.fromLTRB(16, 12, 16, 20);
  }

  static int gridCrossAxisCount(
    BuildContext context, {
    int phone = 2,
    int tablet = 3,
    int largeTablet = 4,
  }) {
    if (!isTablet(context)) return phone;
    final width = sizeOf(context).width;
    if (width >= largeTabletBreakpoint) return largeTablet;
    return tablet;
  }

  static double featuredCardAspectRatio(BuildContext context) {
    if (isTablet(context)) return 1.45;
    final width = sizeOf(context).width;
    if (width < 340) return 0.94;
    if (width < 380) return 1.02;
    return 1.14;
  }

  static double questCardAspectRatio(BuildContext context) {
    if (isTablet(context)) return 1.15;
    final width = sizeOf(context).width;
    if (width < 340) return 0.78;
    if (width < 380) return 0.87;
    return 0.96;
  }

  static double titleSize(
    BuildContext context, {
    required double phone,
    required double tablet,
  }) =>
      isTablet(context) ? tablet : phone;

  /// Height-based compact layouts are for phones only. Tablet landscape height
  /// is naturally shorter than portrait width, so raw height checks break UI.
  static bool isCompactHeight(
    BuildContext context,
    double threshold, {
    BoxConstraints? constraints,
  }) {
    if (isTablet(context)) return false;
    final height = constraints?.maxHeight ?? sizeOf(context).height;
    return height.isFinite && height < threshold;
  }

  static bool isCompactWidth(
    BuildContext context,
    double threshold, {
    BoxConstraints? constraints,
  }) {
    if (isTablet(context)) return false;
    final width = constraints?.maxWidth ?? sizeOf(context).width;
    return width.isFinite && width < threshold;
  }
}

/// Centers hub content on tablets without forcing a fixed height.
class AdaptiveContentWidth extends StatelessWidget {
  const AdaptiveContentWidth({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveLayout.hubMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.min(constraints.maxWidth, maxWidth);
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Centers gameplay screens on wide tablets while keeping full height for columns.
class AdaptiveGameFrame extends StatelessWidget {
  const AdaptiveGameFrame({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = ResponsiveLayout.isTablet(context);
        final maxWidth =
            isTablet ? ResponsiveLayout.gameMaxWidth : constraints.maxWidth;
        final contentWidth = math.min(constraints.maxWidth, maxWidth);
        final effectivePadding =
            padding ?? ResponsiveLayout.gamePadding(context);
        final resolvedPadding = effectivePadding.resolve(Directionality.of(context));
        final availableHeight = constraints.hasBoundedHeight
            ? math.max(0.0, constraints.maxHeight - resolvedPadding.vertical)
            : null;

        return Padding(
          padding: effectivePadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: availableHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
