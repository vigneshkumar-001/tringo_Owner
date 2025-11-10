import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';

import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Menu/Screens/menu_screens.dart';

class EnquiryScreens extends StatefulWidget {
  const EnquiryScreens({super.key});

  @override
  State<EnquiryScreens> createState() => _EnquiryScreensState();
}

class _EnquiryScreensState extends State<EnquiryScreens> {
  int selectedIndex = 0; // 0 = Unanswered, 1 = Answered

  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';
  final GlobalKey _filterKey = GlobalKey();

  String _fmt(DateTime d) =>
      DateFormat('dd MMM yyyy').format(d); // e.g., 23 Sep 2025

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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
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
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuScreens(),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: SizedBox(
                              height: 52,
                              width: 52,
                              child: Image.asset(AppImages.profile),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      CommonContainer.smallShopContainer(
                        shopImage: AppImages.pothys,
                        shopLocation: '12, 2, Tirupparankunram Rd, kunram ',
                        shopName: 'Shop 1',
                      ),
                      SizedBox(width: 8),
                      CommonContainer.smallShopContainer(
                        shopImage: AppImages.pothys,
                        shopLocation: '12, 2, Tirupparankunram Rd, kunram ',
                        shopName: 'Shop 1',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enquiries',
                        style: AppTextStyles.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            backgroundColor: AppColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Select Date',
                                          style: AppTextStyles.mulish(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.mistyRose,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 17,
                                                    vertical: 10,
                                                  ),
                                              child: Icon(
                                                size: 16,
                                                Icons.close,
                                                color: AppColor.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    CommonContainer.horizonalDivider(),
                                    ListTile(
                                      title: Text(
                                        'Today',
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      onTap: () =>
                                          Navigator.pop(context, 'Today'),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Yesterday',
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      onTap: () =>
                                          Navigator.pop(context, 'Yesterday'),
                                      // trailing: GestureDetector(
                                      //   onTap: () =>
                                      //       Navigator.pop(context, 'Yesterday'),
                                      //   child: Container(
                                      //     decoration: BoxDecoration(
                                      //       color: AppColor.iceBlue,
                                      //       borderRadius: BorderRadius.circular(
                                      //         25,
                                      //       ),
                                      //     ),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.symmetric(
                                      //         horizontal: 17,
                                      //         vertical: 10,
                                      //       ),
                                      //       child: Image.asset(
                                      //         AppImages.rightArrow,
                                      //         height: 13,color: AppColor.skyBlue,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Custom Date',
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                dialogBackgroundColor:
                                                    AppColor.white,
                                                colorScheme: ColorScheme.light(
                                                  primary: AppColor.brightBlue,
                                                  onPrimary: Colors.white,
                                                  onSurface: AppColor.black,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                AppColor
                                                                    .brightBlue,
                                                          ),
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (picked != null) {
                                          setState(() {
                                            selectedDate = picked;
                                            selectedDay = _fmt(picked);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          if (selected == 'Today') {
                            setState(() {
                              selectedDay = 'Today';
                              selectedDate = DateTime.now();
                            });
                          } else if (selected == 'Yesterday') {
                            setState(() {
                              selectedDay = 'Yesterday';
                              selectedDate = DateTime.now().subtract(
                                const Duration(days: 1),
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.iceBlue,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset(AppImages.filter, height: 19),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
