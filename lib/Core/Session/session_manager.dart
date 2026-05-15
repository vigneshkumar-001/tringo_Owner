import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Api/DataSource/api_data_source.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';
import 'package:tringo_owner/Core/Session/registration_product_seivice.dart';
import 'package:tringo_owner/Core/Session/registration_session.dart';

class SessionManager {
  static bool _isLoggingOut = false;
  static ValueNotifier<int>? _providerScopeResetSignal;

  static void bindProviderScopeResetSignal(ValueNotifier<int> signal) {
    _providerScopeResetSignal = signal;
  }

  static void _resetProviderScope() {
    final signal = _providerScopeResetSignal;
    if (signal == null) return;
    signal.value = signal.value + 1;
  }

  static Future<void> _clearLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Logout should not leak any user-specific leftovers (e.g., selected shop,
    // onboarding flags). Existing UI logout uses prefs.clear(); keep consistent.
    await prefs.clear();

    // Reset in-memory singletons that can leak state across sessions.
    RegistrationSession.instance.reset();
    RegistrationProductSeivice.instance.reset();
  }

  static Future<void> forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    await _clearLocalUserData();
    _resetProviderScope();

    // Go to login & clear stack (go() replaces route)
    goRouter.go(AppRoutes.loginPath, extra: {
      "phone": "",
      "simToken": "",
    });

    _isLoggingOut = false;
  }

  static Future<void> logoutWithBackend() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = (prefs.getString('refreshToken') ?? '').trim();
    final sessionToken = (prefs.getString('sessionToken') ?? '').trim();

    // Local logout immediately (no UI blocking).
    await _clearLocalUserData();
    _resetProviderScope();
    goRouter.go(AppRoutes.loginPath, extra: {
      "phone": "",
      "simToken": "",
    });

    // Backend logout in background; ignore failures (token may be expired/revoked).
    try {
      if (refreshToken.isNotEmpty) {
        final api = ApiDataSource();
        final result = await api.logout(
          refreshToken: refreshToken,
          sessionToken: sessionToken.isEmpty ? null : sessionToken,
        );
        result.fold(
          (failure) {
            AppLogger.log.w('Logout API failed: ${failure.message}');
          },
          (_) {},
        );
      }
    } catch (e, st) {
      AppLogger.log.w('Logout API exception: $e\n$st');
    } finally {
      _isLoggingOut = false;
    }
  }
}

