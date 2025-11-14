import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Controller/product_notifier.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../../Core/Widgets/bottom_navigation_bar.dart';
import 'add_product_list.dart';

class ProductCategoryScreens extends ConsumerStatefulWidget {
  final bool? isService;
  final bool? isIndividual;
  const ProductCategoryScreens({super.key, this.isService, this.isIndividual});

  @override
  ConsumerState<ProductCategoryScreens> createState() =>
      _ProductCategoryScreensState();
}

class _ProductCategoryScreensState
    extends ConsumerState<ProductCategoryScreens> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> categories = [
    'product-mobile-devices',
    'Clothing',
    'Groceries',
  ];
  final List<String> cities = [
    'product-mobile-smartphones',
    'Chennai',
    'Coimbatore',
  ];
  final List<String> offers = [
    'First App Offer',
    'Second App Offer',
    'Third App Offer',
  ];

  void _validateAndContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductList()),
    );

    // if (_formKey.currentState!.validate()) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Form submitted successfully!'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );A
    //
    //   // 👉 TODO: Navigate to next screen here
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (_) => AddProductList()),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please fill all required fields correctly.'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);
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
                  text: widget.isService == true
                      ? 'Add Service'
                      : 'Add Product',
                  imageHeight: 85,
                  gradientColor: AppColor.lavenderMist,
                  value: 0.8,
                ),

                // CommonContainer.registerTopContainer(
                //   image: AppImages.addProduct,
                //   text: 'Add Product',
                //   imageHeight: 85,
                //   gradientColor: AppColor.lavenderMist,
                //   value: 0.8,
                // ),
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
                        controller: _subCategoryController,
                        isDropdown: true,
                        dropdownItems: cities,
                        context: context,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a sub category'
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
                      // Text(
                      //   'Product price',
                      //   style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      // ),
                      Text(
                        widget.isService == true
                            ? 'Start From'
                            : 'Product price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),

                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
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
                        onTap: () async {
                          final priceText = _productPriceController.text.trim();
                          final price = int.tryParse(priceText);

                          if (_formKey.currentState!.validate()) {
                            final success = await ref
                                .read(productNotifierProvider.notifier)
                                .addProduct(
                                  category: _categoryController.text.trim(),
                                  subCategory: _subCategoryController.text
                                      .trim(),
                                  englishName: _productNameController.text
                                      .trim(),
                                  price: price ?? 0,
                                  offerLabel: _offerController.text.trim(),
                                  offerValue: _offerPriceController.text.trim(),
                                  description: _descriptionController.text
                                      .trim(),
                                );
                            if (success) {
                              context.pushNamed(AppRoutes.addProductList);
                            } else {
                              final err = ref
                                  .read(productNotifierProvider)
                                  .error;
                              if (err != null && err.isNotEmpty) {
                                AppSnackBar.error(context, err);
                              } else {
                                AppSnackBar.error(
                                  context,
                                  'Something went wrong',
                                );
                              }
                            }
                          } else {
                            AppSnackBar.info(
                              context,
                              'Please fill all required fields correctly.',
                            );
                          }
                        },
                        text: state.isLoading
                            ? const ThreeDotsLoader()
                            : Text(
                                'Save & Continue',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        imagePath: state.isLoading
                            ? null
                            : AppImages.rightStickArrow,
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
