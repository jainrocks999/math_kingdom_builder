import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/responsive_layout.dart';

/// Locks orientation by device class: phones portrait, tablets landscape.
class DeviceOrientationService {
  DeviceOrientationService._();

  static const MethodChannel _channel = MethodChannel(
    'com.forebear.mathkingdombuilder/device',
  );

  static bool? _isTablet;

  static bool get isTablet => _isTablet ?? false;

  static bool detectTabletFromView({FlutterView? view}) {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) return false;
    final targetView = view ?? views.first;

    final logicalSize = targetView.physicalSize / targetView.devicePixelRatio;
    if (logicalSize.shortestSide <= 0) return false;
    return logicalSize.shortestSide >= ResponsiveLayout.tabletBreakpoint;
  }

  static Future<bool> detectTabletAsync() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      try {
        final nativeIsTablet = await _channel.invokeMethod<bool>('isTablet');
        if (nativeIsTablet != null) return nativeIsTablet;
      } catch (_) {
        // Fall back to view metrics when the channel is unavailable.
      }
    }

    return detectTabletFromView();
  }

  static Future<void> initialize() async {
    _isTablet = await detectTabletAsync();
    await applyLock();
  }

  static Future<void> ensureInitialized(BuildContext? context) async {
    if (_isTablet == true) {
      await applyLock();
      return;
    }

    if (context != null) {
      final size = MediaQuery.sizeOf(context);
      if (size.shortestSide >= ResponsiveLayout.tabletBreakpoint) {
        _isTablet = true;
        await applyLock();
        return;
      }
    }

    final detected = await detectTabletAsync();
    if (_isTablet != detected) {
      _isTablet = detected;
      await applyLock();
    }
  }

  static Future<void> applyLock() async {
    if (isTablet) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      return;
    }

    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }
}
