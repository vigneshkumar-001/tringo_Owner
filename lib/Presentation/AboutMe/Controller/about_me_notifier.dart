import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Model/shop_root_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';

class AboutMeState {
  final bool isLoading;
  final String? error;
  final ShopRootResponse? shopRootResponse;

  const AboutMeState({
    this.isLoading = false,
    this.error,
    this.shopRootResponse,
  });

  factory AboutMeState.initial() => const AboutMeState();
}

class AboutMeNotifier extends Notifier<AboutMeState> {
  late final ApiDataSource api;

  @override
  AboutMeState build() {
    api = ref.read(apiDataSourceProvider);
    return AboutMeState.initial();
  }

  Future<void> fetchAllShopDetails({String? shopId}) async {
    state = const AboutMeState(isLoading: true);

    final result = await api.getAllShopDetails(shopId: shopId ?? '');

    result.fold(
      (failure) => state = AboutMeState(
        isLoading: false,
        error: failure.message,
        shopRootResponse: null,
      ),
      (response) =>
          state = AboutMeState(isLoading: false, shopRootResponse: response),
    );
  }
}

final aboutMeNotifierProvider = NotifierProvider<AboutMeNotifier, AboutMeState>(
  AboutMeNotifier.new,
);
