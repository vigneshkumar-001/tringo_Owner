import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';

import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Routes/app_go_routes.dart';
import 'Core/Utility/app_textstyles.dart';
import 'Core/Widgets/caller_id_role_helper.dart';
import 'Core/permissions/permission_service.dart';

import 'Presentation/Home/Controller/home_notifier.dart';
import 'Presentation/Home/Controller/shopContext_provider.dart';
import 'Presentation/Login/controller/app_version_notifier.dart';
import 'Presentation/Menu/Controller/subscripe_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver {
  // Use your real app version value here
  final String appVersion = '1.0.0';

  bool _batteryFlowRunning = false;
  bool _batterySheetOpen = false;

  // persist keys
  static const _kBatteryDoneKey = "battery_opt_done";
  static const _kBatteryLastShownAt = "battery_opt_last_shown_at";
  static const _kWentToBatterySettings = "went_to_battery_settings";

  // cooldown (avoid annoying user)
  static const int _cooldownSeconds = 60 * 60 * 12; // 12 hours

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ 1) MUST request Phone/CallLog/Contacts first
      final ok = await PermissionService.requestCorePermissionsWithDialog(
        context,
      );
      if (!ok) return;
      // final nativeOk = await CallerIdRoleHelper.debugPhonePerm();
      // debugPrint("✅ NATIVE READ_PHONE_STATE => $nativeOk");
      // ✅ 2) Overlay permission (optional here)
      final req = await CallerIdRoleHelper.requestReadPhoneState();
      final now = await CallerIdRoleHelper.debugPhonePerm();
      print("PHONE req=$req now=$now");

      await PermissionService.requestOverlayIfNeeded();

      // ✅ 3) Continue your flow

      await _initializeSplash();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When user returns from Settings, re-check and mark done
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _batteryFlowRunning = false;
      await _postSettingsRecheckAndMarkDone();
    }
  }

  Future<void> _postSettingsRecheckAndMarkDone() async {
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();
    final went = prefs.getBool(_kWentToBatterySettings) ?? false;
    if (!went) return;

    await prefs.setBool(_kWentToBatterySettings, false);

    // some devices need time before returning correct value
    await Future.delayed(const Duration(milliseconds: 400));

    bool ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
    if (!ignoring) {
      await Future.delayed(const Duration(milliseconds: 400));
      ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
    }

    AppLogger.log.i("🔋 Post-settings recheck ignoring=$ignoring");

    if (ignoring == true) {
      await prefs.setBool(_kBatteryDoneKey, true);
      AppLogger.log.i("✅ Battery optimization marked DONE");
    }
  }

  Future<void> _initializeSplash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // 1) App version check
      await ref
          .read(appVersionNotifierProvider.notifier)
          .getAppVersion(
            appPlatForm: 'android',
            appVersion: appVersion,
            appName: 'owner',
          );

      final versionState = ref.read(appVersionNotifierProvider);
      if (versionState.appVersionResponse?.data?.forceUpdate == true) {
        _showUpdateBottomSheet();
        return;
      }

      // 2) Battery flow (before navigation)
      await _batteryOptimizationFlow();

      // 3) Continue normal flow
      await ref.read(selectedShopProvider.notifier).switchShop('');
      await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
      await ref.read(subscriptionNotifier.notifier).getCurrentPlan();

      if (!mounted) return;

      final homeState = ref.read(homeNotifierProvider);
      final bool isNewUser = homeState.shopsResponse?.data.isNewOwner ?? false;

      // Optional: hold splash a bit
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      if (token.isNotEmpty) {
        context.go(
          isNewUser ? AppRoutes.privacyPolicyPath : AppRoutes.homeScreenPath,
        );
      } else {
        context.go(AppRoutes.loginPath);
      }
    } catch (e, st) {
      AppLogger.log.e("Splash init error: $e\n$st");
      if (!mounted) return;
      context.go(AppRoutes.loginPath);
    }
  }

  Future<void> _batteryOptimizationFlow() async {
    if (!Platform.isAndroid) return;
    if (_batteryFlowRunning) return;
    _batteryFlowRunning = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1) If already completed once, don't show again
      final done = prefs.getBool(_kBatteryDoneKey) ?? false;
      if (done) {
        _batteryFlowRunning = false;
        return;
      }

      // 2) cooldown
      final lastShownAt = prefs.getInt(_kBatteryLastShownAt) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final secondsFromLast = (now - lastShownAt) ~/ 1000;
      if (secondsFromLast < _cooldownSeconds) {
        _batteryFlowRunning = false;
        return;
      }

      // 3) check twice (OEM bug sometimes)
      bool isIgnoring =
          await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
      if (!isIgnoring) {
        await Future.delayed(const Duration(milliseconds: 450));
        isIgnoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
      }

      AppLogger.log.i("🔋 isIgnoringBatteryOptimizations=$isIgnoring");

      // if already enabled, mark done
      if (isIgnoring == true) {
        await prefs.setBool(_kBatteryDoneKey, true);
        _batteryFlowRunning = false;
        return;
      }

      if (!mounted) {
        _batteryFlowRunning = false;
        return;
      }

      // remember shown time
      await prefs.setInt(_kBatteryLastShownAt, now);

      if (_batterySheetOpen) {
        _batteryFlowRunning = false;
        return;
      }

      _batterySheetOpen = true;
      final action = await _showBatteryMandatoryBottomSheet();
      _batterySheetOpen = false;

      if (!mounted) {
        _batteryFlowRunning = false;
        return;
      }

      if (action == _BatterySheetAction.openSettings) {
        // mark flag so resume can recheck and save done
        await prefs.setBool(_kWentToBatterySettings, true);
        await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
      }

      _batteryFlowRunning = false;
    } catch (_) {
      _batteryFlowRunning = false;
    }
  }

  Future<_BatterySheetAction?> _showBatteryMandatoryBottomSheet() async {
    return showModalBottomSheet<_BatterySheetAction>(
      context: context,
      backgroundColor: AppColor.white,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Battery Optimization Required",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To show Caller ID popup reliably on Android 12–15, set Tringo battery usage to "
                "\"Unrestricted\".\n\n"
                "Settings → Apps → Tringo → Battery → Unrestricted",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, _BatterySheetAction.openSettings),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColor.blueGradient1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Open Settings",
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Available",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "A new version of the app is available. Please update to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 24),
              CommonContainer.button(
                text: const Text('Update Now'),
                onTap: () => openPlayStore(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openPlayStore() async {
    final versionState = ref.read(appVersionNotifierProvider);
    final storeUrl =
        versionState.appVersionResponse?.data?.store.android.toString() ?? '';
    if (storeUrl.isEmpty) return;

    final uri = Uri.parse(storeUrl);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.splashScreen,
              width: w,
              height: h,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: h * 0.53,
              left: w * 0.43,
              child: Text(
                'V $appVersion',
                style: AppTextStyles.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColor.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BatterySheetAction { openSettings }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_owner/Core/Const/app_logger.dart';
// import 'package:tringo_owner/Core/Utility/common_Container.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'Core/Const/app_color.dart';
// import 'Core/Const/app_images.dart';
// import 'Core/Routes/app_go_routes.dart';
// import 'Core/Utility/app_textstyles.dart';
// import 'Core/permissions/permission_service.dart';
// import 'Presentation/Home/Controller/home_notifier.dart';
// import 'Presentation/Home/Controller/shopContext_provider.dart';
// import 'Presentation/Login/controller/app_version_notifier.dart';
// import 'Presentation/Menu/Controller/subscripe_notifier.dart';
//
// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeSplash();
//     checkNavigation();
//     PermissionService.requestOverlayAndContacts();
//   }
//
//   Future<void> checkNavigation() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final token = prefs.getString('token');
//     final bool isProfileCompleted =
//         prefs.getBool("isProfileCompleted") ?? false;
//
//     // 1) Check app version
//     await ref
//         .read(appVersionNotifierProvider.notifier)
//         .getAppVersion(
//           appPlatForm: 'android',
//           appVersion: appVersion,
//           appName: 'customer',
//         );
//
//     final versionState = ref.read(appVersionNotifierProvider);
//
//     if (versionState.appVersionResponse?.data?.forceUpdate == true) {
//       _showUpdateBottomSheet();
//       return;
//     }
//
//     // 3) Hold splash for 3 seconds
//     await Future.delayed(const Duration(seconds: 3));
//     if (!mounted) return;
//
//     // // 4) Navigate
//     // if (token == null) {
//     //   context.go(AppRoutes.loginPath);
//     // } else if (!isProfileCompleted) {
//     //   context.go(AppRoutes.fillProfilePath);
//     // } else {
//     //   context.go(AppRoutes.homePath);
//     // }
//   }
//
//   String appVersion = '1.0.0';
//   Future<void> _initializeSplash() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       // 1) Call App Version API
//       await ref
//           .read(appVersionNotifierProvider.notifier)
//           .getAppVersion(
//             appPlatForm: 'android',
//             appVersion: appVersion,
//             appName: 'owner',
//           );
//
//       // 2) Read version state and decide
//       final versionState = ref.read(appVersionNotifierProvider);
//
//       if (versionState.appVersionResponse?.data?.forceUpdate == true) {
//         _showUpdateBottomSheet();
//
//         return; // ⛔ stop further navigation
//       }
//
//       // 3) Continue normal flow
//       await ref.read(selectedShopProvider.notifier).switchShop('');
//       await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
//       await ref.read(subscriptionNotifier.notifier).getCurrentPlan();
//
//       if (!mounted) return;
//
//       final homeState = ref.read(homeNotifierProvider);
//       final bool isNewUser = homeState.shopsResponse?.data.isNewOwner ?? false;
//
//       // 4) Navigate
//       if (token != null && token.isNotEmpty) {
//         context.go(
//           isNewUser ? AppRoutes.privacyPolicyPath : AppRoutes.homeScreenPath,
//         );
//       } else {
//         context.go(AppRoutes.loginPath);
//       }
//     } catch (e, st) {
//       AppLogger.log.e("Splash init error: $e\n$st");
//       if (!mounted) return;
//       context.go(AppRoutes.loginPath);
//     }
//   }
//
//   void _showUpdateBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Update Available",
//                 style: GoogleFonts.ibmPlexSans(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               Text(
//                 "A new version of the app is available. Please update to continue.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.ibmPlexSans(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//               CommonContainer.button(
//                 text: Text('Update Now'),
//                 onTap: () {
//                   openPlayStore();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void openPlayStore() async {
//     final versionState = ref.read(appVersionNotifierProvider);
//     final storeUrl =
//         versionState.appVersionResponse?.data?.store.android.toString() ?? '';
//
//     if (storeUrl.isEmpty) {
//       print('No URL available.');
//       return;
//     }
//
//     final uri = Uri.parse(storeUrl);
//     print('Trying to launch: $uri');
//
//     // Try in-app or platform default mode
//     final success = await launchUrl(
//       uri,
//       mode: LaunchMode.platformDefault, // or LaunchMode.inAppWebView
//     );
//
//     if (!success) {
//       print('Could not open the link. Maybe no browser is installed.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.splashScreen,
//               width: w,
//               height: h,
//               fit: BoxFit.cover,
//             ),
//             Positioned(
//               top: h * 0.53,
//               left: w * 0.43,
//               child: Text(
//                 'V $appVersion',
//                 style: AppTextStyles.mulish(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w900,
//                   color: AppColor.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
