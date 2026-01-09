import 'dart:io';
import 'package:flutter/services.dart';

class CallerIdRoleHelper {
  static const MethodChannel _native = MethodChannel('tringo/system');

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openBatteryUnrestrictedSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('openBatteryUnrestrictedSettings');
    } catch (_) {}
  }

  static Future<void> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestIgnoreBatteryOptimization');
    } catch (_) {}
  }

  static Future<bool> isOverlayGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isOverlayGranted');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }
}
