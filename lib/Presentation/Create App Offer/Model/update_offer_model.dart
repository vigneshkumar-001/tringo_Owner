class UpdateOfferModel {
  final bool status;
  final UpdateOfferData? data;

  UpdateOfferModel({required this.status, this.data});

  factory UpdateOfferModel.fromJson(Map<String, dynamic> json) {
    return UpdateOfferModel(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? UpdateOfferData.fromJson(json['data'])
          : null,
    );
  }
}

class UpdateOfferData {
  final String id;
  final String? createdAt;
  final String? updatedAt;
  final String? adminTemplate;
  final String type;
  final String title;
  final String description;
  final int discountPercentage;
  final String availableFrom;
  final String availableTo;
  final String announcementAt;
  final String? campaignId;
  final int? maxCoupons;
  final String status;
  final bool autoApply;
  final String? targetSegment;
  final List<OfferProduct> products;
  final List<dynamic> services;

  UpdateOfferData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.adminTemplate,
    required this.type,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.availableFrom,
    required this.availableTo,
    required this.announcementAt,
    required this.campaignId,
    required this.maxCoupons,
    required this.status,
    required this.autoApply,
    required this.targetSegment,
    required this.products,
    required this.services,
  });

  factory UpdateOfferData.fromJson(Map<String, dynamic> json) {
    return UpdateOfferData(
      id: json['id'] ?? "",
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      adminTemplate: json['adminTemplate'],
      type: json['type'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      discountPercentage: json['discountPercentage'] ?? 0,
      availableFrom: json['availableFrom'] ?? "",
      availableTo: json['availableTo'] ?? "",
      announcementAt: json['announcementAt'] ?? "",
      campaignId: json['campaignId'],
      maxCoupons: json['maxCoupons'],
      status: json['status'] ?? "",
      autoApply: json['autoApply'] ?? false,
      targetSegment: json['targetSegment'],
      products: (json['products'] as List<dynamic>)
          .map((e) => OfferProduct.fromJson(e))
          .toList(),
      services: json['services'] ?? [],
    );
  }
}

class OfferProduct {
  final String id;
  final String? createdAt;
  final String? updatedAt;
  final Product product;

  OfferProduct({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.product,
  });

  factory OfferProduct.fromJson(Map<String, dynamic> json) {
    return OfferProduct(
      id: json['id'] ?? "",
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final String id;
  final String? createdAt;
  final String? updatedAt;
  final String category;
  final String subCategory;
  final String englishName;
  final String? tamilName;
  final String price;
  final String? imageUrl;
  final String? unitLabel;
  final int? stockCount;
  final bool isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final dynamic keywords;
  final int? readyTimeMinutes;
  final bool doorDelivery;
  final String status;
  final bool hasVariants;
  final String averageRating;
  final int reviewCount;

  Product({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.category,
    required this.subCategory,
    required this.englishName,
    this.tamilName,
    required this.price,
    this.imageUrl,
    this.unitLabel,
    this.stockCount,
    required this.isFeatured,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.keywords,
    this.readyTimeMinutes,
    required this.doorDelivery,
    required this.status,
    required this.hasVariants,
    required this.averageRating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? "",
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'] ?? "",
      subCategory: json['subCategory'] ?? "",
      englishName: json['englishName'] ?? "",
      tamilName: json['tamilName'],
      price: json['price'] ?? "0",
      imageUrl: json['imageUrl'],
      unitLabel: json['unitLabel'],
      stockCount: json['stockCount'],
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      keywords: json['keywords'],
      readyTimeMinutes: json['readyTimeMinutes'],
      doorDelivery: json['doorDelivery'] ?? false,
      status: json['status'] ?? "",
      hasVariants: json['hasVariants'] ?? false,
      averageRating: json['averageRating'] ?? "0",
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
