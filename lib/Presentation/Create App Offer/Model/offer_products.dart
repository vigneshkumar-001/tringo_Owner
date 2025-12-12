class OfferProductsResponse {
  final bool status;
  final OfferProductsData? data;

  OfferProductsResponse({
    required this.status,
    this.data,
  });

  factory OfferProductsResponse.fromJson(Map<String, dynamic> json) {
    return OfferProductsResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? OfferProductsData.fromJson(json['data'])
          : null,
    );
  }
}


class OfferProductsData {
  final String type;
  final String? offerId;
  final double? discountPercentage;
  final List<CategoryModel> categories;
  final List<ProductItem> items;
  final int page;
  final int limit;
  final int total;

  OfferProductsData({
    required this.type,
    this.offerId,
    this.discountPercentage,
    required this.categories,
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory OfferProductsData.fromJson(Map<String, dynamic> json) {
    return OfferProductsData(
      type: json['type'] ?? '',
      offerId: json['offerId'],
      discountPercentage: (json['discountPercentage'] is int)
          ? (json['discountPercentage'] as int).toDouble()
          : json['discountPercentage'],
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ProductItem.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
class CategoryModel {
  final String id;
  final String label;

  CategoryModel({
    required this.id,
    required this.label,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
    );
  }
}
class ProductItem {
  final String id;
  final String type;
  final String category;
  final String name;
  final double price;
  final double? mrp;
  final double? offerPrice;
  final String? imageUrl;

  ProductItem({
    required this.id,
    required this.type,
    required this.category,
    required this.name,
    required this.price,
    this.mrp,
    this.offerPrice,
    this.imageUrl,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
      mrp: (json['mrp'] is int)
          ? (json['mrp'] as int).toDouble()
          : json['mrp'],
      offerPrice: (json['offerPrice'] is int)
          ? (json['offerPrice'] as int).toDouble()
          : json['offerPrice'],
      imageUrl: json['imageUrl'],
    );
  }
}
