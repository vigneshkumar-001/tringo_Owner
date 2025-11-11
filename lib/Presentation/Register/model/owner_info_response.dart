

class  OwnerInfoResponse  {
  final bool success;
  final String message;

  OwnerInfoResponse({required this.success, required this.message});

  factory OwnerInfoResponse.fromJson(Map<String, dynamic> json) {
    return OwnerInfoResponse(
      success: json["success"] == true,
      message: json["msg"] ?? json["message"] ?? "",
    );
  }
}
