class  OtpResponse  {
  final bool status;
  final int code;
  final OtpData? data;

  OtpResponse({
    required this.status,
    required this.code,
    this.data,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      data: json['data'] != null ? OtpData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'data': data?.toJson(),
    };
  }
}

class OtpData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String sessionToken;
  final bool isNewOwner;
  /// Backend may return either `onboardingStep` or `onboardingStatus`.
  /// Example values: step-1, step-2, step-3, step-4
  final String? onboardingStep;

  final String? scopedShopId;
  final bool? isReferralApplied;
  final bool? vendorApproved;

  OtpData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.sessionToken,
    required this.isNewOwner,
    this.onboardingStep,
    this.scopedShopId,
    this.isReferralApplied,
    this.vendorApproved,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      role: json['role'] ?? '',
      sessionToken: json['sessionToken'] ?? '',
      isNewOwner: json['isNewOwner'] == true,
      onboardingStep:
          (json['onboardingStep'] ?? json['onboardingStatus'])?.toString(),
      scopedShopId: json['scopedShopId']?.toString(),
      isReferralApplied: json['isReferralApplied'] is bool
          ? json['isReferralApplied'] as bool
          : null,
      vendorApproved: json['vendorApproved'] is bool
          ? json['vendorApproved'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'role': role,
      'sessionToken': sessionToken,
      'isNewOwner': isNewOwner,
      'onboardingStep': onboardingStep,
      'scopedShopId': scopedShopId,
      'isReferralApplied': isReferralApplied,
      'vendorApproved': vendorApproved,
    };
  }
}
