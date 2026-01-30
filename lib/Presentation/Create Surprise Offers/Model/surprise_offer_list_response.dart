// surprise_offer_models.dart

class SurpriseOfferListResponse {
  final bool status;
  final SurpriseOfferListData data;

  const SurpriseOfferListResponse({
    required this.status,
    required this.data,
  });

  factory SurpriseOfferListResponse.fromJson(Map<String, dynamic> json) {
    return SurpriseOfferListResponse(
      status: json['status'] == true,
      data: SurpriseOfferListData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class SurpriseOfferListData {
  final OfferShop shop;

  final int liveCount;
  final int upcomingCount;
  final int expiredCount;

  final List<OfferSection> liveSections;
  final List<OfferSection> upcomingSections;
  final List<OfferSection> expiredSections;

  const SurpriseOfferListData({
    required this.shop,
    required this.liveCount,
    required this.upcomingCount,
    required this.expiredCount,
    required this.liveSections,
    required this.upcomingSections,
    required this.expiredSections,
  });

  factory SurpriseOfferListData.fromJson(Map<String, dynamic> json) {
    return SurpriseOfferListData(
      shop: OfferShop.fromJson(
        (json['shop'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      liveCount: (json['liveCount'] as num?)?.toInt() ?? 0,
      upcomingCount: (json['upcomingCount'] as num?)?.toInt() ?? 0,
      expiredCount: (json['expiredCount'] as num?)?.toInt() ?? 0,
      liveSections: OfferSection.listFrom(json['liveSections']),
      upcomingSections: OfferSection.listFrom(json['upcomingSections']),
      expiredSections: OfferSection.listFrom(json['expiredSections']),
    );
  }

  Map<String, dynamic> toJson() => {
    "shop": shop.toJson(),
    "liveCount": liveCount,
    "upcomingCount": upcomingCount,
    "expiredCount": expiredCount,
    "liveSections": liveSections.map((e) => e.toJson()).toList(),
    "upcomingSections": upcomingSections.map((e) => e.toJson()).toList(),
    "expiredSections": expiredSections.map((e) => e.toJson()).toList(),
  };
}

class OfferShop {
  final String id;
  final String name;
  final String address;
  final String? bannerUrl;

  const OfferShop({
    required this.id,
    required this.name,
    required this.address,
    this.bannerUrl,
  });

  factory OfferShop.fromJson(Map<String, dynamic> json) {
    return OfferShop(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      bannerUrl: json['bannerUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "bannerUrl": bannerUrl,
  };
}

class OfferSection {
  final String dayLabel; // "Yesterday" or "27 Jan 2026"
  final List<OfferItem> items;

  const OfferSection({
    required this.dayLabel,
    required this.items,
  });

  factory OfferSection.fromJson(Map<String, dynamic> json) {
    return OfferSection(
      dayLabel: (json['dayLabel'] ?? '').toString(),
      items: OfferItem.listFrom(json['items']),
    );
  }

  Map<String, dynamic> toJson() => {
    "dayLabel": dayLabel,
    "items": items.map((e) => e.toJson()).toList(),
  };

  static List<OfferSection> listFrom(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => OfferSection.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return <OfferSection>[];
  }
}

class OfferItem {
  final String id;
  final String title;
  final String description;
  final String? bannerUrl;
  final String branchId;

  final DateTime? createdAt;
  final String createdTime;

  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String availableRangeLabel;

  final OfferCoupons coupons;
  final OfferClaimers claimers;

  final String statusEnum; // "ACTIVE" / "EXPIRED"
  final String stateLabel; // "LIVE" / "EXPIRED"
  final bool editable;
  final String source; // "SURPRISE_OFFER"

  const OfferItem({
    required this.id,
    required this.title,
    required this.description,
    this.bannerUrl,
    required this.branchId,
    required this.createdAt,
    required this.createdTime,
    required this.availableFrom,
    required this.availableTo,
    required this.availableRangeLabel,
    required this.coupons,
    required this.claimers,
    required this.statusEnum,
    required this.stateLabel,
    required this.editable,
    required this.source,
  });

  factory OfferItem.fromJson(Map<String, dynamic> json) {
    return OfferItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      bannerUrl: json['bannerUrl']?.toString(),
      branchId: (json['branchId'] ?? '').toString(),
      createdAt: _tryParseDate(json['createdAt']),
      createdTime: (json['createdTime'] ?? '').toString(),
      availableFrom: _tryParseDate(json['availableFrom']),
      availableTo: _tryParseDate(json['availableTo']),
      availableRangeLabel: (json['availableRangeLabel'] ?? '').toString(),
      coupons: OfferCoupons.fromJson(
        (json['coupons'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      claimers: OfferClaimers.fromJson(
        (json['claimers'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      statusEnum: (json['statusEnum'] ?? '').toString(),
      stateLabel: (json['stateLabel'] ?? '').toString(),
      editable: json['editable'] == true,
      source: (json['source'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "bannerUrl": bannerUrl,
    "branchId": branchId,
    "createdAt": createdAt?.toIso8601String(),
    "createdTime": createdTime,
    "availableFrom": availableFrom?.toIso8601String(),
    "availableTo": availableTo?.toIso8601String(),
    "availableRangeLabel": availableRangeLabel,
    "coupons": coupons.toJson(),
    "claimers": claimers.toJson(),
    "statusEnum": statusEnum,
    "stateLabel": stateLabel,
    "editable": editable,
    "source": source,
  };

  static List<OfferItem> listFrom(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => OfferItem.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return <OfferItem>[];
  }

  static DateTime? _tryParseDate(dynamic v) {
    final s = v?.toString();
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}

class OfferCoupons {
  final int claimed;
  final int total;
  final String label; // "0 Out of 5"

  const OfferCoupons({
    required this.claimed,
    required this.total,
    required this.label,
  });

  factory OfferCoupons.fromJson(Map<String, dynamic> json) {
    return OfferCoupons(
      claimed: (json['claimed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      label: (json['label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "claimed": claimed,
    "total": total,
    "label": label,
  };
}

class OfferClaimers {
  final List<ClaimerPreview> preview;
  final int total;
  final bool canShowMore;

  const OfferClaimers({
    required this.preview,
    required this.total,
    required this.canShowMore,
  });

  factory OfferClaimers.fromJson(Map<String, dynamic> json) {
    return OfferClaimers(
      preview: ClaimerPreview.listFrom(json['preview']),
      total: (json['total'] as num?)?.toInt() ?? 0,
      canShowMore: json['canShowMore'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    "preview": preview.map((e) => e.toJson()).toList(),
    "total": total,
    "canShowMore": canShowMore,
  };
}

class ClaimerPreview {
  final String? displayName;
  final String? contact; // phone number
  final DateTime? claimedAt;
  final String claimedLabel; // "1:06 PM  •  29 Jan 26"
  final String? callUri; // (tel:...)
  final String? whatsappUri; // (https://wa.me/...)

  const ClaimerPreview({
    this.displayName,
    this.contact,
    this.claimedAt,
    required this.claimedLabel,
    this.callUri,
    this.whatsappUri,
  });

  static String? _pickStr(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  factory ClaimerPreview.fromJson(Map<String, dynamic> json) {
    final displayName = _pickStr(json, [
      'displayName',
      'name',
      'customerName',
      'fullName',
    ]);

    final contact = _pickStr(json, [
      'contact',
      'phone',
      'mobile',
      'mobileNumber',
      'contactNumber',
      'whatsappNumber',
    ]);

    final callUri = _pickStr(json, [
      'callUri',
      'call_uri',
      'callUrl',
      'call_url',
      'tel',
      'telUri',
    ]);

    final whatsappUri = _pickStr(json, [
      'whatsappUri',
      'whatsapp_uri',
      'whatsappUrl',
      'whatsapp_url',
      'wa',
      'waLink',
      'whatsappLink',
    ]);

    return ClaimerPreview(
      displayName: displayName,
      contact: contact,
      claimedAt: _tryParseDate(json['claimedAt'] ?? json['claimed_at']),
      claimedLabel: (json['claimedLabel'] ?? json['claimed_label'] ?? '').toString(),
      callUri: callUri,
      whatsappUri: whatsappUri,
    );
  }

  Map<String, dynamic> toJson() => {
    "displayName": displayName,
    "contact": contact,
    "claimedAt": claimedAt?.toIso8601String(),
    "claimedLabel": claimedLabel,
    "callUri": callUri,
    "whatsappUri": whatsappUri,
  };

  static List<ClaimerPreview> listFrom(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => ClaimerPreview.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return <ClaimerPreview>[];
  }

  static DateTime? _tryParseDate(dynamic v) {
    final s = v?.toString();
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}

