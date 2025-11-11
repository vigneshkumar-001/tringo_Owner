import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../model/login_response.dart';
import '../model/otp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final LoginResponse? loginResponse;
  final OtpResponse? otpResponse;
  final String? error;

  const LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
    );
  }
}

/// --- NOTIFIER ---
class LoginNotifier extends Notifier<LoginState> {
  late final ApiDataSource api;

  @override
  LoginState build() {
    api = ref.read(apiDataSourceProvider);
    return LoginState.initial();
  }

  void resetState() => state = LoginState.initial();

  Future<void> loginUser({required String phoneNumber, String? page}) async {
    state = const LoginState(isLoading: true);

    final result = await api.mobileNumberLogin(phoneNumber, page ?? '');

    result.fold(
      (Failure failure) {
        state = LoginState(isLoading: false, error: failure.message);
      },
      (LoginResponse response) {
        state = LoginState(isLoading: false, loginResponse: response);
      },
    );
  }

  Future<void> verifyOtp({required String contact, required String otp}) async {
    state = const LoginState(isLoading: true);

    final result = await api.otp(contact: contact, otp: otp);

    result.fold(
      (failure) => state = LoginState(isLoading: false, error: failure.message),
      (OtpResponse response) async {
        final data = response.data;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data?.accessToken ?? '');
        await prefs.setString('refreshToken', data?.refreshToken ?? '');
        await prefs.setString('sessionToken', data?.sessionToken ?? '');
        await prefs.setString('role', data?.role ?? '');

        state = LoginState(isLoading: false, otpResponse: response);
      },
    );
  }
}

/// --- PROVIDERS ---
final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
