import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    VoidCallback? buttonTap,
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
                style: AppTextStyles.mulish(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: title.split(' ').skip(2).join(' '),
                    style: AppTextStyles.mulish(
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
                                Text(
                                  "Individual",
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (isIndividual)
                                  Text(
                                    "Selected",
                                    style: AppTextStyles.mulish(
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
                                Text(
                                  "Company",
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (!isIndividual)
                                  Text(
                                    "Selected",
                                    style: AppTextStyles.mulish(
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
                SizedBox(height: 20),
                // --- Save & Continue Button ---
                GestureDetector(
                  onTap: buttonTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Save & Continue",
                      style: AppTextStyles.mulish(
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
                      Text(
                        "Individual",
                        style: AppTextStyles.mulish(
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
                        child: Text(
                          "or",
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "Company",
                        style: AppTextStyles.mulish(
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

    Color buttonColor = AppColor.black,
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
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: "Roboto-normal",
                      fontSize: 16.sp,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    child: text,
                  ),
                  if (imagePath != null) ...[
                    SizedBox(width: 10.w),
                    Image.asset(
                      imagePath,
                      height: imgHeight!.sp,
                      width: imgWeight!.sp,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  static Widget fillingContainer({
    String? text,
    double? textSize = 14,
    Color? textColor = AppColor.mediumGray,
    FontWeight? textFontWeight,
    Key? fieldKey,
    TextEditingController? controller,
    String? imagePath,
    bool verticalDivider = true,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onDetailsTap,
    double imageHight = 30,
    double imageWidth = 11,
    int? maxLine,
    int flex = 4,
    bool isTamil = false,
    bool isAadhaar = false,
    bool isDOB = false,
    bool isMobile = false,
    bool isPincode = false,
    bool readOnly = false,
    bool isDropdown = false,
    List<String>? dropdownItems,
    BuildContext? context,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
    Color borderColor = AppColor.red,
    Color? imageColor,
    VoidCallback? onFieldTap,
  }) {
    return FormField<String>(
      validator: validator,
      key: fieldKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        // -------------------- DOB Picker --------------------
        Future<void> _handleDobTap() async {
          if (!isDOB || context == null) return;

          final DateTime startDate = DateTime(2021, 6, 1);
          final DateTime endDate = DateTime(2022, 5, 31);
          final DateTime initialDate = DateTime(2021, 6, 2);

          final pickedDate = await showDatePicker(
            context: context!,
            initialDate: initialDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2025),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: AppColor.scaffoldColor,
                  colorScheme: ColorScheme.light(
                    primary: AppColor.lightSkyBlue,
                    onPrimary: Colors.white,
                    onSurface: AppColor.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.lightSkyBlue,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            if (pickedDate.isBefore(startDate) || pickedDate.isAfter(endDate)) {
              ScaffoldMessenger.of(context!).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Invalid Date of Birth!\nPlease select a date between 01-06-2021 and 31-05-2022.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              controller?.text =
                  "${pickedDate.day.toString().padLeft(2, '0')}-"
                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                  "${pickedDate.year}";
              state.didChange(controller?.text ?? '');
            }
          }
        }

        // -------------------- Tap Handling --------------------
        void _handleTap() {
          if (isDOB) {
            _handleDobTap();
          } else if (isDropdown &&
              dropdownItems != null &&
              dropdownItems!.isNotEmpty) {
            _showDropdownBottomSheet(
              context!,
              dropdownItems!,
              controller,
              state,
            );
          } else {
            onFieldTap?.call();
          }
        }

        // -------------------- Input Formatter Handling --------------------
        final effectiveInputFormatters = isMobile || isAadhaar || isPincode
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  isMobile ? 10 : (isAadhaar ? 12 : 6),
                ),
              ]
            : (inputFormatters ?? const []);

        // -------------------- UI --------------------
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColor.lightGray,
                  border: Border.all(
                    color: hasError ? AppColor.red : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: flex,
                        child: AbsorbPointer(
                          absorbing: isDOB || readOnly || isDropdown,
                          child: TextFormField(
                            focusNode: focusNode,
                            readOnly: readOnly || isDropdown,
                            controller: controller,
                            maxLines: maxLine,
                            maxLength: isMobile
                                ? 10
                                : (isAadhaar ? 12 : (isPincode ? 6 : null)),
                            keyboardType: keyboardType,
                            inputFormatters: effectiveInputFormatters,
                            style: AppTextStyles.textWith700(fontSize: 18),
                            decoration: const InputDecoration(
                              hintText: '',
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              errorText: null,
                            ),
                            showCursor: !(isDOB || readOnly || isDropdown),
                            enableInteractiveSelection:
                                !(isDOB || readOnly || isDropdown),
                            onChanged: (v) {
                              state.didChange(v);
                              onChanged?.call(v);
                            },
                          ),
                        ),
                      ),
                      if (verticalDivider)
                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      if (text != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style: AppTextStyles.mulish(
                            fontWeight: textFontWeight,
                            fontSize: textSize!,
                            color: textColor,
                          ),
                        ),
                      ],

                      const SizedBox(width: 20),
                      if (imagePath != null)
                        InkWell(
                          onTap: () {
                            controller?.clear();
                            state.didChange('');
                            onDetailsTap?.call();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Image.asset(
                              imagePath,
                              height: imageHight,
                              width: imageWidth,
                              color: imageColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  // -------------------- Common Dropdown Bottom Sheet --------------------
  static void _showDropdownBottomSheet(
    BuildContext context,
    List<String> items,
    TextEditingController? controller,
    FormFieldState<String> state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final value = items[index];
            final isSelected = controller?.text == value;
            return ListTile(
              title: Text(
                value,
                style: AppTextStyles.mulish(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColor.lightSkyBlue : Colors.black,
                ),
              ),
              onTap: () {
                controller?.text = value;
                state.didChange(value);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  static registerTopContainer({
    Color? gradientColor,
    required String image,
    required String text,
    double? imageHeight,
    double? imageWidth,
    double? value,
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.registerBCImage),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          colors: [AppColor.scaffoldColor, gradientColor!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset(image, height: imageHeight, width: imageWidth),
            SizedBox(height: 15),
            Text(
              text,
              style: AppTextStyles.mulish(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.mildBlack,
              ),
            ),
            SizedBox(height: 30),
            LinearProgressIndicator(
              minHeight: 12,
              value: value,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.mediumGreen),
              backgroundColor: AppColor.scaffoldColor,
              borderRadius: BorderRadius.circular(16),
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  static Widget mobileNumberField({
    Key? fieldKey,
    TextEditingController? controller,
    Function(String)? onChanged,
    VoidCallback? onVerifyTap,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    FormFieldValidator<String>? validator,
    bool readOnly = false,
    Color borderColor = Colors.red,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return FormField<String>(
          key: fieldKey,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (state) {
            final hasError = state.hasError;
            final textValue = controller?.text ?? '';
            final isTenDigits = textValue.length == 10;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mobile Number',
                  style: AppTextStyles.mulish(color: AppColor.mildBlack),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFF5F5F5),
                    border: Border.all(
                      color: hasError ? Colors.red : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            readOnly: readOnly,
                            maxLength: 10,
                            keyboardType: keyboardType ?? TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: ' ',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                            onChanged: (v) {
                              setState(() {});
                              state.didChange(v);
                              onChanged?.call(v);
                            },
                          ),
                        ),

                        textValue.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller?.clear();
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 22,
                                ),
                              )
                            : SizedBox.shrink(),
                        Container(
                          width: 1.2,
                          height: 30,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),

                        textValue.isEmpty
                            ? Text(
                                'Mobile No',
                                style: AppTextStyles.mulish(
                                  color: AppColor.mediumGray,
                                ),
                              )
                            : SizedBox.shrink(),
                        if (textValue.isNotEmpty)
                          GestureDetector(
                            onTap: onVerifyTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Verify",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget otpVerificationCard({
    required BuildContext context,
    required List<TextEditingController> controllers,
    required VoidCallback onSubmit,
    required VoidCallback onBack,
    required int resendSeconds,
    required String last4Digits,
    bool showError = false,
  }) {
    return Container(
      key: const ValueKey('otpCard'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF5F5F5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row with back + title
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: AppColor.mediumGray,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "OTP Sent to your xxx$last4Digits",
                style: AppTextStyles.mulish(
                  color: AppColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "If you didn’t get OTP by SMS, resend OTP using the button",
            style: AppTextStyles.mulish(color: AppColor.darkGrey, fontSize: 14),
          ),
          const SizedBox(height: 8),

          Text(
            resendSeconds > 0 ? "Resend in ${resendSeconds}s" : "Resend OTP",
            style: AppTextStyles.mulish(
              color: AppColor.resendOtp,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                List.generate(4, (index) {
                  return SizedBox(
                    width: 55,
                    height: 55,
                    child: TextField(
                      controller: controllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 3,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                })..add(
                  // ✅ Check button at end
                  GestureDetector(
                    onTap: onSubmit,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
          ),

          if (showError)
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 4),
              child: Text(
                "⚠️ Please Enter Valid OTP",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  static Widget smallShopContainer({
    required String shopImage,
    required String shopLocation,
    required String shopName,
    bool isAdd = false,
  }) {
    return Container(
      width: 370,
      margin: const EdgeInsets.only(right: 0, left: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.asset(
              shopImage,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            !isAdd
                ? Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            !isAdd
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          shopName,
                          style: AppTextStyles.mulish(
                            color: AppColor.scaffoldColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColor.scaffoldColor.withOpacity(0.6),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                shopLocation,
                                style: AppTextStyles.mulish(
                                  color: AppColor.scaffoldColor.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 12,
                                ),
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Padding(
                  padding: const EdgeInsets.only(right: 10,bottom: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.3),
                               border: Border.all(color: AppColor.black.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'T-Ads',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
          ],
        ),
      ),
    );
  }

  static Widget offerCardContainer({
    required String tittle,
    required String cardImage,
    required String cardImage1,
    Color arrowColor = AppColor.appOfferArrow,
    bool isSurpriseCard = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Image.asset(cardImage, height: 100)),
        // Orange Card
        Container(
          width: 180,
          height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 15,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  "$tittle\nOffer",
                  style: AppTextStyles.mulish(
                    color: AppColor.scaffoldColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    !isSurpriseCard
                        ? RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '10',
                                  style: AppTextStyles.mulish(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColor.scaffoldColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Out of 25', // Normal part
                                  style: AppTextStyles.mulish(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.scaffoldColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            'Create Now',
                            style: AppTextStyles.mulish(
                              color: AppColor.scaffoldColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        AppImages.rightArrow,
                        height: 15,
                        color: arrowColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Positioned(top: -70, child: Image.asset(cardImage1, height: 150)),
      ],
    );
  }
}
