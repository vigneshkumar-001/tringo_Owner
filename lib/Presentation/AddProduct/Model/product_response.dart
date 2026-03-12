class ProductResponse {
  final bool status;
  final ProductData data;

  ProductResponse({required this.status, required this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      ProductResponse(
        status: json['status'] ?? false,
        data: ProductData.fromJson(
          (json['data'] as Map<String, dynamic>?) ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
}

class ProductData {
  final String id;
  final String shopId;
  final String category;
  final String subCategory;
  final String englishName;
  final String? tamilName;
  final num price;
  final String? offerLabel;
  final String? offerValue;
  final String description;
  final List<String> keywords;
  final int? readyTimeMinutes;
  final bool doorDelivery;
  final String status;
  final num rating;
  final int ratingCount;
  final List<Feature> features;
  final List<SKU> skus;
  final List<dynamic> media;

  ProductData({
    required this.id,
    required this.shopId,
    required this.category,
    required this.subCategory,
    required this.englishName,
    this.tamilName,
    required this.price,
    this.offerLabel,
    this.offerValue,
    required this.description,
    required this.keywords,
    this.readyTimeMinutes,
    required this.doorDelivery,
    required this.status,
    required this.rating,
    required this.ratingCount,
    required this.features,
    required this.skus,
    required this.media,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
    id: json['id']?.toString() ?? '',
    shopId: json['shopId']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    subCategory: json['subCategory']?.toString() ?? '',
    englishName: json['englishName']?.toString() ?? '',
    tamilName: json['tamilName']?.toString(),
    price: json['price'] is String
        ? num.tryParse(json['price']) ?? 0
        : json['price'] ?? 0,
    offerLabel: json['offerLabel']?.toString(),
    offerValue: json['offerValue']?.toString(),
    description: json['description']?.toString() ?? '',
    keywords:
        (json['keywords'] as List<dynamic>?)
            ?.where((e) => e != null)
            .map((e) => e.toString())
            .toList() ??
        [],
    readyTimeMinutes: json['readyTimeMinutes'] is int
        ? json['readyTimeMinutes']
        : int.tryParse(json['readyTimeMinutes']?.toString() ?? ''),
    doorDelivery: () {
      final raw = json['doorDelivery'];
      if (raw is bool) return raw;
      if (raw is num) return raw == 1;
      if (raw is String) {
        final v = raw.toLowerCase();
        return v == 'true' || v == '1' || v == 'yes';
      }
      return false;
    }(),
    status: json['status']?.toString() ?? 'DRAFT',
    rating: json['rating'] is String
        ? num.tryParse(json['rating']) ?? 0
        : json['rating'] ?? 0,
    ratingCount: json['ratingCount'] is int
        ? json['ratingCount']
        : int.tryParse(json['ratingCount']?.toString() ?? '') ?? 0,
    features:
        (json['features'] as List<dynamic>?)
            ?.map(
              (e) => Feature.fromJson(
                (e as Map<String, dynamic>?) ?? <String, dynamic>{},
              ),
            )
            .toList() ??
        [],
    skus:
        (json['skus'] as List<dynamic>?)
            ?.map(
              (e) => SKU.fromJson(
                (e as Map<String, dynamic>?) ?? <String, dynamic>{},
              ),
            )
            .toList() ??
        [],
    media: json['media'] as List<dynamic>? ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'category': category,
    'subCategory': subCategory,
    'englishName': englishName,
    'tamilName': tamilName,
    'price': price,
    'offerLabel': offerLabel,
    'offerValue': offerValue,
    'description': description,
    'keywords': keywords,
    'readyTimeMinutes': readyTimeMinutes,
    'doorDelivery': doorDelivery,
    'status': status,
    'rating': rating,
    'ratingCount': ratingCount,
    'features': features.map((e) => e.toJson()).toList(),
    'skus': skus.map((e) => e.toJson()).toList(),
    'media': media,
  };
}

class Feature {
  final String id;
  final String label;
  final String value;
  final String? language;

  Feature({
    required this.id,
    required this.label,
    required this.value,
    this.language,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    id: json['id']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    value: json['value']?.toString() ?? '',
    language: json['language']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'value': value,
    'language': language,
  };
}

class SKU {
  final String id;
  final num mrp;
  final num price;
  final int stockQty;
  final bool isPrimary;
  final String? variantLabel;
  final String? weightLabel;
  final String? barcode;
  final bool active;

  SKU({
    required this.id,
    required this.mrp,
    required this.price,
    required this.stockQty,
    required this.isPrimary,
    this.variantLabel,
    this.weightLabel,
    this.barcode,
    required this.active,
  });

  factory SKU.fromJson(Map<String, dynamic> json) => SKU(
    id: json['id']?.toString() ?? '',
    mrp: json['mrp'] is String
        ? num.tryParse(json['mrp']) ?? 0
        : json['mrp'] ?? 0,
    price: json['price'] is String
        ? num.tryParse(json['price']) ?? 0
        : json['price'] ?? 0,
    stockQty: json['stockQty'] is int
        ? json['stockQty']
        : int.tryParse(json['stockQty']?.toString() ?? '') ?? 0,
    isPrimary: json['isPrimary'] ?? false,
    variantLabel: json['variantLabel']?.toString(),
    weightLabel: json['weightLabel']?.toString(),
    barcode: json['barcode']?.toString(),
    active: json['active'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mrp': mrp,
    'price': price,
    'stockQty': stockQty,
    'isPrimary': isPrimary,
    'variantLabel': variantLabel,
    'weightLabel': weightLabel,
    'barcode': barcode,
    'active': active,
  };
}

// class ProductResponse {
//   final bool status;
//   final ProductData data;
//
//   ProductResponse({required this.status, required this.data});
//
//   factory ProductResponse.fromJson(Map<String, dynamic> json) =>
//       ProductResponse(
//         status: json['status'] ?? false,
//         data: ProductData.fromJson(json['data']),
//       );
//
//   Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
// }
//
// class ProductData {
//   final String id;
//   final String shopId;
//   final String category;
//   final String subCategory;
//   final String englishName;
//   // final String tamilName;
//   final String? tamilName;
//   final num price;
//   final String? offerLabel;
//   final String? offerValue;
//   final String description;
//   final List<String> keywords;
//   // final int readyTimeMinutes;
//   final int? readyTimeMinutes;
//   final bool doorDelivery;
//   final String status;
//   final num rating;
//   final int ratingCount;
//   final List<Feature> features;
//   final List<SKU> skus;
//   final List<dynamic> media;
//
//   ProductData({
//     required this.id,
//     required this.shopId,
//     required this.category,
//     required this.subCategory,
//     required this.englishName,
//     // required this.tamilName,
//     this.tamilName,
//     required this.price,
//     this.offerLabel,
//     this.offerValue,
//     required this.description,
//     required this.keywords,
//     // required this.readyTimeMinutes,
//     this.readyTimeMinutes,
//     required this.doorDelivery,
//     required this.status,
//     required this.rating,
//     required this.ratingCount,
//     required this.features,
//     required this.skus,
//     required this.media,
//   });
//
//   factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
//     id: json['id'],
//     shopId: json['shopId'],
//     category: json['category'],
//     subCategory: json['subCategory'],
//     englishName: json['englishName'],
//     // tamilName: json['tamilName'],
//     tamilName: json['tamilName'] as String?,
//     price: json['price'] is String
//         ? num.tryParse(json['price']) ?? 0
//         : json['price'] ?? 0,
//     offerLabel: json['offerLabel'],
//     offerValue: json['offerValue'],
//     description: json['description'],
//     keywords: List<String>.from(json['keywords'] ?? []),
//     // readyTimeMinutes: json['readyTimeMinutes'] ?? 0,
//     readyTimeMinutes: json['readyTimeMinutes'] as int?,
//     // doorDelivery: json['doorDelivery'] ?? false,
//     doorDelivery: () {
//       final raw = json['doorDelivery'];
//       if (raw is bool) return raw;
//       if (raw is num) return raw == 1;
//       if (raw is String) {
//         final v = raw.toLowerCase();
//         return v == 'true' || v == '1' || v == 'yes';
//       }
//       return false;
//     }(),
//     status: json['status'] ?? 'DRAFT',
//     rating: json['rating'] is String
//         ? num.tryParse(json['rating']) ?? 0
//         : json['rating'] ?? 0,
//     ratingCount: json['ratingCount'] ?? 0,
//     features:
//         (json['features'] as List<dynamic>?)
//             ?.map((e) => Feature.fromJson(e))
//             .toList() ??
//         [],
//     skus:
//         (json['skus'] as List<dynamic>?)
//             ?.map((e) => SKU.fromJson(e))
//             .toList() ??
//         [],
//     media: json['media'] ?? [],
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'shopId': shopId,
//     'category': category,
//     'subCategory': subCategory,
//     'englishName': englishName,
//     'tamilName': tamilName,
//     'price': price,
//     'offerLabel': offerLabel,
//     'offerValue': offerValue,
//     'description': description,
//     'keywords': keywords,
//     'readyTimeMinutes': readyTimeMinutes,
//     'doorDelivery': doorDelivery,
//     'status': status,
//     'rating': rating,
//     'ratingCount': ratingCount,
//     'features': features.map((e) => e.toJson()).toList(),
//     'skus': skus.map((e) => e.toJson()).toList(),
//     'media': media,
//   };
// }
//
// class Feature {
//   final String id;
//   final String label;
//   final String value;
//   final String? language;
//
//   Feature({
//     required this.id,
//     required this.label,
//     required this.value,
//     this.language,
//   });
//
//   factory Feature.fromJson(Map<String, dynamic> json) => Feature(
//     id: json['id'],
//     label: json['label'],
//     value: json['value'],
//     language: json['language'],
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'label': label,
//     'value': value,
//     'language': language,
//   };
// }
//
// class SKU {
//   final String id;
//   final num mrp;
//   final num price;
//   final int stockQty;
//   final bool isPrimary;
//   final String? variantLabel;
//   final String? weightLabel;
//   final String? barcode;
//   final bool active;
//
//   SKU({
//     required this.id,
//     required this.mrp,
//     required this.price,
//     required this.stockQty,
//     required this.isPrimary,
//     this.variantLabel,
//     this.weightLabel,
//     this.barcode,
//     required this.active,
//   });
//
//   factory SKU.fromJson(Map<String, dynamic> json) => SKU(
//     id: json['id'],
//     mrp: json['mrp'] is String
//         ? num.tryParse(json['mrp']) ?? 0
//         : json['mrp'] ?? 0,
//     price: json['price'] is String
//         ? num.tryParse(json['price']) ?? 0
//         : json['price'] ?? 0,
//     stockQty: json['stockQty'] ?? 0,
//     isPrimary: json['isPrimary'] ?? false,
//     variantLabel: json['variantLabel'],
//     weightLabel: json['weightLabel'],
//     barcode: json['barcode'],
//     active: json['active'] ?? false,
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'mrp': mrp,
//     'price': price,
//     'stockQty': stockQty,
//     'isPrimary': isPrimary,
//     'variantLabel': variantLabel,
//     'weightLabel': weightLabel,
//     'barcode': barcode,
//     'active': active,
//   };
// }
