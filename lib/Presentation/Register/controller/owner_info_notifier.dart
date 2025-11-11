import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tringo_vendor/Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../model/owner_info_response.dart';

class OwnerInfoState {
  final bool isLoading;
  final OwnerInfoResponse? response;
  final String error;

  OwnerInfoState({this.isLoading = false, this.response, this.error = ''});

  OwnerInfoState copyWith({
    bool? isLoading,
    OwnerInfoResponse? response,
    String? error,
  }) {
    return OwnerInfoState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }
}

class OwnerInfoNotifier extends StateNotifier<OwnerInfoState> {
  final ApiDataSource dataSource;

  OwnerInfoNotifier(this.dataSource) : super(OwnerInfoState());

  Future<void> insertOwnerInfo(String phone) async {
    state = state.copyWith(isLoading: true, error: '');
    final Either<Failure, OwnerInfoResponse> result = await dataSource
        .mobileNumberLogin(phone);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(isLoading: false, response: response);
      },
    );
  }
}

final ownerInfoNotifierProvider =
    StateNotifierProvider<OwnerInfoNotifier, OwnerInfoState>(
      (ref) => OwnerInfoNotifier(ref.read(apiDataSourceProvider)),
    );

/// Provider for DataSource (if not already defined)
final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});
