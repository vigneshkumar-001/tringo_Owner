class ShopCategoryResponse {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessProfile businessProfile;
  final String? category;
  final String? subCategory;
  final String? shopKind;
  final String? englishName;
  final String? tamilName;
  final String? descriptionEn;
  final String? descriptionTa;
  final String? addressEn;
  final String? addressTa;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final String? primaryPhone;
  final String? alternatePhone;
  final String? contactEmail;
  final bool? doorDelivery;
  final bool? isTrusted;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? serviceTags;
  final String? weeklyHours;
  final String? averageRating;
  final int? reviewCount;
  final String? status;

  ShopCategoryResponse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessProfile,
    this.category,
    this.subCategory,
    this.shopKind,
    this.englishName,
    this.tamilName,
    this.descriptionEn,
    this.descriptionTa,
    this.addressEn,
    this.addressTa,
    this.gpsLatitude,
    this.gpsLongitude,
    this.primaryPhone,
    this.alternatePhone,
    this.contactEmail,
    this.doorDelivery,
    this.isTrusted,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.serviceTags,
    this.weeklyHours,
    this.averageRating,
    this.reviewCount,
    this.status,
  });

  factory ShopCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ShopCategoryResponse(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      businessProfile: BusinessProfile.fromJson(json['businessProfile']),
      category: json['category'],
      subCategory: json['subCategory'],
      shopKind: json['shopKind'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      descriptionEn: json['descriptionEn'],
      descriptionTa: json['descriptionTa'],
      addressEn: json['addressEn'],
      addressTa: json['addressTa'],
      gpsLatitude: (json['gpsLatitude'] as num?)?.toDouble(),
      gpsLongitude: (json['gpsLongitude'] as num?)?.toDouble(),
      primaryPhone: json['primaryPhone'],
      alternatePhone: json['alternatePhone'],
      contactEmail: json['contactEmail'],
      doorDelivery: json['doorDelivery'],
      isTrusted: json['isTrusted'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      serviceTags: json['serviceTags'],
      weeklyHours: json['weeklyHours'],
      averageRating: json['averageRating'],
      reviewCount: json['reviewCount'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'businessProfile': businessProfile.toJson(),
    'category': category,
    'subCategory': subCategory,
    'shopKind': shopKind,
    'englishName': englishName,
    'tamilName': tamilName,
    'descriptionEn': descriptionEn,
    'descriptionTa': descriptionTa,
    'addressEn': addressEn,
    'addressTa': addressTa,
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
    'primaryPhone': primaryPhone,
    'alternatePhone': alternatePhone,
    'contactEmail': contactEmail,
    'doorDelivery': doorDelivery,
    'isTrusted': isTrusted,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
    'serviceTags': serviceTags,
    'weeklyHours': weeklyHours,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'status': status,
  };
}

class BusinessProfile {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String businessType;
  final String ownershipType;
  final String govtRegisteredName;
  final String preferredLanguage;
  final String gender;
  final String dateOfBirth;
  final String identityDocumentUrl;
  final String ownerNameTamil;
  final User user;
  final String onboardingStatus;

  BusinessProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessType,
    required this.ownershipType,
    required this.govtRegisteredName,
    required this.preferredLanguage,
    required this.gender,
    required this.dateOfBirth,
    required this.identityDocumentUrl,
    required this.ownerNameTamil,
    required this.user,
    required this.onboardingStatus,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      businessType: json['businessType'],
      ownershipType: json['ownershipType'],
      govtRegisteredName: json['govtRegisteredName'],
      preferredLanguage: json['preferredLanguage'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      identityDocumentUrl: json['identityDocumentUrl'],
      ownerNameTamil: json['ownerNameTamil'],
      user: User.fromJson(json['user']),
      onboardingStatus: json['onboardingStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'businessType': businessType,
    'ownershipType': ownershipType,
    'govtRegisteredName': govtRegisteredName,
    'preferredLanguage': preferredLanguage,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'identityDocumentUrl': identityDocumentUrl,
    'ownerNameTamil': ownerNameTamil,
    'user': user.toJson(),
    'onboardingStatus': onboardingStatus,
  };
}

class User {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String role;
  final String status;

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    fullName: json['fullName'],
    phoneNumber: json['phoneNumber'],
    email: json['email'],
    role: json['role'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'email': email,
    'role': role,
    'status': status,
  };
}
