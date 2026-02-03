import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';

import 'package:tringo_vendor/Presentation/Home/Controller/home_notifier.dart';
import 'package:tringo_vendor/Presentation/Home/Controller/shopContext_provider.dart';
import 'package:tringo_vendor/Presentation/Menu/Controller/subscripe_notifier.dart';

class QrCodeScreen extends ConsumerStatefulWidget {
  final String? shopId;
  const QrCodeScreen({super.key, this.shopId});

  @override
  ConsumerState<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  bool _calledOnce = false;

  // ✅ avoid multiple calls (init + refresh + retry spam)
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadQr();
    });
  }

  Future<String> _resolveShopId() async {
    final passed = (widget.shopId ?? '').trim();
    if (passed.isNotEmpty) return passed;

    final home = ref.read(homeNotifierProvider);
    final shopsRes = home.shopsResponse;
    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];

    if (shops.isEmpty) {
      await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
    }

    final home2 = ref.read(homeNotifierProvider);
    final shopsRes2 = home2.shopsResponse;
    final List<dynamic> shops2 =
        (shopsRes2?.data.items as List?)?.toList() ?? <dynamic>[];

    final selected = ref.read(selectedShopProvider)?.toString().trim() ?? '';
    if (selected.isNotEmpty) return selected;

    if (shops2.isNotEmpty) {
      final sid = (shops2.first.id ?? '').toString().trim();
      return sid;
    }

    return '';
  }

  Future<void> _loadQr() async {
    if (_loading) return;
    _loading = true;

    try {
      final shopId = await _resolveShopId();
      if (!mounted) return;

      if (shopId.isEmpty) {
        AppSnackBar.error(context, "Shop not found");
        return;
      }

      await ref.read(subscriptionNotifier.notifier).shopQrCode(shopId: shopId);

      if (!mounted) return;
      setState(() {
        _calledOnce = true;
      });
    } finally {
      _loading = false;
    }
  }

  Future<void> _downloadPdf(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppSnackBar.error(context, "Invalid download url");
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      AppSnackBar.error(context, "Unable to download");
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionNotifier);

    final isLoading = subState.isInsertLoading == true;
    final error = (subState.error ?? '').trim();

    final qr = subState.qrActionResponse?.data;
    final qrImageUrl = (qr?.qrImageUrl ?? '').trim();
    final downloadUrl = (qr?.downloadUrl ?? '').trim();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadQr,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            children: [
              Row(
                children: [
                  CommonContainer.topLeftArrow(
                    isMenu: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: Text(
                        "QR Code",
                        style: AppTextStyles.mulish(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColor.darkBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              if (isLoading) ...[
                const SizedBox(height: 100),
                Center(
                  child: CircularProgressIndicator(color: AppColor.darkBlue),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Loading QR...",
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
              ] else if (error.isNotEmpty) ...[
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    error,
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _loadQr,
                    child: const Text("Retry"),
                  ),
                ),
              ] else if (qr == null && !_calledOnce) ...[
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Tap to load QR",
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _loadQr,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Load QR"),
                  ),
                ),
              ] else if (qrImageUrl.isEmpty) ...[
                const SizedBox(height: 70),
                Center(
                  child: Text(
                    "QR not available",
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _loadQr,
                    child: const Text("Refresh"),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.brightGray,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Scan this QR",
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(14),
                            child: Image.network(
                              qrImageUrl,
                              height: 260,
                              width: 260,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => SizedBox(
                                height: 260,
                                width: 260,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.qrCodeLogo,
                                      height: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Image failed",
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Use Download button to save PDF",
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                CommonContainer.button(
                  onTap:
                  (downloadUrl.isNotEmpty) ? () => _downloadPdf(downloadUrl) : null,
                  text: Text(
                    "Download QR Code",
                    style: AppTextStyles.mulish(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  buttonColor: AppColor.darkBlue,
                  borderColor: AppColor.darkBlue,
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'package:tringo_vendor/Core/Const/app_color.dart';
// import 'package:tringo_vendor/Core/Const/app_images.dart';
// import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
// import 'package:tringo_vendor/Core/Utility/common_Container.dart';
// import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
//
// import 'package:tringo_vendor/Presentation/Home/Controller/home_notifier.dart';
// import 'package:tringo_vendor/Presentation/Home/Controller/shopContext_provider.dart';
// import 'package:tringo_vendor/Presentation/Menu/Controller/subscripe_notifier.dart';
//
// class QrCodeScreen extends ConsumerStatefulWidget {
//   final String? shopId;
//   const QrCodeScreen({super.key,this.shopId});
//
//   @override
//   ConsumerState<QrCodeScreen> createState() => _QrCodeScreenState();
// }
//
// class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
//   bool _calledOnce = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadQr();
//     });
//   }
//
//   Future<String> _resolveShopId() async {
//     // ✅ 0) if menu passed shopId
//     final passed = (widget.shopId ?? '').trim();
//     if (passed.isNotEmpty) return passed;
//
//     // ✅ ensure shops loaded
//     final home = ref.read(homeNotifierProvider);
//     final shopsRes = home.shopsResponse;
//     final List<dynamic> shops =
//         (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
//
//     if (shops.isEmpty) {
//       await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
//     }
//
//     final home2 = ref.read(homeNotifierProvider);
//     final shopsRes2 = home2.shopsResponse;
//     final List<dynamic> shops2 =
//         (shopsRes2?.data.items as List?)?.toList() ?? <dynamic>[];
//
//     // 1) selected shop
//     final selected = ref.read(selectedShopProvider)?.toString().trim() ?? '';
//     if (selected.isNotEmpty) return selected;
//
//     // 2) first shop
//     if (shops2.isNotEmpty) {
//       final sid = (shops2.first.id ?? '').toString().trim();
//       return sid;
//     }
//
//     return '';
//   }
//
//
//   Future<void> _loadQr() async {
//     final shopId = await _resolveShopId();
//
//     if (!mounted) return;
//
//     if (shopId.isEmpty) {
//       AppSnackBar.error(context, "Shop not found");
//       return;
//     }
//
//     await ref.read(subscriptionNotifier.notifier).shopQrCode(shopId: shopId);
//     _calledOnce = true;
//   }
//
//   Future<void> _downloadPdf(String url) async {
//     final uri = Uri.tryParse(url);
//     if (uri == null) {
//       AppSnackBar.error(context, "Invalid download url");
//       return;
//     }
//
//     final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
//     if (!ok && mounted) {
//       AppSnackBar.error(context, "Unable to download");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final subState = ref.watch(subscriptionNotifier);
//
//     final isLoading = subState.isInsertLoading == true;
//     final error = (subState.error ?? '').trim();
//
//     final qr = subState.qrActionResponse?.data;
//     final qrImageUrl = (qr?.qrImageUrl ?? '').trim();
//     final downloadUrl = (qr?.downloadUrl ?? '').trim();
//
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _loadQr,
//           child: ListView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//             children: [
//               // ✅ Top row: back + title + download
//               Row(
//                 children: [
//                   CommonContainer.topLeftArrow(
//                     isMenu: false,
//                     onTap: () => Navigator.pop(context),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         "QR Code",
//                         style: AppTextStyles.mulish(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // // ✅ Download icon (top-right)
//                   // InkWell(
//                   //   onTap: (downloadUrl.isNotEmpty && !isLoading)
//                   //       ? () => _downloadPdf(downloadUrl)
//                   //       : null,
//                   //   borderRadius: BorderRadius.circular(14),
//                   //   child: Opacity(
//                   //     opacity: (downloadUrl.isNotEmpty && !isLoading)
//                   //         ? 1.0
//                   //         : 0.35,
//                   //     child: Container(
//                   //       padding: const EdgeInsets.all(12),
//                   //       decoration: BoxDecoration(
//                   //         color: AppColor.brightGray,
//                   //         borderRadius: BorderRadius.circular(14),
//                   //       ),
//                   //       child: const Icon(
//                   //         Icons.download_rounded,
//                   //         size: 22,
//                   //         color: Colors.black,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//
//               const SizedBox(height: 30),
//
//               // ✅ states
//               if (isLoading) ...[
//                 const SizedBox(height: 100),
//                 Center(
//                   child: CircularProgressIndicator(color: AppColor.darkBlue),
//                 ),
//                 const SizedBox(height: 30),
//                 Center(
//                   child: Text(
//                     "Loading QR...",
//                     style: AppTextStyles.mulish(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: AppColor.darkGrey,
//                     ),
//                   ),
//                 ),
//               ] else if (error.isNotEmpty) ...[
//                 const SizedBox(height: 40),
//                 Center(
//                   child: Text(
//                     error,
//                     style: AppTextStyles.mulish(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.red,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: TextButton(
//                     onPressed: _loadQr,
//                     child: const Text("Retry"),
//                   ),
//                 ),
//               ] else if (qr == null && !_calledOnce) ...[
//                 const SizedBox(height: 40),
//                 Center(
//                   child: Text(
//                     "Tap to load QR",
//                     style: AppTextStyles.mulish(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: AppColor.darkGrey,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _loadQr,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.darkBlue,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text("Load QR"),
//                   ),
//                 ),
//               ] else if (qrImageUrl.isEmpty) ...[
//                 const SizedBox(height: 70),
//                 Center(
//                   child: Text(
//                     "QR not available",
//                     style: AppTextStyles.mulish(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: AppColor.darkGrey,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: TextButton(
//                     onPressed: _loadQr,
//                     child: const Text("Refresh"),
//                   ),
//                 ),
//               ] else ...[
//                 // ✅ QR center card (design neat)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 18,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColor.brightGray,
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "Scan this QR",
//                         style: AppTextStyles.mulish(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//
//                       // ✅ QR image in center
//                       Center(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(18),
//                           child: Container(
//                             color: Colors.white,
//                             padding: const EdgeInsets.all(14),
//                             child: Image.network(
//                               qrImageUrl,
//                               height: 260,
//                               width: 260,
//                               fit: BoxFit.contain,
//                               errorBuilder: (_, __, ___) => SizedBox(
//                                 height: 260,
//                                 width: 260,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Image.asset(
//                                       AppImages.qrCodeLogo,
//                                       height: 40,
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Text(
//                                       "Image failed",
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w700,
//                                         color: AppColor.darkGrey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       Text(
//                         "Use Download button to save PDF",
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: AppColor.darkGrey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // ✅ bottom download button also (optional)
//                 CommonContainer.button(
//                   onTap: (downloadUrl.isNotEmpty)
//                       ? () => _downloadPdf(downloadUrl)
//                       : null,
//                   text: Text(
//                     "Download QR Code",
//                     style: AppTextStyles.mulish(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 16,
//                     ),
//                   ),
//                   buttonColor: AppColor.darkBlue,
//                   borderColor: AppColor.darkBlue,
//                 ),
//               ],
//
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
