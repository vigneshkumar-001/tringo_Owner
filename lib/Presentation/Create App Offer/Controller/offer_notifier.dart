import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';
import '../Model/create_offers.dart';

class createOfferState {
  final bool isLoading;
  final String? error;
  final CreateOffers? createOffers;

  const createOfferState({
    this.isLoading = false,
    this.error,
    this.createOffers,
  });

  factory createOfferState.initial() => const createOfferState();

  createOfferState copyWith({
    bool? isLoading,
    String? error,
    CreateOffers? createOffers,
    bool clearError = false,
  }) {
    return createOfferState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      createOffers: createOffers ?? this.createOffers,
    );
  }
}

class OfferNotifier extends Notifier<createOfferState> {
  late final ApiDataSource api;

  @override
  createOfferState build() {
    api = ref.read(apiDataSourceProvider);
    return createOfferState.initial();
  }

  Future<void> createOffer({
    required String shopId,
    required String title,
    required String description,
    required int discountPercentage,
    required String availableFrom,
    required String availableTo,
    required String announcementAt,
  }) async {
    // start loading
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await api.createOffer(
      shopId: shopId,
      title: title,
      description: description,
      discountPercentage: discountPercentage,
      availableFrom: availableFrom,
      availableTo: availableTo,
      announcementAt: announcementAt,
    );

    result.fold(
      (failure) {
        AppLogger.log.e("createOffer failure: ${failure.message}");
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (offerModel) {
        AppLogger.log.i("createOffer success: ${offerModel.data?.title}");
        state = state.copyWith(
          isLoading: false,
          error: null,
          createOffers: offerModel,
        );
      },
    );
  }
}

final offerNotifierProvider = NotifierProvider<OfferNotifier, createOfferState>(
  OfferNotifier.new,
);
