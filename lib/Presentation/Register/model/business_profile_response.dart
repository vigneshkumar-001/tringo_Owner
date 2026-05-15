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

  const BusinessProfileData({
    this.businessType,
    this.ownershipType,
    this.onboardingStep,
    required this.isOnboardingComplete,
    this.resumeShopId,
    this.resumeShopStatus,
  });

  factory BusinessProfileData.fromJson(Map<String, dynamic> json) {
    return BusinessProfileData(
      businessType: json['businessType']?.toString(),
      ownershipType: json['ownershipType']?.toString(),
      onboardingStep: json['onboardingStep']?.toString(),
      isOnboardingComplete: json['isOnboardingComplete'] == true,
      resumeShopId: json['resumeShopId']?.toString(),
      resumeShopStatus: json['resumeShopStatus']?.toString(),
    );
  }
}

