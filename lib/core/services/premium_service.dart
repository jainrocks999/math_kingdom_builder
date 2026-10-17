import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PremiumStatus { idle, loading, pending, purchased, cancelled, error }

class PremiumService {
  PremiumService._();

  static final PremiumService instance = PremiumService._();

  static const String removeAdsProductId = 'emath_pro_upgrade';

  static const String _adsRemoveKey = 'emath_pro_removed';

  final InAppPurchase _iap = InAppPurchase.instance;

  final ValueNotifier<bool> adsRemoved = ValueNotifier<bool>(false);

  final ValueNotifier<ProductDetails?> product =
      ValueNotifier<ProductDetails?>(null);

  final ValueNotifier<PremiumStatus> status =
      ValueNotifier<PremiumStatus>(PremiumStatus.idle);

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  AppLifecycleListener? _lifecycleListener;
  Timer? _stuckPurchaseTimer;
  bool _initialized = false;

  /// True from tapping "buy" until Play reports back.
  bool _purchaseInFlight = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    adsRemoved.value = prefs.getBool(_adsRemoveKey) ?? false;

    _purchaseSubscription =
        _iap.purchaseStream.listen(_onPurchaseUpdates, onError: (Object error) {
      debugPrint('Purchase stream error: $error');
      status.value = PremiumStatus.error;
    });
    // Safety net: back in the app with the button still spinning and no
    // answer from Play (e.g. its sheet was dismissed without a result).
    _lifecycleListener = AppLifecycleListener(onResume: _onAppResumed);

    unawaited(_syncWithStore());
  }

  void _onAppResumed() {
    if (!_purchaseInFlight) return;
    _stuckPurchaseTimer?.cancel();
    _stuckPurchaseTimer = Timer(const Duration(seconds: 3), () {
      if (_purchaseInFlight && status.value == PremiumStatus.loading) {
        _purchaseInFlight = false;
        status.value = PremiumStatus.idle;
      }
    });
  }

  /// Loads the price. No automatic restore: after a reinstall ads stay on
  /// until the parent taps "Restore purchase".
  Future<void> _syncWithStore() async {
    try {
      if (!await _iap.isAvailable()) return;
      await loadProduct();
      if (_isAndroid) await _refreshOwnership(restore: false);
    } catch (e) {
      debugPrint('Premium store sync failed: $e');
    }
  }

  Future<void> loadProduct() async {
    final response = await _iap.queryProductDetails({removeAdsProductId});

    if (response.error != null) {
      debugPrint('Product query failed: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product not found in Play Console: ${response.notFoundIDs}');
    }
    product.value =
        response.productDetails.isEmpty ? null : response.productDetails.first;
  }

  /// Asks Play what this account owns right now.
  ///
  /// * [restore] true ("Restore purchase" button): owned → ads removed.
  /// * [restore] false (app start): never restores. It only finishes a
  ///   purchase that was paid but not processed (still unacknowledged), and
  ///   turns ads back on if an unlocked purchase was refunded.
  Future<void> _refreshOwnership({required bool restore}) async {
    final addition =
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases();
    if (response.error != null) {
      debugPrint('Past purchase query failed: ${response.error}');
      return;
    }

    var owned = false;
    var interruptedPurchase = false;
    for (final purchase in response.pastPurchases) {
      if (purchase.productID != removeAdsProductId) continue;
      if (purchase.status != PurchaseStatus.purchased) continue;
      owned = true;
      if (purchase.pendingCompletePurchase) {
        // Paid on this phone but never processed: finish it.
        interruptedPurchase = true;
        await _iap.completePurchase(purchase);
      }
    }

    if (restore || interruptedPurchase) {
      await _setAdsRemoved(owned);
    } else if (adsRemoved.value && !owned) {
      // Refunded: ads come back.
      await _setAdsRemoved(false);
    }
  }

  Future<bool> buyRemoveAds() async {
    if (adsRemoved.value) return true;
    status.value = PremiumStatus.loading;
    try {
      if (product.value == null) await loadProduct();
      final details = product.value;
      if (details == null) {
        status.value = PremiumStatus.error;
        return false;
      }
      _purchaseInFlight = true;
      final opened = await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: details));
      if (!opened) {
        // Play's sheet could not be shown; stop the spinner.
        _purchaseInFlight = false;
        status.value = PremiumStatus.error;
      }
      return opened;
    } on PlatformException catch (e) {
      _purchaseInFlight = false;
      debugPrint('Buy failed: ${e.code} ${e.message}');

      if ('${e.code} ${e.message}'.toLowerCase().contains('owned')) {
        await restorePurchases();
        return true;
      }
      status.value = PremiumStatus.error;
      return false;
    } catch (e) {
      _purchaseInFlight = false;
      debugPrint('Buy failed: $e');
      status.value = PremiumStatus.error;
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    status.value = PremiumStatus.loading;
    try {
      await _iap.restorePurchases();
      if (_isAndroid) await _refreshOwnership(restore: true);
    } catch (e) {
      debugPrint('Restore failed:$e');
      status.value = PremiumStatus.error;
      return adsRemoved.value;
    }
    status.value =
        adsRemoved.value ? PremiumStatus.purchased : PremiumStatus.idle;
    return adsRemoved.value;
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // When the user closes Play's sheet (or it fails before a purchase
      // exists) Android reports it with an empty product ID. This app sells
      // only one product, so treat those as answers for it too.
      final isOurs = purchase.productID == removeAdsProductId ||
          (purchase.productID.isEmpty &&
              (purchase.status == PurchaseStatus.canceled ||
                  purchase.status == PurchaseStatus.error));
      if (!isOurs) continue;

      _purchaseInFlight = false;
      _stuckPurchaseTimer?.cancel();

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // E.g. UPI still processing: ads are removed once it completes.
          status.value = PremiumStatus.pending;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setAdsRemoved(true);
          status.value = PremiumStatus.purchased;
        case PurchaseStatus.canceled:
          status.value = PremiumStatus.cancelled;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error}');
          status.value = PremiumStatus.error;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setAdsRemoved(bool value) async {
    adsRemoved.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsRemoveKey, value);
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _lifecycleListener?.dispose();
    _stuckPurchaseTimer?.cancel();
  }
}
