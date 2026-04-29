class CcAvenueInitResponse {
  final bool status;
  final CcAvenueInitData? data;

  const CcAvenueInitResponse({required this.status, this.data});

  factory CcAvenueInitResponse.fromJson(Map<String, dynamic> json) {
    return CcAvenueInitResponse(
      status: json['status'] == true,
      data: (json['data'] is Map)
          ? CcAvenueInitData.fromJson((json['data'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

class CcAvenueInitData {
  final String provider;
  final String orderId;
  final String amount;
  final String currency;
  final String mode;
  final String merchantId;
  final String accessCode;
  final String gatewayUrl;
  final String redirectUrl;
  final String cancelUrl;
  final String encRequest;
  final CcAvenueHostedForm form;
  final String planId;
  final String? businessProfileId;
  final String? shopId;

  const CcAvenueInitData({
    required this.provider,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.mode,
    required this.merchantId,
    required this.accessCode,
    required this.gatewayUrl,
    required this.redirectUrl,
    required this.cancelUrl,
    required this.encRequest,
    required this.form,
    required this.planId,
    this.businessProfileId,
    this.shopId,
  });

  factory CcAvenueInitData.fromJson(Map<String, dynamic> json) {
    return CcAvenueInitData(
      provider: (json['provider'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      mode: (json['mode'] ?? '').toString(),
      merchantId: (json['merchantId'] ?? '').toString(),
      accessCode: (json['accessCode'] ?? '').toString(),
      gatewayUrl: (json['gatewayUrl'] ?? '').toString(),
      redirectUrl: (json['redirectUrl'] ?? '').toString(),
      cancelUrl: (json['cancelUrl'] ?? '').toString(),
      encRequest: (json['encRequest'] ?? '').toString(),
      form: CcAvenueHostedForm.fromJson(
        (json['form'] is Map) ? (json['form'] as Map).cast<String, dynamic>() : const <String, dynamic>{},
      ),
      planId: (json['planId'] ?? '').toString(),
      businessProfileId: json['businessProfileId']?.toString(),
      shopId: json['shopId']?.toString(),
    );
  }
}

class CcAvenueHostedForm {
  final String action;
  final String method;
  final CcAvenueHostedFormFields fields;

  const CcAvenueHostedForm({
    required this.action,
    required this.method,
    required this.fields,
  });

  factory CcAvenueHostedForm.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    final map = (rawFields is Map)
        ? rawFields.cast<String, dynamic>()
        : const <String, dynamic>{};

    return CcAvenueHostedForm(
      action: (json['action'] ?? '').toString(),
      method: (json['method'] ?? 'POST').toString(),
      fields: CcAvenueHostedFormFields.fromJson(map),
    );
  }
}

class CcAvenueHostedFormFields {
  final String encRequest;
  final String accessCode;

  const CcAvenueHostedFormFields({
    required this.encRequest,
    required this.accessCode,
  });

  factory CcAvenueHostedFormFields.fromJson(Map<String, dynamic> json) {
    return CcAvenueHostedFormFields(
      encRequest: (json['encRequest'] ?? '').toString(),
      accessCode: (json['access_code'] ?? '').toString(),
    );
  }
}

