import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/payment_success_screen.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/app_textstyles.dart';

import '../Controller/subscripe_notifier.dart';

import '../Model/plan_list_response.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  final bool showSkip;

  const SubscriptionScreen({super.key, this.showSkip = false});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  // Selected billing index: 0 = 1 Year, 1 = 6 Month, 2 = 3 Month
  int _selectedBilling = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(subscriptionNotifier.notifier).getPlanList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifier);

    final planAmount = state.planListResponse?.data;

    final List<PlanFeature> comparisonFeatures = () {
      final plans = planAmount ?? const <PlanModel>[];
      if (plans.isEmpty) return <PlanFeature>[];

      if (_selectedBilling >= 0 && _selectedBilling < plans.length) {
        final selected = plans[_selectedBilling].features;
        if (selected.isNotEmpty) {
          return selected;
        }
      }

      for (final p in plans) {
        if (p.features.isNotEmpty) return p.features;
      }

      return <PlanFeature>[];
    }();


    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.white3),
                                shape: BoxShape.circle,
                                color: AppColor.white,
                              ),
                              child: Image.asset(
                                AppImages.leftArrow,
                                height: 15,
                                color: AppColor.black,
                              ),
                            ),
                          ),
                          //Spacer(),
                          // if (widget.showSkip)
                          //   InkWell(
                          //     onTap: () {
                          //       RegistrationProductSeivice.instance
                          //           .markUnsubscribed();
                          //
                          //       final router = GoRouter.of(context);
                          //
                          //       // 1ÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢Ãƒâ€ Ã¢â‚¬â„¢Ãƒâ€šÃ‚Â£ Close this SubscriptionScreen if it was pushed via Navigator
                          //       if (Navigator.of(context).canPop()) {
                          //         Navigator.of(context).pop();
                          //       }
                          //
                          //       // 2ÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢Ãƒâ€ Ã¢â‚¬â„¢Ãƒâ€šÃ‚Â£ Now use go_router to show ShopsDetails
                          //       router.goNamed(
                          //         AppRoutes.shopsDetails,
                          //         extra: {
                          //           'backDisabled': false,
                          //           'fromSubscriptionSkip': true,
                          //         },
                          //       );
                          //     },
                          //     borderRadius: BorderRadius.circular(16),
                          //     child: Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 18,
                          //         vertical: 5,
                          //       ),
                          //       child: Text(
                          //         'Skip',
                          //         style: AppTextStyles.mulish(
                          //           fontSize: 20,
                          //           fontWeight: FontWeight.w700,
                          //           color: AppColor.darkBlue,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          //
                          //
                        ],
                      ),
                      SizedBox(height: 10),
                      Image.asset(
                        AppImages.crown,
                        height: 105,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Unlock the Tringo's",
                        style: AppTextStyles.mulish(fontSize: 22),
                      ),
                      Text(
                        "Super Power",
                        style: AppTextStyles.mulish(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _ComparisonCard(features: comparisonFeatures),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Cancel Subscription Any time',
                          style: AppTextStyles.mulish(color: AppColor.darkGrey),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (widget.showSkip)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 31),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              RegistrationProductSeivice.instance
                                  .markUnsubscribed();

                              final router = GoRouter.of(context);

                              //  Close this SubscriptionScreen if it was pushed via Navigator
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }

                              //  Now use go_router to show ShopsDetails
                              router.goNamed(
                                AppRoutes.shopsDetails,
                                extra: {
                                  'backDisabled': false,
                                  'fromSubscriptionSkip': true,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.silverGray),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue as Free',
                                      style: AppTextStyles.mulish(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Image.asset(
                                      AppImages.rightStickArrow,
                                      height: 20,
                                      width: 17,
                                      color: AppColor.darkBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),

              // SizedBox(
              //   height: 90,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       vertical: 8.0,
              //       horizontal: 5,
              //     ),
              //     child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: planAmount?.length ?? 0,
              //       itemBuilder: (context, index) {
              //         final data = planAmount?[index];
              //         return Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 5),
              //           child: _BillingChip(
              //             labelTop: 'ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¹ ${data?.price}',
              //             labelBottom: data?.type.toString() ?? '',
              //             selected: _selectedBilling == 0,
              //             onTap: () {},
              //             highlight: true,
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 5,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: planAmount?.length ?? 0,
                    itemBuilder: (context, index) {
                      final data = planAmount![index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _BillingOptions(
                          index: index, // ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ add this
                          price: data.price.toString(),

                          type: data.type
                              .toString(), // better: show duration text
                          selectedIndex: _selectedBilling,
                          onChanged: (i) => setState(() {
                            _selectedBilling = i;
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0797FD),
                        Color(0xFF07C8FD),
                        Color(0xFF0797FD),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: state.isInsertLoading
                        ? null
                        : () async {
                            if (planAmount == null || planAmount.isEmpty)
                              return;

                            final selectedPlan = planAmount[_selectedBilling];
                            final planId = selectedPlan.id.toString();

                            debugPrint('Selected planId: $planId');

                            await ref
                                .read(subscriptionNotifier.notifier)
                                .purchasePlan(
                                  planId: planId,
                                  businessProfileId: '',
                                );

                            final subState = ref.read(subscriptionNotifier);

                            // ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ SUCCESS ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ navigate
                            if (subState.purchaseResponse != null &&
                                subState.purchaseResponse!.status == true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaySuccessAndCancel(
                                    tittle:
                                        subState
                                            .purchaseResponse
                                            ?.data
                                            .plan
                                            .durationLabel
                                            .toString() ??
                                        '',
                                    planId: planId,
                                    startAt:
                                        subState
                                            .purchaseResponse
                                            ?.data
                                            .period
                                            .startsAtLabel
                                            .toString() ??
                                        '',
                                    endsAt:
                                        subState
                                            .purchaseResponse
                                            ?.data
                                            .period
                                            .endsAtLabel
                                            .toString() ??
                                        '',
                                  ),
                                ),
                              );
                              ref
                                  .watch(subscriptionNotifier.notifier)
                                  .getCurrentPlan();
                            } else {
                              showTopSnackBar(
                                context,
                                CustomSnackBar.error(
                                  message:
                                      subState.error ?? "Something went wrong",
                                ),
                              );
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        state.isInsertLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Pay for Premium',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                        SizedBox(width: 10),
                        state.isInsertLoading
                            ? SizedBox.shrink()
                            : Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

void showTopSnackBar(
  BuildContext context,
  Widget snackBar, {
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Material(color: Colors.transparent, child: snackBar),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

class _ComparisonCard extends StatelessWidget {
  final List<PlanFeature> features;

  const _ComparisonCard({required this.features});

  @override
  Widget build(BuildContext context) {
    const premiumGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0797FD), Color(0xFF07C8FD), Color(0xFF0797FD)],
    );

    final List<({String text, bool free, bool premium})> uiFeatures;
    if (features.isNotEmpty) {
      final sorted = [...features]..sort((a, b) => a.sort.compareTo(b.sort));
      uiFeatures = sorted
          .where((f) => f.label.trim().isNotEmpty)
          .map((f) => (text: _cleanFeatureText(f.label), free: f.free, premium: f.premium))
          .toList();
    } else {
      uiFeatures = const <({String text, bool free, bool premium})>[
        (text: "Limited visibility (5 km only)", free: true, premium: false),
        (text: "Only 3 leads per month", free: true, premium: false),
        (text: "Miss many customers", free: true, premium: false),
        (text: "No priority listing", free: true, premium: false),
        (text: "Reach entire district", free: false, premium: true),
        (text: "Reply to 10 leads daily", free: false, premium: true),
        (text: "Get priority in search", free: false, premium: true),
        (text: "Place ads in Caller ID (100+ users/month)", free: false, premium: true),
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white, // your container color stays
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              spreadRadius: 12,
              color: Colors.black.withOpacity(.05),
              blurRadius: 25,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: Text("")),
                    Expanded(
                      flex: 1,
                      child: Container(color: AppColor.textWhite),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: premiumGradient,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: const [
                        Expanded(flex: 3, child: Text("")),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              "Free",
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "Premium",
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...uiFeatures.map(
                      (f) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              f.text,
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: f.free ? star(color: AppColor.skyBlue) : const SizedBox.shrink(),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: f.premium ? star(color: AppColor.white) : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _cleanFeatureText(String input) {
  var s = input.trim();
  if (s.isEmpty) return s;

  // Remove leading bullets/symbols
  s = s.replaceFirst(RegExp(r'^[\u2022Ã¢â‚¬Â¢\-Ã¢â‚¬â€œÃ¢â‚¬â€\*]+\s*'), '');

  // Remove leading list markers like "1.", "1)", "a.", "a,", "1 -"
  s = s.replaceFirst(RegExp(r'^([0-9]{1,3}|[a-zA-Z])\s*[\)\.\-:,]\s*'), '');
  s = s.replaceFirst(RegExp(r'^([0-9]{1,3}|[a-zA-Z])\s+\)\s*'), '');

  return s.trim();
}

Widget star({Color? color = AppColor.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Icon(Icons.star_rounded, color: color),
  );
}

class _BillingOptions extends StatelessWidget {
  const _BillingOptions({
    required this.index,
    required this.selectedIndex,
    required this.type,
    required this.onChanged,
    required this.price,
  });

  final int index; // ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ current item index
  final int selectedIndex; // ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ selected index in parent
  final ValueChanged<int> onChanged;

  final String type;
  final String price;

  @override
  Widget build(BuildContext context) {
    return _BillingChip(
      labelTop: '\u20B9 $price',
      labelBottom: type,
      selected: selectedIndex == index, // ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ compare with index
      onTap: () => onChanged(index), // ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ send index
      highlight: index == 0, // optional
    );
  }
}

class _BillingChip extends StatelessWidget {
  const _BillingChip({
    required this.labelTop,
    required this.labelBottom,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String labelTop;

  final String labelBottom;
  final bool selected;
  final bool highlight;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? const Color(0xFF0797FD) : const Color(0xFFFFFFFF);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labelTop,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: selected ? const Color(0xff0797FD) : AppColor.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              labelBottom,

              style: AppTextStyles.mulish(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppColor.darkBlue : AppColor.gray84,
              ),
              // style: TextStyle(
              //   fontSize: 12,
              //   color: selected ? AppColor.darkBlue : AppColor.gray84,
              // ),
            ),
          ],
        ),
      ),
    );
  }
}

/// old///
//   Scaffold(
//   backgroundColor: Color(0xFFF3F3F3),
//   body: SafeArea(
//     child: ConstrainedBox(
//       constraints: const BoxConstraints(maxWidth: 420),
//       child: ListView(
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 13),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColor.border),
//                     shape: BoxShape.circle,
//                     color: AppColor.white,
//                   ),
//                   child: Image.asset(
//                     AppImages.leftArrow,
//                     height: 15,
//                     color: AppColor.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Image.asset(
//                 AppImages.crown,
//                 height: 105,
//                 fit: BoxFit.contain,
//               ),
//                SizedBox(height: 10),
//               Text(
//                 "Unlock the TringoÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢s",
//                 style: AppTextStyles.mulish(fontSize: 22),
//               ),
//               Text(
//                 "Super Power",
//                 style: AppTextStyles.mulish(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//                SizedBox(height: 20),
//               _ComparisonCard(),
//
//                SizedBox(height: 20),
//               Center(
//                 child: Text(
//                   'Cancel Subscription Any time',
//                   style: AppTextStyles.mulish(color: AppColor.darkGrey),
//                 ),
//               ),
//                SizedBox(height: 30),
//
//               // Billing options
//               _BillingOptions(
//                 selected: _selectedBilling,
//                 onChanged: (i) => setState(() => _selectedBilling = i),
//               ),
//
//               const SizedBox(height: 16),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 5),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF0797FD),
//                         Color(0xFF07C8FD),
//                         Color(0xFF0797FD),
//                       ],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SubscriptionHistory(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor:
//                           Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 14,
//                         horizontal: 40,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Get Super Power Now',
//                           style: AppTextStyles.mulish(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Icon(
//                           Icons.arrow_forward_rounded,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ),
// );
