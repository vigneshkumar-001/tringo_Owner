class AccountDeleteResponse {
  final bool status;
  final int code;
  final String? message;
  final DeleteData data; // ✅ ADD THIS

  AccountDeleteResponse({
    required this.status,
    required this.code,
    required this.data, // ✅ ADD THIS
    this.message,
  });

  factory AccountDeleteResponse.fromJson(Map<String, dynamic> json) {
    return AccountDeleteResponse(
      status: json['status'] == true,
      code: (json['code'] is int)
          ? json['code']
          : int.tryParse('${json['code']}') ?? 0,
      message: json['message']?.toString(),
      data: DeleteData.fromJson((json['data'] as Map?)?.cast<String, dynamic>() ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'message': message,
    'data': data.toJson(),
  };
}

class DeleteData {
  final bool deleted;

  DeleteData({required this.deleted});

  factory DeleteData.fromJson(Map<String, dynamic> json) {
    return DeleteData(deleted: json['deleted'] == true);
  }

  Map<String, dynamic> toJson() => {'deleted': deleted};
}
