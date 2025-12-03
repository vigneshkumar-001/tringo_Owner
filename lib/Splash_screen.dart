import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Routes/app_go_routes.dart';
import 'Core/Utility/app_textstyles.dart';
import 'Presentation/Home/Controller/home_notifier.dart';

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

  Future<void> _initializeSplash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Get notifier
      final homeNotifier = ref.read(homeNotifierProvider.notifier);

      // Fetch data from APIs
      await homeNotifier.fetchShops();
      await homeNotifier.fetchAllEnquiry();

      if (!mounted) return;

      // Read latest state AFTER both API calls
      final homeState = ref.read(homeNotifierProvider);

      // From your model: ShopsResponse -> ShopsData -> isNewOwner
      final bool isNewUser =
          homeState.shopsResponse?.data.isNewOwner ?? true;

      AppLogger.log.i('isNewUser: $isNewUser');

      if (token != null && token.isNotEmpty) {
        if (!isNewUser) {
          context.go(AppRoutes.homeScreenPath);
        } else {
          context.go(AppRoutes.privacyPolicyPath);
        }
      } else {
        context.go(AppRoutes.loginPath);
      }
    } catch (e, st) {
      AppLogger.log.e("Splash init error: $e\n$st");
      if (!mounted) return;
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
