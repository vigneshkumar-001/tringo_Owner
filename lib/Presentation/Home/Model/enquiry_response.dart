class  EnquiryResponse  {
  final bool status;
  final EnquirySupportData data;

  EnquiryResponse({
    required this.status,
    required this.data,
  });

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryResponse(
      status: json['status'] as bool,
      data: EnquirySupportData.fromJson(json['data']),
    );
  }
}
class EnquirySupportData {
  final Totals totals;
  final List<SupportItem> items;

  EnquirySupportData({
    required this.totals,
    required this.items,
  });

  factory EnquirySupportData.fromJson(Map<String, dynamic> json) {
    return EnquirySupportData(
      totals: Totals.fromJson(json['totals']),
      items: (json['items'] as List<dynamic>)
          .map((e) => SupportItem.fromJson(e))
          .toList(),
    );
  }
}
class Totals {
  final int open;
  final int closed;

  Totals({
    required this.open,
    required this.closed,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      open: json['open'] as int,
      closed: json['closed'] as int,
    );
  }
}
class SupportItem {
  final String id;
  final String message;
  final String status;
  final String createdAt;
  final String contextType;
  final Shop? shop;
  final dynamic product;
  final dynamic service;
  final Customer customer;

  SupportItem({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.contextType,
    this.shop,
    this.product,
    this.service,
    required this.customer,
  });

  factory SupportItem.fromJson(Map<String, dynamic> json) {
    return SupportItem(
      id: json['id'],
      message: json['message'],
      status: json['status'],
      createdAt: json['createdAt'],
      contextType: json['contextType'],
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
      product: json['product'],
      service: json['service'],
      customer: Customer.fromJson(json['customer']),
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
  final String primaryImageUrl;

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
    required this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      shopKind: json['shopKind'],
      category: json['category'],
      subCategory: json['subCategory'],
      city: json['city'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      primaryImageUrl: json['primaryImageUrl'],
    );
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
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      phone: json['phone'],
      whatsappNumber: json['whatsappNumber'],
    );
  }
}
