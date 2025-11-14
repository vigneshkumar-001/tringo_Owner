// ------------------ ROOT RESPONSE ------------------

class ShopDetailsResponse {
  final bool status;
  final ShopData? data;

  ShopDetailsResponse({
    required this.status,
    required this.data,
  });

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailsResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? ShopData.fromJson(json['data']) : null,
    );
  }
}

// ------------------ SHOP DATA ------------------

class ShopData {
  final String shopId;
  final String shopEnglishName;
  final String shopTamilName;
  final String? shopDescriptionEn;
  final String? shopDescriptionTa;
  final String? shopAddressEn;
  final String? shopAddressTa;
  final String shopCity;
  final String shopState;
  final String shopCountry;
  final String shopPostalCode;
  final String shopGpsLatitude;
  final String shopGpsLongitude;
  final String? shopPhone;
  final String? shopWhatsapp;
  final String? shopContactEmail;
  final bool shopDoorDelivery;
  final bool shopIsTrusted;
  final int shopRating;
  final int shopReviewCount;
  final List<ShopImage> shopImages;
  final List<Product> products;

  ShopData({
    required this.shopId,
    required this.shopEnglishName,
    required this.shopTamilName,
    required this.shopDescriptionEn,
    required this.shopDescriptionTa,
    required this.shopAddressEn,
    required this.shopAddressTa,
    required this.shopCity,
    required this.shopState,
    required this.shopCountry,
    required this.shopPostalCode,
    required this.shopGpsLatitude,
    required this.shopGpsLongitude,
    required this.shopPhone,
    required this.shopWhatsapp,
    required this.shopContactEmail,
    required this.shopDoorDelivery,
    required this.shopIsTrusted,
    required this.shopRating,
    required this.shopReviewCount,
    required this.shopImages,
    required this.products,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      shopId: json['shopId'] ?? "",
      shopEnglishName: json['shopEnglishName'] ?? "",
      shopTamilName: json['shopTamilName'] ?? "",
      shopDescriptionEn: json['shopDescriptionEn'],
      shopDescriptionTa: json['shopDescriptionTa'],
      shopAddressEn: json['shopAddressEn'],
      shopAddressTa: json['shopAddressTa'],
      shopCity: json['shopCity'] ?? "",
      shopState: json['shopState'] ?? "",
      shopCountry: json['shopCountry'] ?? "",
      shopPostalCode: json['shopPostalCode'] ?? "",
      shopGpsLatitude: json['shopGpsLatitude'] ?? "",
      shopGpsLongitude: json['shopGpsLongitude'] ?? "",
      shopPhone: json['shopPhone'],
      shopWhatsapp: json['shopWhatsapp'],
      shopContactEmail: json['shopContactEmail'],
      shopDoorDelivery: json['shopDoorDelivery'] ?? false,
      shopIsTrusted: json['shopIsTrusted'] ?? false,
      shopRating: json['shopRating'] ?? 0,
      shopReviewCount: json['shopReviewCount'] ?? 0,
      shopImages: (json['shopImages'] as List<dynamic>?)
          ?.map((e) => ShopImage.fromJson(e))
          .toList() ??
          [],
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e))
          .toList() ??
          [],
    );
  }
}

// ------------------ SHOP IMAGE ------------------

class ShopImage {
  final String id;
  final String type;
  final String url;
  final int displayOrder;

  ShopImage({
    required this.id,
    required this.type,
    required this.url,
    required this.displayOrder,
  });

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      id: json['id'] ?? "",
      type: json['type'] ?? "",
      url: json['url'] ?? "",
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

// ------------------ PRODUCT ------------------

class Product {
  final String productId;
  final String createdAt;
  final String updatedAt;
  final String category;
  final String subCategory;
  final String englishName;
  final String tamilName;
  final num price;
  final bool isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final bool doorDelivery;
  final int rating;
  final int ratingCount;
  final List<ProductMedia> media;

  Product({
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.subCategory,
    required this.englishName,
    required this.tamilName,
    required this.price,
    required this.isFeatured,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.doorDelivery,
    required this.rating,
    required this.ratingCount,
    required this.media,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      category: json['category'] ?? "",
      subCategory: json['subCategory'] ?? "",
      englishName: json['englishName'] ?? "",
      tamilName: json['tamilName'] ?? "",
      price: json['price'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      doorDelivery: json['doorDelivery'] ?? false,
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => ProductMedia.fromJson(e))
          .toList() ??
          [],
    );
  }
}

// ------------------ PRODUCT MEDIA ------------------

class ProductMedia {
  final String id;
  final String url;
  final int displayOrder;

  ProductMedia({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      id: json['id'] ?? "",
      url: json['url'] ?? "",
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}
