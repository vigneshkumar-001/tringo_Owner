import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Api/Repository/api_url.dart';
import 'package:tringo_owner/Api/Repository/failure.dart';
import 'package:tringo_owner/Api/Repository/request.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Presentation/AboutMe/Model/shop_analytics_response.dart';
import 'package:tringo_owner/Presentation/AboutMe/Model/shop_root_response.dart';
import 'package:tringo_owner/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_owner/Presentation/Create%20App%20Offer/Model/offer_products.dart';
import 'package:tringo_owner/Presentation/Create%20Surprise%20Offers/Model/create_surprise_response.dart';
import 'package:tringo_owner/Presentation/Create%20Surprise%20Offers/Model/store_list_response.dart';
import 'package:tringo_owner/Presentation/Home/Model/enquiry_analytics_response.dart';
import 'package:tringo_owner/Presentation/Home/Model/enquiry_response.dart';
import 'package:tringo_owner/Presentation/Home/Model/mark_enquiry.dart';
import 'package:tringo_owner/Presentation/Home/Model/reply_response.dart';
import 'package:tringo_owner/Presentation/Home/Model/shops_response.dart';
import 'package:tringo_owner/Presentation/Login/model/app_version_response.dart';
import 'package:tringo_owner/Presentation/Login/model/login_response.dart';
import 'package:tringo_owner/Presentation/Login/model/otp_response.dart';
import 'package:tringo_owner/Presentation/Menu/Model/current_plan_response.dart';
import 'package:tringo_owner/Presentation/Privacy%20Policy/Model/terms_and_condition_model.dart';
import 'package:tringo_owner/Presentation/ShopInfo/model/category_keywords_response.dart';
import 'package:tringo_owner/Presentation/ShopInfo/model/search_keywords_response.dart';
import 'package:tringo_owner/Presentation/ShopInfo/model/shop_category_list_response.dart';
import 'package:tringo_owner/Presentation/ShopInfo/model/shop_category_response.dart';
import 'package:tringo_owner/Presentation/ShopInfo/model/shop_info_photos_response.dart';
import 'package:tringo_owner/Presentation/Shops%20Details/model/shop_details_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/send_tcoin_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/uid_name_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/wallet_history_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/wallet_qr_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/withdraw_request_response.dart';

import '../../Core/Session/registration_product_seivice.dart';
import '../../Core/Utility/app_prefs.dart';
import '../../Presentation/AboutMe/Model/follower_response.dart';
import '../../Presentation/AboutMe/Model/service_edit_response.dart';
import '../../Presentation/AboutMe/Model/service_remove_response.dart';
import '../../Presentation/AddProduct/Model/delete_response.dart';
import '../../Presentation/AddProduct/Service Info/Model/image_upload_response.dart';
import '../../Presentation/AddProduct/Service Info/Model/service_info_response.dart';
import '../../Presentation/Create App Offer/Model/create_offers.dart';
import '../../Presentation/Create App Offer/Model/edit_offers_response.dart';
import '../../Presentation/Create App Offer/Model/update_offer_model.dart';
import '../../Presentation/Create Surprise Offers/Model/surprise_offer_list_response.dart';
import '../../Presentation/Login/model/contact_response.dart';
import '../../Presentation/Login/model/login_new_response.dart';
import '../../Presentation/Login/model/whatsapp_response.dart';
import '../../Presentation/Menu/Model/delete_response.dart';
import '../../Presentation/Menu/Model/plan_list_response.dart';
import '../../Presentation/Menu/Model/purchase_response.dart';
import '../../Presentation/Menu/Model/qr_action_response.dart';
import '../../Presentation/Mobile Nomber Verify/Model/sim_verify_response.dart';
import '../../Presentation/Offer/Model/offer_model.dart';
import '../../Presentation/Register/model/owner_info_response.dart';
import '../../Presentation/ShopInfo/model/shop_number_otp_response.dart';
import '../../Presentation/ShopInfo/model/shop_number_verify_response.dart';
import '../../Presentation/ShopInfo/model/user_image_response.dart';
import '../../Presentation/Support/Model/chat_message_response.dart';
import '../../Presentation/Support/Model/create_support_response.dart';
import '../../Presentation/Support/Model/send_message_response.dart';
import '../../Presentation/Support/Model/support_list_response.dart';
import '../Repository/api_url.dart';

enum AnalyticsType { enquiries, calls, locations }

String _tabFromType(AnalyticsType t) {
  switch (t) {
    case AnalyticsType.enquiries:
      return "ENQUIRY";
    case AnalyticsType.calls:
      return "CALL";
    case AnalyticsType.locations:
      return "MAP";
  }
}

String _keyFromType(AnalyticsType t) {
  switch (t) {
    case AnalyticsType.enquiries:
      return "enquiries";
    case AnalyticsType.calls:
      return "calls";
    case AnalyticsType.locations:
      return "locations";
  }
}

abstract class BaseApiDataSource {
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String mobileNumber,
    String page,
  );
}

class ApiDataSource extends BaseApiDataSource {
  @override
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String phone,
    String simToken, {
    String page = "",
  }) async {
    try {
      final url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "owner", "simToken": simToken},
        'Post',
        false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(LoginResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      // 🔴 NO INTERNET
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  Future<Either<Failure, OtpLoginResponse>> mobileNewNumberLogin(
    String phone,
    String simToken, {
    String page = "",
  }) async {
    try {
      // final url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
      final url = ApiUrl.requestLogin;
      final method = simToken.isEmpty ? 'OTP' : 'SIM';
      final response = await Request.sendRequest(
        url,
        {
          "contact": "+91$phone",
          "purpose": "owner",
          "loginMethod": method,
          "simToken": simToken,
        },
        'Post',
        false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(OtpLoginResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      // 🔴 NO INTERNET
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  Future<Either<Failure, OtpResponse>> otp({
    required String contact,
    required String otp,
  }) async {
    try {
      String url = ApiUrl.verifyOtp;

      dynamic response = await Request.sendRequest(
        url,
        {"contact": "+91$contact", "code": otp, "purpose": "owner"},
        'Post',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(OtpResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OwnerInfoResponse>> ownerInfo({
    required String govtRegisteredName,
    required String preferredLanguage,
    required String gender,
    required String dateOfBirth,
    required String identityDocumentUrl,
    required String fullName,
    required String ownerNameTamil,
    required String email,
    required String ownershipType,
    required String businessType,
  }) async {
    try {
      String url = ApiUrl.ownerInfo;
      final payload = {
        "businessType": businessType,
        "ownershipType": ownershipType.toUpperCase(),
        "govtRegisteredName": govtRegisteredName,
        "preferredLanguage": preferredLanguage,
        "gender": gender.toUpperCase(),
        "dateOfBirth": dateOfBirth,
        "identityDocumentUrl": "https://cdn.example.com/docs/pan.pdf",
        "fullName": fullName,
        "ownerNameTamil": ownerNameTamil,
        "email": email,
      };

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(OwnerInfoResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopCategoryResponse>> shopCategoryInfo({
    required String category,
    required String subCategory,
    required String englishName,
    required String tamilName,
    required String descriptionEn,
    String? apiShopId,
    required String type,
    required String descriptionTa,
    required String addressEn,
    required String addressTa,
    required double gpsLatitude,
    required double gpsLongitude,
    String? primaryPhoneVerificationToken,
    required String primaryPhone,
    required String alternatePhone,
    required String ownerImageUrl,
    required String contactEmail,
    required bool doorDelivery,
    required String weeklyHours,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedShopId = prefs.getString('shop_id');
      AppLogger.log.w(savedShopId);
      AppLogger.log.w(apiShopId);

      // ✅ Priority: 1) SharedPrefs → 2) apiShopId
      String? finalShopId;
      if (savedShopId != null && savedShopId.isNotEmpty) {
        finalShopId = savedShopId;
      } else if (apiShopId != null && apiShopId.isNotEmpty) {
        finalShopId = apiShopId;
      }

      final bool isUpdate = finalShopId != null;
      final url = isUpdate
          ? ApiUrl.updateShop(shopId: finalShopId)
          : ApiUrl.shop;

      // ✅ READ verification token (saved after OTP verify)
      final phoneVerifyToken = await AppPrefs.getVerificationToken();

      final payload = <String, dynamic>{
        "category": category,
        "subCategory": subCategory,
        "englishName": englishName,
        "tamilName": tamilName,
        "descriptionEn": descriptionEn,
        "descriptionTa": descriptionTa,
        "addressEn": addressEn,
        "addressTa": addressTa,
        "gpsLatitude": gpsLatitude,
        "gpsLongitude": gpsLongitude,
        "primaryPhone": primaryPhone,
        "alternatePhone": alternatePhone,
        "contactEmail": contactEmail,
        "doorDelivery": doorDelivery,
        "weeklyHours": weeklyHours,

        // ✅ IMPORTANT: backend expects this
        if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
          "primaryPhoneVerificationToken": phoneVerifyToken,

        // ✅ keep this also (safe fallback)
        if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
          "phoneVerifyToken": phoneVerifyToken,
      };

      if (type == "service") {
        payload["ownerImageUrl"] = ownerImageUrl;
      }

      dynamic response = await Request.sendRequest(
        url,
        payload,
        'Post',
        true,
        extraHeaders: {
          if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
            "x-phone-verify-token": phoneVerifyToken,

          // ✅ fallback header keys (safe)
          if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
            "x-phone-verification-token": phoneVerifyToken,
          if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
            "x-verification-token": phoneVerifyToken,
        },
      );

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = response.data;

          if (body is Map && body['status'] == true) {
            final shopResponse = ShopCategoryResponse.fromJson(
              body as Map<String, dynamic>,
            );

            // ✅ clear token only after success
            await AppPrefs.clearVerificationToken();

            return Right(shopResponse);
          } else {
            return Left(
              ServerFailure(body['message'] ?? "Something went wrong"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopCategoryListResponse>> getShopCategories() async {
    try {
      String url = ApiUrl.categoriesShop;

      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(ShopCategoryListResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserImageResponse>> userProfileUpload({
    required File imageFile,
  }) async {
    try {
      if (!await imageFile.exists()) {
        return Left(ServerFailure('Image file does not exist.'));
      }

      final url = ApiUrl.imageUrl;

      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);

      if (response is! Response) {
        return Left(ServerFailure('Invalid server response'));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['status'] == true) {
          return Right(UserImageResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? 'Upload failed'));
        }
      }

      return Left(
        ServerFailure((response.data as Map?)?['message'] ?? 'Unknown error'),
      );
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      return Left(ServerFailure('Something went wrong'));
    }
  }

  Future<Either<Failure, ShopInfoPhotosResponse>> shopPhotoUpload({
    required List<Map<String, String>> items,
    String? apiShopId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopIdToUse = apiShopId ?? prefs.getString('shop_id') ?? '';

      // ❗ FIXED: remove `?? ''`
      final url = ApiUrl.shopPhotosUpload(shopId: shopIdToUse);

      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      AppLogger.log.i(payload);
      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopInfoPhotosResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Upload failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopCategoryApiResponse>> searchKeywords({
    required List<String> keywords,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = prefs.getString('shop_id');
      final url = ApiUrl.searchKeyWords(shopId: shopId ?? '');

      final payload = {"keywords": keywords};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      AppLogger.log.i(payload);
      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopCategoryApiResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Something went wrong"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e('$e $st');

      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> addProduct({
    required String category,
    required String subCategory,
    required String englishName,
    required int price,
    required String offerLabel,
    required String offerValue,
    String? apiShopId,
    String? apiProductId,
    required String description,
    required bool doorDelivery,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔹 SHOP ID: can fallback to prefs
      String? shopIdToUse = apiShopId ?? prefs.getString('shop_id');
      String? productId = apiProductId ?? prefs.getString('product_id');

      if (shopIdToUse == null || shopIdToUse.isEmpty) {
        return Left(
          ServerFailure("Shop not found. Please complete shop setup first."),
        );
      }

      // 🔹 PRODUCT ID: ONLY use what caller sends
      // final String? productId = apiProductId; // ❗ no prefs fallback here

      final String url = (productId != null && productId.isNotEmpty)
          ? ApiUrl.updateProducts(productId: productId) // UPDATE
          : ApiUrl.addProducts(shopId: shopIdToUse); // CREATE

      final payload = {
        "category": category,
        "subCategory": subCategory,
        "englishName": englishName,
        "price": price,
        "offerLabel": offerLabel,
        "offerValue": offerValue,
        "description": description,
        "doorDelivery": doorDelivery,
      };

      final response = await Request.sendRequest(url, payload, 'Post', true);

      if (response is! Response) {
        return Left(ServerFailure("Invalid response from server"));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data["status"] == true) {
          return Right(ProductResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Request failed"));
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopCategoryListResponse>> getProductCategories({
    String? apiShopId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedShopId = prefs.getString('shop_id');

      // priority: apiShopId → savedShopId → empty
      final shopId = (apiShopId != null && apiShopId.trim().isNotEmpty)
          ? apiShopId
          : (savedShopId ?? '');

      final url = ApiUrl.productCategoryList(shopId: shopId);
      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(ShopCategoryListResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> updateProducts({
    required List<String> images,
    required List<Map<String, String>> features,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productId = prefs.getString('product_id') ?? '';

      String url = ApiUrl.updateProducts(productId: productId);

      // ✅ Use the actual images + features passed from caller
      final payload = {"images": images, "features": features};

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ProductResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> updateSearchKeyWords({
    required List<String> keywords,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productId = prefs.getString('product_id') ?? '';

      String url = ApiUrl.updateProducts(productId: productId);

      // ✅ Use the actual images + features passed from caller
      final payload = {"keywords": keywords};

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ProductResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopDetailsResponse>> getShopDetails({
    String? apiShopId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedShopId = prefs.getString('shop_id');

      // Priority: apiShopId > savedShopId > ""
      final shopId = (apiShopId != null && apiShopId.trim().isNotEmpty)
          ? apiShopId
          : (savedShopId ?? '');

      final url = ApiUrl.shopDetails(shopId: shopId);

      dynamic response = await Request.sendGetRequest(url, {}, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopDetailsResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WhatsappResponse>> whatsAppNumberVerify({
    required String contact,
    required String purpose,
  }) async {
    try {
      final url = ApiUrl.whatsAppVerify;

      final payload = {"contact": "+91$contact", "purpose": purpose};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WhatsappResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Verification failed"));
        }
      }

      return Left(ServerFailure(data['message'] ?? "Something went wrong"));
    }
    // 🔴 NETWORK / INTERNET ERRORS
    on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  Future<Either<Failure, ServiceInfoResponse>> serviceInfo({
    required String title,
    required String tamilName,
    required String description,
    required int startsAt,
    required String offerLabel,
    required String offerValue,
    required int durationMinutes,
    required String categoryId,
    String? apiShopId,
    required String apiServiceId,
    required String subCategory,
    required List<String> tags,
    // required List<String> keywords,
    // required List<String> images,
    // required bool isFeatured,
    // required List<Map<String, String>> features,
  }) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      //
      // final serviceId = prefs.getString('service_id');
      //
      // AppLogger.log.i(apiServiceId);
      // final shopIdToUse = apiShopId ?? prefs.getString('shop_id') ?? '';
      // final url = (apiServiceId != null && apiServiceId.isNotEmpty)
      //     ? ApiUrl.serviceEdit(serviceId: apiServiceId)
      //     : ApiUrl.serviceInfo(shopId: shopIdToUse ?? '');
      //
      final prefs = await SharedPreferences.getInstance();

      final savedServiceId = prefs.getString('service_id');

      final serviceIdToUse =
          (apiServiceId != null && apiServiceId.trim().isNotEmpty)
          ? apiServiceId
          : (savedServiceId ?? '');
      AppLogger.log.i('Service id - $apiServiceId');

      final savedShopId = prefs.getString('shop_id');
      final shopIdToUse = (apiShopId != null && apiShopId.trim().isNotEmpty)
          ? apiShopId
          : (savedShopId ?? '');

      // DECIDE CREATE OR EDIT API
      // apiServiceId is required but may be "", so we check empty only
      final url = serviceIdToUse.isNotEmpty
          ? ApiUrl.serviceEdit(serviceId: serviceIdToUse)
          : ApiUrl.serviceInfo(shopId: shopIdToUse);
      AppLogger.log.i("SERVICE URL → $url");
      final payload = {
        "title": title,
        "tamilName": tamilName,
        "description": description,
        "startsAt": startsAt,
        "offerLabel": offerLabel,
        "offerValue": offerValue,
        "durationMinutes": durationMinutes,
        "categoryId": categoryId,
        "subCategory": subCategory,
        "tags": tags,
      };

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final root = response.data as Map<String, dynamic>;
          if (root['status'] == true) {
            return Right(ServiceInfoResponse.fromJson(root));
          } else {
            return Left(
              ServerFailure(root['message'] ?? "Something went wrong"),
            );
          }
        } else {
          return Left(
            ServerFailure(
              (response.data is Map && response.data['message'] != null)
                  ? response.data['message']
                  : "Something went wrong",
            ),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.i(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ImageUploadResponse>> serviceImageUpload({
    required File imageFile,
  }) async {
    try {
      if (!await imageFile.exists()) {
        return Left(ServerFailure('Image file does not exist.'));
      }

      final String url = ApiUrl.imageUrl;

      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);

      if (response is! Response) {
        return Left(ServerFailure("Unexpected error type"));
      }

      // ✅ Safely handle both String and Map
      late final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        return Left(ServerFailure("Invalid response format"));
      }

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return Right(ImageUploadResponse.fromJson(responseData));
        } else {
          return Left(
            ServerFailure(responseData['message'] ?? 'Upload failed'),
          );
        }
      } else if (response.statusCode == 409) {
        return Left(ServerFailure(responseData['message'] ?? 'Conflict error'));
      } else {
        return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure('Something went wrong'));
    }
  }

  Future<Either<Failure, ServiceInfoResponse>> serviceList({
    required List<String> images,
    required List<Map<String, String>> features,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serviceId = prefs.getString('service_id');

      if (serviceId == null || serviceId.isEmpty) {
        return Left(ServerFailure("Missing service id in SharedPreferences"));
      }

      // TODO: adapt this to your actual backend route
      // Example: PATCH /api/v1/services/{serviceId}/info
      final String url = ApiUrl.serviceList(serviceId: serviceId);
      // Make sure ApiUrl.serviceList builds a SERVICE URL, not PRODUCTS

      final payload = {"images": images, "features": features};

      // If your backend uses PATCH → 'Patch'
      // If it uses PUT → 'Put'
      // Only keep 'Post' if your backend really expects POST here.
      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ServiceInfoResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceInfoResponse>> serviceSearchKeyWords({
    required List<String> keywords,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serviceId = prefs.getString('service_id') ?? '';

      String url = ApiUrl.serviceList(serviceId: serviceId);

      // ✅ Use the actual images + features passed from caller
      final payload = {"keywords": keywords};

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ServiceInfoResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopRootResponse>> getAllShopDetails({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.getAllShop(shopId: shopId ?? '');

      dynamic response = await Request.sendGetRequest(url, {}, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopRootResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, DeleteResponse>> deleteProduct({
    String? productId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = productId ?? prefs.getString('product_id');

      if (id == null || id.isEmpty) {
        return Left(ServerFailure("Product not found."));
      }

      final url = ApiUrl.deleteProduct(productId: id);

      final response = await Request.sendRequest(url, {}, 'DELETE', true);

      if (response is DioException) {
        return Left(ServerFailure(response.message ?? 'Delete failed'));
      }

      final map = response.data;
      if (map == null || map is! Map<String, dynamic>) {
        return const Right(DeleteResponse(status: true));
      }

      return Right(DeleteResponse.fromJson(map));
    } catch (_) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  Future<Either<Failure, ServiceRemoveResponse>> deleteService({
    String? serviceId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = serviceId ?? prefs.getString('service_id');

      if (id == null || id.isEmpty) {
        return Left(ServerFailure("Service not found."));
      }

      final url = ApiUrl.serviceDelete(serviceId: id);

      // ⚠️ Keep method string consistent with your other calls
      final response = await Request.sendRequest(url, {}, 'Delete', true);

      // Network / Dio error
      if (response is DioException) {
        return Left(ServerFailure(response.message ?? 'Delete failed'));
      }

      final map = response.data;

      if (map == null || map is! Map<String, dynamic>) {
        return Left(ServerFailure('Invalid response from server'));
      }

      return Right(ServiceRemoveResponse.fromJson(map));
    } catch (e, st) {
      AppLogger.log.e('❌ deleteService exception: $e\n$st');
      return Left(ServerFailure('Unexpected error'));
    }
  }

  Future<Either<Failure, SimVerifyResponse>> mobileVerify({
    required String contact,
    required String simToken,
    required String purpose,
  }) async {
    try {
      final url = ApiUrl.mobileVerify;

      final payload = {
        'contact': "+91$contact",
        'simToken': simToken,
        'purpose': 'owner',
      };

      // Use your normal POST helper
      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            // ✅ API returns the same JSON you showed
            return Right(SimVerifyResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EnquiryResponse>> getAllEnquiry({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.getAllEnquiry(shopId: shopId);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(EnquiryResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e,st) {
      AppLogger.log.e('${e},${st}');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopsResponse>> getAllShops({
    required String shopId,
    required String filter,
  }) async {
    try {
      final url = ApiUrl.getAllShopsDetails(shopId: shopId, filter: filter);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopsResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CreateOffers>> createOffer({
    required String shopId,
    required String title,
    required String description,
    required int discountPercentage,
    required String availableFrom,
    required String availableTo,
    required String announcementAt,
    bool autoApply = true,
    String type = "APP",
  }) async {
    try {
      final url = ApiUrl.createAppOffer(shopId: shopId);

      final payload = {
        'title': title,
        'description': description,
        'discountPercentage': discountPercentage,
        'availableFrom': availableFrom,
        'availableTo': availableTo,
        'announcementAt': announcementAt,
        'autoApply': autoApply,
        'type': type,
      };

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        final statusCode = response.statusCode ?? 0;

        if (statusCode == 200 || statusCode == 201) {
          final data = response.data;

          if (data is Map && data['status'] == true) {
            return Right(CreateOffers.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(data['message'] ?? "Offer creation failed"),
            );
          }
        } else {
          final data = response.data;
          return Left(
            ServerFailure(
              (data is Map ? data['message'] : null) ??
                  "Something went wrong (${response.statusCode})",
            ),
          );
        }
      } else {
        // DioException case
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e("createOffer error: $e\n$st");
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OfferProductsResponse>> productListShowForOffer({
    required String shopId,
    required String type,
  }) async {
    try {
      final url = ApiUrl.productListShowForOffer(shopId: shopId, type: type);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(OfferProductsResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UpdateOfferModel>> updateOfferList({
    required List<String> productIds,
    required String shopId,
    required String offerId,
    required String type,
  }) async {
    try {
      final url = ApiUrl.updateOfferList(shopId: shopId, offerId: offerId);

      final Map<String, dynamic> payload = {"type": type};

      if (type == "PRODUCT") {
        payload["productIds"] = productIds;
      } else if (type == "SERVICE") {
        payload["serviceIds"] = productIds;
      }

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        final statusCode = response.statusCode ?? 0;

        if (statusCode == 200 || statusCode == 201) {
          final data = response.data;

          if (data is Map && data['status'] == true) {
            return Right(UpdateOfferModel.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(data['message'] ?? "Offer creation failed"),
            );
          }
        } else {
          final data = response.data;
          return Left(
            ServerFailure(
              (data is Map ? data['message'] : null) ??
                  "Something went wrong (${response.statusCode})",
            ),
          );
        }
      } else {
        // DioException case
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e("createOffer error: $e\n$st");
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OfferModel>> offerScreen({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.offerScreenURL(shopId: shopId);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(OfferModel.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MarkEnquiry>> markEnquiry({
    required String enquiryId,
  }) async {
    try {
      final url = ApiUrl.markEnquiry(enquiryId: enquiryId);

      dynamic response = await Request.sendRequest(url, {}, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(MarkEnquiry.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PlanListResponse>> getPlanList() async {
    try {
      final url = ApiUrl.plans;

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(PlanListResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PurchaseResponse>> purchasePlan({
    required String planId,
    required String businessProfileId,
  }) async {
    try {
      final url = ApiUrl.purchase;

      dynamic response = await Request.sendRequest(
        url,
        {"planId": planId},
        'POST',
        true,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(PurchaseResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CurrentPlanResponse>> getCurrentPlan() async {
    try {
      final url = ApiUrl.currentPlans;

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(CurrentPlanResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AppVersionResponse>> getAppVersion({
    required String appName,
    required String appVersion,
    required String appPlatForm,
  }) async {
    try {
      final url = ApiUrl.version;

      dynamic response = await Request.sendGetRequest(
        url,
        {},
        'GET',
        false,
        appName: appName,
        appPlatForm: appPlatForm,
        appVersion: appVersion,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(AppVersionResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ContactResponse>> syncContacts({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final url = ApiUrl.contactInfo; // same endpoint

      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ContactResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Sync failed"),
            );
          }
        }
        return Left(
          ServerFailure(response.data['message'] ?? "Something went wrong"),
        );
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopNumberVerifyResponse>> shopAddNumberRequest({
    required String phone,
    required String type,
  }) async {
    String url = ApiUrl.shopNumberVerify;

    final response = await Request.sendRequest(
      url,
      {"phone": "+91$phone", "type": type},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(ShopNumberVerifyResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      } else {
        return Left(
          ServerFailure(response.data['message'] ?? "Something went wrong"),
        );
      }
    } else {
      final errorData = response.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(response.message ?? "Unknown Dio error"));
    }
  }

  Future<Either<Failure, ShopNumberOtpResponse>> shopAddOtpRequest({
    required String phone,
    required String type,
    required String code,
  }) async {
    String url = ApiUrl.shopNumberOtpVerify;

    final response = await Request.sendRequest(
      url,
      {"phone": "+91$phone", "code": code, "type": type},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(ShopNumberOtpResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      } else {
        return Left(
          ServerFailure(response.data['message'] ?? "Something went wrong"),
        );
      }
    } else {
      final errorData = response.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(response.message ?? "Unknown Dio error"));
    }
  }

  Future<Either<Failure, EditOffersResponse>> editAndUpdateOffer({
    required List<String> productIds,
    required String shopId,
    required String offerId,
    required String type, // PRODUCT / SERVICE (based on your logic)
    required String title,
    required String description,
    required int discountPercentage,
    required String availableFrom,
    required String availableTo,
    required String announcementAt,
  }) async {
    try {
      final url = ApiUrl.editOffers(shopId: shopId, offerId: offerId);

      final Map<String, dynamic> payload = {
        "type": type,
        "title": title,
        "description": description,
        "discountPercentage": discountPercentage,
        "availableFrom": availableFrom,
        "availableTo": availableTo,
        "announcementAt": announcementAt,
      };

      if (type == "PRODUCT") {
        payload["productIds"] = productIds;
      } else if (type == "SERVICE") {
        payload["serviceIds"] = productIds;
      }

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is DioException) {
        final errorData = response.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode == 200 || statusCode == 201) {
        if (data is Map && data['status'] == true) {
          return Right(
            EditOffersResponse.fromJson(data.cast<String, dynamic>()),
          );
        }
        return Left(
          ServerFailure(
            (data is Map ? data['message'] : null)?.toString() ??
                "Update failed",
          ),
        );
      }

      return Left(
        ServerFailure(
          (data is Map ? data['message'] : null)?.toString() ??
              "Something went wrong ($statusCode)",
        ),
      );
    } catch (e, st) {
      AppLogger.log.e("editAndUpdateOffer error: $e\n$st");
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AccountDeleteResponse>> deleteAccount() async {
    try {
      final url = ApiUrl.deleteAccount;

      final response = await Request.sendRequest(
        url,
        {}, // no payload
        'DELETE',
        true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(AccountDeleteResponse.fromJson(response.data));
        }
        return Left(ServerFailure(response.data['message'] ?? "Delete failed"));
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message'].toString()));
      }

      return Left(ServerFailure("Request failed"));
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  Future<Either<Failure, SupportListResponse>> supportList() async {
    try {
      final String url = ApiUrl.supportTicketsList;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(SupportListResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CreateSupportResponse>> createSupportTicket({
    required String subject,
    required String description,
    required String imageUrl,
    required dynamic attachments,
  }) async {
    try {
      final String url = ApiUrl.supportTicketsList;
      final Map<String, dynamic> body = {
        "subject": subject,
        "description": description,
        "attachments": [
          {"url": imageUrl},
        ],
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(CreateSupportResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ChatMessageResponse>> getChatMessages({
    required String id,
  }) async {
    try {
      final String url = ApiUrl.getChatMessages(id: id);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ChatMessageResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String subject,

    required String imageUrl,
    required String ticketId,
    required dynamic attachments,
  }) async {
    try {
      final String url = ApiUrl.sendMessage(ticketId: ticketId);
      final Map<String, dynamic> body = {
        "message": subject,

        "attachments": [
          {"url": imageUrl},
        ],
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(SendMessageResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, StoreListResponse>> getBranchList({
    String? apiShopId,
  }) async {
    try {
      final url = ApiUrl.branchesList;
      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(StoreListResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CreateSurpriseResponse>> createSurpriseOffer({
    required String branchId,
    required String bannerUrl,
    required String shopIdToUse,
    required String title,
    required String description,
    required int couponCount,
    required String availableFrom,
    required String availableTo,
  }) async {
    try {
      final String url = ApiUrl.createSurpriseOffer(shopId: shopIdToUse);

      final payload = {
        "branchId": branchId,
        "bannerUrl": bannerUrl,
        "title": title,
        "description": description,
        "couponCount": couponCount,
        "availableFrom": availableFrom,
        "availableTo": availableTo,
      };

      final response = await Request.sendRequest(url, payload, 'Post', true);

      if (response is! Response) {
        return Left(ServerFailure("Invalid response from server"));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data["status"] == true) {
          return Right(CreateSurpriseResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Request failed"));
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SurpriseOfferListResponse>> surpriseOfferList({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.surpriseOfferList(shopId: shopId);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(SurpriseOfferListResponse.fromJson(response.data));
          } else {
            return Left(ServerFailure(response.data['message'] ?? ""));
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, QrActionResponse>> shopQrCode({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.shopQrCode(shopId: shopId);

      final dynamic resp = await Request.sendGetRequest(url, {}, 'GET', true);

      // ✅ VERY IMPORTANT: null guard
      if (resp == null) {
        return Left(
          ServerFailure("No response from server. Please try again."),
        );
      }

      // ✅ Safe logs (no crash)
      if (resp is Response) {
        debugPrint("shopQrCode => status=${resp.statusCode}");
        debugPrint("shopQrCode => data=${resp.data}");
        AppLogger.log.i("shopQrCode => status=${resp.statusCode}");
        AppLogger.log.i("shopQrCode => data=${resp.data}");
      } else if (resp is DioException) {
        debugPrint("shopQrCode => dioError=${resp.message}");
        AppLogger.log.i("shopQrCode => dioError=${resp.message}");
      } else {
        debugPrint("shopQrCode => resp=${resp.toString()}");
        AppLogger.log.i("shopQrCode => resp=${resp.toString()}");
      }

      // ✅ If not DioException, it should be a Dio Response
      if (resp is! DioException) {
        if (resp is Response) {
          final status = resp.statusCode ?? 0;

          if (status == 200 || status == 201) {
            final data = resp.data;

            if (data is Map && data['status'] == true) {
              return Right(
                QrActionResponse.fromJson(data.cast<String, dynamic>()),
              );
            } else if (data is Map) {
              return Left(
                ServerFailure(
                  (data['message'] ?? "Something went wrong").toString(),
                ),
              );
            } else {
              return Left(ServerFailure("Invalid API response"));
            }
          } else {
            final data = resp.data;
            if (data is Map) {
              return Left(
                ServerFailure(
                  (data['message'] ?? "Something went wrong").toString(),
                ),
              );
            }
            return Left(ServerFailure("Something went wrong"));
          }
        }

        return Left(ServerFailure("Invalid response type"));
      }

      // ✅ DioException
      final errorData = resp.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message'].toString()));
      }

      return Left(ServerFailure(resp.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  // Future<Either<Failure, QrActionResponse>> shopQrCode({
  //   required String shopId,
  // })
  // async {
  //   try {
  //     final url = ApiUrl.shopQrCode(shopId: shopId);
  //
  //     final dynamic resp = await Request.sendGetRequest(url, {}, 'GET', true);
  //
  //     // ✅ Safe logs (no type error)
  //     if (resp is Response) {
  //       AppLogger.log.i("shopQrCode => status=${resp.statusCode}");
  //       AppLogger.log.i("shopQrCode => data=${resp.data}");
  //       debugPrint("shopQrCode => status=${resp.statusCode}");
  //       debugPrint("shopQrCode => data=${resp.data}");
  //     } else {
  //       AppLogger.log.i("shopQrCode => resp=${resp.toString()}");
  //       debugPrint("shopQrCode => resp=${resp.toString()}");
  //     }
  //
  //     // ✅ If not DioException, it should be a Dio Response
  //     if (resp is! DioException) {
  //       if (resp is Response) {
  //         if (resp.statusCode == 200 || resp.statusCode == 201) {
  //           final data = resp.data;
  //
  //           if (data is Map && data['status'] == true) {
  //             return Right(
  //               QrActionResponse.fromJson(data.cast<String, dynamic>()),
  //             );
  //           } else if (data is Map) {
  //             return Left(
  //               ServerFailure(
  //                 (data['message'] ?? "Something went wrong").toString(),
  //               ),
  //             );
  //           } else {
  //             return Left(ServerFailure("Invalid API response"));
  //           }
  //         } else {
  //           final data = resp.data;
  //           if (data is Map) {
  //             return Left(
  //               ServerFailure(
  //                 (data['message'] ?? "Something went wrong").toString(),
  //               ),
  //             );
  //           }
  //           return Left(ServerFailure("Something went wrong"));
  //         }
  //       }
  //
  //       return Left(ServerFailure("Invalid response type"));
  //     }
  //
  //     // ✅ DioException
  //     final errorData = resp.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message'].toString()));
  //     }
  //     return Left(ServerFailure(resp.message ?? "Unknown Dio error"));
  //   } catch (e) {
  //     AppLogger.log.e(e);
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  Future<Either<Failure, PlanListResponse>> enquiriesAnalytic() async {
    try {
      final url = ApiUrl.plans;

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(PlanListResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WalletHistoryResponse>> walletHistory({
    required String type,
  }) async {
    try {
      final String url = ApiUrl.walletHistory(type: type);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response?.statusCode == 200 || response?.statusCode == 201) {
          if (response?.data['status'] == true) {
            return Right(WalletHistoryResponse.fromJson(response?.data));
          } else {
            return Left(ServerFailure(response?.data['message'] ?? ""));
          }
        } else {
          return Left(
            ServerFailure(response?.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(errorData['message'] ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UidNameResponse>> uIDPersonName({
    required String uid,
  }) async {
    try {
      final String url = ApiUrl.uIDPersonName;

      final payload = {"uid": uid};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is DioException) {
        final errorData = response.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data is Map && data['status'] == true) {
          return Right(UidNameResponse.fromJson(data.cast<String, dynamic>()));
        }

        return Left(
          ServerFailure(
            (data is Map && data['message'] != null)
                ? data['message'].toString()
                : "Failed to fetch user",
          ),
        );
      }

      return Left(ServerFailure("HTTP ${response.statusCode}"));
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SendTcoinResponse>> uIDSendApi({
    required String toUid,
    required String tCoin,
  }) async {
    try {
      final String url = ApiUrl.uIDSendApi; // ✅ /v1/wallet/transfer

      final payload = {
        "toUid": toUid.trim(),
        "tcoin": num.tryParse(tCoin.trim()) ?? 0,
      };

      final response = await Request.sendRequest(url, payload, 'POST', true);

      if (response is DioException) {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode == 200 || statusCode == 201) {
        if (data is Map && data['status'] == true) {
          return Right(
            SendTcoinResponse.fromJson(data.cast<String, dynamic>()),
          );
        }
        final msg = (data is Map ? data['message'] : null) ?? "Send failed";
        return Left(ServerFailure(msg.toString()));
      }

      final msg =
          (data is Map ? data['message'] : null) ?? "Something went wrong";
      return Left(ServerFailure(msg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WithdrawRequestResponse>> uIDWithRawApi({
    required String upiId,
    required String tcoin,
  }) async {
    try {
      final String url = ApiUrl.uIDWithRawApi;
      final payload = {"upiId": upiId, "tcoin": tcoin};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      // 🔴 1. Network / Dio error
      if (response is DioException) {
        final data = response.response?.data;

        if (data is Map && data['message'] != null) {
          return Left(ServerFailure(data['message'].toString()));
        }

        return Left(ServerFailure(response.message ?? 'Network error'));
      }

      // 🔴 2. Normal HTTP response (200 / 400 / 422 etc)
      final body = response.data;

      if (body is Map<String, dynamic>) {
        // ❌ business failure → pass message AS-IS
        if (body['status'] != true) {
          return Left(
            ServerFailure(body['message']?.toString() ?? 'UNKNOWN_ERROR'),
          );
        }

        // ✅ success
        final parsed = WithdrawRequestResponse.fromJson(body);

        if (parsed.data.success != true) {
          return Left(
            ServerFailure(body['message']?.toString() ?? 'UNKNOWN_ERROR'),
          );
        }

        return Right(parsed);
      }

      // 🔴 3. Unexpected response shape
      return Left(ServerFailure('INVALID_RESPONSE'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WalletQrResponse>> walletQrCode() async {
    try {
      final url = ApiUrl.walletQrCode;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WalletQrResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e, st) {
      print('${e}\n${st}');
      AppLogger.log.e('${e}\n${st}');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EnquiryAnalyticsResponse>> fetchEnquiryAnalyticsPaged({
    required String shopId,
    required String tab, // "ENQUIRY" | "CALL" | "MAP"
    required String enquiryStatus,
    required String callStatus,
    required String mapStatus,
    required int take,
    required int skip,
    required String start,
    required String end,
  }) async {
    try {
      final int enquiryTake = (tab == "ENQUIRY") ? take : 0;
      final int enquirySkip = (tab == "ENQUIRY") ? skip : 0;

      final int callTake = (tab == "CALL") ? take : 0;
      final int callSkip = (tab == "CALL") ? skip : 0;

      final int mapTake = (tab == "MAP") ? take : 0;
      final int mapSkip = (tab == "MAP") ? skip : 0;

      AppLogger.log.i('''
📤 fetchEnquiryAnalyticsPaged
shopId: $shopId
tab: $tab
take: $take | skip: $skip
enquiryTake: $enquiryTake | enquirySkip: $enquirySkip
callTake: $callTake | callSkip: $callSkip
mapTake: $mapTake | mapSkip: $mapSkip
dateRange: $start → $end
''');

      final url = ApiUrl.fetchAnalyticsActivity(
        shopId: shopId,
        tab: tab,
        enquiryStatus: enquiryStatus,
        callStatus: callStatus,
        mapStatus: mapStatus,
        enquiryTake: enquiryTake,
        enquirySkip: enquirySkip,
        callTake: callTake,
        callSkip: callSkip,
        mapTake: mapTake,
        mapSkip: mapSkip,
        start: start,
        end: end,
      );

      AppLogger.log.i("🌐 URL => $url");

      final dynamic res = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i("📥 Raw response type => ${res.runtimeType}");

      if (res == null) {
        AppLogger.log.e("❌ Response is NULL");
        return Left(ServerFailure("No response from server"));
      }

      if (res is DioException) {
        AppLogger.log.e("❌ DioException");
        AppLogger.log.e("message => ${res.message}");
        AppLogger.log.e("status => ${res.response?.statusCode}");
        AppLogger.log.e("data => ${res.response?.data}");

        final errData = res.response?.data;
        if (errData is Map) {
          final msg = errData["message"]?.toString();
          if (msg != null && msg.isNotEmpty) {
            return Left(ServerFailure(msg));
          }
        }

        return Left(ServerFailure(res.message ?? "Request failed"));
      }

      final int statusCode = res.statusCode ?? 0;
      final dynamic data = res.data;

      AppLogger.log.i("✅ statusCode => $statusCode");
      AppLogger.log.i("📦 response data => $data");

      if (statusCode == 200 || statusCode == 201) {
        if (data is Map) {
          if (data["status"] == true) {
            return Right(
              EnquiryAnalyticsResponse.fromJson(
                Map<String, dynamic>.from(data),
              ),
            );
          }

          return Left(
            ServerFailure(data["message"]?.toString() ?? "API status=false"),
          );
        }

        return Left(ServerFailure("Invalid response format"));
      }

      if (data is Map) {
        return Left(
          ServerFailure(
            data["message"]?.toString() ?? "Non-success status code",
          ),
        );
      }

      return Left(ServerFailure("Unexpected error"));
    } catch (e, s) {
      AppLogger.log.e("🔥 Exception in fetchEnquiryAnalyticsPaged");
      AppLogger.log.e(e);
      AppLogger.log.e(s);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MarkEnquiry>> markCallOrMapClose({
    required String shopId,
    required String interactionsId,
  }) async {
    try {
      final url = ApiUrl.markCallOrMapClose(
        shopId: shopId,
        interactionsId: interactionsId,
      );

      dynamic response = await Request.sendRequest(url, {}, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(MarkEnquiry.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, FollowersResponse>> getFollowerList({
    required String shopId,
    int take = 10,
    int skip = 0,
    String range = "ALL",
  }) async {
    try {
      final url = ApiUrl.getFollowerList(
        shopId: shopId,
        take: take,
        skip: skip,
        range: range,
      );

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(FollowersResponse.fromJson(response.data));
          } else {
            return Left(ServerFailure(response.data['message'] ?? "Failed"));
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, TermsAndConditionResponse>>
  fetchTermsAndCondition() async {
    try {
      final url = ApiUrl.privacyPolicy;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(TermsAndConditionResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CategoryKeywordsResponse>> getKeyWords({
    required String type,
    required String query,
  }) async {
    try {
      String url = ApiUrl.getKeyWords(type: type, query: query);

      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(CategoryKeywordsResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopAnalyticsResponse>> fetchAnalytics({
    required String shopId,
    required String filter,
    required String months,
  }) async {
    try {
      final url = ApiUrl.getShopAnalytics(
        shopId: shopId,
        filter: filter,
        months: months,
      );

      dynamic response = await Request.sendRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        final statusCode = response.statusCode ?? 0;

        if (statusCode == 200 || statusCode == 201) {
          final data = response.data;

          if (data is Map && data['status'] == true) {
            return Right(ShopAnalyticsResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(data['message'] ?? "Offer creation failed"),
            );
          }
        } else {
          final data = response.data;
          return Left(
            ServerFailure(
              (data is Map ? data['message'] : null) ??
                  "Something went wrong (${response.statusCode})",
            ),
          );
        }
      } else {
        // DioException case
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e(" error: $e\n$st");
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ReplyResponse>> replyEnquiry({
    required String shopId,
    required String requestId,
    required String productTitle,
    required String message,
    required List<String> images, // ✅ FIX: List<String>
    required int price,
  }) async {
    try {
      final url = ApiUrl.replyEnquiry(requestId: requestId);
      final body = {
        "shopId": shopId,
        "productTitle": productTitle,
        "message": message,
        "price": price,
        "images": images,
      };

      dynamic response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ReplyResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
