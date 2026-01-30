import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../Create Surprise Offers/Controller/create_surprise_notifier.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../Controller/home_notifier.dart';
import '../Controller/shopContext_provider.dart';

enum AnalyticsMode { enquiry, call, location }

class HomeScreenAnalytics extends ConsumerStatefulWidget {
  const HomeScreenAnalytics({super.key});

  @override
  ConsumerState<HomeScreenAnalytics> createState() =>
      _HomeScreenAnalyticsState();
}

class _HomeScreenAnalyticsState extends ConsumerState<HomeScreenAnalytics>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int selectedAnalytics = 0; // 0=enquiry,1=call,2=location
  int _selectedTab = 0; // 0=unanswered, 1=answered (ONLY enquiry)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // ✅ If you already have enquiry api in home notifier, call it here
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // load shops etc (optional)
      await _initialLoad();

      // If your home_notifier has this method (you used it in HomeScreens)
      // this will fill enquiryResponse used below.
      try {
        await ref
            .read(homeNotifierProvider.notifier)
            .fetchAllEnquiry(shopId: '');
      } catch (_) {
        // ignore if method not present
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // -------------------- LOADERS --------------------

  Future<void> _initialLoad({String? forceShopId}) async {
    await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');

    final homeState = ref.read(homeNotifierProvider);
    final shopsRes = homeState.shopsResponse;
    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
    if (!mounted) return;
    if (shops.isEmpty) return;

    final String sid = (forceShopId?.trim().isNotEmpty == true)
        ? forceShopId!.trim()
        : (ref.read(selectedShopProvider)?.toString().trim().isNotEmpty == true
              ? ref.read(selectedShopProvider)!.toString().trim()
              : (shops.first.id ?? '').toString().trim());

    if (sid.isEmpty) return;

    // surprise list api (your existing)
    await ref
        .read(createSurpriseNotifier.notifier)
        .surpriseOfferList(shopId: sid);
  }

  Future<void> _switchShopAndReload(dynamic shopId) async {
    final sid = (shopId ?? '').toString().trim();
    if (sid.isEmpty) return;
    ref.read(selectedShopProvider.notifier).switchShop(sid);
    await _initialLoad(forceShopId: sid);

    // optional: fetch enquiry for this shop
    try {
      await ref
          .read(homeNotifierProvider.notifier)
          .fetchAllEnquiry(shopId: sid);
    } catch (_) {}
  }

  // -------------------- UI HELPERS --------------------

  void _onAnalyticsTap(int i) {
    setState(() {
      selectedAnalytics = i;
      _selectedTab = 0; // ✅ reset tab when switching enquiry/call/location
    });
  }

  AnalyticsMode get _mode {
    if (selectedAnalytics == 1) return AnalyticsMode.call;
    if (selectedAnalytics == 2) return AnalyticsMode.location;
    return AnalyticsMode.enquiry;
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    final shopsRes = homeState.shopsResponse;
    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
    final bool isFreemium = shopsRes?.data.subscription?.isFreemium ?? true;

    // ✅ ENQUIRY DATA (same structure you used in HomeScreens)
    final enquiryRes =
        homeState.enquiryResponse; // must exist in your HomeState
    final enquiryData = enquiryRes?.data;

    final openItems = enquiryData?.open.items ?? [];
    final closedItems = enquiryData?.closed.items ?? [];
    final unansweredCount = openItems.length;
    final answeredCount = closedItems.length;

    final enquiryItems = (_selectedTab == 0) ? openItems : closedItems;

    // ✅ CALL & LOCATION LISTS
    // Replace these with your real API lists when ready.
    final List<dynamic> callItems =
        <dynamic>[]; // TODO: homeState.callResponse?.data.items ?? [];
    final List<dynamic> locationItems =
        <dynamic>[]; // TODO: homeState.locationResponse?.data.items ?? [];

    List<dynamic> currentItems;
    if (_mode == AnalyticsMode.enquiry) {
      currentItems = enquiryItems;
    } else if (_mode == AnalyticsMode.call) {
      currentItems = callItems;
    } else {
      currentItems = locationItems;
    }

    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ---------------- TOP GRADIENT + SHOPS ----------------
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColor.white, AppColor.lightGray],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: CommonContainer.topLeftArrow(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // shops scroller
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
                                            builder: (_) =>
                                                SubscriptionScreen(),
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
                                  shopImage: shop.primaryImageUrl ?? '',
                                  shopName: shop.englishName,
                                  shopLocation:
                                      '${shop.addressEn}, ${shop.city}',
                                  onTap: () async =>
                                      _switchShopAndReload(shop.id),
                                  switchOnTap: () async =>
                                      _switchShopAndReload(shop.id),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 33),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------- ANALYTICS BODY ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Text(
                        'Analytics',
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✅ top switch (Enquiry / Call / Location)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.5),
                        child: Row(
                          children: [
                            CommonContainer.analyticsRowBox(
                              image: AppImages.messageImage,
                              text: 'Enquiry',
                              isSelected: selectedAnalytics == 0,
                              onTap: () => _onAnalyticsTap(0),
                            ),
                            const SizedBox(width: 20),
                            CommonContainer.analyticsRowBox(
                              image: AppImages.callImage,
                              text: 'Call',
                              isSelected: selectedAnalytics == 1,
                              onTap: () => _onAnalyticsTap(1),
                            ),
                            const SizedBox(width: 20),
                            CommonContainer.analyticsRowBox(
                              image: AppImages.locationImage,
                              text: 'Location',
                              isSelected: selectedAnalytics == 2,
                              onTap: () => _onAnalyticsTap(2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ✅ enquiry tabs ONLY
                      if (_mode == AnalyticsMode.enquiry) ...[
                        _enquiryTabs(
                          unansweredCount: unansweredCount,
                          answeredCount: answeredCount,
                        ),
                        const SizedBox(height: 30),
                      ],

                      // ✅ content changes below based on selectedAnalytics & selectedTab
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: Container(
                          key: ValueKey('${selectedAnalytics}_$_selectedTab'),
                          child: _buildTodayListSection(
                            mode: _mode,
                            items: currentItems,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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

  // -------------------- WIDGETS --------------------

  Widget _enquiryTabs({
    required int unansweredCount,
    required int answeredCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _tabChip(
              title: '$unansweredCount Un Answered',
              index: 0,
              selectedIndex: _selectedTab,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            const SizedBox(width: 10),
            _tabChip(
              title: '$answeredCount Answered',
              index: 1,
              selectedIndex: _selectedTab,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayListSection({
    required AnalyticsMode mode,
    required List<dynamic> items,
  }) {
    return Column(
      children: [
        Text(
          'Today',
          style: AppTextStyles.mulish(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColor.darkGrey,
          ),
        ),
        const SizedBox(height: 15),

        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Text(
              'No data found',
              style: AppTextStyles.mulish(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.darkGrey,
              ),
            ),
          )
        else
          Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _analyticsCard(mode: mode, item: item),
              );
            }),
          ),
      ],
    );
  }

  Widget _analyticsCard({required AnalyticsMode mode, required dynamic item}) {
    // ✅ TODO: map your real fields here
    // For enquiry items (from your enquiryResponse), you can do:
    // final customerName = item.customer?.name ?? '';
    // final timeText = item.createdTime ?? '';
    //
    // For now safe fallback:
    final String productTitle = (item?.title ?? item?.name ?? 'productTitle')
        .toString();
    final String rating = (item?.rating ?? '0').toString();
    final String ratingCount = (item?.ratingCount ?? '0').toString();
    final String priceText = (item?.priceText ?? 'priceText').toString();
    final String mrpText = (item?.mrpText ?? 'mrpText').toString();
    final String customerName =
        (item?.customerName ?? item?.customer?.name ?? 'customerName')
            .toString();
    final String timeText = (item?.timeText ?? item?.createdTime ?? 'timeText')
        .toString();

    final String imageUrl =
        (item?.imageUrl ??
                item?.primaryImageUrl ??
                item?.shop?.primaryImageUrl ??
                AppImages.imageContainer2)
            .toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColor.floralWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PRODUCT CARD ---
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFFF8FBF8)),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColor.black.withOpacity(0.06),
                          AppColor.black.withOpacity(0.02),
                          AppColor.black.withOpacity(0.00),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // rating pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF31CC64),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$rating ',
                                    style: AppTextStyles.mulish(
                                      fontSize: 12,
                                      color: AppColor.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ratingCount,
                                    style: AppTextStyles.mulish(
                                      fontSize: 12,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    priceText,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.mulish(
                                      fontSize: 14,
                                      color: AppColor.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  mrpText,
                                  style: AppTextStyles.mulish(
                                    fontSize: 14,
                                    color: const Color(0xFF888888),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // --- DOTTED + ACTIONS ROW ---
          Row(
            children: [
              Expanded(
                child: DottedBorder(
                  color: Colors.grey.shade300,
                  strokeWidth: 1.2,
                  dashPattern: const [4, 3],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          customerName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mulish(
                            fontSize: 12,
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        timeText,
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          color: AppColor.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  // TODO: call action for call/location/enquiry based on `mode`
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.skyBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    AppImages.callImage,
                    color: AppColor.white,
                    height: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // TODO: whatsapp action
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    AppImages.whatsappImage,
                    color: AppColor.white,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabChip({
    required String title,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.darkBlue : AppColor.borderLightGrey,
            width: 1.5,
          ),
          color: AppColor.white,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mulish(
            color: isSelected ? AppColor.darkBlue : AppColor.borderLightGrey,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import 'package:tringo_vendor/Core/Const/app_color.dart';
// import 'package:tringo_vendor/Core/Const/app_images.dart';
// import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
//
// import '../../../Core/Routes/app_go_routes.dart';
// import '../../../Core/Utility/common_Container.dart';
// import '../../Create Surprise Offers/Controller/create_surprise_notifier.dart';
// import '../../Menu/Screens/subscription_screen.dart';
// import '../Controller/home_notifier.dart';
// import '../Controller/shopContext_provider.dart';
//
// class HomeScreenAnalytics extends ConsumerStatefulWidget {
//   const HomeScreenAnalytics({super.key});
//
//   @override
//   ConsumerState<HomeScreenAnalytics> createState() =>
//       _HomeScreenAnalyticsState();
// }
//
// class _HomeScreenAnalyticsState extends ConsumerState<HomeScreenAnalytics>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   int selectedAnalytics = 0; // 0=enquiry,1=call,2=location
//   int _selectedTab = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initialLoad({String? forceShopId}) async {
//     // 1) fetch shops
//     await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
//
//     final homeState = ref.read(homeNotifierProvider);
//     final shopsRes = homeState.shopsResponse;
//     final List<dynamic> shops =
//         (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
//
//     if (!mounted) return;
//
//     if (shops.isEmpty) {
//       return;
//     }
//
//     // ✅ always prefer real shopId from list / user tap
//     final String sid = (forceShopId?.trim().isNotEmpty == true)
//         ? forceShopId!.trim()
//         : (ref.read(selectedShopProvider)?.toString().trim().isNotEmpty == true
//               ? ref.read(selectedShopProvider)!.toString().trim()
//               : (shops.first.id ?? '').toString().trim());
//
//     if (sid.isEmpty) return;
//
//     // 2) call surprise list api
//     await ref
//         .read(createSurpriseNotifier.notifier)
//         .surpriseOfferList(shopId: sid);
//   }
//
//   Future<void> _switchShopAndReload(dynamic shopId) async {
//     final sid = (shopId ?? '').toString().trim();
//     if (sid.isEmpty) return;
//
//     // store selected shop
//     ref.read(selectedShopProvider.notifier).switchShop(sid);
//
//     await _initialLoad(forceShopId: sid);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final homeState = ref.watch(homeNotifierProvider);
//
//     final shopsRes = homeState.shopsResponse;
//     final List<dynamic> shops =
//         (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
//
//     final bool isFreemium = shopsRes?.data.subscription?.isFreemium ?? true;
//
//     return Skeletonizer(
//       enabled: homeState.isLoading,
//       enableSwitchAnimation: true,
//       child: Scaffold(
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [AppColor.white, AppColor.lightGray],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     borderRadius: BorderRadius.only(
//                       bottomRight: Radius.circular(20),
//                       bottomLeft: Radius.circular(20),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 5,
//                         ),
//                         child: CommonContainer.topLeftArrow(
//                           onTap: () => Navigator.pop(context),
//                         ),
//                       ),
//
//                       const SizedBox(height: 30),
//
//                       // Shops scroller
//                       if (shops.isEmpty) ...[
//                         CommonContainer.smallShopContainer(
//                           addAnotherShop: true,
//                           shopImage: '',
//                           shopName: 'Add Another Shop',
//                           shopLocation: 'Upgrade to add branch',
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => SubscriptionScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       ] else ...[
//                         SizedBox(
//                           height: 120,
//                           child: ListView.builder(
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             scrollDirection: Axis.horizontal,
//                             physics: const BouncingScrollPhysics(),
//
//                             // ✅ ALWAYS +1 for "Add Another Shop"
//                             itemCount: shops.length + 1,
//
//                             itemBuilder: (context, index) {
//                               // ✅ LAST ITEM → Add Another Shop (always)
//                               if (index == shops.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(right: 10),
//                                   child: CommonContainer.smallShopContainer(
//                                     addAnotherShop: true,
//                                     shopImage: '',
//                                     shopName: 'Add Another Shop',
//                                     shopLocation: isFreemium
//                                         ? 'Upgrade to add branch'
//                                         : 'Add a new branch',
//                                     onTap: () {
//                                       if (isFreemium) {
//                                         // 🔒 Freemium → subscription
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 SubscriptionScreen(),
//                                           ),
//                                         );
//                                       } else {
//                                         // ✅ Premium → add shop flow
//                                         final bool isService =
//                                             shopsRes?.data.items.first.shopKind
//                                                 .toUpperCase() ==
//                                             'SERVICE';
//
//                                         context.push(
//                                           AppRoutes.shopCategoryInfoPath,
//                                           extra: {
//                                             'isService': isService,
//                                             'isIndividual': '',
//                                             'initialShopNameEnglish': shopsRes
//                                                 ?.data
//                                                 .items
//                                                 .first
//                                                 .englishName,
//                                             'initialShopNameTamil': shopsRes
//                                                 ?.data
//                                                 .items
//                                                 .first
//                                                 .tamilName,
//                                             'isEditMode': true,
//                                           },
//                                         );
//                                       }
//                                     },
//                                   ),
//                                 );
//                               }
//
//                               // ✅ NORMAL SHOP ITEM
//                               final shop = shops[index];
//
//                               return Padding(
//                                 padding: const EdgeInsets.only(right: 10),
//                                 child: CommonContainer.smallShopContainer(
//                                   shopImage: shop.primaryImageUrl ?? '',
//                                   shopName: shop.englishName,
//                                   shopLocation:
//                                       '${shop.addressEn}, ${shop.city}',
//                                   onTap: () {
//                                     ref
//                                         .read(selectedShopProvider.notifier)
//                                         .switchShop(shop.id);
//                                   },
//                                   switchOnTap: () {
//                                     ref
//                                         .read(selectedShopProvider.notifier)
//                                         .switchShop(shop.id);
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 33),
//                       ],
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 25),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Analytics',
//                         style: AppTextStyles.mulish(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 20,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(height: 30),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15.5),
//                         child: Row(
//                           children: [
//                             CommonContainer.analyticsRowBox(
//                               image: AppImages.messageImage,
//                               text: 'Enquiry',
//                               isSelected: selectedAnalytics == 0,
//                               onTap: () =>
//                                   setState(() => selectedAnalytics = 0),
//                             ),
//                             const SizedBox(width: 20),
//                             CommonContainer.analyticsRowBox(
//                               image: AppImages.callImage,
//                               text: 'Call',
//                               isSelected: selectedAnalytics == 1,
//                               onTap: () =>
//                                   setState(() => selectedAnalytics = 1),
//                             ),
//                             const SizedBox(width: 20),
//                             CommonContainer.analyticsRowBox(
//                               image: AppImages.locationImage,
//                               text: 'Location',
//                               isSelected: selectedAnalytics == 2,
//                               onTap: () =>
//                                   setState(() => selectedAnalytics = 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 30),
//
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 0),
//                         child: SingleChildScrollView(
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           scrollDirection: Axis.horizontal,
//                           physics: const BouncingScrollPhysics(),
//                           child: Row(
//                             children: [
//                               _tabChip(
//                                 title: '10 Un Answered',
//                                 index: 0,
//                                 selectedIndex: _selectedTab,
//                                 onTap: () {},
//                                 // onTap: () => _onTabTap(0),
//                               ),
//                               const SizedBox(width: 10),
//                               _tabChip(
//                                 title: '50 Answered',
//                                 index: 1,
//                                 selectedIndex: _selectedTab,
//                                 onTap: () {},
//                                 // onTap: () => _onTabTap(1),
//                               ),
//                               const SizedBox(width: 10),
//                               // _tabChip(
//                               //   title: '$expiredCount Expired',
//                               //   index: 2,
//                               //   selectedIndex: _selectedTab,
//                               //   onTap: () => _onTabTap(2),
//                               // ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 30),
//                       Text(
//                         'Today',
//                         style:
//                         AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: AppColor
//                               .darkGrey,
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 20,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColor.floralWhite,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             // --- PRODUCT CARD ---
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(24),
//                                 // boxShadow: [
//                                 //   BoxShadow(
//                                 //     color: Colors.black.withOpacity(0.05),
//                                 //     blurRadius: 10,
//                                 //     offset: const Offset(0, 4),
//                                 //   ),
//                                 // ],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(24),
//                                 child: Stack(
//                                   children: [
//                                     const Positioned.fill(
//                                       child: ColoredBox(
//                                         color: Color(0xFFF8FBF8),
//                                       ),
//                                     ),
//                                     Positioned.fill(
//                                       child: DecoratedBox(
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             begin: Alignment.centerLeft,
//                                             end: Alignment.centerRight,
//                                             colors: [
//                                            AppColor.black.withOpacity(0.06),
//                                               AppColor.black.withOpacity(0.02),
//                                               AppColor.black.withOpacity(0.00),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 14,
//                                               vertical: 14,
//                                             ),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   'productTitle',
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: AppTextStyles.mulish(
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 8),
//
//                                                 // rating pill
//                                                 Container(
//                                                   padding:
//                                                       const EdgeInsets.symmetric(
//                                                         horizontal: 10,
//                                                         vertical: 4,
//                                                       ),
//                                                   decoration: BoxDecoration(
//                                                     color: const Color(
//                                                       0xFF31CC64,
//                                                     ),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           20,
//                                                         ),
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       Text(
//                                                         'rating ',
//                                                         style:
//                                                             AppTextStyles.mulish(
//                                                               fontSize: 12,
//                                                               color: AppColor
//                                                                   .white,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                       ),
//                                                       const Icon(
//                                                         Icons.star,
//                                                         size: 14,
//                                                         color: Colors.white,
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         'ratingCount',
//                                                         style:
//                                                             AppTextStyles.mulish(
//                                                               fontSize: 12,
//                                                               color: AppColor
//                                                                   .white,
//                                                             ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//
//                                                 const SizedBox(height: 10),
//
//                                                 Row(
//                                                   children: [
//                                                     Flexible(
//                                                       child: Text(
//                                                         'priceText',
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         style:
//                                                             AppTextStyles.mulish(
//                                                               fontSize: 14,
//                                                               color: AppColor
//                                                                   .black,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 8),
//                                                     Text(
//                                                       'mrpText',
//                                                       style:
//                                                           AppTextStyles.mulish(
//                                                             fontSize: 14,
//                                                             color: const Color(
//                                                               0xFF888888,
//                                                             ),
//                                                             decoration:
//                                                                 TextDecoration
//                                                                     .lineThrough,
//                                                           ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//
//                                         // image
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                             15,
//                                           ),
//                                           child: CachedNetworkImage(
//                                             imageUrl: AppImages
//                                                 .imageContainer2, // network url
//                                             width: 100,
//                                             height: 100,
//                                             fit: BoxFit.cover,
//                                             placeholder: (_, __) => Container(
//                                               width: 100,
//                                               height: 100,
//                                               color: Colors.grey.shade200,
//                                             ),
//                                             errorWidget: (_, __, ___) =>
//                                                 const Icon(
//                                                   Icons.broken_image,
//                                                   size: 40,
//                                                   color: Colors.grey,
//                                                 ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 12),
//
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: DottedBorder(
//                                     color: Colors.grey.shade300,
//                                     strokeWidth: 1.2,
//                                     dashPattern: const [4, 3],
//                                     borderType: BorderType.RRect,
//                                     radius: const Radius.circular(30),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 8,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             'customerName',
//                                             overflow: TextOverflow.ellipsis,
//                                             style: AppTextStyles.mulish(
//                                               fontSize: 12,
//                                               color: AppColor.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Text(
//                                           'timeText',
//                                           style: AppTextStyles.mulish(
//                                             fontSize: 12,
//                                             color: AppColor.darkGrey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 15,
//                                       vertical: 7,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: AppColor.skyBlue,
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Image.asset(
//                                       AppImages.callImage,
//                                       color: AppColor.white,
//                                       height: 18,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 15,
//                                       vertical: 7,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: AppColor.green,
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Image.asset(
//                                       AppImages.whatsappImage,
//                                       color: AppColor.white,
//                                       height: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _tabChip({
//     required String title,
//     required int index,
//     required int selectedIndex,
//     required VoidCallback onTap,
//   }) {
//     final bool isSelected = selectedIndex == index;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         curve: Curves.easeInOut,
//         padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? AppColor.darkBlue : AppColor.borderLightGrey,
//             width: 1.5,
//           ),
//           color: AppColor.white,
//         ),
//         child: Text(
//           title,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: AppTextStyles.mulish(
//             color: isSelected ? AppColor.darkBlue : AppColor.borderLightGrey,
//             fontWeight: FontWeight.w800,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }
