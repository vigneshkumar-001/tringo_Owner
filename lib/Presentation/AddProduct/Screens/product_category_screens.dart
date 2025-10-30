import 'package:flutter/material.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import 'add_product_list.dart';

class ProductCategoryScreens extends StatefulWidget {
  const ProductCategoryScreens({super.key});

  @override
  State<ProductCategoryScreens> createState() => _ProductCategoryScreensState();
}

class _ProductCategoryScreensState extends State<ProductCategoryScreens> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> cities = ['Madurai', 'Chennai', 'Coimbatore'];
  final List<String> offers = [
    'First App Offer',
    'Second App Offer',
    'Third App Offer',
  ];

  void _validateAndContinue() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // 👉 TODO: Navigate to next screen here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddProductList()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly.'),
          backgroundColor: Colors.red,
        ),
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
                  image: AppImages.addProduct,
                  text: 'Add Product',
                  imageHeight: 85,
                  gradientColor: AppColor.lavenderMist,
                  value: 0.8,
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Category',
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
                      Text(
                        'Product name',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _productNameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Product name'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Product price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _productPriceController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Product price'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'App Offer price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        imagePath: AppImages.downArrow,
                        verticalDivider: false,
                        controller: _offerController,
                        isDropdown: true,
                        dropdownItems: offers,
                        context: context,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select an Offer'
                            : null,
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _offerPriceController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Offer price'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Product Description',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        verticalDivider: false,
                        controller: _descriptionController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Product Description'
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
                            ? 'Please select Door Delivery option'
                            : null,
                      ),
                      SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _validateAndContinue,
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
