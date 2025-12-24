import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/Menu/Controller/subscripe_notifier.dart';
import 'package:tringo_vendor/Presentation/Menu/Screens/subscription_history.dart';
import 'package:tringo_vendor/Presentation/Menu/Screens/subscription_screen.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Create Surprise Offers/create_surprise_offers.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../Offer/Screen/offer_screens.dart';
import '../../under_processing.dart';

class MenuScreens extends ConsumerStatefulWidget {
  final String? page;
  const MenuScreens({super.key, this.page});

  @override
  ConsumerState<MenuScreens> createState() => _MenuScreensState();
}

class _MenuScreensState extends ConsumerState<MenuScreens> {
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
    const UnderProcessing(),

    const SubscriptionScreen(),
    const CommonBottomNavigation(initialIndex: 3, initialAboutMeTab: 1),
    const NoDataScreen(
      showBottomButton: false,
      showTopBackArrow: false,
      title: 'This feature is currently under development',
      message: '',
      fontSize: 14,
    ),
    const NoDataScreen(
      showBottomButton: false,
      showTopBackArrow: false,
      title: 'This feature is currently under development',
      message: '',
      fontSize: 14,
    ),
    const NoDataScreen(
      showBottomButton: false,
      showTopBackArrow: false,
      title: 'This feature is currently under development',
      message: '',
      fontSize: 14,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(subscriptionNotifier);

    final isPremium = RegistrationProductSeivice.instance.isPremium;
    final isNonPremium = RegistrationProductSeivice.instance.isNonPremium;
    final planData = planState.currentPlanResponse?.data;

    String time = '-';
    String date = '-';

    final String? startsAt = planData?.period.startsAt;

    if (startsAt != null && startsAt.isNotEmpty) {
      final DateTime dateTime = DateTime.parse(startsAt).toLocal();
      time = DateFormat('h.mm.a').format(dateTime);
      date = DateFormat('dd MMM yyyy').format(dateTime);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.page != 'bottomScreen') ...[
                  CommonContainer.topLeftArrow(
                    isMenu: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ],

                SizedBox(height: 20),
                if (!isPremium)
                  // CommonContainer.attractCustomerCard(
                  //   title: 'Attract More Customers',
                  //   description: 'Unlock premium to attract more customers',
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => SubscriptionScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  planData?.isFreemium == false
                      ? CommonContainer.paidCustomerCard(
                          title:
                              '${planData?.plan.durationLabel} Premium Activated',
                          description: '${time} @ ${date}',
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => SubscriptionScreen(),
                            //   ),
                            // );
                          },
                        )
                      : CommonContainer.attractCustomerCard(
                          title: 'Attract More Customers',
                          description:
                              'Unlock premium to attract more customers',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubscriptionScreen(),
                              ),
                            );
                          },
                        ),
                if (!isNonPremium)
                  Text(
                    'Menu',
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: AppColor.darkBlue,
                    ),
                  ),
                SizedBox(height: 20),

                for (int i = 0; i < titles.length; i++) ...[
                  InkWell(
                    onTap: () {
                      if (i == 4) {
                        final bool isFreemium = planData?.isFreemium == false;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => isFreemium
                                ? SubscriptionHistory(
                                    fromDate:
                                        planData?.period.startsAtLabel
                                            .toString() ??
                                        '',
                                    titlePlan:
                                        planData?.plan.durationLabel
                                            .toString() ??
                                        '',
                                    toDate:
                                        planData?.period.endsAtLabel
                                            .toString() ??
                                        '',
                                  ) // <-- your history page
                                : const SubscriptionScreen(),
                          ),
                        );
                        return;
                      }

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
                      final prefs = await SharedPreferences.getInstance();
                      // prefs.remove('token');
                      // prefs.remove('isProfileCompleted');
                      // prefs.remove('isNewOwner');
                      await prefs.clear();

                      // Then navigate
                      context.goNamed(AppRoutes.login);
                      // or: context.go(AppRoutes.loginPath);
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
