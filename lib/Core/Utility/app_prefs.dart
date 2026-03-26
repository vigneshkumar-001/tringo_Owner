import 'package:shared_preferences/shared_preferences.dart';


class AppPrefs {
  AppPrefs._(); // no instance

  static const _kPhoneVerifyToken = 'primaryPhoneVerificationToken';

  static const String _token = 'token';
  static const String _refreshToken = 'refreshToken';
  static const String _sessionToken = 'sessionToken';
  static const String _role = 'role';
  static const _kOwnerPhone = 'owner_phone';
  static const String _kOnboardingStep = 'onboardingStep';

  // Registration flow flags (needed to resume onboarding screens after restart)
  static const String _kIsService = 'reg_isService';
  static const String _kIsIndividual = 'reg_isIndividual';

  // Selected slugs (needed for keyword suggestions)
  static const String _kShopCategorySlug = 'shopCategorySlug';
  static const String _kProductCategorySlug = 'productCategorySlug';

  // Convenience: onboarding considered "incomplete" when step-* is present.
  static bool isIncompleteOnboardingStep(String? step) {
    final s = (step ?? '').trim().toLowerCase();
    return s.startsWith('step-');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, token);
  }

  static Future<void> setRefreshToken(String businessProfileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshToken, businessProfileId);
  }

  static Future<void> setSessionToken(String sessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionToken, sessionToken);
  }

  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_role, role);
  }
  static Future<void> setOwnerPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOwnerPhone, phone);
  }

  static Future<void> setOnboardingStep(String? step) async {
    final prefs = await SharedPreferences.getInstance();
    final s = (step ?? '').trim();
    if (s.isEmpty) {
      await prefs.remove(_kOnboardingStep);
    } else {
      await prefs.setString(_kOnboardingStep, s);
    }
  }

  static Future<String?> getOnboardingStep() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kOnboardingStep);
    return (s == null || s.trim().isEmpty) ? null : s.trim();
  }

  static Future<void> setRegistrationFlags({
    required bool isService,
    required bool isIndividual,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsService, isService);
    await prefs.setBool(_kIsIndividual, isIndividual);
  }

  static Future<Map<String, bool>> getRegistrationFlags() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isService': prefs.getBool(_kIsService) ?? false,
      'isIndividual': prefs.getBool(_kIsIndividual) ?? true,
    };
  }

  static Future<bool> hasRegistrationFlags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kIsService) && prefs.containsKey(_kIsIndividual);
  }

  static Future<void> setShopCategorySlug(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final s = slug.trim();
    if (s.isEmpty) {
      await prefs.remove(_kShopCategorySlug);
    } else {
      await prefs.setString(_kShopCategorySlug, s);
    }
  }

  static Future<String?> getShopCategorySlug() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kShopCategorySlug);
    return (s == null || s.trim().isEmpty) ? null : s.trim();
  }

  static Future<void> setProductCategorySlug(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final s = slug.trim();
    if (s.isEmpty) {
      await prefs.remove(_kProductCategorySlug);
    } else {
      await prefs.setString(_kProductCategorySlug, s);
    }
  }

  static Future<String?> getProductCategorySlug() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kProductCategorySlug);
    return (s == null || s.trim().isEmpty) ? null : s.trim();
  }



  /// Read
  static Future<String?> getOwnerPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kOwnerPhone);
  }
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshToken);
  }

  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionToken);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_role);
  }

  static Future<void> clearIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_token);
    await prefs.remove(_role);
    await prefs.remove(_sessionToken);
    await prefs.remove(_refreshToken);
    await prefs.remove(_kOwnerPhone);
    await prefs.remove(_kOnboardingStep);
    // _cachedVerificationToken = null;
  }
  static Future<void> setVerificationToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPhoneVerifyToken, token);
  }

  static Future<String?> getVerificationToken() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kPhoneVerifyToken);
    return (t == null || t.isEmpty) ? null : t;
  }

  static Future<void> clearVerificationToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kPhoneVerifyToken);
  }
}


 // class AppPrefs {
 //   static const _kPhoneVerifyToken = 'primaryPhoneVerificationToken';
 //
 //   static Future<void> setVerificationToken(String token) async {
 //     final sp = await SharedPreferences.getInstance();
 //     await sp.setString(_kPhoneVerifyToken, token);
 //   }
 //
 //   static Future<String?> getVerificationToken() async {
 //     final sp = await SharedPreferences.getInstance();
 //     final t = sp.getString(_kPhoneVerifyToken);
 //     return (t == null || t.isEmpty) ? null : t;
 //   }
 //
 //   static Future<void> clearVerificationToken() async {
 //     final sp = await SharedPreferences.getInstance();
 //     await sp.remove(_kPhoneVerifyToken);
 //   }
 // }
