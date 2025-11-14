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
import '../../ShopInfo/model/shop_category_list_response.dart';
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
  List<ShopCategoryListData>? _selectedCategoryChildren;
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
  final List<String> offers = ['true', 'fast'];

  String productCategorySlug = '';
  String productSubCategorySlug = '';

  void _showCategoryBottomSheet(
    BuildContext context,
    List<ShopCategoryListData>? categories,
    TextEditingController controller, {
    bool isLoading = false,

    void Function(ShopCategoryListData selectedCategory)? onCategorySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final searchController = TextEditingController();
        List<ShopCategoryListData> filtered = List.from(categories ?? []);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                if (isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (categories == null || categories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No categories found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Search Field (no divider / underline)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setModalState(() {
                            filtered = categories
                                .where(
                                  (c) => c.name.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search category...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none, // ❌ No divider line
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final category = filtered[index];
                          return ListTile(
                            title: Text(category.name),
                            trailing: category.children.isNotEmpty
                                ? const Icon(Icons.arrow_forward_ios, size: 14)
                                : null,
                            onTap: () {
                              Navigator.pop(context);

                              setState(() {
                                controller.text = category.name;
                                productCategorySlug = category.slug;
                              });
                              if (onCategorySelected != null) {
                                onCategorySelected(category);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCategoryChildrenBottomSheet(
    BuildContext context,
    List<ShopCategoryListData> children,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final searchController = TextEditingController();
        List<ShopCategoryListData> filtered = List.from(children);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Select Subcategory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Search field with no underline
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setModalState(() {
                            filtered = children
                                .where(
                                  (c) => c.name.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search subcategory...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none, // ❌ No divider
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No subcategories found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final child = filtered[index];
                                return ListTile(
                                  title: Text(child.name),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      controller.text = child.name;
                                      productCategorySlug = child.slug;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).fetchProductCategories();
    });
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
                      /*             CommonContainer.fillingContainer(
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
                      ),*/
                      GestureDetector(
                        onTap: () {
                          final categoriesList =
                              state.shopCategoryListResponse?.data ?? [];
                          if (categoriesList.isNotEmpty) {
                            _showCategoryBottomSheet(
                              context,
                              categoriesList,
                              _categoryController,
                              onCategorySelected: (selectedCategory) {
                                _selectedCategoryChildren =
                                    selectedCategory.children;
                                _subCategoryController.clear();
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 19,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _categoryController.text.isEmpty
                                        ? ""
                                        : _categoryController.text,
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Image.asset(AppImages.downArrow, height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          if (_categoryController.text.isEmpty) {
                            AppSnackBar.info(
                              context,
                              'Please select a category first',
                            );
                          }
                          _showCategoryChildrenBottomSheet(
                            context,
                            _selectedCategoryChildren!,
                            _subCategoryController,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 19,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _subCategoryController.text.isEmpty
                                        ? " "
                                        : _subCategoryController.text,
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: _subCategoryController.text.isEmpty
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Image.asset(AppImages.downArrow, height: 30),
                              ],
                            ),
                          ),
                        ),
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
