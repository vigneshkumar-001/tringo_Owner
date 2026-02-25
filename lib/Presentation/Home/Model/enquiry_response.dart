class EnquiryResponse {
  final bool status;
  final EnquirySupportData data;

  const EnquiryResponse({required this.status, required this.data});

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

  const EnquirySupportData({
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

  const Totals({required this.open, required this.closed});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(open: json['open'] ?? 0, closed: json['closed'] ?? 0);
  }
}

class SupportSection {
  final int count;
  final List<SupportItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const SupportSection({
    required this.count,
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory SupportSection.fromJson(Map<String, dynamic> json) {
    return SupportSection(
      count: json['count'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SupportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
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
  final int createdTimestamp;

  final String contextType;
  final String enquirySource;

  final dynamic answer; // 🔥 dynamic to prevent crash

  final Shop? shop;
  final Product? product;
  final ServiceModel? service;
  final SmartConnect? smartConnect;

  final Customer customer;

  const SupportItem({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.createdDate,
    required this.createdTime,
    required this.createdTimestamp,
    required this.contextType,
    required this.enquirySource,
    this.answer,
    this.shop,
    this.product,
    this.service,
    this.smartConnect,
    required this.customer,
  });

  factory SupportItem.fromJson(Map<String, dynamic> json) {
    return SupportItem(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      createdDate: json['createdDate']?.toString() ?? '',
      createdTime: json['createdTime']?.toString() ?? '',
      createdTimestamp: json['createdTimestamp'] ?? 0,
      contextType: json['contextType']?.toString() ?? '',
      enquirySource: json['enquirySource']?.toString() ?? '',
      answer: json['answer'], // no casting
      shop: json['shop'] is Map<String, dynamic>
          ? Shop.fromJson(json['shop'])
          : null,
      product: json['product'] is Map<String, dynamic>
          ? Product.fromJson(json['product'])
          : null,
      service: json['service'] is Map<String, dynamic>
          ? ServiceModel.fromJson(json['service'])
          : null,
      smartConnect: json['smartConnect'] is Map<String, dynamic>
          ? SmartConnect.fromJson(json['smartConnect'])
          : null,
      customer: Customer.fromJson(
        json['customer'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class SmartConnect {
  final String requestId;
  final String? productName;
  final List<dynamic> attachments; // 🔥 allow map or string
  final dynamic reply;

  const SmartConnect({
    required this.requestId,
    this.productName,
    required this.attachments,
    this.reply,
  });

  factory SmartConnect.fromJson(Map<String, dynamic> json) {
    return SmartConnect(
      requestId: json['requestId']?.toString() ?? '',
      productName: json['productName']?.toString(),
      attachments: json['attachments'] is List ? json['attachments'] : [],
      reply: json['reply'],
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

  const Shop({
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
      id: json['id']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      tamilName: json['tamilName']?.toString() ?? '',
      shopKind: json['shopKind']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      primaryImageUrl: json['primaryImageUrl']?.toString(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String? subtitle;
  final int? price;
  final int? mrp;
  final int? offerPrice;
  final String? offerLabel;
  final String? offerValue;
  final String? imageUrl;
  final int rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.name,
    this.subtitle,
    this.price,
    this.mrp,
    this.offerPrice,
    this.offerLabel,
    this.offerValue,
    this.imageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      price: json['price'],
      mrp: json['mrp'],
      offerPrice: json['offerPrice'],
      offerLabel: json['offerLabel']?.toString(),
      offerValue: json['offerValue']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
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

  const ServiceModel({
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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startsAt: json['startsAt'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      offerLabel: json['offerLabel']?.toString(),
      offerValue: json['offerValue']?.toString(),
      primaryImageUrl: json['primaryImageUrl']?.toString(),
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}

class Customer {
  final String name;
  final String? avatarUrl;
  final String phone;
  final String whatsappNumber;

  const Customer({
    required this.name,
    this.avatarUrl,
    required this.phone,
    required this.whatsappNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      phone: json['phone']?.toString() ?? '',
      whatsappNumber: json['whatsappNumber']?.toString() ?? '',
    );
  }
}

// class EnquiryResponse {
//   final bool status;
//   final EnquirySupportData data;
//
//   const EnquiryResponse({
//     required this.status,
//     required this.data,
//   });
//
//   factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
//     return EnquiryResponse(
//       status: json['status'] ?? false,
//       data: EnquirySupportData.fromJson(json['data'] ?? {}),
//     );
//   }
// }
//
// class EnquirySupportData {
//   final Totals totals;
//   final SupportSection open;
//   final SupportSection closed;
//
//   const EnquirySupportData({
//     required this.totals,
//     required this.open,
//     required this.closed,
//   });
//
//   factory EnquirySupportData.fromJson(Map<String, dynamic> json) {
//     return EnquirySupportData(
//       totals: Totals.fromJson(json['totals'] ?? {}),
//       open: SupportSection.fromJson(json['open'] ?? {}),
//       closed: SupportSection.fromJson(json['closed'] ?? {}),
//     );
//   }
// }
//
// class Totals {
//   final int open;
//   final int closed;
//
//   const Totals({
//     required this.open,
//     required this.closed,
//   });
//
//   factory Totals.fromJson(Map<String, dynamic> json) {
//     return Totals(
//       open: json['open'] ?? 0,
//       closed: json['closed'] ?? 0,
//     );
//   }
// }
//
// class SupportSection {
//   final int count;
//   final List<SupportItem> items;
//
//   final int page;
//   final int limit;
//   final int total;
//   final int totalPages;
//   final bool hasNext;
//   final bool hasPrev;
//
//   const SupportSection({
//     required this.count,
//     required this.items,
//     required this.page,
//     required this.limit,
//     required this.total,
//     required this.totalPages,
//     required this.hasNext,
//     required this.hasPrev,
//   });
//
//   factory SupportSection.fromJson(Map<String, dynamic> json) {
//     return SupportSection(
//       count: json['count'] ?? 0,
//       items: (json['items'] as List<dynamic>? ?? [])
//           .map((e) => SupportItem.fromJson(e))
//           .toList(),
//       page: json['page'] ?? 1,
//       limit: json['limit'] ?? 0,
//       total: json['total'] ?? 0,
//       totalPages: json['totalPages'] ?? 0,
//       hasNext: json['hasNext'] ?? false,
//       hasPrev: json['hasPrev'] ?? false,
//     );
//   }
// }
//
// class SupportItem {
//   final String id;
//   final String message;
//   final String status;
//
//   final String createdAt;
//   final String createdDate;
//   final String createdTime;
//   final int createdTimestamp;
//
//   final String contextType;
//   final String enquirySource;
//
//   final String? answer;
//
//   final Shop? shop;
//   final Product? product;
//   final ServiceModel? service;
//   final SmartConnect? smartConnect;
//
//   final Customer customer;
//
//   const SupportItem({
//     required this.id,
//     required this.message,
//     required this.status,
//     required this.createdAt,
//     required this.createdDate,
//     required this.createdTime,
//     required this.createdTimestamp,
//     required this.contextType,
//     required this.enquirySource,
//     this.answer,
//     this.shop,
//     this.product,
//     this.service,
//     this.smartConnect,
//     required this.customer,
//   });
//
//   factory SupportItem.fromJson(Map<String, dynamic> json) {
//     return SupportItem(
//       id: json['id'] ?? '',
//       message: json['message'] ?? '',
//       status: json['status'] ?? '',
//       createdAt: json['createdAt'] ?? '',
//       createdDate: json['createdDate'] ?? '',
//       createdTime: json['createdTime'] ?? '',
//       createdTimestamp: json['createdTimestamp'] ?? 0,
//       contextType: json['contextType'] ?? '',
//       enquirySource: json['enquirySource'] ?? '',
//       answer: json['answer'] ?? '',
//       shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
//       product:
//       json['product'] != null ? Product.fromJson(json['product']) : null,
//       service:
//       json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
//       smartConnect: json['smartConnect'] != null
//           ? SmartConnect.fromJson(json['smartConnect'])
//           : null,
//       customer: Customer.fromJson(json['customer'] ?? {}),
//     );
//   }
// }
//
// class SmartConnect {
//   final String requestId;
//   final String? productName;
//   final List<String> attachments;
//   final String? reply;
//
//   const SmartConnect({
//     required this.requestId,
//     this.productName,
//     required this.attachments,
//     this.reply,
//   });
//
//   factory SmartConnect.fromJson(Map<String, dynamic> json) {
//     return SmartConnect(
//       requestId: json['requestId'] ?? '',
//       productName: json['productName'],
//       attachments:
//       (json['attachments'] as List<dynamic>? ?? []).cast<String>(),
//       reply: json['reply'],
//     );
//   }
// }
//
// class Shop {
//   final String id;
//   final String englishName;
//   final String tamilName;
//   final String shopKind;
//   final String category;
//   final String subCategory;
//   final String city;
//   final int rating;
//   final int ratingCount;
//   final String? primaryImageUrl;
//
//   const Shop({
//     required this.id,
//     required this.englishName,
//     required this.tamilName,
//     required this.shopKind,
//     required this.category,
//     required this.subCategory,
//     required this.city,
//     required this.rating,
//     required this.ratingCount,
//     this.primaryImageUrl,
//   });
//
//   factory Shop.fromJson(Map<String, dynamic> json) {
//     return Shop(
//       id: json['id'] ?? '',
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'] ?? '',
//       shopKind: json['shopKind'] ?? '',
//       category: json['category'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       city: json['city'] ?? '',
//       rating: json['rating'] ?? 0,
//       ratingCount: json['ratingCount'] ?? 0,
//       primaryImageUrl: json['primaryImageUrl'],
//     );
//   }
// }
//
// class Product {
//   final String id;
//   final String name;
//   final String? subtitle;
//   final int? price;
//   final int? mrp;
//   final int? offerPrice;
//   final String? offerLabel;
//   final String? offerValue;
//   final String? imageUrl;
//   final int rating;
//   final int ratingCount;
//
//   const Product({
//     required this.id,
//     required this.name,
//     this.subtitle,
//     this.price,
//     this.mrp,
//     this.offerPrice,
//     this.offerLabel,
//     this.offerValue,
//     this.imageUrl,
//     required this.rating,
//     required this.ratingCount,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       subtitle: json['subtitle'],
//       price: json['price'],
//       mrp: json['mrp'],
//       offerPrice: json['offerPrice'],
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       imageUrl: json['imageUrl'],
//       rating: json['rating'] ?? 0,
//       ratingCount: json['ratingCount'] ?? 0,
//     );
//   }
// }
//
// class ServiceModel {
//   final String id;
//   final String name;
//   final int startsAt;
//   final int durationMinutes;
//   final String? offerLabel;
//   final String? offerValue;
//   final String? primaryImageUrl;
//   final int rating;
//   final int ratingCount;
//
//   const ServiceModel({
//     required this.id,
//     required this.name,
//     required this.startsAt,
//     required this.durationMinutes,
//     this.offerLabel,
//     this.offerValue,
//     this.primaryImageUrl,
//     required this.rating,
//     required this.ratingCount,
//   });
//
//   factory ServiceModel.fromJson(Map<String, dynamic> json) {
//     return ServiceModel(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       startsAt: json['startsAt'] ?? 0,
//       durationMinutes: json['durationMinutes'] ?? 0,
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       primaryImageUrl: json['primaryImageUrl'],
//       rating: json['rating'] ?? 0,
//       ratingCount: json['ratingCount'] ?? 0,
//     );
//   }
// }
//
// class Customer {
//   final String name;
//   final String? avatarUrl;
//   final String phone;
//   final String whatsappNumber;
//
//   const Customer({
//     required this.name,
//     this.avatarUrl,
//     required this.phone,
//     required this.whatsappNumber,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       name: json['name'] ?? '',
//       avatarUrl: json['avatarUrl'],
//       phone: json['phone'] ?? '',
//       whatsappNumber: json['whatsappNumber'] ?? '',
//     );
//   }
// }
//
