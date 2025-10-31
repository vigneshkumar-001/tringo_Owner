import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Utility/common_Container.dart';

class AboutMeScreens extends StatefulWidget {
  const AboutMeScreens({super.key});

  @override
  State<AboutMeScreens> createState() => _AboutMeScreensState();
}

class _AboutMeScreensState extends State<AboutMeScreens> {
  int selectedIndex = 0;
  int selectedWeight = 0; // default
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
                child: Row(children: [CommonContainer.doorDelivery()]),
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
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            top: BorderSide(width: 1, color: AppColor.black),
                            bottom: BorderSide(width: 3, color: AppColor.black),
                            left: BorderSide(width: 1, color: AppColor.black),
                            right: BorderSide(width: 1, color: AppColor.black),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(AppImages.aboutMeFill, height: 20),
                              SizedBox(width: 10),
                              Text('Shop Details'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.leftArrow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(AppImages.analytics, height: 20),
                              SizedBox(width: 10),
                              Text(
                                'Shop Details',
                                style: AppTextStyles.mulish(
                                  color: AppColor.gray84,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.leftArrow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(AppImages.groupPeople, height: 20),
                              SizedBox(width: 10),
                              Text(
                                'Followers',
                                style: AppTextStyles.mulish(
                                  color: AppColor.gray84,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),
              Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // 🔹 prevents extra vertical space
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  padding: const EdgeInsets.all(
                                    5,
                                  ), // 🔹 reduce vertical space
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
                            const SizedBox(height: 5),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: AppColor.iceBlue,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Edit Shop Details',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.resendOtp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          AppImages.rightArrow,
                                          color: AppColor.resendOtp,
                                          height: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: AppColor.iceBlue,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Edit Shop Details',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.resendOtp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          AppImages.rightArrow,
                                          color: AppColor.resendOtp,
                                          height: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: AppColor.iceBlue,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Edit Shop Details',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.resendOtp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.asset(
                                          AppImages.rightArrow,
                                          color: AppColor.resendOtp,
                                          height: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.attractCustomerCard(
                        title: 'Attract More Customers',
                        description: 'Unlock premium to attract more customers',
                        onTap: () {},
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
                        // weightOptions: const ['300Gm', '500Gm'],
                        // selectedWeightIndex: selectedWeight,
                        // onWeightChanged: (i) =>
                        //     setState(() => selectedWeight = i),
                      ),
                      Row(

                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.call,
                                        color: AppColor.white,
                                        height: 16,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Edit',
                                        style: AppTextStyles.mulish(
                                          color: AppColor.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.leftArrow,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
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

                      SizedBox(height: 30),

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



                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
