class BusinessProfileResponse {
  final bool status;
  final BusinessProfileData? data;

  const BusinessProfileResponse({required this.status, this.data});

  factory BusinessProfileResponse.fromJson(Map<String, dynamic> json) {
    return BusinessProfileResponse(
      status: json['status'] == true,
      data:
          json['data'] is Map ? BusinessProfileData.fromJson(json['data']) : null,
    );
  }
}

class BusinessProfileData {
  final String? businessType;
  final String? ownershipType;
  final String? onboardingStep;
  final bool isOnboardingComplete;
  final String? resumeShopId;
  final String? resumeShopStatus;
  final Map<String, dynamic>? ownerInfo;
  final Map<String, dynamic>? shopInfo;

  const BusinessProfileData({
    this.businessType,
    this.ownershipType,
    this.onboardingStep,
    required this.isOnboardingComplete,
    this.resumeShopId,
    this.resumeShopStatus,
    this.ownerInfo,
    this.shopInfo,
  });

  factory BusinessProfileData.fromJson(Map<String, dynamic> json) {
    return BusinessProfileData(
      businessType: json['businessType']?.toString(),
      ownershipType: json['ownershipType']?.toString(),
      onboardingStep: json['onboardingStep']?.toString(),
      isOnboardingComplete: json['isOnboardingComplete'] == true,
      resumeShopId: json['resumeShopId']?.toString(),
      resumeShopStatus: json['resumeShopStatus']?.toString(),
      ownerInfo: json['ownerInfo'] is Map
          ? (json['ownerInfo'] as Map)
              .map((k, v) => MapEntry(k.toString(), v))
          : null,
      shopInfo: json['shopInfo'] is Map
          ? (json['shopInfo'] as Map).map((k, v) => MapEntry(k.toString(), v))
          : null,
    );
  }
}
