import 'package:flutter/material.dart';
import 'package:math_kingdom_builder/app_colors.dart';
import 'package:math_kingdom_builder/app_typography.dart';
import 'features/number_recognition/number_recognition_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for 2 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    // Navigate to the first feature screen and remove the splash screen from the back stack
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const NumberRecognitionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder icon until you get your final mascot/logo asset
            const Icon(Icons.castle_rounded, size: 100, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Math Kingdom',
              style: AppTypography.hero.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}