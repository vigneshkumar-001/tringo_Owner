import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';

import 'package:tringo_vendor/Core/Session/registration_session.dart';

class ShopsDetails extends StatefulWidget {
  const ShopsDetails({super.key});

  @override
  State<ShopsDetails> createState() => _ShopsDetailsState();
}

class _ShopsDetailsState extends State<ShopsDetails> {
  int selectedIndex = 0;
  int selectedWeight = 0; // default

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        googleMapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (e) {
      debugPrint('Error launching map: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to open map')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const String shopDisplayNameTamil =
        'ஸ்ரீ கிருஷ்ணா ஸ்வீட்ஸ் பிரைவேட் லிமிடெட்';
    const String shopDisplayName = 'Sri Krishna Sweets Private Limited';
    // final bool showAddBranch =
    //     RegistrationSession.instance.businessType == BusinessType.company;
    // Session-based flags
    final bool isCompany =
        RegistrationSession.instance.businessType == BusinessType.company;
    final bool isIndividual =
        RegistrationSession.instance.businessType == BusinessType.individual;

    final bool showAddBranch = isCompany; // company-only
    // IMPORTANT: Attract card is ONLY for Individual (per your requirement)

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [AppColor.scaffoldColor, AppColor.leftArrow],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          CommonContainer.topLeftArrow(
                            onTap: () => Navigator.pop(context),
                          ),
                          Spacer(),
                          CommonContainer.gradientContainer(
                            text: 'Sweets & Bakery',
                            textColor: AppColor.skyBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            shopDisplayName,
                            style: AppTextStyles.mulish(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset(
                                AppImages.locationImage,
                                height: 15,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '12, 2, Tirupparankunram Rd, kunram ',
                                  style: AppTextStyles.mulish(
                                    color: AppColor.darkGrey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 27),
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          child: CommonContainer.callNowButton(
                            callImage: AppImages.callImage,
                            callText: 'Call Now',
                            whatsAppIcon: true,
                            whatsAppOnTap: () {},
                            messageOnTap: () {},
                            MessageIcon: true,
                            mapText: 'Map',
                            mapOnTap: () =>
                                _openMap(9.91878153068342, 78.11575595524265),
                            mapImage: AppImages.locationImage,
                            callIconSize: 21,
                            callTextSize: 16,
                            mapIconSize: 21,
                            mapTextSize: 16,
                            messagesIconSize: 23,
                            whatsAppIconSize: 23,
                            fireIconSize: 23,
                            callNowPadding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            mapBoxPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            iconContainerPadding: EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 13,
                            ),
                            messageContainer: true,
                            mapBox: true,
                          ),
                        ),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    clipBehavior: Clip.antiAlias,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      AppImages.imageContainer1,
                                      height: 230,
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
                                              color: AppColor.darkBlue
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(1),
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
                              Image.asset(
                                AppImages.imageContainer2,
                                height: 250,
                                width: 310,
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                AppImages.imageContainer3,
                                height: 250,
                                width: 310,
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),

                        if (showAddBranch)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShopCategoryInfo(
                                    initialShopNameEnglish: shopDisplayName,
                                    initialShopNameTamil: shopDisplayNameTamil,
                                    isService: true,      // <-- pass the actual value
                                    isIndividual: false,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.borderLightGrey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.addBranch,
                                        height: 22,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Add Branch',
                                        style: AppTextStyles.mulish(
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 15),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppImages.fireImage,
                          height: 35,
                          color: AppColor.darkBlue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Offer Products',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColor.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CommonContainer.foodList(
                      fontSize: 14,
                      titleWeight: FontWeight.w700,
                      onTap: () {},
                      imageWidth: 130,
                      image: AppImages.snacks1,
                      foodName: 'Badam Mysurpa',
                      ratingStar: '4.5',
                      ratingCount: '16',
                      offAmound: '₹79',
                      oldAmound: '₹110',
                      km: '',
                      location: '',
                      Verify: false,
                      locations: false,
                      weight: false,
                      horizontalDivider: false,
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductCategoryScreens(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.lightGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 22.5),
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
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    if (isIndividual)
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
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Image.asset(
                          AppImages.reviewImage,
                          height: 27.08,
                          width: 26,
                        ),
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
                    SizedBox(height: 20),
                    CommonContainer.reviewBox(),
                    SizedBox(height: 17),
                    CommonContainer.reviewBox(),
                    SizedBox(height: 78),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.scaffoldColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  RegistrationSession.instance
                      .reset(); // becomes non-premium again
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CommonBottomNavigation(initialIndex: 0),
                    ),
                    (route) => false, // clears back stack
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Close Preview',
                  style: AppTextStyles.mulish(
                    color: AppColor.scaffoldColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
