import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/register_screen.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../controller/login_notifier.dart';

class OtpScreens extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreens({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreens> createState() => _OtpScreensState();
}

class _OtpScreensState extends ConsumerState<OtpScreens> {
  final TextEditingController otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // ✅ Reset login state when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginNotifierProvider.notifier).resetState();
    });
  }
  String? lastLoginPage;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      final notifier = ref.read(loginNotifierProvider.notifier);

      // Current error
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        notifier.resetState();
      }
      // OTP verified -> navigate
      else if (next.otpResponse != null) {
        AppSnackBar.success(context, 'OTP verified successfully!');
        context.goNamed(AppRoutes.register);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => const RegisterScreen()),
        // );
        notifier.resetState();
      }
      // Login response (used for resend OTP)
      else if (next.loginResponse != null) {
        // Check if this was a resend OTP request
        if (lastLoginPage == 'resendOtp') {
          AppSnackBar.success(context, 'OTP resent successfully!');
        }
        lastLoginPage = null; // reset after handling
        notifier.resetState();
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Otp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      final otp = otpController.text.trim();
                      if (otp.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter phone number'),
                          ),
                        );
                        return;
                      }
                      notifier.verifyOtp(contact: widget.phoneNumber, otp: otp);
                    },
              child: state.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      final otp = otpController.text.trim();
                      if (otp.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter phone number'),
                          ),
                        );
                        return;
                      }
                      notifier. loginUser( phoneNumber: widget.phoneNumber,page: 'resendOtp');
                    },
              child: state.isLoading
                  ? const ThreeDotsLoader()
                  : const Text('Resend Otp Submit'),
            ),
            const SizedBox(height: 20),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
