import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';
import 'package:tringo_vendor/Presentation/Home/Model/shops_response.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';
import '../../Home/Controller/home_notifier.dart';
import '../../Home/Controller/shopContext_provider.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../Model/offer_model.dart';

class OfferScreens extends ConsumerStatefulWidget {
  const OfferScreens({super.key});

  @override
  ConsumerState<OfferScreens> createState() => _OfferScreensState();
}

class _OfferScreensState extends ConsumerState<OfferScreens> {
  int selectedIndex = 0; // 0 = Live, 1 = Expired
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

  late final ProviderSubscription<HomeState> _homeSub;
  bool _calledOnce = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final existingShops =
          ref.read(homeNotifierProvider).shopsResponse?.data.items ?? [];

      if (existingShops.isNotEmpty) {
        final shopId = existingShops.first.id;
        _calledOnce = true;

        AppLogger.log.i("Shop already exists: $shopId");
        await ref
            .read(offerNotifierProvider.notifier)
            .offerScreenEnquiry(shopId: shopId);

        return; // ✅ stop here, no need to listen
      }

      // // ✅ 2) If shops not loaded, fetch shops now
      // await ref.read(homeNotifierProvider.notifier).fetchShops();
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
    });
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ✅ Convert section.dayLabel ("Today", "Yesterday", "10 Dec 2025") -> DateTime
  DateTime? _sectionLabelToDate(String label) {
    final l = label.trim().toLowerCase();
    final now = DateTime.now();

    if (l == 'today') return DateTime(now.year, now.month, now.day);
    if (l == 'yesterday') {
      final y = now.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day);
    }

    // "10 Dec 2025"
    try {
      final d = DateFormat('dd MMM yyyy').parse(label.trim());
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    final shopsRes = homeState.shopsResponse;

    final List<Shop> shops = shopsRes?.data.items ?? [];
    final bool hasShops = shops.isNotEmpty;
    final Shop? mainShop = hasShops ? shops.first : null;

    final offerState = ref.watch(offerNotifierProvider);
    final offerModel = offerState.offerModel;
    final offerData = offerModel?.data;

    final sections = offerData?.sections ?? [];

    // ✅ Items ONLY for selectedDate (fixes date filter)
    final List<OfferListItem> dayItems = sections
        .where((s) {
          final d = _sectionLabelToDate(s.dayLabel);
          if (d == null) return false;
          return _isSameDate(d, selectedDate);
        })
        .expand((s) => s.items)
        .toList();

    // ✅ Counts based on selectedDate (fixes wrong live/expired counts)
    final int liveCountFiltered = dayItems
        .where((it) => it.stateLabel == "LIVE")
        .length;
    final int expiredCountFiltered = dayItems
        .where((it) => it.stateLabel == "EXPIRED")
        .length;

    // ✅ Tab filter
    final List<OfferListItem> currentItems = dayItems.where((it) {
      if (selectedIndex == 0) return it.stateLabel == "LIVE";
      return it.stateLabel == "EXPIRED";
    }).toList();

    return Skeletonizer(
      enabled: offerState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            children: [
              // Header Row
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
                            MaterialPageRoute(builder: (_) => MenuScreens()),
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

              // Shops scroller (bounded height)
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
                            onTap: () {
                              ref
                                  .read(selectedShopProvider.notifier)
                                  .switchShop(shop.id);
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // Attract card
                    CommonContainer.attractCustomerCard(
                      title: 'Attract More Customers',
                      description: 'Unlock premium to attract more customers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubscriptionScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 35),

                    // App Offers + actions
                    Row(
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
                                    CreateAppOffer(shopId: mainShop?.id),
                              ),
                            );
                          },
                          child: Container(
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
                              style: AppTextStyles.mulish(
                                color: AppColor.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Date filter
                        GestureDetector(
                          onTap: () async {
                            final pickedDate = await showModalBottomSheet<DateTime>(
                              context: context,
                              backgroundColor: AppColor.white,
                              shape: const RoundedRectangleBorder(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 17,
                                                    vertical: 10,
                                                  ),
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: AppColor.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
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
                                        onTap: () => Navigator.pop(
                                          context,
                                          DateTime.now(),
                                        ),
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
                                          DateTime.now().subtract(
                                            const Duration(days: 1),
                                          ),
                                        ),
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
                                          final d = await showDatePicker(
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
                                                        primary:
                                                            AppColor.brightBlue,
                                                        onPrimary: Colors.white,
                                                        onSurface:
                                                            AppColor.black,
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

                                          if (d != null) {
                                            Navigator.pop(context, d);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;

                                final today = DateTime.now();
                                final yesterday = today.subtract(
                                  const Duration(days: 1),
                                );

                                if (_isSameDate(pickedDate, today)) {
                                  selectedDay = "Today";
                                } else if (_isSameDate(pickedDate, yesterday)) {
                                  selectedDay = "Yesterday";
                                } else {
                                  selectedDay = _fmt(pickedDate);
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.5,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.iceBlue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Image.asset(AppImages.filter, height: 19),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Segmented toggles (Live / Expired) ✅ date-wise counts
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedIndex = 0),
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
                                    '$liveCountFiltered Live App Offers',
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
                              onTap: () => setState(() => selectedIndex = 1),
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
                                    '$expiredCountFiltered Expired App Offers',
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
                    const SizedBox(height: 20),

                    // Offer list / empty
                    if (currentItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'No offers found for $selectedDay',
                          style: AppTextStyles.mulish(
                            fontSize: 12,
                            color: AppColor.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final offer = currentItems[index];

                          final prodCount = offer.typesCount.products;
                          final servCount = offer.typesCount.services;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.shadowBlue,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              offer.title,
                                              style: AppTextStyles.mulish(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: offer.stateLabel == "LIVE"
                                                  ? AppColor.iceBlue
                                                  : AppColor.mistyRose,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              offer.stateLabel,
                                              style: AppTextStyles.mulish(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    offer.stateLabel == "LIVE"
                                                    ? AppColor.darkBlue
                                                    : AppColor.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            offer.createdTime ?? '',
                                            style: AppTextStyles.mulish(
                                              fontSize: 12,
                                              color: AppColor.gray84,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Expires: ${offer.expiresAt ?? '-'}',
                                            style: AppTextStyles.mulish(
                                              fontSize: 12,
                                              color: AppColor.gray84,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '$prodCount Products • $servCount Services',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.darkGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      if (offer.products.isNotEmpty)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColor.floralWhite,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 20,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: Text(
                                                  offer.title,
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: DottedBorder(
                                                  color: AppColor.black
                                                      .withOpacity(0.2),
                                                  strokeWidth: 1.2,
                                                  dashPattern: const [2, 2],
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(
                                                    30,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    offer.createdTime ?? '-',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.mulish(
                                                      fontSize: 12,
                                                      color: AppColor.gray84,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 25),

                                              // (your horizontal stats row unchanged)
                                              // ... keep your existing widgets here ...
                                              const SizedBox(height: 24),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: Text(
                                                  'Products',
                                                  style: AppTextStyles.mulish(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: Column(
                                                  children: offer.products
                                                      .map(
                                                        (p) => Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                bottom: 10,
                                                              ),
                                                          child: _productTile(
                                                            p,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productTile(OfferProductItem p) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: const ColoredBox(color: Color(0xFFF8FBF8))),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF000000).withOpacity(0.04),
                      const Color(0xFF000000).withOpacity(0.00),
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
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (p.rating != null)
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
                                  '${p.rating!.toStringAsFixed(1)} ',
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
                                  '${p.reviewCount}',
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
                            Text(
                              '₹${p.price.toStringAsFixed(0)}',
                              style: AppTextStyles.mulish(
                                color: AppColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (p.mrp != null && p.mrp! > p.price)
                              Text(
                                '₹${p.mrp!.toStringAsFixed(0)}',
                                style: AppTextStyles.mulish(
                                  color: AppColor.gray84,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        if ((p.offerValue ?? '').isNotEmpty ||
                            p.offerPrice != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${p.offerLabel ?? "Offer"} ${p.offerValue ?? ""}${p.offerPrice != null ? " • ₹${p.offerPrice!.toStringAsFixed(0)}" : ""}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.mulish(
                              fontSize: 11,
                              color: AppColor.gray84,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _productImage(p.imageUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) {
      return Image.asset(
        AppImages.phone,
        width: 100,
        height: 110,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      u,
      width: 100,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        AppImages.phone,
        width: 100,
        height: 110,
        fit: BoxFit.cover,
      ),
    );
  }
}
