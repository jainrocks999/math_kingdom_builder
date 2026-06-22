import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocaleDescriptor {
  const AppLocaleDescriptor({
    required this.locale,
    required this.languageName,
    required this.nativeLanguageName,
    required this.assetPath,
  });

  final Locale locale;
  final String languageName;
  final String nativeLanguageName;
  final String assetPath;
}

class AppLocaleConfig {
  AppLocaleConfig._();

  static const translationsPath = 'assets/translations';
  static const fallbackLocale = Locale('en');

  static List<AppLocaleDescriptor> _descriptors = const [];

  static List<AppLocaleDescriptor> get descriptors => _descriptors;

  static List<Locale> get supportedLocales => _descriptors
      .map((descriptor) => descriptor.locale)
      .toList(growable: false);

  static Future<void> ensureLoaded() async {
    if (_descriptors.isNotEmpty) return;

    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final translationAssets = assetManifest
        .listAssets()
        .where(
          (asset) =>
              asset.startsWith('$translationsPath/') && asset.endsWith('.json'),
        )
        .toList()
      ..sort();

    final descriptors = <AppLocaleDescriptor>[];
    for (final assetPath in translationAssets) {
      final localeCode = assetPath
          .split('/')
          .last
          .replaceFirst('.json', '')
          .replaceAll('_', '-');
      final locale = _parseLocale(localeCode);
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final meta = decoded is Map<String, dynamic>
          ? decoded['meta'] as Map<String, dynamic>?
          : null;

      descriptors.add(
        AppLocaleDescriptor(
          locale: locale,
          languageName: meta?['language_name'] as String? ?? localeCode,
          nativeLanguageName:
              meta?['native_language_name'] as String? ?? localeCode,
          assetPath: assetPath,
        ),
      );
    }

    descriptors.sort((left, right) {
      if (left.locale.languageCode == fallbackLocale.languageCode) return -1;
      if (right.locale.languageCode == fallbackLocale.languageCode) return 1;
      return left.nativeLanguageName.compareTo(right.nativeLanguageName);
    });

    _descriptors = descriptors.isEmpty
        ? const [
            AppLocaleDescriptor(
              locale: fallbackLocale,
              languageName: 'English',
              nativeLanguageName: 'English',
              assetPath: '$translationsPath/en.json',
            ),
          ]
        : descriptors;
  }

  static AppLocaleDescriptor descriptorFor(Locale locale) {
    return _descriptors.firstWhere(
      (descriptor) =>
          descriptor.locale.languageCode == locale.languageCode &&
          (descriptor.locale.countryCode == null ||
              descriptor.locale.countryCode == locale.countryCode),
      orElse: () => _descriptors.first,
    );
  }

  static Locale _parseLocale(String code) {
    final parts = code.split('-');
    if (parts.length >= 2) {
      return Locale(parts.first, parts[1]);
    }
    return Locale(parts.first);
  }
}
