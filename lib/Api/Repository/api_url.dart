class ApiUrl {
  // static const String base = "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";
  static const String base = "https://vk6shsk1-3000.inc1.devtunnels.ms/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String ownerInfo = "${base}api/v1/business";
  static const String shop = "${base}api/v1/shops";
  static String imageUrl =
      "https://next.fenizotechnologies.com/Adrox/api/image-save";
  static const String categoriesShop =
      "${base}api/v1/public/categories?type=shop";

  static String shopPhotosUpload({required String shopId}) {
    return "${base}api/v1/shops/$shopId/media";
  }

  static String updateShop({required String shopId}) {
    return "${base}api/v1/shops/edit/$shopId";
  }

  static String searchKeyWords({required String shopId}) {
    return "${base}api/v1/shops/$shopId/keywords";
  }

  static String addProducts({required String shopId}) {
    return "${base}api/v1/shops/$shopId/products";
  }
}
