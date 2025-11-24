import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../model/login_response.dart';
import '../model/otp_response.dart';
import '../model/whatsapp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final LoginResponse? loginResponse;
  final OtpResponse? otpResponse;
  final String? error;
  final WhatsappResponse? whatsappResponse;

  const LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
    this.whatsappResponse,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
    WhatsappResponse? whatsappResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
      whatsappResponse: whatsappResponse ?? this.whatsappResponse,
    );
  }
}

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

        await prefs.setString('token', data?.accessToken ?? '');
        await prefs.setString('refreshToken', data?.refreshToken ?? '');
        await prefs.setString('sessionToken', data?.sessionToken ?? '');
        await prefs.setString('role', data?.role ?? '');

        //  Print what was actually stored
        final accessToken = prefs.getString('token');
        final refreshToken = prefs.getString('refreshToken');
        final sessionToken = prefs.getString('sessionToken');
        final role = prefs.getString('role');

        AppLogger.log.i(' SharedPreferences stored successfully:');
        AppLogger.log.i('token → $accessToken');
        AppLogger.log.i('refreshToken → $refreshToken');
        AppLogger.log.i('sessionToken → $sessionToken');
        AppLogger.log.i('role → $role');

        state = LoginState(isLoading: false, otpResponse: response);
      },
    );
  }

  Future<void> verifyWhatsappNumber({
    required String contact,
    required String purpose,
  }) async {
    state = LoginState(isLoading: true); // start loader

    try {
      final result = await api.whatsAppNumberVerify(
        contact: contact,
        purpose: purpose,
      );

      result.fold(
        (failure) {
          // API failed
          state = LoginState(isLoading: false, error: failure.message);
        },
        (response) {
          // API success
          state = LoginState(isLoading: false, whatsappResponse: response);
        },
      );
    } catch (e) {
      state = LoginState(isLoading: false, error: e.toString());
    }
  }
}

/// --- PROVIDERS ---
final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
