class ServiceDeleteResponse {
  final bool status;
  final ResponseData? data;

  const ServiceDeleteResponse({
    required this.status,
    this.data,
  });

  factory ServiceDeleteResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDeleteResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? ResponseData.fromJson(
        json['data'] as Map<String, dynamic>,
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class ResponseData {
  final bool success;

  const ResponseData({
    required this.success,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}
