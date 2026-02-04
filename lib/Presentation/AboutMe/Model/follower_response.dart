class FollowersResponse {
  final bool status;
  final FollowersData data;

  FollowersResponse({required this.status, required this.data});

  factory FollowersResponse.fromJson(Map<String, dynamic> json) {
    return FollowersResponse(
      status: (json['status'] as bool?) ?? false,
      data: FollowersData.fromJson((json['data'] as Map<String, dynamic>?) ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
}

class FollowersData {
  final bool success;
  final bool canViewProfiles;
  final Counts counts;
  final String range;
  final Paging paging;
  final List<FollowerItem> items;

  FollowersData({
    required this.success,
    required this.canViewProfiles,
    required this.counts,
    required this.range,
    required this.paging,
    required this.items,
  });

  factory FollowersData.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? const [];

    return FollowersData(
      success: (json['success'] as bool?) ?? false,
      canViewProfiles: (json['canViewProfiles'] as bool?) ?? true,
      counts: Counts.fromJson((json['counts'] as Map<String, dynamic>?) ?? const {}),
      range: (json['range']?.toString()) ?? 'ALL',
      paging: Paging.fromJson((json['paging'] as Map<String, dynamic>?) ?? const {}),
      items: itemsJson
          .whereType<Map>() // safety
          .map((e) => FollowerItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'canViewProfiles': canViewProfiles,
    'counts': counts.toJson(),
    'range': range,
    'paging': paging.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class Counts {
  final int week;
  final int month;
  final int all;

  Counts({required this.week, required this.month, required this.all});

  factory Counts.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return Counts(
      week: _toInt(json['week']),
      month: _toInt(json['month']),
      all: _toInt(json['all']),
    );
  }

  Map<String, dynamic> toJson() => {'week': week, 'month': month, 'all': all};
}

class Paging {
  final int take;
  final int skip;
  final int total;

  Paging({required this.take, required this.skip, required this.total});

  factory Paging.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return Paging(
      take: _toInt(json['take']),
      skip: _toInt(json['skip']),
      total: _toInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {'take': take, 'skip': skip, 'total': total};
}

class FollowerItem {
  final String id;
  final String followerUserId;
  final String followerName;
  final String avatarUrl;
  final bool isBlurred;
  final DateTime joinedAt;
  final String joinedLabel;

  FollowerItem({
    required this.id,
    required this.followerUserId,
    required this.followerName,
    required this.avatarUrl,
    required this.isBlurred,
    required this.joinedAt,
    required this.joinedLabel,
  });

  factory FollowerItem.fromJson(Map<String, dynamic> json) {
    // safe datetime parse
    DateTime _parseDate(dynamic v) {
      final s = v?.toString();
      if (s == null || s.trim().isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return FollowerItem(
      id: (json['id']?.toString()) ?? '',
      followerUserId: (json['followerUserId']?.toString()) ?? '',
      followerName: (json['followerName']?.toString()) ?? 'Unknown',
      avatarUrl: (json['avatarUrl']?.toString()) ?? '', // ✅ null-safe
      isBlurred: (json['isBlurred'] as bool?) ?? false,
      joinedAt: _parseDate(json['joinedAt']),
      joinedLabel: (json['joinedLabel']?.toString()) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'followerUserId': followerUserId,
    'followerName': followerName,
    'avatarUrl': avatarUrl,
    'isBlurred': isBlurred,
    'joinedAt': joinedAt.toIso8601String(),
    'joinedLabel': joinedLabel,
  };
}


// class FollowersResponse {
//   final bool status;
//   final FollowersData data;
//
//   FollowersResponse({required this.status, required this.data});
//
//   factory FollowersResponse.fromJson(Map<String, dynamic> json) {
//     return FollowersResponse(
//       status: json['status'] as bool,
//       data: FollowersData.fromJson(json['data'] as Map<String, dynamic>),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
// }
//
// class FollowersData {
//   final bool success;
//   final bool canViewProfiles;
//   final Counts counts;
//   final String range;
//   final Paging paging;
//   final List<FollowerItem> items;
//
//   FollowersData({
//     required this.success,
//     required this.canViewProfiles,
//     required this.counts,
//     required this.range,
//     required this.paging,
//     required this.items,
//   });
//
//   factory FollowersData.fromJson(Map<String, dynamic> json) {
//     return FollowersData(
//       success: json['success'] as bool,
//       canViewProfiles: json['canViewProfiles'] as bool,
//       counts: Counts.fromJson(json['counts'] as Map<String, dynamic>),
//       range: json['range'] as String,
//       paging: Paging.fromJson(json['paging'] as Map<String, dynamic>),
//       items: (json['items'] as List<dynamic>)
//           .map((e) => FollowerItem.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'success': success,
//     'canViewProfiles': canViewProfiles,
//     'counts': counts.toJson(),
//     'range': range,
//     'paging': paging.toJson(),
//     'items': items.map((e) => e.toJson()).toList(),
//   };
// }
//
// class Counts {
//   final int week;
//   final int month;
//   final int all;
//
//   Counts({required this.week, required this.month, required this.all});
//
//   factory Counts.fromJson(Map<String, dynamic> json) {
//     return Counts(
//       week: (json['week'] as num).toInt(),
//       month: (json['month'] as num).toInt(),
//       all: (json['all'] as num).toInt(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {'week': week, 'month': month, 'all': all};
// }
//
// class Paging {
//   final int take;
//   final int skip;
//   final int total;
//
//   Paging({required this.take, required this.skip, required this.total});
//
//   factory Paging.fromJson(Map<String, dynamic> json) {
//     return Paging(
//       take: (json['take'] as num).toInt(),
//       skip: (json['skip'] as num).toInt(),
//       total: (json['total'] as num).toInt(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {'take': take, 'skip': skip, 'total': total};
// }
//
// class FollowerItem {
//   final String id;
//   final String followerUserId;
//   final String followerName;
//   final String avatarUrl;
//   final bool isBlurred;
//   final DateTime joinedAt;
//   final String joinedLabel;
//
//   FollowerItem({
//     required this.id,
//     required this.followerUserId,
//     required this.followerName,
//     required this.avatarUrl,
//     required this.isBlurred,
//     required this.joinedAt,
//     required this.joinedLabel,
//   });
//
//   factory FollowerItem.fromJson(Map<String, dynamic> json) {
//     return FollowerItem(
//       id: json['id'] as String,
//       followerUserId: json['followerUserId'] as String,
//       followerName: json['followerName'] as String,
//       avatarUrl: json['avatarUrl'] as String,
//       isBlurred: json['isBlurred'] as bool,
//       joinedAt: DateTime.parse(json['joinedAt'] as String),
//       joinedLabel: json['joinedLabel'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'followerUserId': followerUserId,
//     'followerName': followerName,
//     'avatarUrl': avatarUrl,
//     'isBlurred': isBlurred,
//     'joinedAt': joinedAt.toIso8601String(),
//     'joinedLabel': joinedLabel,
//   };
// }
