import 'package:flutter/material.dart';

import '../Core/Const/app_color.dart';
import '../Core/Const/app_images.dart';
import '../Core/Utility/app_textstyles.dart';

class UnderProcessing extends StatelessWidget {
  const UnderProcessing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // CommonContainer.leftSideArrow(onTap: () {}),
            Image.asset(AppImages.noDataGif),
            SizedBox(height: 50),
            Center(
              child: Text(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                'This feature is currently under development',
                style: AppTextStyles.mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColor.darkBlue,
                ),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.skyBlue,
                  foregroundColor: AppColor.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    // side: BorderSide(color: AppColor.blue, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.leftStickArrow,
                      height: 19,
                      color: AppColor.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Back',
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
      ),
    );
  }
}
