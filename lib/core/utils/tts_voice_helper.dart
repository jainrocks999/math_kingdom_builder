import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/audio_settings_service.dart';

class TtsVoiceHelper {
  static final Map<String, Map<String, String>?> _voiceCache = {};

  static Future<void> configureSharedAudio(FlutterTts tts) async {
    if (kIsWeb || !Platform.isIOS) return;

    await tts.setSharedInstance(true);
    await tts.autoStopSharedSession(true);
    await tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      const [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
      IosTextToSpeechAudioMode.voicePrompt,
    );
  }

  static Future<void> applyPreferredVoice(
    FlutterTts tts, {
    required String locale,
    List<String> fallbackLocales = const [],
  }) async {
    final cacheKey = _cacheKey(locale, fallbackLocales);
    final voice = _voiceCache.containsKey(cacheKey)
        ? _voiceCache[cacheKey]
        : await _findBestVoice(
            tts,
            locale: locale,
            fallbackLocales: fallbackLocales,
          );

    _voiceCache[cacheKey] = voice;

    if (voice != null) {
      await tts.setVoice({
        'name': voice['name']!,
        'locale': voice['locale']!,
      });
      await tts.setLanguage(voice['locale']!);
      return;
    }

    await tts.setLanguage(locale);
  }

  static Future<void> applyPreferredSpeechRate(
    FlutterTts tts, {
    required double normalRate,
    double slowRate = 0.3,
  }) async {
    final mode = await AudioSettingsService.instance.speechRateMode();
    await tts.setSpeechRate(mode == 'slow' ? slowRate : normalRate);
  }

  static String _cacheKey(String locale, List<String> fallbackLocales) =>
      ([locale, ...fallbackLocales].map(_normalizeLocale).toList()).join('|');

  static Future<Map<String, String>?> _findBestVoice(
    FlutterTts tts, {
    required String locale,
    required List<String> fallbackLocales,
  }) async {
    final rawVoices = await tts.getVoices;
    if (rawVoices is! List) {
      return null;
    }

    final voices = <Map<String, String>>[];
    for (final rawVoice in rawVoices) {
      if (rawVoice is! Map) continue;
      final voice = <String, String>{};
      rawVoice.forEach((key, value) {
        if (key != null && value != null) {
          voice[key.toString()] = value.toString();
        }
      });
      if ((voice['name'] ?? '').isEmpty || (voice['locale'] ?? '').isEmpty) {
        continue;
      }
      voices.add(voice);
    }

    if (voices.isEmpty) {
      return null;
    }

    final ranked = [...voices]..sort(
        (left, right) => _scoreVoice(
          right,
          locale: locale,
          fallbackLocales: fallbackLocales,
        ).compareTo(
          _scoreVoice(left, locale: locale, fallbackLocales: fallbackLocales),
        ),
      );

    final best = ranked.first;
    final bestScore = _scoreVoice(
      best,
      locale: locale,
      fallbackLocales: fallbackLocales,
    );
    return bestScore > 0 ? best : null;
  }

  static int _scoreVoice(
    Map<String, String> voice, {
    required String locale,
    required List<String> fallbackLocales,
  }) {
    final voiceLocale = _normalizeLocale(voice['locale'] ?? '');
    final targetLocale = _normalizeLocale(locale);
    final fallbackLocaleSet = fallbackLocales.map(_normalizeLocale).toSet();
    final targetLanguage = _languageCode(targetLocale);
    final voiceLanguage = _languageCode(voiceLocale);

    var score = 0;

    if (voiceLocale == targetLocale) {
      score += 300;
    } else if (fallbackLocaleSet.contains(voiceLocale)) {
      score += 220;
    } else if (voiceLanguage == targetLanguage) {
      score += 120;
    }

    if (_isIndianLocale(voiceLocale)) {
      score += 100;
    }

    if (_isFemaleVoice(voice)) {
      score += 80;
    }

    final quality = (voice['quality'] ?? '').toLowerCase();
    if (quality.contains('enhanced') || quality.contains('premium')) {
      score += 15;
    }

    return score;
  }

  static bool _isFemaleVoice(Map<String, String> voice) {
    final gender = (voice['gender'] ?? '').toLowerCase();
    final name = (voice['name'] ?? '').toLowerCase();
    return gender.contains('female') ||
        name.contains('female') ||
        name.contains('woman');
  }

  static bool _isIndianLocale(String locale) => locale.endsWith('-IN');

  static String _languageCode(String locale) =>
      locale.split('-').first.toLowerCase();

  static String _normalizeLocale(String locale) =>
      locale.trim().replaceAll('_', '-');
}
