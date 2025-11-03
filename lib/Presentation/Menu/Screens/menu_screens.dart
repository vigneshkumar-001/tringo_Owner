import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/Menu/Screens/subscription_screen.dart';

import '../../Create App Offer/Screens/create_app_offer.dart';

class MenuScreens extends StatefulWidget {
  const MenuScreens({super.key});

  @override
  State<MenuScreens> createState() => _MenuScreensState();
}

class _MenuScreensState extends State<MenuScreens> {
  final List<String> titles = [
    'Enquiries',
    'Shop & Products',
    'App Offer',
    'Surprise Offer',
    'Subscription & Payment',
    'Analytics',
    'Support',
    'Account Related',
    'Privacy Policy',
  ];

  final List<String> images = [
    AppImages.enquiryFill,
    AppImages.aboutMeFill,
    AppImages.offerFill,
    AppImages.surpriseOffer,
    AppImages.subscription,
    AppImages.analytics,
    AppImages.support,
    AppImages.accountRelated,
    AppImages.privacypolicy,
  ];

  final List<Widget> screens = [
    const SubscriptionScreen(),
    const SubscriptionScreen(),
    const CreateAppOffer(),
    const SubscriptionScreen(),
    const SubscriptionScreen(),
    const SubscriptionScreen(),
    const SubscriptionScreen(),
    const SubscriptionScreen(),
    const SubscriptionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                CommonContainer.topLeftArrow(isMenu: true, onTap: () {}),
                SizedBox(height: 20),
                CommonContainer.attractCustomerCard(
                  title: 'Attract More Customers',
                  description: 'Unlock premium to attract more customers',
                  onTap: () {},
                ),
                SizedBox(height: 20),

                for (int i = 0; i < titles.length; i++) ...[
                  InkWell(
                    onTap: () {
                      print('Tapped on ${titles[i]}');
                      // Example: Navigate or trigger Bloc here
                      // Navigator.push(...);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => screens[i]),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 15,
                          ),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.brightGray,
                          ),
                          child: Image.asset(
                            images[i],
                            height: 17,
                            color: i == 5 ? AppColor.black : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          titles[i],
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          AppImages.rightArrow,
                          color: AppColor.darkGrey,
                          height: 15,
                        ),
                      ],
                    ),
                  ),

                  if (i == 5) ...[
                    const SizedBox(height: 15),
                    CommonContainer.horizonalDivider(),

                    const SizedBox(height: 15),
                  ] else if (i == 8) ...[
                    const SizedBox(height: 15),
                    CommonContainer.horizonalDivider(),
                    const SizedBox(height: 15),
                  ] else
                    const SizedBox(height: 18),
                ],

                CommonContainer.button(
                  onTap: () {},
                  text: Text(
                    'Logout',
                    style: AppTextStyles.mulish(color: AppColor.red1),
                  ),
                  borderColor: AppColor.red1,
                  buttonColor: AppColor.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
