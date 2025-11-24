import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Utility/app_loader.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Model/shop_root_response.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';
import '../../ShopInfo/Screens/shop_photo_info.dart';
import '../controller/about_me_notifier.dart';

class AboutMeScreens extends ConsumerStatefulWidget {
  const AboutMeScreens({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<AboutMeScreens> createState() => _AboutMeScreensState();
}

class _AboutMeScreensState extends ConsumerState<AboutMeScreens> {
  int selectedIndex = 0;
  int followersSelectedIndex = 0;
  int _selectedMonth = 2;

  final ScrollController _scrollController = ScrollController();

  // currently selected shopId from API list
  String? _currentShopId;

  final tabs = [
    {'icon': AppImages.aboutMeFill, 'label': 'Shop Details'},
    {'icon': AppImages.analytics, 'label': 'Analytics'},
    {'icon': AppImages.groupPeople, 'label': 'Followers'},
  ];

  void _scrollToSelected(int index) {
    const itemWidth = 150.0;
    final offset = index * itemWidth - (itemWidth * 1.3);
    final max = _scrollController.position.hasContentDimensions
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    _scrollController.animateTo(
      offset.clamp(0.0, max),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   selectedIndex = widget.initialTab;
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollToSelected(selectedIndex);
  //   });
  //
  //   // Fetch shops from API
  //   Future.microtask(() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedId = prefs.getString('currentShopId');
  //     ref.read(aboutMeNotifierProvider.notifier).fetchAllShopDetails(shopId: _currentShopId?? '');
  //   });
  // }

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(selectedIndex);
    });

    // 🔥 Load saved shopId from SharedPreferences and then fetch
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('currentShopId');
      AppLogger.log.i(savedId);
      // optional: save to local variable (used by _getSelectedShop)
      if (mounted) {
        setState(() {
          _currentShopId = (savedId != null && savedId.isNotEmpty)
              ? savedId
              : null;
        });
      }

      // if we have saved id → pass it, else call without shopId
      if (savedId != null && savedId.isNotEmpty) {
        await ref
            .read(aboutMeNotifierProvider.notifier)
            .fetchAllShopDetails(shopId: savedId);
      } else {
        await ref.read(aboutMeNotifierProvider.notifier).fetchAllShopDetails();
      }
    });
  }

  Shop? _getSelectedShop(AboutMeState aboutState) {
    final response = aboutState.shopRootResponse;
    if (response == null || response.data.isEmpty) return null;

    final shops = response.data;

    if (_currentShopId == null) {
      return shops.first;
    }

    try {
      return shops.firstWhere(
        (s) => s.shopId == _currentShopId,
        orElse: () => shops.first,
      );
    } catch (_) {
      return shops.first;
    }
  }

  /// Bottom sheet for shop selection (shows all shops from API)
  Future<void> _showShopPickerBottomSheet(AboutMeState aboutState) async {
    final response = aboutState.shopRootResponse;
    if (response == null || response.data.isEmpty) return;

    final shops = response.data;

    final selected = await showModalBottomSheet<Shop>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'Select Shop',
                  style: AppTextStyles.mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: shops.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final shop = shops[index];
                    final isSelected = shop.shopId == _currentShopId;

                    final en = (shop.shopEnglishName ?? '').trim();
                    final name = en.isEmpty
                        ? (shop.shopTamilName ?? 'Untitled Shop')
                        : en;

                    final city = (shop.shopCity ?? '').toString();
                    final state = (shop.shopState ?? '').toString();
                    final subtitle = [
                      if (city.isNotEmpty) city,
                      if (state.isNotEmpty) state,
                    ].join(', ');

                    return ListTile(
                      title: Text(
                        name,
                        style: AppTextStyles.mulish(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      subtitle: subtitle.isEmpty
                          ? null
                          : Text(
                              subtitle,
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                color: AppColor.gray84,
                              ),
                            ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColor.resendOtp,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.pop(ctx, shop),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _currentShopId = selected.shopId;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentShopId', _currentShopId ?? '');
      await ref
          .read(aboutMeNotifierProvider.notifier)
          .fetchAllShopDetails(shopId: _currentShopId);
      // If you need shop-specific APIs, call them here using _currentShopId
      // e.g. ref.read(aboutMeNotifierProvider.notifier).fetchAnalytics(_currentShopId!);
    }
  }

  /// Name for top title (large text below hero)
  /// Name for top title (large text below hero)
  String _getShopTitle(Shop? shop) {
    // While fetching or if no shop → return empty string
    if (shop == null) return '';

    final en = (shop.shopEnglishName ?? '').trim();
    if (en.isNotEmpty) return en;

    final ta = (shop.shopTamilName ?? '').trim();
    if (ta.isNotEmpty) return ta;

    // If shop exists but no names → still empty
    return '';
  }

  /// Address text used in small subtitle lines
  String _getShopAddress(Shop? shop) {
    if (shop == null) return 'Address not available';

    final addrEn = (shop.shopAddressEn ?? '').trim();
    final addrTa = (shop.shopAddressTa ?? '').trim();
    if (addrEn.isNotEmpty) return addrEn;
    if (addrTa.isNotEmpty) return addrTa;

    final city = (shop.shopCity ?? '').trim();
    final state = (shop.shopState ?? '').trim();
    final country = (shop.shopCountry ?? '').trim();

    final parts = [
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ];

    if (parts.isEmpty) return 'Address not available';
    return parts.join(', ');
  }

  /// Header card shared by Shop Details & Analytics
  Widget _buildShopHeaderCard(AboutMeState aboutState) {
    final selectedShop = _getSelectedShop(aboutState);
    final name = _getShopTitle(selectedShop);
    final address = _getShopAddress(selectedShop);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () => _showShopPickerBottomSheet(aboutState),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showShopPickerBottomSheet(aboutState),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.black.withOpacity(0.05),
                      ),
                      child: Image.asset(
                        AppImages.downArrow,
                        height: 25,
                        color: AppColor.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColor.darkGrey, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    address,
                    style: AppTextStyles.mulish(
                      color: AppColor.darkGrey,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CommonContainer.editShopContainer(
                  text: 'Edit Shop Details',
                  onTap: () async {
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopCategoryInfo(
                          shopId: _currentShopId,
                          pages: "AboutMeScreens",
                          isService: true,
                          isIndividual: false,
                        ),
                      ),
                    );

                    if (updatedData != null) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 10),
                CommonContainer.editShopContainer(
                  text: 'Edit Shop Photos',
                  onTap: () async {
                    final updatedPhotos = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ShopPhotoInfo(pages: "AboutMeScreens"),
                      ),
                    );

                    if (updatedPhotos != null) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 10),
                CommonContainer.editShopContainer(
                  text: 'Edit Shop Location In Map',
                  onTap: () async {
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShopCategoryInfo(
                          pages: "AboutMeScreens",
                          isService: true,
                          isIndividual: false,
                        ),
                      ),
                    );

                    if (updatedData != null) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top banner using shopImages; falls back to a simple placeholder if no images
  Widget _buildShopHero(AboutMeState aboutState) {
    final shop = _getSelectedShop(aboutState);

    final images = (shop?.shopImages ?? [])
      ..sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));

    final rating = (shop?.shopRating ?? 0.0);
    final reviewCount = (shop?.shopReviewCount ?? 0);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Row(
            children: List.generate(images.length, (index) {
              final img = images[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == images.length - 1 ? 0 : 10,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: img.url ?? '',
                        height: 150,
                        width: 310,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          width: 310,
                          color: AppColor.leftArrow,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 150,
                          width: 310,
                          color: AppColor.leftArrow,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColor.gray84,
                          ),
                        ),
                      ),
                    ),

                    // Rating chip only on first image
                    if (index == 0)
                      Positioned(
                        top: 20,
                        left: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.scaffoldColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                AppImages.starImage,
                                height: 9,
                                color: AppColor.green,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 1.5,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: AppColor.darkBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                reviewCount.toString(),
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aboutState = ref.watch(aboutMeNotifierProvider);
    final selectedShop = _getSelectedShop(aboutState);
    final isDoorDelivery = selectedShop?.shopDoorDelivery == true;

    return Skeletonizer(
      enabled: aboutState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShopHero(aboutState),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      if (isDoorDelivery)
                        CommonContainer.doorDelivery(
                          text: 'Door Delivery',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          textColor: AppColor.skyBlue,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _getShopTitle(selectedShop),
                    style: AppTextStyles.mulish(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedIndex = index);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToSelected(index);
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.white
                                    : AppColor.leftArrow,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColor.black,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    tabs[index]['icon']!,
                                    height: 20,
                                    color: isSelected
                                        ? AppColor.black
                                        : AppColor.gray84,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    tabs[index]['label']!,
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColor.black
                                          : AppColor.gray84,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildSelectedContent(selectedIndex, aboutState),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(int index, AboutMeState aboutState) {
    switch (index) {
      case 0:
        return _buildShopDetails(aboutState);
      case 1:
        return buildAnalyticsSection(aboutState);
      case 2:
        return buildFollowersDetails(aboutState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildShopDetails(AboutMeState aboutState) {
    final isPremium = RegistrationProductSeivice.instance.isPremium;
    final selectedShop = _getSelectedShop(aboutState);
    final products = selectedShop?.products ?? [];

    final services = selectedShop?.services ?? [];

    final bool hasServices = services.isNotEmpty;
    final bool hasProducts = products.isNotEmpty;

    return Container(
      key: const ValueKey('shopDetails'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColor.leftArrow,
            AppColor.scaffoldColor,
            AppColor.scaffoldColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildShopHeaderCard(aboutState),
            const SizedBox(height: 28),
            if (!isPremium)
              CommonContainer.attractCustomerCard(
                title: 'Attract More Customers',
                description: 'Unlock premium to attract more customers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
              ),
            SizedBox(height: isPremium ? 20 : 40),
            Row(
              children: [
                Image.asset(
                  AppImages.product,
                  height: 35,
                  color: AppColor.darkBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  hasServices ? 'Services' : 'Products',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!hasServices && !hasProducts)
              Text(
                'No products or services added yet.',
                style: AppTextStyles.mulish(
                  color: AppColor.gray84,
                  fontSize: 14,
                ),
              )
            else if (hasServices)
              // ---------- SERVICES LIST ----------
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = services[i];

                  final title = (s.englishName ?? s.tamilName ?? '').trim();
                  final serviceName = title.isEmpty ? 'Unnamed Service' : title;

                  final rating = (s.rating ?? 0).toDouble().toStringAsFixed(1);
                  final ratingCount = (s.ratingCount ?? 0).toString();

                  final startsAt = s.startsAt ?? 0;
                  final priceText = 'Starts at ₹$startsAt';

                  String imageUrl = '';
                  if (s.media.isNotEmpty) {
                    imageUrl = s.media.first.url ?? '';
                  }

                  return Column(
                    children: [
                      CommonContainer.foodList(
                        fontSize: 14,
                        titleWeight: FontWeight.w700,
                        onTap: () {
                          // TODO: go to service details if needed
                        },
                        imageWidth: 130,
                        image: imageUrl,
                        foodName: serviceName,
                        ratingStar: rating,
                        ratingCount: ratingCount,
                        offAmound: priceText,
                        oldAmound: '',
                        km: '',
                        location: '',
                        Verify: false,
                        locations: false,
                        weight: false,
                        horizontalDivider: false,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Navigate to edit service screen, pass s
                                // Navigator.push(...);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.resendOtp,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.editImage,
                                      color: AppColor.white,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColor.white,
                                    title: const Text('Confirm Remove'),
                                    content: const Text(
                                      'Are you sure you want to remove this service?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          'Remove',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  // TODO: Call delete service API here with s.serviceId
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.leftArrow,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.closeImage,
                                      color: AppColor.black,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Remove',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            else
              // ---------- PRODUCTS LIST ----------
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final p = products[i];
                  final title = (p.englishName ?? p.tamilName ?? '').trim();
                  final productName = title.isEmpty ? 'Unnamed Product' : title;

                  final rating = (p.rating ?? 0).toDouble().toStringAsFixed(1);
                  final ratingCount = (p.ratingCount ?? 0).toString();

                  final price = p.price ?? 0;
                  final priceText = '₹$price';

                  String imageUrl = '';
                  if (p.media.isNotEmpty) {
                    imageUrl = p.media.first.url ?? '';
                  }

                  return Column(
                    children: [
                      CommonContainer.foodList(
                        fontSize: 14,
                        titleWeight: FontWeight.w700,
                        onTap: () {
                          // TODO: go to product details
                        },
                        imageWidth: 130,
                        image: imageUrl,
                        foodName: productName,
                        ratingStar: rating,
                        ratingCount: ratingCount,
                        offAmound: priceText,
                        oldAmound: '',
                        km: '',
                        location: '',
                        Verify: false,
                        locations: false,
                        weight: false,
                        horizontalDivider: false,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProductCategoryScreens(
                                          allowOfferEdit: true,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.resendOtp,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.editImage,
                                      color: AppColor.white,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColor.white,
                                    title: const Text('Confirm Remove'),
                                    content: const Text(
                                      'Are you sure you want to remove this product?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          'Remove',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  // TODO: Call delete product API here with p.productId
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.leftArrow,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.closeImage,
                                      color: AppColor.black,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Remove',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductCategoryScreens(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.addListImage,
                      height: 22,
                      color: AppColor.darkBlue,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Add Product',
                      style: AppTextStyles.mulish(
                        color: AppColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Image.asset(AppImages.reviewImage, height: 27.08, width: 26),
                const SizedBox(width: 10),
                Text(
                  'Reviews',
                  style: AppTextStyles.mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Row(
              children: [
                Text(
                  ((selectedShop?.shopRating ?? 0.0).toStringAsFixed(1)),
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 33,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  AppImages.starImage,
                  height: 30,
                  color: AppColor.green,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Based on ${(selectedShop?.shopReviewCount ?? 0)} reviews',
              style: AppTextStyles.mulish(color: AppColor.gray84),
            ),
            const SizedBox(height: 17),
            // For now still static review boxes UI; data can be wired later
            CommonContainer.reviewBox(),
            const SizedBox(height: 17),
            CommonContainer.reviewBox(),
          ],
        ),
      ),
    );
  }

  // ---------- ANALYTICS TAB (still mostly UI – numbers can be wired later) ----------

  Widget buildAnalyticsSection(AboutMeState aboutState) {
    final blue = const Color(0xFF2C7BE5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColor.leftArrow,
            AppColor.scaffoldColor,
            AppColor.scaffoldColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: _buildShopHeaderCard(aboutState),
            ),
            const SizedBox(height: 25),
            // Filter row (can be wired to real analytics later)
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.leftArrow, width: 1.3),
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Filter',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.mulish(
                                  color: AppColor.gray84,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Monthly',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  color: AppColor.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColor.leftArrow,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            AppImages.downArrow,
                            color: AppColor.black,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Branch placeholder (can be wired to branch filter later)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      border: Border.all(color: AppColor.leftArrow, width: 1.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Branch',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.mulish(
                                  color: AppColor.gray84,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'All branches',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  color: AppColor.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColor.leftArrow,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            AppImages.downArrow,
                            color: AppColor.black,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: Column(
                children: [
                  Text(
                    '0', // wire with real search impressions later
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: blue,
                    ),
                  ),
                  Text(
                    'Search Impressions',
                    style: AppTextStyles.mulish(
                      color: AppColor.darkBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                height: 180,
                child: LineChart(_lineChartData(blue)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 12,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  final isSel = _selectedMonth == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMonth = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: isSel ? AppColor.resendOtp : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          months[i],
                          style: AppTextStyles.mulish(
                            color: isSel
                                ? AppColor.white
                                : AppColor.slatePurple,
                            fontSize: 16,
                            fontWeight: isSel
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 44),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'More Details',
                style: AppTextStyles.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColor.darkBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Summary cards (can wire with real numbers later)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    _analyticsCard(
                      icon: AppImages.enqury2,
                      value: '0',
                      label: 'Enquiries',
                    ),
                    const SizedBox(width: 15),
                    _analyticsCard(
                      icon: AppImages.hand,
                      value: '0',
                      label: 'Converted Queries',
                    ),
                    const SizedBox(width: 15),
                    _analyticsCard(
                      icon: AppImages.loc,
                      value: '0',
                      label: 'Location Views',
                    ),
                    const SizedBox(width: 15),
                    _analyticsCard(
                      icon: AppImages.whatsappImage,
                      value: '0',
                      label: 'WhatsApp Msg',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.floralWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset(
                      icon,
                      color: AppColor.black,
                      height: 28,
                      width: 26,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mulish(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    color: AppColor.gray84,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppImages.rightArrow,
              color: AppColor.black,
              width: 17,
              height: 17,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- FOLLOWERS TAB (uses dynamic shop name & address) ----------

  Widget buildFollowersDetails(AboutMeState aboutState) {
    final shop = _getSelectedShop(aboutState);
    final name = _getShopTitle(shop);
    final address = _getShopAddress(shop);

    return Container(
      key: const ValueKey('followers'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColor.leftArrow,
            AppColor.scaffoldColor,
            AppColor.scaffoldColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.gray84.withOpacity(0.3),
                      spreadRadius: 0.2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.black.withOpacity(0.05),
                          ),
                          child: Image.asset(
                            AppImages.downArrow,
                            height: 16,
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColor.darkGrey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            address,
                            style: AppTextStyles.mulish(
                              color: AppColor.darkGrey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Followers List',
                style: AppTextStyles.mulish(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _followersChip('15 Last week', 0),
                  const SizedBox(width: 10),
                  _followersChip('38 Last month', 1),
                  const SizedBox(width: 10),
                  _followersChip('60 Last 3 months', 2),
                  const SizedBox(width: 10),
                  _followersChip('103 All time', 3),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 15,
                    ),
                  ],
                ),
                // Followers list UI (static sample, can wire with real followers later)
                child: ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      AppImages.person,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 8,
                                          sigmaY: 8,
                                        ),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                    ),
                                  ),
                                  child: Image.asset(
                                    AppImages.lock,
                                    height: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Follower name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Joined recently',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _followersChip(String label, int index) {
    final isSelected = followersSelectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => followersSelectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.black : AppColor.borderLightGrey,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColor.black : AppColor.borderLightGrey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- LINE CHART DATA ----------

  LineChartData _lineChartData(Color blue) {
    final points = <FlSpot>[
      const FlSpot(0, 6),
      const FlSpot(1, 6.8),
      const FlSpot(2, 6.4),
      const FlSpot(3, 4.2),
      const FlSpot(4, 6.9),
      const FlSpot(5, 8.1),
      const FlSpot(6, 7.2),
    ];

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: points,
          isCurved: true,
          barWidth: 3,
          color: blue,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                blue.withOpacity(0.22),
                blue.withOpacity(0.22),
                blue.withOpacity(0.20),
                blue.withOpacity(0.15),
                blue.withOpacity(0.06),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// import 'dart:ui';
//
// // import 'package:fl_chart/fl_chart.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:tringo_vendor/Core/Const/app_images.dart';
// import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
// import 'package:tringo_vendor/Presentation/AboutMe/Controller/about_me_notifier.dart';
//
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Session/registration_product_seivice.dart';
// import '../../../Core/Session/registration_session.dart';
// import '../../../Core/Utility/common_Container.dart';
// import '../../AddProduct/Screens/product_category_screens.dart';
// import '../../Menu/Screens/subscription_screen.dart';
// import '../../ShopInfo/Screens/shop_category_info.dart';
// import '../../ShopInfo/Screens/shop_photo_info.dart';
// import '../../Shops Details/Screen/shops_details.dart';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 👈 add this
//
// class AboutMeScreens extends StatefulWidget {
//   const AboutMeScreens({super.key, this.initialTab = 0});
//
//   final int initialTab;
//   @override
//   State<AboutMeScreens> createState() => _AboutMeScreensState();
// }
//
// class ProductItem {
//   final String name, image, ratingStar, ratingCount, offAmount, oldAmount;
//   ProductItem({
//     required this.name,
//     required this.image,
//     required this.ratingStar,
//     required this.ratingCount,
//     required this.offAmount,
//     required this.oldAmount,
//   });
// }
//
// class _AboutMeScreensState extends State<AboutMeScreens> {
//   int selectedIndex = 0;
//   int followersSelectedIndex = 0;
//   int selectedWeight = 0;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _offerPriceController = TextEditingController();
//   final TextEditingController _offerController = TextEditingController();
//   String? _currentShopId;
//   void _scrollToSelected(int index) {
//     const itemWidth = 150.0; // adjust if needed
//     final offset = index * itemWidth - (itemWidth * 1.3);
//     final max = _scrollController.position.hasContentDimensions
//         ? _scrollController.position.maxScrollExtent
//         : 0.0;
//     _scrollController.animateTo(
//       offset.clamp(0.0, max),
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     selectedIndex = widget.initialTab;
//
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToSelected(selectedIndex);
//     });
//
//     Future.microtask(() {
//       ref.read(aboutMeNotifierProvider.notifier).fetchShopDetails();
//     });
//   }
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   selectedIndex = widget.initialTab;
//   //
//   //   // ensure the selected chip comes into view on first build
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     _scrollToSelected(selectedIndex);
//   //   });
//   // }
//
//   final List<ProductItem> _products = [
//     ProductItem(
//       name: 'Badam Mysurpa',
//       image: AppImages.snacks1,
//       ratingStar: '4.5',
//       ratingCount: '16',
//       offAmount: '₹79',
//       oldAmount: '₹110',
//     ),
//     // add more items here...
//   ];
//
//   final tabs = [
//     {'icon': AppImages.aboutMeFill, 'label': 'Shop Details'},
//     {'icon': AppImages.analytics, 'label': 'Analytics'},
//     {'icon': AppImages.groupPeople, 'label': 'Followers'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             clipBehavior: Clip.antiAlias,
//
//                             borderRadius: BorderRadius.circular(20),
//                             child: Image.asset(
//                               AppImages.imageContainer1,
//                               height: 150,
//                               width: 310,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned(
//                             top: 20,
//                             left: 15,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColor.scaffoldColor,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     '4.1',
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                   SizedBox(width: 5),
//                                   Image.asset(
//                                     AppImages.starImage,
//                                     height: 9,
//                                     color: AppColor.green,
//                                   ),
//                                   SizedBox(width: 5),
//                                   Container(
//                                     width: 1.5,
//                                     height: 11,
//                                     decoration: BoxDecoration(
//                                       color: AppColor.darkBlue.withOpacity(0.2),
//                                       borderRadius: BorderRadius.circular(1),
//                                     ),
//                                   ),
//                                   SizedBox(width: 5),
//                                   Text(
//                                     '16',
//                                     style: AppTextStyles.mulish(
//                                       fontSize: 12,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(width: 10),
//                       ClipRRect(
//                         clipBehavior: Clip.antiAlias,
//
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.asset(
//                           AppImages.imageContainer3,
//                           height: 150,
//                           width: 310,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//
//                       SizedBox(width: 10),
//
//                       ClipRRect(
//                         clipBehavior: Clip.antiAlias,
//
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.asset(
//                           AppImages.imageContainer2,
//                           height: 150,
//                           width: 310,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//
//                       SizedBox(width: 10),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 25),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     CommonContainer.doorDelivery(
//                       text: 'Door Delivery',
//                       fontSize: 12,
//                       fontWeight: FontWeight.w900,
//                       textColor: AppColor.skyBlue,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 12),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Text(
//                   'Sri Krishna Sweets Private Limited',
//                   style: AppTextStyles.mulish(
//                     fontSize: 25,
//                     fontWeight: FontWeight.bold,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               SingleChildScrollView(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Row(
//                     children: List.generate(tabs.length, (index) {
//                       final isSelected = selectedIndex == index;
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 10),
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() => selectedIndex = index);
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               _scrollToSelected(index);
//                             });
//                           },
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? AppColor.white
//                                   : AppColor.leftArrow,
//                               borderRadius: BorderRadius.circular(20),
//                               border: isSelected
//                                   ? Border.all(color: AppColor.black, width: 2)
//                                   : null,
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 15,
//                             ),
//                             child: Row(
//                               children: [
//                                 Image.asset(
//                                   tabs[index]['icon']!,
//                                   height: 20,
//                                   color: isSelected
//                                       ? AppColor.black
//                                       : AppColor.gray84,
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   tabs[index]['label']!,
//                                   style: AppTextStyles.mulish(
//                                     fontWeight: FontWeight.bold,
//                                     color: isSelected
//                                         ? AppColor.black
//                                         : AppColor.gray84,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//
//               // ---------- SELECTED CONTENT ----------
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: _buildSelectedContent(selectedIndex),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSelectedContent(int index) {
//     switch (index) {
//       case 0:
//         return _buildShopDetails();
//       case 1:
//         return buildAnalyticsSection(context);
//       case 2:
//         return buildFollowersDetails();
//       default:
//         return SizedBox();
//     }
//   }
//
//   int _selectedMonth = 2;
//   Widget buildAnalyticsSection(BuildContext context) {
//     final blue = const Color(0xFF2C7BE5);
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(
//           colors: [
//             AppColor.leftArrow,
//             AppColor.scaffoldColor,
//             AppColor.scaffoldColor,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
//                 decoration: BoxDecoration(
//                   color: AppColor.white,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisSize:
//                       MainAxisSize.min, // 🔹 prevents extra vertical space
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             'Kaalavasal',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Container(
//                             padding: const EdgeInsets.all(
//                               5,
//                             ), // 🔹 reduce vertical space
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColor.black.withOpacity(0.05),
//                             ),
//                             child: Image.asset(
//                               AppImages.downArrow,
//                               height: 25,
//                               color: AppColor.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             color: AppColor.darkGrey,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               '12, 2, Tirupparankunram Rd, kunram',
//                               style: AppTextStyles.mulish(
//                                 color: AppColor.darkGrey,
//                                 fontSize: 12,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     SingleChildScrollView(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           CommonContainer.editShopContainer(
//                             text: 'Edit Shop Details',
//                             onTap: () async {
//                               final updatedData = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const ShopCategoryInfo(
//                                     pages: "AboutMeScreens",
//                                     isService:
//                                         true, // <-- pass the actual value
//                                     isIndividual: false,
//                                   ),
//                                 ),
//                               );
//
//                               if (updatedData != null) {
//                                 setState(() {
//                                   // Use updatedData to refresh your AboutMeScreens UI if needed
//                                 });
//                               }
//                             },
//                           ),
//
//                           SizedBox(width: 10),
//                           CommonContainer.editShopContainer(
//                             text: 'Edit Shop Photos',
//                             onTap: () async {
//                               final updatedPhotos = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const ShopPhotoInfo(
//                                     pages: "AboutMeScreens",
//                                   ),
//                                 ),
//                               );
//
//                               if (updatedPhotos != null) {
//                                 setState(() {
//                                   // use updatedPhotos to refresh your AboutMeScreens UI
//                                 });
//                               }
//                             },
//                           ),
//
//                           SizedBox(width: 10),
//                           CommonContainer.editShopContainer(
//                             text: 'Edit Shop Location In Map',
//                             onTap: () async {
//                               final updatedData = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const ShopCategoryInfo(
//                                     pages: "AboutMeScreens",
//                                     isService:
//                                         true, // <-- pass the actual value
//                                     isIndividual: false,
//                                   ),
//                                 ),
//                               );
//
//                               if (updatedData != null) {
//                                 setState(() {
//                                   // Use updatedData to refresh your AboutMeScreens UI if needed
//                                 });
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 25),
//             SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppColor.leftArrow, width: 1.3),
//                       color: AppColor.white,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'Filter',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: AppTextStyles.mulish(
//                                   color: AppColor.gray84,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 'Monthly',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 18,
//                                   color: AppColor.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(width: 15),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.leftArrow,
//
//                             shape: BoxShape.circle,
//                           ),
//                           child: Image.asset(
//                             AppImages.downArrow,
//                             color: AppColor.black,
//                             width: 20,
//                             height: 20,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColor.white,
//                       border: Border.all(color: AppColor.leftArrow, width: 1.3),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // LEFT: two texts stacked
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'Branch',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: AppTextStyles.mulish(
//                                   color: AppColor.gray84,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 'Kalavasal',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 18,
//                                   color: AppColor.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(width: 15),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.leftArrow,
//
//                             shape: BoxShape.circle,
//                           ),
//                           child: Image.asset(
//                             AppImages.downArrow,
//                             color: AppColor.black,
//                             width: 20,
//                             height: 20,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppColor.leftArrow, width: 1.3),
//                       color: AppColor.white,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // LEFT: two texts stacked
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Action',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: AppTextStyles.mulish(
//                                 color: AppColor.gray84,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'Search Impress',
//                               style: AppTextStyles.mulish(
//                                 fontSize: 18,
//                                 color: AppColor.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(width: 15),
//
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.leftArrow,
//
//                             shape: BoxShape.circle,
//                           ),
//                           child: Image.asset(
//                             AppImages.downArrow,
//                             color: AppColor.black,
//                             width: 20,
//                             height: 20,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 25),
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     '11,756',
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.w800,
//                       color: blue,
//                     ),
//                   ),
//                   // SizedBox(height: 4),
//                   Text(
//                     'Search Impressions',
//                     style: AppTextStyles.mulish(
//                       color: AppColor.darkBlue,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Chart card
//             Container(
//               decoration: BoxDecoration(color: Colors.white),
//
//               child: SizedBox(
//                 height: 180,
//                 child: LineChart(_lineChartData(blue)),
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             // Month chips
//             SizedBox(
//               height: 42,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: 12,
//                 separatorBuilder: (_, __) => const SizedBox(width: 6),
//                 itemBuilder: (_, i) {
//                   const months = [
//                     'Jan',
//                     'Feb',
//                     'March',
//                     'Apr',
//                     'May',
//                     'Jun',
//                     'Jul',
//                     'Aug',
//                     'Sep',
//                     'Oct',
//                     'Nov',
//                     'Dec',
//                   ];
//                   final isSel = _selectedMonth == i;
//                   return GestureDetector(
//                     onTap: () => setState(() => _selectedMonth = i),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       decoration: BoxDecoration(
//                         color: isSel ? AppColor.resendOtp : Colors.transparent,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       alignment: Alignment.center,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           months[i],
//                           style: AppTextStyles.mulish(
//                             color: isSel
//                                 ? AppColor.white
//                                 : AppColor.slatePurple,
//                             fontSize: 16,
//                             fontWeight: isSel
//                                 ? FontWeight.normal
//                                 : FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 44),
//
//             // More Details
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Text(
//                 'More Details',
//                 style: AppTextStyles.mulish(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.floralWhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.enqury2,
//                                       color: AppColor.black,
//
//                                       height: 28,
//                                       width: 26,
//                                       fit: BoxFit.contain,
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       '10',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   'Enquires',
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 12,
//                                     color: AppColor.gray84,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 10),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//
//                               shape: BoxShape.circle,
//                             ),
//                             child: Image.asset(
//                               AppImages.rightArrow,
//                               color: AppColor.black,
//                               width: 17,
//                               height: 17,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 15),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.floralWhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.hand,
//                                       color: AppColor.black,
//
//                                       height: 28,
//                                       width: 26,
//                                       fit: BoxFit.contain,
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       '10',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   'Converted Queries',
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 12,
//                                     color: AppColor.gray84,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 10),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//
//                               shape: BoxShape.circle,
//                             ),
//                             child: Image.asset(
//                               AppImages.rightArrow,
//                               color: AppColor.black,
//                               width: 17,
//                               height: 17,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 15),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.floralWhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.loc,
//                                       color: AppColor.black,
//
//                                       height: 28,
//                                       width: 26,
//                                       fit: BoxFit.contain,
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       '2',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   'Location',
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 12,
//                                     color: AppColor.gray84,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 10),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//
//                               shape: BoxShape.circle,
//                             ),
//                             child: Image.asset(
//                               AppImages.rightArrow,
//                               color: AppColor.black,
//                               width: 17,
//                               height: 17,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 15),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.floralWhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.whatsappImage,
//                                       color: AppColor.black,
//
//                                       height: 28,
//                                       width: 26,
//                                       fit: BoxFit.contain,
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       '2',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   'Whatsapp Msg',
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 12,
//                                     color: AppColor.gray84,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 10),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//
//                               shape: BoxShape.circle,
//                             ),
//                             child: Image.asset(
//                               AppImages.rightArrow,
//                               color: AppColor.black,
//                               width: 17,
//                               height: 17,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShopDetails() {
//     final isPremium = RegistrationProductSeivice.instance.isPremium;
//     final isNonPremium = RegistrationProductSeivice.instance.isNonPremium;
//     return Container(
//       key: const ValueKey('shopDetails'),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(
//           colors: [
//             AppColor.leftArrow,
//             AppColor.scaffoldColor,
//             AppColor.scaffoldColor,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
//               decoration: BoxDecoration(
//                 color: AppColor.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 mainAxisSize:
//                     MainAxisSize.min, // 🔹 prevents extra vertical space
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 15),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Kaalavasal',
//                           style: AppTextStyles.mulish(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.all(
//                             5,
//                           ), // 🔹 reduce vertical space
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: AppColor.black.withOpacity(0.05),
//                           ),
//                           child: Image.asset(
//                             AppImages.downArrow,
//                             height: 25,
//                             color: AppColor.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 15),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.location_on,
//                           color: AppColor.darkGrey,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 4),
//                         Flexible(
//                           child: Text(
//                             '12, 2, Tirupparankunram Rd, kunram',
//                             style: AppTextStyles.mulish(
//                               color: AppColor.darkGrey,
//                               fontSize: 12,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 15),
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         CommonContainer.editShopContainer(
//                           text: 'Edit Shop Details',
//                           onTap: () async {
//                             final updatedData = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const ShopCategoryInfo(
//                                   pages: "AboutMeScreens",
//                                   isService: true, // <-- pass the actual value
//                                   isIndividual: false,
//                                 ),
//                               ),
//                             );
//
//                             if (updatedData != null) {
//                               setState(() {
//                                 // Use updatedData to refresh your AboutMeScreens UI if needed
//                               });
//                             }
//                           },
//                         ),
//
//                         SizedBox(width: 10),
//                         CommonContainer.editShopContainer(
//                           text: 'Edit Shop Photos',
//                           onTap: () async {
//                             final updatedPhotos = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const ShopPhotoInfo(
//                                   pages: "AboutMeScreens",
//                                 ),
//                               ),
//                             );
//
//                             if (updatedPhotos != null) {
//                               setState(() {
//                                 // use updatedPhotos to refresh your AboutMeScreens UI
//                               });
//                             }
//                           },
//                         ),
//
//                         SizedBox(width: 10),
//                         CommonContainer.editShopContainer(
//                           text: 'Edit Shop Location In Map',
//                           onTap: () async {
//                             final updatedData = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const ShopCategoryInfo(
//                                   pages: "AboutMeScreens",
//                                   isService: true, // <-- pass the actual value
//                                   isIndividual: false,
//                                 ),
//                               ),
//                             );
//
//                             if (updatedData != null) {
//                               setState(() {
//                                 // Use updatedData to refresh your AboutMeScreens UI if needed
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 28),
//             if (!isPremium)
//               CommonContainer.attractCustomerCard(
//                 title: 'Attract More Customers',
//                 description: 'Unlock premium to attract more customers',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SubscriptionScreen(),
//                     ),
//                   );
//                 },
//               ),
//             SizedBox(height: isPremium ? 20 : 40),
//             Row(
//               children: [
//                 Image.asset(
//                   AppImages.product,
//                   height: 35,
//                   color: AppColor.darkBlue,
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   'Products',
//                   style: AppTextStyles.mulish(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _products.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 12),
//               itemBuilder: (context, i) {
//                 final p = _products[i];
//                 return Column(
//                   children: [
//                     CommonContainer.foodList(
//                       fontSize: 14,
//                       titleWeight: FontWeight.w700,
//                       onTap: () {},
//                       imageWidth: 130,
//                       image: p.image,
//                       foodName: p.name,
//                       ratingStar: p.ratingStar,
//                       ratingCount: p.ratingCount,
//                       offAmound: p.offAmount,
//                       oldAmound: p.oldAmount,
//                       km: '',
//                       location: '',
//                       Verify: false,
//                       locations: false,
//                       weight: false,
//                       horizontalDivider: false,
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ProductCategoryScreens(
//                                     allowOfferEdit: true,
//                                     // initialOfferLabel: _offerController.text,   // 👈 current offer name
//                                     // initialOfferValue: _offerPriceController.text,
//                                     initialOfferLabel: 'First App Offer',
//                                     initialOfferValue: '5%',
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 15,
//                                 horizontal: 15,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColor.resendOtp,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Image.asset(
//                                     AppImages.editImage,
//                                     color: AppColor.white,
//                                     height: 16,
//                                   ),
//                                   SizedBox(width: 6),
//                                   Text(
//                                     'Edit',
//                                     style: AppTextStyles.mulish(
//                                       color: AppColor.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () async {
//                               // Show confirmation dialog
//                               final confirm = await showDialog<bool>(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                   backgroundColor: AppColor.white,
//                                   title: Text('Confirm Remove'),
//                                   content: Text(
//                                     'Are you sure you want to remove this product?',
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () => Navigator.pop(
//                                         context,
//                                         false,
//                                       ), // cancel
//                                       child: Text('Cancel'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () => Navigator.pop(
//                                         context,
//                                         true,
//                                       ), // confirm
//                                       child: Text(
//                                         'Remove',
//                                         style: AppTextStyles.mulish(
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//
//                               // If user confirmed, remove the product
//                               if (confirm == true) {
//                                 setState(() {
//                                   _products.removeAt(i);
//                                 });
//                               }
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 15,
//                                 horizontal: 15,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColor.leftArrow,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Image.asset(
//                                     AppImages.closeImage,
//                                     color: AppColor.black,
//                                     height: 16,
//                                   ),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     'Remove',
//                                     style: AppTextStyles.mulish(
//                                       color: AppColor.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//
//             SizedBox(height: 20),
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ProductCategoryScreens(),
//                   ),
//                 );
//               },
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   border: Border.all(),
//                   color: AppColor.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 15.5),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       AppImages.addListImage,
//                       height: 22,
//                       color: AppColor.darkBlue,
//                     ),
//                     SizedBox(width: 9),
//                     Text(
//                       'Add Product',
//                       style: AppTextStyles.mulish(
//                         color: AppColor.black,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 30),
//
//             Row(
//               children: [
//                 Image.asset(AppImages.reviewImage, height: 27.08, width: 26),
//                 SizedBox(width: 10),
//                 Text(
//                   'Reviews',
//                   style: AppTextStyles.mulish(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 21),
//             Row(
//               children: [
//                 Text(
//                   '4.5',
//                   style: AppTextStyles.mulish(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 33,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Image.asset(
//                   AppImages.starImage,
//                   height: 30,
//                   color: AppColor.green,
//                 ),
//               ],
//             ),
//             SizedBox(height: 2),
//             Text(
//               'Based on 58 reviews',
//               style: AppTextStyles.mulish(color: AppColor.gray84),
//             ),
//             SizedBox(height: 17),
//             CommonContainer.reviewBox(),
//             SizedBox(height: 17),
//             CommonContainer.reviewBox(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildFollowersDetails() {
//     return Container(
//       key: const ValueKey('shopDetails'),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//
//         gradient: LinearGradient(
//           colors: [
//             AppColor.leftArrow,
//             AppColor.scaffoldColor,
//             AppColor.scaffoldColor,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//
//             /// SHOP DETAILS CARD
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 15,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColor.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColor.gray84.withOpacity(0.3),
//                       spreadRadius: 0.2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Kaalavasal',
//                           style: AppTextStyles.mulish(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Container(
//                           padding: const EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: AppColor.black.withOpacity(0.05),
//                           ),
//                           child: Image.asset(
//                             AppImages.downArrow,
//                             height: 16,
//                             color: AppColor.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 2),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on,
//                           color: AppColor.darkGrey,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 4),
//                         Flexible(
//                           child: Text(
//                             '12, 2, Tirupparankunram Rd, Kunram',
//                             style: AppTextStyles.mulish(
//                               color: AppColor.darkGrey,
//                               fontSize: 12,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//             Center(
//               child: Text(
//                 'Followers List',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 15),
//             SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => setState(() => followersSelectedIndex = 0),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 20,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: followersSelectedIndex == 0
//                               ? AppColor.black
//                               : AppColor.borderLightGrey,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '15 Last week',
//                           style: TextStyle(
//                             color: followersSelectedIndex == 0
//                                 ? AppColor.black
//                                 : AppColor.borderLightGrey,
//                             fontWeight: followersSelectedIndex == 0
//                                 ? FontWeight.w700
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () => setState(() => followersSelectedIndex = 1),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 20,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: followersSelectedIndex == 1
//                               ? AppColor.black
//                               : AppColor.borderLightGrey,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '38 Last Month',
//                           style: TextStyle(
//                             color: followersSelectedIndex == 1
//                                 ? AppColor.black
//                                 : AppColor.borderLightGrey,
//                             fontWeight: followersSelectedIndex == 1
//                                 ? FontWeight.w700
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () => setState(() => followersSelectedIndex = 2),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 20,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: followersSelectedIndex == 2
//                               ? AppColor.black
//                               : AppColor.borderLightGrey,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '15 Last week',
//                           style: TextStyle(
//                             color: followersSelectedIndex == 2
//                                 ? AppColor.black
//                                 : AppColor.borderLightGrey,
//                             fontWeight: followersSelectedIndex == 2
//                                 ? FontWeight.w700
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () => setState(() => followersSelectedIndex = 3),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 20,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: followersSelectedIndex == 3
//                               ? AppColor.black
//                               : AppColor.borderLightGrey,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '103 All times',
//                           style: TextStyle(
//                             color: followersSelectedIndex == 3
//                                 ? AppColor.black
//                                 : AppColor.borderLightGrey,
//                             fontWeight: followersSelectedIndex == 3
//                                 ? FontWeight.w700
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                       spreadRadius: 15,
//                     ),
//                   ],
//                 ),
//                 child: ListView.builder(
//                   itemCount: 5,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 15,
//                         vertical: 6,
//                       ),
//                       child: Row(
//                         children: [
//                           Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(15),
//                                 child: Stack(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.person,
//                                       height: 50,
//                                       width: 50,
//                                       fit: BoxFit.cover,
//                                     ),
//
//                                     // 🔹 If unsubscribed, apply blur overlay
//                                     Positioned.fill(
//                                       child: BackdropFilter(
//                                         filter: ImageFilter.blur(
//                                           sigmaX: 8,
//                                           sigmaY: 8,
//                                         ),
//                                         child: Container(
//                                           color: Colors.black.withOpacity(
//                                             0.3,
//                                           ), // slight dark overlay
//                                           alignment: Alignment.center,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: Container(
//                                   height: 15,
//                                   width: 15,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(7),
//                                     ),
//                                   ),
//                                   child: Image.asset(
//                                     AppImages.lock,
//                                     height: 16,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 15),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Vignesh',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 3),
//                               Text(
//                                 'Joined at 11.30Am',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   LineChartData _lineChartData(Color blue) {
//     final points = <FlSpot>[
//       const FlSpot(0, 6),
//       const FlSpot(1, 6.8),
//       const FlSpot(2, 6.4),
//       const FlSpot(3, 4.2),
//       const FlSpot(4, 6.9),
//       const FlSpot(5, 8.1),
//       const FlSpot(6, 7.2),
//     ];
//
//     return LineChartData(
//       gridData: FlGridData(show: false),
//       titlesData: FlTitlesData(show: false),
//       borderData: FlBorderData(show: false),
//       minX: 0,
//       maxX: 6,
//       minY: 0,
//       maxY: 10,
//       lineBarsData: [
//         LineChartBarData(
//           spots: points,
//           isCurved: true,
//           barWidth: 3,
//           color: blue,
//           dotData: const FlDotData(show: false),
//           belowBarData: BarAreaData(
//             show: true,
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 blue.withOpacity(0.22),
//                 blue.withOpacity(0.22),
//                 blue.withOpacity(0.20),
//
//                 blue.withOpacity(0.15),
//                 blue.withOpacity(0.06),
//                 Colors.transparent,
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
