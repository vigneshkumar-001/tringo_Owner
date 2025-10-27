import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';

class ShopInfo extends StatefulWidget {
  const ShopInfo({super.key});

  @override
  State<ShopInfo> createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> cities = ['Madurai', 'Chennai', 'Coimbatore'];
  final List<String> genders = ['Male', 'Female', 'Other'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style: GoogleFonts.mulish(
                        fontSize: 16,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.registerBCImage),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.scaffoldColor, AppColor.lightSkyBlue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Image.asset(AppImages.shopInfoImage, height: 85),
                      SizedBox(height: 15),
                      Text(
                        'Shop Info',
                        style: GoogleFonts.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(height: 30),
                      LinearProgressIndicator(
                        minHeight: 12,
                        value: 0.7,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.mediumGreen,
                        ),
                        backgroundColor: AppColor.scaffoldColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Category',
                      style: GoogleFonts.mulish(color: AppColor.mildBlack),
                    ),
                    SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      text: 'Category',
                      imagePath: AppImages.downArrow,
                      verticalDivider: false,
                      controller: _categoryController,
                      isDropdown: true,
                      dropdownItems: categories,
                      context: context,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please select a category' : null,
                    ),
                    SizedBox(height: 10,),
                    CommonContainer.fillingContainer(
                      text: 'City',
                      imagePath: AppImages.downArrow,
                      verticalDivider: false,
                      controller: _cityController,
                      isDropdown: true,
                      dropdownItems: cities,
                      context: context,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please select a city' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
