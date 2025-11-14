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

class AppRoutes {
  static const String login = 'login';
  static const String otp = 'otp';
  static const String register = 'register';
  static const String ownerInfo = 'ownerInfo';
  static const String shopCategoryInfo = 'ShopCategoryInfo';
  static const String shopPhotoInfo = 'ShopPhotoInfo';
  static const String searchKeyword = 'SearchKeyword';
  static const String productCategoryScreens = 'ProductCategoryScreens';
  static const String addProductList = 'AddProductList';

  static const String loginPath = '/login';
  static const String otpPath = '/otp';
  static const String registerPath = '/register';
  static const String ownerInfoPath = '/owner-info';
  static const String shopCategoryInfoPath = '/ShopCategoryInfo';
  static const String shopPhotoInfoPath = '/ShopPhotoInfo';
  static const String searchKeywordPath = '/SearchKeyword';
  static const String productCategoryScreensPath = '/ProductCategoryScreens';
  static const String addProductListPath = '/AddProductList';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.loginPath,
  routes: [
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.login,
      builder: (context, state) => const LoginMobileNumber(),
    ),
    GoRoute(
      path: AppRoutes.otpPath,
      name: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String?;
        return OtpScreens(phoneNumber: phone ?? '');
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
        final isCompany = state.extra as bool?;
        return OwnerInfoScreens(isCompany: isCompany ?? false);
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
      builder: (context, state) => const AddProductList(),
    ),
  ],
);
