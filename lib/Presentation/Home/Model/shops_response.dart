class ShopsResponse {
  final bool status;
  final List<Shop> data;

  ShopsResponse({
    required this.status,
    required this.data,
  });

  factory ShopsResponse.fromJson(Map<String, dynamic> json) {
    return ShopsResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
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
  final String addressEn;
  final String category;
  final String subCategory;
  final String primaryImageUrl;

  Shop({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.city,
    required this.shopKind,
    required this.addressEn,
    required this.category,
    required this.subCategory,
    required this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      city: json['city'] ?? '',
      shopKind: json['shopKind'] ?? '',
      category: json['category'] ?? '',
      addressEn: json['addressEn'] ?? '',
      subCategory: json['subCategory'] ?? '',
      primaryImageUrl: json['primaryImageUrl'] ?? '',
    );
  }
}
