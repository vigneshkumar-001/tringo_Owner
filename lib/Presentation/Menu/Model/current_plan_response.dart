import 'plan_list_response.dart';

class CurrentPlanResponse {
  final bool status;
  final String message;
  final CurrentPlanData? data;

  CurrentPlanResponse({required this.status, required this.message, this.data});

  factory CurrentPlanResponse.fromJson(Map<String, dynamic> json) {
    return CurrentPlanResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CurrentPlanData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class CurrentPlanData {
  final String subscriptionId;
  final String businessProfileId;
  final bool isFreemium;
  final String status;
  final Plan plan;
  final dynamic payment; // can update if you have payment model
  final Period period;
  final Invoice? invoice;

  CurrentPlanData({
    required this.subscriptionId,
    required this.businessProfileId,
    required this.isFreemium,
    required this.status,
    required this.plan,
    this.payment,
    required this.period,
    this.invoice,
  });

  factory CurrentPlanData.fromJson(Map<String, dynamic> json) {
    return CurrentPlanData(
      subscriptionId: json['subscriptionId'] ?? '',
      businessProfileId: json['businessProfileId'] ?? '',
      isFreemium: json['isFreemium'] ?? false,
      status: json['status'] ?? '',
      plan: Plan.fromJson(json['plan']),
      payment: json['payment'],
      period: Period.fromJson(json['period']),
      invoice: json['invoice'] != null
          ? Invoice.fromJson(json['invoice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'subscriptionId': subscriptionId,
    'businessProfileId': businessProfileId,
    'isFreemium': isFreemium,
    'status': status,
    'plan': plan.toJson(),
    'payment': payment,
    'period': period.toJson(),
    'invoice': invoice?.toJson(),
  };
  @override
  String toString() => toJson().toString();
}

class Invoice {
  final String? url;
  final String? downloadUrl;
  final String? fileName;
  final String? expiresAt;

  const Invoice({this.url, this.downloadUrl, this.fileName, this.expiresAt});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      url: json['url'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      fileName: json['fileName'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'downloadUrl': downloadUrl,
    'fileName': fileName,
    'expiresAt': expiresAt,
  };
}

class Plan {
  final String id;
  final String title;
  final String planCategory;
  final String type;
  final int durationDays;
  final String durationLabel;
  final int price;
  final List<PlanFeature> features;

  Plan({
    required this.id,
    required this.title,
    required this.planCategory,
    required this.type,
    required this.durationDays,
    required this.durationLabel,
    required this.price,
    required this.features,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
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

    return Plan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      planCategory: json['planCategory'] ?? '',
      type: json['type'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      durationLabel: json['durationLabel'] ?? '',
      price: json['price'] ?? 0,
      features: parsedFeatures,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'planCategory': planCategory,
    'type': type,
    'durationDays': durationDays,
    'durationLabel': durationLabel,
    'price': price,
    'features': features,
  };
}

class Period {
  final String startsAt;
  final String endsAt;
  final String startsAtLabel;
  final String endsAtLabel;
  final int daysLeft;
  final int durationDays;

  Period({
    required this.startsAt,
    required this.endsAt,
    required this.startsAtLabel,
    required this.endsAtLabel,
    required this.daysLeft,
    required this.durationDays,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      startsAt: json['startsAt'] ?? '',
      endsAt: json['endsAt'] ?? '',
      startsAtLabel: json['startsAtLabel'] ?? '',
      endsAtLabel: json['endsAtLabel'] ?? '',
      daysLeft: json['daysLeft'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'startsAt': startsAt,
    'endsAt': endsAt,
    'startsAtLabel': startsAtLabel,
    'endsAtLabel': endsAtLabel,
    'daysLeft': daysLeft,
    'durationDays': durationDays,
  };
  @override
  String toString() => toJson().toString();
}
