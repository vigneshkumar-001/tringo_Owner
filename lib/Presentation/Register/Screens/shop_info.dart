import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';

class ShopInfo extends StatefulWidget {
  const ShopInfo({super.key});

  @override
  State<ShopInfo> createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> cities = ['Madurai', 'Chennai', 'Coimbatore'];
  final List<String> genders = ['Male', 'Female', 'Other'];

  void _onSubmit() {
    // Trigger all validators
    if (_formKey.currentState!.validate()) {
      // All fields valid → proceed
      print('✅ All fields valid, proceed with API call');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form Submitted Successfully')),
      );
    } else {
      // Some field invalid → show error
      print('❌ Validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      CommonContainer.topLeftArrow(onTap: () {}),
                      SizedBox(width: 50),
                      Text(
                        'Register Shop - Individual',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          color: AppColor.mildBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 35),
                CommonContainer.registerTopContainer(
                  image: AppImages.shopInfoImage,
                  text: 'Shop Info',
                  imageHeight: 85,
                  gradientColor: AppColor.lightSkyBlue,
                  value: 0.3,
                ),
                // Container(
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage(AppImages.registerBCImage),
                //       fit: BoxFit.cover,
                //     ),
                //     gradient: LinearGradient(
                //       colors: [AppColor.scaffoldColor, AppColor.lightSkyBlue],
                //       begin: Alignment.topCenter,
                //       end: Alignment.bottomCenter,
                //     ),
                //     borderRadius: BorderRadius.only(
                //       bottomRight: Radius.circular(30),
                //       bottomLeft: Radius.circular(30),
                //     ),
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //     child: Column(
                //       children: [
                //         Image.asset(AppImages.shopInfoImage, height: 85),
                //         SizedBox(height: 15),
                //         Text(
                //           'Shop Info',
                //           style: AppTextStyles.mulish(
                //             fontSize: 28,
                //             fontWeight: FontWeight.bold,
                //             color: AppColor.mildBlack,
                //           ),
                //         ),
                //         SizedBox(height: 30),
                //         LinearProgressIndicator(
                //           minHeight: 12,
                //           value: 0.7,
                //           valueColor: AlwaysStoppedAnimation<Color>(
                //             AppColor.mediumGreen,
                //           ),
                //           backgroundColor: AppColor.scaffoldColor,
                //           borderRadius: BorderRadius.circular(16),
                //         ),
                //         SizedBox(height: 25),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop Category',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        imagePath: AppImages.downArrow,
                        verticalDivider: false,
                        controller: _categoryController,
                        isDropdown: true,
                        dropdownItems: categories,
                        context: context,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a category'
                            : null,
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        imagePath: AppImages.downArrow,
                        verticalDivider: false,
                        controller: _cityController,
                        isDropdown: true,
                        dropdownItems: cities,
                        context: context,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a city'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text(
                            'Shop name',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '( As per Govt Certificate )',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        text: 'English',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Shop Name in English'
                            : null,
                      ),
                      SizedBox(height: 15),
                      CommonContainer.fillingContainer(
                        text: 'Tamil',
                        isTamil: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Shop Name in Tamil'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Describe Shop',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        text: 'English',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Describe in English'
                            : null,
                      ),
                      SizedBox(height: 15),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        text: 'Tamil',
                        isTamil: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Describe in Tamil'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Address',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        text: 'English',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Address in English'
                            : null,
                      ),
                      SizedBox(height: 15),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        text: 'Tamil',
                        isTamil: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Address in Tamil'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'GPS Location',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        text: 'Get by GPS',
                        textColor: AppColor.skyBlue,
                        textFontWeight: FontWeight.w700,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a GPS Location'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Primary Mobile Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: true,
                        isMobile: true,
                        text: 'Mobile No',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Primary Mobile Number'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Alternate Mobile Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: true,
                        isMobile: true,
                        text: 'Mobile No',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Alternate Mobile Number'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Email Id',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: true,
                        text: 'Email Id',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Email Id'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Door Delivery',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        imagePath: AppImages.downArrow,
                        verticalDivider: false,
                        controller: _genderController,
                        isDropdown: true,
                        dropdownItems: categories,
                        context: context,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a Door Delivery'
                            : null,
                      ),
                      SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _onSubmit,
                        text: Text(
                          'Save & Continue',
                          style: AppTextStyles.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        imagePath: AppImages.rightStickArrow,
                        imgHeight: 20,
                      ),
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
