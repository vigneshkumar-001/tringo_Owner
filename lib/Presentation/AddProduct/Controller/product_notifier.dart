import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Model/product_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../AboutMe/Service/Model/service_delete_response.dart';
import '../../Login/controller/login_notifier.dart';
import '../../ShopInfo/model/shop_category_list_response.dart';
import '../Model/delete_response.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final ProductResponse? productResponse;
  final ShopCategoryListResponse? shopCategoryListResponse;
  final DeleteResponse? DeleteResponses;
  final ServiceDeleteResponse? serviceDeleteResponse;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.productResponse,
    this.shopCategoryListResponse,
    this.DeleteResponses,
    this.serviceDeleteResponse,
  });

  factory ProductState.initial() => const ProductState();
}

class ProductNotifier extends Notifier<ProductState> {
  late final ApiDataSource api;

  @override
  ProductState build() {
    api = ref.read(apiDataSourceProvider);
    return ProductState.initial();
  }

  Future<bool> addProduct({
    required String category,
    required String subCategory,
    required String englishName,
    required int price,
    required String offerLabel,
    required String offerValue,
    required String description,
    String? shopId,
    String? productId,
  }) async {
    state = const ProductState(isLoading: true);

    final String? productIdToUse = (productId != null && productId.isNotEmpty)
        ? productId
        : null;

    final result = await api.addProduct(
      apiProductId: productIdToUse,
      subCategory: subCategory,
      apiShopId: shopId,
      englishName: englishName,
      category: category,
      description: description,
      offerLabel: offerLabel,
      offerValue: offerValue,
      price: price,
    );

    final isSuccess = await result.fold<Future<bool>>(
      (failure) async {
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('product_id', response.data.id);
        state = ProductState(isLoading: false, productResponse: response);
        return true;
      },
    );

    return isSuccess;
  }

  ///old///
  // Future<bool> addProduct({
  //   required String category,
  //   required String subCategory,
  //   required String englishName,
  //   required int price,
  //   required String offerLabel,
  //   required String offerValue,
  //   required String description,
  //   String? shopId,
  //   String? productId,
  // }) async {
  //   state = const ProductState(isLoading: true);
  //
  //   final result = await api.addProduct(
  //     apiProductId: productId,
  //     subCategory: subCategory,
  //     apiShopId: shopId,
  //     englishName: englishName,
  //     category: category,
  //     description: description,
  //     offerLabel: offerLabel,
  //     offerValue: offerValue,
  //     price: price,
  //   );
  //
  //   final isSuccess = await result.fold<Future<bool>>(
  //     (failure) async {
  //       state = ProductState(isLoading: false, error: failure.message);
  //       return false;
  //     },
  //     (response) async {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('product_id', response.data.id);
  //       state = ProductState(isLoading: false, productResponse: response);
  //       return true;
  //     },
  //   );
  //
  //   return isSuccess;
  // }

  Future<void> fetchProductCategories() async {
    state = const ProductState(isLoading: true);

    final result = await api.getProductCategories();

    result.fold(
      (failure) =>
          state = ProductState(isLoading: false, error: failure.message),
      (response) => state = ProductState(
        isLoading: false,
        shopCategoryListResponse: response,
      ),
    );
  }

  Future<bool> uploadProductImages({
    required List<File?> images,
    required List<Map<String, String>> features,
    required BuildContext context,
  }) async {
    // ---- VALIDATION ----
    if (images.isEmpty || images.every((f) => f == null)) {
      state = const ProductState(
        isLoading: false,
        error: "Please select at least 1 image",
      );
      return false;
    }

    state = const ProductState(isLoading: true);

    // ---- STEP 1: UPLOAD IMAGES ONE BY ONE ----
    List<String> uploadedUrls = [];

    for (final file in images) {
      if (file == null) continue;

      final uploadResult = await api.userProfileUpload(imageFile: file);

      final uploadedUrl = uploadResult.fold<String?>(
        (failure) => null,
        (success) => success.message,
      );

      if (uploadedUrl == null) {
        state = const ProductState(
          isLoading: false,
          error: "Image upload failed",
        );
        return false;
      }

      uploadedUrls.add(uploadedUrl);
    }

    if (uploadedUrls.isEmpty) {
      state = const ProductState(isLoading: false, error: "No image uploaded");
      return false;
    }

    // ---- STEP 2: UPDATE PRODUCT WITH IMAGES + FEATURES ----
    final result = await api.updateProducts(
      images: uploadedUrls,
      features: features,
    );

    return result.fold(
      (failure) {
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        state = ProductState(isLoading: false, productResponse: response);
        return response.status == true;
      },
    );
  }

  Future<bool> updateProductSearchWords({
    required List<String> keywords,
  }) async {
    state = const ProductState(isLoading: true);

    final result = await api.updateSearchKeyWords(keywords: keywords);

    bool success = false;

    result.fold(
      (failure) {
        state = ProductState(isLoading: false, error: failure.message);
        success = false;
      },
      (response) async {
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.remove('product_id');

        state = ProductState(isLoading: false, productResponse: response);
        success = true;
      },
    );

    return success;
  }

  void resetState() {
    state = ProductState.initial();
  }

  Future<bool> deleteProductAction({String? productId}) async {
    if (!ref.mounted) return false;

    state = const ProductState(isLoading: true, error: null);

    final result = await api.deleteProduct(productId: productId);

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        if (!ref.mounted) return false;
        AppLogger.log.e('❌ deleteProduct failure: ${failure.message}');
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        if (!ref.mounted) return false;
        AppLogger.log.i('✅ deleteProduct status: ${response.status}');
        state = ProductState(isLoading: false, DeleteResponses: response);
        return response.status == true;
      },
    );
  }

  Future<bool> deleteServiceAction({String? serviceId}) async {
    if (!ref.mounted) return false;

    state = const ProductState(isLoading: true, error: null);

    final result = await api.deleteService(serviceId: serviceId);

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        if (!ref.mounted) return false;
        AppLogger.log.e('❌ deleteProduct failure: ${failure.message}');
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        if (!ref.mounted) return false;
        AppLogger.log.i('✅ deleteProduct status: ${response.status}');
        state = ProductState(isLoading: false, serviceDeleteResponse: response);
        return response.status == true;
      },
    );
  }
}

final productNotifierProvider = NotifierProvider<ProductNotifier, ProductState>(
  ProductNotifier.new,
);
