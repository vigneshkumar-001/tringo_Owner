import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Model/product_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../Login/controller/login_notifier.dart';
import '../../ShopInfo/model/shop_category_list_response.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final ProductResponse? productResponse;
  final ShopCategoryListResponse? shopCategoryListResponse;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.productResponse,
    this.shopCategoryListResponse,
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
  }) async
  {
    state = const ProductState(isLoading: true);

    final result = await api.addProduct(
      subCategory: subCategory,
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
}

final productNotifierProvider =
    NotifierProvider.autoDispose<ProductNotifier, ProductState>(
      ProductNotifier.new,
    );
