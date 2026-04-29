import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';
import '../Model/create_surprise_response.dart';
import '../Model/store_list_response.dart';
import '../Model/surprise_offer_list_response.dart';
class CreateSurpriseState {
  final bool isLoading;
  final String? error;
  final StoreListResponse? storeListResponse;
  final CreateSurpriseResponse? createSurpriseResponse;
  final SurpriseOfferListResponse? surpriseOfferListResponse;

  const CreateSurpriseState({
    this.isLoading = false,
    this.error,
    this.storeListResponse,
    this.createSurpriseResponse,
    this.surpriseOfferListResponse,
  });

  factory CreateSurpriseState.initial() => const CreateSurpriseState();
}

class CreateSurpriseNotifier extends Notifier<CreateSurpriseState> {
  late final ApiDataSource api;

  @override
  CreateSurpriseState build() {
    api = ref.read(apiDataSourceProvider);
    return CreateSurpriseState.initial();
  }

  Future<bool> saveSurpriseOffer({
    String? offerId,
    required String branchId,
    required String title,
    required String description,
    required String shopIdToUse,
    required int couponCount,
    File? bannerImageFile,
    String? existingBannerUrl,
    required String availableFrom,
    required String availableTo,
  }) async {
    state = CreateSurpriseState(
      isLoading: true,
      error: null,
      storeListResponse: state.storeListResponse,
      createSurpriseResponse: state.createSurpriseResponse,
      surpriseOfferListResponse: state.surpriseOfferListResponse,
    );

    var bannerUrl = (existingBannerUrl ?? '').trim();

    if (bannerImageFile != null) {
      final uploadResult = await api.userProfileUpload(
        imageFile: bannerImageFile,
      );

      bannerUrl =
          uploadResult.fold<String?>(
            (failure) => null,
            (success) => success.message,
          ) ??
          '';
    }

    final trimmedOfferId = (offerId ?? '').trim();

    final result = trimmedOfferId.isEmpty
        ? await api.createSurpriseOffer(
            branchId: branchId,
            bannerUrl: bannerUrl,
            shopIdToUse: shopIdToUse,
            title: title,
            description: description,
            couponCount: couponCount,
            availableFrom: availableFrom,
            availableTo: availableTo,
          )
        : await api.updateSurpriseOffer(
            offerId: trimmedOfferId,
            branchId: branchId,
            bannerUrl: bannerUrl,
            shopIdToUse: shopIdToUse,
            title: title,
            description: description,
            couponCount: couponCount,
            availableFrom: availableFrom,
            availableTo: availableTo,
          );

    final isSuccess = await result.fold<Future<bool>>(
      (failure) async {
        state = CreateSurpriseState(
          isLoading: false,
          error: failure.message,
          storeListResponse: state.storeListResponse,
          createSurpriseResponse: state.createSurpriseResponse,
          surpriseOfferListResponse: state.surpriseOfferListResponse,
        );
        return false;
      },
      (response) async {
        state = CreateSurpriseState(
          isLoading: false,
          createSurpriseResponse: response,
          error: null,
          storeListResponse: state.storeListResponse,
          surpriseOfferListResponse: state.surpriseOfferListResponse,
        );
        return true;
      },
    );

    return isSuccess;
  }

  Future<bool> createSurpriseOffer({
    required String branchId,
    required String title,
    required String description,
    required String shopIdToUse,
    required int couponCount,
    File? ownerImageFile,
    required String availableFrom,
    required String availableTo,
  }) {
    return saveSurpriseOffer(
      offerId: null,
      branchId: branchId,
      title: title,
      description: description,
      shopIdToUse: shopIdToUse,
      couponCount: couponCount,
      bannerImageFile: ownerImageFile,
      existingBannerUrl: null,
      availableFrom: availableFrom,
      availableTo: availableTo,
    );
  }
  Future<void> getBranchList({String? apiShopId}) async {
    state = CreateSurpriseState(
      isLoading: true,
      error: null,
      storeListResponse: state.storeListResponse,
      createSurpriseResponse: state.createSurpriseResponse,
      surpriseOfferListResponse: state.surpriseOfferListResponse,
    );

    final result = await api.getBranchList(apiShopId: apiShopId);

    result.fold(
      (failure) =>
          state = CreateSurpriseState(
            isLoading: false,
            error: failure.message,
            storeListResponse: state.storeListResponse,
            createSurpriseResponse: state.createSurpriseResponse,
            surpriseOfferListResponse: state.surpriseOfferListResponse,
          ),
      (response) => state = CreateSurpriseState(
        isLoading: false,
        storeListResponse: response,
        createSurpriseResponse: state.createSurpriseResponse,
        surpriseOfferListResponse: state.surpriseOfferListResponse,
      ),
    );
  }

  Future<void> surpriseOfferList({String? shopId}) async {
    state = CreateSurpriseState(
      isLoading: true,
      error: null,
      storeListResponse: state.storeListResponse,
      createSurpriseResponse: state.createSurpriseResponse,
      surpriseOfferListResponse: state.surpriseOfferListResponse,
    );

    final sid = (shopId ?? '').trim();
    if (sid.isEmpty) {
      state = CreateSurpriseState(
        isLoading: false,
        error: "Shop id missing",
        storeListResponse: state.storeListResponse,
        createSurpriseResponse: state.createSurpriseResponse,
        surpriseOfferListResponse: state.surpriseOfferListResponse,
      );
      return;
    }

    final result = await api.surpriseOfferList(shopId: sid);

    result.fold(
      (failure) =>
          state = CreateSurpriseState(
            isLoading: false,
            error: failure.message,
            storeListResponse: state.storeListResponse,
            createSurpriseResponse: state.createSurpriseResponse,
            surpriseOfferListResponse: state.surpriseOfferListResponse,
          ),
      (response) => state = CreateSurpriseState(
        isLoading: false,
        surpriseOfferListResponse: response,
        storeListResponse: state.storeListResponse,
        createSurpriseResponse: state.createSurpriseResponse,
      ),
    );
  }
}

final createSurpriseNotifier =
    NotifierProvider<CreateSurpriseNotifier, CreateSurpriseState>(
      CreateSurpriseNotifier.new,
    );



