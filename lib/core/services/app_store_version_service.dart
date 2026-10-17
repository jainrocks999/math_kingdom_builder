import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// What the App Store says about this app.
class AppStoreRelease {
  const AppStoreRelease({
    required this.version,
    required this.storeUrl,
    required this.releasedAt,
  });

  final String version;
  final Uri storeUrl;
  final DateTime? releasedAt;
}

/// iOS has no in-app update API, so the App Store's public lookup service is
/// asked for the latest version and compared with the installed one.
class AppStoreVersionService {
  AppStoreVersionService._();

  static final AppStoreVersionService instance = AppStoreVersionService._();

  /// The lookup service often reports a new version hours before it can be
  /// downloaded in every country. Forcing it earlier would leave the child on
  /// an App Store page without an Update button.
  static const Duration rolloutDelay = Duration(hours: 24);

  static const Duration _timeout = Duration(seconds: 8);

  /// The newer App Store release that must be installed, or null when the
  /// installed version is current (or the store can't be reached).
  Future<AppStoreRelease?> requiredUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final release = await _lookup(info.packageName);
    if (release == null) return null;

    if (!isNewer(release.version, info.version)) return null;

    final releasedAt = release.releasedAt;
    if (releasedAt != null &&
        DateTime.now().toUtc().difference(releasedAt) < rolloutDelay) {
      return null;
    }
    return release;
  }

  Future<AppStoreRelease?> _lookup(String bundleId) async {
    // The app is only found in a store where it is sold: try the device's
    // region first, then India and the US.
    final deviceCountry =
        PlatformDispatcher.instance.locale.countryCode?.toLowerCase();
    final countries = <String>{
      if (deviceCountry != null && deviceCountry.isNotEmpty) deviceCountry,
      'in',
      'us',
    };

    for (final country in countries) {
      final release = await _lookupIn(bundleId, country);
      if (release != null) return release;
    }
    return null;
  }

  Future<AppStoreRelease?> _lookupIn(String bundleId, String country) async {
    final uri = Uri.https('itunes.apple.com', '/lookup', {
      'bundleId': bundleId,
      'country': country,
      // Avoid a cached, out-of-date answer.
      't': '${DateTime.now().millisecondsSinceEpoch}',
    });

    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(uri).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != HttpStatus.ok) return null;

      final body =
          await response.transform(utf8.decoder).join().timeout(_timeout);
      final json = jsonDecode(body);
      if (json is! Map || json['resultCount'] is! int) return null;
      final results = json['results'];
      if (results is! List || results.isEmpty || results.first is! Map) {
        return null;
      }

      final app = results.first as Map;
      final version = app['version'];
      final trackId = app['trackId'];
      if (version is! String || trackId == null) return null;

      return AppStoreRelease(
        version: version,
        storeUrl: Uri.parse('https://apps.apple.com/app/id$trackId'),
        releasedAt: DateTime.tryParse(
          '${app['currentVersionReleaseDate'] ?? ''}',
        )?.toUtc(),
      );
    } catch (e) {
      debugPrint('App Store lookup ($country) failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  @visibleForTesting
  static bool isNewer(String store, String installed) {
    List<int> parts(String value) => value
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();

    final a = parts(store);
    final b = parts(installed);
    final length = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}
