import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Presentation/AboutMe/Model/shop_root_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';
import '../Model/follower_response.dart';

class AboutMeState {
  final bool isLoading;
  final bool followersLoading;
  final String? error;

  final ShopRootResponse? shopRootResponse;
  final ShopsResponse? shopsResponse;

  // ✅ REQUIRED
  final FollowersResponse? followersResponse;

  const AboutMeState({
    this.isLoading = false,
    this.followersLoading = false,
    this.error,
    this.shopRootResponse,
    this.shopsResponse,
    this.followersResponse,
  });

  factory AboutMeState.initial() => const AboutMeState();

  AboutMeState copyWith({
    bool? isLoading,
    bool? followersLoading,
    String? error,
    ShopRootResponse? shopRootResponse,
    ShopsResponse? shopsResponse,
    FollowersResponse? followersResponse,
    bool clearError = false,
  }) {
    return AboutMeState(
      isLoading: isLoading ?? this.isLoading,
      followersLoading: followersLoading ?? this.followersLoading,
      error: clearError ? null : (error ?? this.error),
      shopRootResponse: shopRootResponse ?? this.shopRootResponse,
      shopsResponse: shopsResponse ?? this.shopsResponse,
      followersResponse: followersResponse ?? this.followersResponse,
    );
  }
}

class AboutMeNotifier extends Notifier<AboutMeState> {
  late final ApiDataSource api;

  @override
  AboutMeState build() {
    api = ref.read(apiDataSourceProvider);
    return AboutMeState.initial();
  }

  Future<void> fetchAllShopDetails({String? shopId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await api.getAllShopDetails(shopId: shopId ?? '');

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        shopRootResponse: null,
      ),
          (response) => state = state.copyWith(
        isLoading: false,
        shopRootResponse: response,
      ),
    );
  }

  // ✅ REQUIRED (your UI calls this)
  Future<void> fetchAllFollowerList({
    required String shopId,
    int take = 20,
    int skip = 0,
    String range = "ALL",
  }) async {
    state = state.copyWith(followersLoading: true, clearError: true);

    final result = await api.getFollowerList(
      shopId: shopId,
      take: take,
      skip: skip,
      range: range,
    );

    result.fold(
          (failure) => state = state.copyWith(
        followersLoading: false,
        error: failure.message,
        followersResponse: null,
      ),
          (response) => state = state.copyWith(
        followersLoading: false,
        followersResponse: response,
      ),
    );
  }
}

final aboutMeNotifierProvider =
NotifierProvider<AboutMeNotifier, AboutMeState>(AboutMeNotifier.new);

