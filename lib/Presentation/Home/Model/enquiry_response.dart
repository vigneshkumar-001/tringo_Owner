class EnquiryResponse {
  final bool status;
  final EnquirySupportData data;

  EnquiryResponse({required this.status, required this.data});

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryResponse(
      status: json['status'] ?? false,
      data: EnquirySupportData.fromJson(json['data'] ?? {}),
    );
  }
}

class EnquirySupportData {
  final Totals totals;
  final SupportSection open;
  final SupportSection closed;

  EnquirySupportData({
    required this.totals,
    required this.open,
    required this.closed,
  });

  factory EnquirySupportData.fromJson(Map<String, dynamic> json) {
    return EnquirySupportData(
      totals: Totals.fromJson(json['totals'] ?? {}),
      open: SupportSection.fromJson(json['open'] ?? {}),
      closed: SupportSection.fromJson(json['closed'] ?? {}),
    );
  }
}

class Totals {
  final int open;
  final int closed;

  Totals({required this.open, required this.closed});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(open: json['open'] ?? 0, closed: json['closed'] ?? 0);
  }
}

class SupportSection {
  final int count;
  final List<SupportItem> items;

  SupportSection({required this.count, required this.items});

  factory SupportSection.fromJson(Map<String, dynamic> json) {
    return SupportSection(
      count: json['count'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SupportItem.fromJson(e))
          .toList(),
    );
  }
}

class SupportItem {
  final String id;
  final String message;
  final String status;
  final String createdAt;
  final String createdDate;
  final String createdTime;
  final String contextType;
  final Shop? shop;
  final Product? product;
  final ServiceModel? service;
  final Customer customer;

  SupportItem({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.createdDate,
    required this.createdTime,
    required this.contextType,
    this.shop,
    this.product,
    this.service,
    required this.customer,
  });

  factory SupportItem.fromJson(Map<String, dynamic> json) {
    return SupportItem(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdDate: json['createdDate'] ?? '',
      createdTime: json['createdTime'] ?? '',
      contextType: json['contextType'] ?? '',
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      customer: Customer.fromJson(json['customer'] ?? {}),
    );
  }
}

class Shop {
  final String id;
  final String englishName;
  final String tamilName;
  final String shopKind;
  final String category;
  final String subCategory;
  final String city;
  final int rating;
  final int ratingCount;
  final String? primaryImageUrl;

  Shop({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.shopKind,
    required this.category,
    required this.subCategory,
    required this.city,
    required this.rating,
    required this.ratingCount,
    this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      shopKind: json['shopKind'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      city: json['city'] ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      primaryImageUrl: json['primaryImageUrl'],
    );
  }
}

class ServiceModel {
  final String id;
  final String name;
  final int startsAt;
  final int durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String? primaryImageUrl;
  final int rating;
  final int ratingCount;

  ServiceModel({
    required this.id,
    required this.name,
    required this.startsAt,
    required this.durationMinutes,
    this.offerLabel,
    this.offerValue,
    this.primaryImageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startsAt: json['startsAt'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      primaryImageUrl: json['primaryImageUrl'],
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}

class Product {
  final String? id;

  Product({this.id});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(id: json['id']);
  }
}

class Customer {
  final String name;
  final String? avatarUrl;
  final String phone;
  final String whatsappNumber;

  Customer({
    required this.name,
    this.avatarUrl,
    required this.phone,
    required this.whatsappNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      phone: json['phone'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
    );
  }
}
