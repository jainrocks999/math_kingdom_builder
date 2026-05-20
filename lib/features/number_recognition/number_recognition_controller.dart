import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';
import 'number_recognition_state.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/celebration_service.dart';

part 'number_recognition_controller.g.dart';

@riverpod
class NumberRecognitionController extends _$NumberRecognitionController {
  final _random = Random();
  int _wrongAttempts = 0;

  @override
  NumberRecognitionState build() {
    final initialState = _generateNextState(const {});
    // Speak the target number when the screen initially loads
    Future.microtask(() {
      AudioService().speakNumber(initialState.currentNumber);
    });
    return initialState;
  }

  NumberRecognitionState _generateNextState(Set<int> mastered) {
    // Stage 1: Numbers 1-3
    int target = _random.nextInt(3) + 1; 
    
    List<int> options = [target];
    while (options.length < 3) {
      int wrong = _random.nextInt(5) + 1;
      if (!options.contains(wrong)) {
        options.add(wrong);
      }
    }
    options.shuffle();

    return NumberRecognitionState(
      currentNumber: target,
      options: options,
      masteredNumbers: mastered,
    );
  }

  void checkAnswer(int selected) {
    if (state.isCorrect) return; // Prevent extra taps while animating

    // Speak the number the child tapped
    AudioService().speakNumber(selected);

    if (selected == state.currentNumber) {
      // Correct Answer!
      AudioService().playCorrectFeedback();
      CelebrationService().trigger(CelebrationType.sparkle);

      final newMastered = Set<int>.from(state.masteredNumbers)..add(selected);
      state = state.copyWith(
        isCorrect: true, 
        showHint: false, 
        masteredNumbers: newMastered
      );
      
      // Load next number after a delay so they see the celebration
      Future.delayed(const Duration(milliseconds: 2000), () {
        state = _generateNextState(newMastered);
        _wrongAttempts = 0;
        
        // Speak the new target number
        AudioService().speakNumber(state.currentNumber);
      });
    } else {
      // Wrong Answer
      _wrongAttempts++;
      AudioService().playWrongFeedback();
      
      if (_wrongAttempts >= 3) {
        state = state.copyWith(showHint: true);
        // Repeat target
        AudioService().speakNumber(state.currentNumber);
      } else if (_wrongAttempts >= 2) {
        state = state.copyWith(options: List<int>.from(state.options)..shuffle());
      }
    }
  }
}