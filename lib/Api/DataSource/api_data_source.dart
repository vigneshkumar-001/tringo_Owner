import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tringo_vendor/Api/Repository/api_url.dart';
import 'package:tringo_vendor/Api/Repository/failure.dart';
import 'package:tringo_vendor/Api/Repository/request.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/Login/model/login_response.dart';
import 'package:tringo_vendor/Presentation/Login/model/otp_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_list_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_response.dart';

import '../../Presentation/Register/model/owner_info_response.dart';

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
      String url = ApiUrl.shop;
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
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopCategoryResponse.fromJson(response.data));
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


  Future<Either<Failure, ShopCategoryListResponse>> getShopCategories( ) async {
    try {
      String url = ApiUrl.categoriesShop;

      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);


      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopCategoryListResponse.fromJson(response.data));
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
