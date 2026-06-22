import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/audio_settings_service.dart';
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
  bool _isMusicPlaying = false;
  bool _resumeMusicOnForeground = false;

  Future<void> init() async {
    // Configure TTS
    await TtsVoiceHelper.configureSharedAudio(_tts);
    await TtsVoiceHelper.applyPreferredVoice(
      _tts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'hi-IN'],
    );
    await TtsVoiceHelper.applyPreferredSpeechRate(
      _tts,
      normalRate: 0.45,
      slowRate: 0.3,
    );
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
    if (!_sfxEnabled || !await AudioSettingsService.instance.isSfxEnabled()) {
      return;
    }
    try {
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _sfxPlayer.setVolume(1.0);
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint("SFX asset missing: $fileName");
    }
  }

  Future<void> playMusic(String fileName) async {
    if (!_musicEnabled ||
        !await AudioSettingsService.instance.isMusicEnabled()) {
      return;
    }
    try {
      await _musicPlayer.play(AssetSource('audio/$fileName'));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint("Music asset missing: $fileName");
    }
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.pause();
      _isMusicPlaying = false;
      _resumeMusicOnForeground = false;
    } else {
      _musicPlayer.resume();
      _isMusicPlaying = true;
    }
  }

  void setSfxEnabled(bool enabled) => _sfxEnabled = enabled;

  void setSpeechRate(String rate) {
    AudioSettingsService.instance.setSpeechRateMode(rate);
    TtsVoiceHelper.applyPreferredSpeechRate(
      _tts,
      normalRate: 0.45,
      slowRate: 0.3,
    );
  }

  Future<void> handleAppBackgrounded() async {
    _resumeMusicOnForeground = _isMusicPlaying;
    if (_resumeMusicOnForeground) {
      await _musicPlayer.pause();
      _isMusicPlaying = false;
    }
    await _sfxPlayer.stop();
    await _tts.stop();
  }

  Future<void> handleAppResumed() async {
    if (!_resumeMusicOnForeground) return;
    _resumeMusicOnForeground = false;
    if (!_musicEnabled ||
        !await AudioSettingsService.instance.isMusicEnabled()) {
      return;
    }
    await _musicPlayer.resume();
    _isMusicPlaying = true;
  }
}
