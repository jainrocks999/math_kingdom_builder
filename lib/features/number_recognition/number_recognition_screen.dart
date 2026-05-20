import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:math_kingdom_builder/app_colors.dart';
import 'package:math_kingdom_builder/app_typography.dart';
import '../../shared/widgets/celebration_overlay.dart';
import '../../shared/widgets/hint_bubble.dart';
import '../../shared/widgets/number_block.dart';
import 'number_recognition_controller.dart';

class NumberRecognitionScreen extends ConsumerWidget {
  const NumberRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(numberRecognitionControllerProvider);
    final controller = ref.read(numberRecognitionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Find the number',
                  style: AppTypography.h1,
                ),
                const SizedBox(height: 32),
                Text(
                  '${state.currentNumber}',
                  style: AppTypography.hero.copyWith(
                    fontSize: 80, 
                    color: AppColors.primary
                  ),
                ),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: state.options.map((number) {
                    return NumberBlock(
                      number: number,
                      onTap: () => controller.checkAnswer(number),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                HintBubble(
                  text: "Try looking for the number ${state.currentNumber}!",
                  isVisible: state.showHint,
                ),
              ],
            ),
          ),
          CelebrationOverlay(isVisible: state.isCorrect),
        ],
      ),
    );
  }
}