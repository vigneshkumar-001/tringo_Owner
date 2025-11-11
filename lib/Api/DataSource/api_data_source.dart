import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tringo_vendor/Api/Repository/api_url.dart';
import 'package:tringo_vendor/Api/Repository/failure.dart';
import 'package:tringo_vendor/Api/Repository/request.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';

import '../../Presentation/Register/model/owner_info_response.dart';

abstract class BaseApiDataSource {
  Future<Either<Failure, OwnerInfoResponse>> mobileNumberLogin(
    String mobileNumber,
  );
}

class ApiDataSource extends BaseApiDataSource {
  @override
  Future<Either<Failure, OwnerInfoResponse>> mobileNumberLogin(
    String phone,
  ) async {
    try {
      String url = ApiUrl.register;

      dynamic response = await Request.sendRequest(
        url,
        {"phone": phone},
        'Post',
        false,
      );

      AppLogger.log.i(response);

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
      return Left(ServerFailure(e.toString()));
    }
  }
}
