import 'package:easy_localization/easy_localization.dart';
import 'package:emath_app/core/constants/app_colors.dart';
import 'package:emath_app/core/constants/app_typography.dart';
import 'package:emath_app/shared/widgets/top_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/services/app_store_version_service.dart';

/// Every store update is mandatory.
///
/// * Android: Play's immediate in-app update; cancelling shows a snackbar.
/// * iOS: no in-app update API exists, so the App Store version is checked and
///   "Update now" opens the App Store. Coming back without updating shows the
///   same snackbar.
class StartupUpdateGate extends StatefulWidget {
  const StartupUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<StartupUpdateGate> createState() => _StartupUpdateGateState();
}

class _StartupUpdateGateState extends State<StartupUpdateGate>
    with WidgetsBindingObserver {
  bool _updateRequired = false;
  bool _busy = false;

  /// iOS: the App Store release to install, and whether the App Store was
  /// opened (iOS ends the app when it updates, so returning means it didn't).
  AppStoreRelease? _iosRelease;
  bool _openedAppStore = false;

  BuildContext? _overlayContext;

  late final OverlayEntry _screenEntry =
      OverlayEntry(builder: (overlayContext) {
    _overlayContext = overlayContext;
    return _UpdateRequiredPage(onUpdate: _onUpdatePressed);
  });

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_updateRequired) {
      _screenEntry.remove();
      _screenEntry.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the App Store without updating (iOS restarts the app after
    // an update, so this only runs when the update was skipped).
    if (state == AppLifecycleState.resumed &&
        _isIOS &&
        _updateRequired &&
        _openedAppStore) {
      _openedAppStore = false;
      _showMessage('update.cancelled');
    }
  }

  Future<void> _checkAndUpdate() async {
    if (_isAndroid) {
      await _checkAndroid();
    } else if (_isIOS) {
      await _checkIos();
    }
  }

  void _onUpdatePressed() {
    if (_isIOS) {
      _openAppStore();
    } else {
      _checkAndUpdate();
    }
  }

  Future<void> _checkIos() async {
    if (_busy) return;
    _busy = true;
    try {
      final release = await AppStoreVersionService.instance.requiredUpdate();
      if (release == null) return;
      _iosRelease = release;
      _setRequired(true);
    } catch (e) {
      debugPrint('App Store update check failed: $e');
    } finally {
      _busy = false;
    }
  }

  Future<void> _openAppStore() async {
    final release = _iosRelease;
    if (release == null) return;
    try {
      final opened = await launchUrl(
        release.storeUrl,
        mode: LaunchMode.externalApplication,
      );
      if (opened) {
        _openedAppStore = true;
      } else {
        _showMessage('update.failed');
      }
    } catch (e) {
      debugPrint('Opening the App Store failed: $e');
      _showMessage('update.failed');
    }
  }

  Future<void> _checkAndroid() async {
    if (_busy) return;
    _busy = true;
    try {
      final info = await InAppUpdate.checkForUpdate()
          .timeout(const Duration(seconds: 8));

      final hasUpdate =
          info.updateAvailability == UpdateAvailability.updateAvailable ||
              info.updateAvailability ==
                  UpdateAvailability.developerTriggeredUpdateInProgress;

      if (!hasUpdate) {
        _setRequired(false);
        return;
      }

      _setRequired(true);

      if (!info.immediateUpdateAllowed) {
        _showMessage('update.not_allowed');
        return;
      }

      final result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.userDeniedUpdate) {
        _showMessage('update.cancelled');
      } else if (result == AppUpdateResult.inAppUpdateFailed) {
        _showMessage('update.failed');
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
      if (_updateRequired) _showMessage('update.offline');
    } finally {
      _busy = false;
    }
  }

  void _setRequired(bool required) {
    if (!mounted || _updateRequired || !required) return;
    setState(() => _updateRequired = required);
  }

  void _showMessage(String key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayContext = _overlayContext;
      if (!mounted || overlayContext == null) return;
      TopSnackbar.show(
        overlayContext,
        message: overlayContext.tr(key),
        color: AppColors.primary,
        softColor: AppColors.primaryLight,
        icon: Icons.system_update_rounded,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_updateRequired) return widget.child;
    return PopScope(
      canPop: false,
      child: Overlay(initialEntries: [_screenEntry]),
    );
  }
}

class _UpdateRequiredPage extends StatelessWidget {
  const _UpdateRequiredPage({required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update_rounded,
                    size: 72, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(context.tr('update.title'),
                    textAlign: TextAlign.center, style: AppTypography.h2),
                const SizedBox(height: 8),
                Text(context.tr('update.message'),
                    textAlign: TextAlign.center, style: AppTypography.body),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onUpdate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: Text(context.tr('update.button'),
                      style: AppTypography.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
