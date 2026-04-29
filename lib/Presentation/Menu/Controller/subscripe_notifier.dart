import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Presentation/Menu/Model/current_plan_response.dart';
import 'package:tringo_owner/Presentation/Menu/Model/ccavenue_init_response.dart';
import 'package:tringo_owner/Presentation/Menu/Model/subscription_confirm_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../AddProduct/Model/delete_response.dart';
import '../../Login/controller/login_notifier.dart';
import '../../AboutMe/controller/about_me_notifier.dart';
import '../../Home/Controller/shopContext_provider.dart';
import '../Model/delete_response.dart';
import '../Model/plan_list_response.dart';
import '../Model/qr_action_response.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isInsertLoading;
  final String? error;
  final PlanListResponse? planListResponse;
  final CurrentPlanResponse? currentPlanResponse;
  final CcAvenueInitResponse? ccAvenueInitResponse;
  final SubscriptionConfirmResponse? confirmResponse;
  final AccountDeleteResponse? accountDeleteResponse;
  final QrActionResponse? qrActionResponse;

  const SubscriptionState({
    this.isLoading = false,
    this.isInsertLoading = false,
    this.error,
    this.planListResponse,
    this.currentPlanResponse,
    this.ccAvenueInitResponse,
    this.confirmResponse,
    this.accountDeleteResponse,
    this.qrActionResponse,
  });

  factory SubscriptionState.initial() => const SubscriptionState();

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isInsertLoading,
    String? error,
    PlanListResponse? planListResponse,
    CurrentPlanResponse? currentPlanResponse,
    CcAvenueInitResponse? ccAvenueInitResponse,
    SubscriptionConfirmResponse? confirmResponse,
    AccountDeleteResponse? accountDeleteResponse,
    QrActionResponse? qrActionResponse,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isInsertLoading: isInsertLoading ?? this.isInsertLoading,
      error: clearError ? null : (error ?? this.error),
      planListResponse: planListResponse ?? this.planListResponse,
      currentPlanResponse: currentPlanResponse ?? this.currentPlanResponse,
      ccAvenueInitResponse: ccAvenueInitResponse ?? this.ccAvenueInitResponse,
      confirmResponse: confirmResponse ?? this.confirmResponse,
      accountDeleteResponse: accountDeleteResponse ?? this.accountDeleteResponse,
      qrActionResponse: qrActionResponse ?? this.qrActionResponse,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  late final ApiDataSource api;

  @override
  SubscriptionState build() {
    api = ref.read(apiDataSourceProvider);
    Future.microtask(() async {
      await getPlanList();
      await getCurrentPlan();
    });
    return SubscriptionState.initial();
  }

  Future<void> getPlanList() async {
    state = state.copyWith(isLoading: true, planListResponse: null);

    final result = await api.getPlanList();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          planListResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          planListResponse: response,
        );
      },
    );
  }

  Future<void> getCurrentPlan({String? businessProfileId}) async {
    state = state.copyWith(isLoading: false, currentPlanResponse: null);

    String? effectiveBusinessProfileId = businessProfileId;
    final bp = (effectiveBusinessProfileId ?? '').trim();

    if (bp.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final role = (prefs.getString('role') ?? '').trim().toUpperCase();

      if (role == 'EMPLOYEE') {
        final selectedShopId = (ref.read(selectedShopProvider) ?? '').trim();
        final persistedShopId =
            (prefs.getString('currentShopId') ?? prefs.getString('shop_id') ?? '')
                .trim();
        final shopId = selectedShopId.isNotEmpty ? selectedShopId : persistedShopId;

        // Prefer businessProfileId from existing shop list cache (AboutMe).
        final about = ref.read(aboutMeNotifierProvider);
        final shops = about.shopRootResponse?.data ?? const [];
        if (shopId.isNotEmpty) {
          for (final s in shops) {
            if ((s.shopId ?? '').trim() == shopId) {
              final v = (s.businessProfileId ?? '').trim();
              if (v.isNotEmpty) effectiveBusinessProfileId = v;
              break;
            }
          }
        }

        // Fallback: fetch shop details to get businessProfileId (best-effort).
        if ((effectiveBusinessProfileId ?? '').trim().isEmpty &&
            shopId.isNotEmpty) {
          final shopRes = await api.getShopDetails(apiShopId: shopId);
          shopRes.fold(
            (_) {},
            (resp) {
              final v = (resp.data?.businessProfileId ?? '').trim();
              if (v.isNotEmpty) effectiveBusinessProfileId = v;
            },
          );
        }
      }
    }

    final result = await api.getCurrentPlan(
      businessProfileId: effectiveBusinessProfileId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          currentPlanResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          currentPlanResponse: response,
        );
      },
    );
  }

  Future<CcAvenueInitResponse?> initCcAvenue({
    required String planId,
    String? businessProfileId,
    String? shopId,
    bool extend = false,
  }) async {
    state = state.copyWith(
      isInsertLoading: true,
      ccAvenueInitResponse: null,
      confirmResponse: null,
      clearError: true,
    );

    final result = extend
        ? await api.ccavenueExtendInit(
            planId: planId,
            businessProfileId: businessProfileId,
            shopId: shopId,
          )
        : await api.ccavenueInit(
            planId: planId,
            businessProfileId: businessProfileId,
            shopId: shopId,
          );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          ccAvenueInitResponse: null,
        );
        return null;
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          ccAvenueInitResponse: response,
        );
        return response;
      },
    );
  }

  Future<SubscriptionConfirmResponse?> confirmCcAvenue({
    required String encResp,
  }) async {
    state = state.copyWith(
      isInsertLoading: true,
      confirmResponse: null,
      clearError: true,
    );

    final result = await api.ccavenueConfirm(encResp: encResp);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          confirmResponse: null,
        );
        return null;
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          confirmResponse: response,
        );
        return response;
      },
    );
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(
      isInsertLoading: true,
      accountDeleteResponse: null,
      clearError: true,
    );

    final result = await api.deleteAccount();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          accountDeleteResponse: null,
        );
        return false;
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          accountDeleteResponse: response,
        );

        // ✅ treat both status and deleted flag
        return response.status == true && response.data.deleted == true;
      },
    );
  }

  Future<void> shopQrCode({required String shopId}) async {
    state = state.copyWith(
      isInsertLoading: true,
      clearError: true,          // ✅ important
      qrActionResponse: null,     // ✅ clear old QR
    );

    final result = await api.shopQrCode(shopId: shopId);

    result.fold(
          (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          qrActionResponse: null,
        );
      },
          (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          qrActionResponse: response,
        );
      },
    );
  }


  // Future<void> shopQrCode({required String shopId}) async {
  //   state = state.copyWith(
  //     isInsertLoading: true,
  //     error: null,
  //     qrActionResponse: null,
  //   );
  //
  //   final result = await api.shopQrCode(shopId: shopId);
  //
  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(
  //         isInsertLoading: false,
  //         error: failure.message,
  //         qrActionResponse: null,
  //       );
  //     },
  //     (response) {
  //       state = state.copyWith(
  //         isInsertLoading: false,
  //         error: null,
  //         qrActionResponse: response,
  //       );
  //     },
  //   );
  // }

  void resetState() {
    state = SubscriptionState.initial();
  }
}

final subscriptionNotifier =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
