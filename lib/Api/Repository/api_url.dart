class ApiUrl {
  // static const String base =
  //     "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";

  static const String base = "https://bknd.tringobiz.com/";
  static const String baseUrlImage = "https://bknd.tringobiz.com/";

  static const String base1 = "https://vk6shsk1-3000.inc1.devtunnels.ms/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String requestLogin = "${base}api/v1/auth/request-login";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String ownerInfo = "${base}api/v1/business";
  static const String shop = "${base}api/v1/shops";
  static const String mobileVerify = "${base}api/v1/auth/login-by-sim";
  static const String version = "${base}api/v1/app/version";
  static const String deleteAccount = "${base}api/v1/auth/me";
  static const String imageUrl = "${baseUrlImage}api/media/image-save";
  // "https://next.fenizotechnologies.com/Adrox/api/image-save";
  static const String plans = "${base}api/v1/subscriptions/plans";
  static const String currentPlans = "${base}api/v1/subscriptions/current";
  static const String purchase = "${base}api/v1/subscriptions/purchase";
  static const String contactInfo = "${base}api/v1/contacts/sync";
  static const String supportTicketsList = "${base}api/v1/support/tickets";
  static const String branchesList = "${base}api/v1/shops/branches";
  static const String walletQrCode = "${base}api/v1/wallet/my-qr";
  static String sendMessage({required String ticketId}) {
    return "${base}api/v1/support/tickets/$ticketId/messages";
  }

  static String getChatMessages({required String id}) {
    return "${base}api/v1/support/tickets/$id";
  }

  static const String shopNumberVerify =
      "${base}api/v1/auth/phone-verification/request";
  static const String shopNumberOtpVerify =
      "${base}api/v1/auth/phone-verification/verify";
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

  static String createSurpriseOffer({required String shopId}) {
    return "${base}api/v1/shops/$shopId/offers/surprise";
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

  static String fetchAnalyticsActivity({
    required String shopId,
    required String tab, // "ENQUIRY" | "CALL" | "MAP"
    required String enquiryStatus, // "OPEN" | "CLOSED"
    required String callStatus,
    required String mapStatus,
    required int enquiryTake,
    required int enquirySkip,
    required int callTake,
    required int callSkip,
    required int mapTake,
    required int mapSkip,
    required String start, // "YYYY-MM-DD"
    required String end, // "YYYY-MM-DD"
  }) {
    final uri =
        Uri.parse(
          "${base}api/v1/shops/$shopId/profile/analytics/activity",
        ).replace(
          queryParameters: {
            "tab": tab,
            "enquiryStatus": enquiryStatus,
            "callStatus": callStatus,
            "mapStatus": mapStatus,
            "enquiryTake": enquiryTake.toString(),
            "enquirySkip": enquirySkip.toString(),
            "callTake": callTake.toString(),
            "callSkip": callSkip.toString(),
            "mapTake": mapTake.toString(),
            "mapSkip": mapSkip.toString(),
            "start": start,
            "end": end,
          },
        );

    return uri.toString();
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

  static String markEnquiry({required String enquiryId}) {
    return "${base}api/v1/dashboard/enquiries/$enquiryId/close";
  }

  static String markCallOrMapClose({
    required String shopId,
    required String interactionsId,
  }) {
    return "${base}api/v1/shops/$shopId/profile/analytics/interactions/$interactionsId/close";
  }

  static String editOffers({required String shopId, required String offerId}) {
    return "${base}api/v1/shops/$shopId/offers/app/$offerId";
  }

  static String surpriseOfferList({required String shopId}) {
    return "${base}api/v1/shops/$shopId/offers/surprise/list?limitClaimers=4";
  }

  static String shopQrCode({required String shopId}) {
    return "${base}api/v1/shops/$shopId/qr";
  }

  static String en({required String shopId}) {
    return "${base}api/v1/shops/$shopId/qr";
  }

  static String walletHistory({required String type}) {
    return "${base}api/v1/wallet/history?type=$type";
  }

  static const String uIDPersonName = "${base}api/v1/wallet/resolve-uid";
  static const String uIDSendApi = "${base}api/v1/wallet/transfer";
  static const String uIDWithRawApi = "${base}api/v1/wallet/withdraw-request";

  static const String privacyPolicy =
      "${base}api/v1/public/pages/privacy-policy";

  static String getFollowerList({
    required String shopId,
    int take = 10,
    int skip = 0,
    String range = "ALL", // WEEK | MONTH | ALL (whatever your API supports)
  }) {
    return "${base}api/v1/shops/$shopId/profile/followers"
        "?take=$take&skip=$skip&range=$range";
  }

}
