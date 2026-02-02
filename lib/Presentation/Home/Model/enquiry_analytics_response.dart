class EnquiryAnalyticsResponse {
  final bool status;
  final EnquiryAnalyticsData data;

  const EnquiryAnalyticsResponse({
    required this.status,
    required this.data,
  });

  factory EnquiryAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryAnalyticsResponse(
      status: json['status'] == true,
      data: EnquiryAnalyticsData.fromJson(
        (json['data'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }
}

class EnquiryAnalyticsData {
  final DateRange range;
  final EnquiryCounts counts;
  final EnquiryLists lists;

  const EnquiryAnalyticsData({
    required this.range,
    required this.counts,
    required this.lists,
  });

  factory EnquiryAnalyticsData.fromJson(Map<String, dynamic> json) {
    return EnquiryAnalyticsData(
      range: DateRange.fromJson((json['range'] ?? {}) as Map<String, dynamic>),
      counts:
      EnquiryCounts.fromJson((json['counts'] ?? {}) as Map<String, dynamic>),
      lists: EnquiryLists.fromJson((json['lists'] ?? {}) as Map<String, dynamic>),
    );
  }
}

class DateRange {
  final String start; // "2026-01-01"
  final String end; // "2026-01-31"

  const DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
    );
  }
}

class EnquiryCounts {
  final EnquiryCountSummary enquiries;

  const EnquiryCounts({required this.enquiries});

  factory EnquiryCounts.fromJson(Map<String, dynamic> json) {
    return EnquiryCounts(
      enquiries: EnquiryCountSummary.fromJson(
        (json['enquiries'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }
}

class EnquiryCountSummary {
  final int open;
  final int closed;
  final int total;

  const EnquiryCountSummary({
    required this.open,
    required this.closed,
    required this.total,
  });

  factory EnquiryCountSummary.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) => v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return EnquiryCountSummary(
      open: _i(json['open']),
      closed: _i(json['closed']),
      total: _i(json['total']),
    );
  }
}

class EnquiryLists {
  final EnquiryList enquiries;

  const EnquiryLists({required this.enquiries});

  factory EnquiryLists.fromJson(Map<String, dynamic> json) {
    return EnquiryLists(
      enquiries: EnquiryList.fromJson(
        (json['enquiries'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }
}

class EnquiryList {
  final Paging paging;
  final List<EnquirySection> sections;
  final String status; // "OPEN"

  const EnquiryList({
    required this.paging,
    required this.sections,
    required this.status,
  });

  factory EnquiryList.fromJson(Map<String, dynamic> json) {
    return EnquiryList(
      paging: Paging.fromJson((json['paging'] ?? {}) as Map<String, dynamic>),
      sections: (json['sections'] as List? ?? const [])
          .map((e) => EnquirySection.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class Paging {
  final int take;
  final int skip;
  final int total;

  const Paging({required this.take, required this.skip, required this.total});

  factory Paging.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) => v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return Paging(
      take: _i(json['take']),
      skip: _i(json['skip']),
      total: _i(json['total']),
    );
  }
}

class EnquirySection {
  final String dayKey; // "TODAY"
  final String dayLabel; // "Today"
  final List<EnquiryItem> items;

  const EnquirySection({
    required this.dayKey,
    required this.dayLabel,
    required this.items,
  });

  factory EnquirySection.fromJson(Map<String, dynamic> json) {
    return EnquirySection(
      dayKey: (json['dayKey'] ?? '').toString(),
      dayLabel: (json['dayLabel'] ?? '').toString(),
      items: (json['items'] as List? ?? const [])
          .map((e) => EnquiryItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class EnquiryItem {
  final String id;
  final String status; // "OPEN"
  final String message;
  final String timeLabel; // "1:13pm"
  final String dateLabel; // "30 Jan 2026"
  final DateTime? createdAt;

  final EnquiryShop shop;
  final dynamic product; // null now (replace with Product model later if needed)
  final dynamic service; // null now (replace with Service model later if needed)
  final EnquiryCustomer customer;

  const EnquiryItem({
    required this.id,
    required this.status,
    required this.message,
    required this.timeLabel,
    required this.dateLabel,
    required this.createdAt,
    required this.shop,
    required this.product,
    required this.service,
    required this.customer,
  });

  factory EnquiryItem.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s)?.toLocal();
    }

    return EnquiryItem(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      timeLabel: (json['timeLabel'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? '').toString(),
      createdAt: _dt(json['createdAt']),
      shop: EnquiryShop.fromJson((json['shop'] ?? {}) as Map<String, dynamic>),
      product: json['product'], // null currently
      service: json['service'], // null currently
      customer: EnquiryCustomer.fromJson(
        (json['customer'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }
}

class EnquiryShop {
  final String id;
  final String name;
  final String? primaryImageUrl;
  final double rating;
  final int ratingCount;

  const EnquiryShop({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory EnquiryShop.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse((v ?? '0').toString()) ?? 0.0;
    int _i(dynamic v) => v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return EnquiryShop(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      primaryImageUrl: json['primaryImageUrl']?.toString(),
      rating: _d(json['rating']),
      ratingCount: _i(json['ratingCount']),
    );
  }
}

class EnquiryCustomer {
  final String name;
  final String? avatarUrl;
  final String phone;
  final String whatsappNumber;

  const EnquiryCustomer({
    required this.name,
    required this.avatarUrl,
    required this.phone,
    required this.whatsappNumber,
  });

  factory EnquiryCustomer.fromJson(Map<String, dynamic> json) {
    return EnquiryCustomer(
      name: (json['name'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      phone: (json['phone'] ?? '').toString(),
      whatsappNumber: (json['whatsappNumber'] ?? '').toString(),
    );
  }
}
