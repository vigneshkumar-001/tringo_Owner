import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Model/shop_root_response.dart';
import 'package:tringo_vendor/Presentation/Home/Model/enquiry_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';

class  HomeState {
  final bool isLoading;
  final String? error;
  final EnquiryResponse? enquiryResponse;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.enquiryResponse,
  });

  factory HomeState.initial() => const HomeState();
}

class  HomeNotifier  extends Notifier<HomeState> {
  late final ApiDataSource api;

  @override
  HomeState build() {
    api = ref.read(apiDataSourceProvider);
    return HomeState.initial();
  }

  Future<void> fetchAllEnquiry({String? shopId}) async {
    state = const HomeState(isLoading: true);

    final result = await api.getAllEnquiry();

    result.fold(
          (failure) => state = HomeState(
        isLoading: false,
        error: failure.message,
            enquiryResponse: null,
      ),
          (response) =>
      state = HomeState(isLoading: false, enquiryResponse: response),
    );
  }
}

final homeNotifierProvider =
NotifierProvider.autoDispose<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
