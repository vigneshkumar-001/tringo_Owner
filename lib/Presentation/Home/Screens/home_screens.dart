import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/call_helper.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Core/Widgets/bottom_navigation_bar.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';
import 'package:tringo_owner/Presentation/Home/Screens/tringo_chart.dart';
import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_history.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Api/Repository/api_url.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Create Surprise Offers/Screens/create_surprise_offer.dart';
import '../../Create Surprise Offers/Screens/create_surprise_offers.dart';
import '../../Create Surprise Offers/Screens/surprise_offer_list.dart';
import '../../Enquiry/Screens/enquiry_screens.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import 'package:tringo_owner/Presentation/Home/Model/shops_response.dart';

import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../under_processing.dart';
import '../Controller/shopContext_provider.dart';
import 'home_screen_analytics.dart';

// ✅ NEW
import '../../../Core/Utility/filter_enum.dart';

class HomeScreens extends ConsumerStatefulWidget {
  const HomeScreens({super.key});

  @override
  ConsumerState<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends ConsumerState<HomeScreens> {
  bool _isDownloading = false;
  int selectedIndex = 0;
  bool isTexTiles = true;
  int selectIndex = -1;
  bool _isFreemium = false;

  // ✅ NEW: chart filter state + loading state (only for chart reload)
  ChartFilter _selectedChartFilter = ChartFilter.day;
  bool _chartLoading = false;

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
      await ref
          .read(homeNotifierProvider.notifier)
          .fetchShops(
            shopId: '',
            filter: chartFilterToApi(_selectedChartFilter),
          );

      await ref.read(homeNotifierProvider.notifier).fetchAllEnquiry(shopId: '');
    });
  }

  Future<void> openPdfInChrome() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('sessionToken') ?? '';
    final String urlString = ApiUrl.enguiriesDownload(
      sessionToken: sessionToken,
    );
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  Future<void> _reloadChart({required String shopId}) async {
    setState(() => _chartLoading = true);

    final apiFilter = chartFilterToApi(
      _selectedChartFilter,
    ); // DAY/WEEK/MONTH/YEAR

    try {
      await ref
          .read(homeNotifierProvider.notifier)
          .fetchShops(
            shopId: shopId,
            filter: apiFilter, // ✅ ONLY THIS
          );
    } finally {
      if (mounted) setState(() => _chartLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final homeNotifier = ref.watch(homeNotifierProvider.notifier);
    final planState = ref.watch(subscriptionNotifier);
    final planData = planState.currentPlanResponse?.data;
    // final isPremium = RegistrationProductSeivice.instance.isPremium;
    final isNonPremium = RegistrationProductSeivice.instance.isNonPremium;
    final selectedShopId = homeState.selectedShopId;
    final enquiry = homeState.enquiryResponse;
    final shopsRes = homeState.shopsResponse;

    final List<Shop> shops = shopsRes?.data.items ?? [];

    final bool hasShops = shops.isNotEmpty;
    final homeChart = shopsRes?.data.homeChart;

    bool hasEnquiries = false;
    final enquiryData = enquiry?.data;
    if (enquiryData != null) {
      final openItems = enquiryData.open.items;
      final closedItems = enquiryData.closed.items;
      hasEnquiries = openItems.isNotEmpty || closedItems.isNotEmpty;
    }

    final bool isFreemium = shopsRes?.data.subscription.isFreemium ?? true;
    final bool isPremium = isFreemium;
    AppLogger.log.w(isPremium);

    //  GLOBAL "NO DATA FOUND" (no shops + no enquiries + not loading)
    if (!homeState.isLoading && !hasShops && !hasEnquiries) {
      return Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchShops(
                    shopId: '',
                    filter: chartFilterToApi(_selectedChartFilter),
                  );
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchAllEnquiry(shopId: '');
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 600,
                  child: NoDataScreen(
                    showBottomButton: false,
                    showTopBackArrow: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Open = Unanswered
    final openItems = enquiryData?.open.items ?? [];
    // Closed = Answered
    final closedItems = enquiryData?.closed.items ?? [];
    final unansweredCount = openItems.length;
    final answeredCount = closedItems.length;

    final Shop? mainShop = hasShops ? shops.first : null;

    final bool isUnansweredTab = selectedIndex == 0;
    final currentItems = isUnansweredTab ? openItems : closedItems;

    // ✅ CHOOSE current shopId for chart api
    final String chartShopId = (selectedShopId ?? '').isNotEmpty
        ? (selectedShopId ?? '')
        : (mainShop?.id ?? '');

    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(homeNotifierProvider.notifier)
                    .fetchShops(
                      shopId: '',
                      filter: chartFilterToApi(_selectedChartFilter),
                    );
                await ref
                    .read(homeNotifierProvider.notifier)
                    .fetchAllEnquiry(shopId: '');
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ---------------- HEADER ROW ----------------
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
                                  (mainShop?.englishName ?? '').isNotEmpty
                                      ? mainShop!.englishName
                                      : 'My Shop',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  mainShop?.category ?? '',
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

                    const SizedBox(height: 30),

                    // ---------------- SHOPS LIST ----------------
                    if (shops.isEmpty) ...[
                      CommonContainer.smallShopContainer(
                        addAnotherShop: true,
                        shopImage: '',
                        shopName: 'Add Another Shop',
                        shopLocation: 'Upgrade to add branch',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubscriptionScreen(),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: shops.length + 1,
                          itemBuilder: (context, index) {
                            final bool showSwitch = shops.length > 1;

                            if (index == shops.length) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CommonContainer.smallShopContainer(
                                  addAnotherShop: true,
                                  shopImage: '',
                                  shopName: 'Add Another Shop',
                                  shopLocation: isFreemium
                                      ? 'Upgrade to add branch'
                                      : 'Add a new branch',
                                  onTap: () {
                                    if (isFreemium) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SubscriptionScreen(),
                                        ),
                                      );
                                    } else {
                                      final bool isService =
                                          shopsRes?.data.items.first.shopKind
                                              .toUpperCase() ==
                                          'SERVICE';

                                      context.push(
                                        AppRoutes.shopCategoryInfoPath,
                                        extra: {
                                          'isService': isService,
                                          'isIndividual': '',
                                          'initialShopNameEnglish': shopsRes
                                              ?.data
                                              .items
                                              .first
                                              .englishName,
                                          'initialShopNameTamil': shopsRes
                                              ?.data
                                              .items
                                              .first
                                              .tamilName,
                                          'isEditMode': true,
                                        },
                                      );
                                    }
                                  },
                                ),
                              );
                            }

                            final shop = shops[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CommonContainer.smallShopContainer(
                                showSwitch: showSwitch,
                                shopImage: shop.primaryImageUrl ?? '',
                                shopName: shop.englishName,
                                shopLocation: '${shop.addressEn}, ${shop.city}',
                                onTap: () async {
                                  ref
                                      .read(selectedShopProvider.notifier)
                                      .switchShop(shop.id);

                                  // ✅ reload chart for new shop with current filter
                                  if (shop.id.isNotEmpty) {
                                    await _reloadChart(shopId: shop.id);
                                  }
                                },
                                switchOnTap: () async {
                                  ref
                                      .read(selectedShopProvider.notifier)
                                      .switchShop(shop.id);

                                  if (shop.id.isNotEmpty) {
                                    await _reloadChart(shopId: shop.id);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ---------------- ANALYTICS CARD ----------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0A1E4D),
                                  AppColor.black,
                                ],
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

                                      // ✅ UPDATED: dropdown filter inside dotted border
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
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<ChartFilter>(
                                              value: _selectedChartFilter,
                                              dropdownColor: const Color(
                                                0xFF0A1E4D,
                                              ),
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                              style: AppTextStyles.mulish(
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.scaffoldColor,
                                                fontSize: 14,
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: ChartFilter.day,
                                                  child: Text('Last 7 Days'),
                                                ),
                                                DropdownMenuItem(
                                                  value: ChartFilter.week,
                                                  child: Text('Last 4 Weeks'),
                                                ),
                                                DropdownMenuItem(
                                                  value: ChartFilter.month,
                                                  child: Text('This Month'),
                                                ),
                                                DropdownMenuItem(
                                                  value: ChartFilter.year,
                                                  child: Text('This Year'),
                                                ),
                                              ],
                                              onChanged: (v) async {
                                                if (v == null) return;
                                                setState(
                                                  () =>
                                                      _selectedChartFilter = v,
                                                );

                                                if (chartShopId.isNotEmpty) {
                                                  await _reloadChart(
                                                    shopId: chartShopId,
                                                  );
                                                } else {
                                                  // fallback refresh
                                                  await _reloadChart(
                                                    shopId: mainShop?.id ?? '',
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50),

                                // Chart
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: SizedBox(
                                    height: 240,
                                    child: _chartLoading
                                        ? const Center(
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : (homeChart == null
                                              ? const SizedBox.shrink()
                                              : ReachLineChart(
                                                  chart: homeChart,
                                                )),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Stats row (unchanged)
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
                                        1,
                                        shopsRes
                                                ?.data
                                                .homeChart
                                                ?.totals
                                                .enquiries
                                                .toString() ??
                                            '',
                                        'Enquiries',
                                        AppImages.msg,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenAnalytics(
                                                    shopId:
                                                        shopsRes
                                                            ?.data
                                                            .homeChart
                                                            ?.shopId
                                                            .toString() ??
                                                        '',
                                                    initialIndex: 0,
                                                    initialType:
                                                        AnalyticsType.enquiries,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      _statBox(
                                        2,
                                        shopsRes?.data.homeChart?.totals.calls
                                                .toString() ??
                                            '',
                                        'Calls',
                                        AppImages.call,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenAnalytics(
                                                    shopId:
                                                        shopsRes
                                                            ?.data
                                                            .homeChart
                                                            ?.shopId
                                                            .toString() ??
                                                        '',
                                                    initialIndex: 1,
                                                    initialType:
                                                        AnalyticsType.calls,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      _statBox(
                                        3,
                                        shopsRes
                                                ?.data
                                                .homeChart
                                                ?.totals
                                                .directions
                                                .toString() ??
                                            '',
                                        'Direction',
                                        AppImages.location,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenAnalytics(
                                                    shopId:
                                                        shopsRes
                                                            ?.data
                                                            .homeChart
                                                            ?.shopId
                                                            .toString() ??
                                                        '',
                                                    initialIndex: 2,
                                                    initialType:
                                                        AnalyticsType.locations,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: isPremium == false ? 20 : 75),
                              ],
                            ),
                          ),

                          if (isPremium) ...[
                            Positioned(
                              bottom: -7,
                              left: 30,
                              right: 30,
                              child: GestureDetector(
                                onTap: () {
                                  final bool isFreemium =
                                      planData?.isFreemium ?? true;

                                  if (!isFreemium) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionHistory(
                                              fromDate:
                                                  planData?.period.startsAtLabel
                                                      .toString() ??
                                                  '',
                                              titlePlan:
                                                  planData?.plan.durationLabel
                                                      .toString() ??
                                                  '',
                                              toDate:
                                                  planData?.period.endsAtLabel
                                                      .toString() ??
                                                  '',
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 18,
                                  ),
                                  decoration: const BoxDecoration(
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
                                      const SizedBox(width: 4),
                                      Text(
                                        'to Conquer Market',
                                        style: AppTextStyles.mulish(
                                          fontSize: 13,
                                          color: AppColor.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                              bottom: -9,
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

                    const SizedBox(height: 140),
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
                                  builder: (context) =>
                                      CommonBottomNavigation(initialIndex: 2),
                                  //     CreateAppOffer(
                                  //   shopId: mainShop?.id ?? '',
                                  // ),
                                ),
                              );
                            },
                            tittle: 'The App',
                            cardImage: AppImages.appOfferCard,
                            cardImage1: AppImages.appOffer,
                          ),
                          CommonContainer.offerCardContainer(
                            onTap: () {
                              // ✅ false => SurpriseOfferList, true => SubscriptionScreen
                              if (isFreemium == false) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SurpriseOfferList(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubscriptionScreen(),
                                  ),
                                );
                              }

                              AppLogger.log.i(mainShop?.id);
                            },

                            // onTap: () {
                            //   if (_isFreemium == false) {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => SurpriseOfferList(),
                            //       ),
                            //     );
                            //   } else {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => SubscriptionScreen(),
                            //       ),
                            //     );
                            //   }
                            //   // final isPremium =
                            //   //     RegistrationProductSeivice.instance.isPremium;
                            //   // Navigator.push(
                            //   //   context,
                            //   //   MaterialPageRoute(
                            //   //     builder: (_) => isPremium
                            //   //         ? SurpriseOfferList()
                            //   //         : SubscriptionScreen(),
                            //   //   ),
                            //   // );
                            //   AppLogger.log.i(mainShop?.id);
                            // },
                            arrowColor: AppColor.surpriseOfferArrow,
                            isSurpriseCard: true,
                            tittle: 'Surprise',
                            cardImage: AppImages.surpriseCard,
                            cardImage1: AppImages.surprise,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================== IF TEXTILES (ENQUIRY SECTION) ==================
                    if (isTexTiles) ...[
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enquiries',
                              style: AppTextStyles.mulish(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),
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
                                padding: const EdgeInsets.symmetric(
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

                      // tabs
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

                      if (currentItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'No enquiries yet',
                              style: TextStyle(
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

                            final type = data.contextType.toUpperCase();

                            String productTitle = 'Enquiry';
                            String rating = '0.0';
                            String ratingCount = '0';
                            String priceText = '';
                            String offerPrice = '';
                            String image = '';
                            String customerName = data.customer.name;
                            String whatsappNumber =
                                data.customer.whatsappNumber;
                            String phone = data.customer.phone;
                            String customerImg = data.customer.avatarUrl
                                .toString();
                            String timeText = data.createdTime;

                            if (type == 'PRODUCT_SHOP' ||
                                type == 'SERVICE_SHOP') {
                              final shop = data.shop;
                              productTitle =
                                  (shop?.englishName.toUpperCase() ?? '')
                                      .isNotEmpty
                                  ? shop!.englishName.toUpperCase()
                                  : 'Shop Enquiry';
                              rating = (shop?.rating ?? 0).toString();
                              ratingCount = (shop?.ratingCount ?? 0).toString();
                              offerPrice =
                                  '${shop?.category.toUpperCase() ?? ''}';
                              image = shop?.primaryImageUrl ?? '';
                            } else if (type == 'PRODUCT_SERVICE' ||
                                type == 'SERVICE_SHOP') {
                              final service = data.service;
                              productTitle = (service?.name ?? '').isNotEmpty
                                  ? service!.name
                                  : 'Service Enquiry';
                              rating = (service?.rating ?? 0).toString();
                              image = (service?.primaryImageUrl ?? 0)
                                  .toString();
                              ratingCount = (service?.ratingCount ?? 0)
                                  .toString();
                              if (service != null && service.startsAt > 0) {
                                priceText = 'From ₹${service.startsAt}';
                              } else {
                                priceText = 'Service';
                              }
                            } else if (type == 'PRODUCT') {
                              productTitle =
                                  data.product?.name.toString() ?? '';
                              priceText = '${data.product?.price ?? ''}';
                              offerPrice = '₹${data.product?.offerPrice ?? ''}';
                              image = data.product?.imageUrl ?? '';
                              rating = '${data.product?.rating ?? ''}';
                              ratingCount =
                                  '${data.product?.ratingCount ?? ''}';
                            } else if (type == 'SERVICE') {
                              productTitle =
                                  data.service?.name.toString() ?? '';
                              offerPrice = '₹${data.service?.startsAt ?? ''}';

                              image = data.service?.primaryImageUrl ?? '';
                              rating = '${data.service?.rating ?? ''}';
                              ratingCount =
                                  '${data.service?.ratingCount ?? ''}';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Column(
                                children: [
                                  CommonContainer.inquiryProductCard(
                                    questionText: '',
                                    productTitle: productTitle,
                                    rating: rating,
                                    ratingCount: ratingCount,
                                    priceText: offerPrice,
                                    mrpText: '$priceText',
                                    phoneImageAsset: image,
                                    avatarAsset: customerImg,
                                    customerName: customerName,
                                    timeText: timeText,
                                    onChatTap: () {
                                      CallHelper.openWhatsapp(
                                        context: context,
                                        phone: whatsappNumber,
                                      );
                                      ref
                                          .read(homeNotifierProvider.notifier)
                                          .markEnquiry(enquiryId: data.id);
                                      ref
                                          .read(selectedShopProvider.notifier)
                                          .switchShop('');
                                    },
                                    onCallTap: () {
                                      CallHelper.openDialer(
                                        context: context,
                                        rawPhone: phone,
                                      );
                                      ref
                                          .read(homeNotifierProvider.notifier)
                                          .markEnquiry(enquiryId: data.id);
                                      ref
                                          .read(selectedShopProvider.notifier)
                                          .switchShop('');
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        ),
                    ] else ...[
                      // ================== NON-TEXTILES BRANCH (NO FOOD WASTAGE etc.) ==================
                      // (your existing non-textiles UI unchanged)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.05,
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
                                    const Expanded(flex: 1, child: SizedBox()),
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
                                              shadows: const [
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
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                      TextSpan(
                                                        text: '1.30Pm',
                                                        style:
                                                            AppTextStyles.mulish(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                      const SizedBox(height: 50),
                      // ... rest of your screen is unchanged ...
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(
    int index,
    String value,
    String label,
    String image,
    VoidCallback? onTap,
  ) {
    final bool isSelected = selectIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectIndex = index);
        onTap?.call();
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
            const SizedBox(width: 8),
            Text(
              value,
              style: AppTextStyles.mulish(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.mulish(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade900,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/call_helper.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Core/Widgets/bottom_navigation_bar.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';
import 'package:tringo_owner/Presentation/Home/Screens/tringo_chart.dart';
import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_history.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Api/Repository/api_url.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Create Surprise Offers/Screens/create_surprise_offer.dart';
import '../../Create Surprise Offers/Screens/create_surprise_offers.dart';
import '../../Create Surprise Offers/Screens/surprise_offer_list.dart';
import '../../Enquiry/Screens/enquiry_screens.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import 'package:tringo_owner/Presentation/Home/Model/shops_response.dart';

import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../under_processing.dart';
import '../Controller/shopContext_provider.dart';
import 'home_screen_analytics.dart';

class HomeScreens extends ConsumerStatefulWidget {
  const HomeScreens({super.key});

  @override
  ConsumerState<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends ConsumerState<HomeScreens> {
  bool _isDownloading = false;
  int selectedIndex = 0;
  bool isTexTiles = true;
  int selectIndex = -1;
  bool _isFreemium = false;

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
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await ref.read(homeNotifierProvider.notifier).fetchShops();
    //   await ref.read(homeNotifierProvider.notifier).fetchAllEnquiry();
    // });
  }

  Future<void> openPdfInChrome() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('sessionToken') ?? '';

    // Assuming this returns a String like "https://.../enquiries/export?..."
    final String urlString = ApiUrl.enguiriesDownload(
      sessionToken: sessionToken,
    );

    final Uri url = Uri.parse(urlString);

    // Try opening in browser (Chrome if default)
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Optional: handle failure
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {

    final homeState = ref.watch(homeNotifierProvider);
    final homeNotifier = ref.watch(homeNotifierProvider.notifier);
    final planState = ref.watch(subscriptionNotifier);
    final planData = planState.currentPlanResponse?.data;
    final isPremium = RegistrationProductSeivice.instance.isPremium;
    final isNonPremium = RegistrationProductSeivice.instance.isNonPremium;
    final selectedShopId = homeState.selectedShopId;
    final enquiry = homeState.enquiryResponse;
    final shopsRes = homeState.shopsResponse;

    final List<Shop> shops = shopsRes?.data.items ?? [];

    final bool hasShops = shops.isNotEmpty;
    final homeChart = shopsRes?.data.homeChart; // from API model
    bool hasEnquiries = false;
    final enquiryData = enquiry?.data;
    if (enquiryData != null) {
      final openItems = enquiryData.open.items;
      final closedItems = enquiryData.closed.items;
      hasEnquiries = openItems.isNotEmpty || closedItems.isNotEmpty;
    }

    final bool isFreemium = shopsRes?.data.subscription.isFreemium ?? true;

    //  GLOBAL "NO DATA FOUND" (no shops + no enquiries + not loading)
    if (!homeState.isLoading && !hasShops && !hasEnquiries) {
      return Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchShops(shopId: '');
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchAllEnquiry(shopId: '');
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 600, // ensures scroll even when empty
                  child: NoDataScreen(
                    showBottomButton: false,
                    showTopBackArrow: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ---------- NORMAL BUILD FLOW BELOW ----------

    // Open = Unanswered
    final openItems = enquiryData?.open.items ?? [];

    // Closed = Answered
    final closedItems = enquiryData?.closed.items ?? [];

    // counts for chips
    final unansweredCount = openItems.length;
    final answeredCount = closedItems.length;

    // main shop (first shop if available)
    final Shop? mainShop = hasShops ? shops.first : null;

    final bool isUnansweredTab = selectedIndex == 0;
    final currentItems = isUnansweredTab ? openItems : closedItems;

    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(homeNotifierProvider.notifier)
                    .fetchShops(shopId: '');
                await ref
                    .read(homeNotifierProvider.notifier)
                    .fetchAllEnquiry(shopId: '');
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ---------------- HEADER ROW ----------------
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
                                  // title fallback
                                  (mainShop?.englishName ?? '').isNotEmpty
                                      ? mainShop!.englishName
                                      : 'My Shop',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  mainShop?.category ?? '',
                                  style: AppTextStyles.mulish(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.gray84,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => MenuScreens(),
                          //         ),
                          //       );
                          //     },
                          //     child: ClipRRect(
                          //       borderRadius: BorderRadius.circular(25),
                          //       child: SizedBox(
                          //         height: 52,
                          //         width: 52,
                          //         child: CachedNetworkImage(
                          //           imageUrl: mainShop?.primaryImageUrl ?? '',
                          //           fit: BoxFit.cover,
                          //
                          //           // While loading
                          //           placeholder: (context, url) => const Center(
                          //             child: CircularProgressIndicator(
                          //               strokeWidth: 2,
                          //             ),
                          //           ),
                          //
                          //           // If error occurs
                          //           errorWidget: (context, url, error) =>
                          //               const Icon(Icons.person, size: 40),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
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

                    const SizedBox(height: 30),

                    if (shops.isEmpty) ...[
                      CommonContainer.smallShopContainer(
                        addAnotherShop: true,
                        shopImage: '',
                        shopName: 'Add Another Shop',
                        shopLocation: 'Upgrade to add branch',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubscriptionScreen(),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),

                          // ✅ ALWAYS +1 for "Add Another Shop"
                          itemCount: shops.length + 1,

                          itemBuilder: (context, index) {
                            final bool showSwitch = shops.length > 1;

                            // ✅ LAST ITEM → Add Another Shop (always)
                            if (index == shops.length) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CommonContainer.smallShopContainer(
                                  addAnotherShop: true,
                                  shopImage: '',
                                  shopName: 'Add Another Shop',
                                  shopLocation: isFreemium
                                      ? 'Upgrade to add branch'
                                      : 'Add a new branch',
                                  onTap: () {
                                    if (isFreemium) {
                                      // 🔒 Freemium → subscription
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SubscriptionScreen(),
                                        ),
                                      );
                                    } else {
                                      // ✅ Premium → add shop flow
                                      final bool isService =
                                          shopsRes?.data.items.first.shopKind
                                              .toUpperCase() ==
                                          'SERVICE';

                                      context.push(
                                        AppRoutes.shopCategoryInfoPath,
                                        extra: {
                                          'isService': isService,
                                          'isIndividual': '',
                                          'initialShopNameEnglish': shopsRes
                                              ?.data
                                              .items
                                              .first
                                              .englishName,
                                          'initialShopNameTamil': shopsRes
                                              ?.data
                                              .items
                                              .first
                                              .tamilName,
                                          'isEditMode': true,
                                        },
                                      );
                                    }
                                  },
                                ),
                              );
                            }

                            // ✅ NORMAL SHOP ITEM
                            final shop = shops[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CommonContainer.smallShopContainer(
                                showSwitch: showSwitch, // 🔑 HERE
                                shopImage: shop.primaryImageUrl ?? '',
                                shopName: shop.englishName,
                                shopLocation: '${shop.addressEn}, ${shop.city}',
                                onTap: () {
                                  ref
                                      .read(selectedShopProvider.notifier)
                                      .switchShop(shop.id);
                                },
                                switchOnTap: () {
                                  ref
                                      .read(selectedShopProvider.notifier)
                                      .switchShop(shop.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ---------------- ANALYTICS CARD ----------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0A1E4D),
                                  AppColor.black,
                                ],
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
                                              const SizedBox(width: 5),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 3.0,
                                                ),
                                                child: Icon(
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
                                const SizedBox(height: 50),

                                // Chart
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: SizedBox(
                                    height: 240,
                                    child: homeChart == null
                                        ? const SizedBox.shrink()
                                        : ReachLineChart(chart: homeChart),   // ✅ pass here
                                  ),
                                ),
                                */
/*Padding(
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
                                          bottomTitles: const AxisTitles(
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
                                ),*/ /*

                                const SizedBox(height: 40),

                                // Stats row
                                SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    // if your Flutter doesn't support `spacing`, replace with SizedBox in children
                                    spacing: 10,
                                    children: [
                                      // _statBox(
                                      //   0,
                                      //   shopsRes
                                      //           ?.data
                                      //           .homeChart
                                      //           ?.totals
                                      //           .profileViews
                                      //           .toString() ??
                                      //       '',
                                      //   'Reach',
                                      //   AppImages.search,
                                      //   () {},
                                      // ),
                                      _statBox(
                                        1,
                                        shopsRes
                                                ?.data
                                                .homeChart
                                                ?.totals
                                                .enquiries
                                                .toString() ??
                                            '',
                                        'Enquiries',
                                        AppImages.msg,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenAnalytics(
                                                    shopId:
                                                        shopsRes
                                                            ?.data
                                                            .homeChart
                                                            ?.shopId
                                                            .toString() ??
                                                        '',
                                                    initialIndex: 0,
                                                    initialType:
                                                        AnalyticsType.enquiries,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      _statBox(
                                        2,
                                        shopsRes?.data.homeChart?.totals.calls
                                                .toString() ??
                                            '',
                                        'Calls',
                                        AppImages.call,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenAnalytics(
                                                    shopId:
                                                        shopsRes
                                                            ?.data
                                                            .homeChart
                                                            ?.shopId
                                                            .toString() ??
                                                        '',
                                                    initialIndex: 1,
                                                    initialType:
                                                        AnalyticsType.calls,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      _statBox(
                                        3,
                                        shopsRes
                                                ?.data
                                                .homeChart
                                                ?.totals
                                                .directions
                                                .toString() ??
                                            '',

                                        'Direction',
                                        AppImages.location,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenAnalytics(
                                                    shopId:
                                                        shopsRes
                                                            ?.data
                                                            .homeChart
                                                            ?.shopId
                                                            .toString() ??
                                                        '',
                                                    initialIndex: 2,
                                                    initialType:
                                                        AnalyticsType.locations,
                                                  ),
                                            ),
                                          );
                                        },
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
                                  final bool isFreemium =
                                      planData?.isFreemium ?? true;

                                  if (!isFreemium) {
                                    // NOT freemium → go to subscription history
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionHistory(
                                              fromDate:
                                                  planData?.period.startsAtLabel
                                                      .toString() ??
                                                  '',
                                              titlePlan:
                                                  planData?.plan.durationLabel
                                                      .toString() ??
                                                  '',
                                              toDate:
                                                  planData?.period.endsAtLabel
                                                      .toString() ??
                                                  '',
                                            ),
                                      ),
                                    );
                                  } else {
                                    // Freemium → go to subscription screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionScreen(),
                                      ),
                                    );
                                  }
                                },

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 18,
                                  ),
                                  decoration: const BoxDecoration(
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
                                      const SizedBox(width: 4),
                                      Text(
                                        'to Conquer Market',
                                        style: AppTextStyles.mulish(
                                          fontSize: 13,
                                          color: AppColor.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                              bottom: -9,
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
                                  builder: (context) =>
                                      CommonBottomNavigation(initialIndex: 2),
                                  //     CreateAppOffer(
                                  //   shopId: mainShop?.id ?? '',
                                  // ),
                                ),
                              );
                            },
                            tittle: 'The App',
                            cardImage: AppImages.appOfferCard,
                            cardImage1: AppImages.appOffer,
                          ),
                          CommonContainer.offerCardContainer(
                            onTap: () {
                              // ✅ false => SurpriseOfferList, true => SubscriptionScreen
                              if (isFreemium == false) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SurpriseOfferList(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubscriptionScreen(),
                                  ),
                                );
                              }

                              AppLogger.log.i(mainShop?.id);
                            },

                            // onTap: () {
                            //   if (_isFreemium == false) {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => SurpriseOfferList(),
                            //       ),
                            //     );
                            //   } else {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => SubscriptionScreen(),
                            //       ),
                            //     );
                            //   }
                            //   // final isPremium =
                            //   //     RegistrationProductSeivice.instance.isPremium;
                            //   // Navigator.push(
                            //   //   context,
                            //   //   MaterialPageRoute(
                            //   //     builder: (_) => isPremium
                            //   //         ? SurpriseOfferList()
                            //   //         : SubscriptionScreen(),
                            //   //   ),
                            //   // );
                            //   AppLogger.log.i(mainShop?.id);
                            // },
                            arrowColor: AppColor.surpriseOfferArrow,
                            isSurpriseCard: true,
                            tittle: 'Surprise',
                            cardImage: AppImages.surpriseCard,
                            cardImage1: AppImages.surprise,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================== IF TEXTILES (ENQUIRY SECTION) ==================
                    if (isTexTiles) ...[
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enquiries',
                              style: AppTextStyles.mulish(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),
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
                                padding: const EdgeInsets.symmetric(
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

                      // tabs
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

                      if (currentItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'No enquiries yet',
                              style: TextStyle(
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

                            final type = data.contextType.toUpperCase();

                            String productTitle = 'Enquiry';
                            String rating = '0.0';
                            String ratingCount = '0';
                            String priceText = '';
                            String offerPrice = '';
                            String image = '';
                            String customerName = data.customer.name;
                            String whatsappNumber =
                                data.customer.whatsappNumber;
                            String phone = data.customer.phone;
                            String customerImg = data.customer.avatarUrl
                                .toString();
                            String timeText = data.createdTime;

                            if (type == 'PRODUCT_SHOP' ||
                                type == 'SERVICE_SHOP') {
                              final shop = data.shop;
                              productTitle =
                                  (shop?.englishName.toUpperCase() ?? '')
                                      .isNotEmpty
                                  ? shop!.englishName.toUpperCase()
                                  : 'Shop Enquiry';
                              rating = (shop?.rating ?? 0).toString();
                              ratingCount = (shop?.ratingCount ?? 0).toString();
                              offerPrice =
                                  '${shop?.category.toUpperCase() ?? ''}';
                              image = shop?.primaryImageUrl ?? '';
                            } else if (type == 'PRODUCT_SERVICE' ||
                                type == 'SERVICE_SHOP') {
                              final service = data.service;
                              productTitle = (service?.name ?? '').isNotEmpty
                                  ? service!.name
                                  : 'Service Enquiry';
                              rating = (service?.rating ?? 0).toString();
                              image = (service?.primaryImageUrl ?? 0)
                                  .toString();
                              ratingCount = (service?.ratingCount ?? 0)
                                  .toString();
                              if (service != null && service.startsAt > 0) {
                                priceText = 'From ₹${service.startsAt}';
                              } else {
                                priceText = 'Service';
                              }
                            } else if (type == 'PRODUCT') {
                              productTitle =
                                  data.product?.name.toString() ?? '';
                              priceText = '${data.product?.price ?? ''}';
                              offerPrice = '₹${data.product?.offerPrice ?? ''}';
                              image = data.product?.imageUrl ?? '';
                              rating = '${data.product?.rating ?? ''}';
                              ratingCount =
                                  '${data.product?.ratingCount ?? ''}';
                            } else if (type == 'SERVICE') {
                              productTitle =
                                  data.service?.name.toString() ?? '';
                              offerPrice = '₹${data.service?.startsAt ?? ''}';

                              image = data.service?.primaryImageUrl ?? '';
                              rating = '${data.service?.rating ?? ''}';
                              ratingCount =
                                  '${data.service?.ratingCount ?? ''}';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Column(
                                children: [
                                  CommonContainer.inquiryProductCard(
                                    questionText: '',
                                    productTitle: productTitle,
                                    rating: rating,
                                    ratingCount: ratingCount,
                                    priceText: offerPrice,
                                    mrpText: '$priceText',
                                    phoneImageAsset: image,
                                    avatarAsset: customerImg,
                                    customerName: customerName,
                                    timeText: timeText,
                                    onChatTap: () {
                                      CallHelper.openWhatsapp(
                                        context: context,
                                        phone: whatsappNumber,
                                      );
                                      ref
                                          .read(homeNotifierProvider.notifier)
                                          .markEnquiry(enquiryId: data.id);
                                      ref
                                          .read(selectedShopProvider.notifier)
                                          .switchShop('');
                                    },
                                    onCallTap: () {
                                      CallHelper.openDialer(
                                        context: context,
                                        rawPhone: phone,
                                      );
                                      ref
                                          .read(homeNotifierProvider.notifier)
                                          .markEnquiry(enquiryId: data.id);
                                      ref
                                          .read(selectedShopProvider.notifier)
                                          .switchShop('');
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        ),
                    ] else ...[
                      // ================== NON-TEXTILES BRANCH (NO FOOD WASTAGE etc.) ==================
                      // (your existing non-textiles UI unchanged)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.05,
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
                                    const Expanded(flex: 1, child: SizedBox()),
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
                                              shadows: const [
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
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                      TextSpan(
                                                        text: '1.30Pm',
                                                        style:
                                                            AppTextStyles.mulish(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                      const SizedBox(height: 50),
                      // ... your remaining non-textiles UI (Food Orders cards etc.) ...
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(
    int index,
    String value,
    String label,
    String image,
    VoidCallback? onTap,
  ) {
    final bool isSelected = selectIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectIndex = index);
        onTap?.call();
      },
      // onTap: () {
      //   setState(() {
      //     selectIndex = index;
      //   });
      // },
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
*/
