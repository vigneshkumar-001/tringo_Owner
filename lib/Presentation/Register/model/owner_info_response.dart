class OwnerInfoResponse {
  final bool status;
  final OwnerData? data;

  OwnerInfoResponse({required this.status, this.data});

  factory OwnerInfoResponse.fromJson(Map<String, dynamic> json) {
    return OwnerInfoResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? OwnerData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data?.toJson(),
  };
}

class OwnerData {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String businessType;
  final String ownershipType;
  final String govtRegisteredName;
  final String preferredLanguage;
  final String gender;
  final DateTime dateOfBirth;
  final String? identityDocumentUrl;
  final String ownerNameTamil;
  final User user;
  final String onboardingStatus;

  OwnerData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessType,
    required this.ownershipType,
    required this.govtRegisteredName,
    required this.preferredLanguage,
    required this.gender,
    required this.dateOfBirth,
    this.identityDocumentUrl,
    required this.ownerNameTamil,
    required this.user,
    required this.onboardingStatus,
  });

  factory OwnerData.fromJson(Map<String, dynamic> json) {
    return OwnerData(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      businessType: json['businessType'],
      ownershipType: json['ownershipType'],
      govtRegisteredName: json['govtRegisteredName'],
      preferredLanguage: json['preferredLanguage'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
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
    'dateOfBirth': dateOfBirth.toIso8601String(),
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
  final dynamic businessProfile;
  final dynamic customerProfile;

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
    this.businessProfile,
    this.customerProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      businessProfile: json['businessProfile'],
      customerProfile: json['customerProfile'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'email': email,
    'role': role,
    'status': status,
    'businessProfile': businessProfile,
    'customerProfile': customerProfile,
  };
}
