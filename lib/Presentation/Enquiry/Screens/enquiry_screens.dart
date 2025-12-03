import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/call_helper.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/Home/Controller/home_notifier.dart';

import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Home/Model/shops_response.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';

class EnquiryScreens extends ConsumerStatefulWidget {
  const EnquiryScreens({super.key});

  @override
  ConsumerState<EnquiryScreens> createState() => _EnquiryScreensState();
}

class _EnquiryScreensState extends ConsumerState<EnquiryScreens> {
  int selectedIndex = 0; // 0 = Unanswered, 1 = Answered

  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';
  final GlobalKey _filterKey = GlobalKey();

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

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

    final enquiry = homeState.enquiryResponse;
    final shopsRes = homeState.shopsResponse;

    final List<Shop> shops = shopsRes?.data.items ?? [];
    final bool hasShops = shops.isNotEmpty;

    bool hasEnquiries = false;
    final enquiryData = enquiry?.data;
    if (enquiryData != null) {
      final openItems = enquiryData.open.items;
      final closedItems = enquiryData.closed.items;
      hasEnquiries = openItems.isNotEmpty || closedItems.isNotEmpty;
    }

    // ✅ GLOBAL "NO DATA FOUND" (no shops + no enquiries + not loading)
    if (!homeState.isLoading && !hasShops && !hasEnquiries) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: NoDataScreen(
              showTopBackArrow: false,
              showBottomButton: false,
            ),
            // Text(
            //   'No data found',
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            // ),
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
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(homeNotifierProvider.notifier).fetchShops();
                await ref.read(homeNotifierProvider.notifier).fetchAllEnquiry();
              },
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
                    if (shops.isEmpty) ...[
                      CommonContainer.smallShopContainer(
                        shopImage: '',
                        shopLocation: '',
                        shopName: '',
                      ),
                    ] else ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: shops.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final shop = shops[index];
                            return Row(
                              children: [
                                CommonContainer.smallShopContainer(
                                  shopImage: shop.primaryImageUrl ?? '',
                                  shopLocation:
                                      '${shop.addressEn}, ${shop.city}',
                                  shopName: shop.englishName,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],

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
                                              onTap: () =>
                                                  Navigator.pop(context),
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
                                          onTap: () => Navigator.pop(
                                            context,
                                            'Yesterday',
                                          ),
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
                                                    colorScheme:
                                                        ColorScheme.light(
                                                          primary: AppColor
                                                              .brightBlue,
                                                          onPrimary:
                                                              Colors.white,
                                                          onSurface:
                                                              AppColor.black,
                                                        ),
                                                    textButtonTheme:
                                                        TextButtonThemeData(
                                                          style: TextButton.styleFrom(
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
                    // SizedBox(height: 20),
                    // Text(
                    //   'Today',
                    //   style: AppTextStyles.mulish(
                    //     fontSize: 12,
                    //     color: AppColor.darkGrey,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    SizedBox(height: 20),
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
                          String whatsappNumber = data.customer.whatsappNumber;
                          String phone = data.customer.phone;
                          String customerImg = data.customer.avatarUrl
                              .toString();
                          String timeText = data.createdTime;

                          if (type == 'PRODUCT_SHOP') {
                            final shop = data.shop;
                            productTitle =
                                (shop?.englishName.toUpperCase() ?? '')
                                    .isNotEmpty
                                ? shop!.englishName.toUpperCase()
                                : 'Shop Enquiry';
                            rating = (shop?.rating ?? 0).toString();
                            ratingCount = (shop?.ratingCount ?? 0).toString();
                            priceText = '${shop?.category.toUpperCase() ?? ''}';
                            image = shop?.primaryImageUrl ?? '';
                          } else if (type == 'PRODUCT_SERVICE' ||
                              type == 'SERVICE_SHOP') {
                            final service = data.service;
                            productTitle = (service?.name ?? '').isNotEmpty
                                ? service!.name
                                : 'Service Enquiry';
                            rating = (service?.rating ?? 0).toString();
                            ratingCount = (service?.ratingCount ?? 0)
                                .toString();
                            if (service != null && service.startsAt > 0) {
                              priceText = 'From ₹${service.startsAt}';
                            } else {
                              priceText = 'Service';
                            }
                          } else if (type == 'PRODUCT') {
                            productTitle = data.product?.name.toString() ?? '';
                            priceText = '${data.product?.price ?? ''}';
                            offerPrice = '₹${data.product?.offerPrice ?? ''}';
                            image = data.product?.imageUrl ?? '';
                            rating = '₹${data.product?.rating ?? ''}';
                            ratingCount = '₹${data.product?.ratingCount ?? ''}';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                CommonContainer.inquiryProductCard(
                                  questionText: '',
                                  productTitle: productTitle,
                                  rating: rating,
                                  ratingCount: ratingCount,
                                  priceText: priceText,
                                  mrpText: '$offerPrice',
                                  phoneImageAsset: image,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
