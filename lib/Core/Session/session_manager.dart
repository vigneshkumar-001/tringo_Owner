import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';

class SessionManager {
  static bool _isLoggingOut = false;

  static Future<void> forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('sessionToken');
    await prefs.remove('userId');

    // ✅ Go to login & clear stack (go() replaces route)
    goRouter.go(AppRoutes.loginPath, extra: {
      "phone": "",
      "simToken": "",
    });

    _isLoggingOut = false;
  }
}
