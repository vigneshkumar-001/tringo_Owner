class ApiUrl {
  static const String base =
      "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";
  static const String base1 = "https://vk6shsk1-3000.inc1.devtunnels.ms/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String ownerInfo = "${base}api/v1/business";
  static const String shop = "${base}api/v1/shops";
  static const String mobileVerify = "${base}api/v1/auth/login-by-sim";
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

  static String updateProducts({required String productId}) {
    return "${base}api/v1/products/$productId";
  }

  static String deleteProduct({required String productId}) {
    return "${base}api/v1/products/$productId";
  }

  static String productCategoryList({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/product-categories";
  }

  static String shopDetails({required String shopId}) {
    return "${base}api/v1/shops/$shopId";
  }

  static String serviceInfo({required String shopId}) {
    //  no slash before api
    return "${base}api/v1/shops/$shopId/services";
  }

  static String serviceList({required String serviceId}) {
    return "${base}api/v1/services/$serviceId";
  }

  static String serviceEdit({required String serviceId}) {
    return "${base}api/v1/services/$serviceId";
  }

  static String serviceDelete({required String serviceId}) {
    return "${base}api/v1/services/$serviceId";
  }

  static String getAllShop({required String shopId}) {
    return "${base}api/v1/shops?mine=true&selectedShopId=$shopId";
  }

  static String deleteService({required String serviceId}) {
    return "${base}api/v1/services/$serviceId";
  }

  static String getAllEnquiry({required String shopId}) {
    return "${base}api/v1/dashboard/enquiries?page=1&limit=20&shopId=$shopId";
  }

  static String getAllShopsDetails({required String shopId}) {
    return "${base}api/v1/dashboard/shops?shopId=$shopId";
  }

  static String enguiriesDownload({required String sessionToken}) {
    return "${base}api/v1/dashboard/enquiries/export?format=pdf&sessionToken=$sessionToken";
  }

  static String createAppOffer({required String shopId}) {
    return "${base}api/v1/shops/$shopId/offers/app";
  }

  static String productListShowForOffer({
    required String shopId,
    required String type,
  }) {
    return "${base}api/v1/shops/$shopId/offers/app/items?type=$type";
  }

  static String updateOfferList({
    required String shopId,
    required String offerId,
  }) {
    return "${base}api/v1/shops/$shopId/offers/app/$offerId";
  }

  static String offerScreenURL({required String shopId}) {
    return "${base}api/v1/shops/$shopId/offers?type=APP";
  }
}
