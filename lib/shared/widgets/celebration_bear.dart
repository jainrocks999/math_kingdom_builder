import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebrationBear extends StatefulWidget {
  const CelebrationBear({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  State<CelebrationBear> createState() => _CelebrationBearState();
}

class _CelebrationBearState extends State<CelebrationBear>
    with SingleTickerProviderStateMixin {
  static const List<String> _frames = [
    'assets/images/bear/idle.png',
    'assets/images/bear/waw.png',
    'assets/images/bear/clapping.png',
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final frameIndex = (progress * _frames.length).floor() % _frames.length;
        final bobOffset =
            math.sin(progress * math.pi * 2) * (widget.size * 0.03);
        final scale = 0.98 + (math.sin(progress * math.pi * 2).abs() * 0.04);

        return Transform.translate(
          offset: Offset(0, -bobOffset),
          child: Transform.scale(
            scale: scale,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Image.asset(
                _frames[frameIndex],
                key: ValueKey<String>(_frames[frameIndex]),
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
