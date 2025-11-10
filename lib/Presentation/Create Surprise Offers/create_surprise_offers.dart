import 'package:flutter/material.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../Create App Offer/Screens/offer_products.dart';
import '../ShopInfo/Screens/search_keyword.dart';

class CreateSurpriseOffers extends StatefulWidget {
  const CreateSurpriseOffers({super.key});

  @override
  State<CreateSurpriseOffers> createState() => _CreateSurpriseOffersState();
}

class _CreateSurpriseOffersState extends State<CreateSurpriseOffers> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _offerTitleController = TextEditingController();
  final TextEditingController _availableDateController =
      TextEditingController();
  final TextEditingController _offerDescriptionController =
      TextEditingController();
  final TextEditingController _announcementDateController =
      TextEditingController();
  int Percentage = 1;

  void _onSubmit() {
    // if (_formKey.currentState!.validate()) {
    //   // ✅ All fields valid
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Form submitted successfully')),
    //   );
    //
    //   // Navigate to next screen
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ShopPhotoInfo(),
    //     ), // Replace with your next screen
    //   );
    // } else {
    //   // ❌ Validation failed
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please fill all required fields')),
    //   );
    // }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchKeyword(),
      ), // Replace with your next screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: CommonContainer.topLeftArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.registerBCImage),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                      colors: [AppColor.scaffoldColor, AppColor.paleMintGreen],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.surprise, height: 154),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          Text(
                            'Create Surprise Offer',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.mulish(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 70.0,
                            ),
                            child: Text(
                              'Clients can view or claim this coupon by near your shop only',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.mulish(
                                fontSize: 14,
                                color: AppColor.gray84,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 35),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offer Title',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _offerTitleController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter App Offer Title'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Offer Description',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        verticalDivider: false,
                        controller: _offerDescriptionController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter App Offer Description'
                            : null,
                      ),
                      SizedBox(height: 25),
                      CommonContainer.containerTitle(
                        context: context,
                        title: 'No of Coupons for Clients',
                        image: AppImages.iImage,
                        infoMessage:
                        'Please upload a clear photo of your shop signboard showing the name clearly.',
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          InkWell(
                            // onTap: () {
                            //   if (Percentage > 0) {
                            //     setState(() {
                            //       Percentage -=
                            //           5; // reduce by 5% or any step you want
                            //       if (Percentage < 0) Percentage = 0;
                            //     });
                            //   }
                            // },
                            onTap: () {
                              if (Percentage > 1) {
                                setState(() {
                                  Percentage--;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.leftArrow,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 20,
                                ),
                                child: Image.asset(AppImages.sub, width: 20),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: AppColor.leftArrow,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    '$Percentage%',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColor.mildBlack,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            // onTap: () {
                            //   setState(() {
                            //     Percentage +=
                            //         5; // increase by 5% or whatever increment you prefer
                            //     if (Percentage > 100)
                            //       Percentage = 100; // max limit
                            //   });
                            // },
                            onTap: () {
                              setState(() {
                                Percentage++;
                              });
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.leftArrow,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 20,
                                ),
                                child: Image.asset(
                                  AppImages.addPlus,
                                  width: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text(
                            'Available Date',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '( Start to End Date )',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        controller: _availableDateController,
                        context: context,
                        datePickMode: DatePickMode.range,
                        styledRangeText: true,
                        validator: (value) {
                          if ((value == null || value.isEmpty)) {
                            return 'Please select a valid date range';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Announcement Date',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        isDOB: true,
                        verticalDivider: true,
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        datePickMode: DatePickMode.single,
                        controller: _announcementDateController,
                        context: context,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Announcement Date';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _onSubmit,
                        text: Text(
                          'Create Now',
                          style: AppTextStyles.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        imagePath: AppImages.rightStickArrow,
                        imgHeight: 20,
                      ),
                      SizedBox(height: 36),
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
}
