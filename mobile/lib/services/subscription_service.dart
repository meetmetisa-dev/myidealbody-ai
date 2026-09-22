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
        _billing = billing;

  final ApiService _api;
  InAppPurchase? _billing;
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
    if (_api.isDemoMode) {
      verificationReady = false;
      products = const [];
      errorMessage = null;
      state = BillingState.unavailable;
      notifyListeners();
      return;
    }
    _initializing = true;
    final billing = _billing ??= InAppPurchase.instance;
    _purchaseSubscription ??= billing.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        state = BillingState.error;
        errorMessage = error.toString();
        notifyListeners();
      },
    );

    try {
      verificationReady = await _api.canVerifyPurchases();
      if (!await billing.isAvailable()) {
        state = BillingState.unavailable;
        notifyListeners();
        return;
      }

      final response = await billing.queryProductDetails({
        AppConfig.monthlyProductId,
        AppConfig.annualProductId,
      });
      products = response.productDetails;
      errorMessage = response.error?.message;
      state = products.isEmpty ? BillingState.unavailable : BillingState.ready;
      if (verificationReady) {
        await billing.restorePurchases();
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
    final billing = _billing;
    if (_api.isDemoMode || billing == null) {
      state = BillingState.unavailable;
      errorMessage = null;
      notifyListeners();
      return;
    }
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
      final started = await billing.buyNonConsumable(
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
    final billing = _billing;
    if (_api.isDemoMode || billing == null || !verificationReady) return;
    try {
      await billing.restorePurchases();
    } on Exception catch (error) {
      state = BillingState.error;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    final billing = _billing;
    if (billing == null) return;
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
        await billing.completePurchase(purchase);
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
