import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_voice_helper.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  Future<void> init() async {
    // Configure TTS
    await TtsVoiceHelper.applyPreferredVoice(
      _tts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'hi-IN'],
    );
    await _tts.setSpeechRate(0.45); // Slow for young children
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // Slightly warm/high

    // Start background music (Uncomment when you add the asset)
    // await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    // await playMusic('music/background_1.mp3');
  }

  // Play a pre-recorded voice file
  Future<void> playVoice(String fileName) async {
    try {
      await _sfxPlayer.play(AssetSource('audio/voice/$fileName'));
    } catch (e) {
      debugPrint("Voice asset missing: $fileName");
    }
  }

  // Speak a number name (uses TTS fallback until MP3s are added)
  Future<void> speakNumber(int number) async {
    final names = [
      'zero',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten'
    ];
    if (number >= 0 && number <= 10) {
      await _tts.speak(names[number]);
    }
  }

  // Speak counting: "one", "two", "three"...
  Future<void> speakCount(int count) async {
    await speakNumber(count);
  }

  // Correct feedback — randomize to avoid repetition
  Future<void> playCorrectFeedback() async {
    final options = ['Great job!', 'Amazing!', 'Wonderful!', 'You did it!'];
    options.shuffle();
    await _tts.speak(options.first);
    await playSfx('sfx/correct.mp3');
  }

  Future<void> playWrongFeedback() async {
    await playSfx('sfx/wrong_soft.mp3');
  }

  Future<void> playSfx(String fileName) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint("SFX asset missing: $fileName");
    }
  }

  Future<void> playMusic(String fileName) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint("Music asset missing: $fileName");
    }
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.pause();
    } else {
      _musicPlayer.resume();
    }
  }

  void setSfxEnabled(bool enabled) => _sfxEnabled = enabled;

  void setSpeechRate(String rate) {
    _tts.setSpeechRate(rate == 'slow' ? 0.3 : 0.45);
  }
}
