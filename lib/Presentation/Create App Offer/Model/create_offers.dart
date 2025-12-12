// offer_model.dart

class CreateOffers {
  final bool status;
  final OfferData? data;

  CreateOffers({required this.status, required this.data});

  factory CreateOffers.fromJson(Map<String, dynamic> json) {
    return CreateOffers(
      status: json['status'] ?? false,
      data: json['data'] != null ? OfferData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "data": data?.toJson()};
  }
}

class OfferData {
  final String id;
  final String createdAt;
  final String updatedAt;
  final Shop shop;

  final String type;
  final String title;
  final String description;

  final num? discountPercentage;
  final String? availableFrom;
  final String? availableTo;
  final String? announcementAt;
  final String? campaignId;
  final num? maxCoupons;
  final String status;
  final bool autoApply;
  final dynamic targetSegment;

  final List<dynamic> products;
  final List<dynamic> services;
  final String nextListType;

  OfferData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.shop,
    required this.type,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.availableFrom,
    required this.availableTo,
    required this.announcementAt,
    required this.campaignId,
    required this.maxCoupons,
    required this.status,
    required this.autoApply,
    required this.targetSegment,
    required this.products,
    required this.services,
    required this. nextListType ,
  });

  factory OfferData.fromJson(Map<String, dynamic> json) {
    return OfferData(
      id: json["id"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      shop: Shop.fromJson(json["shop"]),

      type: json["type"],
      title: json["title"],
      description: json["description"],

      discountPercentage: json["discountPercentage"],
      availableFrom: json["availableFrom"],
      availableTo: json["availableTo"],
      announcementAt: json["announcementAt"],
      campaignId: json["campaignId"],
      maxCoupons: json["maxCoupons"],
      status: json["status"],
      autoApply: json["autoApply"] ?? false,
      targetSegment: json["targetSegment"],
      nextListType: json["nextListType"],

      products: json["products"] ?? [],
      services: json["services"] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "shop": shop.toJson(),
      "type": type,
      "title": title,
      "description": description,
      "discountPercentage": discountPercentage,
      "availableFrom": availableFrom,
      "availableTo": availableTo,
      "announcementAt": announcementAt,
      "campaignId": campaignId,
      "maxCoupons": maxCoupons,
      "status": status,
      "autoApply": autoApply,
      "targetSegment": targetSegment,
      "products": products,
      "services": services,
      "nextListType": nextListType,
    };
  }
}

class Shop {
  final String id;
  final String createdAt;
  final String updatedAt;

  final BusinessProfile businessProfile;

  final String category;
  final String subCategory;
  final String shopKind;
  final String englishName;
  final String tamilName;
  final String descriptionEn;
  final String descriptionTa;
  final String addressEn;
  final String addressTa;
  final String gpsLatitude;
  final String gpsLongitude;
  final String primaryPhone;
  final String? alternatePhone;
  final String? contactEmail;
  final String? ownerImageUrl;
  final bool doorDelivery;
  final bool isTrusted;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  final dynamic serviceTags;

  final List<WeeklyHours> weeklyHours;
  final String averageRating;
  final num reviewCount;
  final String status;

  Shop({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessProfile,
    required this.category,
    required this.subCategory,
    required this.shopKind,
    required this.englishName,
    required this.tamilName,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.addressEn,
    required this.addressTa,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.primaryPhone,
    required this.alternatePhone,
    required this.contactEmail,
    required this.ownerImageUrl,
    required this.doorDelivery,
    required this.isTrusted,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.serviceTags,
    required this.weeklyHours,
    required this.averageRating,
    required this.reviewCount,
    required this.status,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json["id"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      businessProfile: BusinessProfile.fromJson(json["businessProfile"]),
      category: json["category"],
      subCategory: json["subCategory"],
      shopKind: json["shopKind"],
      englishName: json["englishName"],
      tamilName: json["tamilName"],
      descriptionEn: json["descriptionEn"],
      descriptionTa: json["descriptionTa"],
      addressEn: json["addressEn"],
      addressTa: json["addressTa"],
      gpsLatitude: json["gpsLatitude"],
      gpsLongitude: json["gpsLongitude"],
      primaryPhone: json["primaryPhone"],
      alternatePhone: json["alternatePhone"],
      contactEmail: json["contactEmail"],
      ownerImageUrl: json["ownerImageUrl"],
      doorDelivery: json["doorDelivery"],
      isTrusted: json["isTrusted"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      postalCode: json["postalCode"],
      serviceTags: json["serviceTags"],
      weeklyHours: (json["weeklyHours"] as List<dynamic>)
          .map((e) => WeeklyHours.fromJson(e))
          .toList(),
      averageRating: json["averageRating"].toString(),
      reviewCount: json["reviewCount"] ?? 0,
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "businessProfile": businessProfile.toJson(),
      "category": category,
      "subCategory": subCategory,
      "shopKind": shopKind,
      "englishName": englishName,
      "tamilName": tamilName,
      "descriptionEn": descriptionEn,
      "descriptionTa": descriptionTa,
      "addressEn": addressEn,
      "addressTa": addressTa,
      "gpsLatitude": gpsLatitude,
      "gpsLongitude": gpsLongitude,
      "primaryPhone": primaryPhone,
      "alternatePhone": alternatePhone,
      "contactEmail": contactEmail,
      "ownerImageUrl": ownerImageUrl,
      "doorDelivery": doorDelivery,
      "isTrusted": isTrusted,
      "city": city,
      "state": state,
      "country": country,
      "postalCode": postalCode,
      "serviceTags": serviceTags,
      "weeklyHours": weeklyHours.map((e) => e.toJson()).toList(),
      "averageRating": averageRating,
      "reviewCount": reviewCount,
      "status": status,
    };
  }
}

class BusinessProfile {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String businessType;
  final String ownershipType;
  final String govtRegisteredName;
  final String preferredLanguage;
  final String gender;
  final String dateOfBirth;
  final String identityDocumentUrl;
  final String ownerNameTamil;

  final UserModel user;
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
      id: json["id"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      businessType: json["businessType"],
      ownershipType: json["ownershipType"],
      govtRegisteredName: json["govtRegisteredName"],
      preferredLanguage: json["preferredLanguage"] ?? "",
      gender: json["gender"],
      dateOfBirth: json["dateOfBirth"],
      identityDocumentUrl: json["identityDocumentUrl"],
      ownerNameTamil: json["ownerNameTamil"],
      user: UserModel.fromJson(json["user"]),
      onboardingStatus: json["onboardingStatus"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "businessType": businessType,
      "ownershipType": ownershipType,
      "govtRegisteredName": govtRegisteredName,
      "preferredLanguage": preferredLanguage,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "identityDocumentUrl": identityDocumentUrl,
      "ownerNameTamil": ownerNameTamil,
      "user": user.toJson(),
      "onboardingStatus": onboardingStatus,
    };
  }
}

class UserModel {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      fullName: json["fullName"],
      phoneNumber: json["phoneNumber"],
      email: json["email"],
      role: json["role"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "email": email,
      "role": role,
      "status": status,
    };
  }
}

class WeeklyHours {
  final String day;
  final String opensAt;
  final String closesAt;
  final bool closed;

  WeeklyHours({
    required this.day,
    required this.opensAt,
    required this.closesAt,
    required this.closed,
  });

  factory WeeklyHours.fromJson(Map<String, dynamic> json) {
    return WeeklyHours(
      day: json["day"],
      opensAt: json["opensAt"],
      closesAt: json["closesAt"],
      closed: json["closed"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "day": day,
      "opensAt": opensAt,
      "closesAt": closesAt,
      "closed": closed,
    };
  }
}
