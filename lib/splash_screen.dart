import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'core/router/app_router.dart';
import 'core/services/app_session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  Timer? _fallbackTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _fallbackTimer = Timer(const Duration(seconds: 6), _navigateForward);

    _videoController = VideoPlayerController.asset(
      'assets/videos/splash_video.mp4',
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController
          ..setLooping(false)
          ..play();
        _videoController.addListener(_onVideoEnd);
      }).catchError((_) {
        _navigateForward();
      });
  }

  void _onVideoEnd() {
    if (_videoController.value.position >= _videoController.value.duration &&
        !_videoController.value.isPlaying) {
      _navigateForward();
    }
  }

  Future<void> _navigateForward() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();
    _videoController.removeListener(_onVideoEnd);

    final onboardingDone =
        await AppSessionService.instance.isOnboardingComplete();
    if (!mounted) return;

    context.go(onboardingDone ? AppRoutes.home : AppRoutes.onbording);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _videoController.removeListener(_onVideoEnd);
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildVideo({double opacity = 1}) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController.value.size.width,
          height: _videoController.value.size.height,
          child: Opacity(
            opacity: opacity,
            child: VideoPlayer(_videoController),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _videoController.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: initialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: _buildVideo(opacity: 0.28),
                  ),
                ),
                Container(color: Colors.black.withValues(alpha: 0.18)),
                _buildVideo(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}
