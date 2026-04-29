import 'package:flutter/material.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';

import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import 'subscription_screen.dart';

class SubscriptionHistory extends StatefulWidget {
  final String titlePlan;
  final String fromDate;
  final String toDate;
  final VoidCallback? onDownloadInvoice;
  final VoidCallback? onCancelSubscription;
  final VoidCallback? onExtendPlan;
  const SubscriptionHistory({
    super.key,
    required this.titlePlan,
    required this.fromDate,
    required this.toDate,
    this.onDownloadInvoice,
    this.onCancelSubscription,
    this.onExtendPlan,
  });

  @override
  State<SubscriptionHistory> createState() => _SubscriptionHistoryState();
}

class _SubscriptionHistoryState extends State<SubscriptionHistory> {
  void _showInfoSnack(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _downloadInvoice() {
    if (widget.onDownloadInvoice != null) {
      widget.onDownloadInvoice!.call();
      return;
    }
    _showInfoSnack('Download invoice is not connected yet.');
  }

  void _extendPlan() {
    if (widget.onExtendPlan != null) {
      widget.onExtendPlan!.call();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionScreen()),
    );
  }

  Future<void> _confirmCancelSubscription() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColor.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Cancel subscription',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColor.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'You can extend your plan anytime. Cancelling will stop renewal for this plan.',
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.gray84,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.red1.withAlpha(64)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColor.red1.withAlpha(31),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: AppColor.red1,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan: ${widget.titlePlan}',
                              style: AppTextStyles.mulish(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColor.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paid on ${widget.fromDate} • Expires on ${widget.toDate}',
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColor.gray84,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColor.border),
                          ),
                          child: Center(
                            child: Text(
                              'Keep Subscription',
                              style: AppTextStyles.mulish(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColor.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.red1,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel Now',
                              style: AppTextStyles.mulish(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColor.white,
                              ),
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

    if (ok != true) return;

    if (widget.onCancelSubscription != null) {
      widget.onCancelSubscription!.call();
      return;
    }

    _showInfoSnack('Cancel subscription is not connected yet.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 15),
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
                        border: Border.all(color: AppColor.border),
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
                ],
              ),
              SizedBox(height: 30),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Subscription ',
                      style: AppTextStyles.mulish(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: 'History',
                      style: AppTextStyles.mulish(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.titlePlan} Plan',
                                    style: AppTextStyles.mulish(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Paid on ',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.fromDate,
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Expires on ',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.toDate,
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right side image
                            Image.asset(AppImages.crown, height: 90),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _downloadInvoice,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.downLoad, height: 18),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Download Invoice',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                         
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _extendPlan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppColor.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.autorenew,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Extend My Plan',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                           const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _confirmCancelSubscription,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.red1,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AppImages.closeImage,
                                    height: 18,
                                    color: AppColor.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Cancel Subscription',
                                    style: AppTextStyles.mulish(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        CommonContainer.horizonalDivider(isSubscription: true),
                        SizedBox(height: 20),
                        Text(
                          "Premium Tringo's Features",
                          style: AppTextStyles.mulish(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20),
                        const _ComparisonCard(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    const premiumGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0797FD), Color(0xFF07C8FD), Color(0xFF0797FD)],
    );

    // text + availability in Free
    const features = <({String text, bool premium})>[
      (text: 'Search engine visibility upto 5km', premium: true),
      (text: 'Unlimited Reply in Smart Connect', premium: true),
      (text: 'Reach your entire district', premium: true),
      (text: 'Search engine priority', premium: true),
      (text: 'Place 2 ads per month', premium: true),
      (text: 'Get Trusted Batch to gain clients', premium: true),
      (text: 'View Followers Picture', premium: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
              // Background bands (left = cardColor shows; middle = Free; right = Premium gradient)
              // Make backgrounds fill the card area
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('')),
                    // Free
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: Text('')),

                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              'Premium',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    ...features.map(
                      (f) => Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                f.text,
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: f.premium
                                  ? star(color: AppColor.white)
                                  : const SizedBox.shrink(),
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

///new
// class _ComparisonCard extends StatelessWidget {
//   const _ComparisonCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     const premiumGradient = LinearGradient(
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//       colors: [Color(0xFF0797FD), Color(0xFF07C8FD), Color(0xFF0797FD)],
//     );
//
//     const features = <({String text, bool premium})>[
//       (text: 'Search engine visibility upto 5km', premium: true),
//       (text: 'Unlimited Reply in Smart Connect', premium: true),
//       (text: 'Reach your entire district', premium: true),
//       (text: 'Search engine priority', premium: true),
//       (text: 'Place 2 ads per month', premium: true),
//       (text: 'Get Trusted Batch to gain clients', premium: true),
//       (text: 'View Followers Picture', premium: true),
//     ];
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 3,
//             blurRadius: 10,
//             offset: const Offset(2, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left side: feature texts
//           Expanded(
//             flex: 3,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: features
//                     .map(
//                       (f) => Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         child: Text(
//                           f.text,
//                           style: AppTextStyles.mulish(
//                             color: AppColor.darkBlue,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//
//           // Right side: premium column
//           Expanded(
//             flex: 2,
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: premiumGradient,
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(18),
//                   bottomRight: Radius.circular(18),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Premium',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     ...features.map(
//                       (f) => Padding(
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                         child: Icon(Icons.star, color: Colors.white, size: 18),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

Widget star({Color? color = AppColor.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Icon(Icons.star_rounded, color: color),
  );
}
