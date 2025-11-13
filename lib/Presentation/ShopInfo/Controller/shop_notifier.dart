import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_list_response.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_response.dart';
import '../../../Api/Repository/failure.dart';

class ShopCategoryState {
  final bool isLoading;
  final String? error;
  final ShopCategoryResponse? shopCategoryResponse;
  final ShopCategoryListResponse? shopCategoryListResponse;

  const ShopCategoryState({
    this.isLoading = false,
    this.error,
    this.shopCategoryResponse,
    this.shopCategoryListResponse,
  });

  factory ShopCategoryState.initial() => const ShopCategoryState();
}

class ShopNotifier extends Notifier<ShopCategoryState> {
  final ApiDataSource apiDataSource = ApiDataSource();

  @override
  ShopCategoryState build() => ShopCategoryState.initial();

  Future<void> shopCategoryInfo({
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
    state = const ShopCategoryState(isLoading: true);

    final result = await apiDataSource.shopCategoryInfo(
      category: category,
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
      contactEmail: contactEmail,
      doorDelivery: doorDelivery,
    );

    result.fold(
      (Failure failure) =>
          state = ShopCategoryState(isLoading: false, error: failure.message),
      (response) => state = ShopCategoryState(
        isLoading: false,
        shopCategoryResponse: response,
      ),
    );
  }

  Future<void> fetchCategories() async {
    state = const ShopCategoryState(isLoading: true);

    final result = await apiDataSource
        .getShopCategories(); // Implement this API in ApiDataSource

    result.fold(
      (failure) =>
          state = ShopCategoryState(isLoading: false, error: failure.message),
      (response) => state = ShopCategoryState(
        isLoading: false,
        shopCategoryListResponse: response,
      ),
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
