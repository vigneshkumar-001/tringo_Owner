import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Model/shop_root_response.dart';
import 'package:tringo_vendor/Presentation/Home/Model/enquiry_response.dart';
import 'package:tringo_vendor/Presentation/Home/Model/shops_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final EnquiryResponse? enquiryResponse;
  final ShopsResponse? shopsResponse;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.enquiryResponse,
    this.shopsResponse,
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    bool? isLoading,
    String? error,
    EnquiryResponse? enquiryResponse,
    ShopsResponse? shopsResponse,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      // if you pass `error: null` it will clear error, else keep old
      error: error,
      enquiryResponse: enquiryResponse ?? this.enquiryResponse,
      shopsResponse: shopsResponse ?? this.shopsResponse,
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

  Future<void> fetchAllEnquiry({String? shopId}) async {
    // only set loading flag, keep shopsResponse as it is
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getAllEnquiry();

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

  Future<void> fetchShops() async {
    // only set loading flag, keep enquiryResponse
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getAllShops();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          shopsResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          shopsResponse: response,
        );
      },
    );
  }
}

final homeNotifierProvider =
    NotifierProvider.autoDispose<HomeNotifier, HomeState>(HomeNotifier.new);
