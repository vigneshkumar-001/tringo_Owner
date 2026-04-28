import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

// OfferScreens.dart (FULL UPDATED)
// ✅ Fix: shopId missing -> "Shop not found" (shops//offers)
// ✅ Fix: screen open ஆனதும் automatic refresh (shops + offers load)
// ✅ Fix: shop switch tap -> immediately load offers for that shop
// ✅ Fix: RefreshIndicator -> always uses valid shopId

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Core/Widgets/qr_scanner_page.dart';

import 'package:tringo_owner/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/menu_screens.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_screen.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_history.dart';

import 'package:tringo_owner/Presentation/Create%20App%20Offer/Screens/create_app_offer.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';
import 'package:tringo_owner/Presentation/Home/Controller/shopContext_provider.dart';

import '../Model/offer_model.dart';

class OfferScreens extends ConsumerStatefulWidget {
  const OfferScreens({super.key});

  @override
  ConsumerState<OfferScreens> createState() => _OfferScreensState();
}

class _OfferScreensState extends ConsumerState<OfferScreens> {
  int selectedIndex = 0; // 0 live, 1 upcoming, 2 expired

  // ✅ auto selected date
  DateTime? selectedDate;
  String selectedDayLabel = '';

  bool _autoPickedOnce = false; // first load
  bool _autoPickedForTab = false; // when tab changes

  bool _initialAutoRefreshed = false;
  bool _calledOnce = false;

  void initState() {
    super.initState();
    // selectedDay = 'Today';
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final existingShops =
          ref.read(homeNotifierProvider).shopsResponse?.data.items ?? [];
      // await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');
      if (existingShops.isNotEmpty) {
        final selectedShopId = ref.read(selectedShopProvider);
        final shopId =
            ((selectedShopId ?? '').toString().trim().isNotEmpty
                    ? selectedShopId
                    : existingShops.first.id)
                .toString();
        _calledOnce = true;

        AppLogger.log.i("Shop already exists: $shopId");
        await ref
            .read(offerNotifierProvider.notifier)
            .offerScreenEnquiry(shopId: shopId);

        return; // ✅ stop here, no need to listen
        // // ✅ 2) If shops not loaded, fetch shops now
        //
        //
        // // ✅ 3) Listen for shops response (only once)
        // _homeSub = ref.listenManual<HomeState>(
        //   homeNotifierProvider,
        //       (prev, next) async {
        //     final shops = next.shopsResponse?.data.items ?? [];
        //     if (shops.isEmpty) return;
        //
        //     if (_calledOnce) return; // ✅ avoid multiple calls
        //     _calledOnce = true;
        //
        //     final shopId = shops.first.id;
        //     AppLogger.log.i("Shop loaded via listener: $shopId");
        //
        //     await ref
        //         .read(offerNotifierProvider.notifier)
        //         .offerScreenEnquiry(shopId: shopId);
        //   },
        // );
      }
    });
  }

  /// ✅ Always return non-empty shopId when possible
  String _resolveShopId({
    required String mainShopId,
    required List<dynamic> shops,
  }) {
    final currentShop = ref.read(selectedShopProvider);
    final sid = (currentShop ?? mainShopId).toString().trim();

    if (sid.isNotEmpty) return sid;

    // fallback from list
    if (shops.isNotEmpty) {
      final fallback = (shops.first.id ?? '').toString().trim();
      return fallback;
    }

    return '';
  }

  Future<void> _switchShopAndReload(dynamic shopId) async {
    final sid = (shopId ?? '').toString().trim();
    if (sid.isEmpty) return;

    // store selected shop
    ref.read(selectedShopProvider.notifier).switchShop(sid);

    // load offers for selected shop
    await ref
        .read(offerNotifierProvider.notifier)
        .offerScreenEnquiry(shopId: sid);
  }

  // ------------------ helpers ------------------

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Convert API section.dayLabel ("Today"/"Yesterday"/"8 Jan 2026") -> DateTime
  DateTime? _sectionLabelToDate(String label) {
    final l = label.trim().toLowerCase();
    final now = DateTime.now();

    if (l == 'today') return DateTime(now.year, now.month, now.day);
    if (l == 'yesterday') {
      final y = now.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day);
    }

    // "8 Jan 2026" or "08 Jan 2026"
    try {
      final d = DateFormat('dd MMM yyyy').parse(label.trim());
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      try {
        final d = DateFormat('d MMM yyyy').parse(label.trim());
        return DateTime(d.year, d.month, d.day);
      } catch (_) {
        return null;
      }
    }
  }

  /// pick first available date from a list of sections
  DateTime? _firstDateFromSections(List<OfferDaySection> sections) {
    for (final s in sections) {
      final d = _sectionLabelToDate(s.dayLabel);
      if (d != null) return d;
    }
    return null;
  }

  /// Get sections by tab index
  List<OfferDaySection> _sectionsByTab({
    required int tab,
    required List<OfferDaySection> live,
    required List<OfferDaySection> upcoming,
    required List<OfferDaySection> expired,
  }) {
    if (tab == 0) return live;
    if (tab == 1) return upcoming;
    return expired;
  }

  Future<void> _openQrScanner() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerPage()),
    );

    if (result != null && result.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
    }
  }

  void _onTabChanged(int index) {
    if (selectedIndex == index) return;
    setState(() {
      selectedIndex = index;
      _autoPickedForTab = false;
    });
  }

  // ------------------ build ------------------

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final planState = ref.watch(subscriptionNotifier);
    final planData = planState.currentPlanResponse?.data;

    // ✅ shops: use dynamic to avoid type errors
    final shopsRes = homeState.shopsResponse;

    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
    final dynamic mainShop = shops.isNotEmpty ? shops.first : null;

    final String mainShopId = (mainShop?.id ?? '').toString();
    final String selectedShopId = (ref.watch(selectedShopProvider) ?? '')
        .toString()
        .trim();
    final String currentShopId = selectedShopId.isNotEmpty
        ? selectedShopId
        : mainShopId;
    final String mainShopName = (mainShop?.englishName ?? '').toString();
    final String mainShopCategory = (mainShop?.category ?? '').toString();
    final loginContext = shopsRes?.data.loginContext;
    final bool isOwner = loginContext == "OWNER";
    // ✅ offers
    final offerState = ref.watch(offerNotifierProvider);
    final offerData = offerState.offerModel?.data;

    final liveSections = offerData?.liveSections ?? <OfferDaySection>[];
    final upcomingSections = offerData?.upcomingSections ?? <OfferDaySection>[];
    final expiredSections = offerData?.expiredSections ?? <OfferDaySection>[];

    final bool isFreemium = shopsRes?.data.subscription.isFreemium ?? true;

    // ✅ Auto pick date on first load / tab change
    if (offerData != null) {
      if (!_autoPickedOnce) {
        final pickFrom = _sectionsByTab(
          tab: selectedIndex,
          live: liveSections,
          upcoming: upcomingSections,
          expired: expiredSections,
        );
        DateTime? d = _firstDateFromSections(pickFrom);
        d ??= _firstDateFromSections([
          ...liveSections,
          ...upcomingSections,
          ...expiredSections,
        ]);

        _autoPickedOnce = true;

        if (d != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              selectedDate = d;
              selectedDayLabel = _fmt(d!);
            });
          });
        }
      }

      if (_autoPickedOnce && !_autoPickedForTab) {
        final pickFrom = _sectionsByTab(
          tab: selectedIndex,
          live: liveSections,
          upcoming: upcomingSections,
          expired: expiredSections,
        );

        final d = _firstDateFromSections(pickFrom);
        _autoPickedForTab = true;

        if (d != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              selectedDate = d;
              selectedDayLabel = _fmt(d);
            });
          });
        }
      }
    }

    final DateTime? selDate = selectedDate;

    final activeSections = _sectionsByTab(
      tab: selectedIndex,
      live: liveSections,
      upcoming: upcomingSections,
      expired: expiredSections,
    );

    final List<OfferItem> currentItems = (selDate == null)
        ? <OfferItem>[]
        : activeSections
              .where((s) {
                final d = _sectionLabelToDate(s.dayLabel);
                return d != null && _isSameDate(d, selDate);
              })
              .expand((s) => s.items)
              .toList();

    int liveCountFiltered = 0;
    int upcomingCountFiltered = 0;
    int expiredCountFiltered = 0;

    if (selDate != null) {
      liveCountFiltered = liveSections
          .where((s) {
            final d = _sectionLabelToDate(s.dayLabel);
            return d != null && _isSameDate(d, selDate);
          })
          .expand((s) => s.items)
          .length;

      upcomingCountFiltered = upcomingSections
          .where((s) {
            final d = _sectionLabelToDate(s.dayLabel);
            return d != null && _isSameDate(d, selDate);
          })
          .expand((s) => s.items)
          .length;

      expiredCountFiltered = expiredSections
          .where((s) {
            final d = _sectionLabelToDate(s.dayLabel);
            return d != null && _isSameDate(d, selDate);
          })
          .expand((s) => s.items)
          .length;
    }

    // ✅ plan time
    String time = '-';
    String date = '-';
    final String? startsAt = planData?.period.startsAt;
    if (startsAt != null && startsAt.isNotEmpty) {
      final DateTime dt = DateTime.parse(startsAt).toLocal();
      time = DateFormat('h.mm.a').format(dt);
      date = DateFormat('dd MMM yyyy').format(dt);
    }

    return Skeletonizer(
      enabled: offerState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchShops(shopId: currentShopId, filter: '');
              await ref
                  .read(offerNotifierProvider.notifier)
                  .offerScreenEnquiry(shopId: currentShopId);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: _openQrScanner,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.shadowBlue,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Image.asset(AppImages.qr_code, height: 23),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            Text(
                              mainShopName.isNotEmpty
                                  ? mainShopName
                                  : 'My Shop',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              mainShopCategory,
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

                // Shops scroller
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
                      // itemCount: shops.length + 1,
                      itemCount: isOwner ? shops.length + 1 : shops.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        // if (index == shops.length) {
                        if (isOwner && index == shops.length) {
                          return Row(
                            children: [
                              CommonContainer.smallShopContainer(
                                onTap: () {
                                  if (homeState
                                          .shopsResponse
                                          ?.data
                                          .subscription
                                          ?.isFreemium ==
                                      false) {
                                    final bool isService =
                                        shopsRes?.data.items[0].shopKind
                                            .toUpperCase() ==
                                        'SERVICE';

                                    context.push(
                                      AppRoutes.shopCategoryInfoPath,
                                      extra: {
                                        'isService': isService,
                                        'isIndividual': '',
                                        'initialShopNameEnglish':
                                            shopsRes?.data.items[0].englishName,
                                        'initialShopNameTamil':
                                            shopsRes?.data.items[0].tamilName,
                                        'isEditMode': true,
                                      },
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
                                shopImage: '',
                                addAnotherShop: true,
                                shopLocation: 'Premium User can add branch',
                                shopName: 'Add Another Shop',
                              ),
                            ],
                          );
                        }

                        final shop = shops[index];
                        final bool showSwitch = shops.length > 1;
                        return Row(
                          children: [
                            CommonContainer.smallShopContainer(
                              showSwitch: showSwitch,
                              // ✅ FIXED: switch + reload offers
                              onTap: () async {
                                await _switchShopAndReload(shop.id);
                              },
                              switchOnTap: () async {
                                await _switchShopAndReload(shop.id);
                              },
                              shopImage: shop.primaryImageUrl ?? '',
                              shopLocation: '${shop.addressEn}, ${shop.city}',
                              shopName: shop.englishName,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Plan card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: (planData?.isFreemium == false)
                      ? CommonContainer.paidCustomerCard(
                          title:
                              '${planData?.plan.durationLabel} Premium Activated',
                          description: '$time @ $date',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubscriptionHistory(
                                  fromDate:
                                      planData?.period.startsAtLabel ?? '',
                                  titlePlan: planData?.plan.durationLabel ?? '',
                                  toDate: planData?.period.endsAtLabel ?? '',
                                ),
                              ),
                            );
                          },
                        )
                      : CommonContainer.attractCustomerCard(
                          title: 'Attract More Customers',
                          description:
                              'Unlock premium to attract more customers',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubscriptionScreen(),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 35),

                // Header + Create
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'App Offers',
                          style: AppTextStyles.mulish(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreateAppOffer(shopId: currentShopId),
                            ),
                          );
                          // if (isFreemium == false) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (_) =>
                          //           CreateAppOffer(shopId: currentShopId),
                          //     ),
                          //   );
                          // } else {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (_) => SubscriptionScreen(),
                          //     ),
                          //   );
                          // }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Tab chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _tabChip(
                          isSelected: selectedIndex == 0,
                          text: '$liveCountFiltered Live App Offers',
                          onTap: () => _onTabChanged(0),
                        ),
                        const SizedBox(width: 10),
                        _tabChip(
                          isSelected: selectedIndex == 1,
                          text: '$upcomingCountFiltered Upcoming App Offers',
                          onTap: () => _onTabChanged(1),
                        ),
                        const SizedBox(width: 10),
                        _tabChip(
                          isSelected: selectedIndex == 2,
                          text: '$expiredCountFiltered Expired App Offers',
                          onTap: () => _onTabChanged(2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ List / Empty
                if (currentItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 40,
                    ),
                    child: Center(
                      child: Text(
                        'No offers found',
                        style: AppTextStyles.mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentItems.length,
                    itemBuilder: (_, index) {
                      final offer = currentItems[index];
                      final bool isAdminTemplate =
                          (offer.source.trim().toUpperCase() ==
                          'ADMIN_TEMPLATE');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColor.floralWhite,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                '${offer.discountPercentage}% App offer for ${offer.title}',
                                style: AppTextStyles.mulish(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: DottedBorder(
                                color: AppColor.black.withOpacity(0.2),
                                dashPattern: const [2, 2],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(30),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  offer.createdTime.isNotEmpty
                                      ? offer.createdTime
                                      : '-',
                                  style: AppTextStyles.mulish(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _infoTile(
                                    onTap: () {},
                                    image: AppImages.rightArrow,
                                    title: 'Enquiries',
                                    value: offer.enquiriesCount.toString(),
                                  ),
                                  if (offer.expiresAt.isNotEmpty)
                                    _infoTile(
                                      onTap: isAdminTemplate
                                          ? null
                                          : () {
                                              final sid = _resolveShopId(
                                                mainShopId: mainShopId,
                                                shops: shops,
                                              );

                                              final bool isServiceFlow =
                                                  (shopsRes
                                                      ?.data
                                                      .items[0]
                                                      .shopKind
                                                      .toString()
                                                      .toUpperCase() ==
                                                  'SERVICE');

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      CreateAppOffer(
                                                        shopId: sid,
                                                        isService:
                                                            isServiceFlow,
                                                        editOffer: offer,
                                                        isEdit: true,
                                                      ),
                                                ),
                                              );
                                            },

                                      // ✅ disableனா icon காட்டவேண்டாம் (so user won’t think it’s clickable)
                                      image: isAdminTemplate
                                          ? null
                                          : AppImages.editImage,
                                      title: 'Expires on',
                                      value: offer.expiresAt,
                                    ),

                                  // _infoTile(
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => CreateAppOffer(
                                  //           shopId: mainShopId,
                                  //           isService:
                                  //               (shopsRes
                                  //                   ?.data
                                  //                   .items[0]
                                  //                   .shopKind
                                  //                   .toUpperCase() ==
                                  //               'SERVICE'),
                                  //           editOffer:
                                  //               offer, // ✅ pass full offer item
                                  //           isEdit: true,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   image: AppImages.editImage,
                                  //   title: 'Expires on',
                                  //   value: offer.expiresAt,
                                  // ),
                                  if ((offer.services.isNotEmpty) ||
                                      (offer.typesCount.services > 0))
                                    _infoTile(
                                      title: 'Services',
                                      value:
                                          (offer.services.isNotEmpty
                                                  ? offer.services.length
                                                  : offer.typesCount.services)
                                              .toString(),
                                    )
                                  else if ((offer.products.isNotEmpty) ||
                                      (offer.typesCount.products > 0))
                                    _infoTile(
                                      title: 'Types of Product',
                                      value:
                                          (offer.products.isNotEmpty
                                                  ? offer.products.length
                                                  : offer.typesCount.products)
                                              .toString(),
                                    ),
                                ],
                              ),
                            ),
                            if (offer.services.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Services',
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: offer.services.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    _serviceCard(offer.services[i]),
                              ),
                            ] else if (offer.products.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Products',
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: offer.products.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    _productCard(offer.products[i]),
                              ),
                            ],
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
    );
  }

  // ------------------ widgets ------------------

  Widget _tabChip({
    required bool isSelected,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.black : AppColor.borderLightGrey,
            width: 1.5,
          ),
          color: isSelected ? AppColor.white : Colors.transparent,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mulish(
            color: isSelected ? AppColor.black : AppColor.borderLightGrey,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required String title,
    required String value,
    String? image,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    color: AppColor.gray84,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (image != null) ...[
              const SizedBox(width: 20),
              InkWell(
                onTap: enabled ? onTap : null,
                child: Image.asset(
                  image,
                  color: AppColor.black,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _infoTile({
  //   required String title,
  //   required String value,
  //   String? image,
  //   VoidCallback? onTap,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.only(right: 15),
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: AppColor.white,
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: Row(
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: AppTextStyles.mulish(
  //                 fontSize: 12,
  //                 color: AppColor.gray84,
  //               ),
  //             ),
  //             const SizedBox(height: 2),
  //             Text(
  //               value,
  //               style: AppTextStyles.mulish(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         if (image != null) ...[
  //           const SizedBox(width: 20),
  //           InkWell(
  //             onTap: onTap,
  //             child: Image.asset(
  //               image,
  //               color: AppColor.black,
  //               width: 18,
  //               height: 18,
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _productCard(OfferProduct p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mulish(fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (p.rating > 0)
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
                          p.rating.toStringAsFixed(1),
                          style: AppTextStyles.mulish(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        Text(
                          ' ${p.reviewCount}',
                          style: AppTextStyles.mulish(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '₹${p.offerPrice}',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (p.price > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${p.price}',
                        style: AppTextStyles.mulish(
                          fontSize: 11,
                          color: AppColor.gray84,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              p.imageUrl,
              width: 90,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(OfferService p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mulish(fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (p.rating > 0)
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
                          p.rating.toStringAsFixed(1),
                          style: AppTextStyles.mulish(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        Text(
                          ' ${p.reviewCount}',
                          style: AppTextStyles.mulish(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '₹${p.offerPrice}',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (p.price > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${p.price}',
                        style: AppTextStyles.mulish(
                          fontSize: 11,
                          color: AppColor.gray84,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              p.imageUrl,
              width: 90,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
