class ShopPhotoResponse {
  final bool status;
  final List<ShopPhotoData> data;

  ShopPhotoResponse({
    required this.status,
    required this.data,
  });

  factory ShopPhotoResponse.fromJson(Map<String, dynamic> json) {
    return ShopPhotoResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ShopPhotoData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class ShopPhotoData {
  final String id;
  final String? createdAt;
  final String? updatedAt;
  final ShopDetails? shop;
  final String? type;
  final String? url;
  final int? displayOrder;

  ShopPhotoData({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.shop,
    this.type,
    this.url,
    this.displayOrder,
  });

  factory ShopPhotoData.fromJson(Map<String, dynamic> json) {
    return ShopPhotoData(
      id: json['id'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      shop: json['shop'] != null ? ShopDetails.fromJson(json['shop']) : null,
      type: json['type'],
      url: json['url'],
      displayOrder: json['displayOrder'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'shop': shop?.toJson(),
    'type': type,
    'url': url,
    'displayOrder': displayOrder,
  };
}

class ShopDetails {
  final String id;
  final String? createdAt;
  final String? updatedAt;
  final BusinessProfile? businessProfile;
  final String? category;
  final String? subCategory;
  final String? shopKind;
  final String? englishName;
  final String? tamilName;
  final String? descriptionEn;
  final String? descriptionTa;
  final String? addressEn;
  final String? addressTa;
  final String? gpsLatitude;
  final String? gpsLongitude;
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

  ShopDetails({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.businessProfile,
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

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      id: json['id'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      businessProfile: json['businessProfile'] != null
          ? BusinessProfile.fromJson(json['businessProfile'])
          : null,
      category: json['category'],
      subCategory: json['subCategory'],
      shopKind: json['shopKind'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      descriptionEn: json['descriptionEn'],
      descriptionTa: json['descriptionTa'],
      addressEn: json['addressEn'],
      addressTa: json['addressTa'],
      gpsLatitude: json['gpsLatitude'],
      gpsLongitude: json['gpsLongitude'],
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
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'businessProfile': businessProfile?.toJson(),
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
  final String? createdAt;
  final String? updatedAt;
  final String? businessType;
  final String? ownershipType;
  final String? govtRegisteredName;
  final String? preferredLanguage;
  final String? gender;
  final String? dateOfBirth;
  final String? identityDocumentUrl;
  final String? ownerNameTamil;
  final UserProfile? user;
  final String? onboardingStatus;

  BusinessProfile({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.businessType,
    this.ownershipType,
    this.govtRegisteredName,
    this.preferredLanguage,
    this.gender,
    this.dateOfBirth,
    this.identityDocumentUrl,
    this.ownerNameTamil,
    this.user,
    this.onboardingStatus,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      businessType: json['businessType'],
      ownershipType: json['ownershipType'],
      govtRegisteredName: json['govtRegisteredName'],
      preferredLanguage: json['preferredLanguage'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      identityDocumentUrl: json['identityDocumentUrl'],
      ownerNameTamil: json['ownerNameTamil'],
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      onboardingStatus: json['onboardingStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'businessType': businessType,
    'ownershipType': ownershipType,
    'govtRegisteredName': govtRegisteredName,
    'preferredLanguage': preferredLanguage,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'identityDocumentUrl': identityDocumentUrl,
    'ownerNameTamil': ownerNameTamil,
    'user': user?.toJson(),
    'onboardingStatus': onboardingStatus,
  };
}

class UserProfile {
  final String id;
  final String? createdAt;
  final String? updatedAt;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? role;
  final String? status;

  UserProfile({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.role,
    this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'email': email,
    'role': role,
    'status': status,
  };
}
