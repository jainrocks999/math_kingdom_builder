import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../router/app_router.dart';
import '../utils/tts_voice_helper.dart';

/// Shared localization helpers for UI strings and TTS locale selection.
abstract final class AppLocalization {
  static bool isHindi(BuildContext context) =>
      context.locale.languageCode == 'hi';

  static String ttsLocale(BuildContext context) =>
      isHindi(context) ? 'hi-IN' : 'en-IN';

  static List<String> ttsFallbackLocales(BuildContext context) =>
      isHindi(context)
          ? const ['hi-IN', 'en-IN', 'en-US']
          : const ['en-IN', 'en-US', 'en-GB'];

  static String tr(BuildContext context, String key, [Map<String, String>? args]) {
    if (args == null || args.isEmpty) {
      return context.tr(key);
    }
    return context.tr(key, namedArgs: args);
  }

  static String plural(
    BuildContext context,
    String key,
    num count, {
    Map<String, String>? namedArgs,
  }) {
    return context.plural(key, count, namedArgs: namedArgs);
  }

  /// Maps app routes to translation keys under `modules.*`.
  static String? moduleKeyForRoute(String route) {
    switch (route) {
      case AppRoutes.learnNumbers:
        return 'learn_numbers';
      case AppRoutes.tracing:
        return 'trace_numbers';
      case AppRoutes.counting:
        return 'count_objects';
      case AppRoutes.findNumber:
        return 'find_correct_number';
      case AppRoutes.matching:
        return 'match_numbers';
      case AppRoutes.miniQuiz:
        return 'mini_quiz';
      case AppRoutes.stickers:
        return 'rewards';
      case AppRoutes.mathOperations:
        return 'math_operations';
      case AppRoutes.addition:
        return 'addition';
      case AppRoutes.subtraction:
        return 'subtraction';
      case AppRoutes.multiplication:
        return 'multiplication';
      case AppRoutes.division:
        return 'division';
      case AppRoutes.sequencing:
        return 'sequencing';
      case AppRoutes.patterns:
        return 'patterns';
      case AppRoutes.kingdom:
        return 'kingdom_map';
      case AppRoutes.startlearning:
        return 'start_learning';
      default:
        return null;
    }
  }

  static String moduleTitle(BuildContext context, String route) {
    final key = moduleKeyForRoute(route);
    if (key == null) return route;
    return context.tr('modules.$key.title');
  }

  static String moduleSubtitle(BuildContext context, String route) {
    final key = moduleKeyForRoute(route);
    if (key == null) return '';
    return context.tr('modules.$key.subtitle');
  }

  static String objectLabel(
    BuildContext context,
    String objectId,
    int count,
  ) {
    final nounKey = count == 1
        ? 'objects.$objectId.singular'
        : 'objects.$objectId.plural';
    return context.tr(nounKey);
  }

  static String kingdomZone(BuildContext context, String zoneId, String field) {
    return context.tr('kingdom.zones.$zoneId.$field');
  }

  static String rewardItem(BuildContext context, String itemId, String field) {
    return context.tr('rewards.items.$itemId.$field');
  }

  static String numberWord(BuildContext context, int value) {
    return context.tr('numbers.$value');
  }

  static Future<void> configureTts(
    FlutterTts tts,
    BuildContext context, {
    double normalRate = 0.42,
    double slowRate = 0.3,
  }) async {
    await TtsVoiceHelper.configureSharedAudio(tts);
    await TtsVoiceHelper.applyPreferredVoice(
      tts,
      locale: ttsLocale(context),
      fallbackLocales: ttsFallbackLocales(context),
    );
    await TtsVoiceHelper.applyPreferredSpeechRate(
      tts,
      normalRate: normalRate,
      slowRate: slowRate,
    );
  }
}
