class  CreateSurpriseResponse  {
  final bool status;
  final CreateSurpriseData? data;

  CreateSurpriseResponse({
    required this.status,
    this.data,
  });

  factory CreateSurpriseResponse.fromJson(Map<String, dynamic> json) {
    return CreateSurpriseResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? CreateSurpriseData.fromJson(json['data'])
          : null,
    );
  }
}
class CreateSurpriseData {
  final String id;

  CreateSurpriseData({required this.id});

  factory CreateSurpriseData.fromJson(Map<String, dynamic> json) {
    return CreateSurpriseData(
      id: json['id'] ?? '',
    );
  }
}
