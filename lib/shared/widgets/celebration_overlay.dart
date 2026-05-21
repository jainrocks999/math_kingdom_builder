import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CelebrationOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onComplete;

  const CelebrationOverlay({
    super.key,
    this.isVisible = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          'assets/animations/confetti.json',
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () => onComplete?.call());
          },
        ),
      ),
    );
  }
}