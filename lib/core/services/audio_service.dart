import 'package:audioplayers/audioplayers.dart';

class AppAudioService {
  AppAudioService._();

  static final AppAudioService instance = AppAudioService._();

  final AudioPlayer _bgPlayer = AudioPlayer();
  bool _isHomeMusicPlaying = false;

  Future<void> playHomeMusic() async {
    if (_isHomeMusicPlaying) return;

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.35);
    await _bgPlayer.play(AssetSource('audio/bg/home_music.mp3'));

    _isHomeMusicPlaying = true;
  }

  Future<void> stopHomeMusic() async {
    await _bgPlayer.stop();
    _isHomeMusicPlaying = false;
  }

  Future<void> pauseHomeMusic() async {
    await _bgPlayer.pause();
    _isHomeMusicPlaying = false;
  }
}