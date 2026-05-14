import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Session/session_manager.dart';

class Request {
  static const bool _isRelease = bool.fromEnvironment('dart.vm.product');

  static Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = <String, dynamic>{};
    headers.forEach((k, v) {
      final key = k.toString();
      final lower = key.toLowerCase();
      if (lower == 'authorization') {
        redacted[key] = 'Bearer ***';
      } else if (lower == 'x-session-token') {
        redacted[key] = '***';
      } else {
        redacted[key] = v;
      }
    });
    return redacted;
  }

  static Map<String, dynamic> _redactBody(Map<String, dynamic> body) {
    const sensitiveKeys = <String>{
      'password',
      'token',
      'refreshToken',
      'sessionToken',
      'otp',
      'simToken',
      'fcmToken',
    };

    dynamic redact(dynamic value) {
      if (value is Map) {
        return value.map((k, v) {
          final key = k.toString();
          if (sensitiveKeys.contains(key)) return MapEntry(key, '***');
          return MapEntry(key, redact(v));
        });
      }
      if (value is List) return value.map(redact).toList();
      return value;
    }

    return (redact(body) as Map).cast<String, dynamic>();
  }

  static Future<dynamic> sendRequest(
    String url,
    Map<String, dynamic> body,
    String? method,
    bool isTokenRequired, {
    Map<String, dynamic>? extraHeaders, // ✅ NEW
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? sessionToken = prefs.getString('sessionToken');
    final String? userId = prefs.getString('userId'); // (currently unused)

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              if (!_isRelease) {
                AppLogger.log.i(
                  "sendRequest\n"
                  " API: $url\n"
                  " STATUS: ${response.statusCode}",
                );
              }
              return handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final status = error.response?.statusCode;

          if (status == 402) {
            return handler.reject(error);
          } else if (status == 406 || status == 401) {
            return handler.reject(error);
          } else if (status == 429) {
            return handler.reject(error);
          } else if (status == 409) {
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );

    try {
      final headers = <String, dynamic>{
        "Content-Type": "application/json",
        if (token != null && isTokenRequired) "Authorization": "Bearer $token",
        if (sessionToken != null && isTokenRequired)
          "x-session-token": sessionToken,

        // ✅ Merge extraHeaders (phone verify token etc.)
        if (extraHeaders != null) ...extraHeaders,
      };

      final httpMethod = (method ?? 'POST').toUpperCase();

      if (!_isRelease) {
        AppLogger.log.i(
          "REQUEST\n"
          " METHOD: $httpMethod\n"
          " API: $url\n"
          " BODY: ${_redactBody(body)}\n"
          " HEADERS: ${_redactHeaders(headers)}",
        );
      }

      late Response response;

      switch (httpMethod) {
        case 'GET':
          response = await dio
              .get(
                url,
                queryParameters: body.isEmpty ? null : body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        case 'PUT':
          response = await dio
              .put(
                url,
                data: body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        case 'PATCH':
          response = await dio
              .patch(
                url,
                data: body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        case 'DELETE':
          response = await dio
              .delete(
                url,
                data: body.isEmpty ? null : body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        case 'POST':
        default:
          response = await dio
              .post(
                url,
                data: body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;
      }

      AppLogger.log.i(
        "RESPONSE \n"
        " API: $url \n"
        " Token : $token \n"
        " session Token : $sessionToken \n"
        " Headers : $headers \n"
        " RESPONSE: ${response.toString()}",
      );

      AppLogger.log.i("$body");

      return response;
    } on DioException catch (e) {
      print(e);
      throw e;
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }

  static Future<Response<dynamic>> formData(
    String url,
    dynamic body,
    String? method,
    bool isTokenRequired,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.log.i(
            "REQUEST → ${options.method} ${options.uri}\nBODY → ${options.data}",
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.log.i(
            "RESPONSE ← ${response.statusCode} ${response.requestOptions.uri}\nDATA → ${response.data}",
          );
          handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final status = error.response?.statusCode;

          final data = error.response?.data;
          final msg = (data is Map && data['message'] != null)
              ? data['message'].toString().toLowerCase()
              : '';

          final isInvalidSession = msg.contains("invalid session token");

          if (status == 401 || status == 406 || isInvalidSession) {
            await SessionManager.forceLogout();
          }

          return handler.next(error);
        },
        // onError: (error, handler) {
        //   AppLogger.log.e(
        //     "ERROR ← ${error.requestOptions.uri}\nTYPE → ${error.type}\nMESSAGE → ${error.message}",
        //   );
        //   handler.next(error);
        // },
      ),
    );

    try {
      final response = await dio.request(
        url,
        data: body,
        options: Options(
          method: method ?? 'POST',
          headers: {
            if (isTokenRequired && token != null)
              "Authorization": "Bearer $token",
            "Content-Type": body is FormData
                ? "multipart/form-data"
                : "application/json",
          },
          validateStatus: (status) {
            // Only treat 2xx–3xx as success
            return status != null && status >= 200 && status < 400;
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      // TIMEOUTS — the real reason your loader spins forever
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Request timed out. Server or network is slow.");
      }

      // SERVER RESPONSE ERRORS
      if (e.response != null) {
        throw Exception(
          "API Error ${e.response?.statusCode}: ${e.response?.data}",
        );
      }

      // UNKNOWN / NETWORK
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  static Future<Response?> sendGetRequest(
    String url,
    Map<String, dynamic> queryParams,
    String method,
    bool isTokenRequired, {
    String? appName,
    String? appVersion,
    String? appPlatForm,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? sessionToken = prefs.getString('sessionToken');
    String? userId = prefs.getString('userId');

    Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              AppLogger.log.i(queryParams);
              AppLogger.log.i(
                "RESPONSE \n API: $url \n Token : $token \n session Token : $sessionToken \n Headers : headers \n RESPONSE: ${response.toString()}",
              );
              return handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final status = error.response?.statusCode;
          if (status == 402) {
            return handler.reject(error);
          } else if (status == 406 || status == 401) {
            return handler.reject(error);
          } else if (status == 429) {
            return handler.reject(error);
          } else if (status == 409) {
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );
    final headers = {
      "Content-Type": "application/json",
      if (isTokenRequired && token != null) "Authorization": "Bearer $token",
      if (isTokenRequired && sessionToken != null)
        "x-session-token": sessionToken,
      "X-App-Id": appName,
      "X-App-Version": appVersion,
      "X-Platform": appPlatForm,
    };
    try {
      Response response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      AppLogger.log.i(
        "GET RESPONSE \n API: $url \nToken: $token \nSessionToken: $sessionToken \n RESPONSE: ${response.toString()}",
      );
      return response;
    } catch (e) {
      AppLogger.log.e('GET API: $url \n ERROR: $e');
      return null;
    }
  }
}

// import 'dart:async';
//
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_owner/Core/Const/app_logger.dart';
//
// class Request {
//   static Future<dynamic> sendRequest(
//     String url,
//     Map<String, dynamic> body,
//     String? method,
//     bool isTokenRequired,
//   ) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     String? sessionToken = prefs.getString('sessionToken');
//     String? userId = prefs.getString('userId');
//
//     // AuthController authController = getx.Get.find();
//     // // OtpController otpController = getx.Get.find();
//     Dio dio = Dio(
//       BaseOptions(
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 15),
//       ),
//     );
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//           return handler.next(options);
//         },
//         onResponse:
//             (Response<dynamic> response, ResponseInterceptorHandler handler) {
//               AppLogger.log.i(body);
//               AppLogger.log.i(
//                 "sendPostRequest \n API: $url \n Token : $token \n RESPONSE: ${response.toString()}",
//               );
//               return handler.next(response);
//             },
//         onError: (DioException error, ErrorInterceptorHandler handler) async {
//           if (error.response?.statusCode == '402') {
//             // app update new version
//             return handler.reject(error);
//           } else if (error.response?.statusCode == '406' ||
//               error.response?.statusCode == '401') {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == '429') {
//             //Too many Attempts
//             return handler.reject(error);
//           } else if (error.response?.statusCode == '409') {
//             //Too many Attempts
//             return handler.reject(error);
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//     try {
//       final headers = {
//         "Content-Type": "application/json",
//         if (token != null && isTokenRequired) "Authorization": "Bearer $token",
//         if (sessionToken != null && isTokenRequired)
//           "x-session-token": sessionToken,
//       };
//
//       final response = await dio
//           .post(
//             url,
//             data: body,
//             options: Options(
//               headers: headers,
//               validateStatus: (status) => status != null && status < 503,
//             ),
//           )
//           .timeout(
//             const Duration(seconds: 10),
//             onTimeout: () {
//               throw TimeoutException("Request timed out after 10 seconds");
//             },
//           );
//       // 🔹 Debug print
//
//       AppLogger.log.i(
//         "RESPONSE \n API: $url \n Token : $token \n session Token : $sessionToken \n Headers : $headers \n RESPONSE: ${response.toString()}",
//       );
//
//       AppLogger.log.i("$body");
//
//       return response;
//     } catch (e) {
//       AppLogger.log.e('API: $url \n ERROR: $e ');
//
//       return e;
//     }
//   }
//
//   static Future<dynamic> formData(
//     String url,
//     dynamic body,
//     String? method,
//     bool isTokenRequired,
//   ) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     String? userId = prefs.getString('userId');
//
//     // AuthController authController = getx.Get.find();
//     // // OtpController otpController = getx.Get.find();
//     Dio dio = Dio();
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//           return handler.next(options);
//         },
//         onResponse:
//             (Response<dynamic> response, ResponseInterceptorHandler handler) {
//               AppLogger.log.i(
//                 "sendPostRequest \n API: $url \n RESPONSE: ${response.toString()}",
//               );
//               return handler.next(response);
//             },
//         onError: (DioException error, ErrorInterceptorHandler handler) async {
//           if (error.response?.statusCode == '402') {
//             // app update new version
//             return handler.reject(error);
//           } else if (error.response?.statusCode == '406' ||
//               error.response?.statusCode == '401') {
//             // Unauthorized user navigate to login page
//
//             return handler.reject(error);
//           } else if (error.response?.statusCode == '429') {
//             //Too many Attempts
//             return handler.reject(error);
//           } else if (error.response?.statusCode == '409') {
//             //Too many Attempts
//             return handler.reject(error);
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//     try {
//       final response = await dio.post(
//         url,
//         data: body,
//         options: Options(
//           headers: {
//             "Authorization": token != null ? "Bearer $token" : "",
//             "Content-Type": body is FormData
//                 ? "multipart/form-data"
//                 : "application/json",
//           },
//           validateStatus: (status) {
//             // Allow all status codes below 500 to be handled manually
//             return status != null && status < 500;
//           },
//         ),
//       );
//
//       AppLogger.log.i(
//         "RESPONSE \n API: $url \n RESPONSE: ${response.toString()}",
//       );
//       AppLogger.log.i("$token");
//       AppLogger.log.i("$body");
//
//       return response;
//     } catch (e) {
//       AppLogger.log.e('API: $url \n ERROR: $e ');
//
//       return e;
//     }
//   }
//
//   static Future<Response?> sendGetRequest(
//     String url,
//     Map<String, dynamic> queryParams,
//     String method,
//     bool isTokenRequired,
//   ) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     String? userId = prefs.getString('userId');
//
//     Dio dio = Dio();
//
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//           return handler.next(options);
//         },
//         onResponse:
//             (Response<dynamic> response, ResponseInterceptorHandler handler) {
//               AppLogger.log.i(queryParams);
//               AppLogger.log.i(
//                 "GET Request \n API: $url \n Token: $token \n RESPONSE: ${response.toString()}",
//               );
//               return handler.next(response);
//             },
//         onError: (DioException error, ErrorInterceptorHandler handler) async {
//           if (error.response?.statusCode == 402) {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == 406 ||
//               error.response?.statusCode == 401) {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == 429) {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == 409) {
//             return handler.reject(error);
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//
//     try {
//       Response response = await dio.get(
//         url,
//         queryParameters: queryParams,
//         options: Options(
//           headers: {
//             "Authorization": token != null
//                 ? "Bearer $token"
//                 : "", // Only the token in the header
//           },
//           validateStatus: (status) {
//             return status != null && status < 500;
//           },
//         ),
//       );
//
//       AppLogger.log.i(
//         "GET RESPONSE \n API: $url \n RESPONSE: ${response.toString()}",
//       );
//       return response;
//     } catch (e) {
//       AppLogger.log.e('GET API: $url \n ERROR: $e');
//       return null;
//     }
//   }
// }
