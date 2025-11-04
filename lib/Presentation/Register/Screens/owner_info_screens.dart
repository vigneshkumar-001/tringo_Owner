import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Core/Utility/thanglish_to_tamil.dart';

import '../../../Core/Utility/common_Container.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';

class OwnerInfoScreens extends StatefulWidget {
  const OwnerInfoScreens({super.key});

  @override
  State<OwnerInfoScreens> createState() => _OwnerInfoScreensState();
}

class _OwnerInfoScreensState extends State<OwnerInfoScreens> {
  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  bool showOtpCard = false;
  int resendSeconds = 30;
  List<String> tamilNameSuggestion = [];
  bool isTamilNameLoading = false;

  // OTP related
  final int otpLength = 4;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  @override
  void initState() {
    super.initState();
    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    englishNameController.dispose();
    tamilNameController.dispose();
    mobileController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    resendSeconds = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => resendSeconds--);
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < otpLength - 1) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
    }
    setState(() {});
  }

  bool get isOtpComplete =>
      otpControllers.every((controller) => controller.text.isNotEmpty);

  void _onSubmitOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    debugPrint("Entered OTP: $otp");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("OTP Entered: $otp")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CommonContainer.topLeftArrow(
                      onTap: () {
                        if (showOtpCard) {
                          setState(() => showOtpCard = false);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(width: 50),
                    Text(
                      'Register Shop - Individual',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              /// Header Container
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.registerBCImage),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.scaffoldColor, AppColor.lightGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Image.asset(AppImages.person, height: 85),
                      const SizedBox(height: 15),
                      Text(
                        'Owner’s Info',
                        style: AppTextStyles.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      const SizedBox(height: 30),
                      LinearProgressIndicator(
                        minHeight: 12,
                        value: 0.3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.mediumGreen,
                        ),
                        backgroundColor: AppColor.scaffoldColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Name of the User ',
                            style: TextStyle(color: AppColor.mildBlack),
                          ),
                          TextSpan(
                            text: '( As per Govt Certificate )',
                            style: const TextStyle(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      text: 'English',
                      verticalDivider: true,
                      controller: englishNameController,
                      context: context,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a user name'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      onChanged: (value) async {
                        setState(() => isTamilNameLoading = true);
                        final result = await TanglishTamilHelper.transliterate(
                          value,
                        );

                        setState(() {
                          tamilNameSuggestion = result;
                          isTamilNameLoading = false;
                        });
                      },

                      text: 'Tamil',
                      verticalDivider: true,
                      controller: tamilNameController,
                      context: context,
                    ),
                    if (isTamilNameLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (tamilNameSuggestion.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tamilNameSuggestion.length,
                          itemBuilder: (context, index) {
                            final suggestion = tamilNameSuggestion[index];
                            return ListTile(
                              title: Text(suggestion),
                              onTap: () {
                                print("Selected suggestion: $suggestion");
                                TanglishTamilHelper.applySuggestion(
                                  controller: tamilNameController,
                                  suggestion: suggestion,
                                  onSuggestionApplied: () {
                                    setState(() => tamilNameSuggestion = []);
                                  },
                                );
                              },
                              // onTap:
                              //     () => _onSuggestionSelected(suggestion),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 30),

                    /// OTP Switcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: showOtpCard
                          ? CommonContainer.otpVerificationCard(
                              last4Digits: mobileController.text.substring(
                                mobileController.text.length - 4,
                              ),
                              resendSeconds: resendSeconds,
                              context: context,
                              controllers: otpControllers,
                              // focusNodes: otpFocusNodes,
                              // onChanged: _onOtpChanged,
                              // isOtpComplete: isOtpComplete,
                              onSubmit: _onSubmitOtp,
                              onBack: () => setState(() => showOtpCard = false),
                            )
                          : CommonContainer.mobileNumberField(
                              controller: mobileController,
                              onChanged: (v) {},
                              onVerifyTap: () {
                                if (mobileController.text.length == 10) {
                                  setState(() => showOtpCard = true);
                                  _startResendTimer();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Enter a valid 10-digit mobile number",
                                      ),
                                    ),
                                  );
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mobile number required';
                                }
                                if (value.length != 10) {
                                  return 'Enter valid 10-digit number';
                                }
                                return null;
                              },
                            ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Email Id',
                      style: GoogleFonts.mulish(color: AppColor.mildBlack),
                    ),
                    const SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      keyboardType: TextInputType.emailAddress,
                      text: 'Email Id',
                      verticalDivider: true,
                      controller: emailIdController,
                      context: context,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Date of Birth',
                      style: GoogleFonts.mulish(color: AppColor.mildBlack),
                    ),
                    const SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      isDOB: true,
                      verticalDivider: true,
                      imagePath: AppImages.dob,
                      imageWidth: 20,
                      imageHight: 25,
                      controller: dateOfBirthController,
                      context: context,
                      datePickMode: DatePickMode.single,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Gender',
                      style: GoogleFonts.mulish(color: AppColor.mildBlack),
                    ),
                    const SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      readOnly: true,

                      isDropdown: true,
                      dropdownItems: ['Male', 'Female', 'Others'],
                      verticalDivider: false,
                      imagePath: AppImages.downArrow,
                      controller: genderController,
                      context: context,
                    ),
                    const SizedBox(height: 30),
                    CommonContainer.button(
                      imagePath: AppImages.rightStickArrow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopCategoryInfo(),
                          ),
                        );
                      },
                      text: Text('Save & Continue'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
