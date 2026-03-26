import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_owner/Presentation/Login/model/app_version_response.dart';

import 'package:tringo_owner/Presentation/Login/controller/login_notifier.dart';


import '../../../Api/DataSource/api_data_source.dart';
import '../model/device_token_response.dart';
//

class AppVersionState {
  final String? appVersion;
  final AppVersionResponse? appVersionResponse;
  final bool isSendingToken;
  final String? error;
  final DeviceTokenResponse? deviceTokenResponse;

  const AppVersionState({
    this.appVersion,
    this.appVersionResponse,
    this.isSendingToken = false,
    this.error,
    this.deviceTokenResponse,
  });

  factory AppVersionState.initial() => const AppVersionState();

  AppVersionState copyWith({
    String? appVersion,
    AppVersionResponse? appVersionResponse,
    bool? isSendingToken,
    String? error,
    dynamic deviceTokenResponse,
  }) {
    return AppVersionState(
      appVersion: appVersion ?? this.appVersion,
      appVersionResponse: appVersionResponse ?? this.appVersionResponse,
      isSendingToken: isSendingToken ?? this.isSendingToken,
      error: error,
      deviceTokenResponse: deviceTokenResponse ?? this.deviceTokenResponse,
    );
  }
}

class AppVersionNotifier extends Notifier<AppVersionState> {
  late final ApiDataSource api;

  @override
  AppVersionState build() {
    api = ref.read(apiDataSourceProvider);
    return AppVersionState.initial();
  }

  Future<void> getAppVersion({
    required String appName,
    required String appVersion,
    required String appPlatForm,
  }) async {
    final results = await api.getAppVersion(
      appName: appName,
      appVersion: appVersion,
      appPlatForm: appPlatForm,
    );

    results.fold(
          (failure) {
        state = state.copyWith(error: failure.message);
      },
          (response) {
        state = state.copyWith(
          appVersion: response.data?.currentVersion,
          appVersionResponse: response,
          error: null,
        );
      },
    );
  }

  Future<void> fcmTokenSend({
    required String fcmToken,
    required String platform,
    required String deviceId,
  }) async {
    state = state.copyWith(isSendingToken: true, error: null);

    final results = await api.fcmTokenSend(
      deviceId: deviceId,
      fcmToken: fcmToken,
      platform: platform,
    );

    results.fold(
          (failure) {
        state = state.copyWith(
          isSendingToken: false,
          error: failure.message,
        );
      },
          (response) {
        state = state.copyWith(
          isSendingToken: false,
          deviceTokenResponse: response,
          error: null,
        );
      },
    );
  }
}

final appVersionNotifierProvider =
NotifierProvider<AppVersionNotifier, AppVersionState>(
  AppVersionNotifier.new,
);

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_owner/Presentation/Login/controller/login_notifier.dart';
// import 'package:tringo_owner/Presentation/Login/model/app_version_response.dart';
//
// import '../../../Api/DataSource/api_data_source.dart';
//
// class AppVersionState {
//   final String? appVersion;
//   final AppVersionResponse? appVersionResponse;
//
//   const AppVersionState({this.appVersion, this.appVersionResponse});
//
//   factory AppVersionState.initial() => AppVersionState();
// }
//
// class AppVersionNotifier extends Notifier<AppVersionState> {
//   late final ApiDataSource api;
//   @override
//   AppVersionState build() {
//     api = ref.read(apiDataSourceProvider);
//     return AppVersionState();
//   }
//
//   Future<void> getAppVersion({
//     required String appName,
//     required String appVersion,
//     required String appPlatForm,
//   }) async {
//     final results = await api.getAppVersion(
//       appName: appName,
//       appVersion: appVersion,
//       appPlatForm: appPlatForm,
//     );
//     results.fold((failure) {}, (response) {
//       state = AppVersionState(
//         appVersion: response.data?.currentVersion,
//         appVersionResponse: response,
//       );
//     });
//   }
//
//   Future<void> fcmTokenSend({
//     required String fcmToken,
//     required String platform,
//     required String deviceId,
//   }) async {
//     state = state.copyWith(isSendingToken: true, error: null);
//
//     final results = await api.fcmTokenSend(
//       deviceId: deviceId,
//       fcmToken: fcmToken,
//       platform: platform,
//     );
//
//     results.fold(
//           (failure) {
//         state = state.copyWith(isSendingToken: false, error: failure.message);
//       },
//           (response) {
//         state = state.copyWith(
//           isSendingToken: false,
//           deviceTokenResponse: response,
//           error: null,
//         );
//       },
//     );
//   }
// }
//
// final appVersionNotifierProvider =
//     NotifierProvider<AppVersionNotifier, AppVersionState>(
//       AppVersionNotifier.new,
//     );
