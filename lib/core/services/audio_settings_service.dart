import 'package:shared_preferences/shared_preferences.dart';

class AudioSettingsSnapshot {
  const AudioSettingsSnapshot({
    required this.musicEnabled,
    required this.sfxEnabled,
    required this.speechRateMode,
  });

  final bool musicEnabled;
  final bool sfxEnabled;
  final String speechRateMode;
}

class AudioSettingsService {
  AudioSettingsService._();

  static final AudioSettingsService instance = AudioSettingsService._();

  static const _musicEnabledKey = 'audio_settings_music_enabled';
  static const _sfxEnabledKey = 'audio_settings_sfx_enabled';
  static const _speechRateModeKey = 'audio_settings_speech_rate_mode';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<AudioSettingsSnapshot> loadSnapshot() async {
    final prefs = await _prefs;
    return AudioSettingsSnapshot(
      musicEnabled: prefs.getBool(_musicEnabledKey) ?? true,
      sfxEnabled: prefs.getBool(_sfxEnabledKey) ?? true,
      speechRateMode: _normalizeSpeechRateMode(
        prefs.getString(_speechRateModeKey),
      ),
    );
  }

  Future<bool> isMusicEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  Future<bool> isSfxEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_sfxEnabledKey) ?? true;
  }

  Future<String> speechRateMode() async {
    final prefs = await _prefs;
    return _normalizeSpeechRateMode(prefs.getString(_speechRateModeKey));
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_musicEnabledKey, enabled);
  }

  Future<void> setSfxEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_sfxEnabledKey, enabled);
  }

  Future<void> setSpeechRateMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_speechRateModeKey, _normalizeSpeechRateMode(mode));
  }

  String _normalizeSpeechRateMode(String? value) {
    return value == 'slow' ? 'slow' : 'normal';
  }
}
