import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'audio_settings_service.dart';

class AppAudioService {
  AppAudioService._();

  static final AppAudioService instance = AppAudioService._();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _celebrationPlayer = AudioPlayer();

  final Map<String, Source> _sourceCache = {};
  bool _isConfigured = false;
  bool _isBackgroundMusicPlaying = false;
  bool _resumeBackgroundOnForeground = false;
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

  Future<Source> _sourceForAsset(String filePath) async {
    final assetPath = _assetPath(filePath);
    final cached = _sourceCache[assetPath];
    if (cached != null) return cached;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final directory = await getTemporaryDirectory();
      final fileName = assetPath.replaceAll('/', '_');
      final localFile = File('${directory.path}/$fileName');
      if (!await localFile.exists()) {
        final data = await rootBundle.load('assets/$assetPath');
        await localFile.writeAsBytes(
          data.buffer.asUint8List(),
          flush: true,
        );
      }
      final source = DeviceFileSource(localFile.path);
      _sourceCache[assetPath] = source;
      return source;
    }

    final source = AssetSource(assetPath);
    _sourceCache[assetPath] = source;
    return source;
  }

  Future<void> _playLoopingBackgroundMusic(
    String filePath, {
    required double volume,
  }) async {
    await _ensureConfigured();
    if (!await AudioSettingsService.instance.isMusicEnabled()) {
      await stopBackgroundMusic();
      return;
    }
    final assetPath = _assetPath(filePath);
    if (_isBackgroundMusicPlaying && _currentBackgroundTrack == assetPath) {
      return;
    }

    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(volume);
      await _bgPlayer.play(await _sourceForAsset(filePath));
      _currentBackgroundTrack = assetPath;
      _isBackgroundMusicPlaying = true;
    } catch (error) {
      debugPrint('Background music asset missing: $filePath ($error)');
    }
  }

  Future<void> playHomeMusic() async {
    await _playLoopingBackgroundMusic(
      'assets/audio/bg/home_music.mp3',
      volume: 0.35,
    );
  }

  Future<void> playKingdomMusic() async {
    await _playLoopingBackgroundMusic(
      'assets/audio/bg/home_music.mp3',
      volume: 0.18,
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
    _resumeBackgroundOnForeground = false;
    _currentBackgroundTrack = null;
  }

  Future<void> pauseHomeMusic() async {
    await pauseBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
    _isBackgroundMusicPlaying = false;
  }

  Future<void> handleAppBackgrounded() async {
    _resumeBackgroundOnForeground =
        _isBackgroundMusicPlaying && _currentBackgroundTrack != null;
    if (_resumeBackgroundOnForeground) {
      await _bgPlayer.pause();
      _isBackgroundMusicPlaying = false;
    }
    await _celebrationPlayer.stop();
  }

  Future<void> handleAppResumed() async {
    if (!_resumeBackgroundOnForeground) return;
    _resumeBackgroundOnForeground = false;
    if (!await AudioSettingsService.instance.isMusicEnabled()) {
      return;
    }
    await _bgPlayer.resume();
    _isBackgroundMusicPlaying = true;
  }

  Future<void> playCelebrationMusic() async {
    await _ensureConfigured();
    try {
      await _celebrationPlayer.stop();
      await _celebrationPlayer.setReleaseMode(ReleaseMode.release);
      await _celebrationPlayer.setVolume(0.85);
      await _celebrationPlayer.play(
        await _sourceForAsset('assets/audio/bg/celebration.mp3'),
      );
    } catch (error) {
      debugPrint('Celebration music asset missing: $error');
    }
  }

  Future<void> stopCelebrationMusic() async {
    await _celebrationPlayer.stop();
  }
}
