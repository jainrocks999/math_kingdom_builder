import 'dart:async';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../shared/widgets/parental_gate.dart';
import '../shared/widgets/top_snackbar.dart';

/// Lock state for one ad. The ad's listener calls [relock] when the ad is
/// clicked or opened, so each grown-up approval allows exactly one visit.
class ParentalAdGateController extends ChangeNotifier {
  bool _unlocked = false;

  /// iOS Kids rules: opening an ad leaves the app, so it needs a grown-up.
  bool get enabled => !kIsWeb && Platform.isIOS;

  bool get locked => enabled && !_unlocked;

  void unlock() {
    if (_unlocked) return;
    _unlocked = true;
    notifyListeners();
  }

  void relock() {
    if (!_unlocked) return;
    _unlocked = false;
    notifyListeners();
  }
}

/// Puts a tap-catching layer over a native ad view (iOS). Tapping it shows
/// the parental gate; a correct answer lets the next tap through to the ad
/// for [unlockDuration]. It locks again when the ad opens, when the app comes
/// back to the foreground, or when the time runs out.
class ParentalAdGate extends StatefulWidget {
  const ParentalAdGate({
    super.key,
    required this.controller,
    required this.child,
    this.unlockDuration = const Duration(seconds: 15),
  });

  final ParentalAdGateController controller;
  final Widget child;
  final Duration unlockDuration;

  @override
  State<ParentalAdGate> createState() => _ParentalAdGateState();
}

class _ParentalAdGateState extends State<ParentalAdGate>
    with WidgetsBindingObserver {
  Timer? _relockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant ParentalAdGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerChanged);
    _relockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the browser: always locked again.
    if (state == AppLifecycleState.resumed) widget.controller.relock();
  }

  void _onControllerChanged() {
    if (widget.controller.locked) _relockTimer?.cancel();
    if (mounted) setState(() {});
  }

  Future<void> _onLockedTap() async {
    if (!await showParentalGate(context) || !mounted) return;
    widget.controller.unlock();
    TopSnackbar.show(
      context,
      message: context.tr('parental_gate.tap_ad_now'),
      color: const Color(0xFF5C7AEA),
      softColor: const Color(0xFFEAF0FF),
      icon: Icons.touch_app_rounded,
    );
    _relockTimer?.cancel();
    _relockTimer = Timer(widget.unlockDuration, widget.controller.relock);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        // Catches taps before they reach the native ad view.
        if (widget.controller.locked)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onLockedTap,
            ),
          ),
      ],
    );
  }
}
