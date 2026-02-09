import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Presentation/Create%20Surprise%20Offers/Screens/surprise_offer_list.dart';
import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Model/delete_response.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/qr_code_screen.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_history.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_screen.dart';
import 'package:tringo_owner/Presentation/Wallet/Screens/wallet_screens.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Create Surprise Offers/Screens/create_surprise_offers.dart';
import '../../Home/Controller/shopContext_provider.dart';
import '../../Login/controller/login_notifier.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../Offer/Screen/offer_screens.dart';
import '../../Privacy Policy/Screens/privacy_policy.dart';
import '../../Support/Screen/support_screen.dart';
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
    'Delete Account',
    'QR Code',
    'Privacy Policy',
    'Wallet',
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
    AppImages.qrCodeLogo,
    AppImages.privacypolicy,
    AppImages.walletImage,
  ];

  final List<Widget> screens = [
    const CommonBottomNavigation(initialIndex: 1),
    const CommonBottomNavigation(initialIndex: 3, initialAboutMeTab: 0),
    const CommonBottomNavigation(initialIndex: 2),
    // const UnderProcessing(),
    SurpriseOfferList(),

    const SubscriptionScreen(),
    const CommonBottomNavigation(initialIndex: 3, initialAboutMeTab: 1),
    const SupportScreen(),
    const UnderProcessing(),
    const UnderProcessing(),
    const PrivacyPolicy(),
    const WalletScreens(),
  ];

  Future<bool> _confirmDeleteAccount(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade600,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(false); // <-- return false
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(true); // <-- return true
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false; // if dialog is dismissed unexpectedly
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _confirmDeleteAccount(context);
    if (!confirmed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(subscriptionNotifier.notifier).deleteAccount();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // always close loader
      }
    }

    final st = ref.read(subscriptionNotifier);

    final success =
        st.accountDeleteResponse?.status == true &&
        st.accountDeleteResponse?.data.deleted == true;

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      AppSnackBar.success(context, "Account deleted successfully");
      context.goNamed(AppRoutes.login);
    } else {
      AppSnackBar.error(context, st.error ?? "Delete failed");
    }
  }

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
                    onTap: () async {
                      switch (i) {
                        case 6: // SUPPORT
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupportScreen(),
                            ),
                          );
                          break;

                        case 7: // DELETE ACCOUNT
                          await _handleDeleteAccount();
                          break;

                        case 4: // SUBSCRIPTION
                          final bool isFreemium = planData?.isFreemium == false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => isFreemium
                                  ? SubscriptionHistory(
                                      fromDate:
                                          planData?.period.startsAtLabel ?? '',
                                      titlePlan:
                                          planData?.plan.durationLabel ?? '',
                                      toDate:
                                          planData?.period.endsAtLabel ?? '',
                                    )
                                  : const SubscriptionScreen(),
                            ),
                          );
                          break;

                        case 8: // ✅ QR Code
                          final selectedShopId =
                              (ref.read(selectedShopProvider)?.toString() ?? '')
                                  .trim();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QrCodeScreen(shopId: selectedShopId),
                            ),
                          );
                          break;

                        case 9: // ✅ Privacy Policy
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PrivacyPolicy(showAcceptReject: false),
                            ),
                          );
                          break;

                        default:
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => screens[i]),
                          );
                      }
                    },

                    // onTap: () async {
                    //   // ✅ DELETE ACCOUNT (index 7)
                    //   if (i == 7) {
                    //     final confirmed = await showDialog<bool>(
                    //       context: context,
                    //       barrierDismissible: false,
                    //       builder: (_) => Dialog(
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(24),
                    //         ),
                    //         elevation: 0,
                    //         backgroundColor: Colors.transparent,
                    //         child: Container(
                    //           padding: const EdgeInsets.all(24),
                    //           decoration: BoxDecoration(
                    //             color: Colors.white,
                    //             borderRadius: BorderRadius.circular(24),
                    //             boxShadow: [
                    //               BoxShadow(
                    //                 color: Colors.black.withOpacity(0.15),
                    //                 blurRadius: 20,
                    //                 offset: const Offset(0, 10),
                    //               ),
                    //             ],
                    //           ),
                    //           child: Column(
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //               // Icon
                    //               Container(
                    //                 padding: const EdgeInsets.all(16),
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.red.shade50,
                    //                   shape: BoxShape.circle,
                    //                 ),
                    //                 child: Icon(
                    //                   Icons.warning_rounded,
                    //                   color: Colors.red.shade600,
                    //                   size: 48,
                    //                 ),
                    //               ),
                    //
                    //               const SizedBox(height: 20),
                    //
                    //               // Title
                    //               const Text(
                    //                 'Delete Account?',
                    //                 style: TextStyle(
                    //                   fontSize: 22,
                    //                   fontWeight: FontWeight.w700,
                    //                   color: Colors.black87,
                    //                 ),
                    //                 textAlign: TextAlign.center,
                    //               ),
                    //
                    //               const SizedBox(height: 12),
                    //
                    //               // Description
                    //               Text(
                    //                 'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                    //                 style: TextStyle(
                    //                   fontSize: 15,
                    //                   color: Colors.grey.shade600,
                    //                   height: 1.5,
                    //                 ),
                    //                 textAlign: TextAlign.center,
                    //               ),
                    //
                    //               const SizedBox(height: 28),
                    //
                    //               // Buttons
                    //               Row(
                    //                 children: [
                    //                   // Cancel Button
                    //                   Expanded(
                    //                     child: SizedBox(
                    //                       height: 52,
                    //                       child: OutlinedButton(
                    //                         onPressed: () =>
                    //                             Navigator.pop(context, false),
                    //                         style: OutlinedButton.styleFrom(
                    //                           side: BorderSide(
                    //                             color: Colors.grey.shade300,
                    //                             width: 1.5,
                    //                           ),
                    //                           shape: RoundedRectangleBorder(
                    //                             borderRadius:
                    //                                 BorderRadius.circular(14),
                    //                           ),
                    //                           foregroundColor:
                    //                               Colors.grey.shade700,
                    //                         ),
                    //                         child: const Text(
                    //                           'Cancel',
                    //                           style: TextStyle(
                    //                             fontSize: 16,
                    //                             fontWeight: FontWeight.w600,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //
                    //                   const SizedBox(width: 12),
                    //
                    //                   // Delete Button
                    //                   Expanded(
                    //                     child: SizedBox(
                    //                       height: 52,
                    //                       child: ElevatedButton(
                    //                         onPressed: () =>
                    //                             Navigator.pop(context, true),
                    //                         style: ElevatedButton.styleFrom(
                    //                           backgroundColor:
                    //                               Colors.red.shade600,
                    //                           foregroundColor: Colors.white,
                    //                           elevation: 0,
                    //                           shape: RoundedRectangleBorder(
                    //                             borderRadius:
                    //                                 BorderRadius.circular(14),
                    //                           ),
                    //                         ),
                    //                         child: const Text(
                    //                           'Delete',
                    //                           style: TextStyle(
                    //                             fontSize: 16,
                    //                             fontWeight: FontWeight.w600,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       //     AlertDialog(
                    //       //   backgroundColor: AppColor.white,
                    //       //   title: Text(
                    //       //     'Delete Account?',
                    //       //     style: AppTextStyles.mulish(
                    //       //       fontWeight: FontWeight.w800,
                    //       //       fontSize: 18,
                    //       //       color: AppColor.darkBlue,
                    //       //     ),
                    //       //   ),
                    //       //   content: Text(
                    //       //     'This will permanently delete your account. This action cannot be undone.',
                    //       //     style: AppTextStyles.mulish(
                    //       //       fontSize: 14,
                    //       //       color: AppColor.darkGrey,
                    //       //     ),
                    //       //   ),
                    //       //   actions: [
                    //       //     TextButton(
                    //       //       onPressed: () => Navigator.pop(context, false),
                    //       //       child: Text(
                    //       //         'Cancel',
                    //       //         style: AppTextStyles.mulish(
                    //       //           color: AppColor.darkBlue,
                    //       //         ),
                    //       //       ),
                    //       //     ),
                    //       //     TextButton(
                    //       //       onPressed: () => Navigator.pop(context, true),
                    //       //       child: Text(
                    //       //         'Delete Account',
                    //       //         style: AppTextStyles.mulish(
                    //       //           color: AppColor.red1,
                    //       //         ),
                    //       //       ),
                    //       //     ),
                    //       //   ],
                    //       // ),
                    //     );
                    //
                    //     if (confirmed != true) return;
                    //
                    //     // loader
                    //     showDialog(
                    //       context: context,
                    //       barrierDismissible: false,
                    //       builder: (_) =>
                    //           const Center(child: CircularProgressIndicator()),
                    //     );
                    //
                    //     await ref
                    //         .read(subscriptionNotifier.notifier)
                    //         .deleteAccount();
                    //
                    //     if (context.mounted)
                    //       Navigator.pop(context); // close loader
                    //
                    //     final st = ref.read(subscriptionNotifier);
                    //
                    //     if (st.deleteResponse?.status == true) {
                    //       final prefs = await SharedPreferences.getInstance();
                    //       await prefs.clear();
                    //
                    //       if (!context.mounted) return;
                    //       AppSnackBar.success(
                    //         context,
                    //         "Account deleted successfully",
                    //       );
                    //       context.goNamed(AppRoutes.login);
                    //     } else {
                    //       if (!context.mounted) return;
                    //       AppSnackBar.error(
                    //         context,
                    //         st.deleteResponse?.message ??
                    //             st.error ??
                    //             "Delete failed",
                    //       );
                    //     }
                    //
                    //     return; // ✅ stop further navigation
                    //   }
                    //
                    //   // ✅ EXISTING subscription click
                    //   if (i == 4) {
                    //     final bool isFreemium = planData?.isFreemium == false;
                    //
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => isFreemium
                    //             ? SubscriptionHistory(
                    //                 fromDate:
                    //                     planData?.period.startsAtLabel
                    //                         .toString() ??
                    //                     '',
                    //                 titlePlan:
                    //                     planData?.plan.durationLabel
                    //                         .toString() ??
                    //                     '',
                    //                 toDate:
                    //                     planData?.period.endsAtLabel
                    //                         .toString() ??
                    //                     '',
                    //               )
                    //             : const SubscriptionScreen(),
                    //       ),
                    //     );
                    //     return;
                    //   }
                    //
                    //   if (i == 8) {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const UnderProcessing(),
                    //       ),
                    //     );
                    //     return;
                    //   }
                    //
                    //   if (i == 6) {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) =>  SupportScreen(),
                    //       ),
                    //     );
                    //     return;
                    //   }
                    //   // ✅ DEFAULT navigation
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (_) => screens[i]),
                    //   );
                    // },
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

                  // InkWell(
                  //   onTap: () {
                  //     if (i == 4) {
                  //       final bool isFreemium = planData?.isFreemium == false;
                  //
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) => isFreemium
                  //               ? SubscriptionHistory(
                  //                   fromDate:
                  //                       planData?.period.startsAtLabel
                  //                           .toString() ??
                  //                       '',
                  //                   titlePlan:
                  //                       planData?.plan.durationLabel
                  //                           .toString() ??
                  //                       '',
                  //                   toDate:
                  //                       planData?.period.endsAtLabel
                  //                           .toString() ??
                  //                       '',
                  //                 ) // <-- your history page
                  //               : const SubscriptionScreen(),
                  //         ),
                  //       );
                  //       return;
                  //     }
                  //
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (_) => screens[i]),
                  //     );
                  //   },
                  //
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.symmetric(
                  //           horizontal: 13,
                  //           vertical: 15,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: AppColor.brightGray,
                  //         ),
                  //         child: Image.asset(
                  //           images[i],
                  //           height: 17,
                  //           color: i == 5 ? AppColor.black : null,
                  //         ),
                  //       ),
                  //       SizedBox(width: 15),
                  //       Text(
                  //         titles[i],
                  //         style: AppTextStyles.mulish(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w500,
                  //           color: AppColor.darkBlue,
                  //         ),
                  //       ),
                  //       Spacer(),
                  //       Image.asset(
                  //         AppImages.rightArrow,
                  //         color: AppColor.darkGrey,
                  //         height: 15,
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
