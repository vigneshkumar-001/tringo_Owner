class ShopsResponse {
  final bool status;
  final ShopsData data;

  ShopsResponse({
    required this.status,
    required this.data,
  });

  factory ShopsResponse.fromJson(Map<String, dynamic> json) {
    return ShopsResponse(
      status: json['status'] ?? false,
      data: ShopsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ShopsData {
  final bool isNewOwner;
  final List<Shop> items;

  ShopsData({
    required this.isNewOwner,
    required this.items,
  });

  factory ShopsData.fromJson(Map<String, dynamic> json) {
    return ShopsData(
      isNewOwner: json['isNewOwner'] ?? true,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => Shop.fromJson(e))
          .toList(),
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
      primaryImageUrl: json['primaryImageUrl'],
    );
  }
}
