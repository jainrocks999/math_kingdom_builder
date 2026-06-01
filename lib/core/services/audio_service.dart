import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AppAudioService {
  AppAudioService._();

  static final AppAudioService instance = AppAudioService._();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _celebrationPlayer = AudioPlayer();

  bool _isConfigured = false;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  String _assetPath(String filePath) {
    return filePath.startsWith('assets/')
        ? filePath.substring('assets/'.length)
        : filePath;
  }

  Future<void> _ensureConfigured() async {
    if (_isConfigured) return;

    final mixedAudioContext = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();

    await _bgPlayer.setAudioContext(mixedAudioContext);
    await _celebrationPlayer.setAudioContext(mixedAudioContext);
    _isConfigured = true;
  }

  Future<void> _playLoopingBackgroundMusic(
    String filePath, {
    required double volume,
  }) async {
    await _ensureConfigured();
    final assetPath = _assetPath(filePath);
    if (_isBackgroundMusicPlaying && _currentBackgroundTrack == assetPath) {
      return;
    }

    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(volume);
      await _bgPlayer.play(AssetSource(assetPath));
      _currentBackgroundTrack = assetPath;
      _isBackgroundMusicPlaying = true;
    } catch (error) {
      debugPrint('Background music asset missing: $filePath ($error)');
    }
  }

  Future<void> playHomeMusic() async {
    await _playLoopingBackgroundMusic(
      'assets/audio/bg/start_counting.mp3',
      volume: 0.35,
    );
  }

  Future<void> playStartCountingMusic() async {
    await _playLoopingBackgroundMusic(
      'assets/audio/bg/start_counting.mp3',
      volume: 0.42,
    );
  }

  Future<void> stopHomeMusic() async {
    await stopBackgroundMusic();
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
  }

  Future<void> pauseHomeMusic() async {
    await pauseBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
    _isBackgroundMusicPlaying = false;
  }

  Future<void> playCelebrationMusic() async {
    await _ensureConfigured();
    try {
      await _celebrationPlayer.stop();
      await _celebrationPlayer.setReleaseMode(ReleaseMode.release);
      await _celebrationPlayer.setVolume(0.85);
      await _celebrationPlayer.play(
        AssetSource(_assetPath('assets/audio/bg/celebration.mp3')),
      );
    } catch (error) {
      debugPrint('Celebration music asset missing: $error');
    }
  }

  Future<void> stopCelebrationMusic() async {
    await _celebrationPlayer.stop();
  }
}
