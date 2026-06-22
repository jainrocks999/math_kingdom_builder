import 'package:flutter/services.dart';

import '../../core/utils/audio_service.dart';

class FeedbackHelper {
  FeedbackHelper._();

  static final AudioService _audio = AudioService();

  static Future<void> playCorrect({
    Future<void> Function()? speak,
  }) async {
    HapticFeedback.mediumImpact();
    await _audio.playSfx('sfx/correct.mp3');
    if (speak != null) {
      await Future<void>.delayed(const Duration(milliseconds: 320));
      await speak();
    }
  }

  static Future<void> playWrong({
    Future<void> Function()? speak,
  }) async {
    HapticFeedback.lightImpact();
    await _audio.playWrongFeedback();
    if (speak != null) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      await speak();
    }
  }
}
