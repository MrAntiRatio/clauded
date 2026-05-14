// PRODUCTION CONFIGURATION:
// 1. Create the following products in your Google Play Console under
//    Monetize > Products > In-app products:
//
//    Product ID         | Type            | Price
//    -------------------|-----------------|-------
//    gems_small         | Consumable      | $0.99
//    gems_medium        | Consumable      | $4.99
//    gems_large         | Consumable      | $9.99
//    remove_ads         | Non-consumable  | $2.99
//    starter_pack       | Non-consumable  | $1.99
//
// 2. Product IDs below must match exactly what is registered in Play Console.
// 3. Test with a licensed tester account before releasing.

import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

enum IAPProductId {
  gemsSmall('gems_small'),
  gemsMedium('gems_medium'),
  gemsLarge('gems_large'),
  removeAds('remove_ads'),
  starterPack('starter_pack');

  const IAPProductId(this.id);
  final String id;
}

class IAPProduct {
  final ProductDetails details;
  final IAPProductId productId;
  final int? gemAmount;
  final bool removesAds;

  const IAPProduct({
    required this.details,
    required this.productId,
    this.gemAmount,
    this.removesAds = false,
  });
}

class IAPService {
  IAPService._();
  static final instance = IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<IAPProduct> _products = [];
  bool _available = false;

  List<IAPProduct> get products => _products;
  bool get isAvailable => _available;

  void Function(int gems, bool removesAds)? onPurchaseSuccess;
  void Function(String error)? onPurchaseError;

  static const Map<String, int> _gemAmounts = {
    'gems_small': 100,
    'gems_medium': 550,
    'gems_large': 1200,
    'starter_pack': 200,
  };

  static const Set<String> _adRemovalProducts = {'remove_ads', 'starter_pack'};

  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    final ids = IAPProductId.values.map((e) => e.id).toSet();
    final response = await _iap.queryProductDetails(ids);

    _products = response.productDetails.map((details) {
      return IAPProduct(
        details: details,
        productId: IAPProductId.values.firstWhere((e) => e.id == details.id),
        gemAmount: _gemAmounts[details.id],
        removesAds: _adRemovalProducts.contains(details.id),
      );
    }).toList();

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => onPurchaseError?.call(error.toString()),
    );

    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverPurchase(purchase);
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        case PurchaseStatus.error:
          onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    final gems = _gemAmounts[purchase.productID] ?? 0;
    final removesAds = _adRemovalProducts.contains(purchase.productID);
    onPurchaseSuccess?.call(gems, removesAds);
  }

  Future<bool> buyProduct(IAPProduct product) async {
    if (!_available) return false;
    final param = PurchaseParam(productDetails: product.details);

    final isConsumable = product.gemAmount != null && !product.removesAds;

    if (isConsumable) {
      return await _iap.buyConsumable(purchaseParam: param);
    } else {
      return await _iap.buyNonConsumable(purchaseParam: param);
    }
  }

  IAPProduct? findProduct(IAPProductId id) {
    try {
      return _products.firstWhere((p) => p.productId == id);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
