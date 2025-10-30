import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/register_screen.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/shop_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Presentation/AddProduct/Screens/add_product_list.dart';
import 'Presentation/Create App Offer/Screens/create_app_offer.dart';
import 'Presentation/Home/Screens/home_screens.dart';
import 'Presentation/Shops Details/Screen/shops_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: AppColor.scaffoldColor),
        home: RegisterScreen(),
      ),
    );
  }
}
