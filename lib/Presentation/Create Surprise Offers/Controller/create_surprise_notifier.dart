import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_owner/Presentation/Create%20Surprise%20Offers/Model/create_surprise_response.dart';
import 'package:tringo_owner/Presentation/Create%20Surprise%20Offers/Model/store_list_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../AboutMe/Model/service_edit_response.dart';
import '../../AboutMe/Model/service_remove_response.dart';
import '../../Login/controller/login_notifier.dart';
import '../../ShopInfo/model/shop_category_list_response.dart';
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

  Future<bool> createSurpriseOffer({
    required String branchId,

    required String title,
    required String description,
    required String shopIdToUse,
    required int couponCount,
    File? ownerImageFile, // only used if type == service
    required String availableFrom,
    required String availableTo,
  }) async {
    state = const CreateSurpriseState(isLoading: true, error: null);
    String ownerImageUrl = '';

    // Upload owner image only if type is 'service' and file is provided
    if (ownerImageFile != null) {
      final uploadResult = await api.userProfileUpload(
        imageFile: ownerImageFile,
      );

      ownerImageUrl =
          uploadResult.fold<String?>(
            (failure) => null,
            (success) => success.message,
          ) ??
          '';
    }

    final result = await api.createSurpriseOffer(
      branchId: branchId,
      bannerUrl: ownerImageUrl,
      shopIdToUse: shopIdToUse,
      title: title,
      description: description,
      couponCount: couponCount,
      availableFrom: availableFrom,
      availableTo: availableTo,
    );

    final isSuccess = await result.fold<Future<bool>>(
      (failure) async {
        state = CreateSurpriseState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        state = CreateSurpriseState(
          isLoading: false,
          createSurpriseResponse: response,
          error: null, // 🔥 CLEAR OLD ERROR
        );
        return true;
      },
    );

    return isSuccess;
  }

  Future<void> getBranchList({String? apiShopId}) async {
    state = const CreateSurpriseState(isLoading: true);

    final result = await api.getBranchList(apiShopId: apiShopId);

    result.fold(
      (failure) =>
          state = CreateSurpriseState(isLoading: false, error: failure.message),
      (response) => state = CreateSurpriseState(
        isLoading: false,
        storeListResponse: response,
      ),
    );
  }

  Future<void> surpriseOfferList({String? shopId}) async {
    state = const CreateSurpriseState(isLoading: true);

    final sid = (shopId ?? '').trim();
    if (sid.isEmpty) {
      state = const CreateSurpriseState(
        isLoading: false,
        error: "Shop id missing",
      );
      return;
    }

    final result = await api.surpriseOfferList(shopId: sid);

    result.fold(
      (failure) =>
          state = CreateSurpriseState(isLoading: false, error: failure.message),
      (response) => state = CreateSurpriseState(
        isLoading: false,
        surpriseOfferListResponse: response,
      ),
    );
  }
}

final createSurpriseNotifier =
    NotifierProvider<CreateSurpriseNotifier, CreateSurpriseState>(
      CreateSurpriseNotifier.new,
    );
