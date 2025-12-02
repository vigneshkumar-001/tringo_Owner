class ShopCategoryResponse {
  final bool status;
  final ShopDetails data;

  const ShopCategoryResponse({required this.status, required this.data});

  factory ShopCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ShopCategoryResponse(
      status: json['status'] ?? false,
      data: ShopDetails.fromJson(json['data'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class ShopDetails {
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
  final String? ownerImageUrl;

  final bool? doorDelivery;
  final bool? isTrusted;

  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  final String? serviceTags;

  /// Backend sends an array of objects
  final List<ShopWeeklyHour> weeklyHours;

  final String? averageRating;
  final int? reviewCount;
  final String? status;

  const ShopDetails({
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
    this.ownerImageUrl,
    this.doorDelivery,
    this.isTrusted,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.serviceTags,
    this.weeklyHours = const [],
    this.averageRating,
    this.reviewCount,
    this.status,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      businessProfile: BusinessProfile.fromJson(
        json['businessProfile'] ?? const {},
      ),
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
      ownerImageUrl: json['ownerImageUrl'],
      doorDelivery: _parseBool(json['doorDelivery']),
      isTrusted: _parseBool(json['isTrusted']),
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      serviceTags: json['serviceTags'],
      weeklyHours:
          (json['weeklyHours'] as List<dynamic>?)
              ?.map((e) => ShopWeeklyHour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      averageRating: json['averageRating']?.toString(),
      reviewCount: json['reviewCount'] is int
          ? json['reviewCount'] as int
          : int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'ownerImageUrl': ownerImageUrl,
      'doorDelivery': doorDelivery,
      'isTrusted': isTrusted,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'serviceTags': serviceTags,
      'weeklyHours': weeklyHours.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'status': status,
    };
  }
}

class BusinessProfile {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? businessType;
  final String? ownershipType;
  final String? govtRegisteredName;
  final String? preferredLanguage;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? identityDocumentUrl;
  final String? ownerNameTamil;

  final AppUser user;
  final String? onboardingStatus;

  const BusinessProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.businessType,
    this.ownershipType,
    this.govtRegisteredName,
    this.preferredLanguage,
    this.gender,
    this.dateOfBirth,
    this.identityDocumentUrl,
    this.ownerNameTamil,
    this.onboardingStatus,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      businessType: json['businessType'],
      ownershipType: json['ownershipType'],
      govtRegisteredName: json['govtRegisteredName'],
      preferredLanguage: json['preferredLanguage'],
      gender: json['gender'],
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? ''),
      identityDocumentUrl: json['identityDocumentUrl'],
      ownerNameTamil: json['ownerNameTamil'],
      user: AppUser.fromJson(json['user'] ?? const {}),
      onboardingStatus: json['onboardingStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'businessType': businessType,
      'ownershipType': ownershipType,
      'govtRegisteredName': govtRegisteredName,
      'preferredLanguage': preferredLanguage,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'identityDocumentUrl': identityDocumentUrl,
      'ownerNameTamil': ownerNameTamil,
      'user': user.toJson(),
      'onboardingStatus': onboardingStatus,
    };
  }
}

class AppUser {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? role;
  final String? status;

  const AppUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.role,
    this.status,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}

class ShopWeeklyHour {
  final String? day;
  final String? opensAt;
  final String? closesAt;
  final bool? closed;

  const ShopWeeklyHour({this.day, this.opensAt, this.closesAt, this.closed});

  factory ShopWeeklyHour.fromJson(Map<String, dynamic> json) {
    return ShopWeeklyHour(
      day: json['day'],
      opensAt: json['opensAt'],
      closesAt: json['closesAt'],
      closed: _parseBool(json['closed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'opensAt': opensAt,
      'closesAt': closesAt,
      'closed': closed,
    };
  }
}

/// Helper for dynamic → bool
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;

  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }

  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == 'yes' || lower == '1') return true;
    if (lower == 'false' || lower == 'no' || lower == '0') return false;
  }

  return null;
}

// class ShopCategoryResponse {
//   final String id;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final BusinessProfile businessProfile;
//   final String? category;
//   final String? subCategory;
//   final String? shopKind;
//   final String? englishName;
//   final String? tamilName;
//   final String? descriptionEn;
//   final String? descriptionTa;
//   final String? addressEn;
//   final String? addressTa;
//   final double? gpsLatitude;
//   final double? gpsLongitude;
//   final String? primaryPhone;
//   final String? alternatePhone;
//   final String? shopWeeklyHours;
//   final String? contactEmail;
//   final bool? doorDelivery;
//   final bool? isTrusted;
//   final String? city;
//   final String? state;
//   final String? country;
//   final String? postalCode;
//   final String? serviceTags;
//   final String? weeklyHours;
//   final String? averageRating;
//   final int? reviewCount;
//   final String? status;
//
//   ShopCategoryResponse({
//     required this.id,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.businessProfile,
//     this.category,
//     this.subCategory,
//     this.shopKind,
//     this.englishName,
//     this.tamilName,
//     this.descriptionEn,
//     this.descriptionTa,
//     this.addressEn,
//     this.addressTa,
//     this.gpsLatitude,
//     this.gpsLongitude,
//     this.primaryPhone,
//     this.alternatePhone,
//     this.shopWeeklyHours,
//     this.contactEmail,
//     this.doorDelivery,
//     this.isTrusted,
//     this.city,
//     this.state,
//     this.country,
//     this.postalCode,
//     this.serviceTags,
//     this.weeklyHours,
//     this.averageRating,
//     this.reviewCount,
//     this.status,
//   });
//
//   factory ShopCategoryResponse.fromJson(Map<String, dynamic> json) {
//     return ShopCategoryResponse(
//       id: json['id'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: DateTime.parse(json['updatedAt'] as String),
//       businessProfile: BusinessProfile.fromJson(
//         json['businessProfile'] as Map<String, dynamic>,
//       ),
//       category: json['category'] as String?,
//       subCategory: json['subCategory'] as String?,
//       shopKind: json['shopKind'] as String?,
//       englishName: json['englishName'] as String?,
//       tamilName: json['tamilName'] as String?,
//       descriptionEn: json['descriptionEn'] as String?,
//       descriptionTa: json['descriptionTa'] as String?,
//       addressEn: json['addressEn'] as String?,
//       addressTa: json['addressTa'] as String?,
//       gpsLatitude: (json['gpsLatitude'] as num?)?.toDouble(),
//       gpsLongitude: (json['gpsLongitude'] as num?)?.toDouble(),
//       primaryPhone: json['primaryPhone'] as String?,
//       alternatePhone: json['alternatePhone'] as String?,
//       shopWeeklyHours: json['shopWeeklyHours'] as String?,
//       contactEmail: json['contactEmail'] as String?,
//       doorDelivery: json['doorDelivery'] as bool?,
//       isTrusted: json['isTrusted'] as bool?,
//       city: json['city'] as String?,
//       state: json['state'] as String?,
//       country: json['country'] as String?,
//       postalCode: json['postalCode'] as String?,
//       serviceTags: json['serviceTags'] as String?,
//       weeklyHours: json['weeklyHours'] as String?,
//       averageRating: json['averageRating'] as String?,
//       reviewCount: json['reviewCount'] as int?,
//       status: json['status'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdAt': createdAt.toIso8601String(),
//     'updatedAt': updatedAt.toIso8601String(),
//     'businessProfile': businessProfile.toJson(),
//     'category': category,
//     'subCategory': subCategory,
//     'shopKind': shopKind,
//     'englishName': englishName,
//     'tamilName': tamilName,
//     'descriptionEn': descriptionEn,
//     'descriptionTa': descriptionTa,
//     'addressEn': addressEn,
//     'addressTa': addressTa,
//     'gpsLatitude': gpsLatitude,
//     'gpsLongitude': gpsLongitude,
//     'primaryPhone': primaryPhone,
//     'alternatePhone': alternatePhone,
//     'shopWeeklyHours': shopWeeklyHours,
//     'contactEmail': contactEmail,
//     'doorDelivery': doorDelivery,
//     'isTrusted': isTrusted,
//     'city': city,
//     'state': state,
//     'country': country,
//     'postalCode': postalCode,
//     'serviceTags': serviceTags,
//     'weeklyHours': weeklyHours,
//     'averageRating': averageRating,
//     'reviewCount': reviewCount,
//     'status': status,
//   };
// }
//
// class BusinessProfile {
//   final String id;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final String businessType;
//   final String ownershipType;
//   final String govtRegisteredName;
//   final String preferredLanguage;
//   final String gender;
//   final String dateOfBirth;
//   final String identityDocumentUrl;
//   final String ownerNameTamil;
//   final User user;
//   final String onboardingStatus;
//
//   BusinessProfile({
//     required this.id,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.businessType,
//     required this.ownershipType,
//     required this.govtRegisteredName,
//     required this.preferredLanguage,
//     required this.gender,
//     required this.dateOfBirth,
//     required this.identityDocumentUrl,
//     required this.ownerNameTamil,
//     required this.user,
//     required this.onboardingStatus,
//   });
//
//   factory BusinessProfile.fromJson(Map<String, dynamic> json) {
//     return BusinessProfile(
//       id: json['id'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: DateTime.parse(json['updatedAt'] as String),
//       businessType: json['businessType'] as String,
//       ownershipType: json['ownershipType'] as String,
//       govtRegisteredName: json['govtRegisteredName'] as String,
//       preferredLanguage: json['preferredLanguage'] as String,
//       gender: json['gender'] as String,
//       dateOfBirth: json['dateOfBirth'] as String,
//       identityDocumentUrl: json['identityDocumentUrl'] as String,
//       ownerNameTamil: json['ownerNameTamil'] as String,
//       user: User.fromJson(json['user'] as Map<String, dynamic>),
//       onboardingStatus: json['onboardingStatus'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdAt': createdAt.toIso8601String(),
//     'updatedAt': updatedAt.toIso8601String(),
//     'businessType': businessType,
//     'ownershipType': ownershipType,
//     'govtRegisteredName': govtRegisteredName,
//     'preferredLanguage': preferredLanguage,
//     'gender': gender,
//     'dateOfBirth': dateOfBirth,
//     'identityDocumentUrl': identityDocumentUrl,
//     'ownerNameTamil': ownerNameTamil,
//     'user': user.toJson(),
//     'onboardingStatus': onboardingStatus,
//   };
// }
//
// class User {
//   final String id;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final String fullName;
//   final String phoneNumber;
//   final String email;
//   final String role;
//   final String status;
//
//   User({
//     required this.id,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.fullName,
//     required this.phoneNumber,
//     required this.email,
//     required this.role,
//     required this.status,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) => User(
//     id: json['id'] as String,
//     createdAt: DateTime.parse(json['createdAt'] as String),
//     updatedAt: DateTime.parse(json['updatedAt'] as String),
//     fullName: json['fullName'] as String,
//     phoneNumber: json['phoneNumber'] as String,
//     email: json['email'] as String,
//     role: json['role'] as String,
//     status: json['status'] as String,
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdAt': createdAt.toIso8601String(),
//     'updatedAt': updatedAt.toIso8601String(),
//     'fullName': fullName,
//     'phoneNumber': phoneNumber,
//     'email': email,
//     'role': role,
//     'status': status,
//   };
// }
