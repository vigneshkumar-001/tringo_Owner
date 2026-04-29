import 'package:flutter/material.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';

enum PaymentResultType { cancelled, failed }

class PaymentResultDialog extends StatelessWidget {
  final PaymentResultType type;
  final String message;
  final VoidCallback? onRetry;

  const PaymentResultDialog({
    super.key,
    required this.type,
    required this.message,
    this.onRetry,
  });

  static Future<void> show(
    BuildContext context, {
    required PaymentResultType type,
    String? message,
    VoidCallback? onRetry,
  }) {
    final defaultMessage =
        type == PaymentResultType.cancelled
            ? 'Your payment was cancelled. You can try again anytime.'
            : 'Your payment failed. Please try again.';

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'payment_result',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return Center(
          child: PaymentResultDialog(
            type: type,
            message: (message ?? '').trim().isEmpty
                ? defaultMessage
                : message!.trim(),
            onRetry: onRetry,
          ),
        );
      },
      transitionBuilder: (context, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = type == PaymentResultType.cancelled;
    final title = isCancelled ? 'Payment Cancelled' : 'Payment Failed';
    final accent = isCancelled ? AppColor.yellow : AppColor.red1;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCancelled
                          ? Icons.close_rounded
                          : Icons.error_outline_rounded,
                      color: accent,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColor.mildBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColor.borderLightGrey),
                            ),
                            child: Text(
                              'Close',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.mulish(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColor.mildBlack,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.of(context).pop();
                            onRetry?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColor.blueGradient1, AppColor.blueGradient2],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.rightStickArrow,
                                  height: 18,
                                  width: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Try again',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.mulish(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
