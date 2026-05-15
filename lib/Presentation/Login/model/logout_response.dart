class LogoutResponse {
  final bool status;
  final int? code;
  final LogoutData? data;
  final String? message;

  const LogoutResponse({
    required this.status,
    this.code,
    this.data,
    this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] == true,
      code: json['code'] is int ? json['code'] as int : int.tryParse('${json['code']}'),
      data: json['data'] is Map ? LogoutData.fromJson((json['data'] as Map).cast<String, dynamic>()) : null,
      message: json['message']?.toString(),
    );
  }
}

class LogoutData {
  final bool success;

  const LogoutData({required this.success});

  factory LogoutData.fromJson(Map<String, dynamic> json) {
    return LogoutData(success: json['success'] == true);
  }
}

