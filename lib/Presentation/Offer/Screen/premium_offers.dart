import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Menu/Screens/menu_screens.dart';

class PremiumOffers extends StatefulWidget {
  const PremiumOffers({super.key});

  @override
  State<PremiumOffers> createState() => _PremiumOffersState();
}

class _PremiumOffersState extends State<PremiumOffers> {
  bool isSurpriseSelected = true;
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';

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
    final Color surpriseBg1 = AppColor.teaGreen;
    final Color appBg1 = AppColor.lightApricot;
    final Color white = AppColor.white;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _openQrScanner,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.shadowBlue,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(AppImages.qr_code, height: 23),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Pothys Textiles',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Textiles & Readymade',
                          style: AppTextStyles.mulish(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColor.gray84,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MenuScreens()),
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
                ],
              ),
            ),

            // Gradient background area
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  topLeft: Radius.circular(25),
                ),
                gradient: LinearGradient(
                  colors: isSurpriseSelected
                      ? [surpriseBg1, white]
                      : [appBg1, white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offers',
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => isSurpriseSelected = true);
                          },
                          child: OfferCard(
                            title: "Surprise Offers",
                            image: isSurpriseSelected
                                ? AppImages.surprise
                                : AppImages.blackSurprise,
                            active: isSurpriseSelected,
                            horizontalPadding: 50,
                            activeColor: AppColor.deepForestGreen,
                            inactiveColor: AppColor.black.withOpacity(0.03),
                            textColor: isSurpriseSelected
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() => isSurpriseSelected = false);
                          },
                          child: OfferCard(
                            title: "App Offers",
                            image: isSurpriseSelected
                                ? AppImages.blackAppOffers
                                : AppImages.appOffer,
                            active: !isSurpriseSelected,
                            horizontalPadding: 28,
                            activeColor: AppColor.darkCoffee,
                            inactiveColor: AppColor.black.withOpacity(0.03),
                            textColor: !isSurpriseSelected
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Offer Design Switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isSurpriseSelected
                  ? SurpriseOffersDesign()
                  : AppOffersDesign(),
            ),
          ],
        ),
      ),
    );
  }

  Widget SurpriseOffersDesign() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'History',
                  style: AppTextStyles.mulish(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Create',
                  style: AppTextStyles.mulish(color: AppColor.white),
                ),
              ),
              SizedBox(width: 15),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
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
                              onTap: () => Navigator.pop(context, 'Today'),
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
                              onTap: () => Navigator.pop(context, 'Yesterday'),
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
                                        dialogBackgroundColor: AppColor.white,
                                        colorScheme: ColorScheme.light(
                                          primary: AppColor.brightBlue,
                                          onPrimary: Colors.white,
                                          onSurface: AppColor.black,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColor.brightBlue,
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
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 10,
              //     vertical: 8,
              //   ),
              //   decoration: BoxDecoration(
              //     color: AppColor.iceBlue,
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   child: Image.asset(AppImages.filter, height: 19),
              // ),
            ],
          ),
          SizedBox(height: 22),
          Center(
            child: Text(
              'Yesterday',
              style: AppTextStyles.mulish(
                fontSize: 12,
                color: AppColor.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Offer History Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColor.ghostWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Diwali Offer',
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Mauris nulla magna, dignissim sit amet interdum eu, varius vel nisi.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DottedBorder(
                    color: AppColor.black.withOpacity(0.2),
                    strokeWidth: 1.2,
                    dashPattern: [2, 2],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      '10.40PM',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mulish(
                        fontSize: 12,
                        color: AppColor.gray84,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Clamied Coupon  ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.mulish(
                                color: AppColor.gray84,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '2',
                              style: AppTextStyles.mulish(
                                fontSize: 18,
                                color: AppColor.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: two texts stacked
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pending Coupon',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mulish(
                                    color: AppColor.gray84,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '26',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 15),

                            // RIGHT: image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColor.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.5),
                                child: Image.asset(
                                  AppImages.editImage,
                                  color: AppColor.black,
                                  width: 13,
                                  height: 13,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: two texts stacked
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Expire on',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mulish(
                                    color: AppColor.gray84,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '5 Aug 25',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 20),

                            // RIGHT: image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColor.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.5),
                                child: Image.asset(
                                  AppImages.editImage,
                                  color: AppColor.black,
                                  width: 13,
                                  height: 13,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '2 Claimed Coupons',
                    style: AppTextStyles.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                CommonContainer.couponsContainer(
                  customerName: 'Ambika Kumari ',
                  customerImage: AppImages.customerImage1,
                  timeAndDate: '10.02Am -18.07.25 ',
                  couponNumber: 'DFKO9G9',
                ),
                SizedBox(height: 10),
                CommonContainer.couponsContainer(
                  customerName: 'Kumaravel',
                  customerImage: AppImages.customerImage2,
                  timeAndDate: '10.02Am -18.07.25 ',
                  couponNumber: 'DFKOFGU',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget AppOffersDesign() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'History',
                  style: AppTextStyles.mulish(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Create',
                  style: AppTextStyles.mulish(color: AppColor.white),
                ),
              ),
              SizedBox(width: 15),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
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
                              onTap: () => Navigator.pop(context, 'Today'),
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
                              onTap: () => Navigator.pop(context, 'Yesterday'),
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
                                        dialogBackgroundColor: AppColor.white,
                                        colorScheme: ColorScheme.light(
                                          primary: AppColor.brightBlue,
                                          onPrimary: Colors.white,
                                          onSurface: AppColor.black,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColor.brightBlue,
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

              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 10,
              //     vertical: 8,
              //   ),
              //   decoration: BoxDecoration(
              //     color: AppColor.iceBlue,
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   child: Image.asset(AppImages.filter, height: 19),
              // ),
            ],
          ),

          SizedBox(height: 25),

          // Segmented toggles (Live / Expired)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selectedIndex == 0
                            ? AppColor.black
                            : AppColor.borderLightGrey,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '10 Live App Offers',
                        style: AppTextStyles.mulish(
                          color: selectedIndex == 0
                              ? AppColor.darkBlue
                              : AppColor.borderLightGrey,
                          fontWeight: selectedIndex == 0
                              ? FontWeight.w800
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selectedIndex == 1
                            ? AppColor.black
                            : AppColor.borderLightGrey,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '24 Expired App Offers',
                        style: AppTextStyles.mulish(
                          color: selectedIndex == 1
                              ? AppColor.darkBlue
                              : AppColor.borderLightGrey,
                          fontWeight: selectedIndex == 1
                              ? FontWeight.w800
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

          // Offer card
          Container(
            decoration: BoxDecoration(
              color: AppColor.floralWhite,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '10% App offer for diwali celebration',
                    style: AppTextStyles.mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
                SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DottedBorder(
                    color: AppColor.black.withOpacity(0.2),
                    strokeWidth: 1.2,
                    dashPattern: [2, 2],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(30),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      '10.40PM',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mulish(
                        fontSize: 12,
                        color: AppColor.gray84,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: two texts stacked
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Enquiries',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mulish(
                                    color: AppColor.gray84,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '10',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 20),

                            // RIGHT: image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColor.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.5),
                                child: Image.asset(
                                  AppImages.rightArrow,
                                  color: AppColor.black,
                                  width: 13,
                                  height: 13,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: two texts stacked
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Expires on',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mulish(
                                    color: AppColor.gray84,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '5 Aug 25',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 15),

                            // RIGHT: image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColor.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.5),
                                child: Image.asset(
                                  AppImages.editImage,
                                  color: AppColor.black,
                                  width: 13,
                                  height: 13,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: two texts stacked
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Types of Product',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mulish(
                                    color: AppColor.gray84,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '5 ',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 15),

                            // // RIGHT: image
                            // Image.asset(
                            //   AppImages.rightStickArrow,
                            //   color: AppColor.black,
                            //   width: 18,
                            //   height: 18,
                            //   fit: BoxFit.contain,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Products',
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(color: Color(0xFFF8FBF8)),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF000000).withOpacity(0.04), // 3%

                                    Color(0xFF000000).withOpacity(0.00), // 0%
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Samsung s24fe ( 258GB 8GB )',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF31CC64),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '4.5 ',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    color: AppColor.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  '16',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    color: AppColor.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // price
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '₹29000',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '₹39000',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.gray84,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  AppImages.phone,
                                  width: 100,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: const ColoredBox(color: Color(0xFFF8FBF8)),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF000000).withOpacity(0.04), // 3%

                                    Color(0xFF000000).withOpacity(0.00), // 0%
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Samsung s24fe ( 258GB 8GB )',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF31CC64),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '4.5 ',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    color: AppColor.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  '16',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    color: AppColor.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // price
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '₹29000',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '₹39000',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.gray84,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  AppImages.phone,
                                  width: 100,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: const ColoredBox(color: Color(0xFFF8FBF8)),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF000000).withOpacity(0.04), // 3%

                                    Color(0xFF000000).withOpacity(0.00), // 0%
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Samsung s24fe ( 258GB 8GB )',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF31CC64),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '4.5 ',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    color: AppColor.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  '16',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    color: AppColor.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: const [
                                          // price
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '₹29000',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '₹39000',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.gray84,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  AppImages.phone,
                                  width: 100,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String title;
  final String image;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final double horizontalPadding;
  final double verticalPadding;

  const OfferCard({
    super.key,
    required this.title,
    required this.image,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
    this.horizontalPadding = 35,
    this.verticalPadding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active ? activeColor : inactiveColor,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: active
                  ? AppColor.white
                  : AppColor.scaffoldColor.withOpacity(0.3),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Image.asset(
                image,
                height: 92,
                width: 84,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.mulish(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 14),
        ],
      ),
    );
  }
}
