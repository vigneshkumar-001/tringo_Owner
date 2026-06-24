import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Core/Utility/app_prefs.dart';
import 'package:tringo_owner/Core/Session/registration_product_seivice.dart';
import 'package:tringo_owner/Core/Session/registration_session.dart';
import 'package:tringo_owner/Core/Firebase_service/device_token_sync.dart';
import 'package:tringo_owner/Api/DataSource/api_data_source.dart';
import 'package:tringo_owner/Core/Utility/onboarding_cache.dart';

import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Routes/app_go_routes.dart';
import 'Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Presentation/Login/controller/app_version_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver {
  // Use your real app version value here
  final String appVersion = '1.0.2';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // // ✅ 1) MUST request Phone/CallLog/Contacts first
      // final ok = await PermissionService.requestCorePermissionsWithDialog(
      //   context,
      // );
      // if (!ok) return;
      // // final nativeOk = await CallerIdRoleHelper.debugPhonePerm();
      // // debugPrint("✅ NATIVE READ_PHONE_STATE => $nativeOk");
      // // ✅ 2) Overlay permission (optional here)
      // final req = await CallerIdRoleHelper.requestReadPhoneState();
      // final now = await CallerIdRoleHelper.debugPhonePerm();
      // print("PHONE req=$req now=$now");
      //
      // await PermissionService.requestOverlayIfNeeded();

      // ✅ 3) Continue your flow

      await _initializeSplash();
    });
  }

  /// When user returns from Settings, re-check and mark done
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed) {
  //     _batteryFlowRunning = false;
  //     await _postSettingsRecheckAndMarkDone();
  //   }
  // }

  // Future<void> _postSettingsRecheckAndMarkDone() async {
  //   if (!Platform.isAndroid) return;
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final went = prefs.getBool(_kWentToBatterySettings) ?? false;
  //   if (!went) return;
  //
  //   await prefs.setBool(_kWentToBatterySettings, false);
  //
  //   // some devices need time before returning correct value
  //   await Future.delayed(const Duration(milliseconds: 400));
  //
  //   bool ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
  //   if (!ignoring) {
  //     await Future.delayed(const Duration(milliseconds: 400));
  //     ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
  //   }
  //
  //   AppLogger.log.i("🔋 Post-settings recheck ignoring=$ignoring");
  //
  //   if (ignoring == true) {
  //     await prefs.setBool(_kBatteryDoneKey, true);
  //     AppLogger.log.i("✅ Battery optimization marked DONE");
  //   }
  // }
  /*
  bool _tokenSent = false;
  Future<void> _sendDeviceTokenIfNeeded() async {
    if (_tokenSent) return;
    _tokenSent = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcmToken') ?? '';
      AppLogger.log.i(fcmToken);

      if (fcmToken.isEmpty) {
        AppLogger.log.w("⚠️ No fcmToken in prefs yet");
        return;
      }

      final deviceId = await DeviceIdHelper.getDeviceId();
      final platform = Platform.isAndroid ? "android" : "ios";

      await ref
          .read(appVersionNotifierProvider.notifier)
          .fcmTokenSend(
            fcmToken: fcmToken,
            platform: platform,
            deviceId: deviceId,
          );

      final st = ref.read(appVersionNotifierProvider);
      AppLogger.log.i(
        "✅ device-token api response: ${st.deviceTokenResponse?.status}",
      );
    } catch (e, st) {
      AppLogger.log.e("❌ sendDeviceToken failed: $e");
      AppLogger.log.e(st);
    }
  }
  */

  Future<void> _initializeSplash() async {
    try {
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
      // await _batteryOptimizationFlow();

      final businessFuture = ApiDataSource().getBusinessProfile();
      await Future.delayed(const Duration(seconds: 2));

      // 3) Auth policy: resume session if token exists.
      final token = (await AppPrefs.getToken())?.trim() ?? '';
      if (token.isNotEmpty) {
        unawaited(DeviceTokenSync.instance.sync(reason: 'splash', force: true));
      }

      String? goPath;
      String? goNamed;
      Object? extra;

      if (token.isEmpty) {
        goPath = AppRoutes.loginPath;
      } else {
        // Always prefer backend onboarding state to avoid wrong navigation
        // after app restart (token exists but onboarding incomplete).
        final businessResult = await businessFuture;
        final backendHandled = await businessResult.fold<Future<bool>>(
          (failure) async {
            AppLogger.log.w('Business profile fetch failed: ${failure.message}');
            return false;
          },
          (profile) async {
            final data = profile.data;
            final step = (data?.onboardingStep ?? '').trim().toLowerCase();
            final isComplete = data?.isOnboardingComplete == true;

            final bt = (data?.businessType ?? '').trim().toUpperCase();
            final ot = (data?.ownershipType ?? '').trim().toUpperCase();

            final isService = bt == 'SERVICES';
            final isIndividual = ot == 'INDIVIDUAL';

            await AppPrefs.setOnboardingStep(step.isEmpty ? null : step);
            await AppPrefs.setRegistrationFlags(
              isService: isService,
              isIndividual: isIndividual,
            );

            if (data?.ownerInfo != null) {
              await OnboardingCache.saveOwnerInfo(data!.ownerInfo!);
            }
            if (data?.shopInfo != null) {
              await OnboardingCache.saveShopInfo(data!.shopInfo!);
            }

            if (isComplete) {
              await AppPrefs.setOnboardingStep(null);
              goNamed = AppRoutes.homeScreen;
              return true;
            }

            // Restore in-memory registration singletons (needed by later screens)
            final businessType = isIndividual
                ? BusinessType.individual
                : BusinessType.company;
            RegistrationSession.instance.businessType = businessType;
            RegistrationProductSeivice.instance.businessType = businessType;
            RegistrationProductSeivice.instance.businessCategory = isService
                ? BusinessCategory.services
                : BusinessCategory.sellingProduct;

            if (step == 'step-1') {
              goNamed = AppRoutes.ownerInfo;
              extra = {'isService': isService, 'isIndividual': isIndividual};
            } else if (step == 'step-2') {
              goNamed = AppRoutes.shopCategoryInfo;
              extra = {'isService': isService, 'isIndividual': isIndividual};
            } else if (step == 'step-3') {
              goNamed = AppRoutes.shopPhotoInfo;
              extra = 'onboarding';
            } else if (step == 'step-4') {
              goNamed = AppRoutes.searchKeyword;
            } else if (step == 'step-5') {
              goNamed = AppRoutes.productCategoryScreens;
            } else {
              goNamed = AppRoutes.register;
            }

            return true;
          },
        );

        if (!backendHandled) {
          // Fallback to local onboarding state if backend call fails.
          final step =
              (await AppPrefs.getOnboardingStep())?.trim().toLowerCase();
          final needsOnboarding = AppPrefs.isIncompleteOnboardingStep(step);

          if (!needsOnboarding) {
            await AppPrefs.setOnboardingStep(null);
            await AppPrefs.clearRegistrationFlags();
            goNamed = AppRoutes.homeScreen;
          } else {
            final hasFlags = await AppPrefs.hasRegistrationFlags();
            final flags = await AppPrefs.getRegistrationFlags();
            final isService = flags['isService'] == true;
            final isIndividual = flags['isIndividual'] == true;

            if (!hasFlags) {
              await AppPrefs.setOnboardingStep(null);
              await AppPrefs.clearRegistrationFlags();
              goNamed = AppRoutes.homeScreen;
            } else {
              final bt = isIndividual
                  ? BusinessType.individual
                  : BusinessType.company;
              RegistrationSession.instance.businessType = bt;
              RegistrationProductSeivice.instance.businessType = bt;
              RegistrationProductSeivice.instance.businessCategory = isService
                  ? BusinessCategory.services
                  : BusinessCategory.sellingProduct;

              if (step == 'step-2') {
                goNamed = AppRoutes.shopCategoryInfo;
                extra = {'isService': isService, 'isIndividual': isIndividual};
              } else if (step == 'step-3') {
                goNamed = AppRoutes.shopPhotoInfo;
                extra = 'onboarding';
              } else if (step == 'step-4') {
                goNamed = AppRoutes.searchKeyword;
              } else if (step == 'step-1') {
                goNamed = AppRoutes.ownerInfo;
                extra = {'isService': isService, 'isIndividual': isIndividual};
              } else if (step == 'step-5') {
                goNamed = AppRoutes.productCategoryScreens;
              } else {
                goNamed = AppRoutes.register;
              }
            }
          }
        }
      }

      if (!mounted) return;
      if (goPath != null) {
        context.go(goPath);
      } else if (goNamed != null) {
        context.goNamed(goNamed!, extra: extra);
      } else {
        context.go(AppRoutes.loginPath);
      }
    } catch (e, st) {
      AppLogger.log.e("Splash init error: $e\n$st");
      if (!mounted) return;
      context.go(AppRoutes.loginPath);
    }
  }

  /*  Future<void> _batteryOptimizationFlow() async {
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
  }*/

  /*Future<_BatterySheetAction?> _showBatteryMandatoryBottomSheet() async {
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
  }*/

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

// enum _BatterySheetAction { openSettings }
