import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Controller/shop_notifier.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/shop_photo_info.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/model/shop_category_list_response.dart';

import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/thanglish_to_tamil.dart';
import '../../AboutMe/Screens/about_me_screens.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';

class ShopCategoryInfo extends ConsumerStatefulWidget {
  final String? pages;
  final String? initialShopNameEnglish;
  final String? initialShopNameTamil;
  final bool? isService;
  final bool? isIndividual;
  const ShopCategoryInfo({
    super.key,
    this.pages,
    this.initialShopNameEnglish,
    this.initialShopNameTamil,
    required this.isService,
    required this.isIndividual,
  });

  @override
  ConsumerState<ShopCategoryInfo> createState() => _ShopCategoryInfotate();
}

class _ShopCategoryInfotate extends ConsumerState<ShopCategoryInfo> {
  final _formKey = GlobalKey<FormState>();
  List<ShopCategoryListData>? _selectedCategoryChildren;

  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _doorDeliveryController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController addressTamilNameController =
      TextEditingController();
  final TextEditingController descriptionTamilController =
      TextEditingController();
  final TextEditingController _shopNameEnglishController =
      TextEditingController();
  final TextEditingController _descriptionEnglishController =
      TextEditingController();
  final TextEditingController _addressEnglishController =
      TextEditingController();
  final TextEditingController _primaryMobileController =
      TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> doorDelivery = ['true', 'false'];

  List<String> tamilNameSuggestion = [];
  List<String> descriptionTamilSuggestion = [];
  List<String> addressTamilSuggestion = [];
  bool _tamilPrefilled = false;
  String categorySlug = '';
  String subCategorySlug = '';
  bool isTamilNameLoading = false;
  bool isDescriptionTamilLoading = false;
  bool isAddressLoading = false;
  bool _isSubmitted = false;
  bool _gpsFetched = false;
  bool _timetableInvalid = false;
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
                                categorySlug = category.slug;
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
                                      subCategorySlug = child.slug;
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

  File? _selectedImage;
  XFile? _permanentImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _permanentImage = pickedFile;
        _timetableInvalid = false; // if you use this as error flag
      });
    }
  }

  TimeOfDay? _openTod;
  TimeOfDay? _closeTod;
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  bool validateTimes() {
    if (_openTod == null || _closeTod == null) return false;
    return _toMinutes(_closeTod!) > _toMinutes(_openTod!);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _gpsController.text =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
        _gpsFetched = true; // Mark GPS as fetched
      });

      debugPrint('📍 Current Location → ${_gpsController.text}');
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopCategoryNotifierProvider.notifier).fetchCategories();
    });
    if (widget.pages == "AboutMeScreens") {
      if (widget.initialShopNameEnglish?.isNotEmpty ?? false) {
        _shopNameEnglishController.text = widget.initialShopNameEnglish!;
      }

      // If Tamil was passed explicitly, use it; else transliterate once
      if (widget.initialShopNameTamil?.isNotEmpty ?? false) {
        tamilNameController.text = widget.initialShopNameTamil!;
        _tamilPrefilled = true;
      } else {
        _prefillTamilFromEnglishOnce();
      }
    }
  }

  Future<void> _prefillTamilFromEnglishOnce() async {
    if (_tamilPrefilled) return;
    final english = _shopNameEnglishController.text.trim();
    if (english.isEmpty) return;

    setState(() => isTamilNameLoading = true);
    try {
      final result = await TanglishTamilHelper.transliterate(english);
      if (!mounted) return;
      if (result.isNotEmpty && tamilNameController.text.trim().isEmpty) {
        tamilNameController.text = result.first; // pick first suggestion
      }
      _tamilPrefilled = true;
    } catch (_) {
      // ignore; user can type manually
    } finally {
      if (mounted) setState(() => isTamilNameLoading = false);
    }
  }

  // Future<void> _prefillTamilFromEnglish(String english) async {
  //   try {
  //     final result = await TanglishTamilHelper.transliterate(english);
  //     if (mounted && result.isNotEmpty) {
  //       setState(() {
  //         tamilNameController.text = result.first; // take the first suggestion
  //       });
  //     }
  //   } catch (_) {}
  // }

  @override
  void dispose() {
    _shopNameEnglishController.dispose();
    _categoryController.dispose();
    _cityController.dispose();
    _doorDeliveryController.dispose();
    tamilNameController.dispose();
    addressTamilNameController.dispose();
    descriptionTamilController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopCategoryNotifierProvider);
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
                        controller: _shopNameEnglishController,
                        text: 'English',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Shop Name in English'
                            : null,
                      ),
                      SizedBox(height: 15),
                      CommonContainer.fillingContainer(
                        controller: tamilNameController,
                        text: 'Tamil',
                        isTamil: true,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please Enter Shop Name in Tamil'
                            : null,
                        onChanged: (value) async {
                          // your existing suggestion logic can remain
                          setState(() => isTamilNameLoading = true);
                          final result =
                              await TanglishTamilHelper.transliterate(value);
                          setState(() {
                            tamilNameSuggestion = result;
                            isTamilNameLoading = false;
                            _tamilPrefilled =
                                true; // user started typing; stop auto-updates
                          });
                        },
                      ),
                      if (isTamilNameLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                        controller: _descriptionEnglishController,
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
                        controller: _addressEnglishController,
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

                      GestureDetector(
                        onTap: _getCurrentLocation,
                        child: AbsorbPointer(
                          child: CommonContainer.fillingContainer(
                            controller: _gpsController,
                            text: 'Get by GPS',
                            textColor: _gpsController.text.isEmpty
                                ? AppColor.skyBlue
                                : AppColor.mildBlack,
                            textFontWeight: FontWeight.w700,
                            validator: (value) {
                              if (!_isSubmitted) return null;
                              return _gpsFetched
                                  ? null
                                  : 'Please get GPS location';
                            },
                          ),
                        ),
                      ),

                      // CommonContainer.fillingContainer(
                      //   text: 'Get by GPS',
                      //   textColor: AppColor.skyBlue,
                      //   textFontWeight: FontWeight.w700,
                      //   validator: (value) => value == null || value.isEmpty
                      //       ? 'Please select a GPS Location'
                      //       : null,
                      // ),
                      SizedBox(height: 25),
                      Text(
                        'Primary Mobile Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _primaryMobileController,
                        verticalDivider: true,
                        isMobile: true,
                        text: 'Mobile No',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Primary Mobile Number'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Whatsapp Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _whatsappController,
                        verticalDivider: true,
                        isMobile: true,
                        text: 'Mobile No',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Whatsapp Number'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Open Time',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _openTimeController,
                        text: '',
                        imagePath: AppImages.clock,
                        imageWidth: 25,
                        readOnly: true,
                        onFieldTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            _openTimeController.text = picked.format(context);
                            setState(
                              () => _openTod = picked,
                            ); // if you keep a TimeOfDay for validation
                          }
                        },
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please select Open Time'
                            : null,
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Close Time',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _closeTimeController,
                        text: '',
                        readOnly: true,
                        imagePath: AppImages.clock,
                        imageWidth: 25,
                        onFieldTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            _closeTimeController.text = picked.format(context);
                            setState(() => _closeTod = picked);
                          }
                        },
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please select Close Time'
                            : null,
                      ),

                      SizedBox(height: 25),
                      Text(
                        'Email Id',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _emailController,
                        verticalDivider: true,
                        text: 'Email Id',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Enter Email Id'
                            : null,
                      ),
                      SizedBox(height: 25),
                      if (!(widget.isService ?? false)) ...[
                        // Selling Product: show Door Delivery
                        Text(
                          'Door Delivery',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        SizedBox(height: 10),
                        CommonContainer.fillingContainer(
                          imagePath: AppImages.downArrow,
                          verticalDivider: false,
                          controller: _doorDeliveryController,
                          isDropdown: true,
                          dropdownItems: doorDelivery,
                          context: context,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a Door Delivery'
                              : null,
                        ),
                      ] else ...[
                        // Service: show image picker container
                        Text(
                          'Upload Image',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImage,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(20),
                            color: _timetableInvalid
                                ? Colors.red
                                : AppColor.mediumLightGray,
                            strokeWidth: 1.5,
                            dashPattern: [6, 2],
                            padding: EdgeInsets.all(1),
                            child: Container(
                              height: 160,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColor.white3,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _permanentImage == null
                                  ? Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            AppImages.uploadImage,
                                            height: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Upload',
                                            style: AppTextStyles.mulish(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.mediumLightGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              File(_permanentImage!.path),
                                              height: 140,
                                              fit: BoxFit
                                                  .cover, // fills available width safely
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _permanentImage = null;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 35.0,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  AppImages.closeImage,
                                                  height: 26,
                                                  color: AppColor.mediumGray,
                                                ),
                                                Text(
                                                  'Clear',
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColor
                                                        .mediumLightGray,
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
                        ),
                        // GestureDetector(
                        //   onTap: _pickImage,
                        //   child: Container(
                        //     height: 150,
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       color: AppColor.lightGray,
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(color: Colors.grey),
                        //     ),
                        //     child: _selectedImage != null
                        //         ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        //         : Icon(
                        //             Icons.camera_alt,
                        //             size: 50,
                        //             color: Colors.grey,
                        //           ),
                        //   ),
                        // ),
                      ],

                      // Text(
                      //   'Door Delivery',
                      //   style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      // ),
                      // SizedBox(height: 10),
                      // CommonContainer.fillingContainer(
                      //   imagePath: AppImages.downArrow,
                      //   verticalDivider: false,
                      //   controller: _genderController,
                      //   isDropdown: true,
                      //   dropdownItems: cities,
                      //   context: context,
                      //   validator: (value) => value == null || value.isEmpty
                      //       ? 'Please select a Door Delivery'
                      //       : null,
                      // ),
                      SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: () async {
                          if (widget.pages == "AboutMeScreens") {
                            // If coming from AboutMeScreens, treat this as an update flow
                            // Example: gather updated data to return
                            final updatedData = {
                              'category': _categoryController.text,
                              'city': _cityController.text,
                              'tamilName': tamilNameController.text,
                            };

                            Navigator.pop(context, updatedData);
                          } else {
                            // AppLogger.log.i( _addressEnglishController.text);
                            // AppLogger.log.i( addressTamilNameController.text);
                            // AppLogger.log.i( _whatsappController.text);
                            // AppLogger.log.i( _categoryController.text);
                            // AppLogger.log.i( _emailController.text);
                            // AppLogger.log.i( _descriptionEnglishController.text);
                            // AppLogger.log.i( descriptionTamilController.text);
                            // AppLogger.log.i( _primaryMobileController.text);
                            // AppLogger.log.i( _subCategoryController.text);
                            AppLogger.log.i(_gpsController.text);
                            final gpsText = _gpsController.text.trim();
                            double latitude = 0.0;
                            double longitude = 0.0;

                            if (gpsText.isNotEmpty && gpsText.contains(',')) {
                              final parts = gpsText.split(',');
                              latitude =
                                  double.tryParse(parts[0].trim()) ?? 0.0;
                              longitude =
                                  double.tryParse(parts[1].trim()) ?? 0.0;
                            }

                            final response = await ref
                                .read(shopCategoryNotifierProvider.notifier)
                                .shopCategoryInfo(
                                  addressEn: _addressEnglishController.text
                                      .trim(),
                                  addressTa: addressTamilNameController.text
                                      .trim(),
                                  alternatePhone: _whatsappController.text
                                      .trim(),
                                  category: categorySlug,
                                  contactEmail: _emailController.text.trim(),
                                  descriptionEn: _descriptionEnglishController
                                      .text
                                      .trim(),
                                  descriptionTa: descriptionTamilController.text
                                      .trim(),
                                  doorDelivery: true,
                                  englishName: _shopNameEnglishController.text
                                      .trim(),
                                  gpsLatitude: latitude,
                                  gpsLongitude: longitude,
                                  primaryPhone: _primaryMobileController.text
                                      .trim(),
                                  subCategory: subCategorySlug,
                                  tamilName: tamilNameController.text.trim(),
                                );

                            final newState = ref.read(
                              shopCategoryNotifierProvider,
                            );

                            if (newState.error != null &&
                                newState.error!.isNotEmpty) {
                              AppSnackBar.error(
                                context,
                                newState.error!,
                              ); // ✅ show API error
                            } else if (response != null) {
                              context.pushNamed(
                                AppRoutes.shopPhotoInfo,
                                extra: 'shopCategory',
                              );
                            } else {
                              AppSnackBar.error(
                                context,
                                "Unexpected error, please try again",
                              );
                            }
                          }
                        },
                        text: state.isLoading
                            ? const ThreeDotsLoader()
                            : Text(
                                widget.pages == "AboutMeScreens"
                                    ? 'Update'
                                    : 'Save & Continue',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        imagePath: state.isLoading
                            ? null
                            : AppImages.rightStickArrow,
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
