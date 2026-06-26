class PlanListResponse {
  final bool status;
  final List<PlanModel> data;

  PlanListResponse({required this.status, required this.data});

  factory PlanListResponse.fromJson(Map<String, dynamic> json) {
    return PlanListResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => PlanModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class PlanModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String type;
  final String price;
  final int durationDays;
  final bool isBestValue;
  final String color;
  final List<PlanFeature> features;

  PlanModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.isBestValue,
    required this.color,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = (v ?? '').toString().trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    final rawFeatures = json['features'];

    final List<PlanFeature> parsedFeatures = <PlanFeature>[];
    if (rawFeatures is List) {
      for (var i = 0; i < rawFeatures.length; i++) {
        final e = rawFeatures[i];
        if (e is Map) {
          parsedFeatures.add(PlanFeature.fromJson(e.cast<String, dynamic>()));
        } else {
          parsedFeatures.add(
            PlanFeature(
              key: '',
              label: e.toString(),
              free: true,
              premium: true,
              sort: i + 1,
            ),
          );
        }
      }
    }

    return PlanModel(
      id: (json['id'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      price: (json['price'] ?? '0').toString(),
      durationDays: (json['durationDays'] is int)
          ? (json['durationDays'] as int)
          : int.tryParse((json['durationDays'] ?? '0').toString()) ?? 0,
      isBestValue:
          parseBool(json['isBestValue']) ||
          parseBool(json['is_best_value']) ||
          parseBool(json['bestValue']) ||
          parseBool(json['isBestvalue']),
      color: (json['color'] ?? '').toString(),
      features: parsedFeatures,
    );
  }
}

class PlanFeature {
  final String key;
  final String label;
  final bool free;
  final bool premium;
  final int sort;

  const PlanFeature({
    required this.key,
    required this.label,
    required this.free,
    required this.premium,
    required this.sort,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    return PlanFeature(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      free: json['free'] == true,
      premium: json['premium'] == true,
      sort: (json['sort'] is int)
          ? (json['sort'] as int)
          : int.tryParse((json['sort'] ?? '0').toString()) ?? 0,
    );
  }
}
