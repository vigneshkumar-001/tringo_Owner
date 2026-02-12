class ShopsResponse {
  final bool status;
  final ShopsData data;

  const ShopsResponse({required this.status, required this.data});

  factory ShopsResponse.fromJson(Map<String, dynamic> json) {
    return ShopsResponse(
      status: json['status'] == true,
      data: ShopsData.fromJson((json['data'] ?? {}) as Map<String, dynamic>),
    );
  }
}

class ShopsData {
  final bool isNewOwner;
  final List<Shop> items;
  final Subscription subscription;
  final bool canCreateMoreShops;
  final int remainingShops;

  // ✅ NEW
  final HomeChart? homeChart;

  const ShopsData({
    required this.isNewOwner,
    required this.items,
    required this.subscription,
    required this.canCreateMoreShops,
    required this.remainingShops,
    required this.homeChart,
  });

  factory ShopsData.fromJson(Map<String, dynamic> json) {
    return ShopsData(
      isNewOwner: json['isNewOwner'] == true,
      items: (json['items'] as List? ?? const [])
          .map((e) => Shop.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      subscription: Subscription.fromJson(
        (json['subscription'] as Map? ?? const {}).cast<String, dynamic>(),
      ),
      canCreateMoreShops: json['canCreateMoreShops'] == true,
      remainingShops: (json['remainingShops'] ?? 0) is int
          ? (json['remainingShops'] ?? 0) as int
          : int.tryParse((json['remainingShops'] ?? '0').toString()) ?? 0,

      // ✅ NEW (nullable)
      homeChart: (json['homeChart'] is Map)
          ? HomeChart.fromJson(
              (json['homeChart'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class Subscription {
  final bool isFreemium;
  final int maxShopsAllowed;
  final String planType;

  const Subscription({
    required this.isFreemium,
    required this.maxShopsAllowed,
    required this.planType,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      isFreemium: json['isFreemium'] == true,
      maxShopsAllowed: (json['maxShopsAllowed'] ?? 0) is int
          ? (json['maxShopsAllowed'] ?? 0) as int
          : int.tryParse((json['maxShopsAllowed'] ?? '0').toString()) ?? 0,
      planType: (json['planType'] ?? '').toString(),
    );
  }
}

class Shop {
  final String id;
  final String englishName;
  final String tamilName;
  final String city;
  final String shopKind;
  final String category;
  final String subCategory;
  final String addressEn;
  final String addressTa;
  final String? primaryImageUrl;

  const Shop({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.city,
    required this.shopKind,
    required this.category,
    required this.subCategory,
    required this.addressEn,
    required this.addressTa,
    this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: (json['id'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      shopKind: (json['shopKind'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      addressEn: (json['addressEn'] ?? '').toString(),
      addressTa: (json['addressTa'] ?? '').toString(),
      primaryImageUrl: json['primaryImageUrl']?.toString(),
    );
  }
}

//
// ✅ NEW: HomeChart Models
//

class HomeChart {
  final String shopId;
  final String filter; // DAY/WEEK/MONTH/YEAR
  final ChartRange range;
  final HomeTotals totals;
  final List<HomeSeriesPoint> series;

  const HomeChart({
    required this.shopId,
    required this.filter,
    required this.range,
    required this.totals,
    required this.series,
  });

  factory HomeChart.fromJson(Map<String, dynamic> json) {
    return HomeChart(
      shopId: (json['shopId'] ?? '').toString(),
      filter: (json['filter'] ?? '').toString(),
      range: ChartRange.fromJson((json['range'] ?? {}) as Map<String, dynamic>),
      totals: HomeTotals.fromJson((json['totals'] ?? {}) as Map<String, dynamic>),
      series: (json['series'] as List? ?? const [])
          .map((e) => HomeSeriesPoint.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class ChartRange {
  final String start;
  final String end;

  const ChartRange({required this.start, required this.end});

  factory ChartRange.fromJson(Map<String, dynamic> json) {
    return ChartRange(
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
    );
  }
}

class HomeTotals {
  final int reach;
  final int enquiries;
  final int calls;
  final int directions;

  const HomeTotals({
    required this.reach,
    required this.enquiries,
    required this.calls,
    required this.directions,
  });

  factory HomeTotals.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) => v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return HomeTotals(
      reach: _i(json['reach']),
      enquiries: _i(json['enquiries']),
      calls: _i(json['calls']),
      directions: _i(json['directions']),
    );
  }
}

class HomeSeriesPoint {
  final String key;   // "2026-02-06"
  final String label; // "06"
  final int value;

  const HomeSeriesPoint({
    required this.key,
    required this.label,
    required this.value,
  });

  factory HomeSeriesPoint.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) => v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return HomeSeriesPoint(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      value: _i(json['value']),
    );
  }
}




class ChartTotals {
  final int profileViews;
  final int enquiries;
  final int orders;
  final int followersGained;
  final int calls;
  final int mapClicks;

  const ChartTotals({
    required this.profileViews,
    required this.enquiries,
    required this.orders,
    required this.followersGained,
    required this.calls,
    required this.mapClicks,
  });

  factory ChartTotals.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) =>
        v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return ChartTotals(
      profileViews: _i(json['profileViews']),
      enquiries: _i(json['enquiries']),
      orders: _i(json['orders']),
      followersGained: _i(json['followersGained']),
      calls: _i(json['calls']),
      mapClicks: _i(json['mapClicks']),
    );
  }
}

class ChartSeries {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String period; // "2026-01-28"
  final int profileViews;
  final int enquiries;
  final int orders;
  final int followersGained;
  final int calls;
  final int mapClicks;

  const ChartSeries({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.period,
    required this.profileViews,
    required this.enquiries,
    required this.orders,
    required this.followersGained,
    required this.calls,
    required this.mapClicks,
  });

  factory ChartSeries.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s)?.toLocal();
    }

    int _i(dynamic v) =>
        v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    return ChartSeries(
      id: (json['id'] ?? '').toString(),
      createdAt: _dt(json['createdAt']),
      updatedAt: _dt(json['updatedAt']),
      period: (json['period'] ?? '').toString(),
      profileViews: _i(json['profileViews']),
      enquiries: _i(json['enquiries']),
      orders: _i(json['orders']),
      followersGained: _i(json['followersGained']),
      calls: _i(json['calls']),
      mapClicks: _i(json['mapClicks']),
    );
  }
}
