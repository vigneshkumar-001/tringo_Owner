import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Utility/app_snackbar.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';

// ✅ add: import your wallet notifier
import '../Controller/wallet_notifier.dart'; // <-- adjust path if different

class ReceiveScreen extends ConsumerStatefulWidget {
  final String toUid;
  final String amount;

  const ReceiveScreen({super.key, required this.toUid, required this.amount});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ✅ QR format (you can change this)
  String get _qrData {
    final uid = widget.toUid.trim();
    final amt = widget.amount.trim();

    return uid;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // ✅ CALL API ON LOAD
    Future.microtask(() {
      ref.read(walletNotifier.notifier).walletQrCode();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Copied: $text")));
  }

  // ✅ NEW: build QR widget from URL (fallback to generated QR)
  Widget _buildQrWidget({required String? qrImageUrl}) {
    final url = (qrImageUrl ?? '').trim();

    // If API url available -> show image
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 210,
          height: 210,
          fit: BoxFit.contain,
          // ✅ optional loading
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 210,
              height: 210,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColor.black,
                  backgroundColor: AppColor.white.withOpacity(0.15),
                  value: loadingProgress.expectedTotalBytes != null
                      ? (loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1))
                      : null,
                ),
              ),
            );
          },
          // ✅ if URL broken -> fallback to generated QR
          errorBuilder: (_, __, ___) {
            return QrImageView(
              data: _qrData,
              size: 210,
              backgroundColor: Colors.white,
            );
          },
        ),
      );
    }

    // URL not available -> fallback generated QR
    return QrImageView(data: _qrData, size: 210, backgroundColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.toUid.trim();
    final amt = widget.amount.trim();

    // ✅ watch wallet state
    final wState = ref.watch(walletNotifier);
    final qrUrl = wState.walletQrResponse?.data.qrImageUrl;

    return Scaffold(
      backgroundColor: AppColor.border,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.leftSideArrow(
                        Color: AppColor.border,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Receive TCoin',
                      style: AppTextStyles.mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 43),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 45,
                    ),
                    child: Column(
                      children: [
                        // ✅ SHOW qrImageUrl IMAGE HERE (fallback to QrImageView)
                        _buildQrWidget(qrImageUrl: qrUrl),

                        const SizedBox(height: 20),

                        Text(
                          'Scan QR',
                          style: AppTextStyles.mulish(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColor.darkBlue,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '( or )',
                          style: AppTextStyles.mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.borderLightGrey,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ✅ UID
                        Text(
                          'Send To UID',
                          style: AppTextStyles.mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.skyBlue,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              uid.isEmpty ? "—" : uid,
                              style: AppTextStyles.mulish(
                                fontSize: 13,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                final uid = widget.toUid.trim();
                                if (uid.isEmpty) return;
                                await Clipboard.setData(
                                  ClipboardData(text: uid),
                                );
                                if (!mounted) return;
                                AppSnackBar.success(
                                  context,
                                  "UID copied: $uid",
                                );
                              },
                              child: Image.asset(AppImages.uIDBlue, height: 14),
                            ),
                          ],
                        ),

                        // // ✅ optional: show API error
                        // if ((wState.error ?? '').isNotEmpty) ...[
                        //   const SizedBox(height: 12),
                        //   Text(
                        //     wState.error!,
                        //     style: GoogleFont.Mulish(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w600,
                        //       color: Colors.red,
                        //     ),
                        //     textAlign: TextAlign.center,
                        //   ),
                        // ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
