import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Utility/app_loader.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Presentation/Home/Model/enquiry_analytics_response.dart';
import 'package:tringo_owner/Presentation/Home/Model/shops_response.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/call_helper.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../Create Surprise Offers/Controller/create_surprise_notifier.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../Controller/home_notifier.dart';
import '../Controller/shopContext_provider.dart';

class HomeScreenAnalytics extends ConsumerStatefulWidget {
  final String shopId;
  final AnalyticsType initialType;
  final int initialIndex;
  const HomeScreenAnalytics({
    super.key,
    required this.shopId,
    this.initialIndex = 0,
    this.initialType = AnalyticsType.enquiries,
  });

  @override
  ConsumerState<HomeScreenAnalytics> createState() =>
      _HomeScreenAnalyticsState();
}

class _HomeScreenAnalyticsState extends ConsumerState<HomeScreenAnalytics>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int selectedAnalytics = 0;

  int _selectedTab = 0;

  // ✅ Dynamic date range
  late String _start;
  late String _end;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // ✅ set dynamic dates (current month start → today)
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    _start = _ymd(firstDay);
    _end = _ymd(now);

    // ✅ apply initial selection immediately
    selectedAnalytics = widget.initialIndex;
    _selectedTab = 0; // default Unanswered (open)

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ set initial type + status in provider
      ref
          .read(homeNotifierProvider.notifier)
          .setAnalyticsType(widget.initialType);
      ref
          .read(homeNotifierProvider.notifier)
          .setAnalyticsStatus(AnalyticsStatus.open);

      // your other calls
      // await _initialLoad();

      // ✅ refresh based on selected tab + type (uses _selectedTab take logic)
      await _refreshCurrent();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(vsync: this);
  //
  //   // ✅ set dynamic dates (current month start → today)
  //   final now = DateTime.now();
  //   final firstDay = DateTime(now.year, now.month, 1);
  //   _start = _ymd(firstDay);
  //   _end = _ymd(now);
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await _initialLoad();
  //
  //     // ✅ first analytics load (dynamic)
  //     await ref.read(homeNotifierProvider.notifier).refreshAnalytics(
  //       shopId: widget.shopId,
  //       start: _start,
  //       end: _end,
  //       take: 10,
  //     );
  //   });
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  late ShopsResponse? shopsRes;
  String? shopIdVar;
  Future<void> _initialLoad() async {
    // 1) fetch shops
    shopsRes = await ref
        .read(homeNotifierProvider.notifier)
        .fetchShops(shopId: '');

    shopIdVar = shopsRes?.data.items[0].id; // adjust to your model
    if (!mounted) return;

    // 2) call surprise list api
    await ref
        .read(createSurpriseNotifier.notifier)
        .surpriseOfferList(shopId: widget.shopId);
  }

  // ✅ Professional empty state
  Widget _emptyState({
    required AnalyticsType type,
    required AnalyticsStatus status,
  }) {
    final typeText = switch (type) {
      AnalyticsType.enquiries => "Enquiries",
      AnalyticsType.calls => "Calls",
      AnalyticsType.locations => "Locations",
    };

    final statusText = (status == AnalyticsStatus.open)
        ? "Unanswered"
        : "Answered";

    final title = "No $statusText $typeText";
    final subtitle =
        "There are no $statusText ${typeText.toLowerCase()} "
        "for the selected date range.";

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.mulish(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.mulish(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshCurrent() async {
    await ref
        .read(homeNotifierProvider.notifier)
        .refreshAnalytics(
          shopId: widget.shopId,
          /* shopId: shopIdVar ?? '',*/
          start: _start,
          end: _end,
          take: (_selectedTab == 0) ? 10 : 50,
        );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    final type = homeState.selectedAnalyticsType;
    final key = (type == AnalyticsType.enquiries)
        ? "enquiries"
        : (type == AnalyticsType.calls)
        ? "calls"
        : "locations";

    final page = homeState.analyticsPages[key] ?? const AnalyticsPageState();

    final shopsRes = homeState.shopsResponse;
    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];

    final bool isFreemium = shopsRes?.data.subscription?.isFreemium ?? true;

    // counts
    final counts = homeState.enquiryAnalyticsResponse?.data.counts;
    int openCount = 0;
    int closedCount = 0;

    if (counts != null) {
      switch (homeState.selectedAnalyticsType) {
        case AnalyticsType.enquiries:
          openCount = counts.enquiries.open;
          closedCount = counts.enquiries.closed;
          break;
        case AnalyticsType.calls:
          openCount = counts.calls.open;
          closedCount = counts.calls.closed;
          break;
        case AnalyticsType.locations:
          openCount = counts.locations.open;
          closedCount = counts.locations.closed;
          break;
      }
    }

    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              // ✅ pagination from outer scroll
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 250) {
                ref
                    .read(homeNotifierProvider.notifier)
                    .loadMoreAnalytics(
                      shopId: widget.shopId,
                      start: _start,
                      end: _end,
                    );
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // header
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
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
                                              shopsRes
                                                  ?.data
                                                  .items
                                                  .first
                                                  .shopKind
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
                                final bool showSwitch = shops.length > 1;
                                final shop = shops[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: CommonContainer.smallShopContainer(
                                    shopImage: shop.primaryImageUrl ?? '',
                                    shopName: shop.englishName,
                                    showSwitch: showSwitch,
                                    shopLocation:
                                        '${shop.addressEn}, ${shop.city}',
                                    onTap: () async {
                                      ref
                                          .read(selectedShopProvider.notifier)
                                          .switchShop(shop.id);
                                      await ref
                                          .read(homeNotifierProvider.notifier)
                                          .refreshAnalytics(
                                            /*   shopId: widget.shopId,*/
                                            shopId: shop.id ?? '',
                                            start: _start,
                                            end: _end,
                                            take: (_selectedTab == 0) ? 10 : 50,
                                          );
                                    },
                                    switchOnTap: () async {
                                      ref
                                          .read(selectedShopProvider.notifier)
                                          .switchShop(shop.id);
                                      await ref
                                          .read(homeNotifierProvider.notifier)
                                          .refreshAnalytics(
                                        /*   shopId: widget.shopId,*/
                                        shopId: shop.id ?? '',
                                        start: _start,
                                        end: _end,
                                        take: (_selectedTab == 0) ? 10 : 50,
                                      );
                                    },
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

                        // type row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.5),
                          child: Row(
                            children: [
                              CommonContainer.analyticsRowBox(
                                image: AppImages.messageImage,
                                text: 'Enquiry',
                                isSelected: selectedAnalytics == 0,
                                onTap: () async {
                                  setState(() => selectedAnalytics = 0);
                                  ref
                                      .read(homeNotifierProvider.notifier)
                                      .setAnalyticsType(
                                        AnalyticsType.enquiries,
                                      );
                                  await _refreshCurrent();
                                },
                              ),
                              const SizedBox(width: 20),
                              CommonContainer.analyticsRowBox(
                                image: AppImages.callImage,
                                text: 'Call',
                                isSelected: selectedAnalytics == 1,
                                onTap: () async {
                                  setState(() => selectedAnalytics = 1);
                                  ref
                                      .read(homeNotifierProvider.notifier)
                                      .setAnalyticsType(AnalyticsType.calls);
                                  await _refreshCurrent();
                                },
                              ),
                              const SizedBox(width: 20),
                              CommonContainer.analyticsRowBox(
                                image: AppImages.locationImage,
                                text: 'Location',
                                isSelected: selectedAnalytics == 2,
                                onTap: () async {
                                  setState(() => selectedAnalytics = 2);
                                  ref
                                      .read(homeNotifierProvider.notifier)
                                      .setAnalyticsType(
                                        AnalyticsType.locations,
                                      );
                                  await _refreshCurrent();
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // status chips
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _tabChip(
                                title: '$openCount Unanswered',
                                index: 0,
                                selectedIndex: _selectedTab,
                                onTap: () async {
                                  setState(() => _selectedTab = 0);
                                  ref
                                      .read(homeNotifierProvider.notifier)
                                      .setAnalyticsStatus(AnalyticsStatus.open);
                                  await _refreshCurrent();
                                },
                              ),
                              const SizedBox(width: 10),
                              _tabChip(
                                title: '$closedCount Answered',
                                index: 1,
                                selectedIndex: _selectedTab,
                                onTap: () async {
                                  setState(() => _selectedTab = 1);
                                  ref
                                      .read(homeNotifierProvider.notifier)
                                      .setAnalyticsStatus(
                                        AnalyticsStatus.closed,
                                      );
                                  await _refreshCurrent();
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ✅ loader + empty + list
                        if (page.isLoading && page.sections.isEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(top: 25, bottom: 40),
                            child: Center(
                              child: ThreeDotsLoader(
                                dotColor: AppColor.darkBlue,
                              ),
                            ),
                          ),
                        ] else if (page.sections.isEmpty) ...[
                          _emptyState(
                            type: homeState.selectedAnalyticsType,
                            status: homeState.selectedAnalyticsStatus,
                          ),
                        ] else ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: page.sections.length,
                            itemBuilder: (context, index) {
                              final section = page.sections[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                      top: 10,
                                    ),
                                    child: Center(
                                      child: Text(
                                        section.dayLabel,
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.darkGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...section.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _AnalyticsItemCard(
                                        item: item,
                                        selectedType:
                                            type, // ✅ pass current selected type
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                          if (page.isLoadingMore) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: AppLoader.circularLoader()),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

class _AnalyticsItemCard extends ConsumerWidget {
  final CommonItem item;
  final AnalyticsType selectedType;
  const _AnalyticsItemCard({required this.item, required this.selectedType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = (item.contextType ?? "").toUpperCase();

    // customer info
    final customerName = item.customer?.name ?? "Customer";
    final timeText = item.timeLabel ?? "";
    final phone = (item.customer?.phone ?? "").trim();
    final whatsapp = (item.customer?.whatsappNumber ?? phone).trim();

    // shop info
    final shopName = item.shop?.name ?? "Shop";
    final shopImage = item.shop?.primaryImageUrl ?? "";
    final name = item.shop?.name ?? "";
    final rating = (item.shop?.rating ?? 0).toString();
    final ratingCount = (item.shop?.ratingCount ?? 0).toString();

    // product info
    final productName = item.product?.name ?? "Product";
    final productImage = item.product?.primaryImageUrl ?? "";
    final productPrice = item.product?.price?.toString() ?? "";
    final productOffer = item.product?.offerPrice?.toString() ?? "";

    // service info (safe fallback – depends on your API model)
    final serviceName = item.service?.name ?? "Service";
    final serviceImage = item.service?.primaryImageUrl ?? "";
    final servicePrice = item.service?.price?.toString() ?? "";

    // ✅ decide what to show based on contextType
    String title;
    String imageUrl;
    String priceText = "";
    String mrpText = "";
    String questionText = "";

    if (ctx == "SHOP") {
      title = shopName;
      imageUrl = shopImage;
      priceText = "";
      mrpText = "";
      questionText = name;
    } else if (ctx == "PRODUCT") {
      title = productName;
      imageUrl = productImage.isNotEmpty ? productImage : shopImage;
      priceText = productOffer.isNotEmpty ? productOffer : productPrice;
      mrpText = productPrice;
    } else if (ctx == "SERVICE") {
      title = serviceName;
      imageUrl = serviceImage.isNotEmpty ? serviceImage : shopImage;
      priceText = servicePrice;
      mrpText = "";
    } else {
      // unknown fallback
      title = shopName;
      imageUrl = shopImage;
    }

    final avatarAsset = (item.customer?.avatarUrl ?? "").trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          CommonContainer.inquiryProductCard(
            questionText: '',
            productTitle: title,
            rating: rating,
            ratingCount: ratingCount,
            priceText: priceText,
            mrpText: mrpText,
            phoneImageAsset: imageUrl,
            avatarAsset: avatarAsset,
            customerName: customerName,
            timeText: timeText,
            onChatTap: () async {
              if (whatsapp.isEmpty) return;

              CallHelper.openWhatsapp(context: context, phone: whatsapp);

              final id =
                  item.id.toString() ??
                  ""; // ✅ change if your id field is different
              if (id.isEmpty) return;

              await ref
                  .read(homeNotifierProvider.notifier)
                  .markAnalyticsItem(
                    type: selectedType,
                    id: id,
                    shopId: item.shop?.id.toString() ?? '',
                  );
            },
            onCallTap: () async {
              if (phone.isEmpty) return;
              CallHelper.openDialer(context: context, rawPhone: phone);
              final id = item.id.toString() ?? "";
              if (id.isEmpty) return;

              await ref
                  .read(homeNotifierProvider.notifier)
                  .markAnalyticsItem(
                    type: selectedType,
                    id: id,
                    shopId: item.shop?.id.toString() ?? '',
                  );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
