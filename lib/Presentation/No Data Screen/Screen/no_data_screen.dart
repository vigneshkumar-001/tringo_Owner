import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/common_Container.dart';

class NoDataScreen extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onBackTap;
  final VoidCallback? onTopBackTap;
  final String? imagePath;
  final bool showTopBackArrow;
  final bool showBottomButton;
  final EdgeInsetsGeometry padding;
  final double ?fontSize;

  /// ✅ NEW: if provided, pull-to-refresh will work
  final Future<void> Function()? onRefresh;

  const NoDataScreen({
    super.key,
    this.title = 'No Data Found',
    this.message =
        'No matching records were detected. Kindly adjust your inputs and try again.',
    this.buttonText = 'Back',
    this.onBackTap,
    this.onTopBackTap,
    this.imagePath,
    this.showTopBackArrow = true,
    this.showBottomButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    this.onRefresh, // ✅ NEW
    this.fontSize= 24,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopBackArrow)
            CommonContainer.topLeftArrow(
              onTap: onTopBackTap ?? () => Navigator.of(context).maybePop(),
            ),
          const SizedBox(height: 160),

          Image.asset(imagePath ?? AppImages.noDataGif),

          const SizedBox(height: 30),

          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.mulish(
                fontSize: fontSize!,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
          ),

          const SizedBox(height: 11),

          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.mulish(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.darkGrey,
            ),
          ),

          const SizedBox(height: 26),

          if (showBottomButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.resendOtp,
                  foregroundColor: AppColor.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.leftStickArrow,
                      height: 19,
                      color: AppColor.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    // ✅ If onRefresh is null, show normal UI
    if (onRefresh == null) {
      return SafeArea(child: content);
    }

    // ✅ If onRefresh is provided, enable pull-to-refresh
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh!,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
//
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Utility/common_Container.dart';
//
// class NoDataScreen extends StatelessWidget {
//   final String title;
//   final String message;
//   final String buttonText;
//   final VoidCallback? onBackTap;
//   final VoidCallback? onTopBackTap;
//   final String? imagePath;
//   final bool showTopBackArrow;
//   final bool showBottomButton;
//   final double ?fontSize;
//   final EdgeInsetsGeometry padding;
//   final Future<void> Function()? onRefresh;
//
//   const NoDataScreen({
//     super.key,
//     this.title = 'No Data Found',
//     this.message =
//         'No matching records were detected. Kindly adjust your inputs and try again.',
//     this.buttonText = 'Back',
//     this.onBackTap,
//     this.onTopBackTap,
//     this.imagePath,
//     this.fontSize= 24,
//     this.showTopBackArrow = true,
//     this.showBottomButton = true,
//     this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//     this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SafeArea(
//         child: Padding(
//           padding: padding,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (showTopBackArrow)
//                 CommonContainer.topLeftArrow(
//                   onTap: onTopBackTap ?? () => Navigator.of(context).maybePop(),
//                 ),
//               SizedBox(height: 160),
//
//               Image.asset(imagePath ?? AppImages.noDataGif),
//
//               SizedBox(height: 30),
//
//               Center(
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.mulish(
//                     fontSize: fontSize!,
//                     fontWeight: FontWeight.bold,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 11),
//
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: AppTextStyles.mulish(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: AppColor.darkGrey,
//                 ),
//               ),
//
//               SizedBox(height: 26),
//
//               if (showBottomButton)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 120),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.skyBlue,
//                       foregroundColor: AppColor.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         // side: BorderSide(color: AppColor.blue, width: 2),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     onPressed:
//                         onBackTap ?? () => Navigator.of(context).maybePop(),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           AppImages.leftStickArrow,
//                           height: 19,
//                           color: AppColor.white,
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           buttonText,
//                           style: AppTextStyles.mulish(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 16,
//                             color: AppColor.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
