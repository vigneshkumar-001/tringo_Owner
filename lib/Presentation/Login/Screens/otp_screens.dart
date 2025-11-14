// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tringo_vendor/Presentation/Register/Screens/register_screen.dart';
//
// import '../../../Core/Routes/app_go_routes.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_snackbar.dart';
// import '../controller/login_notifier.dart';
//
// class OtpScreens extends ConsumerStatefulWidget {
//   final String phoneNumber;
//   const OtpScreens({super.key, required this.phoneNumber});
//
//   @override
//   ConsumerState<OtpScreens> createState() => _OtpScreensState();
// }
//
// class _OtpScreensState extends ConsumerState<OtpScreens> {
//   final TextEditingController otpController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Reset login state when entering this screen
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(loginNotifierProvider.notifier).resetState();
//     });
//   }
//   String? lastLoginPage;
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//
//     ref.listen<LoginState>(loginNotifierProvider, (_, next) {
//       final notifier = ref.read(loginNotifierProvider.notifier);
//
//       // Current error
//       if (next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         notifier.resetState();
//       }
//       // OTP verified -> navigate
//       else if (next.otpResponse != null) {
//         AppSnackBar.success(context, 'OTP verified successfully!');
//         context.goNamed(AppRoutes.register);
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (_) => const RegisterScreen()),
//         // );
//         notifier.resetState();
//       }
//       // Login response (used for resend OTP)
//       else if (next.loginResponse != null) {
//         // Check if this was a resend OTP request
//         if (lastLoginPage == 'resendOtp') {
//           AppSnackBar.success(context, 'OTP resent successfully!');
//         }
//         lastLoginPage = null; // reset after handling
//         notifier.resetState();
//       }
//     });
//     return Scaffold(
//       appBar: AppBar(title: const Text('Otp')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(labelText: 'Phone Number'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: state.isLoading
//                   ? null
//                   : () {
//                       final otp = otpController.text.trim();
//                       if (otp.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please enter phone number'),
//                           ),
//                         );
//                         return;
//                       }
//                       notifier.verifyOtp(contact: widget.phoneNumber, otp: otp);
//                     },
//               child: state.isLoading
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : const Text('Submit'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: state.isLoading
//                   ? null
//                   : () {
//                       final otp = otpController.text.trim();
//                       if (otp.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please enter phone number'),
//                           ),
//                         );
//                         return;
//                       }
//                       notifier. loginUser( phoneNumber: widget.phoneNumber,page: 'resendOtp');
//                     },
//               child: state.isLoading
//                   ? const ThreeDotsLoader()
//                   : const Text('Resend Otp Submit'),
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
///
///
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/common_Container.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otp = TextEditingController();
  String? otpError;
  String verifyCode = '';
  @override
  Widget build(BuildContext context) {
    String mobileNumber = widget.phoneNumber ?? '';
    String maskMobileNumber;

    if (mobileNumber.length <= 3) {
      maskMobileNumber = mobileNumber;
    } else {
      maskMobileNumber =
          'x' * (mobileNumber.length - 3) +
          mobileNumber.substring(mobileNumber.length - 3);
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 140,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
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
                                'Enter 4 Digit OTP',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'sent to',
                                style: AppTextStyles.mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'your given Mobile Number',
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
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: PinCodeTextField(
                        onCompleted: (value) async {},

                        autoFocus: otp.text.isEmpty,
                        appContext: context,
                        // pastedTextStyle: TextStyle(
                        //   color: Colors.green.shade600,
                        //   fontWeight: FontWeight.bold,
                        // ),
                        length: 4,

                        // obscureText: true,
                        // obscuringCharacter: '*',
                        // obscuringWidget: const FlutterLogo(size: 24,),
                        blinkWhenObscuring: true,
                        mainAxisAlignment: MainAxisAlignment.start,
                        autoDisposeControllers: false,

                        // validator: (v) {
                        //   if (v == null || v.length != 4)
                        //     return 'Enter valid 4-digit OTP';
                        //   return null;
                        // },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(17),
                          fieldHeight: 55,
                          fieldWidth: 55,
                          selectedColor: AppColor.darkBlue,
                          activeColor: AppColor.darkBlue,
                          activeFillColor: AppColor.white,
                          inactiveColor: AppColor.darkBlue,
                          selectedFillColor: AppColor.white,
                          fieldOuterPadding: EdgeInsets.symmetric(
                            horizontal: 9,
                          ),
                          inactiveFillColor: AppColor.white,
                        ),
                        cursorColor: AppColor.black,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        // errorAnimationController: errorController,
                        controller: otp,
                        keyboardType: TextInputType.number,
                        boxShadows: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: AppColor.skyBlue,
                            blurRadius: 5,
                          ),
                        ],
                        // validator: (value) {
                        //   if (value == null || value.length != 4) {
                        //     return 'Please enter a valid 4-digit OTP';
                        //   }
                        //   return null;
                        // },
                        // onCompleted: (value) async {},
                        onChanged: (value) {
                          debugPrint(value);
                          verifyCode = value;

                          if (otpError != null && value.isNotEmpty) {
                            setState(() {
                              otpError = null;
                            });
                          }
                        },

                        beforeTextPaste: (text) {
                          debugPrint("Allowing to paste $text");
                          return true;
                        },
                      ),
                    ),
                    if (otpError != null)
                      Center(
                        child: Text(
                          otpError!,
                          style: AppTextStyles.mulish(
                            color: AppColor.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          Text(
                            'Resend code in',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w800,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '00.29',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w800,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Text(
                        'OTP sent to $maskMobileNumber, please check and enter below. If you’re not received OTP',
                        style: AppTextStyles.mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                        ),
                      ),
                    ),
                    SizedBox(height: 35),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: CommonContainer.button(
                        onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => PrivacyPolicy(),
                          //     ),
                          //   );
                        },
                        text: Text('Verify Now'),
                      ),
                    ),
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
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
