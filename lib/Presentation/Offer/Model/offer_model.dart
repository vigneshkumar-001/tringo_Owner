// offer_sections_response.dart

import 'package:intl/intl.dart';

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

// ✅ UPDATED: supports "2026-02-04" and "04-02-2026"
DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;

  final s = v.toString().trim();
  if (s.isEmpty) return null;

  // 1) ISO parse (handles Z, milliseconds, etc.)
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso.toLocal(); // ✅ important

  // 2) yyyy-MM-dd
  try {
    final d1 = DateFormat('yyyy-MM-dd').parseStrict(s);
    return DateTime(d1.year, d1.month, d1.day);
  } catch (_) {}

  // 3) dd-MM-yyyy
  try {
    final d2 = DateFormat('dd-MM-yyyy').parseStrict(s);
    return DateTime(d2.year, d2.month, d2.day);
  } catch (_) {}

  return null;
}


