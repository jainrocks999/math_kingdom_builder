import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_typography.dart';

/// A kid-friendly hint that slides down from the top of the screen.
///
/// Only one is visible at a time; showing a new one replaces the old one.
class TopSnackbar {
  TopSnackbar._();

  static _TopSnackbarHandle? _current;

  static void show(
    BuildContext context, {
    required String message,
    required Color color,
    required Color softColor,
    IconData icon = Icons.touch_app_rounded,
    Duration duration = const Duration(seconds: 4),
  }) {
    hide(immediate: true);

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final handle = _TopSnackbarHandle();
    handle.entry = OverlayEntry(
      builder: (_) => _TopSnackbarView(
        key: handle.viewKey,
        message: message,
        color: color,
        softColor: softColor,
        icon: icon,
        duration: duration,
        onDismissed: () => _remove(handle),
      ),
    );
    _current = handle;
    overlay.insert(handle.entry);
  }

  /// Slides the current snackbar away. Pass [immediate] to remove it without
  /// animation (e.g. when the screen is being disposed).
  static void hide({bool immediate = false}) {
    final handle = _current;
    if (handle == null) return;

    final view = handle.viewKey.currentState;
    if (immediate || view == null) {
      _remove(handle);
    } else {
      view.dismiss();
    }
  }

  static void _remove(_TopSnackbarHandle handle) {
    if (identical(_current, handle)) _current = null;
    if (handle.removed) return;
    handle.removed = true;
    handle.entry.remove();
  }
}

class _TopSnackbarHandle {
  final GlobalKey<_TopSnackbarViewState> viewKey = GlobalKey();
  late final OverlayEntry entry;
  bool removed = false;
}

class _TopSnackbarView extends StatefulWidget {
  const _TopSnackbarView({
    super.key,
    required this.message,
    required this.color,
    required this.softColor,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Color color;
  final Color softColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopSnackbarView> createState() => _TopSnackbarViewState();
}

class _TopSnackbarViewState extends State<_TopSnackbarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.4),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
  ));

  Timer? _autoHideTimer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _autoHideTimer = Timer(widget.duration, dismiss);
  }

  Future<void> dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _autoHideTimer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topInset + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _controller,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Semantics(
                liveRegion: true,
                child: GestureDetector(
                  onTap: dismiss,
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) < 0) dismiss();
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Color.lerp(Colors.white, widget.softColor, 0.55),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(widget.icon, color: widget.color, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: AppTypography.bodySmall.copyWith(
                                color: widget.color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
