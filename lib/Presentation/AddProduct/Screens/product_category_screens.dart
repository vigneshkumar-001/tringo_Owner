import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Controller/product_notifier.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../ShopInfo/model/shop_category_list_response.dart';
import '../Service Info/Controller/service_info_notifier.dart';
import 'add_product_list.dart';

class ProductCategoryScreens extends ConsumerStatefulWidget {
  final bool? isService;
  final bool? isIndividual;
  final bool allowOfferEdit;
  final String? initialOfferLabel;
  final String? initialOfferValue;
  final String? shopId;
  final String? productId;
  final String? page;
  final String? pages;

  final String? initialCategoryName;
  final String? initialSubCategoryName;
  final String? initialProductName;
  final int? initialPrice;
  final String? initialDescription;
  final String? initialDoorDelivery; // "Yes" / "No"
  final String? initialCategorySlug;
  final String? initialSubCategorySlug;

  const ProductCategoryScreens({
    super.key,
    this.isService,
    this.shopId,
    this.productId,
    this.page,
    this.pages,
    this.isIndividual,
    this.allowOfferEdit = false,
    this.initialOfferLabel,
    this.initialOfferValue,
    this.initialCategoryName,
    this.initialSubCategoryName,
    this.initialProductName,
    this.initialPrice,
    this.initialDescription,
    this.initialDoorDelivery,
    this.initialCategorySlug,
    this.initialSubCategorySlug,
  });

  @override
  ConsumerState<ProductCategoryScreens> createState() =>
      _ProductCategoryScreensState();
}

class _ProductCategoryScreensState
    extends ConsumerState<ProductCategoryScreens> {
  final _formKey = GlobalKey<FormState>();
  bool _categoryHasError = false;
  bool _subCategoryHasError = false;
  bool _doorDelivery = false;

  List<ShopCategoryListData>? _selectedCategoryChildren;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();
  final TextEditingController _doorDeliveryController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> categories = [
    'product-mobile-devices',
    'Clothing',
    'Groceries',
  ];
  final List<String> cities = ['Yes', 'No'];
  final List<String> offers = ['First App Offer', 'second App Offer'];

  String productCategorySlug = '';
  String productSubCategorySlug = '';
  bool get isIndividualFlow {
    final session = RegistrationProductSeivice.instance;
    return session.businessType == BusinessType.individual;
  }

  void _showCategoryBottomSheet(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller, {
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

        return Consumer(
          builder: (context, ref, _) {
            final productState = ref.watch(productNotifierProvider);
            final isLoading = productState.isLoading;
            final categories =
                productState.shopCategoryListResponse?.data ?? [];

            List<ShopCategoryListData> filtered = List.from(categories);

            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.8,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    if (!isLoading && categories.isEmpty) {
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
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
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
                              prefixIcon: Icon(
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
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: ThreeDotsLoader(
                                      dotColor: AppColor.darkBlue,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final category = filtered[index];
                                    return ListTile(
                                      title: Text(category.name),
                                      trailing: category.children.isNotEmpty
                                          ? const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                            )
                                          : null,
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          controller.text = category.name;
                                          productCategorySlug = category.slug;
                                          _categoryHasError = false;
                                          _subCategoryHasError = false;
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
                            borderSide: BorderSide.none,
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
                                      productSubCategorySlug = child.slug;
                                      _categoryHasError = false;
                                      _subCategoryHasError = false;
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

  Future<void> _showOfferBottomSheet() async {
    if (!widget.allowOfferEdit) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Select App Offer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...offers.map(
                (offer) => ListTile(
                  title: Text(offer),
                  onTap: () => Navigator.pop(context, offer),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _offerController.text = selected;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AppLogger.log.i(widget.productId);
    AppLogger.log.i(widget.page);

    _categoryController.text = widget.initialCategoryName ?? '';
    _subCategoryController.text = widget.initialSubCategoryName ?? '';
    _productNameController.text = widget.initialProductName ?? '';
    if (widget.initialPrice != null) {
      _productPriceController.text = widget.initialPrice!.toString();
    }
    _descriptionController.text = widget.initialDescription ?? '';
    _doorDeliveryController.text = widget.initialDoorDelivery ?? '';
    if (widget.initialDoorDelivery != null &&
        widget.initialDoorDelivery!.isNotEmpty) {
      _doorDelivery = widget.initialDoorDelivery == 'Yes';
    }

    productCategorySlug = widget.initialCategorySlug ?? '';
    productSubCategorySlug = widget.initialSubCategorySlug ?? '';

    _offerController.text = widget.initialOfferLabel ?? offers.first;
    _offerPriceController.text = widget.initialOfferValue ?? '5%';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).fetchProductCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final serviceState = ref.watch(serviceInfoNotifierProvider);

    // 👇 VERY IMPORTANT: Decide service / product from widget.isService if given
    final bool isServiceFlow =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;
    AppLogger.log.i('IS Service : $isServiceFlow');
    final bool isEditFromAboutMe =
        (widget.page == 'AboutMeScreens') &&
        (widget.productId != null && widget.productId!.isNotEmpty);

    final bool isLoading = isServiceFlow
        ? serviceState.isLoading
        : productState.isLoading;

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
                      const SizedBox(width: 50),
                      Text(
                        'Register Shop',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '-',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        isIndividualFlow ? 'Individual' : 'Company',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.mildBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                CommonContainer.registerTopContainer(
                  image: AppImages.addProduct,
                  text: isServiceFlow ? 'Add Service' : 'Add Product',
                  imageHeight: 85,
                  gradientColor: AppColor.lavenderMist,
                  value: 0.8,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isServiceFlow
                            ? ' Service Category'
                            : 'Product Category',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(productNotifierProvider.notifier)
                              .fetchProductCategories();

                          _showCategoryBottomSheet(
                            context,
                            ref,
                            _categoryController,
                            onCategorySelected: (selectedCategory) {
                              _selectedCategoryChildren =
                                  selectedCategory.children;
                              _subCategoryController.clear();
                              setState(() {
                                _categoryHasError = false;
                                _subCategoryHasError = false;
                              });
                            },
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
                            border: Border.all(
                              color: _categoryHasError
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 1.5,
                            ),
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
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_categoryController.text.isEmpty) {
                            AppSnackBar.info(
                              context,
                              'Please select a category first',
                            );
                            setState(() {
                              _categoryHasError = true;
                            });
                            return;
                          }

                          if (_selectedCategoryChildren == null ||
                              _selectedCategoryChildren!.isEmpty) {
                            AppSnackBar.info(
                              context,
                              'No subcategories available for this category',
                            );
                            return;
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
                            border: Border.all(
                              color: _subCategoryHasError
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 1.5,
                            ),
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
                      const SizedBox(height: 25),
                      Text(
                        isServiceFlow ? 'Service Name' : 'Product name',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _productNameController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return isServiceFlow
                        //         ? 'Please enter Service Name'
                        //         : 'Please enter Product name';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        isServiceFlow ? 'Start From' : 'Product price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
                        verticalDivider: false,
                        controller: _productPriceController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return isServiceFlow
                        //         ? 'Please enter Start From amount'
                        //         : 'Please enter Product price';
                        //   }
                        //   return null;
                        // },
                      ),
                      SizedBox(height: 25),
                      Text(
                        'App Offer price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        text1: 'First App Offer',
                        readOnly: true,
                        verticalDivider: false,
                        controller: _offerController,
                      ),
                      // GestureDetector(
                      //   onTap: widget.allowOfferEdit
                      //       ? _showOfferBottomSheet
                      //       : null,
                      //   child: AbsorbPointer(
                      //     child: CommonContainer.fillingContainer(
                      //       imagePath: widget.allowOfferEdit
                      //           ? AppImages.downArrow
                      //           : null,
                      //       verticalDivider: false,
                      //       controller: _offerController,
                      //       readOnly: true,
                      //       context: context,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
                        verticalDivider: false,
                        controller: _offerPriceController,
                        readOnly: !widget.allowOfferEdit,
                        onChanged: (value) {
                          final onlyDigits = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (onlyDigits.isEmpty) {
                            _offerPriceController.clear();
                            return;
                          }
                          final formatted = '$onlyDigits%';
                          _offerPriceController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        isServiceFlow
                            ? 'Service Description'
                            : 'Product Description',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        verticalDivider: false,
                        controller: _descriptionController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return isServiceFlow
                        //         ? 'Please enter Service Description'
                        //         : 'Please enter Product Description';
                        //   }
                        //   return null;
                        // },
                      ),
                      if (!isServiceFlow) ...[
                        const SizedBox(height: 25),
                        Text(
                          'Door Delivery',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CommonContainer.fillingContainer(
                          imagePath: AppImages.downArrow,
                          verticalDivider: false,
                          controller: _doorDeliveryController,
                          isDropdown: true,
                          dropdownItems: cities,
                          context: context,
                          // validator: (value) => value == null || value.isEmpty
                          //     ? 'Please select Door Delivery option'
                          //     : null,
                        ),
                        const SizedBox(height: 30),
                      ],
                      const SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,

                        // onTap: () async {
                        //   FocusScope.of(context).unfocus();
                        //
                        //   final priceText = _productPriceController.text.trim();
                        //   final price = int.tryParse(priceText);
                        //
                        //   final hasCategoryError = _categoryController.text
                        //       .trim()
                        //       .isEmpty;
                        //   final hasSubCategoryError = _subCategoryController
                        //       .text
                        //       .trim()
                        //       .isEmpty;
                        //
                        //   setState(() {
                        //     _categoryHasError = hasCategoryError;
                        //     _subCategoryHasError = hasSubCategoryError;
                        //   });
                        //
                        //   final formValid = _formKey.currentState!.validate();
                        //
                        //   if (!formValid ||
                        //       hasCategoryError ||
                        //       hasSubCategoryError) {
                        //     AppSnackBar.info(
                        //       context,
                        //       'Please fill all required fields correctly.',
                        //     );
                        //     return;
                        //   }
                        //
                        //   // -------------------------------------------------------------------
                        //   // 🔵 DOOR DELIVERY FIX — convert dropdown to boolean before saving
                        //   // -------------------------------------------------------------------
                        //   if (!isServiceFlow) {
                        //     final ddText = _doorDeliveryController.text.trim();
                        //
                        //     if (ddText.isEmpty) {
                        //       AppSnackBar.error(
                        //         context,
                        //         'Please select Door Delivery',
                        //       );
                        //       return;
                        //     }
                        //
                        //     _doorDelivery =
                        //         ddText == 'Yes'; // <-- REAL VALUE NOW
                        //   } else {
                        //     _doorDelivery = false; // service case
                        //   }
                        //   // -------------------------------------------------------------------
                        //
                        //   bool success = false;
                        //
                        //   if (isServiceFlow) {
                        //     // service call...
                        //   } else {
                        //     // PRODUCT SAVE
                        //     success = await ref
                        //         .read(productNotifierProvider.notifier)
                        //         .addProduct(
                        //           doorDelivery: _doorDelivery,
                        //           productId: widget.productId,
                        //           shopId: widget.shopId,
                        //           category: _categoryController.text.trim(),
                        //           subCategory: _subCategoryController.text
                        //               .trim(),
                        //           englishName: _productNameController.text
                        //               .trim(),
                        //           price: price ?? 0,
                        //           offerLabel: _offerController.text.trim(),
                        //           offerValue: _offerPriceController.text.trim(),
                        //           description: _descriptionController.text
                        //               .trim(),
                        //         );
                        //
                        //     if (!success) {
                        //       final err = ref
                        //           .read(productNotifierProvider)
                        //           .error;
                        //       if (err != null && err.isNotEmpty) {
                        //         AppSnackBar.error(context, err);
                        //       } else {
                        //         AppSnackBar.error(
                        //           context,
                        //           'Something went wrong',
                        //         );
                        //       }
                        //     }
                        //   }
                        //
                        //   if (success) {
                        //     // navigation logic...
                        //   }
                        // },
                        onTap: () async {
                          FocusScope.of(context).unfocus();

                          final priceText = _productPriceController.text.trim();
                          final price = int.tryParse(priceText);

                          final hasCategoryError = _categoryController.text
                              .trim()
                              .isEmpty;
                          final hasSubCategoryError = _subCategoryController
                              .text
                              .trim()
                              .isEmpty;

                          setState(() {
                            _categoryHasError = hasCategoryError;
                            _subCategoryHasError = hasSubCategoryError;
                          });

                          final formValid = _formKey.currentState!.validate();

                          // if (!formValid ||
                          //     hasCategoryError ||
                          //     hasSubCategoryError) {
                          //   AppSnackBar.info(
                          //     context,
                          //     'Please fill all required fields correctly.',
                          //   );
                          //   return;
                          // }

                          bool success = false;
                          if (!isServiceFlow) {
                            final ddText = _doorDeliveryController.text.trim();

                            if (ddText.isEmpty) {
                              AppSnackBar.error(
                                context,
                                'Please select Door Delivery',
                              );
                              return;
                            }

                            // 'Yes' → true, anything else → false
                            _doorDelivery = ddText == 'Yes';
                          } else {
                            _doorDelivery =
                                false; // services currently no door-delivery flag
                          }

                          if (isServiceFlow) {
                            // 🔵 SERVICE SAVE / UPDATE
                            final serviceResponse = await ref
                                .read(serviceInfoNotifierProvider.notifier)
                                .saveServiceInfo(
                                  ServiceId:
                                      widget.productId ??
                                      '', // serviceId in edit mode
                                  title: _productNameController.text.trim(),
                                  tamilName: _productNameController.text.trim(),
                                  description: _descriptionController.text
                                      .trim(),
                                  startsAt: price ?? 0,
                                  offerLabel: _offerController.text.trim(),
                                  offerValue: _offerPriceController.text.trim(),
                                  durationMinutes: 60,
                                  categoryId: productCategorySlug,
                                  subCategory: _subCategoryController.text
                                      .trim(),
                                  tags: const [],
                                );

                            success = serviceResponse != null;

                            if (!success) {
                              final svcState = ref.read(
                                serviceInfoNotifierProvider,
                              );
                              if (svcState.error != null &&
                                  svcState.error!.isNotEmpty) {
                                AppSnackBar.error(context, svcState.error!);
                              } else {
                                AppSnackBar.error(
                                  context,
                                  'Service save failed. Please try again.',
                                );
                              }
                            }
                          } else {
                            // PRODUCT SAVE / UPDATE
                            final ddText = _doorDeliveryController.text.trim();
                            if (ddText.isEmpty) {
                              AppSnackBar.error(
                                context,
                                'Please select Door Delivery option',
                              );
                              return;
                            }
                            _doorDelivery = ddText == 'Yes';
                            success = await ref
                                .read(productNotifierProvider.notifier)
                                .addProduct(
                                  doorDelivery:
                                      _doorDelivery, //  use state variable
                                  productId: widget.productId,
                                  shopId: widget.shopId,
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

                            if (!success) {
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
                          }

                          if (success) {
                            // 🎯 Navigation logic (product + service both use this)
                            if (widget.page == 'AboutMeScreens') {
                              // EDIT mode (product or service) -> productId / serviceId present
                              if (widget.productId != null &&
                                  widget.productId!.isNotEmpty) {
                                // ✅ Tell AboutMeScreens that something was updated
                                Navigator.pop(context, true);
                              } else {
                                // ADD mode from AboutMe -> go to AddProductList
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddProductList(),
                                  ),
                                );
                              }
                            } else {
                              // normal registration flow or other pages
                              context.pushNamed(AppRoutes.addProductList);
                            }
                          }
                        },
                        text: isLoading
                            ? const ThreeDotsLoader()
                            : Text(
                                isEditFromAboutMe
                                    ? 'Update'
                                    : 'Save & Continue',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        imagePath: isLoading ? null : AppImages.rightStickArrow,
                        imgHeight: 20,
                      ),

                      // CommonContainer.button(
                      //   buttonColor: AppColor.black,
                      //   onTap: () async {
                      //     FocusScope.of(context).unfocus();
                      //
                      //     final priceText = _productPriceController.text.trim();
                      //     final price = int.tryParse(priceText);
                      //
                      //     final hasCategoryError = _categoryController.text
                      //         .trim()
                      //         .isEmpty;
                      //     final hasSubCategoryError = _subCategoryController
                      //         .text
                      //         .trim()
                      //         .isEmpty;
                      //
                      //     setState(() {
                      //       _categoryHasError = hasCategoryError;
                      //       _subCategoryHasError = hasSubCategoryError;
                      //     });
                      //
                      //     final formValid = _formKey.currentState!.validate();
                      //
                      //     if (!formValid ||
                      //         hasCategoryError ||
                      //         hasSubCategoryError) {
                      //       AppSnackBar.info(
                      //         context,
                      //         'Please fill all required fields correctly.',
                      //       );
                      //       return;
                      //     }
                      //
                      //     bool doorDelivery = false; // state variable
                      //
                      //     Switch(
                      //       value: doorDelivery,
                      //       onChanged: (v) {
                      //         setState(() {
                      //           doorDelivery = v;
                      //         });
                      //       },
                      //     );
                      //     bool success = false;
                      //
                      //     if (isServiceFlow) {
                      //       final serviceResponse = await ref
                      //           .read(serviceInfoNotifierProvider.notifier)
                      //           .saveServiceInfo(
                      //             ServiceId: widget.productId ?? '',
                      //             title: _productNameController.text.trim(),
                      //             tamilName: _productNameController.text.trim(),
                      //             description: _descriptionController.text
                      //                 .trim(),
                      //             startsAt: price ?? 0,
                      //             offerLabel: _offerController.text.trim(),
                      //             offerValue: _offerPriceController.text.trim(),
                      //             durationMinutes: 60,
                      //             categoryId: productCategorySlug,
                      //             subCategory: _subCategoryController.text
                      //                 .trim(),
                      //             tags: const [],
                      //             keywords: const [],
                      //             images: const [],
                      //             isFeatured: false,
                      //             features: const [],
                      //           );
                      //
                      //       success = serviceResponse != null;
                      //
                      //       if (!success) {
                      //         final svcState = ref.read(
                      //           serviceInfoNotifierProvider,
                      //         );
                      //         if (svcState.error != null &&
                      //             svcState.error!.isNotEmpty) {
                      //           AppSnackBar.error(context, svcState.error!);
                      //         } else {
                      //           AppSnackBar.error(
                      //             context,
                      //             'Service save failed. Please try again.',
                      //           );
                      //         }
                      //       }
                      //     } else {
                      //       success = await ref
                      //           .read(productNotifierProvider.notifier)
                      //           .addProduct(
                      //             doorDelivery: doorDelivery,
                      //             productId: widget.productId,
                      //             shopId: widget.shopId,
                      //             category: _categoryController.text.trim(),
                      //             subCategory: _subCategoryController.text
                      //                 .trim(),
                      //             englishName: _productNameController.text
                      //                 .trim(),
                      //             price: price ?? 0,
                      //             offerLabel: _offerController.text.trim(),
                      //             offerValue: _offerPriceController.text.trim(),
                      //             description: _descriptionController.text
                      //                 .trim(),
                      //           );
                      //
                      //       if (!success) {
                      //         final err = ref
                      //             .read(productNotifierProvider)
                      //             .error;
                      //         if (err != null && err.isNotEmpty) {
                      //           AppSnackBar.error(context, err);
                      //         } else {
                      //           AppSnackBar.error(
                      //             context,
                      //             'Something went wrong',
                      //           );
                      //         }
                      //       }
                      //     }
                      //
                      //     if (success) {
                      //       //  Navigation logic
                      //       if (widget.page == 'AboutMeScreens') {
                      //         // EDIT mode -> productId present
                      //         if (widget.productId != null &&
                      //             widget.productId!.isNotEmpty) {
                      //           Navigator.pop(
                      //             context,
                      //             true,
                      //           ); // ✅ back to AboutMeScreens
                      //         } else {
                      //           // ADD mode from AboutMe -> go to AddProductList
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (_) =>
                      //                   AddProductList(), // ✅ goes to AddProductList
                      //             ),
                      //           );
                      //         }
                      //       } else {
                      //         // normal registration flow or other pages
                      //         context.pushNamed(AppRoutes.addProductList);
                      //       }
                      //     }
                      //
                      //     // if (success) {
                      //     //   //  Navigation logic
                      //     //   if (widget.page == 'AboutMeScreens') {
                      //     //     // EDIT mode -> productId present
                      //     //     if (widget.productId != null &&
                      //     //         widget.productId!.isNotEmpty) {
                      //     //       Navigator.pop(context, true);
                      //     //     } else {
                      //     //       // ADD mode from AboutMe -> go to AddProductList
                      //     //       Navigator.push(
                      //     //         context,
                      //     //         MaterialPageRoute(
                      //     //           builder: (_) => AddProductList(),
                      //     //         ),
                      //     //       );
                      //     //     }
                      //     //   } else {
                      //     //     // normal registration flow or other pages
                      //     //     context.pushNamed(AppRoutes.addProductList);
                      //     //   }
                      //     // }
                      //   },
                      //   text: isLoading
                      //       ? const ThreeDotsLoader()
                      //       : Text(
                      //           isEditFromAboutMe
                      //               ? 'Update'
                      //               : 'Save & Continue',
                      //           style: AppTextStyles.mulish(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.w700,
                      //           ),
                      //         ),
                      //   imagePath: isLoading ? null : AppImages.rightStickArrow,
                      //   imgHeight: 20,
                      // ),
                      const SizedBox(height: 36),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tringo_vendor/Core/Const/app_logger.dart';
// import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
// import 'package:tringo_vendor/Presentation/AddProduct/Controller/product_notifier.dart';
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Routes/app_go_routes.dart';
// import '../../../Core/Session/registration_product_seivice.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_textstyles.dart';
// import '../../../Core/Utility/common_Container.dart';
// import '../../../Core/Widgets/bottom_navigation_bar.dart';
// import '../../ShopInfo/model/shop_category_list_response.dart';
// import '../Service Info/Controller/service_info_notifier.dart';
// import 'add_product_list.dart';
//
// class ProductCategoryScreens extends ConsumerStatefulWidget {
//   final bool? isService;
//   final bool? isIndividual;
//   final bool allowOfferEdit;
//   final String? initialOfferLabel;
//   final String? initialOfferValue;
//   final String? shopId;
//   final String? productId;
//   final String? page;
//
//   final String? initialCategoryName;
//   final String? initialSubCategoryName;
//   final String? initialProductName;
//   final int? initialPrice;
//   final String? initialDescription;
//   final String? initialDoorDelivery; // "Yes" / "No"
//   final String? initialCategorySlug;
//   final String? initialSubCategorySlug;
//   const ProductCategoryScreens({
//     super.key,
//     this.isService,
//     this.shopId,
//     this.productId,
//     this.page,
//     this.isIndividual,
//     this.allowOfferEdit = false,
//     this.initialOfferLabel,
//     this.initialOfferValue,
//     this.initialCategoryName,
//     this.initialSubCategoryName,
//     this.initialProductName,
//     this.initialPrice,
//     this.initialDescription,
//     this.initialDoorDelivery,
//     this.initialCategorySlug,
//     this.initialSubCategorySlug,
//   });
//
//   @override
//   ConsumerState<ProductCategoryScreens> createState() =>
//       _ProductCategoryScreensState();
// }
//
// class _ProductCategoryScreensState
//     extends ConsumerState<ProductCategoryScreens> {
//   final _formKey = GlobalKey<FormState>();
//   bool _categoryHasError = false;
//   bool _subCategoryHasError = false;
//
//   List<ShopCategoryListData>? _selectedCategoryChildren;
//   final TextEditingController _categoryController = TextEditingController();
//   final TextEditingController _subCategoryController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _offerController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   final TextEditingController _productNameController = TextEditingController();
//   final TextEditingController _productPriceController = TextEditingController();
//   final TextEditingController _offerPriceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//
//   final List<String> categories = [
//     'product-mobile-devices',
//     'Clothing',
//     'Groceries',
//   ];
//   final List<String> cities = ['Yes', 'No'];
//   final List<String> offers = ['First App Offer', 'second App Offer'];
//
//   String productCategorySlug = '';
//   String productSubCategorySlug = '';
//
//   void _showCategoryBottomSheet(
//     BuildContext context,
//     WidgetRef ref,
//     TextEditingController controller, {
//     void Function(ShopCategoryListData selectedCategory)? onCategorySelected,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       enableDrag: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         final searchController = TextEditingController();
//
//         return Consumer(
//           builder: (context, ref, _) {
//             // 🔹 Always get the latest ProductState here
//             final productState = ref.watch(productNotifierProvider);
//             final isLoading = productState.isLoading;
//             final categories =
//                 productState.shopCategoryListResponse?.data ?? [];
//
//             // Local filtered list for search
//             List<ShopCategoryListData> filtered = List.from(categories);
//
//             return StatefulBuilder(
//               builder: (context, setModalState) {
//                 return DraggableScrollableSheet(
//                   expand: false,
//                   initialChildSize: 0.8,
//                   minChildSize: 0.4,
//                   maxChildSize: 0.95,
//                   builder: (context, scrollController) {
//                     // ❌ No data & not loading
//                     if (!isLoading && categories.isEmpty) {
//                       return const Center(
//                         child: Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Text(
//                             'No categories found',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//
//                     // ✅ Header + Search + Loader/List
//                     return Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                           child: SizedBox(
//                             width: 40,
//                             height: 4,
//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 color: Colors.grey,
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(2),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const Text(
//                           'Select Category',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//
//                         // 🔍 Search field
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           child: TextField(
//                             controller: searchController,
//                             onChanged: (value) {
//                               setModalState(() {
//                                 filtered = categories
//                                     .where(
//                                       (c) => c.name.toLowerCase().contains(
//                                         value.toLowerCase(),
//                                       ),
//                                     )
//                                     .toList();
//                               });
//                             },
//                             decoration: InputDecoration(
//                               hintText: 'Search category...',
//                               prefixIcon: const Icon(
//                                 Icons.search,
//                                 color: Colors.grey,
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 10,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         Expanded(
//                           child: isLoading
//                               ? Center(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: ThreeDotsLoader(
//                                       dotColor: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   controller: scrollController,
//                                   itemCount: filtered.length,
//                                   itemBuilder: (context, index) {
//                                     final category = filtered[index];
//                                     return ListTile(
//                                       title: Text(category.name),
//                                       trailing: category.children.isNotEmpty
//                                           ? const Icon(
//                                               Icons.arrow_forward_ios,
//                                               size: 14,
//                                             )
//                                           : null,
//                                       onTap: () {
//                                         Navigator.pop(context);
//
//                                         // ⬇️ Update your screen state
//                                         setState(() {
//                                           controller.text = category.name;
//                                           productCategorySlug = category.slug;
//                                           _categoryHasError =
//                                               false; // ✅ clear error when selected
//                                           _subCategoryHasError = false;
//                                         });
//
//                                         if (onCategorySelected != null) {
//                                           onCategorySelected(category);
//                                         }
//                                       },
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showCategoryChildrenBottomSheet(
//     BuildContext context,
//     List<ShopCategoryListData> children,
//     TextEditingController controller,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         final searchController = TextEditingController();
//         List<ShopCategoryListData> filtered = List.from(children);
//
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return DraggableScrollableSheet(
//               expand: false,
//               initialChildSize: 0.6,
//               minChildSize: 0.4,
//               maxChildSize: 0.9,
//               builder: (context, scrollController) {
//                 return Column(
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       child: SizedBox(
//                         width: 40,
//                         height: 4,
//                         child: DecoratedBox(
//                           decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.all(Radius.circular(2)),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Text(
//                       'Select Subcategory',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//
//                     // 🔹 Search field with no underline
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       child: TextField(
//                         controller: searchController,
//                         onChanged: (value) {
//                           setModalState(() {
//                             filtered = children
//                                 .where(
//                                   (c) => c.name.toLowerCase().contains(
//                                     value.toLowerCase(),
//                                   ),
//                                 )
//                                 .toList();
//                           });
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Search subcategory...',
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: Colors.grey,
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 10,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none, // ❌ No divider
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     Expanded(
//                       child: filtered.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'No subcategories found',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               controller: scrollController,
//                               itemCount: filtered.length,
//                               itemBuilder: (context, index) {
//                                 final child = filtered[index];
//                                 return ListTile(
//                                   title: Text(child.name),
//                                   onTap: () {
//                                     Navigator.pop(context);
//                                     setState(() {
//                                       controller.text = child.name;
//                                       productSubCategorySlug = child.slug;
//                                       _categoryHasError =
//                                           false; // ✅ clear error when selected
//                                       _subCategoryHasError = false;
//                                     });
//                                   },
//                                 );
//                               },
//                             ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _showOfferBottomSheet() async {
//     if (!widget.allowOfferEdit) return;
//
//     final selected = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(height: 12),
//               Text(
//                 'Select App Offer',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 12),
//               ...offers.map(
//                 (offer) => ListTile(
//                   title: Text(offer),
//                   onTap: () => Navigator.pop(context, offer),
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     );
//
//     if (selected != null && mounted) {
//       setState(() {
//         _offerController.text = selected;
//       });
//     }
//   }
//
//   void _validateAndContinue() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => AddProductList()),
//     );
//
//     // if (_formKey.currentState!.validate()) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text('Form submitted successfully!'),
//     //       backgroundColor: Colors.green,
//     //     ),
//     //   );
//     //
//     //   // 👉 TODO: Navigate to next screen here
//     //   Navigator.push(
//     //     context,
//     //     MaterialPageRoute(builder: (_) => AddProductList()),
//     //   );
//     // } else {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text('Please fill all required fields correctly.'),
//     //       backgroundColor: Colors.red,
//     //     ),
//     //   );
//     // }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     AppLogger.log.i(widget.productId);
//     AppLogger.log.i(widget.page);
//
//     // 🔹 Prefill from widget (edit mode)
//     _categoryController.text = widget.initialCategoryName ?? '';
//     _subCategoryController.text = widget.initialSubCategoryName ?? '';
//     _productNameController.text = widget.initialProductName ?? '';
//     if (widget.initialPrice != null) {
//       _productPriceController.text = widget.initialPrice!.toString();
//     }
//     _descriptionController.text = widget.initialDescription ?? '';
//     _genderController.text = widget.initialDoorDelivery ?? '';
//
//     // These slugs are mainly for service flow; safe to keep
//     productCategorySlug = widget.initialCategorySlug ?? '';
//     productSubCategorySlug = widget.initialSubCategorySlug ?? '';
//
//     _offerController.text = widget.initialOfferLabel ?? offers.first;
//     _offerPriceController.text = widget.initialOfferValue ?? '5%';
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(productNotifierProvider.notifier).fetchProductCategories();
//     });
//   }
//
//   ///old///
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   AppLogger.log.i(widget.productId);
//   //   AppLogger.log.i(widget.page);
//   //   // // 🔹 Default dropdown value
//   //   // _offerController.text = offers.first; // 'First App Offer'
//   //   //
//   //   // // 🔹 Default offer price value
//   //   // _offerPriceController.text = '5%';
//   //
//   //   _offerController.text = widget.initialOfferLabel ?? offers.first;
//   //   _offerPriceController.text = widget.initialOfferValue ?? '5%';
//   //
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     ref.read(productNotifierProvider.notifier).fetchProductCategories();
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final productState = ref.watch(productNotifierProvider);
//     final isProduct = RegistrationProductSeivice.instance.isProductBusiness;
//     final isService = RegistrationProductSeivice.instance.isServiceBusiness;
//     final serviceState = ref.watch(serviceInfoNotifierProvider);
//     final bool isLoading = isService
//         ? serviceState.isLoading
//         : productState.isLoading;
//
//     final state = ref.watch(productNotifierProvider);
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 16,
//                   ),
//                   child: Row(
//                     children: [
//                       CommonContainer.topLeftArrow(
//                         onTap: () => Navigator.pop(context),
//                       ),
//                       SizedBox(width: 50),
//                       Text(
//                         'Register Shop - Individual',
//                         style: AppTextStyles.mulish(
//                           fontSize: 16,
//                           color: AppColor.mildBlack,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 35),
//                 CommonContainer.registerTopContainer(
//                   image: AppImages.addProduct,
//                   text: isService ? 'Add Service' : 'Add Product',
//                   imageHeight: 85,
//                   gradientColor: AppColor.lavenderMist,
//                   value: 0.8,
//                 ),
//
//                 // CommonContainer.registerTopContainer(
//                 //   image: AppImages.addProduct,
//                 //   text: 'Add Product',
//                 //   imageHeight: 85,
//                 //   gradientColor: AppColor.lavenderMist,
//                 //   value: 0.8,
//                 // ),
//                 SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         isService ? ' Service Category' : 'Product Category',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       /*             CommonContainer.fillingContainer(
//                         imagePath: AppImages.downArrow,
//                         verticalDivider: false,
//                         controller: _categoryController,
//                         isDropdown: true,
//                         dropdownItems: categories,
//                         context: context,
//                         validator: (value) => value == null || value.isEmpty
//                             ? 'Please select a category'
//                             : null,
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         imagePath: AppImages.downArrow,
//                         verticalDivider: false,
//                         controller: _subCategoryController,
//                         isDropdown: true,
//                         dropdownItems: cities,
//                         context: context,
//                         validator: (value) => value == null || value.isEmpty
//                             ? 'Please select a sub category'
//                             : null,
//                       ),*/
//                       GestureDetector(
//                         onTap: () {
//                           ref
//                               .read(productNotifierProvider.notifier)
//                               .fetchProductCategories();
//
//                           _showCategoryBottomSheet(
//                             context,
//                             ref,
//                             _categoryController,
//                             onCategorySelected: (selectedCategory) {
//                               _selectedCategoryChildren =
//                                   selectedCategory.children;
//                               _subCategoryController.clear();
//                               setState(() {
//                                 _categoryHasError = false;
//                                 _subCategoryHasError = false;
//                               });
//                             },
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 19,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.lightGray,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: _categoryHasError
//                                   ? Colors.red
//                                   : Colors.transparent,
//                               width: 1.5,
//                             ), // 🔴 here
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0,
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     _categoryController.text.isEmpty
//                                         ? ""
//                                         : _categoryController.text,
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ),
//                                 Image.asset(AppImages.downArrow, height: 30),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: 10),
//
//                       GestureDetector(
//                         onTap: () {
//                           if (_categoryController.text.isEmpty) {
//                             AppSnackBar.info(
//                               context,
//                               'Please select a category first',
//                             );
//                             setState(() {
//                               _categoryHasError =
//                                   true; // highlight category if missing
//                             });
//                             return; // ❗ stop here
//                           }
//
//                           if (_selectedCategoryChildren == null ||
//                               _selectedCategoryChildren!.isEmpty) {
//                             AppSnackBar.info(
//                               context,
//                               'No subcategories available for this category',
//                             );
//                             return;
//                           }
//
//                           _showCategoryChildrenBottomSheet(
//                             context,
//                             _selectedCategoryChildren!,
//                             _subCategoryController,
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 19,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.lightGray,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: _subCategoryHasError
//                                   ? Colors.red
//                                   : Colors.transparent,
//                               width: 1.5,
//                             ), //  here
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0,
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     _subCategoryController.text.isEmpty
//                                         ? " "
//                                         : _subCategoryController.text,
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 18,
//                                       color: _subCategoryController.text.isEmpty
//                                           ? Colors.grey
//                                           : Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                                 Image.asset(AppImages.downArrow, height: 30),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: 25),
//                       Text(
//                         isService ? 'Service Name' : 'Product name',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         verticalDivider: false,
//                         controller: _productNameController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             //  Service-na "Start From", illa na "Product price"
//                             return isService
//                                 ? 'Please enter Product name'
//                                 : 'Please enter Service Name';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 25),
//                       // Text(
//                       //   'Product price',
//                       //   style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       // ),
//                       Text(
//                         isService ? 'Start From' : 'Product price',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         keyboardType: TextInputType.number,
//                         verticalDivider: false,
//                         controller: _productPriceController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             // 🔥 Service-na "Start From", illa na "Product price"
//                             return isService
//                                 ? 'Please enter Start From amount'
//                                 : 'Please enter Product price';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 25),
//                       Text(
//                         'App Offer price',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       GestureDetector(
//                         onTap: widget.allowOfferEdit
//                             ? _showOfferBottomSheet
//                             : null,
//                         child: AbsorbPointer(
//                           child: CommonContainer.fillingContainer(
//                             imagePath: widget.allowOfferEdit
//                                 ? AppImages.downArrow
//                                 : null,
//                             verticalDivider: false,
//                             controller: _offerController,
//                             readOnly: true, // 👈 always read-only, no typing
//                             context: context,
//                           ),
//                         ),
//                       ),
//
//                       // CommonContainer.fillingContainer(
//                       //   imagePath: AppImages.downArrow,
//                       //   verticalDivider: false,
//                       //   controller: _offerController,
//                       //   isDropdown: widget.allowOfferEdit,
//                       //   dropdownItems: widget.allowOfferEdit ? offers : null,
//                       //   readOnly: !widget.allowOfferEdit,
//                       //   context: context,
//                       //   // validator: (value) => value == null || value.isEmpty
//                       //   //     ? 'Please select an Offer'
//                       //   //     : null,
//                       // ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         keyboardType: TextInputType.number,
//                         verticalDivider: false,
//                         controller: _offerPriceController,
//                         readOnly: !widget.allowOfferEdit,
//                         onChanged: (value) {
//                           //  Numbers mattum retain pannuvom
//                           final onlyDigits = value.replaceAll(
//                             RegExp(r'[^0-9]'),
//                             '',
//                           );
//
//                           if (onlyDigits.isEmpty) {
//                             _offerPriceController.clear();
//                             return;
//                           }
//
//                           final formatted = '$onlyDigits%';
//
//                           //  Text + cursor position update
//                           _offerPriceController.value = TextEditingValue(
//                             text: formatted,
//                             selection: TextSelection.collapsed(
//                               offset: formatted.length,
//                             ),
//                           );
//                         },
//                         // validator: (value) {
//                         //   if (value == null || value.isEmpty) {
//                         //     return 'Please enter Offer price';
//                         //   }
//                         //   final digits = value.replaceAll(
//                         //     RegExp(r'[^0-9]'),
//                         //     '',
//                         //   );
//                         //   if (digits.isEmpty) {
//                         //     return 'Please enter a valid number';
//                         //   }
//                         //   return null;
//                         // },
//                       ),
//
//                       SizedBox(height: 25),
//                       Text(
//                         isService
//                             ? 'Service Description'
//                             : 'Product Description',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         maxLine: 4,
//                         verticalDivider: false,
//                         controller: _descriptionController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             //  Service-na "Start From", illa na "Product price"
//                             return isService
//                                 ? 'Please enter Product Description'
//                                 : 'Please enter Service Description';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       if (!isService) ...[
//                         SizedBox(height: 25),
//                         Text(
//                           'Door Delivery',
//                           style: AppTextStyles.mulish(
//                             color: AppColor.mildBlack,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         CommonContainer.fillingContainer(
//                           imagePath: AppImages.downArrow,
//                           verticalDivider: false,
//                           controller: _genderController,
//                           isDropdown: true,
//                           dropdownItems: cities,
//                           context: context,
//                           validator: (value) => value == null || value.isEmpty
//                               ? 'Please select Door Delivery option'
//                               : null,
//                         ),
//                         SizedBox(height: 30),
//                       ],
//
//                       SizedBox(height: 30),
//
//                       CommonContainer.button(
//                         buttonColor: AppColor.black,
//
//                         onTap: () async {
//                           FocusScope.of(context).unfocus();
//
//                           final isService = RegistrationProductSeivice
//                               .instance
//                               .isServiceBusiness; // 🔹 decide flow
//
//                           final priceText = _productPriceController.text.trim();
//                           final price = int.tryParse(priceText);
//
//                           final hasCategoryError = _categoryController.text
//                               .trim()
//                               .isEmpty;
//                           final hasSubCategoryError = _subCategoryController
//                               .text
//                               .trim()
//                               .isEmpty;
//
//                           setState(() {
//                             _categoryHasError = hasCategoryError;
//                             _subCategoryHasError = hasSubCategoryError;
//                           });
//
//                           final formValid = _formKey.currentState!.validate();
//
//                           if (!formValid ||
//                               hasCategoryError ||
//                               hasSubCategoryError) {
//                             AppSnackBar.info(
//                               context,
//                               'Please fill all required fields correctly.',
//                             );
//                             return;
//                           }
//                           bool success = false;
//
//                           if (isService) {
//                             //  SERVICE FLOW → call serviceInfo API
//
//                             // For now, use basic values; later you can plug Tamil name, tags, keywords, images from other screens.
//                             final serviceResponse = await ref
//                                 .read(serviceInfoNotifierProvider.notifier)
//                                 .saveServiceInfo(
//                                   title: _productNameController.text
//                                       .trim(), // Service name (English)
//                                   tamilName: _productNameController.text
//                                       .trim(), // TODO: replace with Tamil field when you add
//                                   description: _descriptionController.text
//                                       .trim(),
//                                   startsAt: price ?? 0, // "Start From" amount
//                                   offerLabel: _offerController.text.trim(),
//                                   offerValue: _offerPriceController.text.trim(),
//                                   durationMinutes:
//                                       60, // TODO: read from UI later
//                                   categoryId:
//                                       productCategorySlug, // slug/id from category picker
//                                   subCategory: _subCategoryController.text
//                                       .trim(),
//                                   tags: const [], // later you can add tags
//                                   keywords:
//                                       const [], // or reuse your keyword screen
//                                   images: const [], // add after image upload
//                                   isFeatured: false,
//                                   features:
//                                       const [], // later: add feature chips
//                                 );
//
//                             success = serviceResponse != null;
//
//                             if (!success) {
//                               final svcState = ref.read(
//                                 serviceInfoNotifierProvider,
//                               );
//                               if (svcState.error != null &&
//                                   svcState.error!.isNotEmpty) {
//                                 AppSnackBar.error(context, svcState.error!);
//                               } else {
//                                 AppSnackBar.error(
//                                   context,
//                                   'Service save failed. Please try again.',
//                                 );
//                               }
//                             }
//                           } else {
//                             success = await ref
//                                 .read(productNotifierProvider.notifier)
//                                 .addProduct(
//                                   productId: widget.productId,
//                                   shopId: widget.shopId,
//                                   category: _categoryController.text.trim(),
//                                   subCategory: _subCategoryController.text
//                                       .trim(),
//                                   englishName: _productNameController.text
//                                       .trim(),
//                                   price: price ?? 0,
//                                   offerLabel: _offerController.text.trim(),
//                                   offerValue: _offerPriceController.text.trim(),
//                                   description: _descriptionController.text
//                                       .trim(),
//                                 );
//
//                             if (!success) {
//                               final err = ref
//                                   .read(productNotifierProvider)
//                                   .error;
//                               if (err != null && err.isNotEmpty) {
//                                 AppSnackBar.error(context, err);
//                               } else {
//                                 AppSnackBar.error(
//                                   context,
//                                   'Something went wrong',
//                                 );
//                               }
//                             }
//                           }
//
//                           if (success) {
//                             if (widget.page == 'AboutMeScreens') {
//                               Navigator.pop(context, true);
//                               // context.pushNamed(AppRoutes.homeScreen, extra: 3);
//                             } else {
//                               context.pushNamed(AppRoutes.addProductList);
//                             }
//                           }
//                         },
//                         text: isLoading
//                             ? ThreeDotsLoader()
//                             : Text(
//                                 'Save & Continue',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                         imagePath: isLoading ? null : AppImages.rightStickArrow,
//                         imgHeight: 20,
//                       ),
//
//                       SizedBox(height: 36),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
