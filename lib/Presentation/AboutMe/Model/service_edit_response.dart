class ServiceEditResponse {
  final bool status;
  final ServiceData data;

  const ServiceEditResponse({required this.status, required this.data});

  factory ServiceEditResponse.fromJson(Map<String, dynamic> json) {
    return ServiceEditResponse(
      status: json['status'] ?? false,
      data: ServiceData.fromJson(json['data'] ?? <String, dynamic>{}),
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
  final String offerLabel;
  final String offerValue;
  final String description;
  final List<String> keywords;
  final int durationMinutes;
  final String status;
  final double rating;
  final int ratingCount;
  final List<ServiceFeature> features;
  final List<ServiceMedia> media;

  const ServiceData({
    required this.id,
    required this.shopId,
    required this.category,
    required this.subCategory,
    required this.englishName,
    required this.tamilName,
    required this.startsAt,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.keywords,
    required this.durationMinutes,
    required this.status,
    required this.rating,
    required this.ratingCount,
    required this.features,
    required this.media,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    final num? ratingNum = json['rating'] as num?;
    final int? ratingCountNum = json['ratingCount'] as int?;
    final int? startsAtNum = json['startsAt'] is num
        ? (json['startsAt'] as num).toInt()
        : json['startsAt'];
    final int? durationNum = json['durationMinutes'] is num
        ? (json['durationMinutes'] as num).toInt()
        : json['durationMinutes'];

    return ServiceData(
      id: json['id']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      tamilName: json['tamilName']?.toString() ?? '',
      startsAt: startsAtNum ?? 0,
      offerLabel: json['offerLabel']?.toString() ?? '',
      offerValue: json['offerValue']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      durationMinutes: durationNum ?? 0,
      status: json['status']?.toString() ?? '',
      rating: ratingNum?.toDouble() ?? 0.0,
      ratingCount: ratingCountNum ?? 0,
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => ServiceFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <ServiceFeature>[],
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => ServiceMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <ServiceMedia>[],
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

  const ServiceFeature({
    required this.id,
    required this.label,
    required this.value,
    required this.language,
  });

  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
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

  const ServiceMedia({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory ServiceMedia.fromJson(Map<String, dynamic> json) {
    final int? displayOrderNum = json['displayOrder'] is num
        ? (json['displayOrder'] as num).toInt()
        : json['displayOrder'];

    return ServiceMedia(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      displayOrder: displayOrderNum ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'displayOrder': displayOrder};
  }
}
