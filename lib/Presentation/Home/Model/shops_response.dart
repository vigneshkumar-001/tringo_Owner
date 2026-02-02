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
  final ChartRange range;
  final ChartTotals totals;
  final List<ChartSeries> series;

  const HomeChart({
    required this.shopId,
    required this.range,
    required this.totals,
    required this.series,
  });

  factory HomeChart.fromJson(Map<String, dynamic> json) {
    return HomeChart(
      shopId: (json['shopId'] ?? '').toString(),
      range: ChartRange.fromJson((json['range'] ?? {}) as Map<String, dynamic>),
      totals: ChartTotals.fromJson(
        (json['totals'] ?? {}) as Map<String, dynamic>,
      ),
      series: (json['series'] as List? ?? const [])
          .map((e) => ChartSeries.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class ChartRange {
  final String start; // "2026-01-23"
  final String end; // "2026-01-30"

  const ChartRange({required this.start, required this.end});

  factory ChartRange.fromJson(Map<String, dynamic> json) {
    return ChartRange(
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
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

// class ShopsResponse {
//   final bool status;
//   final ShopsData data;
//
//   ShopsResponse({required this.status, required this.data});
//
//   factory ShopsResponse.fromJson(Map<String, dynamic> json) {
//     return ShopsResponse(
//       status: json['status'] ?? false,
//       data: ShopsData.fromJson(json['data'] ?? {}),
//     );
//   }
// }
//
// class ShopsData {
//   final bool isNewOwner;
//   final List<Shop> items;
//   final Subscription subscription;
//   final bool canCreateMoreShops;
//   final int remainingShops;
//
//   ShopsData({
//     required this.isNewOwner,
//     required this.items,
//     required this.subscription,
//     required this.canCreateMoreShops,
//     required this.remainingShops,
//   });
//
//   factory ShopsData.fromJson(Map<String, dynamic> json) {
//     return ShopsData(
//       isNewOwner: json['isNewOwner'] == true,
//       items: (json['items'] as List<dynamic>? ?? [])
//           .map((e) => Shop.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       subscription: Subscription.fromJson(
//         json['subscription'] as Map<String, dynamic>? ?? {},
//       ),
//       canCreateMoreShops: json['canCreateMoreShops'] == true,
//       remainingShops: json['remainingShops'] ?? 0,
//     );
//   }
// }
//
// class Subscription {
//   final bool isFreemium;
//   final int maxShopsAllowed;
//   final String planType;
//
//   Subscription({
//     required this.isFreemium,
//     required this.maxShopsAllowed,
//     required this.planType,
//   });
//
//   factory Subscription.fromJson(Map<String, dynamic> json) {
//     return Subscription(
//       isFreemium: json['isFreemium'] == true,
//       maxShopsAllowed: json['maxShopsAllowed'] ?? 0,
//       planType: json['planType'] ?? '',
//     );
//   }
// }
//
// class Shop {
//   final String id;
//   final String englishName;
//   final String tamilName;
//   final String city;
//   final String shopKind;
//   final String category;
//   final String subCategory;
//   final String addressEn;
//   final String addressTa;
//   final String? primaryImageUrl;
//
//   Shop({
//     required this.id,
//     required this.englishName,
//     required this.tamilName,
//     required this.city,
//     required this.shopKind,
//     required this.category,
//     required this.subCategory,
//     required this.addressEn,
//     required this.addressTa,
//     this.primaryImageUrl,
//   });
//
//   factory Shop.fromJson(Map<String, dynamic> json) {
//     return Shop(
//       id: json['id'] ?? '',
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'] ?? '',
//       city: json['city'] ?? '',
//       shopKind: json['shopKind'] ?? '',
//       category: json['category'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       addressEn: json['addressEn'] ?? '',
//       addressTa: json['addressTa'] ?? '',
//       primaryImageUrl: json['primaryImageUrl'],
//     );
//   }
// }
