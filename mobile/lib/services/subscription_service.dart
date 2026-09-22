import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/app_config.dart';
import 'api_service.dart';

enum BillingState { loading, ready, unavailable, purchasing, active, error }

class SubscriptionService extends ChangeNotifier {
  SubscriptionService({
    required ApiService api,
    required Future<void> Function(bool active) onEntitlementChanged,
    InAppPurchase? billing,
  })  : _api = api,
        _onEntitlementChanged = onEntitlementChanged,
        _billing = billing ?? InAppPurchase.instance;

  final ApiService _api;
  final InAppPurchase _billing;
  final Future<void> Function(bool active) _onEntitlementChanged;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  BillingState state = BillingState.loading;
  List<ProductDetails> products = const [];
  String? errorMessage;
  bool verificationReady = false;
  bool _initializing = false;

  ProductDetails? get monthly => _byId(AppConfig.monthlyProductId);
  ProductDetails? get annual => _byId(AppConfig.annualProductId);

  ProductDetails? _byId(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> initialize() async {
    if (_initializing) return;
    _initializing = true;
    _purchaseSubscription ??= _billing.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        state = BillingState.error;
        errorMessage = error.toString();
        notifyListeners();
      },
    );

    try {
      verificationReady = await _api.canVerifyPurchases();
      if (!await _billing.isAvailable()) {
        state = BillingState.unavailable;
        notifyListeners();
        return;
      }

      final response = await _billing.queryProductDetails({
        AppConfig.monthlyProductId,
        AppConfig.annualProductId,
      });
      products = response.productDetails;
      errorMessage = response.error?.message;
      state = products.isEmpty ? BillingState.unavailable : BillingState.ready;
      if (verificationReady) {
        await _billing.restorePurchases();
      }
    } on Exception catch (error) {
      state = BillingState.error;
      errorMessage = error.toString();
    } finally {
      _initializing = false;
    }
    notifyListeners();
  }

  Future<void> purchase(ProductDetails product) async {
    if (!verificationReady) {
      state = BillingState.error;
      errorMessage = 'Secure purchase verification is not configured.';
      notifyListeners();
      return;
    }
    state = BillingState.purchasing;
    errorMessage = null;
    notifyListeners();
    try {
      final started = await _billing.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (started) return;
      state = BillingState.error;
      errorMessage = 'The Play purchase flow could not be started.';
    } on Exception catch (error) {
      state = BillingState.error;
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> restore() async {
    if (!verificationReady) return;
    try {
      await _billing.restorePurchases();
    } on Exception catch (error) {
      state = BillingState.error;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      var verifiedPurchase = false;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = BillingState.purchasing;
          break;
        case PurchaseStatus.error:
          state = BillingState.error;
          errorMessage = purchase.error?.message;
          break;
        case PurchaseStatus.canceled:
          state = BillingState.ready;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final verified = await _api.verifyGooglePurchase(
            productId: purchase.productID,
            purchaseToken: purchase.verificationData.serverVerificationData,
          );
          if (verified) {
            await _onEntitlementChanged(true);
            state = BillingState.active;
            verifiedPurchase = true;
          } else {
            state = BillingState.error;
            errorMessage = 'Purchase verification failed.';
          }
          break;
      }

      if (verifiedPurchase && purchase.pendingCompletePurchase) {
        await _billing.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
