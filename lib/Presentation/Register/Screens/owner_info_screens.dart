import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/app_loader.dart';
import 'package:tringo_owner/Core/Utility/app_prefs.dart';
import 'package:tringo_owner/Core/Utility/app_snackbar.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Core/Utility/ios_review_guard.dart';
import 'package:tringo_owner/Core/Utility/thanglish_to_tamil.dart';
import 'package:tringo_owner/Core/Utility/onboarding_cache.dart';
import 'package:tringo_owner/Core/Utility/onboarding_nav.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../Login/controller/login_notifier.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';
import '../controller/owner_info_notifier.dart';

class OwnerInfoScreens extends ConsumerStatefulWidget {
  final bool isService;
  final bool isIndividual;
  const OwnerInfoScreens({
    super.key,
    this.isCompany,
    required this.isService,
    required this.isIndividual,
  });
  final bool? isCompany;
  @override
  ConsumerState<OwnerInfoScreens> createState() => _OwnerInfoScreensState();
}

///new///
class _OwnerInfoScreensState extends ConsumerState<OwnerInfoScreens> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  // final type = RegistrationSession.instance.businessType?.label ?? 'Not set';

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

  // OTP
  final int otpLength = 4;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  late final String ownershipType;
  late final String businessTypeForApi;
  @override
  void initState() {
    super.initState();

    ownershipType = widget.isIndividual ? 'INDIVIDUAL' : 'COMPANY';
    businessTypeForApi = widget.isService ? 'SERVICES' : 'SELLING_PRODUCTS';

    _loadOwnerPhone();
    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromCache();
    });
  }

  @override
  void dispose() {
    englishNameController.dispose();
    tamilNameController.dispose();
    mobileController.dispose();
    emailIdController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();

    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOwnerPhone() async {
    final phone = await AppPrefs.getOwnerPhone() ?? '';

    AppLogger.log.i('owner_phone => $phone');

    if (mounted) {
      setState(() {
        mobileController.text = phone;
      });
    }
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

  bool get isOtpComplete =>
      otpControllers.every((controller) => controller.text.isNotEmpty);

  Future<void> _prefillFromCache() async {
    try {
      final cached = await OnboardingCache.getOwnerInfo();
      if (cached == null) return;

      final fullName = (cached['fullName'] ?? cached['govtRegisteredName'] ?? '')
          .toString()
          .trim();
      final email = (cached['email'] ?? '').toString().trim();
      final ownerTamil = (cached['ownerNameTamil'] ?? '').toString().trim();
      final gender = (cached['gender'] ?? '').toString().trim();
      final dob = (cached['dateOfBirth'] ?? '').toString().trim(); // yyyy-MM-dd

      if (!mounted) return;

      if (fullName.isNotEmpty && englishNameController.text.trim().isEmpty) {
        englishNameController.text = fullName;
      }
      if (ownerTamil.isNotEmpty && tamilNameController.text.trim().isEmpty) {
        tamilNameController.text = ownerTamil;
      }
      if (email.isNotEmpty && emailIdController.text.trim().isEmpty) {
        emailIdController.text = email;
      }
      if (gender.isNotEmpty && genderController.text.trim().isEmpty) {
        genderController.text = gender;
      }
      if (dob.isNotEmpty && dateOfBirthController.text.trim().isEmpty) {
        try {
          final parsed = DateTime.parse(dob);
          dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(parsed);
        } catch (_) {
          // ignore invalid format
        }
      }
    } catch (_) {
      // ignore cache parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerInfoNotifierProvider);
    AppLogger.log.w(mobileController.text);
    final bool isIndividualFlow = widget.isIndividual ?? true;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await OnboardingNav.backToPreviousOrExit(GoRouter.of(context));
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: _isSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                /// HEADER BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      CommonContainer.topLeftArrow(
                        onTap: () async {
                          if (showOtpCard) {
                            setState(() => showOtpCard = false);
                          } else {
                            final router = GoRouter.of(context);
                            if (router.canPop()) {
                              context.pop();
                            } else {
                              await OnboardingNav.backToPreviousOrExit(router);
                            }
                          }
                        },
                      ),
                      SizedBox(width: 50),
                      Text(
                        'Register Shop',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '-',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        isIndividualFlow ? 'Individual' : 'Company',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.mildBlack,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 35),

                /// HEADER BLOCK
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USER NAME
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
                            const TextSpan(
                              text: '( As per Govt Certificate )',
                              style: TextStyle(color: AppColor.mediumLightGray),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ENGLISH NAME
                      CommonContainer.fillingContainer(
                        text: '',
                        verticalDivider: false,
                        controller: englishNameController,
                        context: context,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter name' : null,
                      ),

                      //const SizedBox(height: 10),

                      /// TAMIL NAME
                      // CommonContainer.fillingContainer(
                      //   onChanged: (value) async {
                      //     setState(() => isTamilNameLoading = true);
                      //     final result =
                      //         await TanglishTamilHelper.transliterate(value);
                      //
                      //     setState(() {
                      //       tamilNameSuggestion = result;
                      //       isTamilNameLoading = false;
                      //     });
                      //   },
                      //   text: 'Tamil',
                      //   verticalDivider: true,
                      //   controller: tamilNameController,
                      //   context: context,
                      //   validator: (v) => v == null || v.trim().isEmpty
                      //       ? 'Enter Tamil name'
                      //       : null,
                      // ),
                      //
                      // if (isTamilNameLoading)
                      //   const Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: CircularProgressIndicator(strokeWidth: 2),
                      //   ),
                      //
                      // if (tamilNameSuggestion.isNotEmpty)
                      //   Container(
                      //     margin: const EdgeInsets.only(top: 4),
                      //     constraints: const BoxConstraints(maxHeight: 150),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(color: Colors.grey),
                      //     ),
                      //     child: ListView.builder(
                      //       shrinkWrap: true,
                      //       itemCount: tamilNameSuggestion.length,
                      //       itemBuilder: (context, index) {
                      //         final suggestion = tamilNameSuggestion[index];
                      //         return ListTile(
                      //           title: Text(suggestion),
                      //           onTap: () {
                      //             TanglishTamilHelper.applySuggestion(
                      //               controller: tamilNameController,
                      //               suggestion: suggestion,
                      //               onSuggestionApplied: () {
                      //                 setState(() => tamilNameSuggestion = []);
                      //               },
                      //             );
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   ),
                      const SizedBox(height: 30),

                      /// MOBILE NUMBER
                      Text(
                        'Mobile Number',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        readOnly: true,
                        controller: mobileController,
                        verticalDivider: true,
                        isMobile: true,
                        text: 'Mobile No',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Mobile number required';
                          }
                          if (v.length != 10) {
                            return 'Enter valid 10-digit mobile number';
                          }
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                            return 'Invalid mobile number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// EMAIL
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
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email required';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(v)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// DOB
                      Text(
                        'Date of Birth',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        controller: dateOfBirthController,
                        isDOB: true,
                        verticalDivider: false,
                        datePickMode: DatePickMode.single,
                        singleType:
                            DateSingleType.dob18Plus, // ✅ 18+ restriction
                        context: context,
                        readOnly: true,
                        validator: (v) {
                          // iOS App Store Guideline 5.1.1(v): DOB must be optional.
                          if (isIOSReviewBuild) return null;
                          return v == null || v.isEmpty ? "Select DOB" : null;
                        },
                      ),

                      // CommonContainer.fillingContainer(
                      //   isDOB: true,
                      //   verticalDivider: true,
                      //   imagePath: AppImages.dob,
                      //   imageWidth: 20,
                      //   imageHight: 25,
                      //   controller: dateOfBirthController,
                      //   textFontWeight: FontWeight.w700,
                      //   context: context,
                      //   datePickMode: DatePickMode.single,
                      //   validator: (v) =>
                      //       v == null || v.isEmpty ? 'DOB required' : null,
                      // ),
                      const SizedBox(height: 30),

                      /// GENDER
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
                        validator: (v) {
                          // iOS App Store Guideline 5.1.1(v): gender must be optional.
                          if (isIOSReviewBuild) return null;
                          return v == null || v.isEmpty ? 'Select gender' : null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// SUBMIT
                      CommonContainer.button(
                        imagePath: state.isLoading
                            ? null
                            : AppImages.rightStickArrow,
                        text: state.isLoading
                            ? ThreeDotsLoader()
                            : Text('Save & Continue'),
                        onTap: () async {
                          setState(() => _isSubmitted = true);

                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final englishName = englishNameController.text.trim();
                          final tamilName = tamilNameController.text.trim();
                          final mobile = mobileController.text.trim();
                          final email = emailIdController.text.trim();
                          final input = dateOfBirthController.text.trim();

                          String dobForApi = '';
                          // DOB is optional (e.g. iOS Guideline 5.1.1(v)); only
                          // parse/validate when the user actually entered one.
                          if (input.isNotEmpty) {
                            try {
                              final parsedDate = DateFormat(
                                'dd-MM-yyyy',
                              ).parseStrict(input);
                              dobForApi = DateFormat(
                                'yyyy-MM-dd',
                              ).format(parsedDate);
                            } catch (e) {
                              AppSnackBar.error(context, "Invalid DOB");
                              return;
                            }
                          }

                          final gender = genderController.text.trim();

                          AppLogger.log.i(
                            'ownershipType: $ownershipType, businessType: $businessTypeForApi',
                          );

                          await ref
                              .read(ownerInfoNotifierProvider.notifier)
                              .submitOwnerInfo(
                                ownershipType:
                                    ownershipType, // ✅ "INDIVIDUAL" / "COMPANY"
                                businessType:
                                    businessTypeForApi, // ✅ "PRODUCT" / "SERVICE" (adjust if backend uses different strings)
                                ownerNameTamil: tamilName,
                                identityDocumentUrl: '',
                                govtRegisteredName: englishName,
                                gender: gender,
                                fullName: englishName,
                                dateOfBirth: dobForApi,
                                email: email,
                                preferredLanguage: '',
                              );

                          if (!mounted) return;
                          final newState = ref.read(ownerInfoNotifierProvider);

                          if (newState.error != null) {
                            AppSnackBar.error(context, newState.error!);
                          } else if (newState.ownerResponse != null) {
                            context.push(
                              AppRoutes.shopCategoryInfoPath,
                              extra: {
                                'isService': widget.isService,
                                'isIndividual': widget.isIndividual,
                                'initialShopNameEnglish': englishNameController
                                    .text
                                    .trim(),
                                'initialShopNameTamil': tamilNameController.text
                                    .trim(),
                                'pages': 'OwnerInfoScreens',
                              },
                            );

                            AppLogger.log.i(
                              "Owner Info Saved  ${newState.ownerResponse?.toJson()}",
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
