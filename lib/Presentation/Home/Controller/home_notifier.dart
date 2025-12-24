import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Model/shop_root_response.dart';
import 'package:tringo_vendor/Presentation/Home/Model/enquiry_response.dart';
import 'package:tringo_vendor/Presentation/Home/Model/mark_enquiry.dart';
import 'package:tringo_vendor/Presentation/Home/Model/shops_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final EnquiryResponse? enquiryResponse;
  final ShopsResponse? shopsResponse;
  final MarkEnquiry? markEnquiry;
  final String? selectedShopId; // ✅ ADD THIS
  const HomeState({
    this.isLoading = false,
    this.error,
    this.enquiryResponse,
    this.shopsResponse,
    this.selectedShopId,
    this.markEnquiry,
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    bool? isLoading,
    String? error,
    EnquiryResponse? enquiryResponse,
    ShopsResponse? shopsResponse,
    String? selectedShopId,
    MarkEnquiry? markEnquiry,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      // if you pass `error: null` it will clear error, else keep old
      error: error,
      enquiryResponse: enquiryResponse ?? this.enquiryResponse,
      shopsResponse: shopsResponse ?? this.shopsResponse,
      selectedShopId: selectedShopId ?? this.selectedShopId,
      markEnquiry: markEnquiry ?? this.markEnquiry,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  late final ApiDataSource api;

  @override
  HomeState build() {
    api = ref.read(apiDataSourceProvider);
    return HomeState.initial();
  }

  Future<void> selectShop(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentShopId', shopId);
    AppLogger.log.i(shopId);
    state = state.copyWith(selectedShopId: shopId);
  }

  Future<void> fetchAllEnquiry({required String shopId}) async {
    // only set loading flag, keep shopsResponse as it is
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getAllEnquiry(shopId: shopId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          enquiryResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          enquiryResponse: response,
        );
      },
    );
  }

  Future<void> fetchShops({required String shopId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getAllShops(shopId: shopId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          shopsResponse: null,
        );
      },
      (response) async {
        final isFreemium = response.data.subscription?.isFreemium ?? false;
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isFreemium', isFreemium);
        AppLogger.log.i('isNewUser Data ==== ${isFreemium}');
        state = state.copyWith(
          isLoading: false,
          error: null,
          shopsResponse: response,
        );
      },
    );
  }

  Future<void> markEnquiry({required String enquiryId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.markEnquiry(enquiryId: enquiryId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          markEnquiry: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          markEnquiry: response,
        );
      },
    );
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

// final homeNotifierProvider =
//     NotifierProvider.autoDispose<HomeNotifier, HomeState>(HomeNotifier.new);
