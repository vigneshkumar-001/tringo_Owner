// -----------------------------------------------------------------------------
// ROOT RESPONSE
// -----------------------------------------------------------------------------
class ShopDetailsResponse {
  final bool status;
  final ShopData? data;

  ShopDetailsResponse({
    required this.status,
    required this.data,
  });

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailsResponse(
      status: json['status'] as bool? ?? false,
      data: json['data'] != null
          ? ShopData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// SHOP DATA
// -----------------------------------------------------------------------------
class ShopData {
  final String? shopId;
  final String? shopEnglishName;
  final String? shopTamilName;
  final String? shopDescriptionEn;
  final String? shopDescriptionTa;
  final String? shopAddressEn;
  final String? shopAddressTa;
  final String? shopCity;
  final String? shopState;
  final String? shopCountry;
  final String? shopPostalCode;
  final String? shopGpsLatitude;
  final String? shopGpsLongitude;

  final String? category;
  final String? subCategory;

  final String? shopKind;
  final String? shopPhone;
  final String? shopWhatsapp;
  final String? shopContactEmail;

  final bool? shopDoorDelivery;
  final bool? shopIsTrusted;

  final double? shopRating;
  final int? shopReviewCount;

  final List<ShopImage> shopImages;
  final List<Product> products;
  final List<ServiceItem> services;
  final List<dynamic> reviews;

  ShopData({
    this.shopId,
    this.shopEnglishName,
    this.shopTamilName,
    this.shopDescriptionEn,
    this.shopDescriptionTa,
    this.shopAddressEn,
    this.shopAddressTa,
    this.shopCity,
    this.shopState,
    this.shopCountry,
    this.shopPostalCode,
    this.shopGpsLatitude,
    this.shopGpsLongitude,
    this.category,
    this.subCategory,
    this.shopKind,
    this.shopPhone,
    this.shopWhatsapp,
    this.shopContactEmail,
    this.shopDoorDelivery,
    this.shopIsTrusted,
    this.shopRating,
    this.shopReviewCount,
    required this.shopImages,
    required this.products,
    required this.services,
    required this.reviews,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      shopId: json['shopId'],
      shopEnglishName: json['shopEnglishName'],
      shopTamilName: json['shopTamilName'],
      shopDescriptionEn: json['shopDescriptionEn'],
      shopDescriptionTa: json['shopDescriptionTa'],
      shopAddressEn: json['shopAddressEn'],
      shopAddressTa: json['shopAddressTa'],
      shopCity: json['shopCity'],
      shopState: json['shopState'],
      shopCountry: json['shopCountry'],
      shopPostalCode: json['shopPostalCode'],
      shopGpsLatitude: json['shopGpsLatitude']?.toString(),
      shopGpsLongitude: json['shopGpsLongitude']?.toString(),

      category: json['category'],
      subCategory: json['subCategory'],

      shopKind: json['shopKind'],
      shopPhone: json['shopPhone'],
      shopWhatsapp: json['shopWhatsapp'],
      shopContactEmail: json['shopContactEmail'],

      shopDoorDelivery: json['shopDoorDelivery'] as bool? ?? false,
      shopIsTrusted: json['shopIsTrusted'] as bool? ?? false,

      shopRating: (json['shopRating'] as num?)?.toDouble(),
      shopReviewCount: (json['shopReviewCount'] as num?)?.toInt() ?? 0,

      shopImages: (json['shopImages'] as List<dynamic>? ?? [])
          .map((e) => ShopImage.fromJson(e))
          .toList(),

      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),

      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceItem.fromJson(e))
          .toList(),

      reviews: json['reviews'] ?? [],
    );
  }
}

// -----------------------------------------------------------------------------
// SHOP IMAGE
// -----------------------------------------------------------------------------
class ShopImage {
  final String? id;
  final String? type;
  final String? url;
  final int? displayOrder;

  ShopImage({this.id, this.type, this.url, this.displayOrder});

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT
// -----------------------------------------------------------------------------
class Product {
  final String? productId;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
  final String? englishName;
  final String? tamilName;
  final int? price;
  final bool? isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final bool? doorDelivery;
  final int? rating;
  final int? ratingCount;
  final List<ProductMedia> media;

  Product({
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.subCategory,
    this.englishName,
    this.tamilName,
    this.price,
    this.isFeatured,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.doorDelivery,
    this.rating,
    this.ratingCount,
    required this.media,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'],
      subCategory: json['subCategory'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      price: (json['price'] as num?)?.toInt(),
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      doorDelivery: json['doorDelivery'] ?? false,
      rating: (json['rating'] as num?)?.toInt(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),

      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => ProductMedia.fromJson(e))
          .toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT MEDIA
// -----------------------------------------------------------------------------
class ProductMedia {
  final String? id;
  final String? url;
  final int? displayOrder;

  ProductMedia({this.id, this.url, this.displayOrder});

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      id: json['id'],
      url: json['url'],
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE ITEM
// -----------------------------------------------------------------------------
class ServiceItem {
  final String? serviceId;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
  final String? englishName;
  final String? tamilName;
  final int? startsAt;
  final int? durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final int? rating;
  final int? ratingCount;
  final String? status;

  final List<ServiceFeature> features;
  final List<ServiceMedia> media;

  ServiceItem({
    this.serviceId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.subCategory,
    this.englishName,
    this.tamilName,
    this.startsAt,
    this.durationMinutes,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.rating,
    this.ratingCount,
    this.status,
    required this.features,
    required this.media,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      serviceId: json['serviceId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'],
      subCategory: json['subCategory'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      startsAt: (json['startsAt'] as num?)?.toInt(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      rating: (json['rating'] as num?)?.toInt(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      status: json['status'],

      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => ServiceFeature.fromJson(e))
          .toList(),

      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => ServiceMedia.fromJson(e))
          .toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE FEATURE
// -----------------------------------------------------------------------------
class ServiceFeature {
  final String? id;
  final String? label;
  final String? value;
  final String? language;

  ServiceFeature({this.id, this.label, this.value, this.language});

  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(
      id: json['id'],
      label: json['label'],
      value: json['value'],
      language: json['language'],
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE MEDIA
// -----------------------------------------------------------------------------
class ServiceMedia {
  final String? id;
  final String? url;
  final int? displayOrder;

  ServiceMedia({this.id, this.url, this.displayOrder});

  factory ServiceMedia.fromJson(Map<String, dynamic> json) {
    return ServiceMedia(
      id: json['id'],
      url: json['url'],
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}


// // -------------------- MAIN RESPONSE ------------------------
//
// class ShopDetailsResponse {
//   final bool status;
//   final ShopData? data;
//
//   ShopDetailsResponse({required this.status, required this.data});
//
//   factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return ShopDetailsResponse(
//       status: json['status'] as bool? ?? false,
//       data: json['data'] != null
//           ? ShopData.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }
//
// // -------------------- SHOP DATA ------------------------
//
// class ShopData {
//   final String? shopId;
//   final String? shopEnglishName;
//   final String? shopTamilName;
//   final String? shopDescriptionEn;
//   final String? shopDescriptionTa;
//   final String? shopAddressEn;
//   final String? shopAddressTa;
//   final String? shopCity;
//   final String? shopState;
//   final String? shopCountry;
//   final String? shopPostalCode;
//   final String? shopGpsLatitude;
//   final String? shopGpsLongitude;
//
//   /// Needed for the runtime getter lookup
//   final String? category; // ✅ keep this
//
//   final String? subCategory;
//   final String? shopKind;
//   final String? shopPhone;
//   final String? shopWhatsapp;
//   final String? shopContactEmail;
//   final bool? shopDoorDelivery;
//   final bool? shopIsTrusted;
//   final double? shopRating;
//   final int? shopReviewCount;
//
//   final List<ShopImage> shopImages;
//   final List<Product> products;
//   final List<dynamic> reviews; // you can replace with Review model later
//
//   ShopData({
//     this.shopId,
//     this.shopEnglishName,
//     this.shopTamilName,
//     this.shopDescriptionEn,
//     this.shopDescriptionTa,
//     this.shopAddressEn,
//     this.shopAddressTa,
//     this.shopCity,
//     this.shopState,
//     this.shopCountry,
//     this.shopPostalCode,
//     this.shopGpsLatitude,
//     this.shopGpsLongitude,
//     this.category,
//     this.subCategory,
//     this.shopKind,
//     this.shopPhone,
//     this.shopWhatsapp,
//     this.shopContactEmail,
//     this.shopDoorDelivery,
//     this.shopIsTrusted,
//     this.shopRating,
//     this.shopReviewCount,
//     required this.shopImages,
//     required this.products,
//     required this.reviews,
//   });
//
//   factory ShopData.fromJson(Map<String, dynamic> json) {
//     return ShopData(
//       shopId: json['shopId'] as String?,
//       shopEnglishName: json['shopEnglishName'] as String?,
//       shopTamilName: json['shopTamilName'] as String?,
//       shopDescriptionEn: json['shopDescriptionEn'] as String?,
//       shopDescriptionTa: json['shopDescriptionTa'] as String?,
//       shopAddressEn: json['shopAddressEn'] as String?,
//       shopAddressTa: json['shopAddressTa'] as String?,
//       shopCity: json['shopCity'] as String?,
//       shopState: json['shopState'] as String?,
//       shopCountry: json['shopCountry'] as String?,
//       shopPostalCode: json['shopPostalCode'] as String?,
//       shopGpsLatitude: json['shopGpsLatitude']?.toString(),
//       shopGpsLongitude: json['shopGpsLongitude']?.toString(),
//
//       // ✅ this is the important one for your error
//       category: json['category'] as String?,
//
//       subCategory: json['subCategory'] as String?,
//       shopKind: json['shopKind'] as String?,
//       shopPhone: json['shopPhone'] as String?,
//       shopWhatsapp: json['shopWhatsapp'] as String?,
//       shopContactEmail: json['shopContactEmail'] as String?,
//       shopDoorDelivery: json['shopDoorDelivery'] as bool? ?? false,
//       shopIsTrusted: json['shopIsTrusted'] as bool? ?? false,
//       shopRating: (json['shopRating'] as num?)?.toDouble(),
//       shopReviewCount: (json['shopReviewCount'] as num?)?.toInt() ?? 0,
//
//       shopImages:
//           (json['shopImages'] as List<dynamic>?)
//               ?.map((e) => ShopImage.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//
//       products:
//           (json['products'] as List<dynamic>?)
//               ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//
//       reviews: json['reviews'] as List<dynamic>? ?? const [],
//     );
//   }
// }
//
// // -------------------- SHOP IMAGES ------------------------
//
// class ShopImage {
//   final String? id;
//   final String? type;
//   final String? url;
//   final int? displayOrder;
//
//   ShopImage({this.id, this.type, this.url, this.displayOrder});
//
//   factory ShopImage.fromJson(Map<String, dynamic> json) {
//     return ShopImage(
//       id: json['id'] as String?,
//       type: json['type'] as String?,
//       url: json['url'] as String?,
//       displayOrder: (json['displayOrder'] as num?)?.toInt(),
//     );
//   }
// }
//
// // -------------------- PRODUCT ------------------------
//
// class Product {
//   final String? productId;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? category;
//   final String? subCategory;
//   final String? englishName;
//   final String? tamilName;
//   final int? price;
//   final bool? isFeatured;
//   final String? offerLabel;
//   final String? offerValue;
//   final String? description;
//   final bool? doorDelivery;
//   final int? rating;
//   final int? ratingCount;
//
//   final List<ProductMedia> media;
//
//   Product({
//     this.productId,
//     this.createdAt,
//     this.updatedAt,
//     this.category,
//     this.subCategory,
//     this.englishName,
//     this.tamilName,
//     this.price,
//     this.isFeatured,
//     this.offerLabel,
//     this.offerValue,
//     this.description,
//     this.doorDelivery,
//     this.rating,
//     this.ratingCount,
//     required this.media,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       productId: json['productId'] as String?,
//       createdAt: json['createdAt'] as String?,
//       updatedAt: json['updatedAt'] as String?,
//       category: json['category'] as String?,
//       subCategory: json['subCategory'] as String?,
//       englishName: json['englishName'] as String?,
//       tamilName: json['tamilName'] as String?,
//       price: (json['price'] as num?)?.toInt(),
//       isFeatured: json['isFeatured'] as bool? ?? false,
//       offerLabel: json['offerLabel'] as String?,
//       offerValue: json['offerValue'] as String?,
//       description: json['description'] as String?,
//       doorDelivery: json['doorDelivery'] as bool? ?? false,
//       rating: (json['rating'] as num?)?.toInt(),
//       ratingCount: (json['ratingCount'] as num?)?.toInt(),
//       media:
//           (json['media'] as List<dynamic>?)
//               ?.map((e) => ProductMedia.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//     );
//   }
// }
//
// // -------------------- PRODUCT MEDIA ------------------------
//
// class ProductMedia {
//   final String? id;
//   final String? url;
//   final int? displayOrder;
//
//   ProductMedia({this.id, this.url, this.displayOrder});
//
//   factory ProductMedia.fromJson(Map<String, dynamic> json) {
//     return ProductMedia(
//       id: json['id'] as String?,
//       url: json['url'] as String?,
//       displayOrder: (json['displayOrder'] as num?)?.toInt(),
//     );
//   }
// }
