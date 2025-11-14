// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/top_snack_bar.dart';
// import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
// import 'package:tringo_vendor/Presentation/Login/Screens/otp_screens.dart';
// import '../../../Core/Routes/app_go_routes.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../Login/controller/login_notifier.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final TextEditingController phoneController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//     ref.listen<LoginState>(loginNotifierProvider, (_, next) {
//       if (next.error != null) {
//         AppSnackBar.error(context, next.error!);
//       } else if (next.loginResponse != null) {
//         AppSnackBar.success(context, 'OTP sent successfully!');
//         context.goNamed(AppRoutes.otp, extra: phoneController.text.trim());
//         ref.read(loginNotifierProvider.notifier).resetState();
//       }
//     });
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(labelText: 'Phone Number'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: state.isLoading
//                   ? null
//                   : () {
//                       final phone = phoneController.text.trim();
//                       if (phone.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please enter phone number'),
//                           ),
//                         );
//                         return;
//                       }
//                       notifier.loginUser(phoneNumber: phone);
//                     },
//               child: state.isLoading
//                   ? const ThreeDotsLoader()
//                   : const Text('Login'),
//             ),
//             const SizedBox(height: 20),
//             if (state.error != null)
//               Text(state.error!, style: const TextStyle(color: Colors.red)),
//           ],
//         ),
//       ),
//     );
//   }
// }
///New///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/common_Container.dart';
import '../controller/login_notifier.dart';

class LoginMobileNumber extends ConsumerStatefulWidget {
  const LoginMobileNumber({super.key});

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber> {
  String errorText = '';
  bool _isFormatting = false;
  final TextEditingController mobileNumberController = TextEditingController();

  void _formatPhoneNumber(String value) {
    setState(() => errorText = '');

    if (_isFormatting) return;

    _isFormatting = true;
    String digitsOnly = value.replaceAll(' ', '');

    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 4 || i == 7) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    mobileNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _isFormatting = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
      } else if (next.loginResponse != null) {
        AppSnackBar.success(context, 'OTP sent successfully!');
        context.pushNamed(
          AppRoutes.otp,
          extra: mobileNumberController.text.trim(),
        );
        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              fit: BoxFit.cover,
              height: double.infinity,
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 120,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),
                    SizedBox(height: 81),

                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Login',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'With',
                                style: AppTextStyles.mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Your Mobile Number',
                            style: AppTextStyles.mulish(
                              fontSize: 24,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: mobileNumberController.text.isNotEmpty
                                ? AppColor.skyBlue
                                : AppColor.black,
                            width: mobileNumberController.text.isNotEmpty
                                ? 2
                                : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '+91',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColor.gray84,
                              ),
                            ),
                            SizedBox(width: 8),
                            Image.asset(
                              AppImages.downArrow,
                              height: 14,
                              color: AppColor.darkGrey,
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 2,
                              height: 35,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColor.white.withOpacity(0.5),
                                    AppColor.white3,
                                    AppColor.white3,
                                    AppColor.white.withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: TextFormField(
                                controller: mobileNumberController,
                                keyboardType: TextInputType.phone,
                                maxLength: 12,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                                onChanged: _formatPhoneNumber,
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Enter Mobile Number',
                                  hintStyle: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.borderLightGrey,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon:
                                      mobileNumberController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            mobileNumberController.clear();
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 17,
                                            ),
                                            child: Image.asset(
                                              AppImages.closeImage,
                                              width: 10,
                                              height: 10,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 10),
                      child: ListTile(
                        dense: true,
                        minLeadingWidth: 0,
                        horizontalTitleGap: 10,
                        leading: Image.asset(
                          AppImages.whatsAppBlack,
                          height: 20,
                        ),
                        title: Text(
                          'Get Instant Updates',
                          style: AppTextStyles.mulish(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'From Tringo on your',
                              style: AppTextStyles.mulish(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColor.darkGrey,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'whatsapp',
                              style: AppTextStyles.mulish(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColor.gray84,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.green, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              AppImages.tickImage,
                              height: 12,
                              color: AppColor.green,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 35),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: CommonContainer.button2(
                        width: double.infinity,
                        loader: state.isLoading ? ThreeDotsLoader() : null,
                        onTap: state.isLoading
                            ? null
                            : () {
                                final phone = mobileNumberController.text
                                    .trim();
                                if (phone.isEmpty) {
                                  AppSnackBar.info(
                                    context,
                                    'Please Enter Phone Number',
                                  );
                                  return;
                                }
                                notifier.loginUser(phoneNumber: phone);
                              },

                        text: 'Verify Now',
                      ),
                    ),

                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 35),
                    //   child: CommonContainer.button(
                    //     onTap: state.isLoading ? null : () {
                    //       final phone = mobileNumberController.text.trim();
                    //       if (phone.isEmpty) {
                    //         AppSnackBar.info(context, 'Please Enter Phone Number');
                    //         return;
                    //       }
                    //       notifier.loginUser(phoneNumber: phone);
                    //     },
                    //
                    //     text:   Text('Verify Now'),
                    //   ),
                    // ),

                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 35),
                    //   child: CommonContainer.button(
                    //     onTap: state.isLoading ? null : () {
                    //       final phone = mobileNumberController.text.trim();
                    //       if (phone.isEmpty) {
                    //        AppSnackBar.info(context, 'Please Enter Phone Number');
                    //         return;
                    //       }
                    //       notifier.loginUser(phoneNumber: phone);
                    //     },
                    //     // onTap: () {
                    //     //   Navigator.push(
                    //     //     context,
                    //     //     MaterialPageRoute(
                    //     //       builder: (context) => MobileNumberVerify(),
                    //     //     ),
                    //     //   );
                    //     // },
                    //     text: state.isLoading
                    //         ? const ThreeDotsLoader()
                    //         : const Text('Verify Now'),
                    //
                    //   ),
                    // ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppImages.loginScreenBottom,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
