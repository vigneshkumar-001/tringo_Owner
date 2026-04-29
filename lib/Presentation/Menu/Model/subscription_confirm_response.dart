class SubscriptionConfirmResponse {
  final bool status;
  final String message;
  final SubscriptionConfirmData? data;
  final String? paymentStatus;
  final String? orderId;
  final String? orderStatusLabel;
  final String? referenceNo;

  const SubscriptionConfirmResponse({
    required this.status,
    required this.message,
    this.data,
    this.paymentStatus,
    this.orderId,
    this.orderStatusLabel,
    this.referenceNo,
  });

  factory SubscriptionConfirmResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionConfirmResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: (json['data'] is Map)
          ? SubscriptionConfirmData.fromJson(
              (json['data'] as Map).cast<String, dynamic>(),
            )
          : null,
      paymentStatus: json['paymentStatus']?.toString(),
      orderId: json['orderId']?.toString(),
      orderStatusLabel: json['orderStatusLabel']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
    );
  }
}

class SubscriptionConfirmData {
  final String? subscriptionId;
  final String businessProfileId;
  final bool? isFreemium;
  final String? status;
  final SubscriptionPlan? plan;
  final SubscriptionPayment? payment;
  final SubscriptionPeriod? period;
  final String? orderStatus;

  const SubscriptionConfirmData({
    this.subscriptionId,
    required this.businessProfileId,
    this.isFreemium,
    this.status,
    this.plan,
    this.payment,
    this.period,
    this.orderStatus,
  });

  factory SubscriptionConfirmData.fromJson(Map<String, dynamic> json) {
    return SubscriptionConfirmData(
      subscriptionId: json['subscriptionId']?.toString(),
      businessProfileId: (json['businessProfileId'] ?? '').toString(),
      isFreemium: (json['isFreemium'] is bool) ? json['isFreemium'] as bool : null,
      status: json['status']?.toString(),
      plan: (json['plan'] is Map)
          ? SubscriptionPlan.fromJson((json['plan'] as Map).cast<String, dynamic>())
          : null,
      payment: (json['payment'] is Map)
          ? SubscriptionPayment.fromJson(
              (json['payment'] as Map).cast<String, dynamic>(),
            )
          : null,
      period: (json['period'] is Map)
          ? SubscriptionPeriod.fromJson((json['period'] as Map).cast<String, dynamic>())
          : null,
      orderStatus: json['orderStatus']?.toString(),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String title;
  final String? planCategory;
  final String type;
  final int? durationDays;
  final String durationLabel;
  final int price;
  final List<dynamic> features;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    this.planCategory,
    required this.type,
    this.durationDays,
    required this.durationLabel,
    required this.price,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      planCategory: json['planCategory']?.toString(),
      type: (json['type'] ?? '').toString(),
      durationDays: (json['durationDays'] is int)
          ? json['durationDays'] as int
          : int.tryParse((json['durationDays'] ?? '').toString()),
      durationLabel: (json['durationLabel'] ?? '').toString(),
      price: (json['price'] is int)
          ? json['price'] as int
          : int.tryParse((json['price'] ?? '0').toString()) ?? 0,
      features: (json['features'] is List) ? json['features'] as List : const [],
    );
  }
}

class SubscriptionPayment {
  final String provider;
  final int? paidAmount;
  final String currency;
  final String? orderId;
  final String? paymentId;
  final String? txId;
  final String status;
  final String? paidAt;

  const SubscriptionPayment({
    required this.provider,
    this.paidAmount,
    required this.currency,
    this.orderId,
    this.paymentId,
    this.txId,
    required this.status,
    this.paidAt,
  });

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      provider: (json['provider'] ?? '').toString(),
      paidAmount: (json['paidAmount'] is int)
          ? json['paidAmount'] as int
          : int.tryParse((json['paidAmount'] ?? '').toString()),
      currency: (json['currency'] ?? '').toString(),
      orderId: json['orderId']?.toString(),
      paymentId: json['paymentId']?.toString(),
      txId: json['txId']?.toString(),
      status: (json['status'] ?? '').toString(),
      paidAt: json['paidAt']?.toString(),
    );
  }
}

class SubscriptionPeriod {
  final String? startsAt;
  final String? endsAt;
  final String? startsAtLabel;
  final String? endsAtLabel;
  final int? daysLeft;
  final int? durationDays;

  const SubscriptionPeriod({
    this.startsAt,
    this.endsAt,
    this.startsAtLabel,
    this.endsAtLabel,
    this.daysLeft,
    this.durationDays,
  });

  factory SubscriptionPeriod.fromJson(Map<String, dynamic> json) {
    return SubscriptionPeriod(
      startsAt: json['startsAt']?.toString(),
      endsAt: json['endsAt']?.toString(),
      startsAtLabel: json['startsAtLabel']?.toString(),
      endsAtLabel: json['endsAtLabel']?.toString(),
      daysLeft: (json['daysLeft'] is int)
          ? json['daysLeft'] as int
          : int.tryParse((json['daysLeft'] ?? '').toString()),
      durationDays: (json['durationDays'] is int)
          ? json['durationDays'] as int
          : int.tryParse((json['durationDays'] ?? '').toString()),
    );
  }
}

