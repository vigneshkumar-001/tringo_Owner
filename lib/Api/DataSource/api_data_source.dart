import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Api/Repository/api_url.dart';
import 'package:tringo_vendor/Api/Repository/failure.dart';
import 'package:tringo_vendor/Api/Repository/request.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_vendor/Presentation/Login/model/login_response.dart';
import 'package:tringo_vendor/Presentation/Login/model/otp_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/search_keywords_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_list_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_info_photos_response.dart';
import 'package:tringo_vendor/Presentation/Shops%20Details/model/shop_details_response.dart';

import '../../Presentation/Register/model/owner_info_response.dart';
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
    String page,
  ) async {
    try {
      String url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
      AppLogger.log.i(url);

      dynamic response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "owner"},
        'Post',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(LoginResponse.fromJson(response.data));
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
      return Left(ServerFailure(e.toString()));
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
        "businessType": "SELLING_PRODUCTS",
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopCategoryResponse>> shopCategoryInfo({
    required String category,
    required String subCategory,
    required String englishName,
    required String tamilName,
    required String descriptionEn,
    required String descriptionTa,
    required String addressEn,
    required String addressTa,
    required double gpsLatitude,
    required double gpsLongitude,
    required String primaryPhone,
    required String alternatePhone,
    required String contactEmail,
    required bool doorDelivery,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = prefs.getString('shop_id');
      final url = (shopId != null && shopId.isNotEmpty)
          ? ApiUrl.updateShop(shopId: shopId)
          : ApiUrl.shop;

      // final url = ApiUrl.shop;
      final payload = {
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
        "primaryPhone": "+91$primaryPhone",
        "alternatePhone": "+91$alternatePhone",
        "contactEmail": contactEmail,
        "doorDelivery": true,
      };

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            final data =
                response.data['data'] as Map<String, dynamic>; // cast safely
            return Right(ShopCategoryResponse.fromJson(data));
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
      AppLogger.log.i(e);
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

      String url = ApiUrl.imageUrl;
      FormData formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);
      Map<String, dynamic> responseData =
          jsonDecode(response.data) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return Right(UserImageResponse.fromJson(responseData));
        } else {
          return Left(ServerFailure(responseData['message']));
        }
      } else if (response is Response && response.statusCode == 409) {
        return Left(ServerFailure(responseData['message']));
      } else if (response is Response) {
        return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
      } else {
        return Left(ServerFailure("Unexpected error"));
      }
    } catch (e) {
      // CommonLogger.log.e(e);
      print(e);
      return Left(ServerFailure('Something went wrong'));
    }
  }

  Future<Either<Failure, ShopPhotoResponse>> shopPhotoUpload({
    required List<Map<String, String>> items,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = prefs.getString('shop_id');
      final url = ApiUrl.shopPhotosUpload(shopId: shopId ?? '');

      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      AppLogger.log.i(payload);
      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopPhotoResponse.fromJson(response.data));
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

    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = prefs.getString('shop_id');
      final productId = prefs.getString('product_id');

      final url = (productId != null && productId.isNotEmpty)
          ? ApiUrl.updateProducts(productId: productId)
          : ApiUrl.addProducts(shopId: shopId ?? '');

      // String url = ApiUrl.addProducts(shopId:shopId?? '' );

      final payload = {
        "category": category,
        "subCategory": subCategory,
        "englishName": englishName,
        "tamilName": "ரெட்மி நோட் 13",
        "price": 16999,
        "offerLabel": offerLabel,
        "offerValue": "$offerValue%",
        "description": description,
        "doorDelivery": true,
      };

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ProductResponse.fromJson(response.data));
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

  Future<Either<Failure, ShopCategoryListResponse>>
  getProductCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = prefs.getString('shop_id');
      String url = ApiUrl.productCategoryList(shopId: shopId ?? '');

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

  Future<Either<Failure, ShopDetailsResponse>> getShopDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = prefs.getString('shop_id');
      final productId = prefs.getString('product_id');

      final url = ApiUrl.shopDetails(shopId: shopId ?? '');

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
}
