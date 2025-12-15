class OfferModel {
  final bool status;
  final OffersGroupedData? data;

  OfferModel({required this.status, this.data});

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? OffersGroupedData.fromJson(json['data'])
          : null,
    );
  }
}

class OffersGroupedData {
  final int liveCount;
  final int expiredCount;
  final List<OfferSection> sections;

  OffersGroupedData({
    required this.liveCount,
    required this.expiredCount,
    required this.sections,
  });

  factory OffersGroupedData.fromJson(Map<String, dynamic> json) {
    return OffersGroupedData(
      liveCount: (json['liveCount'] ?? 0) is int
          ? json['liveCount']
          : int.tryParse('${json['liveCount']}') ?? 0,
      expiredCount: (json['expiredCount'] ?? 0) is int
          ? json['expiredCount']
          : int.tryParse('${json['expiredCount']}') ?? 0,
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => OfferSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OfferSection {
  final String dayLabel;
  final List<OfferListItem> items;

  OfferSection({required this.dayLabel, required this.items});

  factory OfferSection.fromJson(Map<String, dynamic> json) {
    return OfferSection(
      dayLabel: json['dayLabel'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OfferListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OfferListItem {
  final String id;
  final String title;

  /// You can keep as String since API returns ISO string (ex: 2025-12-12T15:34:24.323Z)
  final String? createdAt;

  /// ex: "9:04pm"
  final String? createdTime;

  /// ex: "19 Dec 25"
  final String? expiresAt;

  /// ex: "ACTIVE", "DRAFT"
  final String statusEnum;

  /// ex: "LIVE", "UPCOMING", "EXPIRED"
  final String stateLabel;

  final int enquiriesCount;
  final OfferTypesCount typesCount;

  final List<OfferProductItem> products;
  final List<OfferServiceItem> services;

  OfferListItem({
    required this.id,
    required this.title,
    this.createdAt,
    this.createdTime,
    this.expiresAt,
    required this.statusEnum,
    required this.stateLabel,
    required this.enquiriesCount,
    required this.typesCount,
    required this.products,
    required this.services,
  });

  factory OfferListItem.fromJson(Map<String, dynamic> json) {
    return OfferListItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      createdAt: json['createdAt'],
      createdTime: json['createdTime'],
      expiresAt: json['expiresAt'],
      statusEnum: json['statusEnum'] ?? '',
      stateLabel: json['stateLabel'] ?? '',
      enquiriesCount: (json['enquiriesCount'] ?? 0) is int
          ? json['enquiriesCount']
          : int.tryParse('${json['enquiriesCount']}') ?? 0,
      typesCount: OfferTypesCount.fromJson(
        json['typesCount'] as Map<String, dynamic>? ?? {},
      ),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => OfferProductItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => OfferServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
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

  factory OfferTypesCount.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return OfferTypesCount(
      products: _toInt(json['products']),
      services: _toInt(json['services']),
      total: _toInt(json['total']),
    );
  }
}

class OfferProductItem {
  final String id;
  final String name;
  final double? rating;
  final int reviewCount;
  final double price;
  final double? mrp;

  final String? offerLabel; // ex: "chfyd"
  final String? offerValue; // ex: "6%"
  final double? offerPrice;

  final String? imageUrl;

  OfferProductItem({
    required this.id,
    required this.name,
    this.rating,
    required this.reviewCount,
    required this.price,
    this.mrp,
    this.offerLabel,
    this.offerValue,
    this.offerPrice,
    this.imageUrl,
  });

  factory OfferProductItem.fromJson(Map<String, dynamic> json) {
    double? _toDoubleNullable(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0.0;
    }

    return OfferProductItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rating: _toDoubleNullable(json['rating']),
      reviewCount: _toInt(json['reviewCount']),
      price: _toDouble(json['price']),
      mrp: _toDoubleNullable(json['mrp']),
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      offerPrice: _toDoubleNullable(json['offerPrice']),
      imageUrl: json['imageUrl'],
    );
  }
}

class OfferServiceItem {
  /// Your sample shows `services: []`, so keep it flexible
  final Map<String, dynamic> raw;

  OfferServiceItem({required this.raw});

  factory OfferServiceItem.fromJson(Map<String, dynamic> json) {
    return OfferServiceItem(raw: json);
  }
}
