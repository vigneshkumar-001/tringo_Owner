import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';

import 'app_textstyles.dart';

class CommonContainer {
  static topLeftArrow({required VoidCallback onTap}) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.leftArrow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Image.asset(
              height: 14,
              width: 14,
              AppImages.leftArrow,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  static Widget sellingProduct({
    required String image,
    required VoidCallback onTap,
    required String title,
    required String description,
    required bool isSelected,
    required bool isIndividual,
    bool isSellingCard = true,
    required ValueChanged<bool> onToggle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? const Border(
                  bottom: BorderSide(width: 8, color: Colors.black),
                  top: BorderSide(width: 2, color: Colors.black),
                  left: BorderSide(width: 2, color: Colors.black),
                  right: BorderSide(width: 2, color: Colors.black),
                )
              : Border.all(color: const Color(0xffD0D0D0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Icon ---
            Image.asset(image, height: 50, width: 50),
            const SizedBox(height: 14),

            // --- Title ---
            RichText(
              text: TextSpan(
                text: title.split(' ').take(2).join(' ') + ' ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: title.split(' ').skip(2).join(' '),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Description ---
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            if (isSellingCard) ...[
              const SizedBox(height: 24),

              // If a selection has been made → show full card + button
              if (isSelected) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onToggle(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: isIndividual
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isIndividual
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        offset: const Offset(0, 2),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Individual",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (isIndividual)
                                  const Text(
                                    "Selected",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onToggle(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: !isIndividual
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !isIndividual
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        offset: const Offset(0, 2),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Company",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (!isIndividual)
                                  const Text(
                                    "Selected",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // --- Save & Continue Button ---
                GestureDetector(
                  onTap: () {
                    // do save action
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Save & Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // --- Default Simple Row (when not selected) ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Individual",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "or",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        "Company",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static Widget button({
    required GestureTapCallback? onTap,
    required Widget text,
    double? size = double.infinity,
    double? imgHeight = 24,
    double? imgWeight = 24,
    double? borderRadius = 15,

    Color? buttonColor,
    Color? foreGroundColor,
    Color? borderColor,
    Color? textColor = Colors.white,
    bool? isLoading,
    bool hasBorder = false,
    String? imagePath,
  }) {
    return SizedBox(
      width: size,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: foreGroundColor,

          shape: hasBorder
              ? RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xff3F5FF2)),
                  borderRadius: BorderRadius.circular(borderRadius!),
                )
              : RoundedRectangleBorder(
                  side: BorderSide(color: borderColor ?? Colors.transparent),

                  borderRadius: BorderRadius.circular(borderRadius!),
                ),
          elevation: 0,
          fixedSize: Size(150.w, 45.h),
          backgroundColor: buttonColor,
        ),
        child: isLoading == true
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imagePath != null) ...[
                    Image.asset(
                      imagePath,
                      height: imgHeight!.sp,
                      width: imgWeight!.sp,
                    ),
                    SizedBox(width: 10.w),
                  ],
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: "Roboto-normal",
                      fontSize: 16.sp,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    child: text,
                  ),
                ],
              ),
      ),
    );
  }
}

// Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// const Text(
// "Individual",
// style: TextStyle(
// fontSize: 16,
// fontWeight: FontWeight.w500,
// ),
// ),
// Container(
// padding: const EdgeInsets.symmetric(
// horizontal: 14,
// vertical: 8,
// ),
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(12),
// boxShadow: [
// BoxShadow(
// color: Colors.black.withOpacity(0.1),
// blurRadius: 5,
// offset: const Offset(0, 2),
// ),
// ],
// ),
// child: const Text(
// "or",
// style: TextStyle(
// fontSize: 16,
// fontWeight: FontWeight.bold,
// ),
// ),
// ),
// const Text(
// "Company",
// style: TextStyle(
// fontSize: 16,
// fontWeight: FontWeight.w500,
// ),
// ),
// ],
// ),
