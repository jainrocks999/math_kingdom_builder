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
  bool _isAppInBackground = false;
  bool _resumeBackgroundOnForeground = false;
  String? _currentBackgroundTrack;

  int _commandSeq = 0;
  Future<void> _commandQueue = Future<void>.value();
  String? _desiredTrackPath;
  double _desiredVolume = 0.35;
  String? _resumeTrackPath;
  double _resumeVolume = 0.35;

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

  void _enqueue(Future<void> Function() action) {
    _commandQueue = _commandQueue.then((_) => action()).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('AppAudioService error: $error');
    });
  }

  Future<void> _applyDesired(int seq) async {
    if (seq != _commandSeq) return;

    await _ensureConfigured();
    if (seq != _commandSeq) return;

    if (_isAppInBackground) {
      if (_desiredTrackPath != null) {
        _resumeTrackPath = _desiredTrackPath;
        _resumeVolume = _desiredVolume;
        _resumeBackgroundOnForeground = true;
      }
      await _bgPlayer.stop();
      if (seq != _commandSeq) return;
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
      return;
    }

    if (_desiredTrackPath == null) {
      await _bgPlayer.stop();
      if (seq != _commandSeq) return;
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
      return;
    }

    if (!await AudioSettingsService.instance.isMusicEnabled()) {
      await _bgPlayer.stop();
      if (seq != _commandSeq) return;
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
      return;
    }

    final assetPath = _assetPath(_desiredTrackPath!);
    if (_isBackgroundMusicPlaying && _currentBackgroundTrack == assetPath) {
      await _bgPlayer.setVolume(_desiredVolume);
      return;
    }

    try {
      await _bgPlayer.stop();
      if (seq != _commandSeq) return;
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(_desiredVolume);
      await _bgPlayer.play(await _sourceForAsset(_desiredTrackPath!));
      if (seq != _commandSeq) return;
      _currentBackgroundTrack = assetPath;
      _isBackgroundMusicPlaying = true;
    } catch (error) {
      debugPrint('Background music asset missing: $_desiredTrackPath ($error)');
    }
  }

  Future<void> _playLoopingBackgroundMusic(
    String filePath, {
    required double volume,
  }) async {
    if (_isAppInBackground) {
      _resumeTrackPath = filePath;
      _resumeVolume = volume;
      _resumeBackgroundOnForeground = true;
      return;
    }

    _desiredTrackPath = filePath;
    _desiredVolume = volume;
    _resumeBackgroundOnForeground = false;
    final seq = ++_commandSeq;
    _enqueue(() => _applyDesired(seq));
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
    _desiredTrackPath = null;
    _resumeBackgroundOnForeground = false;
    _resumeTrackPath = null;
    final seq = ++_commandSeq;
    _enqueue(() => _applyDesired(seq));
  }

  Future<void> pauseHomeMusic() async {
    await pauseBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
    _isBackgroundMusicPlaying = false;
  }

  Future<void> handleAppBackgrounded() async {
    _isAppInBackground = true;
    final shouldResumeLater =
        _desiredTrackPath != null || _resumeTrackPath != null;
    if (shouldResumeLater) {
      _resumeTrackPath = _desiredTrackPath ?? _resumeTrackPath;
      _resumeVolume =
          _desiredTrackPath != null ? _desiredVolume : _resumeVolume;
    }

    _desiredTrackPath = null;
    _resumeBackgroundOnForeground = shouldResumeLater;
    final seq = ++_commandSeq;
    _enqueue(() async {
      if (seq != _commandSeq) return;
      await _bgPlayer.stop();
      await _celebrationPlayer.stop();
      if (seq != _commandSeq) return;
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    });
  }

  Future<void> handleAppResumed() async {
    _isAppInBackground = false;
    if (!_resumeBackgroundOnForeground) return;
    _resumeBackgroundOnForeground = false;
    final track = _resumeTrackPath;
    final volume = _resumeVolume;
    _resumeTrackPath = null;
    if (track == null) return;
    await _playLoopingBackgroundMusic(track, volume: volume);
  }

  Future<void> playCelebrationMusic() async {
    if (_isAppInBackground) return;
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
