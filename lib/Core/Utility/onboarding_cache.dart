import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCache {
  OnboardingCache._();

  static const String _kOwnerInfo = 'onboarding_ownerInfo_json';
  static const String _kShopInfo = 'onboarding_shopInfo_json';

  static Future<void> saveOwnerInfo(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOwnerInfo, jsonEncode(json));
  }

  static Future<void> saveShopInfo(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kShopInfo, jsonEncode(json));
  }

  static Future<Map<String, dynamic>?> getOwnerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOwnerInfo);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getShopInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kShopInfo);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return null;
  }
}

