class QrActionResponse {
  final bool status;
  final QrActionData? data;

  const QrActionResponse({required this.status, this.data});

  factory QrActionResponse.fromJson(Map<String, dynamic> json) {
    return QrActionResponse(
      status: json['status'] == true,
      data: (json['data'] is Map)
          ? QrActionData.fromJson((json['data'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

enum QrActionType { choose, unknown }

QrActionType qrActionTypeFromString(String? v) {
  final s = (v ?? '').trim().toUpperCase();
  if (s == 'CHOOSE') return QrActionType.choose;
  return QrActionType.unknown;
}

String qrActionTypeToString(QrActionType t) {
  switch (t) {
    case QrActionType.choose:
      return 'CHOOSE';
    case QrActionType.unknown:
      return 'UNKNOWN';
  }
}

class QrActionData {
  final String shopId;
  final QrActionType action;
  final String qrImageUrl;
  final String downloadUrl; // ✅ NEW
  final String deepLink;
  final DateTime? expiresAt; // nullable
  final String? shopName; // nullable

  const QrActionData({
    required this.shopId,
    required this.action,
    required this.qrImageUrl,
    required this.downloadUrl,
    required this.deepLink,
    required this.expiresAt,
    required this.shopName,
  });

  factory QrActionData.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String && v.trim().isNotEmpty) {
        return DateTime.tryParse(v)?.toLocal();
      }
      return null;
    }

    return QrActionData(
      shopId: (json['shopId'] ?? '').toString(),
      action: qrActionTypeFromString(json['action']?.toString()),
      qrImageUrl: (json['qrImageUrl'] ?? '').toString(),
      downloadUrl: (json['downloadUrl'] ?? '').toString(), // ✅
      deepLink: (json['deepLink'] ?? '').toString(),
      expiresAt: parseDate(json['expiresAt']),
      shopName: json['shopName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'shopId': shopId,
    'action': qrActionTypeToString(action),
    'qrImageUrl': qrImageUrl,
    'downloadUrl': downloadUrl,
    'deepLink': deepLink,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'shopName': shopName,
  };
}
