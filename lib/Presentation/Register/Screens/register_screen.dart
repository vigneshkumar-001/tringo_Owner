import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/owner_info_screens.dart';

import 'package:tringo_vendor/Core/Session/registration_session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedIndex = -1;

  bool? selectedKind;

  // void _goNext() {
  //   // selectedKind is guaranteed non-null when the button is visible
  //   final isIndividual = selectedKind ?? true;
  //
  //   RegistrationSession.instance.businessType = isIndividual
  //       ? BusinessType.individual
  //       : BusinessType.company;
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const OwnerInfoScreens()),
  //   );
  // }
  void _goNext() {
    if (selectedKind == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your business type.')),
      );
      return;
    }

    RegistrationSession.instance.businessType = selectedKind!
        ? BusinessType.individual
        : BusinessType.company;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OwnerInfoScreens()),
    );
  }

  @override
  void dispose() {
    // RegistrationSession.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonContainer.topLeftArrow(
                  onTap: () {
                    Navigator.maybePop(context);
                  },
                ),
                const SizedBox(height: 20),

                Text('Choose', style: AppTextStyles.textWithBold(fontSize: 28)),
                Text(
                  'your business type',
                  style: AppTextStyles.textWithBold(fontSize: 28),
                ),
                const SizedBox(height: 12),

                Text(
                  'Connect your business to millions of customers. Whether you sell products or services, our platform helps you grow.',
                  style: AppTextStyles.textWithBold(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 20),

                CommonContainer.sellingProduct(
                  image: AppImages.sell,
                  title: 'I’m Selling Products',
                  description:
                      'Gain instant visibility and connect with thousands of local customers actively searching for your goods. Our platform is your direct link to a wider audience and increased sales.',
                  isSelected: selectedIndex == 0,
                  selectedKind: selectedKind,
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                      selectedKind =
                          null; // show chooser, hide button until user picks
                    });
                  },
                  onToggle: (bool? value) {
                    setState(() => selectedKind = value);
                  },
                  buttonTap: _goNext,
                ),

                const SizedBox(height: 20),

                CommonContainer.sellingProduct(
                  image: AppImages.service,
                  title: 'I Do Services',
                  description:
                      'Grow your client base and fill your schedule with quality leads from our platform. We help you get discovered by new customers who need your expertise right now.',
                  isSelected: selectedIndex == 1,
                  selectedKind: selectedKind,
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                      selectedKind = null;
                    });
                  },
                  onToggle: (bool? value) {
                    setState(() => selectedKind = value);
                  },
                  buttonTap: _goNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
