import 'dart:ui';

// import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';
import '../../ShopInfo/Screens/shop_photo_info.dart';
import '../../Shops Details/Screen/shops_details.dart';

class AboutMeScreens extends StatefulWidget {
  const AboutMeScreens({super.key, this.initialTab = 0});

  final int initialTab;
  @override
  State<AboutMeScreens> createState() => _AboutMeScreensState();
}

class ProductItem {
  final String name, image, ratingStar, ratingCount, offAmount, oldAmount;
  ProductItem({
    required this.name,
    required this.image,
    required this.ratingStar,
    required this.ratingCount,
    required this.offAmount,
    required this.oldAmount,
  });
}

class _AboutMeScreensState extends State<AboutMeScreens> {
  int selectedIndex = 0;
  int followersSelectedIndex = 0;
  int selectedWeight = 0;
  final ScrollController _scrollController = ScrollController();

  void _scrollToSelected(int index) {
    const itemWidth = 150.0; // adjust if needed
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

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab;

    // ensure the selected chip comes into view on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(selectedIndex);
    });
  }

  final List<ProductItem> _products = [
    ProductItem(
      name: 'Badam Mysurpa',
      image: AppImages.snacks1,
      ratingStar: '4.5',
      ratingCount: '16',
      offAmount: '₹79',
      oldAmount: '₹110',
    ),
    // add more items here...
  ];

  final tabs = [
    {'icon': AppImages.aboutMeFill, 'label': 'Shop Details'},
    {'icon': AppImages.analytics, 'label': 'Analytics'},
    {'icon': AppImages.groupPeople, 'label': 'Followers'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),

                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.antiAlias,

                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              AppImages.imageContainer1,
                              height: 150,
                              width: 310,
                              fit: BoxFit.cover,
                            ),
                          ),
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
                                    '4.1',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Image.asset(
                                    AppImages.starImage,
                                    height: 9,
                                    color: AppColor.green,
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    width: 1.5,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: AppColor.darkBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '16',
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

                      SizedBox(width: 10),
                      ClipRRect(
                        clipBehavior: Clip.antiAlias,

                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          AppImages.imageContainer3,
                          height: 150,
                          width: 310,
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(width: 10),

                      ClipRRect(
                        clipBehavior: Clip.antiAlias,

                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          AppImages.imageContainer2,
                          height: 150,
                          width: 310,
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    CommonContainer.doorDelivery(
                      text: 'Door Delivery',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      textColor: AppColor.skyBlue,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Sri Krishna Sweets Private Limited',
                  style: AppTextStyles.mulish(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                                  ? Border.all(color: AppColor.black, width: 2)
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
              SizedBox(height: 10),

              // ---------- SELECTED CONTENT ----------
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSelectedContent(selectedIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(int index) {
    switch (index) {
      case 0:
        return _buildShopDetails();
      case 1:
        return buildAnalyticsSection(context);
      case 2:
        return buildFollowersDetails();
      default:
        return SizedBox();
    }
  }

  int _selectedMonth = 2;
  Widget buildAnalyticsSection(BuildContext context) {
    final blue = const Color(0xFF2C7BE5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
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
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // 🔹 prevents extra vertical space
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kaalavasal',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(
                              5,
                            ), // 🔹 reduce vertical space
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColor.darkGrey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '12, 2, Tirupparankunram Rd, kunram',
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
                    SizedBox(height: 20),
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
                                  builder: (context) => const ShopCategoryInfo(
                                    pages: "AboutMeScreens",
                                    isService: true,      // <-- pass the actual value
                                    isIndividual: false,
                                  ),
                                ),
                              );

                              if (updatedData != null) {
                                setState(() {
                                  // Use updatedData to refresh your AboutMeScreens UI if needed
                                });
                              }
                            },
                          ),

                          SizedBox(width: 10),
                          CommonContainer.editShopContainer(
                            text: 'Edit Shop Photos',
                            onTap: () async {
                              final updatedPhotos = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShopPhotoInfo(
                                    pages: "AboutMeScreens",
                                  ),
                                ),
                              );

                              if (updatedPhotos != null) {
                                setState(() {
                                  // use updatedPhotos to refresh your AboutMeScreens UI
                                });
                              }
                            },
                          ),

                          SizedBox(width: 10),
                          CommonContainer.editShopContainer(
                            text: 'Edit Shop Location In Map',
                            onTap: () async {
                              final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShopCategoryInfo(
                                    pages: "AboutMeScreens",
                                    isService: true,      // <-- pass the actual value
                                    isIndividual: false,
                                  ),
                                ),
                              );

                              if (updatedData != null) {
                                setState(() {
                                  // Use updatedData to refresh your AboutMeScreens UI if needed
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
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
                  SizedBox(width: 15),
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
                        // LEFT: two texts stacked
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
                                'Kalavasal',
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
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
                  SizedBox(width: 15),
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
                        // LEFT: two texts stacked
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Action',
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
                              'Search Impress',
                              style: AppTextStyles.mulish(
                                fontSize: 18,
                                color: AppColor.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 15),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
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
            SizedBox(height: 25),
            Center(
              child: Column(
                children: [
                  Text(
                    '11,756',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: blue,
                    ),
                  ),
                  // SizedBox(height: 4),
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

            // Chart card
            Container(
              decoration: BoxDecoration(color: Colors.white),

              child: SizedBox(
                height: 180,
                child: LineChart(_lineChartData(blue)),
              ),
            ),
            const SizedBox(height: 12),

            // Month chips
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
                    'March',
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

            // More Details
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

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
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
                                      AppImages.enqury2,
                                      color: AppColor.black,

                                      height: 28,
                                      width: 26,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '10',
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
                                  'Enquires',
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
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
                    ),
                    SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
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
                                      AppImages.hand,
                                      color: AppColor.black,

                                      height: 28,
                                      width: 26,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '10',
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
                                  'Converted Queries',
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
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
                    ),
                    SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
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
                                      AppImages.loc,
                                      color: AppColor.black,

                                      height: 28,
                                      width: 26,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '2',
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
                                  'Location',
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
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
                    ),
                    SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
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
                                      AppImages.whatsappImage,
                                      color: AppColor.black,

                                      height: 28,
                                      width: 26,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '2',
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
                                  'Whatsapp Msg',
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
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
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShopDetails() {
    return Container(
      key: const ValueKey('shopDetails'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
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
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // 🔹 prevents extra vertical space
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Kaalavasal',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(
                            5,
                          ), // 🔹 reduce vertical space
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColor.darkGrey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '12, 2, Tirupparankunram Rd, kunram',
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
                  SizedBox(height: 20),
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
                                builder: (context) => const ShopCategoryInfo(
                                  pages: "AboutMeScreens",
                                  isService: true,      // <-- pass the actual value
                                  isIndividual: false,
                                ),
                              ),
                            );

                            if (updatedData != null) {
                              setState(() {
                                // Use updatedData to refresh your AboutMeScreens UI if needed
                              });
                            }
                          },
                        ),

                        SizedBox(width: 10),
                        CommonContainer.editShopContainer(
                          text: 'Edit Shop Photos',
                          onTap: () async {
                            final updatedPhotos = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopPhotoInfo(
                                  pages: "AboutMeScreens",
                                ),
                              ),
                            );

                            if (updatedPhotos != null) {
                              setState(() {
                                // use updatedPhotos to refresh your AboutMeScreens UI
                              });
                            }
                          },
                        ),

                        SizedBox(width: 10),
                        CommonContainer.editShopContainer(
                          text: 'Edit Shop Location In Map',
                          onTap: () async {
                            final updatedData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopCategoryInfo(
                                  pages: "AboutMeScreens",
                                  isService: true, // <-- pass the actual value
                                  isIndividual: false,
                                ),
                              ),
                            );

                            if (updatedData != null) {
                              setState(() {
                                // Use updatedData to refresh your AboutMeScreens UI if needed
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            CommonContainer.attractCustomerCard(
              title: 'Attract More Customers',
              description: 'Unlock premium to attract more customers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Image.asset(
                  AppImages.fireImage,
                  height: 35,
                  color: AppColor.darkBlue,
                ),
                SizedBox(width: 10),
                Text(
                  'Products',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = _products[i];
                return Column(
                  children: [
                    CommonContainer.foodList(
                      fontSize: 14,
                      titleWeight: FontWeight.w700,
                      onTap: () {},
                      imageWidth: 130,
                      image: p.image,
                      foodName: p.name,
                      ratingStar: p.ratingStar,
                      ratingCount: p.ratingCount,
                      offAmound: p.offAmount,
                      oldAmound: p.oldAmount,
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
                                      ProductCategoryScreens(),
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
                                  SizedBox(width: 6),
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
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // Show confirmation dialog
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColor.white,
                                  title: Text('Confirm Remove'),
                                  content: Text(
                                    'Are you sure you want to remove this product?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        false,
                                      ), // cancel
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        true,
                                      ), // confirm
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

                              // If user confirmed, remove the product
                              if (confirm == true) {
                                setState(() {
                                  _products.removeAt(i);
                                });
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
                                  SizedBox(width: 10),
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

            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCategoryScreens(),
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
                    SizedBox(width: 9),
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

            SizedBox(height: 30),

            Row(
              children: [
                Image.asset(AppImages.reviewImage, height: 27.08, width: 26),
                SizedBox(width: 10),
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
            SizedBox(height: 21),
            Row(
              children: [
                Text(
                  '4.5',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 33,
                    color: AppColor.darkBlue,
                  ),
                ),
                SizedBox(width: 10),
                Image.asset(
                  AppImages.starImage,
                  height: 30,
                  color: AppColor.green,
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'Based on 58 reviews',
              style: AppTextStyles.mulish(color: AppColor.gray84),
            ),
            SizedBox(height: 17),
            CommonContainer.reviewBox(),
            SizedBox(height: 17),
            CommonContainer.reviewBox(),
          ],
        ),
      ),
    );
  }

  Widget buildFollowersDetails() {
    return Container(
      key: const ValueKey('shopDetails'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        gradient: LinearGradient(
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

            /// SHOP DETAILS CARD
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
                        Text(
                          'Kaalavasal',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                            '12, 2, Tirupparankunram Rd, Kunram',
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
                  GestureDetector(
                    onTap: () => setState(() => followersSelectedIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: followersSelectedIndex == 0
                              ? AppColor.black
                              : AppColor.borderLightGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '15 Last week',
                          style: TextStyle(
                            color: followersSelectedIndex == 0
                                ? AppColor.black
                                : AppColor.borderLightGrey,
                            fontWeight: followersSelectedIndex == 0
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => followersSelectedIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: followersSelectedIndex == 1
                              ? AppColor.black
                              : AppColor.borderLightGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '38 Last Month',
                          style: TextStyle(
                            color: followersSelectedIndex == 1
                                ? AppColor.black
                                : AppColor.borderLightGrey,
                            fontWeight: followersSelectedIndex == 1
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => followersSelectedIndex = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: followersSelectedIndex == 2
                              ? AppColor.black
                              : AppColor.borderLightGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '15 Last week',
                          style: TextStyle(
                            color: followersSelectedIndex == 2
                                ? AppColor.black
                                : AppColor.borderLightGrey,
                            fontWeight: followersSelectedIndex == 2
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => followersSelectedIndex = 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: followersSelectedIndex == 3
                              ? AppColor.black
                              : AppColor.borderLightGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '103 All times',
                          style: TextStyle(
                            color: followersSelectedIndex == 3
                                ? AppColor.black
                                : AppColor.borderLightGrey,
                            fontWeight: followersSelectedIndex == 3
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

                                    // 🔹 If unsubscribed, apply blur overlay
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 8,
                                          sigmaY: 8,
                                        ),
                                        child: Container(
                                          color: Colors.black.withOpacity(
                                            0.3,
                                          ), // slight dark overlay
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
                                  decoration: BoxDecoration(
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
                              Text(
                                'Vignesh',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Joined at 11.30Am',
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
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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
