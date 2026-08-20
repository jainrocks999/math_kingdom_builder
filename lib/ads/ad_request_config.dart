import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Shared AdMob request settings for a child-focused learning app.
class AdRequestConfig {
  AdRequestConfig._();

  static const AdRequest request = AdRequest();

  static Future<void> applyGlobalSettings() async {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
  }
}
