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
  Timer? _skipTimer;
  bool _hasNavigated = false;
  bool _onboardingDone = false;
  bool _showSkip = false;

  @override
  void initState() {
    super.initState();
    _fallbackTimer = Timer(const Duration(seconds: 4), _navigateForward);
    _prepareSessionState();

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

  Future<void> _prepareSessionState() async {
    final onboardingDone =
        await AppSessionService.instance.isOnboardingComplete();
    if (!mounted) return;
    _onboardingDone = onboardingDone;
    if (_onboardingDone) {
      _skipTimer?.cancel();
      _skipTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || _hasNavigated) return;
        setState(() => _showSkip = true);
      });
    }
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
    _skipTimer?.cancel();
    _videoController.removeListener(_onVideoEnd);

    context.go(_onboardingDone ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _skipTimer?.cancel();
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
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (initialized) ...[
              ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: _buildVideo(opacity: 0.28),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: 0.18)),
              _buildVideo(),
            ] else
              Container(color: const Color(0xFF120D31)),
            _buildFallbackLogo(initialized: initialized),
            if (_showSkip)
              Positioned(
                top: 16,
                right: 16,
                child: FilledButton(
                  onPressed: _navigateForward,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.88),
                    foregroundColor: const Color(0xFF1E1060),
                  ),
                  child: const Text('Skip'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo({required bool initialized}) {
    return IgnorePointer(
      ignoring: initialized,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(alpha: initialized ? 0.14 : 0.96),
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.all(18),
              child: Image.asset(
                'assets/logo/math_kingdom_app_logo (1).png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.castle_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Math Kingdom',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            if (!initialized)
              const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
