import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/search_keywords_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_list_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_response.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../model/shop_info_photos_response.dart';
import '../model/shop_number_otp_response.dart';
import '../model/shop_number_verify_response.dart';

class ShopCategoryState {
  final bool isLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final String? imageUrl;
  final String? error;
  final ShopCategoryResponse? shopCategoryResponse;
  final ShopCategoryListResponse? shopCategoryListResponse;
  final ShopInfoPhotosResponse? shopPhotoResponse;
  final ShopCategoryApiResponse? shopCategoryApiResponse;
  final ShopNumberVerifyResponse? shopNumberVerifyResponse;
  final ShopNumberOtpResponse? shopNumberOtpResponse;

  const ShopCategoryState({
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.error,
    this.shopCategoryResponse,
    this.shopPhotoResponse,
    this.shopCategoryApiResponse,
    this.imageUrl,
    this.shopCategoryListResponse,
    this.shopNumberVerifyResponse,
    this.shopNumberOtpResponse,
  });

  factory ShopCategoryState.initial() => const ShopCategoryState();

  ShopCategoryState copyWith({
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    String? error,
    ShopNumberVerifyResponse? shopNumberVerifyResponse,
    ShopNumberOtpResponse? shopNumberOtpResponse,
    bool clearError = false,
  }) {
    return ShopCategoryState(
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      error: clearError ? null : (error ?? this.error),
      shopNumberVerifyResponse:
          shopNumberVerifyResponse ?? this.shopNumberVerifyResponse,
      shopNumberOtpResponse:
          shopNumberOtpResponse ?? this.shopNumberOtpResponse,
    );
  }
}

class ShopNotifier extends Notifier<ShopCategoryState> {
  final ApiDataSource apiDataSource = ApiDataSource();

  String _onlyIndian10(String input) {
    var p = input.trim();
    p = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('91') && p.length == 12) p = p.substring(2);
    if (p.length > 10) p = p.substring(p.length - 10);
    return p;
  }

  @override
  ShopCategoryState build() => ShopCategoryState.initial();

  Future<ShopCategoryResponse?> shopCategoryInfo({
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
    String? shopId,
    File? ownerImageFile, // only used if type == service
    required bool doorDelivery,
    required String type,
    required String weeklyHours,
  }) async {
    state = const ShopCategoryState(isLoading: true);

    String ownerImageUrl = '';

    // Upload owner image only if type is 'service' and file is provided
    if (type == 'service' && ownerImageFile != null) {
      final uploadResult = await apiDataSource.userProfileUpload(
        imageFile: ownerImageFile,
      );

      ownerImageUrl =
          uploadResult.fold<String?>(
            (failure) => null,
            (success) => success.message,
          ) ??
          '';
    }

    final result = await apiDataSource.shopCategoryInfo(
      type: type,
      category: category,
      weeklyHours: weeklyHours,
      apiShopId: shopId,
      subCategory: subCategory,
      englishName: englishName,
      tamilName: tamilName,
      descriptionEn: descriptionEn,
      descriptionTa: descriptionTa,
      addressEn: addressEn,
      addressTa: addressTa,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      primaryPhone: primaryPhone,
      alternatePhone: alternatePhone,
      ownerImageUrl: ownerImageUrl,
      contactEmail: contactEmail,
      doorDelivery: doorDelivery,
    );

    return result.fold(
      (failure) {
        state = ShopCategoryState(isLoading: false, error: failure.message);
        return null;
      },
      (response) async {
        // ✅ use response.data.id
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shop_id', response.data.id);

        state = ShopCategoryState(
          isLoading: false,
          shopCategoryResponse: response,
        );
        return response;
      },
    );
  }

  Future<void> fetchCategories() async {
    state = const ShopCategoryState(isLoading: true);

    final result = await apiDataSource.getShopCategories();

    result.fold(
      (failure) =>
          state = ShopCategoryState(isLoading: false, error: failure.message),
      (response) => state = ShopCategoryState(
        isLoading: false,
        shopCategoryListResponse: response,
      ),
    );
  }

  /// Returns true on success; false otherwise.
  /// No SnackBars here — let the UI decide what to show.
  Future<bool> uploadShopImages({
    required List<File?> images,
    required BuildContext context,
    String? shopId,
  }) async {
    if (images.isEmpty || images.every((e) => e == null)) {
      state = const ShopCategoryState(
        isLoading: false,
        error: 'No images selected',
      );
      return false;
    }

    state = const ShopCategoryState(isLoading: true);

    final types = ["SIGN_BOARD", "OUTSIDE", "INSIDE", "INSIDE"];
    final List<Map<String, String>> items = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      if (file == null) continue;

      final uploadResult = await apiDataSource.userProfileUpload(
        imageFile: file,
      );

      final uploadedUrl = uploadResult.fold<String?>(
        (failure) => null,
        (success) => success.message,
      );

      if (uploadedUrl != null) {
        items.add({"type": types[i], "url": uploadedUrl});
      }
    }

    if (items.isEmpty) {
      state = const ShopCategoryState(isLoading: false, error: 'Upload failed');
      return false;
    }

    final apiResult = await apiDataSource.shopPhotoUpload(
      items: items,
      apiShopId: shopId,
    );

    return apiResult.fold(
      (failure) {
        state = ShopCategoryState(isLoading: false, error: failure.message);
        AppLogger.log.e(failure.message);
        return false;
      },
      (response) {
        state = ShopCategoryState(
          isLoading: false,
          shopPhotoResponse: response,
        );
        return response.status == true;
      },
    );

    // IMPORTANT: do NOT reset state again; that would erase success/error.
  }

  Future<bool> searchKeywords({required List<String> keywords}) async {
    state = const ShopCategoryState(isLoading: true);

    final result = await apiDataSource.searchKeywords(keywords: keywords);

    bool success = false;

    result.fold(
      (failure) {
        state = ShopCategoryState(isLoading: false, error: failure.message);
        success = false;
      },
      (response) {
        state = ShopCategoryState(
          isLoading: false,
          shopCategoryApiResponse: response,
        );
        success = true;
      },
    );

    return success;
  }

  Future<String?> shopAddNumberRequest({
    required String phoneNumber,
    required String type,
  }) async {
    if (state.isSendingOtp) return "OTP_ALREADY_SENDING";
    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isSendingOtp: true, clearError: true);

    final result = await apiDataSource.shopAddNumberRequest(
      phone: phone10,
      type: type,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isSendingOtp: false, error: failure.message);
        return failure.message;
      },
      (response) {
        state = state.copyWith(
          isSendingOtp: false,
          shopNumberVerifyResponse: response,
        );
        return null; // ✅ success
      },
    );
  }

  Future<bool> shopAddOtpRequest({
    required String phoneNumber,
    required String type,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isVerifyingOtp: true, clearError: true);

    final result = await apiDataSource.shopAddOtpRequest(
      phone: phone10,
      type: type,
      code: code,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isVerifyingOtp: false, error: failure.message);
        return false;
      },
      (response) async {
        final token = response.data?.verificationToken ?? '';
        if (token.isNotEmpty) {
          await AppPrefs.setVerificationToken(token);
        }

        state = state.copyWith(
          isVerifyingOtp: false,
          shopNumberOtpResponse: response,
        );
        return response.data?.verified == true; // ✅ verified true/false
      },
    );
  }

  void resetState() {
    state = ShopCategoryState.initial();
  }
}

final shopCategoryNotifierProvider =
    NotifierProvider.autoDispose<ShopNotifier, ShopCategoryState>(
      ShopNotifier.new,
    );
