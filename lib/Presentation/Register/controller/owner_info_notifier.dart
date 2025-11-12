import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../Login/controller/login_notifier.dart';
import '../model/owner_info_response.dart';

class OwnerInfoState {
  final bool isLoading;
  final String? error;
  final OwnerInfoResponse? ownerResponse;

  const OwnerInfoState({
    this.isLoading = false,
    this.error,
    this.ownerResponse,
  });

  factory OwnerInfoState.initial() => const OwnerInfoState();
}

class OwnerInfoNotifier extends Notifier<OwnerInfoState> {
  late final ApiDataSource api;

  @override
  OwnerInfoState build() {
    api = ref.read(apiDataSourceProvider);
    return OwnerInfoState.initial();
  }

  /// Register or update owner info
  Future<void> submitOwnerInfo({
    required String govtRegisteredName,
    required String preferredLanguage,
    required String gender,
    required String dateOfBirth,
    required String identityDocumentUrl,
    required String fullName,
    required String ownerNameTamil,
    required String email,
    required String businessType,
    required String ownershipType,
  }) async {
    state = const OwnerInfoState(isLoading: true);

    final result = await api.ownerInfo(
      businessType: businessType,
      ownershipType: ownershipType,
      email: email,
      dateOfBirth: dateOfBirth,
      fullName: fullName,
      gender: gender,
      govtRegisteredName: govtRegisteredName,
      identityDocumentUrl: identityDocumentUrl,
      ownerNameTamil: ownerNameTamil,
      preferredLanguage: preferredLanguage,
    );

    result.fold(
      (Failure failure) =>
          state = OwnerInfoState(isLoading: false, error: failure.message),
      (response) =>
          state = OwnerInfoState(isLoading: false, ownerResponse: response),
    );
  }

  void resetState() {
    state = OwnerInfoState.initial();
  }
}

final ownerInfoNotifierProvider =
    NotifierProvider.autoDispose<OwnerInfoNotifier, OwnerInfoState>(
      OwnerInfoNotifier.new,
    );
