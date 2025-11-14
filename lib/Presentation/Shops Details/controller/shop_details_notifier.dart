import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_vendor/Presentation/Shops%20Details/model/shop_details_response.dart';
import '../../../Api/DataSource/api_data_source.dart';

import '../../Login/controller/login_notifier.dart';

class ShopDetailsState {
  final bool isLoading;
  final String? error;
  final ShopDetailsResponse? shopDetailsResponse;

  const ShopDetailsState({
    this.isLoading = false,
    this.error,

    this.shopDetailsResponse,
  });

  factory ShopDetailsState.initial() => const ShopDetailsState();
}

class ShopDetailsNotifier extends Notifier<ShopDetailsState> {
  late final ApiDataSource api;

  @override
  ShopDetailsState build() {
    api = ref.read(apiDataSourceProvider);
    return ShopDetailsState.initial();
  }

  Future<void> fetchShopDetails() async {
    state = const ShopDetailsState(isLoading: true);

    final result = await api.getShopDetails();

    result.fold(
      (failure) =>
          state = ShopDetailsState(isLoading: false, error: failure.message),
      (response) => state = ShopDetailsState(
        isLoading: false,
        shopDetailsResponse: response,
      ),
    );
  }

  void resetState() {
    state = ShopDetailsState.initial();
  }
}

final shopDetailsNotifierProvider =
    NotifierProvider.autoDispose<ShopDetailsNotifier, ShopDetailsState>(
      ShopDetailsNotifier.new,
    );
