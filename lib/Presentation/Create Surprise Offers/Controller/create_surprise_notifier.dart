import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_vendor/Presentation/Create%20Surprise%20Offers/Model/create_surprise_response.dart';
import 'package:tringo_vendor/Presentation/Create%20Surprise%20Offers/Model/store_list_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../AboutMe/Model/service_edit_response.dart';
import '../../AboutMe/Model/service_remove_response.dart';
import '../../Login/controller/login_notifier.dart';
import '../../ShopInfo/model/shop_category_list_response.dart';

class CreateSurpriseState {
  final bool isLoading;
  final String? error;
  final StoreListResponse? storeListResponse;
  final CreateSurpriseResponse? createSurpriseResponse;

  const CreateSurpriseState({
    this.isLoading = false,
    this.error,
    this.storeListResponse,
    this.createSurpriseResponse,
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
    state = const CreateSurpriseState(isLoading: true,error : null);
    String ownerImageUrl = '';

    // Upload owner image only if type is 'service' and file is provided
    if (  ownerImageFile != null) {
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
}

final createSurpriseNotifier =
    NotifierProvider<CreateSurpriseNotifier, CreateSurpriseState>(
      CreateSurpriseNotifier.new,
    );
