import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Api/Repository/api_url.dart';
import 'package:tringo_vendor/Api/Repository/failure.dart';
import 'package:tringo_vendor/Api/Repository/request.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Model/shop_root_response.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Model/offer_products.dart';
import 'package:tringo_vendor/Presentation/Home/Model/enquiry_response.dart';
import 'package:tringo_vendor/Presentation/Home/Model/mark_enquiry.dart';
import 'package:tringo_vendor/Presentation/Home/Model/shops_response.dart';
import 'package:tringo_vendor/Presentation/Login/model/app_version_response.dart';
import 'package:tringo_vendor/Presentation/Login/model/login_response.dart';
import 'package:tringo_vendor/Presentation/Login/model/otp_response.dart';
import 'package:tringo_vendor/Presentation/Menu/Model/current_plan_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/search_keywords_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_list_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_info_photos_response.dart';
import 'package:tringo_vendor/Presentation/Shops%20Details/model/shop_details_response.dart';

import '../../Core/Session/registration_product_seivice.dart';
import '../../Core/Utility/app_prefs.dart';
import '../../Presentation/AboutMe/Model/service_edit_response.dart';
import '../../Presentation/AboutMe/Model/service_remove_response.dart';
import '../../Presentation/AddProduct/Model/delete_response.dart';
import '../../Presentation/AddProduct/Service Info/Model/image_upload_response.dart';
import '../../Presentation/AddProduct/Service Info/Model/service_info_response.dart';
import '../../Presentation/Create App Offer/Model/create_offers.dart';
import '../../Presentation/Create App Offer/Model/edit_offers_response.dart';
import '../../Presentation/Create App Offer/Model/update_offer_model.dart';
import '../../Presentation/Login/model/contact_response.dart';
import '../../Presentation/Login/model/login_new_response.dart';
import '../../Presentation/Login/model/whatsapp_response.dart';
import '../../Presentation/Menu/Model/plan_list_response.dart';
import '../../Presentation/Menu/Model/purchase_response.dart';
import '../../Presentation/Mobile Nomber Verify/Model/sim_verify_response.dart';
import '../../Presentation/Offer/Model/offer_model.dart';
import '../../Presentation/Register/model/owner_info_response.dart';
import '../../Presentation/ShopInfo/model/shop_number_otp_response.dart';
import '../../Presentation/ShopInfo/model/shop_number_verify_response.dart';
import '../../Presentation/ShopInfo/model/user_image_response.dart';

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
        {"contact": "+91$phone", "purpose": "owner"},
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

  // Future<Either<Failure, LoginResponse>> mobileNumberLogin(
  //   String phone,
  //   String simToken, {
  //   String page = "",
  // }) async {
  //   String url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
  //
  //   final response = await Request.sendRequest(
  //     url,
  //     {"contact": "+91$phone", "purpose": "owner"},
  //     'Post',
  //     false,
  //   );
  //
  //   if (response is! DioException) {
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (response.data['status'] == true) {
  //         return Right(LoginResponse.fromJson(response.data));
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Login failed"),
  //         );
  //       }
  //     } else {
  //       return Left(
  //         ServerFailure(response.data['message'] ?? "Something went wrong"),
  //       );
  //     }
  //   } else {
  //     final errorData = response.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //   }
  // }

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

  // Future<Either<Failure, ShopCategoryResponse>> shopCategoryInfo({
  //   required String category,
  //   required String subCategory,
  //   required String englishName,
  //   required String tamilName,
  //   required String descriptionEn,
  //   String? apiShopId,
  //   required String type,
  //   required String descriptionTa,
  //   required String addressEn,
  //   required String addressTa,
  //   required double gpsLatitude,
  //   required double gpsLongitude,
  //   required String primaryPhone,
  //   required String alternatePhone,
  //   required String ownerImageUrl,
  //   required String contactEmail,
  //   required bool doorDelivery,
  //   required String weeklyHours,
  // }) async
  // {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final savedShopId = prefs.getString('shop_id');
  //
  //     // ✅ Priority: 1) SharedPrefs → 2) apiShopId → 3) create new
  //     String? finalShopId;
  //     if (savedShopId != null && savedShopId.isNotEmpty) {
  //       finalShopId = savedShopId;
  //     } else if (apiShopId != null && apiShopId.isNotEmpty) {
  //       finalShopId = apiShopId;
  //     }
  //
  //     final bool isUpdate = finalShopId != null;
  //     final url = isUpdate
  //         ? ApiUrl.updateShop(shopId: finalShopId)
  //         : ApiUrl.shop; // create
  //
  //     // final url = (shopId != null && shopId.isNotEmpty)
  //     //     ? ApiUrl.updateShop(shopId: shopId)
  //     //     : ApiUrl.shop;
  //
  //     final payload = {
  //       "category": category,
  //       "subCategory": subCategory,
  //       "englishName": englishName,
  //       "tamilName": tamilName,
  //       "descriptionEn": descriptionEn,
  //       "descriptionTa": descriptionTa,
  //       "addressEn": addressEn,
  //       "addressTa": addressTa,
  //       "gpsLatitude": gpsLatitude,
  //       "gpsLongitude": gpsLongitude,
  //       "primaryPhone": "$primaryPhone",
  //       "alternatePhone": "$alternatePhone",
  //       "contactEmail": contactEmail,
  //       "doorDelivery": doorDelivery,
  //       "weeklyHours":
  //           weeklyHours, // <== keep as your backend expects (string/JSON)
  //     };
  //
  //     if (type == "service") {
  //       payload["ownerImageUrl"] = ownerImageUrl;
  //     }
  //
  //     final phoneVerifyToken = await AppPrefs.getVerificationToken();
  //
  //     dynamic response = await Request.sendRequest(
  //       url,
  //       payload,
  //       'Post',
  //       true,
  //       extraHeaders: {
  //         // ✅ Send token only if available
  //         if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
  //           "x-phone-verify-token": phoneVerifyToken,
  //       },
  //     );
  //
  //     AppLogger.log.i(response);
  //     AppLogger.log.i(payload);
  //
  //     if (response is! DioException) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         final body = response.data;
  //
  //         if (body is Map && body['status'] == true) {
  //           // ✅ pass full response JSON here
  //           final shopResponse = ShopCategoryResponse.fromJson(
  //             body as Map<String, dynamic>,
  //           );
  //
  //           await AppPrefs.clearVerificationToken();
  //
  //           return Right(shopResponse);
  //         } else {
  //           return Left(
  //             ServerFailure(body['message'] ?? "Something went wrong"),
  //           );
  //         }
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } catch (e, st) {
  //     AppLogger.log.e(e);
  //     AppLogger.log.e(st);
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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

  // Future<Either<Failure, UserImageResponse>> userProfileUpload({
  //   required File imageFile,
  // }) async {
  //   try {
  //     if (!await imageFile.exists()) {
  //       return Left(ServerFailure('Image file does not exist.'));
  //     }
  //
  //     String url = ApiUrl.imageUrl;
  //     FormData formData = FormData.fromMap({
  //       'images': await MultipartFile.fromFile(
  //         imageFile.path,
  //         filename: imageFile.path.split('/').last,
  //       ),
  //     });
  //
  //     final response = await Request.formData(url, formData, 'POST', true);
  //     Map<String, dynamic> responseData =
  //         jsonDecode(response.data) as Map<String, dynamic>;
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (responseData['status'] == true) {
  //         return Right(UserImageResponse.fromJson(responseData));
  //       } else {
  //         return Left(ServerFailure(responseData['message']));
  //       }
  //     } else if (response is Response && response.statusCode == 409) {
  //       return Left(ServerFailure(responseData['message']));
  //     } else if (response is Response) {
  //       return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
  //     } else {
  //       return Left(ServerFailure("Unexpected error"));
  //     }
  //   } catch (e) {
  //     // CommonLogger.log.e(e);
  //     AppLogger.log.e(e);
  //     return Left(ServerFailure('Something went wrong'));
  //   }
  // }

  // Future<Either<Failure, ShopInfoPhotosResponse>> shopPhotoUpload({
  //   required List<Map<String, String>> items,
  //   String? apiShopId,
  // }) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     // final shopId = prefs.getString('shop_id');
  //     final shopIdToUse = apiShopId ?? prefs.getString('shop_id') ?? '';
  //     final url = ApiUrl.shopPhotosUpload(shopId: shopIdToUse ?? '');
  //
  //     final payload = {"items": items};
  //
  //     final response = await Request.sendRequest(url, payload, 'POST', true);
  //
  //     AppLogger.log.i(payload);
  //     AppLogger.log.i(response);
  //
  //     if (response is! DioException) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.data['status'] == true) {
  //           return Right(ShopInfoPhotosResponse.fromJson(response.data));
  //         } else {
  //           return Left(
  //             ServerFailure(response.data['message'] ?? "Upload failed"),
  //           );
  //         }
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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
    } catch (e) {
      AppLogger.log.e(e);
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

  ///old///
  // Future<Either<Failure, ProductResponse>> addProduct({
  //   required String category,
  //   required String subCategory,
  //   required String englishName,
  //   required int price,
  //   required String offerLabel,
  //   required String offerValue,
  //   String? apiShopId,
  //   String? apiProductId,
  //   required bool doorDelivery,
  //
  //   required String description,
  // }) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final shopId = prefs.getString('shop_id');
  //
  //     final shopIdToUse = apiShopId ?? prefs.getString('shop_id') ?? '';
  //     final productId = apiProductId ?? prefs.getString('product_id');
  //     AppLogger.log.i(productId);
  //     final url = (productId != null && productId.isNotEmpty)
  //         ? ApiUrl.updateProducts(productId: productId)
  //         : ApiUrl.addProducts(shopId: shopIdToUse);
  //
  //     final payload = {
  //       "category": category,
  //       "subCategory": subCategory,
  //       "englishName": englishName,
  //       "tamilName": "ரெட்மி நோட் 13",
  //       "price": price,
  //       "offerLabel": offerLabel,
  //       "offerValue": "$offerValue%",
  //       "description": description,
  //       "doorDelivery": doorDelivery,
  //     };
  //
  //     dynamic response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     AppLogger.log.i(response);
  //     AppLogger.log.i(payload);
  //
  //     if (response is! DioException) {
  //       // If status code is success
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.data['status'] == true) {
  //           return Right(ProductResponse.fromJson(response.data));
  //         } else {
  //           return Left(
  //             ServerFailure(response.data['message'] ?? "Login failed"),
  //           );
  //         }
  //       } else {
  //         // ❗ API returned non-success code but has JSON error message
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } catch (e) {
  //     print(e);
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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

  // Future<Either<Failure, WhatsappResponse>> whatsAppNumberVerify({
  //   required String contact,
  //   required String purpose,
  // }) async {
  //   try {
  //     final url = ApiUrl.whatsAppVerify;
  //
  //     final payload = {"contact": "+91$contact", "purpose": purpose};
  //
  //     final response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     AppLogger.log.i(response);
  //
  //     // assuming response.data is already a Map<String, dynamic>
  //     final data = response.data;
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (data['status'] == true) {
  //         return Right(WhatsappResponse.fromJson(data));
  //       } else {
  //         return Left(ServerFailure(data['message'] ?? "Login failed"));
  //       }
  //     } else {
  //       return Left(ServerFailure(data['message'] ?? "Something went wrong"));
  //     }
  //   } on DioException catch (dioError) {
  //     final errorData = dioError.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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

  // Future<Either<Failure, ServiceInfoResponse>> serviceList({
  //   required List<String> images,
  //   required List<Map<String, String>> features,
  // }) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final serviceId = prefs.getString('service_id') ?? '';
  //
  //     String url = ApiUrl.serviceList(serviceId: serviceId);
  //
  //     final payload = {"images": images, "features": features};
  //
  //     dynamic response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     AppLogger.log.i(response);
  //     AppLogger.log.i(payload);
  //
  //     if (response is! DioException) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.data['status'] == true) {
  //           return Right(ServiceInfoResponse.fromJson(response.data));
  //         } else {
  //           return Left(
  //             ServerFailure(response.data['message'] ?? "Update failed"),
  //           );
  //         }
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } catch (e) {
  //     AppLogger.log.e(e);
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopsResponse>> getAllShops({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.getAllShopsDetails(shopId: shopId);

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
}
