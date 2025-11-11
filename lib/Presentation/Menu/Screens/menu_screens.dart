import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/Menu/Screens/subscription_screen.dart';

import '../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Create Surprise Offers/create_surprise_offers.dart';
import '../../Offer/Screen/offer_screens.dart';

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
    const CommonBottomNavigation(initialIndex: 1),
    const CommonBottomNavigation(initialIndex: 3, initialAboutMeTab: 0),
    const CommonBottomNavigation(initialIndex: 2),
    const CreateSurpriseOffers(),
    const SubscriptionScreen(),
    const CommonBottomNavigation(initialIndex: 3, initialAboutMeTab: 1),
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
                CommonContainer.topLeftArrow(
                  isMenu: true,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: 20),
                CommonContainer.attractCustomerCard(
                  title: 'Attract More Customers',
                  description: 'Unlock premium to attract more customers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionScreen(),
                      ),
                    );
                  },
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.brightGray,
                          ),
                          child: Image.asset(
                            images[i],
                            height: 17,
                            color: i == 5 ? AppColor.black : null,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          titles[i],
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        Spacer(),
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
                    const SizedBox(height: 25),
                    CommonContainer.horizonalDivider(),
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 18),
                ],

                CommonContainer.button(
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColor.white,
                        title: Text('Confirm Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false), // cancel
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true), // confirm
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout ?? false) {
                      // Perform your logout logic here
                      // For example: AuthController.logout() or Navigator.pushReplacement to login screen
                      print('User logged out');
                    }
                  },
                  text: Text(
                    'Logout',
                    style: AppTextStyles.mulish(
                      color: AppColor.red1,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
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
