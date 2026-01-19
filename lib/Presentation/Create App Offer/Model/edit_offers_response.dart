// ------------------ helpers ------------------

int _asInt(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? def;
}

num _asNum(dynamic v, {num def = 0}) {
  if (v == null) return def;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? def;
}

bool _asBool(dynamic v, {bool def = false}) {
  if (v == null) return def;
  if (v is bool) return v;
  final s = v.toString().toLowerCase().trim();
  return (s == 'true' || s == '1' || s == 'yes');
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

List<dynamic> _asList(dynamic v) {
  if (v == null) return <dynamic>[];
  if (v is List) return v;
  return <dynamic>[];
}

// ------------------ models ------------------

class EditOffersResponse {
  final bool status;
  final OfferDetailData? data;

  EditOffersResponse({required this.status, this.data});

  factory EditOffersResponse.fromJson(Map<String, dynamic> json) {
    return EditOffersResponse(
      status: json['status'] == true,
      data: json['data'] == null
          ? null
          : OfferDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

class OfferDetailData {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final dynamic adminTemplate;
  final String type;

  final String title;
  final String description;

  final num discountPercentage;

  final DateTime? availableFrom;
  final DateTime? availableTo;
  final DateTime? announcementAt;

  final dynamic campaignId;
  final dynamic maxCoupons;

  final String status;
  final bool autoApply;

  final dynamic targetSegment;

  final List<OfferProductLink> products;
  final List<OfferServiceLink> services;

  OfferDetailData({
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

  factory OfferDetailData.fromJson(Map<String, dynamic> json) {
    return OfferDetailData(
      id: (json['id'] ?? '').toString(),
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
      adminTemplate: json['adminTemplate'],
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      discountPercentage: _asNum(json['discountPercentage']),
      availableFrom: _tryParseDate(json['availableFrom']),
      availableTo: _tryParseDate(json['availableTo']),
      announcementAt: _tryParseDate(json['announcementAt']),
      campaignId: json['campaignId'],
      maxCoupons: json['maxCoupons'],
      status: (json['status'] ?? '').toString(),
      autoApply: _asBool(json['autoApply']),
      targetSegment: json['targetSegment'],
      products: _asList(json['products'])
          .map((e) => OfferProductLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: _asList(json['services'])
          .map((e) => OfferServiceLink.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'adminTemplate': adminTemplate,
    'type': type,
    'title': title,
    'description': description,
    'discountPercentage': discountPercentage,
    'availableFrom': availableFrom?.toIso8601String(),
    'availableTo': availableTo?.toIso8601String(),
    'announcementAt': announcementAt?.toIso8601String(),
    'campaignId': campaignId,
    'maxCoupons': maxCoupons,
    'status': status,
    'autoApply': autoApply,
    'targetSegment': targetSegment,
    'products': products.map((e) => e.toJson()).toList(),
    'services': services.map((e) => e.toJson()).toList(),
  };
}

// ------------------ product link + product ------------------

class OfferProductLink {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CatalogItem? product;

  OfferProductLink({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory OfferProductLink.fromJson(Map<String, dynamic> json) {
    return OfferProductLink(
      id: (json['id'] ?? '').toString(),
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
      product: json['product'] == null
          ? null
          : CatalogItem.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'product': product?.toJson(),
  };
}

// ------------------ service link + service (SAME AS PRODUCT) ------------------

class OfferServiceLink {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CatalogItem? service;

  OfferServiceLink({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
  });

  factory OfferServiceLink.fromJson(Map<String, dynamic> json) {
    return OfferServiceLink(
      id: (json['id'] ?? '').toString(),
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
      service: json['service'] == null
          ? null
          : CatalogItem.fromJson(json['service'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'service': service?.toJson(),
  };
}

// ------------------ common catalog item (reused for product & service) ------------------

class CatalogItem {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String category;
  final String subCategory;

  final String englishName;
  final String? tamilName;

  final String price;
  final String? imageUrl;

  final String? unitLabel;
  final dynamic stockCount;

  final bool isFeatured;

  final String offerLabel;
  final String offerValue;

  final String description;
  final dynamic keywords;

  final dynamic readyTimeMinutes;
  final bool doorDelivery;

  final String status;

  final bool hasVariants;

  final String averageRating;
  final int reviewCount;

  CatalogItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.subCategory,
    required this.englishName,
    required this.tamilName,
    required this.price,
    required this.imageUrl,
    required this.unitLabel,
    required this.stockCount,
    required this.isFeatured,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.keywords,
    required this.readyTimeMinutes,
    required this.doorDelivery,
    required this.status,
    required this.hasVariants,
    required this.averageRating,
    required this.reviewCount,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: (json['id'] ?? '').toString(),
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: json['tamilName']?.toString(),
      price: (json['price'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      unitLabel: json['unitLabel']?.toString(),
      stockCount: json['stockCount'],
      isFeatured: _asBool(json['isFeatured']),
      offerLabel: (json['offerLabel'] ?? '').toString(),
      offerValue: (json['offerValue'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      keywords: json['keywords'],
      readyTimeMinutes: json['readyTimeMinutes'],
      doorDelivery: _asBool(json['doorDelivery']),
      status: (json['status'] ?? '').toString(),
      hasVariants: _asBool(json['hasVariants']),
      averageRating: (json['averageRating'] ?? '').toString(),
      reviewCount: _asInt(json['reviewCount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'category': category,
    'subCategory': subCategory,
    'englishName': englishName,
    'tamilName': tamilName,
    'price': price,
    'imageUrl': imageUrl,
    'unitLabel': unitLabel,
    'stockCount': stockCount,
    'isFeatured': isFeatured,
    'offerLabel': offerLabel,
    'offerValue': offerValue,
    'description': description,
    'keywords': keywords,
    'readyTimeMinutes': readyTimeMinutes,
    'doorDelivery': doorDelivery,
    'status': status,
    'hasVariants': hasVariants,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
  };
}
