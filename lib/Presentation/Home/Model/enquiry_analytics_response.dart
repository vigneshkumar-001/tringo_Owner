// enquiry_analytics_response.dart
// ✅ UPDATED for NEW JSON:
// lists -> enquiries/calls/locations -> open/closed -> { paging, sections }
// ✅ product + service SAME JSON structure
// ✅ Added: enquirySource, answer(Map), statusText getter

// ------------------ Helpers ------------------

String _asString(dynamic v, [String fallback = ""]) {
  if (v == null) return fallback;
  return v.toString();
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  final n = int.tryParse(s);
  if (n != null) return n;
  final d = double.tryParse(s);
  if (d != null) return d.toInt();
  return fallback;
}

num _asNum(dynamic v, [num fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v;
  final s = v.toString().trim();
  final i = int.tryParse(s);
  if (i != null) return i;
  final d = double.tryParse(s);
  if (d != null) return d;
  return fallback;
}

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  return null;
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  return const [];
}

// ------------------ Enums ------------------

enum EnquiryStatus { open, closed, unknown }

EnquiryStatus enquiryStatusFromString(String? v) {
  switch ((v ?? "").toUpperCase()) {
    case "OPEN":
      return EnquiryStatus.open;
    case "CLOSED":
      return EnquiryStatus.closed;
    default:
      return EnquiryStatus.unknown;
  }
}

String enquiryStatusToString(EnquiryStatus v) {
  switch (v) {
    case EnquiryStatus.open:
      return "OPEN";
    case EnquiryStatus.closed:
      return "CLOSED";
    case EnquiryStatus.unknown:
      return "UNKNOWN";
  }
}

// ------------------ Root ------------------

class EnquiryAnalyticsResponse {
  final bool status;
  final DashboardData data;

  EnquiryAnalyticsResponse({required this.status, required this.data});

  factory EnquiryAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      EnquiryAnalyticsResponse(
        status: json["status"] == true,
        data: DashboardData.fromJson(
          (json["data"] as Map<String, dynamic>?) ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class DashboardData {
  final DateRange range;
  final Counts counts;
  final Lists lists;

  DashboardData({
    required this.range,
    required this.counts,
    required this.lists,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    range: DateRange.fromJson(
      (json["range"] as Map<String, dynamic>?) ?? const {},
    ),
    counts: Counts.fromJson(
      (json["counts"] as Map<String, dynamic>?) ?? const {},
    ),
    lists: Lists.fromJson(
      (json["lists"] as Map<String, dynamic>?) ?? const {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "range": range.toJson(),
    "counts": counts.toJson(),
    "lists": lists.toJson(),
  };
}

class DateRange {
  final String start;
  final String end;

  DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
    start: _asString(json["start"]),
    end: _asString(json["end"]),
  );

  Map<String, dynamic> toJson() => {
    "start": start,
    "end": end,
  };
}

// ------------------ Counts ------------------

class Counts {
  final CountBucket enquiries;
  final CountBucket calls;
  final CountBucket locations;

  Counts({
    required this.enquiries,
    required this.calls,
    required this.locations,
  });

  factory Counts.fromJson(Map<String, dynamic> json) => Counts(
    enquiries: CountBucket.fromJson(
      (json["enquiries"] as Map<String, dynamic>?) ?? const {},
    ),
    calls: CountBucket.fromJson(
      (json["calls"] as Map<String, dynamic>?) ?? const {},
    ),
    locations: CountBucket.fromJson(
      (json["locations"] as Map<String, dynamic>?) ?? const {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "enquiries": enquiries.toJson(),
    "calls": calls.toJson(),
    "locations": locations.toJson(),
  };
}

class CountBucket {
  final int open;
  final int closed;
  final int total;

  CountBucket({required this.open, required this.closed, required this.total});

  factory CountBucket.fromJson(Map<String, dynamic> json) => CountBucket(
    open: _asInt(json["open"]),
    closed: _asInt(json["closed"]),
    total: _asInt(json["total"]),
  );

  Map<String, dynamic> toJson() => {
    "open": open,
    "closed": closed,
    "total": total,
  };
}

// ------------------ Lists ------------------
/// ✅ lists -> enquiries/calls/locations -> StatusLists(open/closed)
class Lists {
  final Map<String, StatusLists> items;

  Lists({required this.items});

  factory Lists.fromJson(Map<String, dynamic> json) {
    final map = <String, StatusLists>{};

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        map[key] = StatusLists.fromJson(value);
      }
    });

    return Lists(items: map);
  }

  Map<String, dynamic> toJson() =>
      items.map((key, value) => MapEntry(key, value.toJson()));

  StatusLists? get enquiries => items["enquiries"];
  StatusLists? get calls => items["calls"];
  StatusLists? get locations => items["locations"];
}

class StatusLists {
  final CommonList open;
  final CommonList closed;

  StatusLists({required this.open, required this.closed});

  factory StatusLists.fromJson(Map<String, dynamic> json) => StatusLists(
    open: CommonList.fromJson(
      (json["open"] as Map<String, dynamic>?) ?? const {},
    ),
    closed: CommonList.fromJson(
      (json["closed"] as Map<String, dynamic>?) ?? const {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "open": open.toJson(),
    "closed": closed.toJson(),
  };
}

class CommonList {
  final Paging paging;
  final List<CommonSection> sections;

  CommonList({required this.paging, required this.sections});

  factory CommonList.fromJson(Map<String, dynamic> json) => CommonList(
    paging: Paging.fromJson(
      (json["paging"] as Map<String, dynamic>?) ?? const {},
    ),
    sections: (_asList(json["sections"]))
        .map((e) => CommonSection.fromJson(
      (e as Map<String, dynamic>?) ?? const {},
    ))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "paging": paging.toJson(),
    "sections": sections.map((e) => e.toJson()).toList(),
  };
}

class Paging {
  final int take;
  final int skip;
  final int total;

  Paging({required this.take, required this.skip, required this.total});

  factory Paging.fromJson(Map<String, dynamic> json) => Paging(
    take: _asInt(json["take"]),
    skip: _asInt(json["skip"]),
    total: _asInt(json["total"]),
  );

  Map<String, dynamic> toJson() => {
    "take": take,
    "skip": skip,
    "total": total,
  };
}

class CommonSection {
  final String dayKey; // "TODAY" or "YYYY-MM-DD"
  final String dayLabel; // "Today" or "13 Jan 2026"
  final List<CommonItem> items;

  CommonSection({
    required this.dayKey,
    required this.dayLabel,
    required this.items,
  });

  factory CommonSection.fromJson(Map<String, dynamic> json) => CommonSection(
    dayKey: _asString(json["dayKey"]),
    dayLabel: _asString(json["dayLabel"]),
    items: (_asList(json["items"]))
        .map((e) => CommonItem.fromJson(
      (e as Map<String, dynamic>?) ?? const {},
    ))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "dayKey": dayKey,
    "dayLabel": dayLabel,
    "items": items.map((e) => e.toJson()).toList(),
  };
}

// ------------------ Item ------------------

class CommonItem {
  final String id;
  final String kind; // "ENQUIRY" / "CALL" / "MAP"

  /// ✅ Store both raw + enum (for UI flexibility)
  final String statusRaw; // "OPEN"/"CLOSED"
  final EnquiryStatus status; // enum

  final String message;
  final String timeLabel;
  final String dateLabel;
  final String createdAt;

  final String? closedAt;

  final String? contextType; // SHOP / PRODUCT / SERVICE
  final String? productId;
  final String? serviceId;

  /// ✅ NEW: enquirySource (SMART_CONNECT / NORMAL)
  final String? enquirySource;

  /// ✅ NEW: answer object (Map)
  /// API example:
  /// { "title": "...", "description": "...", "price": 100, "images": [] }
  final Map<String, dynamic>? answer;

  final Customer? customer;
  final Shop? shop;
  final Product? product;
  final Service? service;

  CommonItem({
    required this.id,
    required this.kind,
    required this.statusRaw,
    required this.status,
    required this.message,
    required this.timeLabel,
    required this.dateLabel,
    required this.createdAt,
    required this.closedAt,
    required this.contextType,
    required this.productId,
    required this.serviceId,
    required this.enquirySource,
    required this.answer,
    required this.customer,
    required this.shop,
    required this.product,
    required this.service,
  });

  /// ✅ Use this in UI:
  /// final status = item.statusText.toUpperCase();
  String get statusText => statusRaw.isNotEmpty ? statusRaw : enquiryStatusToString(status);

  factory CommonItem.fromJson(Map<String, dynamic> json) {
    final rawStatus = _asString(json["status"]);
    return CommonItem(
      id: _asString(json["id"]),
      kind: _asString(json["kind"]),
      statusRaw: rawStatus,
      status: enquiryStatusFromString(rawStatus),
      message: _asString(json["message"]),
      timeLabel: _asString(json["timeLabel"]),
      dateLabel: _asString(json["dateLabel"]),
      createdAt: _asString(json["createdAt"]),
      closedAt: json["closedAt"]?.toString(),
      contextType: json["contextType"]?.toString(),
      productId: json["productId"]?.toString(),
      serviceId: json["serviceId"]?.toString(),

      // ✅ NEW fields
      enquirySource: json["enquirySource"]?.toString(),
      answer: _asMap(json["answer"]),

      customer: (json["customer"] is Map<String, dynamic>)
          ? Customer.fromJson(json["customer"] as Map<String, dynamic>)
          : null,
      shop: (json["shop"] is Map<String, dynamic>)
          ? Shop.fromJson(json["shop"] as Map<String, dynamic>)
          : null,
      product: (json["product"] is Map<String, dynamic>)
          ? Product.fromJson(json["product"] as Map<String, dynamic>)
          : null,
      service: (json["service"] is Map<String, dynamic>)
          ? Service.fromJson(json["service"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "kind": kind,
    "status": statusText,
    "message": message,
    "timeLabel": timeLabel,
    "dateLabel": dateLabel,
    "createdAt": createdAt,
    "closedAt": closedAt,
    "contextType": contextType,
    "productId": productId,
    "serviceId": serviceId,
    "enquirySource": enquirySource,
    "answer": answer,
    "customer": customer?.toJson(),
    "shop": shop?.toJson(),
    "product": product?.toJson(),
    "service": service?.toJson(),
  };
}

// ------------------ Shop ------------------

class Shop {
  final String id;
  final String name;
  final String primaryImageUrl;
  final num rating;
  final int ratingCount;

  Shop({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: _asString(json["id"]),
    name: _asString(json["name"]),
    primaryImageUrl: _asString(json["primaryImageUrl"]),
    rating: _asNum(json["rating"]),
    ratingCount: _asInt(json["ratingCount"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "primaryImageUrl": primaryImageUrl,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

// ------------------ Product & Service (Same Structure) ------------------

class Product {
  final String id;
  final String name;
  final String primaryImageUrl;
  final String price; // API gives "500000.00" (string) sometimes
  final num offerPrice; // API gives number sometimes
  final num rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.price,
    required this.offerPrice,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: _asString(json["id"]),
    name: _asString(json["name"]),
    primaryImageUrl: _asString(json["primaryImageUrl"]),
    price: _asString(json["price"]),
    offerPrice: _asNum(json["offerPrice"]),
    rating: _asNum(json["rating"]),
    ratingCount: _asInt(json["ratingCount"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "primaryImageUrl": primaryImageUrl,
    "price": price,
    "offerPrice": offerPrice,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

class Service {
  final String id;
  final String name;
  final String primaryImageUrl;
  final String price;
  final num offerPrice;
  final num rating;
  final int ratingCount;

  Service({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.price,
    required this.offerPrice,
    required this.rating,
    required this.ratingCount,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: _asString(json["id"]),
    name: _asString(json["name"]),
    primaryImageUrl: _asString(json["primaryImageUrl"]),
    price: _asString(json["price"]),
    offerPrice: _asNum(json["offerPrice"]),
    rating: _asNum(json["rating"]),
    ratingCount: _asInt(json["ratingCount"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "primaryImageUrl": primaryImageUrl,
    "price": price,
    "offerPrice": offerPrice,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

// ------------------ Customer ------------------

class Customer {
  final String name;
  final String avatarUrl;
  final String phone;
  final String whatsappNumber;

  Customer({
    required this.name,
    required this.avatarUrl,
    required this.phone,
    required this.whatsappNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: _asString(json["name"]),
    avatarUrl: _asString(json["avatarUrl"]),
    phone: _asString(json["phone"]),
    whatsappNumber: _asString(json["whatsappNumber"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "avatarUrl": avatarUrl,
    "phone": phone,
    "whatsappNumber": whatsappNumber,
  };
}

/*
// enquiry_analytics_response.dart
// ✅ UPDATED for NEW JSON:
// lists -> enquiries/calls/locations -> open/closed -> { paging, sections }
// ✅ product + service SAME JSON structure

// ------------------ Helpers ------------------

String _asString(dynamic v, [String fallback = ""]) {
  if (v == null) return fallback;
  return v.toString();
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  final n = int.tryParse(s);
  if (n != null) return n;
  final d = double.tryParse(s);
  if (d != null) return d.toInt();
  return fallback;
}

num _asNum(dynamic v, [num fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v;
  final s = v.toString().trim();
  final i = int.tryParse(s);
  if (i != null) return i;
  final d = double.tryParse(s);
  if (d != null) return d;
  return fallback;
}

// ------------------ Enums ------------------

enum EnquiryStatus { open, closed, unknown }

EnquiryStatus enquiryStatusFromString(String? v) {
  switch ((v ?? "").toUpperCase()) {
    case "OPEN":
      return EnquiryStatus.open;
    case "CLOSED":
      return EnquiryStatus.closed;
    default:
      return EnquiryStatus.unknown;
  }
}

String enquiryStatusToString(EnquiryStatus v) {
  switch (v) {
    case EnquiryStatus.open:
      return "OPEN";
    case EnquiryStatus.closed:
      return "CLOSED";
    case EnquiryStatus.unknown:
      return "UNKNOWN";
  }
}

// ------------------ Root ------------------

class EnquiryAnalyticsResponse {
  final bool status;
  final DashboardData data;

  EnquiryAnalyticsResponse({required this.status, required this.data});

  factory EnquiryAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      EnquiryAnalyticsResponse(
        status: json["status"] == true,
        data: DashboardData.fromJson(
          (json["data"] as Map<String, dynamic>?) ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class DashboardData {
  final DateRange range;
  final Counts counts;
  final Lists lists;

  DashboardData({
    required this.range,
    required this.counts,
    required this.lists,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    range: DateRange.fromJson(
      (json["range"] as Map<String, dynamic>?) ?? const {},
    ),
    counts: Counts.fromJson(
      (json["counts"] as Map<String, dynamic>?) ?? const {},
    ),
    lists: Lists.fromJson(
      (json["lists"] as Map<String, dynamic>?) ?? const {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "range": range.toJson(),
    "counts": counts.toJson(),
    "lists": lists.toJson(),
  };
}

class DateRange {
  final String start;
  final String end;

  DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
    start: _asString(json["start"]),
    end: _asString(json["end"]),
  );

  Map<String, dynamic> toJson() => {
    "start": start,
    "end": end,
  };
}

// ------------------ Counts ------------------

class Counts {
  final CountBucket enquiries;
  final CountBucket calls;
  final CountBucket locations;

  Counts({
    required this.enquiries,
    required this.calls,
    required this.locations,
  });

  factory Counts.fromJson(Map<String, dynamic> json) => Counts(
    enquiries: CountBucket.fromJson(
      (json["enquiries"] as Map<String, dynamic>?) ?? const {},
    ),
    calls: CountBucket.fromJson(
      (json["calls"] as Map<String, dynamic>?) ?? const {},
    ),
    locations: CountBucket.fromJson(
      (json["locations"] as Map<String, dynamic>?) ?? const {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "enquiries": enquiries.toJson(),
    "calls": calls.toJson(),
    "locations": locations.toJson(),
  };
}

class CountBucket {
  final int open;
  final int closed;
  final int total;

  CountBucket({required this.open, required this.closed, required this.total});

  factory CountBucket.fromJson(Map<String, dynamic> json) => CountBucket(
    open: _asInt(json["open"]),
    closed: _asInt(json["closed"]),
    total: _asInt(json["total"]),
  );

  Map<String, dynamic> toJson() => {
    "open": open,
    "closed": closed,
    "total": total,
  };
}

// ------------------ Lists ------------------
/// ✅ lists -> enquiries/calls/locations -> StatusLists(open/closed)
class Lists {
  final Map<String, StatusLists> items;

  Lists({required this.items});

  factory Lists.fromJson(Map<String, dynamic> json) {
    final map = <String, StatusLists>{};

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        map[key] = StatusLists.fromJson(value);
      }
    });

    return Lists(items: map);
  }

  Map<String, dynamic> toJson() =>
      items.map((key, value) => MapEntry(key, value.toJson()));

  StatusLists? get enquiries => items["enquiries"];
  StatusLists? get calls => items["calls"];
  StatusLists? get locations => items["locations"];
}

class StatusLists {
  final CommonList open;
  final CommonList closed;

  StatusLists({required this.open, required this.closed});

  factory StatusLists.fromJson(Map<String, dynamic> json) => StatusLists(
    open: CommonList.fromJson(
      (json["open"] as Map<String, dynamic>?) ?? const {},
    ),
    closed: CommonList.fromJson(
      (json["closed"] as Map<String, dynamic>?) ?? const {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "open": open.toJson(),
    "closed": closed.toJson(),
  };
}

class CommonList {
  final Paging paging;
  final List<CommonSection> sections;

  CommonList({required this.paging, required this.sections});

  factory CommonList.fromJson(Map<String, dynamic> json) => CommonList(
    paging: Paging.fromJson(
      (json["paging"] as Map<String, dynamic>?) ?? const {},
    ),
    sections: ((json["sections"] as List<dynamic>?) ?? const [])
        .map((e) => CommonSection.fromJson(
      (e as Map<String, dynamic>?) ?? const {},
    ))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "paging": paging.toJson(),
    "sections": sections.map((e) => e.toJson()).toList(),
  };
}

class Paging {
  final int take;
  final int skip;
  final int total;

  Paging({required this.take, required this.skip, required this.total});

  factory Paging.fromJson(Map<String, dynamic> json) => Paging(
    take: _asInt(json["take"]),
    skip: _asInt(json["skip"]),
    total: _asInt(json["total"]),
  );

  Map<String, dynamic> toJson() => {
    "take": take,
    "skip": skip,
    "total": total,
  };
}

class CommonSection {
  final String dayKey; // "TODAY" or "YYYY-MM-DD"
  final String dayLabel; // "Today" or "13 Jan 2026"
  final List<CommonItem> items;

  CommonSection({
    required this.dayKey,
    required this.dayLabel,
    required this.items,
  });

  factory CommonSection.fromJson(Map<String, dynamic> json) => CommonSection(
    dayKey: _asString(json["dayKey"]),
    dayLabel: _asString(json["dayLabel"]),
    items: ((json["items"] as List<dynamic>?) ?? const [])
        .map((e) => CommonItem.fromJson(
      (e as Map<String, dynamic>?) ?? const {},
    ))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "dayKey": dayKey,
    "dayLabel": dayLabel,
    "items": items.map((e) => e.toJson()).toList(),
  };
}

// ------------------ Item ------------------

class CommonItem {
  final String id;
  final String kind; // "ENQUIRY" / "CALL" / "MAP"
  final EnquiryStatus status; // OPEN/CLOSED -> enum
  final String message;
  final String timeLabel;
  final String dateLabel;
  final String createdAt;

  final String? closedAt;
  final String? contextType; // SHOP / PRODUCT / SERVICE
  final String? productId;
  final String? serviceId;

  final Customer? customer;
  final Shop? shop;
  final Product? product;
  final Service? service;

  CommonItem({
    required this.id,
    required this.kind,
    required this.status,
    required this.message,
    required this.timeLabel,
    required this.dateLabel,
    required this.createdAt,
    required this.closedAt,
    required this.contextType,
    required this.productId,
    required this.serviceId,
    required this.customer,
    required this.shop,
    required this.product,
    required this.service,
  });

  factory CommonItem.fromJson(Map<String, dynamic> json) => CommonItem(
    id: _asString(json["id"]),
    kind: _asString(json["kind"]),
    status: enquiryStatusFromString(json["status"] as String?),
    message: _asString(json["message"]),
    timeLabel: _asString(json["timeLabel"]),
    dateLabel: _asString(json["dateLabel"]),
    createdAt: _asString(json["createdAt"]),
    closedAt: json["closedAt"]?.toString(),
    contextType: json["contextType"]?.toString(),
    productId: json["productId"]?.toString(),
    serviceId: json["serviceId"]?.toString(),
    customer: (json["customer"] is Map<String, dynamic>)
        ? Customer.fromJson(json["customer"] as Map<String, dynamic>)
        : null,
    shop: (json["shop"] is Map<String, dynamic>)
        ? Shop.fromJson(json["shop"] as Map<String, dynamic>)
        : null,
    product: (json["product"] is Map<String, dynamic>)
        ? Product.fromJson(json["product"] as Map<String, dynamic>)
        : null,
    service: (json["service"] is Map<String, dynamic>)
        ? Service.fromJson(json["service"] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "kind": kind,
    "status": enquiryStatusToString(status),
    "message": message,
    "timeLabel": timeLabel,
    "dateLabel": dateLabel,
    "createdAt": createdAt,
    "closedAt": closedAt,
    "contextType": contextType,
    "productId": productId,
    "serviceId": serviceId,
    "customer": customer?.toJson(),
    "shop": shop?.toJson(),
    "product": product?.toJson(),
    "service": service?.toJson(),
  };
}

// ------------------ Shop ------------------

class Shop {
  final String id;
  final String name;
  final String primaryImageUrl;
  final num rating;
  final int ratingCount;

  Shop({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: _asString(json["id"]),
    name: _asString(json["name"]),
    primaryImageUrl: _asString(json["primaryImageUrl"]),
    rating: _asNum(json["rating"]),
    ratingCount: _asInt(json["ratingCount"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "primaryImageUrl": primaryImageUrl,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

// ------------------ Product & Service (Same Structure) ------------------

class Product {
  final String id;
  final String name;
  final String primaryImageUrl;
  final String price; // API gives "500000.00" (string) sometimes
  final num offerPrice; // API gives number sometimes
  final num rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.price,
    required this.offerPrice,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: _asString(json["id"]),
    name: _asString(json["name"]),
    primaryImageUrl: _asString(json["primaryImageUrl"]),
    price: _asString(json["price"]),
    offerPrice: _asNum(json["offerPrice"]),
    rating: _asNum(json["rating"]),
    ratingCount: _asInt(json["ratingCount"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "primaryImageUrl": primaryImageUrl,
    "price": price,
    "offerPrice": offerPrice,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

class Service {
  final String id;
  final String name;
  final String primaryImageUrl;
  final String price;
  final num offerPrice;
  final num rating;
  final int ratingCount;

  Service({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.price,
    required this.offerPrice,
    required this.rating,
    required this.ratingCount,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: _asString(json["id"]),
    name: _asString(json["name"]),
    primaryImageUrl: _asString(json["primaryImageUrl"]),
    price: _asString(json["price"]),
    offerPrice: _asNum(json["offerPrice"]),
    rating: _asNum(json["rating"]),
    ratingCount: _asInt(json["ratingCount"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "primaryImageUrl": primaryImageUrl,
    "price": price,
    "offerPrice": offerPrice,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

// ------------------ Customer ------------------

class Customer {
  final String name;
  final String avatarUrl;
  final String phone;
  final String whatsappNumber;

  Customer({
    required this.name,
    required this.avatarUrl,
    required this.phone,
    required this.whatsappNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: _asString(json["name"]),
    avatarUrl: _asString(json["avatarUrl"]),
    phone: _asString(json["phone"]),
    whatsappNumber: _asString(json["whatsappNumber"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "avatarUrl": avatarUrl,
    "phone": phone,
    "whatsappNumber": whatsappNumber,
  };
}
*/
