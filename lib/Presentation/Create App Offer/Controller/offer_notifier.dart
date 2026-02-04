import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/app_snackbar.dart';
import 'package:tringo_owner/Presentation/Create%20App%20Offer/Model/offer_products.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';
import '../../Offer/Model/offer_model.dart';
import '../Model/create_offers.dart';
import '../Model/edit_offers_response.dart';
import '../Model/update_offer_model.dart';

class createOfferState {
  final bool isLoading;
  final bool updateInsertLoading;
  final String? error;
  final CreateOffers? createOffers;
  final OfferProductsResponse? offerProducts;
  final UpdateOfferModel? updateOfferModel;
  final OfferModel? offerModel;
  final EditOffersResponse? editOffersResponse;

  const createOfferState({
    this.isLoading = false,
    this.updateInsertLoading = false,
    this.error,
    this.createOffers,
    this.offerProducts,
    this.updateOfferModel,
    this.offerModel,
    this.editOffersResponse,
  });

  factory createOfferState.initial() => const createOfferState();

  createOfferState copyWith({
    bool? isLoading,
    bool? updateInsertLoading,
    String? error,
    CreateOffers? createOffers,
    OfferProductsResponse? offerProducts,
    UpdateOfferModel? updateOfferModel,
    OfferModel? offerModel,
    EditOffersResponse? editOffersResponse,
    bool clearError = false,
  }) {
    return createOfferState(
      isLoading: isLoading ?? this.isLoading,
      updateInsertLoading: updateInsertLoading ?? this.updateInsertLoading,
      error: clearError ? null : (error ?? this.error),
      createOffers: createOffers ?? this.createOffers,
      offerProducts: offerProducts ?? this.offerProducts,
      updateOfferModel: updateOfferModel ?? this.updateOfferModel,
      offerModel: offerModel ?? this.offerModel,
      editOffersResponse: editOffersResponse ?? this.editOffersResponse,
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
    required String type,
    required BuildContext context,
  }) async {
    state = state.copyWith(updateInsertLoading: true, clearError: true);

    final result = await api.updateOfferList(
      type: type,
      shopId: shopId,
      offerId: offerId,
      productIds: productIds,
    );

    return result.fold(
      (failure) {
        AppSnackBar.error(context, failure.message);
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

  Future<void> offerScreenEnquiry({String? shopId}) async {
    // only set loading flag, keep shopsResponse as it is
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.offerScreen(shopId: shopId ?? '');

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          offerModel: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          offerModel: response,
        );
      },
    );
  }

  Future<bool> editAndUpdateOffer({
    required List<String> productIds,
    required String shopId,
    required String offerId,
    required String type,
    required BuildContext context,
    required String title,
    required String description,
    required int discountPercentage,
    required String availableFrom,
    required String availableTo,
    required String announcementAt,
  }) async {
    state = state.copyWith(updateInsertLoading: true, clearError: true);

    final result = await api.editAndUpdateOffer(
      title: title,
      announcementAt: announcementAt,
      availableFrom: availableFrom,
      availableTo: availableTo,
      description: description,
      discountPercentage: discountPercentage,
      type: type,
      shopId: shopId,
      offerId: offerId,
      productIds: productIds,
    );

    return result.fold(
      (failure) {
        AppSnackBar.error(context, failure.message);
        state = state.copyWith(
          updateInsertLoading: false,
          error: failure.message,
        );
        return false;
      },
      (response) {
        state = state.copyWith(
          updateInsertLoading: false,
          editOffersResponse: response,
        );
        return true;
      },
    );
  }
}

final offerNotifierProvider = NotifierProvider<OfferNotifier, createOfferState>(
  OfferNotifier.new,
);
