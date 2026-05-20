import 'package:flutter/material.dart';

import 'splash_screen.dart';

class MathKingdomApp extends StatelessWidget {
  const MathKingdomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Kingdom Builder',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Fredoka',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35)),
      ),
      home: const SplashScreen(),
    );
  }
}