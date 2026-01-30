import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Presentation/Menu/Model/current_plan_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../AddProduct/Model/delete_response.dart';
import '../../Login/controller/login_notifier.dart';
import '../Model/plan_list_response.dart';
import '../Model/purchase_response.dart';
import '../Model/qr_action_response.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isInsertLoading;
  final String? error;
  final PlanListResponse? planListResponse;
  final PurchaseResponse? purchaseResponse;
  final CurrentPlanResponse? currentPlanResponse;
  final DeleteResponse? deleteResponse;
  final QrActionResponse? qrActionResponse;

  const SubscriptionState({
    this.isLoading = false,
    this.isInsertLoading = false,
    this.error,
    this.planListResponse,
    this.purchaseResponse,
    this.currentPlanResponse,
    this.deleteResponse,
    this.qrActionResponse,
  });

  factory SubscriptionState.initial() => const SubscriptionState();

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isInsertLoading,
    String? error,
    PurchaseResponse? purchaseResponse,
    PlanListResponse? planListResponse,
    CurrentPlanResponse? currentPlanResponse,
    DeleteResponse? deleteResponse,
    QrActionResponse? qrActionResponse,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isInsertLoading: isInsertLoading ?? this.isInsertLoading,
      error: clearError ? null : (error ?? this.error),
      planListResponse: planListResponse ?? this.planListResponse,
      currentPlanResponse: currentPlanResponse ?? this.currentPlanResponse,
      purchaseResponse: purchaseResponse ?? this.purchaseResponse,
      deleteResponse: deleteResponse ?? this.deleteResponse,
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

  Future<void> getCurrentPlan() async {
    state = state.copyWith(isLoading: true, currentPlanResponse: null);

    final result = await api.getCurrentPlan();

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

  Future<void> purchasePlan({
    required String planId,
    required String businessProfileId,
  }) async {
    state = state.copyWith(isInsertLoading: true, purchaseResponse: null);

    final result = await api.purchasePlan(
      planId: planId,
      businessProfileId: businessProfileId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          purchaseResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          purchaseResponse: response,
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(
      isInsertLoading: true,
      deleteResponse: null,
      error: null,
    );

    final result = await api.deleteAccount();

    result.fold(
      (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          deleteResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          deleteResponse: response,
        );
      },
    );
  }

  Future<void> shopQrCode({required String shopId}) async {
    state = state.copyWith(
      isInsertLoading: true,
      error: null,
      qrActionResponse: null,
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

  void resetState() {
    state = SubscriptionState.initial();
  }
}

final subscriptionNotifier =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
