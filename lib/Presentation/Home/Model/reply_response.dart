class ReplyResponse {
  final bool status;
  final ReplyData? data;

  const ReplyResponse({required this.status, required this.data});

  factory ReplyResponse.fromJson(Map<String, dynamic> json) {
    return ReplyResponse(
      status: json['status'] == true,
      data: json['data'] == null
          ? null
          : ReplyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

class ReplyData {
  final String id;
  final String title;
  final String description;
  final String message;
  final num price; // num supports int/double safely
  final List<String> images;
  final String contactPhone;
  final DateTime? repliedAt;
  final Shop shop;

  const ReplyData({
    required this.id,
    required this.title,
    required this.description,
    required this.message,
    required this.price,
    required this.images,
    required this.contactPhone,
    required this.repliedAt,
    required this.shop,
  });

  factory ReplyData.fromJson(Map<String, dynamic> json) {
    return ReplyData(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      price: (json['price'] ?? 0) as num,
      images:
          (json['images'] as List?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
      contactPhone: (json['contactPhone'] ?? '') as String,
      repliedAt: _tryParseDateTime(json['repliedAt']),
      shop: Shop.fromJson((json['shop'] ?? const {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'message': message,
    'price': price,
    'images': images,
    'contactPhone': contactPhone,
    'repliedAt': repliedAt?.toUtc().toIso8601String(),
    'shop': shop.toJson(),
  };

  static DateTime? _tryParseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String && v.trim().isNotEmpty) {
      return DateTime.tryParse(v);
    }
    return null;
  }
}

class Shop {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String alternatePhone;

  final String? imageUrl;
  final num averageRating;
  final int reviewCount;
  final bool isTrusted;

  final num? distanceKm;
  final bool? openNow;
  final String? openLabel;

  const Shop({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.alternatePhone,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.isTrusted,
    required this.distanceKm,
    required this.openNow,
    required this.openLabel,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      alternatePhone: (json['alternatePhone'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
      averageRating: (json['averageRating'] ?? 0) as num,
      reviewCount: ((json['reviewCount'] ?? 0) as num).toInt(),
      isTrusted: json['isTrusted'] == true,
      distanceKm: json['distanceKm'] as num?,
      openNow: json['openNow'] as bool?,
      openLabel: json['openLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'address': address,
    'phone': phone,
    'alternatePhone': alternatePhone,
    'imageUrl': imageUrl,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'isTrusted': isTrusted,
    'distanceKm': distanceKm,
    'openNow': openNow,
    'openLabel': openLabel,
  };
}
