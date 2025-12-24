import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Routes/app_go_routes.dart';
import 'Core/Utility/app_textstyles.dart';
import 'Presentation/Home/Controller/home_notifier.dart';
import 'Presentation/Home/Controller/shopContext_provider.dart';
import 'Presentation/Login/controller/app_version_notifier.dart';
import 'Presentation/Menu/Controller/subscripe_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  String appVersion = '1.0.0';
  Future<void> _initializeSplash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // 1) Call App Version API
      await ref
          .read(appVersionNotifierProvider.notifier)
          .getAppVersion(
            appPlatForm: 'android',
            appVersion: appVersion,
            appName: 'owner',
          );

      // 2) Read version state and decide
      final versionState = ref.read(appVersionNotifierProvider);

      if (versionState.appVersionResponse?.data?.forceUpdate == true) {
        _showUpdateBottomSheet();

        return; // ⛔ stop further navigation
      }

      // 3) Continue normal flow
      await ref.read(selectedShopProvider.notifier).switchShop('');
      await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
      await ref.read(subscriptionNotifier.notifier).getCurrentPlan();

      if (!mounted) return;

      final homeState = ref.read(homeNotifierProvider);
      final bool isNewUser = homeState.shopsResponse?.data.isNewOwner ?? false;

      // 4) Navigate
      if (token != null && token.isNotEmpty) {
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
                text: Text('Update Now'),
                onTap: () {
                  openPlayStore();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void openPlayStore() async {
    final versionState = ref.read(appVersionNotifierProvider);
    final storeUrl =
        versionState.appVersionResponse?.data?.store.android.toString() ?? '';

    if (storeUrl.isEmpty) {
      print('No URL available.');
      return;
    }

    final uri = Uri.parse(storeUrl);
    print('Trying to launch: $uri');

    // Try in-app or platform default mode
    final success = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault, // or LaunchMode.inAppWebView
    );

    if (!success) {
      print('Could not open the link. Maybe no browser is installed.');
    }
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

/*
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkNavigation();
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final bool isProfileCompleted =
        prefs.getBool("isProfileCompleted") ?? false;

    final isNewOwner = prefs.getBool("isNewOwner") ?? true;

    if (!mounted) return;

    AppLogger.log.i(isNewOwner);
    if (token != null && isNewOwner == false) {
      context.go(AppRoutes.homeScreenPath);
    } else if (token != null && isNewOwner == true) {
      context.go(AppRoutes.privacyPolicyPath);
    }else{
      context.go(AppRoutes.loginPath);
    }
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
                'V 1.2',
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
*/
