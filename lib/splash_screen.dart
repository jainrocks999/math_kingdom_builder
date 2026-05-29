import 'dart:ui';

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

        _videoController
          ..setLooping(false)
          ..play();

        _videoController.addListener(_onVideoEnd);
      });
  }

  void _onVideoEnd() {
    if (_videoController.value.position >=
            _videoController.value.duration &&
        !_videoController.value.isPlaying) {
      _videoController.removeListener(_onVideoEnd);

      if (!mounted) return;

      context.go(AppRoutes.onbording);
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: _videoController.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                /// Blur Background Video
                ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 22,
                      sigmaY: 22,
                    ),
                    child: _buildVideo(opacity: 0.28),
                  ),
                ),

                /// Dark Overlay
                Container(
                  color: Colors.black.withValues(alpha: 0.18),
                ),

                /// Main Fullscreen Video
                _buildVideo(),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}