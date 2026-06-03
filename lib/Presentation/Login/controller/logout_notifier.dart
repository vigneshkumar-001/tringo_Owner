import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Api/DataSource/api_data_source.dart';
import 'package:tringo_owner/Api/Repository/failure.dart';
import 'package:tringo_owner/Presentation/Login/controller/login_notifier.dart';
import 'package:tringo_owner/Presentation/Login/model/logout_response.dart';

class LogoutState {
  final bool isLoading;
  final String? error;
  final LogoutResponse? response;

  const LogoutState({this.isLoading = false, this.error, this.response});

  factory LogoutState.initial() => const LogoutState();
}

class LogoutNotifier extends Notifier<LogoutState> {
  late final ApiDataSource api;

  @override
  LogoutState build() {
    api = ref.read(apiDataSourceProvider);
    return LogoutState.initial();
  }

  Future<void> logout() async {
    state = const LogoutState(isLoading: true);

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = (prefs.getString('refreshToken') ?? '').trim();
    final sessionToken = (prefs.getString('sessionToken') ?? '').trim();

    if (refreshToken.isEmpty) {
      state = const LogoutState(isLoading: false, error: 'Missing refresh token');
      return;
    }

    final result = await api.logout(
      refreshToken: refreshToken,
      sessionToken: sessionToken.isEmpty ? null : sessionToken,
    );

    result.fold(
      (Failure failure) {
        state = LogoutState(isLoading: false, error: failure.message);
      },
      (res) {
        state = LogoutState(isLoading: false, response: res);
      },
    );
  }
}

final logoutNotifierProvider =
    NotifierProvider.autoDispose<LogoutNotifier, LogoutState>(
  LogoutNotifier.new,
);
