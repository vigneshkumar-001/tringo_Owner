import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor/Presentation/Privacy%20Policy/Model/terms_and_condition_model.dart';

import '../../Login/controller/login_notifier.dart';
import '../model/terms_and_condition_model.dart' hide TermsAndConditionResponse;

class TermsAndConditionState {
  final bool isLoading;
  final String? error;
  final TermsAndConditionResponse? termsAndConditionResponse;
  const TermsAndConditionState({
    this.isLoading = true,

    this.error,
    this.termsAndConditionResponse,
  });

  factory TermsAndConditionState.initial() => const TermsAndConditionState();

  TermsAndConditionState copyWith({
    bool? isLoading,
    String? activeEnquiryId,
    bool? isEnquiryLoading,
    String? error,
    TermsAndConditionResponse? termsAndConditionResponse,
  }) {
    return TermsAndConditionState(
      isLoading: isLoading ?? this.isLoading,

      error: error,

      termsAndConditionResponse:
          termsAndConditionResponse ?? this.termsAndConditionResponse,
    );
  }
}

class TermsAndConditionNotifier extends Notifier<TermsAndConditionState> {
  late final ApiDataSource api;

  @override
  TermsAndConditionState build() {
    api = ref.read(apiDataSourceProvider);
    return TermsAndConditionState.initial();
  }

  Future<void> fetchTermsAndCondition() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.fetchTermsAndCondition();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          // homeResponse stays as it was (probably null on first load)
        );
      },
      (response) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
          termsAndConditionResponse: response,
        );
      },
    );
  }
}

final termsAndConditionNotifierProvider =
    NotifierProvider<TermsAndConditionNotifier, TermsAndConditionState>(
      TermsAndConditionNotifier.new,
    );
