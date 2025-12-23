class ShopsResponse {
  final bool status;
  final ShopsData data;

  ShopsResponse({required this.status, required this.data});

  factory ShopsResponse.fromJson(Map<String, dynamic> json) {
    return ShopsResponse(
      status: json['status'] ?? false,
      data: ShopsData.fromJson(json['data'] ?? const {}),
    );
  }
}

class ShopsData {
  final bool isNewOwner;
  final List<Shop> items;
  final Subscription subscription;
  final bool canCreateMoreShops;
  final int remainingShops;

  // ✅ NEW
  final SubscriptionInfo? subscription;
  final bool canCreateMoreShops;
  final int remainingShops;

  ShopsData({
    required this.isNewOwner,
    required this.items,
    required this.subscription,
    required this.canCreateMoreShops,
    required this.remainingShops,
  });

  factory ShopsData.fromJson(Map<String, dynamic> json) {
    return ShopsData(
      isNewOwner: json['isNewOwner'] == true,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => Shop.fromJson(e as Map<String, dynamic>))
          .toList(),

      // ✅ NEW
      subscription: json['subscription'] == null
          ? null
          : SubscriptionInfo.fromJson(json['subscription'] as Map<String, dynamic>),
      canCreateMoreShops: json['canCreateMoreShops'] ?? false,
      remainingShops: json['remainingShops'] ?? 0,
    );
  }
}

class SubscriptionInfo {
  final bool isFreemium;
  final int maxShopsAllowed;
  final String planType; // "PREMIUM"

  SubscriptionInfo({
    required this.isFreemium,
    required this.maxShopsAllowed,
    required this.planType,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      isFreemium: json['isFreemium'] ?? false,
      maxShopsAllowed: json['maxShopsAllowed'] ?? 0,
      planType: (json['planType'] ?? '').toString(),
    );
  }
}

class Shop {
  final String id;
  final String englishName;
  final String tamilName;
  final String city;
  final String shopKind;
  final String category;
  final String subCategory;
  final String addressEn;
  final String addressTa;
  final String? primaryImageUrl;

  Shop({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.city,
    required this.shopKind,
    required this.category,
    required this.subCategory,
    required this.addressEn,
    required this.addressTa,
    this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      city: json['city'] ?? '',
      shopKind: json['shopKind'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      addressEn: json['addressEn'] ?? '',
      addressTa: json['addressTa'] ?? '',
      primaryImageUrl: json['primaryImageUrl'], // can be null
    );
  }
}
