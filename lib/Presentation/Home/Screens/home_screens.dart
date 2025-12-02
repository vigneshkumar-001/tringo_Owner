import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/call_helper.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Core/Widgets/bottom_navigation_bar.dart';
import 'package:tringo_vendor/Presentation/Home/Controller/home_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Create Surprise Offers/create_surprise_offers.dart';
import '../../Enquiry/Screens/enquiry_screens.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';

class HomeScreens extends ConsumerStatefulWidget {
  const HomeScreens({super.key});

  @override
  ConsumerState<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends ConsumerState<HomeScreens> {
  int selectedIndex = 0; // 0 = Unanswered, 1 = Answered
  bool isTexTiles = true;
  int selectIndex = -1;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(homeNotifierProvider.notifier).fetchShops();
      await ref.read(homeNotifierProvider.notifier).fetchAllEnquiry();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final isPremium = RegistrationProductSeivice.instance.isPremium;
    final isNonPremium = RegistrationProductSeivice.instance.isNonPremium;
    final enquiryData = homeState.enquiryResponse?.data;

    // Open = Unanswered
    final openItems = enquiryData?.open.items ?? [];

    // Closed = Answered
    final closedItems = enquiryData?.closed.items ?? [];

    // counts for chips
    final unansweredCount = openItems.length;
    final answeredCount = closedItems.length;

    // which list to show now
    final bool isUnansweredTab = selectedIndex == 0;
    final currentItems = isUnansweredTab ? openItems : closedItems;
    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
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
                              padding: const EdgeInsets.symmetric(
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
                                child: Image.asset(
                                  AppImages.qr_code,
                                  height: 23,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Text(
                                homeState.shopsResponse?.data[0].englishName
                                        .toString() ??
                                    '',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                homeState.shopsResponse?.data[0].category
                                        .toString() ??
                                    '',
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
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: homeState.shopsResponse?.data.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data = homeState.shopsResponse?.data[index];
                        return Row(
                          children: [
                            CommonContainer.smallShopContainer(
                              shopImage: data?.primaryImageUrl.toString() ?? '',
                              shopLocation:
                                  '${data?.addressEn.toString() ?? ''},${data?.city.toString() ?? ''}, kunram ',
                              shopName: data?.englishName.toString() ?? '',
                            ),
                            /* SizedBox(width: 8),
                            CommonContainer.smallShopContainer(
                              shopImage: AppImages.pothys,
                              shopLocation: '12, 2, Tirupparankunram Rd, kunram ',
                              shopName: 'Shop 1',
                            ),*/
                          ],
                        );
                      },
                    ),
                  ),
                  /*    SingleChildScrollView(
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
                  ),*/
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0A1E4D), AppColor.black],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Analytics',
                                      style: AppTextStyles.mulish(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.scaffoldColor,
                                      ),
                                    ),
                                    DottedBorder(
                                      color: Colors.white24,
                                      dashPattern: const [7, 3],
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(20),
                                      strokeWidth: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Last 7 Days',
                                              style: AppTextStyles.mulish(
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.scaffoldColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 3,
                                              ),
                                              child: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 50),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: SizedBox(
                                  height: 240,
                                  child: LineChart(
                                    LineChartData(
                                      betweenBarsData: [
                                        BetweenBarsData(
                                          fromIndex: 1,
                                          toIndex: 0,
                                          // color: [
                                          //   Colors.blueAccent.withOpacity(0.8),
                                          //   Colors.blueAccent.withOpacity(0.3)
                                          // ],
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.2),
                                              Colors.white.withOpacity(0.2),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ],
                                      gridData: FlGridData(
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                              color: Colors.white12,
                                              strokeWidth: 1,
                                            ),
                                      ),
                                      titlesData: FlTitlesData(
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: 100,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: GoogleFonts.mulish(
                                                  color: Colors.white54,
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minX: 0,
                                      maxX: 4,
                                      minY: 0,
                                      maxY: 600,
                                      lineBarsData: [
                                        // Premium User Line
                                        LineChartBarData(
                                          spots: const [
                                            FlSpot(0, 400),
                                            FlSpot(1, 500),
                                            FlSpot(2, 600),
                                            FlSpot(3, 450),
                                            FlSpot(4, 500),
                                          ],
                                          isCurved: false,
                                          color: Colors.white70,
                                          barWidth: 0.5,
                                          belowBarData: BarAreaData(
                                            show: false,
                                          ),
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter:
                                                (
                                                  spot,
                                                  percent,
                                                  barData,
                                                  index,
                                                ) {
                                                  return FlDotCirclePainter(
                                                    color: Colors.white,
                                                    radius: spot.y == 600
                                                        ? 4
                                                        : 2,
                                                    strokeWidth: 0,
                                                  );
                                                },
                                          ),
                                        ),

                                        // Your Reach Line
                                        LineChartBarData(
                                          spots: const [
                                            FlSpot(0, 250),
                                            FlSpot(1, 200),
                                            FlSpot(2, 320),
                                            FlSpot(3, 260),
                                            FlSpot(4, 300),
                                          ],
                                          isCurved: false,
                                          color: Colors.blueAccent,
                                          barWidth: 0.5,
                                          // belowBarData: BarAreaData(
                                          //   show: true,
                                          //   gradient: LinearGradient(
                                          //     colors: [
                                          //       Colors.blueAccent.withOpacity(0.6),
                                          //       Colors.transparent,
                                          //     ],
                                          //     begin: Alignment.topCenter,
                                          //     end: Alignment.bottomCenter,
                                          //   ),
                                          // ),
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter:
                                                (
                                                  spot,
                                                  percent,
                                                  barData,
                                                  index,
                                                ) {
                                                  return FlDotCirclePainter(
                                                    color: spot.y == 320
                                                        ? Colors.blueAccent
                                                        : Colors.white54,
                                                    radius: spot.y == 320
                                                        ? 5
                                                        : 2,
                                                    strokeWidth: 0,
                                                  );
                                                },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    _statBox(
                                      0,
                                      '320',
                                      'Reach',
                                      AppImages.search,
                                    ),
                                    _statBox(
                                      1,
                                      '31',
                                      'Enquiries',
                                      AppImages.msg,
                                    ),
                                    _statBox(2, '20', 'Calls', AppImages.call),
                                    _statBox(
                                      3,
                                      '12',
                                      'Direction',
                                      AppImages.location,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isPremium ? 20 : 90),
                            ],
                          ),
                        ),
                        if (!isPremium) ...[
                          Positioned(
                            bottom: -7,
                            left: 30,
                            right: 30,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubscriptionScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(25),
                                    topLeft: Radius.circular(25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Upgrade',
                                      style: AppTextStyles.mulish(
                                        fontSize: 13,
                                        color: AppColor.skyBlue,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'to Conquer Market',
                                      style: AppTextStyles.mulish(
                                        fontSize: 13,
                                        color: AppColor.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Image.asset(
                                      AppImages.rightStickArrow,
                                      height: 13,
                                      color: AppColor.darkBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -09,
                            left: 45,

                            child: Center(
                              child: Image.asset(
                                AppImages.upgrade,
                                height: 84,
                                width: 71,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 140),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonContainer.offerCardContainer(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateAppOffer(),
                              ),
                            );
                          },
                          tittle: 'The App',
                          cardImage: AppImages.appOfferCard,
                          cardImage1: AppImages.appOffer,
                        ),
                        CommonContainer.offerCardContainer(
                          onTap: () {
                            final isPremium =
                                RegistrationProductSeivice.instance.isPremium;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => isPremium
                                    ? CreateSurpriseOffers() // ✅ PREMIUM → create surprise offer
                                    : SubscriptionScreen(), // ✅ NON-PREMIUM → ask to upgrade
                              ),
                            );
                          },
                          arrowColor: AppColor.surpriseOfferArrow,
                          isSurpriseCard: true,
                          tittle: 'Surprise',
                          cardImage: AppImages.surpriseCard,
                          cardImage1: AppImages.surprise,
                        ),

                        // CommonContainer.offerCardContainer(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => CreateSurpriseOffers(),
                        //       ),
                        //     );
                        //   },
                        //   arrowColor: AppColor.surpriseOfferArrow,
                        //   isSurpriseCard: true,
                        //   tittle: 'Surprise',
                        //   cardImage: AppImages.surpriseCard,
                        //   cardImage1: AppImages.surprise,
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  if (isTexTiles) ...[
                    CommonContainer.smallShopContainer(
                      isAdd: true,
                      shopImage: AppImages.ads,
                      shopLocation: ' ',
                      shopName: ' ',
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommonBottomNavigation(initialIndex: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.asset(
                                AppImages.rightStickArrow,
                                height: 19,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
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
                                    '$unansweredCount Unanswered',
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
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
                                    '$answeredCount Answered',
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

                    const SizedBox(height: 20),
                    Text(
                      'Today',
                      style: AppTextStyles.mulish(
                        fontSize: 12,
                        color: AppColor.darkGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (currentItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isUnansweredTab
                                ? 'No unanswered enquiries'
                                : 'No answered enquiries',
                            style: AppTextStyles.mulish(
                              fontSize: 12,
                              color: AppColor.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final data = currentItems[index];

                          // Normalize type (API sends "PRODUCT_SHOP", "PRODUCT_SERVICE", etc.)
                          final type = data.contextType.toUpperCase();

                          // Default values
                          String productTitle = 'Enquiry';
                          String rating = '0.0';
                          String ratingCount = '0';
                          String priceText = '';
                          String image = '';
                          String customerName = data.customer.name;
                          String whatsappNumber = data.customer.whatsappNumber;
                          String phone = data.customer.phone;
                          String customerImg =
                              data.customer.avatarUrl.toString() ?? '';
                          String timeText = data.createdTime;

                          if (type == 'PRODUCT_SHOP') {
                            final shop = data.shop;

                            productTitle = shop?.englishName.isNotEmpty == true
                                ? shop!.englishName
                                : 'Shop Enquiry';

                            rating = (shop?.rating ?? 0).toString();
                            ratingCount = (shop?.ratingCount ?? 0).toString();

                            // You can customise this (city / category / etc.)
                            priceText = 'Shop · ${shop?.city ?? ''}';
                            image = shop?.primaryImageUrl ?? '';
                          }
                          // ---------- PRODUCT_SERVICE → use SERVICE details ----------
                          else if (type == 'PRODUCT_SERVICE' ||
                              type == 'SERVICE_SHOP') {
                            final service = data.service;

                            productTitle = service?.name.isNotEmpty == true
                                ? service!.name
                                : 'Service Enquiry';

                            rating = (service?.rating ?? 0).toString();
                            ratingCount = (service?.ratingCount ?? 0)
                                .toString();

                            // If startsAt is price
                            if (service != null && service.startsAt > 0) {
                              priceText = 'From ₹${service.startsAt}';
                            } else {
                              priceText = 'Service';
                            }
                          }
                          // ---------- (Optional) PRODUCT → use PRODUCT details ----------
                          else if (type == 'PRODUCT') {
                            // right now Product has only id – you can expand later
                            productTitle = 'Product Enquiry';
                            priceText = 'Product Id: ${data.product?.id ?? ''}';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                CommonContainer.inquiryProductCard(
                                  // 🔹 message from enquiry
                                  questionText: data.message,

                                  // 🔹 title depends on contextType
                                  productTitle: productTitle,

                                  // 🔹 rating depends on shop / service
                                  rating: rating,
                                  ratingCount: ratingCount,

                                  // 🔹 price / label text depends on contextType
                                  priceText: priceText,

                                  // You can still keep dummy MRP or map from your real product later
                                  mrpText: '₹36,999',

                                  // Still using static image asset (your widget expects asset path)
                                  phoneImageAsset: image,

                                  // Customer details
                                  avatarAsset: customerImg,
                                  customerName: customerName,
                                  timeText: timeText,

                                  onChatTap: () {
                                    CallHelper.openWhatsapp(
                                      context: context,
                                      phone: whatsappNumber,
                                    );
                                  },
                                  onCallTap: () {
                                    CallHelper.openDialer(
                                      context: context,
                                      rawPhone: phone,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE29300), Color(0xFFFFB222)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.35),
                              offset: const Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                        ),

                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Stack(
                            clipBehavior: Clip
                                .none, // <-- allows overflow outside the stack bounds
                            children: [
                              // --- Background texture pattern (subtle, low opacity)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.05, // mild visibility
                                  child: Image.asset(
                                    AppImages.imageContainer1,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              Positioned(
                                left: -17,
                                bottom: -70,

                                child: Image.asset(
                                  AppImages.sale,
                                  height: 190,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              Row(
                                children: [
                                  Expanded(flex: 1, child: Text('')),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'No Food\nWastage Sale',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            height: 1.15,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(1, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Sell your remaining food faster with offer',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColor.white,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Starts at ',
                                                      style:
                                                          AppTextStyles.mulish(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text: '1.30Pm',
                                                      style:
                                                          AppTextStyles.mulish(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColor.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Image.asset(
                                                AppImages.rightStickArrow,
                                                height: 20,
                                                color: AppColor.appOfferArrow,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '11Am ',
                                  style: AppTextStyles.mulish(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Food Orders',
                                  style: AppTextStyles.mulish(
                                    color: Colors.black,

                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.black,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Image.asset(
                              AppImages.rightStickArrow,
                              height: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => selectedIndex = 0);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
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
                                  '15 All Orders',
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
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() => selectedIndex = 1);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
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
                                  '50 Un Served',
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
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() => selectedIndex = 2);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: selectedIndex == 2
                                      ? AppColor.black
                                      : AppColor.borderLightGrey,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '5 Served',
                                  style: TextStyle(
                                    color: selectedIndex == 2
                                        ? AppColor.black
                                        : AppColor.borderLightGrey,
                                    fontWeight: selectedIndex == 2
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() => selectedIndex = 3);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: selectedIndex == 3
                                      ? AppColor.black
                                      : AppColor.borderLightGrey,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '50 Answered',
                                  style: TextStyle(
                                    color: selectedIndex == 3
                                        ? AppColor.black
                                        : AppColor.borderLightGrey,
                                    fontWeight: selectedIndex == 3
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Card(
                        elevation: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // LEFT SIDE CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Paid + Delivery Status
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColor.green,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                "Paid",
                                                style: AppTextStyles.mulish(
                                                  color: AppColor.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColor.iceBlue,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.delivery_dining,
                                                    size: 16,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Door Delivery",
                                                    style: AppTextStyles.mulish(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AppColor.skyBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Order Time
                                        Text(
                                          'Order At 11.PM',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),

                                        const SizedBox(height: 25),

                                        // PRICE + QTY + DOTTED DIVIDER
                                        Row(
                                          children: [
                                            const Text(
                                              "₹42 ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              "Total",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              height: 15,
                                              width: 1,
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1,
                                                    style: BorderStyle.solid,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "2 Qty",
                                              style: AppTextStyles.mulish(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // RIGHT SIDE IMAGE
                                  Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          AppImages.vadai,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Kadai Vada',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // ACTION BUTTONS
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.skyBlue,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.call,
                                            color: AppColor.white,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Call',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.skyBlue,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.loc,
                                            height: 16,
                                            color: AppColor.skyBlue,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Location',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.skyBlue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(int index, String value, String label, String image) {
    final bool isSelected = selectIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColor.black,
          border: Border.all(
            color: isSelected ? AppColor.white : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(image, height: 23, color: AppColor.white),
            SizedBox(width: 8),
            Text(
              '$value',
              style: AppTextStyles.mulish(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '$label',
              style: AppTextStyles.mulish(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade900,
              ),
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 15),
            ),
          ],
        ),
      ),
    );
  }
}
