import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';

import '../../../Core/Widgets/qr_scanner_page.dart';

class EnquiryScreens extends StatefulWidget {
  const EnquiryScreens({super.key});

  @override
  State<EnquiryScreens> createState() => _EnquiryScreensState();
}

class _EnquiryScreensState extends State<EnquiryScreens> {
  int selectedIndex = 0; // 0 = Unanswered, 1 = Answered

  Future<void> _openQrScanner() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerPage()),
      );

      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _openQrScanner,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.shadowBlue,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(AppImages.qr_code, height: 23),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Text(
                            'Pothys Textiles',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Textiles & Readymade',
                            style: AppTextStyles.mulish(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColor.gray84,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Image.asset(AppImages.profile, height: 52),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      CommonContainer.smallShopContainer(
                        shopImage: AppImages.pothys,
                        shopLocation: '12, 2, Tirupparankunram Rd, kunram ',
                        shopName: 'Shop 1',
                      ),
                      CommonContainer.smallShopContainer(
                        shopImage: AppImages.pothys,
                        shopLocation: '12, 2, Tirupparankunram Rd, kunram ',
                        shopName: 'Shop 1',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enquiries',
                      style: AppTextStyles.mulish(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.iceBlue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(AppImages.filter, height: 19),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: selectedIndex == 0
                                  ? AppColor.black
                                  : AppColor.borderLightGrey,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '10 Unanswered',
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? AppColor.black
                                    : AppColor.borderLightGrey,
                                fontWeight: selectedIndex == 0
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: selectedIndex == 1
                                  ? AppColor.black
                                  : AppColor.borderLightGrey,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '50 Answered',
                              style: TextStyle(
                                color: selectedIndex == 1
                                    ? AppColor.black
                                    : AppColor.borderLightGrey,
                                fontWeight: selectedIndex == 1
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Today',
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    color: AppColor.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),

                CommonContainer.inquiryProductCard(
                  questionText:
                      'Is Samsung s24fe white color available?\nIf it is i need best price',
                  productTitle: 'Samsung s24fe ( 258GB 8GB )',
                  rating: '4.5',
                  ratingCount: '16',
                  priceText: '₹29,999',
                  mrpText: '₹36,999',
                  phoneImageAsset: AppImages.phone,
                  avatarAsset: AppImages.profile,
                  customerName: 'Ganeshan Kandhasa...',
                  timeText: '10.40Pm',
                  onChatTap: () {},
                ),
                SizedBox(height: 20),

                CommonContainer.inquiryProductCard(
                  isAds: true,
                  questionText:
                      'Is Samsung s24fe white color available?\nIf it is i need best price',
                  productTitle: 'Samsung s24fe ( 258GB 8GB )',
                  rating: '4.5',
                  ratingCount: '16',
                  priceText: '₹29,999',
                  mrpText: '₹36,999',
                  phoneImageAsset: AppImages.fan,
                  avatarAsset: AppImages.profile,
                  customerName: 'Ganeshan Kandhasa',
                  timeText: '10.40Pm',
                  onChatTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
