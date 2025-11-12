import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';

class AppLoader {
  static Widget circularLoader({Color color = AppColor.white}) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 1.8,
        color: AppColor.white,
      ),
    );
  }
}
