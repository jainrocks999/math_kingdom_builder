import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset(
      'assets/videos/splash_video.mp4',
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.setLooping(false);
        _videoController.play();

        // Navigate when video ends
        _videoController.addListener(_onVideoEnd);
      });
  }

  void _onVideoEnd() {
    if (_videoController.value.position >= _videoController.value.duration &&
        !_videoController.value.isPlaying) {
      _videoController.removeListener(_onVideoEnd);
      if (!mounted) return;
      // Redirects to onboarding. Ensure this route is mapped in app_router.dart!
      context.go(AppRoutes.onbording);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final videoHeight = screenSize.width * (9 / 16);

    return Scaffold(
      backgroundColor: const Color(0xFFC6C6C6), // matches the video's grey bg
      body: Stack(
        children: [
          // --- Background gradient matching video grey ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8E8E8), // lighter top
                  Color(0xFFCBCBCB), // mid — matches video bg
                  Color(0xFFB8B8B8), // slightly deeper bottom
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // --- Video centered ---
          Center(
            child: _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayer(_videoController),
                  )
                : const SizedBox.shrink(),
          ),

          // --- Top fade: blends screen top into video top edge ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: (screenSize.height - videoHeight) / 2 + 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8E8E8),
                    Color(0x00E8E8E8), // fade out into transparent
                  ],
                ),
              ),
            ),
          ),

          // --- Bottom fade: blends video bottom edge into screen bottom ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: (screenSize.height - videoHeight) / 2 + 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFB8B8B8),
                    Color(0x00B8B8B8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
