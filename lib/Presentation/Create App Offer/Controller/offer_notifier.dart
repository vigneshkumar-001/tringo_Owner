import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Model/offer_products.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';
import '../Model/create_offers.dart';
import '../Model/update_offer_model.dart';

class createOfferState {
  final bool isLoading;
  final bool updateInsertLoading;
  final String? error;
  final CreateOffers? createOffers;
  final OfferProductsResponse? offerProducts;
  final UpdateOfferModel? updateOfferModel;

  const createOfferState({
    this.isLoading = false,
    this.updateInsertLoading = false,
    this.error,
    this.createOffers,
    this.offerProducts,
    this.updateOfferModel,
  });

  factory createOfferState.initial() => const createOfferState();

  createOfferState copyWith({
    bool? isLoading,
    bool? updateInsertLoading,
    String? error,
    CreateOffers? createOffers,
    OfferProductsResponse? offerProducts,
    UpdateOfferModel? updateOfferModel,
    bool clearError = false,
  }) {
    return createOfferState(
      isLoading: isLoading ?? this.isLoading,
      updateInsertLoading: updateInsertLoading ?? this.updateInsertLoading,
      error: clearError ? null : (error ?? this.error),
      createOffers: createOffers ?? this.createOffers,
      offerProducts: offerProducts ?? this.offerProducts,
      updateOfferModel: updateOfferModel ?? this.updateOfferModel,
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

  Future<CreateOffers?> createOffer({
    required String shopId,
    required String title,
    required String description,
    required int discountPercentage,
    required String availableFrom,
    required String availableTo,
    required String announcementAt,
  }) async {
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

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (offerModel) {
        state = state.copyWith(isLoading: false, createOffers: offerModel);
        return offerModel; // <-- RETURN THE NEW OFFER ID
      },
    );
  }

  Future<void> productListShowForOffer({
    required String shopId,
    required String type,
  }) async {
    // start loading
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await api.productListShowForOffer(
      shopId: shopId,
      type: type,
    );

    result.fold(
      (failure) {
        AppLogger.log.e("productListShowForOffer: ${failure.message}");
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          offerProducts: response,
        );
      },
    );
  }

  Future<bool> updateOfferList({
    required List<String> productIds,
    required String shopId,
    required String offerId,
    required BuildContext context,
  }) async {
    state = state.copyWith(updateInsertLoading: true, clearError: true);

    final result = await api.updateOfferList(
      shopId: shopId,
      offerId: offerId,
      productIds: productIds,
    );

    return result.fold(
      (failure) {
        AppSnackBar. error(context, failure.message);
        state = state.copyWith(
          updateInsertLoading: false,
          error: failure.message,
        );
        return false;
      },
      (response) {
        state = state.copyWith(
          updateInsertLoading: false,
          updateOfferModel: response,
        );
        return true;
      },
    );
  }
}

final offerNotifierProvider = NotifierProvider<OfferNotifier, createOfferState>(
  OfferNotifier.new,
);
