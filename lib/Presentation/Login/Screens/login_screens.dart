import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor/Presentation/Login/Screens/otp_screens.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../Login/controller/login_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
      } else if (next.loginResponse != null) {
        AppSnackBar.success(context, 'OTP sent successfully!');
        context.goNamed(AppRoutes.otp, extra: phoneController.text.trim());
        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      final phone = phoneController.text.trim();
                      if (phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter phone number'),
                          ),
                        );
                        return;
                      }
                      notifier.loginUser(phoneNumber: phone);
                    },
              child: state.isLoading
                  ? const ThreeDotsLoader()
                  : const Text('Login'),
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
