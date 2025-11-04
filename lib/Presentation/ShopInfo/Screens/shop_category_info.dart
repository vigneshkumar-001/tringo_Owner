import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/shop_photo_info.dart';

import '../../../Core/Utility/thanglish_to_tamil.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';

class ShopCategoryInfo extends StatefulWidget {
  const ShopCategoryInfo({super.key});

  @override
  State<ShopCategoryInfo> createState() => _ShopCategoryInfotate();
}

class _ShopCategoryInfotate extends State<ShopCategoryInfo> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController addressTamilNameController =
      TextEditingController();
  final TextEditingController descriptionTamilController =
      TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> cities = ['Madurai', 'Chennai', 'Coimbatore'];

  List<String> tamilNameSuggestion = [];
  List<String> descriptionTamilSuggestion = [];
  List<String> addressTamilSuggestion = [];
  bool isTamilNameLoading = false;
  bool isDescriptionTamilLoading = false;
  bool isAddressLoading = false;

  void _onSubmit() {
    // Trigger all validators
    // if (_formKey.currentState!.validate()) {
    //   // All fields valid → proceed
    //   print('✅ All fields valid, proceed with API call');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Form Submitted Successfully')),
    //   );
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => CreateAppOffer()),
    //   );
    // } else {
    //   // Some field invalid → show error
    //   print('❌ Validation failed');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please fill all required fields')),
    //   );
    // }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopPhotoInfo()),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      CommonContainer.topLeftArrow(
                        onTap: () => Navigator.pop(context),
                      ),
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
                        onChanged: (value) async {
                          setState(() => isTamilNameLoading = true);
                          final result =
                              await TanglishTamilHelper.transliterate(value);

                          setState(() {
                            tamilNameSuggestion = result;
                            isTamilNameLoading = false;
                          });
                        },

                        controller: tamilNameController,
                        text: 'Tamil',
                        isTamil: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Shop Name in Tamil'
                            : null,
                      ),
                      if (isTamilNameLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (tamilNameSuggestion.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tamilNameSuggestion.length,
                            itemBuilder: (context, index) {
                              final suggestion = tamilNameSuggestion[index];
                              return ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  print("Selected suggestion: $suggestion");
                                  TanglishTamilHelper.applySuggestion(
                                    controller: tamilNameController,
                                    suggestion: suggestion,
                                    onSuggestionApplied: () {
                                      setState(() => tamilNameSuggestion = []);
                                    },
                                  );
                                },
                                // onTap:
                                //     () => _onSuggestionSelected(suggestion),
                              );
                            },
                          ),
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
                        onChanged: (value) async {
                          setState(() => isDescriptionTamilLoading = true);
                          final result =
                              await TanglishTamilHelper.transliterate(value);

                          setState(() {
                            descriptionTamilSuggestion = result;
                            isDescriptionTamilLoading = false;
                          });
                        },
                        controller: descriptionTamilController,
                        maxLine: 4,
                        text: 'Tamil',
                        isTamil: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Describe in Tamil'
                            : null,
                      ),
                      if (isDescriptionTamilLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (descriptionTamilSuggestion.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: descriptionTamilSuggestion.length,
                            itemBuilder: (context, index) {
                              final suggestion =
                                  descriptionTamilSuggestion[index];
                              return ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  print("Selected suggestion: $suggestion");
                                  TanglishTamilHelper.applySuggestion(
                                    controller: descriptionTamilController,
                                    suggestion: suggestion,
                                    onSuggestionApplied: () {
                                      setState(
                                        () => descriptionTamilSuggestion = [],
                                      );
                                    },
                                  );
                                },
                                // onTap:
                                //     () => _onSuggestionSelected(suggestion),
                              );
                            },
                          ),
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
                        onChanged: (value) async {
                          setState(() => isAddressLoading = true);
                          final result =
                              await TanglishTamilHelper.transliterate(value);

                          setState(() {
                            addressTamilSuggestion = result;
                            isAddressLoading = false;
                          });
                        },
                        controller: addressTamilNameController,
                        maxLine: 4,
                        text: 'Tamil',
                        isTamil: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Address in Tamil'
                            : null,
                      ),
                      if (isAddressLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (addressTamilSuggestion.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: addressTamilSuggestion.length,
                            itemBuilder: (context, index) {
                              final suggestion = addressTamilSuggestion[index];
                              return ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  print("Selected suggestion: $suggestion");
                                  TanglishTamilHelper.applySuggestion(
                                    controller: descriptionTamilController,
                                    suggestion: suggestion,
                                    onSuggestionApplied: () {
                                      setState(
                                        () => addressTamilSuggestion = [],
                                      );
                                    },
                                  );
                                },
                                // onTap:
                                //     () => _onSuggestionSelected(suggestion),
                              );
                            },
                          ),
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
                        dropdownItems: cities,
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
