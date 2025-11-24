class ServiceListResponse {
  final bool status;
  final ServiceData data;

  ServiceListResponse({required this.status, required this.data});

  factory ServiceListResponse.fromJson(Map<String, dynamic> json) {
    return ServiceListResponse(
      status: json['status'] as bool,
      data: ServiceData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class ServiceData {
  final String id;
  final String shopId;
  final String category;
  final String subCategory;
  final String englishName;
  final String tamilName;
  final int startsAt;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final List<String> keywords;
  final int durationMinutes;
  final String status;
  final double rating;
  final int ratingCount;
  final List<ServiceFeature> features;
  final List<ServiceMedia> media;

  ServiceData({
    required this.id,
    required this.shopId,
    required this.category,
    required this.subCategory,
    required this.englishName,
    required this.tamilName,
    required this.startsAt,
    this.offerLabel,
    this.offerValue,
    this.description,
    required this.keywords,
    required this.durationMinutes,
    required this.status,
    required this.rating,
    required this.ratingCount,
    required this.features,
    required this.media,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
      englishName: json['englishName'] as String,
      tamilName: json['tamilName'] as String,
      startsAt: (json['startsAt'] as num).toInt(),
      offerLabel: json['offerLabel'] as String?,
      offerValue: json['offerValue'] as String?,
      description: json['description'] as String?,
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      status: json['status'] as String,
      rating: (json['rating'] as num).toDouble(),
      ratingCount: (json['ratingCount'] as num).toInt(),
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => ServiceFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => ServiceMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'category': category,
      'subCategory': subCategory,
      'englishName': englishName,
      'tamilName': tamilName,
      'startsAt': startsAt,
      'offerLabel': offerLabel,
      'offerValue': offerValue,
      'description': description,
      'keywords': keywords,
      'durationMinutes': durationMinutes,
      'status': status,
      'rating': rating,
      'ratingCount': ratingCount,
      'features': features.map((e) => e.toJson()).toList(),
      'media': media.map((e) => e.toJson()).toList(),
    };
  }
}

class ServiceFeature {
  final String id;
  final String label;
  final String value;
  final String language;

  ServiceFeature({
    required this.id,
    required this.label,
    required this.value,
    required this.language,
  });

  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(
      id: json['id'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'value': value, 'language': language};
  }
}

class ServiceMedia {
  final String id;
  final String url;
  final int displayOrder;

  ServiceMedia({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory ServiceMedia.fromJson(Map<String, dynamic> json) {
    return ServiceMedia(
      id: json['id'] as String,
      url: json['url'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'displayOrder': displayOrder};
  }
}
