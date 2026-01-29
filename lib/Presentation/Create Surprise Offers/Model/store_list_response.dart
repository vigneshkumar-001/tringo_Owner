class StoreListResponse {
  final bool status;
  final StoreListData? data;

  StoreListResponse({required this.status, this.data});

  factory StoreListResponse.fromJson(Map<String, dynamic> json) {
    return StoreListResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? StoreListData.fromJson(json['data']) : null,
    );
  }
}

class StoreListData {
  final List<StoreItem> items;

  StoreListData({required this.items});

  factory StoreListData.fromJson(Map<String, dynamic> json) {
    return StoreListData(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => StoreItem.fromJson(e))
          .toList(),
    );
  }
}

class StoreItem {
  final String id;
  final String label;
  final String address;
  final String city;
  final String state;
  final String bannerUrl;
  final String phone;

  StoreItem({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.state,
    required this.bannerUrl,
    required this.phone,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
