// -----------------------------------------------------------------------------
// FULL UPDATED MODEL (ShopDetailsResponse)
// - Fixes: reviews parsing, createdAtRelative null issue, safe casting
// - Matches your API response exactly
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// ROOT RESPONSE
// -----------------------------------------------------------------------------
class ShopDetailsResponse {
  final bool status;
  final ShopData? data;

  ShopDetailsResponse({required this.status, required this.data});

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailsResponse(
      status: json['status'] as bool? ?? false,
      data: json['data'] is Map
          ? ShopData.fromJson((json['data'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// SHOP DATA
// -----------------------------------------------------------------------------
class ShopData {
  final String? shopId;
  final String? businessProfileId;

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

  final List<ShopWeeklyHour> shopWeeklyHours;
  final String? opensAt;
  final String? closesAt;
  final String? ownershipType;

  final List<ShopImage> shopImages;
  final String? shopOwnerImageUrl;

  final List<Product> products;
  final List<ServiceItem> services;

  // ✅ Reviews (typed, safe)
  final List<ShopReviewItem> reviews;

  ShopData({
    this.shopId,
    this.businessProfileId,
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
    required this.shopWeeklyHours,
    this.opensAt,
    this.closesAt,
    this.ownershipType,
    required this.shopImages,
    this.shopOwnerImageUrl,
    required this.products,
    required this.services,
    required this.reviews,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    // ---------- Reviews safe parse ----------
    final rawReviews = json['reviews'];
    final List<ShopReviewItem> parsedReviews = (rawReviews is List)
        ? rawReviews.map((e) {
            final m = (e is Map<String, dynamic>)
                ? e
                : (e is Map)
                ? e.cast<String, dynamic>()
                : <String, dynamic>{'comment': e.toString()};
            return ShopReviewItem.fromJson(m);
          }).toList()
        : <ShopReviewItem>[];

    // ---------- Weekly hours safe parse ----------
    final rawHours = json['shopWeeklyHours'];
    final List<ShopWeeklyHour> parsedHours = (rawHours is List)
        ? rawHours.map((e) {
            final m = (e is Map<String, dynamic>)
                ? e
                : (e is Map)
                ? e.cast<String, dynamic>()
                : <String, dynamic>{};
            return ShopWeeklyHour.fromJson(m);
          }).toList()
        : <ShopWeeklyHour>[];

    return ShopData(
      shopId: json['shopId']?.toString(),
      businessProfileId: json['businessProfileId']?.toString(),

      shopEnglishName: json['shopEnglishName']?.toString(),
      shopTamilName: json['shopTamilName']?.toString(),
      shopDescriptionEn: json['shopDescriptionEn']?.toString(),
      shopDescriptionTa: json['shopDescriptionTa']?.toString(),
      shopAddressEn: json['shopAddressEn']?.toString(),
      shopAddressTa: json['shopAddressTa']?.toString(),
      shopCity: json['shopCity']?.toString(),
      shopState: json['shopState']?.toString(),
      shopCountry: json['shopCountry']?.toString(),
      shopPostalCode: json['shopPostalCode']?.toString(),
      shopGpsLatitude: json['shopGpsLatitude']?.toString(),
      shopGpsLongitude: json['shopGpsLongitude']?.toString(),

      category: json['category']?.toString(),
      subCategory: json['subCategory']?.toString(),

      shopKind: json['shopKind']?.toString(),
      shopPhone: json['shopPhone']?.toString(),
      shopWhatsapp: json['shopWhatsapp']?.toString(),
      shopContactEmail: json['shopContactEmail']?.toString(),

      shopDoorDelivery: json['shopDoorDelivery'] as bool? ?? false,
      shopIsTrusted: json['shopIsTrusted'] as bool? ?? false,

      shopRating: (json['shopRating'] as num?)?.toDouble(),
      shopReviewCount: (json['shopReviewCount'] as num?)?.toInt() ?? 0,

      shopWeeklyHours: parsedHours,
      opensAt: json['opensAt']?.toString(),
      closesAt: json['closesAt']?.toString(),
      ownershipType: json['ownershipType']?.toString(),

      shopImages: (json['shopImages'] is List)
          ? (json['shopImages'] as List)
                .map(
                  (e) => ShopImage.fromJson((e as Map).cast<String, dynamic>()),
                )
                .toList()
          : <ShopImage>[],
      shopOwnerImageUrl: json['shopOwnerImageUrl']?.toString(),

      products: (json['products'] is List)
          ? (json['products'] as List)
                .map(
                  (e) => Product.fromJson((e as Map).cast<String, dynamic>()),
                )
                .toList()
          : <Product>[],

      services: (json['services'] is List)
          ? (json['services'] as List)
                .map(
                  (e) =>
                      ServiceItem.fromJson((e as Map).cast<String, dynamic>()),
                )
                .toList()
          : <ServiceItem>[],

      // ✅ final reviews
      reviews: parsedReviews,
    );
  }
}

// -----------------------------------------------------------------------------
// WEEKLY HOURS
// -----------------------------------------------------------------------------
class ShopWeeklyHour {
  final String? day;
  final String? opensAt;
  final String? closesAt;
  final bool? closed;

  ShopWeeklyHour({this.day, this.opensAt, this.closesAt, this.closed});

  factory ShopWeeklyHour.fromJson(Map<String, dynamic> json) {
    return ShopWeeklyHour(
      day: json['day']?.toString(),
      opensAt: json['opensAt']?.toString(),
      closesAt: json['closesAt']?.toString(),
      closed: json['closed'] as bool? ?? false,
    );
  }
}

// -----------------------------------------------------------------------------
// REVIEW MODEL (UPDATED FOR createdAtRelative)
// -----------------------------------------------------------------------------
class ShopReviewItem {
  final String? id;
  final double? rating; // "4.0" -> 4.0
  final String? comment; // multiline
  final String? createdAtRelative; // "1 Hour Ago"

  const ShopReviewItem({
    this.id,
    this.rating,
    this.comment,
    this.createdAtRelative,
  });

  factory ShopReviewItem.fromJson(Map<String, dynamic> json) {
    double? parseRating(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
      return null;
    }

    String? pick(Map<String, dynamic> j, List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return null;
    }

    return ShopReviewItem(
      id: pick(json, ['id', '_id', 'reviewId']),
      rating: parseRating(pick(json, ['rating', 'stars', 'rate'])),
      comment: pick(json, ['comment', 'message', 'review', 'text']),
      createdAtRelative: pick(json, [
        'createdAtRelative',
        'created_at_relative',
        'createdAtHuman',
        'createdAtText',
        'timeAgo',
      ]),
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
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      url: json['url']?.toString(),
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
  final int? offerPrice;
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
    this.offerPrice,
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
      productId: json['productId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      category: json['category']?.toString(),
      subCategory: json['subCategory']?.toString(),
      englishName: json['englishName']?.toString(),
      tamilName: json['tamilName']?.toString(),
      price: (json['price'] as num?)?.toInt(),
      offerPrice: (json['offerPrice'] as num?)?.toInt(),
      isFeatured: json['isFeatured'] as bool? ?? false,
      offerLabel: json['offerLabel']?.toString(),
      offerValue: json['offerValue']?.toString(),
      description: json['description']?.toString(),
      doorDelivery: json['doorDelivery'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toInt(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      media: (json['media'] is List)
          ? (json['media'] as List)
                .map(
                  (e) =>
                      ProductMedia.fromJson((e as Map).cast<String, dynamic>()),
                )
                .toList()
          : <ProductMedia>[],
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
      id: json['id']?.toString(),
      url: json['url']?.toString(),
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

  final double? startsAt;
  final double? offerPrice;

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
    this.offerPrice,
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
      serviceId: json['serviceId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      category: json['category']?.toString(),
      subCategory: json['subCategory']?.toString(),
      englishName: json['englishName']?.toString(),
      tamilName: json['tamilName']?.toString(),
      startsAt: (json['startsAt'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      offerLabel: json['offerLabel']?.toString(),
      offerValue: json['offerValue']?.toString(),
      description: json['description']?.toString(),
      rating: (json['rating'] as num?)?.toInt(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      status: json['status']?.toString(),
      features: (json['features'] is List)
          ? (json['features'] as List)
                .map(
                  (e) => ServiceFeature.fromJson(
                    (e as Map).cast<String, dynamic>(),
                  ),
                )
                .toList()
          : <ServiceFeature>[],
      media: (json['media'] is List)
          ? (json['media'] as List)
                .map(
                  (e) =>
                      ServiceMedia.fromJson((e as Map).cast<String, dynamic>()),
                )
                .toList()
          : <ServiceMedia>[],
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
      id: json['id']?.toString(),
      label: json['label']?.toString(),
      value: json['value']?.toString(),
      language: json['language']?.toString(),
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
      id: json['id']?.toString(),
      url: json['url']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}
