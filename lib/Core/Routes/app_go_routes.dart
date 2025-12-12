import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Presentation/Login/Screens/login_screens.dart';
import 'package:tringo_vendor/Presentation/Login/Screens/otp_screens.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/register_screen.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/owner_info_screens.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/search_keyword.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/shop_category_info.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/shop_photo_info.dart';

import '../../Presentation/AddProduct/Screens/add_product_list.dart';
import '../../Presentation/AddProduct/Screens/product_category_screens.dart';
import '../../Presentation/Create App Offer/Screens/offer_products.dart';
import '../../Presentation/Home/Screens/home_screens.dart';
import '../../Presentation/Menu/Screens/subscription_screen.dart';
import '../../Presentation/Mobile Nomber Verify/mobile_number_verify.dart';
import '../../Presentation/Privacy Policy/privacy_policy.dart';
import '../../Presentation/Shops Details/Screen/shops_details.dart';
import '../../Splash_screen.dart';
import '../Session/registration_product_seivice.dart';
import '../Widgets/bottom_navigation_bar.dart';

class AppRoutes {
  static const String splashScreen = 'splashScreen';
  static const String login = 'login';
  static const String otp = 'otp';
  static const String register = 'register';
  static const String ownerInfo = 'ownerInfo';
  static const String shopCategoryInfo = 'ShopCategoryInfo';
  static const String shopPhotoInfo = 'ShopPhotoInfo';
  static const String searchKeyword = 'SearchKeyword';
  static const String productCategoryScreens = 'ProductCategoryScreens';
  static const String addProductList = 'AddProductList';
  static const String shopsDetails = 'ShopsDetails';
  static const String homeScreen = 'HomeScreens';
  static const String subscriptionScreen = 'SubscriptionScreen';
  static const String mobileNumberVerify = 'MobileNumberVerify';
  static const String privacyPolicy = 'privacyPolicy';
  static const String aboutMeScreens = 'AboutMeScreens';
  static const String offerProducts = 'OfferProducts';

  static const String splashScreenPath = '/splashScreen';
  static const String loginPath = '/login';
  static const String otpPath = '/otp';
  static const String registerPath = '/register';
  static const String ownerInfoPath = '/owner-info';
  static const String shopCategoryInfoPath = '/ShopCategoryInfo';
  static const String shopPhotoInfoPath = '/ShopPhotoInfo';
  static const String searchKeywordPath = '/SearchKeyword';
  static const String productCategoryScreensPath = '/ProductCategoryScreens';
  static const String addProductListPath = '/AddProductList';
  static const String shopsDetailsPath = '/ShopsDetails';
  static const String homeScreenPath = '/HomeScreens';
  static const String subscriptionScreenPath = '/SubscriptionScreen';
  static const String mobileNumberVerifyPath = '/MobileNumberVerify';
  static const String privacyPolicyPath = '/privacyPolicy';
  static const String aboutMeScreensPath = '/AboutMeScreens';
  static const String offerProductsPath = '/OfferProducts';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.splashScreenPath,

  redirect: (context, state) {
    final location = state.matchedLocation;

    // If navigating to ShopsDetails after pressing SKIP → never redirect
    if (location == AppRoutes.shopsDetailsPath) {
      final extra = state.extra;

      if (extra is Map<String, dynamic>) {
        if (extra['fromSubscriptionSkip'] == true) {
          //  Came from SubscriptionScreen skip → allow ShopsDetails
          return null;
        }
      }
    }

    // No other forced redirects for now
    return null;
  },

  routes: [
    GoRoute(
      path: AppRoutes.splashScreenPath,
      name: AppRoutes.splashScreen,
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.login,
      builder: (context, state) => LoginMobileNumber(),
    ),
    GoRoute(
      path: AppRoutes.otpPath,
      name: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String?;
        return OtpScreen(phoneNumber: phone ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.registerPath,
      name: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.ownerInfoPath,
      name: AppRoutes.ownerInfo,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final isService = (extra?['isService'] as bool?) ?? false;
        final isIndividual = (extra?['isIndividual'] as bool?) ?? true;

        return OwnerInfoScreens(
          isService: isService,
          isIndividual: isIndividual,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.shopCategoryInfoPath,
      name: AppRoutes.shopCategoryInfo,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final isService = args['isService'] as bool? ?? false;
        final isIndividual = args['isIndividual'] as bool? ?? true;

        return ShopCategoryInfo(
          isService: isService,
          isIndividual: isIndividual,
          initialShopNameEnglish: args['initialShopNameEnglish'] as String?,
          initialShopNameTamil: args['initialShopNameTamil'] as String?,
          pages: args['pages'] as String?,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.shopPhotoInfoPath,
      name: AppRoutes.shopPhotoInfo,
      builder: (context, state) {
        final pageName = state.extra as String? ?? '';
        return ShopPhotoInfo(pages: pageName);
      },
    ),

    GoRoute(
      path: AppRoutes.searchKeywordPath,
      name: AppRoutes.searchKeyword,
      builder: (context, state) => const SearchKeyword(),
    ),
    GoRoute(
      path: AppRoutes.productCategoryScreensPath,
      name: AppRoutes.productCategoryScreens,
      builder: (context, state) => const ProductCategoryScreens(),
    ),
    GoRoute(
      path: AppRoutes.addProductListPath,
      name: AppRoutes.addProductList,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return AddProductList(
          isService: extra?['isService'] ?? false,

        );
      },
    ),
    GoRoute(
      path: AppRoutes.shopsDetailsPath,
      name: AppRoutes.shopsDetails,
      builder: (context, state) {
        final extra = state.extra;

        bool backDisabled = false;
        bool fromSubscription = false;
        String? shopId;

        if (extra is Map<String, dynamic>) {
          backDisabled = extra['backDisabled'] as bool? ?? false;
          fromSubscription = extra['fromSubscriptionSkip'] as bool? ?? false;
          shopId = extra['shopId'] as String?;
        } else if (extra is bool) {
          fromSubscription = extra;
        }

        return ShopsDetails(
          backDisabled: backDisabled,
          fromSubscriptionSkip: fromSubscription,
          shopId: shopId,
        );
      },
    ),

    // GoRoute(
    //   path: AppRoutes.shopsDetailsPath,
    //   name: AppRoutes.shopsDetails,
    //   builder: (context, state) => const ShopsDetails(backDisabled: true),
    // ),
    GoRoute(
      path: AppRoutes.homeScreenPath,
      name: AppRoutes.homeScreen,
      builder: (context, state) {
        final initialIndex =
            state.extra as int? ?? 0; // default to 0 if not provided
        return CommonBottomNavigation(initialIndex: initialIndex);
      },
    ),

    // GoRoute(
    //   path: AppRoutes.homeScreenPath,
    //   name: AppRoutes.homeScreen,
    //   builder: (context, state) => CommonBottomNavigation(initialIndex: 0),
    // ),
    GoRoute(
      path: AppRoutes.subscriptionScreenPath,
      name: AppRoutes.subscriptionScreen,
      builder: (context, state) {
        final extra = state.extra;

        bool showSkip = false;
        if (extra is bool) {
          showSkip = extra;
        } else if (extra is Map<String, dynamic>) {
          showSkip = extra['showSkip'] as bool? ?? false;
        }

        return SubscriptionScreen(showSkip: showSkip);
      },
    ),
    GoRoute(
      path: AppRoutes.mobileNumberVerifyPath,
      name: AppRoutes.mobileNumberVerify,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final phone = args['phone'] as String? ?? '';
        final simToken = args['simToken'] as String? ?? '';

        return MobileNumberVerify(
          loginNumber: phone,
          simToken: simToken, // pass it to the screen
        );
      },
    ),

    GoRoute(
      path: AppRoutes.privacyPolicyPath,
      name: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicy(),
    ),
    GoRoute(
      path: AppRoutes.aboutMeScreensPath,
      name: AppRoutes.aboutMeScreens,
      builder: (context, state) {
        final initialIndex =
            state.extra as int? ?? 0; // default to 0 if not provided
        return CommonBottomNavigation(initialIndex: initialIndex);
      },
    ),

    GoRoute(
      path: AppRoutes.offerProductsPath,
      name: AppRoutes.offerProducts,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return OfferProducts(
          isService: extra?['isService'] ?? false,

        );
      },
    ),
  ],
);
