import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
}

