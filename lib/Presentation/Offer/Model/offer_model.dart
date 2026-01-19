// offer_sections_response.dart

class OfferModel {
  final bool status;
  final OfferSectionsData? data;

  OfferModel({required this.status, this.data});

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      status: json['status'] == true,
      data: json['data'] == null
          ? null
          : OfferSectionsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

class OfferSectionsData {
  final int liveCount;
  final int upcomingCount;
  final int expiredCount;

  final List<OfferDaySection> upcomingSections;
  final List<OfferDaySection> liveSections;
  final List<OfferDaySection> expiredSections;

  OfferSectionsData({
    required this.liveCount,
    required this.upcomingCount,
    required this.expiredCount,
    required this.upcomingSections,
    required this.liveSections,
    required this.expiredSections,
  });

  factory OfferSectionsData.fromJson(Map<String, dynamic> json) {
    return OfferSectionsData(
      liveCount: _asInt(json['liveCount']),
      upcomingCount: _asInt(json['upcomingCount']),
      expiredCount: _asInt(json['expiredCount']),
      upcomingSections: _asList(
        json['upcomingSections'],
      ).map((e) => OfferDaySection.fromJson(e)).toList(),
      liveSections: _asList(
        json['liveSections'],
      ).map((e) => OfferDaySection.fromJson(e)).toList(),
      expiredSections: _asList(
        json['expiredSections'],
      ).map((e) => OfferDaySection.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'liveCount': liveCount,
    'upcomingCount': upcomingCount,
    'expiredCount': expiredCount,
    'upcomingSections': upcomingSections.map((e) => e.toJson()).toList(),
    'liveSections': liveSections.map((e) => e.toJson()).toList(),
    'expiredSections': expiredSections.map((e) => e.toJson()).toList(),
  };
}

class OfferDaySection {
  final String dayLabel;
  final List<OfferItem> items;

  OfferDaySection({required this.dayLabel, required this.items});

  factory OfferDaySection.fromJson(Map<String, dynamic> json) {
    return OfferDaySection(
      dayLabel: (json['dayLabel'] ?? '').toString(),
      items: _asList(json['items']).map((e) => OfferItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dayLabel': dayLabel,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class OfferItem {
  final String id;
  final String title;

  // ✅ NEW
  final String description;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final DateTime? announcementAt;

  final num discountPercentage;
  final String offerBadgeLabel;

  final DateTime? createdAt;
  final String createdTime;
  final String expiresAt;

  final String statusEnum;
  final String stateLabel;

  final int enquiriesCount;
  final OfferTypesCount typesCount;

  final List<OfferProduct> products;
  final List<OfferService> services;

  final String source;

  OfferItem({
    required this.id,
    required this.title,
    required this.description,
    required this.availableFrom,
    required this.availableTo,
    required this.announcementAt,
    required this.discountPercentage,
    required this.offerBadgeLabel,
    required this.createdAt,
    required this.createdTime,
    required this.expiresAt,
    required this.statusEnum,
    required this.stateLabel,
    required this.enquiriesCount,
    required this.typesCount,
    required this.products,
    required this.services,
    required this.source,
  });

  factory OfferItem.fromJson(Map<String, dynamic> json) {
    return OfferItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),

      // ✅ NEW
      description: (json['description'] ?? '').toString(),
      availableFrom: _tryParseDate(json['availableFrom']),
      availableTo: _tryParseDate(json['availableTo']),
      announcementAt: _tryParseDate(json['announcementAt']),

      discountPercentage: _asNum(json['discountPercentage']),
      offerBadgeLabel: (json['offerBadgeLabel'] ?? '').toString(),

      createdAt: _tryParseDate(json['createdAt']),
      createdTime: (json['createdTime'] ?? '').toString(),
      expiresAt: (json['expiresAt'] ?? '').toString(),

      statusEnum: (json['statusEnum'] ?? '').toString(),
      stateLabel: (json['stateLabel'] ?? '').toString(),

      enquiriesCount: _asInt(json['enquiriesCount']),
      typesCount: json['typesCount'] == null
          ? OfferTypesCount.empty()
          : OfferTypesCount.fromJson(
              json['typesCount'] as Map<String, dynamic>,
            ),

      products: _asList(
        json['products'],
      ).map((e) => OfferProduct.fromJson(e as Map<String, dynamic>)).toList(),

      services: _asList(
        json['services'],
      ).map((e) => OfferService.fromJson(e as Map<String, dynamic>)).toList(),

      source: (json['source'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,

    // ✅ NEW
    'description': description,
    'availableFrom': availableFrom?.toIso8601String(),
    'availableTo': availableTo?.toIso8601String(),
    'announcementAt': announcementAt?.toIso8601String(),

    'discountPercentage': discountPercentage,
    'offerBadgeLabel': offerBadgeLabel,

    'createdAt': createdAt?.toIso8601String(),
    'createdTime': createdTime,
    'expiresAt': expiresAt,

    'statusEnum': statusEnum,
    'stateLabel': stateLabel,

    'enquiriesCount': enquiriesCount,
    'typesCount': typesCount.toJson(),

    'products': products.map((e) => e.toJson()).toList(),
    'services': services.map((e) => e.toJson()).toList(),

    'source': source,
  };
}

// class OfferItem {
//   final String id;
//   final String title;
//   final num discountPercentage;
//   final String offerBadgeLabel;
//
//   final DateTime? createdAt;
//   final String createdTime;
//   final String expiresAt;
//
//   final String statusEnum;
//   final String stateLabel;
//
//   final int enquiriesCount;
//   final OfferTypesCount typesCount;
//
//   final List<OfferProduct> products;
//   final List<OfferService> services;
//
//   final String source;
//
//   OfferItem({
//     required this.id,
//     required this.title,
//     required this.discountPercentage,
//     required this.offerBadgeLabel,
//     required this.createdAt,
//     required this.createdTime,
//     required this.expiresAt,
//     required this.statusEnum,
//     required this.stateLabel,
//     required this.enquiriesCount,
//     required this.typesCount,
//     required this.products,
//     required this.services,
//     required this.source,
//   });
//
//   factory OfferItem.fromJson(Map<String, dynamic> json) {
//     return OfferItem(
//       id: (json['id'] ?? '').toString(),
//       title: (json['title'] ?? '').toString(),
//       discountPercentage: _asNum(json['discountPercentage']),
//       offerBadgeLabel: (json['offerBadgeLabel'] ?? '').toString(),
//       createdAt: _tryParseDate(json['createdAt']),
//       createdTime: (json['createdTime'] ?? '').toString(),
//       expiresAt: (json['expiresAt'] ?? '').toString(),
//       statusEnum: (json['statusEnum'] ?? '').toString(),
//       stateLabel: (json['stateLabel'] ?? '').toString(),
//       enquiriesCount: _asInt(json['enquiriesCount']),
//       typesCount: json['typesCount'] == null
//           ? OfferTypesCount.empty()
//           : OfferTypesCount.fromJson(json['typesCount'] as Map<String, dynamic>),
//       products: _asList(json['products'])
//           .map((e) => OfferProduct.fromJson(e))
//           .toList(),
//       services: _asList(json['services'])
//           .map((e) => OfferService.fromJson(e))
//           .toList(),
//       source: (json['source'] ?? '').toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'discountPercentage': discountPercentage,
//     'offerBadgeLabel': offerBadgeLabel,
//     'createdAt': createdAt?.toIso8601String(),
//     'createdTime': createdTime,
//     'expiresAt': expiresAt,
//     'statusEnum': statusEnum,
//     'stateLabel': stateLabel,
//     'enquiriesCount': enquiriesCount,
//     'typesCount': typesCount.toJson(),
//     'products': products.map((e) => e.toJson()).toList(),
//     'services': services.map((e) => e.toJson()).toList(),
//     'source': source,
//   };
// }

class OfferTypesCount {
  final int products;
  final int services;
  final int total;

  OfferTypesCount({
    required this.products,
    required this.services,
    required this.total,
  });

  factory OfferTypesCount.empty() =>
      OfferTypesCount(products: 0, services: 0, total: 0);

  factory OfferTypesCount.fromJson(Map<String, dynamic> json) {
    return OfferTypesCount(
      products: _asInt(json['products']),
      services: _asInt(json['services']),
      total: _asInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'products': products,
    'services': services,
    'total': total,
  };
}

class OfferProduct {
  final String id;
  final String name;
  final num rating;
  final int reviewCount;
  final num price;
  final String offerValue;
  final num offerPrice;
  final String imageUrl;

  OfferProduct({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.offerValue,
    required this.offerPrice,
    required this.imageUrl,
  });

  factory OfferProduct.fromJson(Map<String, dynamic> json) {
    return OfferProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rating: _asNum(json['rating']),
      reviewCount: _asInt(json['reviewCount']),
      price: _asNum(json['price']),
      offerValue: (json['offerValue'] ?? '').toString(),
      offerPrice: _asNum(json['offerPrice']),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rating': rating,
    'reviewCount': reviewCount,
    'price': price,
    'offerValue': offerValue,
    'offerPrice': offerPrice,
    'imageUrl': imageUrl,
  };
}

// In your JSON services is [] now, but model is kept ready.
class OfferService {
  final String id;
  final String name;
  final num rating;
  final int reviewCount;
  final num price;
  final String offerValue;
  final num offerPrice;
  final String imageUrl;

  OfferService({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.offerValue,
    required this.offerPrice,
    required this.imageUrl,
  });

  factory OfferService.fromJson(Map<String, dynamic> json) {
    return OfferService(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rating: _asNum(json['rating']),
      reviewCount: _asInt(json['reviewCount']),
      price: _asNum(json['price']),
      offerValue: (json['offerValue'] ?? '').toString(),
      offerPrice: _asNum(json['offerPrice']),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rating': rating,
    'reviewCount': reviewCount,
    'price': price,
    'offerValue': offerValue,
    'offerPrice': offerPrice,
    'imageUrl': imageUrl,
  };
}

// ----------------- helpers -----------------

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

num _asNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

List<Map<String, dynamic>> _asList(dynamic v) {
  if (v is List) {
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return <Map<String, dynamic>>[];
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return DateTime.tryParse(s);
}

// class OfferModel {
//   final bool status;
//   final OffersGroupedData? data;
//
//   OfferModel({required this.status, this.data});
//
//   factory OfferModel.fromJson(Map<String, dynamic> json) {
//     return OfferModel(
//       status: json['status'] ?? false,
//       data: json['data'] != null
//           ? OffersGroupedData.fromJson(json['data'])
//           : null,
//     );
//   }
// }
//
// class OffersGroupedData {
//   final int liveCount;
//   final int expiredCount;
//   final List<OfferSection> sections;
//
//   OffersGroupedData({
//     required this.liveCount,
//     required this.expiredCount,
//     required this.sections,
//   });
//
//   factory OffersGroupedData.fromJson(Map<String, dynamic> json) {
//     return OffersGroupedData(
//       liveCount: (json['liveCount'] ?? 0) is int
//           ? json['liveCount']
//           : int.tryParse('${json['liveCount']}') ?? 0,
//       expiredCount: (json['expiredCount'] ?? 0) is int
//           ? json['expiredCount']
//           : int.tryParse('${json['expiredCount']}') ?? 0,
//       sections: (json['sections'] as List<dynamic>? ?? [])
//           .map((e) => OfferSection.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// class OfferSection {
//   final String dayLabel;
//   final List<OfferListItem> items;
//
//   OfferSection({required this.dayLabel, required this.items});
//
//   factory OfferSection.fromJson(Map<String, dynamic> json) {
//     return OfferSection(
//       dayLabel: json['dayLabel'] ?? '',
//       items: (json['items'] as List<dynamic>? ?? [])
//           .map((e) => OfferListItem.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
// class OfferListItem {
//   final String id;
//   final String title;
//
//   final int discountPercentage;
//   final String offerBadgeLabel;
//
//   final String? createdAt;
//   final String? createdTime;
//   final String? expiresAt;
//
//   final String statusEnum;
//   final String stateLabel;
//
//   final int enquiriesCount;
//   final OfferTypesCount typesCount;
//
//   final List<OfferProductItem> products;
//   final List<OfferServiceItem> services;
//
//   final String source;
//
//   const OfferListItem({
//     required this.id,
//     required this.title,
//     required this.discountPercentage,
//     required this.offerBadgeLabel,
//     this.createdAt,
//     this.createdTime,
//     this.expiresAt,
//     required this.statusEnum,
//     required this.stateLabel,
//     required this.enquiriesCount,
//     required this.typesCount,
//     required this.products,
//     required this.services,
//     required this.source,
//   });
//
//   factory OfferListItem.fromJson(Map<String, dynamic> json) {
//     int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
//
//     return OfferListItem(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       discountPercentage: _toInt(json['discountPercentage']),
//       offerBadgeLabel: json['offerBadgeLabel'] ?? '',
//       createdAt: json['createdAt'],
//       createdTime: json['createdTime'],
//       expiresAt: json['expiresAt'],
//       statusEnum: json['statusEnum'] ?? '',
//       stateLabel: json['stateLabel'] ?? '',
//       enquiriesCount: _toInt(json['enquiriesCount']),
//       typesCount:
//       OfferTypesCount.fromJson(json['typesCount'] ?? {}),
//       products: (json['products'] as List<dynamic>? ?? [])
//           .map((e) => OfferProductItem.fromJson(e))
//           .toList(),
//       services: (json['services'] as List<dynamic>? ?? [])
//           .map((e) => OfferServiceItem.fromJson(e))
//           .toList(),
//       source: json['source'] ?? '',
//     );
//   }
// }
//
//
//
// // class OfferListItem {
// //   final String id;
// //   final String title;
// //
// //   /// You can keep as String since API returns ISO string (ex: 2025-12-12T15:34:24.323Z)
// //   final String? createdAt;
// //
// //   /// ex: "9:04pm"
// //   final String? createdTime;
// //
// //   /// ex: "19 Dec 25"
// //   final String? expiresAt;
// //
// //   /// ex: "ACTIVE", "DRAFT"
// //   final String statusEnum;
// //
// //   /// ex: "LIVE", "UPCOMING", "EXPIRED"
// //   final String stateLabel;
// //
// //   final int enquiriesCount;
// //   final OfferTypesCount typesCount;
// //
// //   final List<OfferProductItem> products;
// //   final List<OfferServiceItem> services;
// //
// //   OfferListItem({
// //     required this.id,
// //     required this.title,
// //     this.createdAt,
// //     this.createdTime,
// //     this.expiresAt,
// //     required this.statusEnum,
// //     required this.stateLabel,
// //     required this.enquiriesCount,
// //     required this.typesCount,
// //     required this.products,
// //     required this.services,
// //   });
// //
// //   factory OfferListItem.fromJson(Map<String, dynamic> json) {
// //     return OfferListItem(
// //       id: json['id'] ?? '',
// //       title: json['title'] ?? '',
// //       createdAt: json['createdAt'],
// //       createdTime: json['createdTime'],
// //       expiresAt: json['expiresAt'],
// //       statusEnum: json['statusEnum'] ?? '',
// //       stateLabel: json['stateLabel'] ?? '',
// //       enquiriesCount: (json['enquiriesCount'] ?? 0) is int
// //           ? json['enquiriesCount']
// //           : int.tryParse('${json['enquiriesCount']}') ?? 0,
// //       typesCount: OfferTypesCount.fromJson(
// //         json['typesCount'] as Map<String, dynamic>? ?? {},
// //       ),
// //       products: (json['products'] as List<dynamic>? ?? [])
// //           .map((e) => OfferProductItem.fromJson(e as Map<String, dynamic>))
// //           .toList(),
// //       services: (json['services'] as List<dynamic>? ?? [])
// //           .map((e) => OfferServiceItem.fromJson(e as Map<String, dynamic>))
// //           .toList(),
// //     );
// //   }
// // }
//
// class OfferTypesCount {
//   final int products;
//   final int services;
//   final int total;
//
//   OfferTypesCount({
//     required this.products,
//     required this.services,
//     required this.total,
//   });
//
//   factory OfferTypesCount.fromJson(Map<String, dynamic> json) {
//     int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
//
//     return OfferTypesCount(
//       products: _toInt(json['products']),
//       services: _toInt(json['services']),
//       total: _toInt(json['total']),
//     );
//   }
// }
//
// class OfferProductItem {
//   final String id;
//   final String name;
//   final double? rating;
//   final int reviewCount;
//   final double price;
//
//   final String? offerLabel; // ex: "chfyd"
//   final String? offerValue; // ex: "6%"
//   final double? offerPrice;
//
//   final String? imageUrl;
//
//   OfferProductItem({
//     required this.id,
//     required this.name,
//     this.rating,
//     required this.reviewCount,
//     required this.price,
//
//     this.offerLabel,
//     this.offerValue,
//     this.offerPrice,
//     this.imageUrl,
//   });
//
//   factory OfferProductItem.fromJson(Map<String, dynamic> json) {
//     double? _toDoubleNullable(dynamic v) {
//       if (v == null) return null;
//       if (v is num) return v.toDouble();
//       return double.tryParse('$v');
//     }
//
//     int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
//
//     double _toDouble(dynamic v) {
//       if (v == null) return 0.0;
//       if (v is num) return v.toDouble();
//       return double.tryParse('$v') ?? 0.0;
//     }
//
//     return OfferProductItem(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       rating: _toDoubleNullable(json['rating']),
//       reviewCount: _toInt(json['reviewCount']),
//       price: _toDouble(json['price']),
//
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       offerPrice: _toDoubleNullable(json['offerPrice']),
//       imageUrl: json['imageUrl'],
//     );
//   }
// }
//
// class OfferServiceItem {
//   /// Your sample shows `services: []`, so keep it flexible
//   final String id;
//   final String name;
//   final double? rating;
//   final int reviewCount;
//   final double price;
//
//   final String? offerLabel; // ex: "chfyd"
//   final String? offerValue; // ex: "6%"
//   final double? offerPrice;
//
//   final String? imageUrl;
//
//   OfferServiceItem({
//     required this.id,
//     required this.name,
//     this.rating,
//     required this.reviewCount,
//     required this.price,
//
//     this.offerLabel,
//     this.offerValue,
//     this.offerPrice,
//     this.imageUrl,
//   });
//
//   factory OfferServiceItem.fromJson(Map<String, dynamic> json) {
//     double? _toDoubleNullable(dynamic v) {
//       if (v == null) return null;
//       if (v is num) return v.toDouble();
//       return double.tryParse('$v');
//     }
//
//     int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
//
//     double _toDouble(dynamic v) {
//       if (v == null) return 0.0;
//       if (v is num) return v.toDouble();
//       return double.tryParse('$v') ?? 0.0;
//     }
//     return OfferServiceItem(      id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       rating: _toDoubleNullable(json['rating']),
//       reviewCount: _toInt(json['reviewCount']),
//       price: _toDouble(json['price']),
//
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       offerPrice: _toDoubleNullable(json['offerPrice']),
//       imageUrl: json['imageUrl'],);
//   }
// }
