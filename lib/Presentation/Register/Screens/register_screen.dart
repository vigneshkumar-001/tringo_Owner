import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
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
  bool isIndividual = true;

  void _goNext() {
    RegistrationSession.instance.businessType = isIndividual
        ? BusinessType.individual
        : BusinessType.company;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OwnerInfoScreens()),
    );
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
                CommonContainer.topLeftArrow(onTap: () {}),
                const SizedBox(height: 20),
                Text(
                  'Choose your business type',
                  style: AppTextStyles.textWithBold(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Connect your business to millions of customers. Whether you sell products or services, our platform helps you grow.',
                  style: AppTextStyles.textWithBold(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 20),

                CommonContainer.sellingProduct(
                  buttonTap: _goNext, // <-- set session + navigate
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                      isIndividual = true; // default when selecting card
                    });
                  },
                  isSelected: selectedIndex == 0,
                  image: AppImages.sell,
                  isIndividual: isIndividual,
                  onToggle: (value) {
                    setState(() {
                      isIndividual = value;
                    });
                  },
                  title: 'I’m Selling Products',
                  description:
                      'Gain instant visibility and connect with thousands of local customers actively searching for your goods. Our platform is your direct link to a wider audience and increased sales.',
                ),

                const SizedBox(height: 20),

                CommonContainer.sellingProduct(
                  buttonTap: _goNext,
                  onToggle: (value) {
                    setState(() {
                      isIndividual = value;
                    });
                  },
                  isSellingCard: true,
                  image: AppImages.service,
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                      isIndividual = true;
                    });
                  },
                  title: 'I Do Services',
                  isSelected: selectedIndex == 1,
                  description:
                      'Grow your client base and fill your schedule with quality leads from our platform. We help you get discovered by new customers who need your expertise right now.',
                  isIndividual: isIndividual,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
