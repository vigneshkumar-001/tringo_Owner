import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/shop_photo_info.dart';

import '../../../Core/Utility/thanglish_to_tamil.dart';
import '../../AboutMe/Screens/about_me_screens.dart';
import '../../Create App Offer/Screens/create_app_offer.dart';

class ShopCategoryInfo extends StatefulWidget {
  final String? pages;
  final String? initialShopNameEnglish;
  final String? initialShopNameTamil;
  const ShopCategoryInfo({
    super.key,
    this.pages,
    this.initialShopNameEnglish,
    this.initialShopNameTamil,
  });

  @override
  State<ShopCategoryInfo> createState() => _ShopCategoryInfotate();
}

class _ShopCategoryInfotate extends State<ShopCategoryInfo> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _shopNameEnglishController =
      TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController addressTamilNameController =
      TextEditingController();
  final TextEditingController descriptionTamilController =
      TextEditingController();
  final TextEditingController _gpsController = TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> cities = ['Madurai', 'Chennai', 'Coimbatore'];

  List<String> tamilNameSuggestion = [];
  List<String> descriptionTamilSuggestion = [];
  List<String> addressTamilSuggestion = [];
  bool _tamilPrefilled = false;
  bool isTamilNameLoading = false;
  bool isDescriptionTamilLoading = false;
  bool isAddressLoading = false;
  bool _isSubmitted = false; // Add this at class level
  bool _gpsFetched = false;

  // void _onSubmit() {
  //   setState(() => _isSubmitted = true); // Mark that user clicked submit
  //
  //   if (_formKey.currentState!.validate()) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => ShopPhotoInfo()),
  //     ).then((_) {
  //       Navigator.pop(context, true);
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all required fields')),
  //     );
  //   }
  // }

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

    // Prefill English (from nav param)
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
  // @override
  // void initState() {
  //   super.initState();
  //
  //   // Prefill English name
  //   if (widget.initialShopNameEnglish != null &&
  //       widget.initialShopNameEnglish!.isNotEmpty) {
  //     _shopNameEnglishController.text = widget.initialShopNameEnglish!;
  //   }
  //
  //   // Prefill Tamil name if provided
  //   if (widget.initialShopNameTamil != null &&
  //       widget.initialShopNameTamil!.isNotEmpty) {
  //     tamilNameController.text = widget.initialShopNameTamil!;
  //   }
  //
  //   // If you want to auto-copy English into Tamil by default when Tamil is empty:
  //   if (tamilNameController.text.isEmpty &&
  //       _shopNameEnglishController.text.isNotEmpty) {
  //     // Option A: simple copy (comment out if you only want suggestions)
  //     tamilNameController.text = _shopNameEnglishController.text;
  //
  //     // Option B: if you prefer using your transliteration helper, do it once here:
  //     // _prefillTamilFromEnglish(_shopNameEnglishController.text);
  //   }
  // }

  // Optional: one-time transliteration

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
    _genderController.dispose();
    tamilNameController.dispose();
    addressTamilNameController.dispose();
    descriptionTamilController.dispose();
    _gpsController.dispose();
    super.dispose();
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
                        onTap: () {
                          if (widget.pages == "AboutMeScreens") {
                            // If coming from AboutMeScreens, treat this as an update flow
                            // Example: gather updated data to return
                            final updatedData = {
                              'category': _categoryController.text,
                              'city': _cityController.text,
                              'tamilName': tamilNameController.text,
                            };

                            Navigator.pop(
                              context,
                              updatedData,
                            ); // return data back
                          } else {
                            // Normal flow: move to next step
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopPhotoInfo(),
                              ),
                            );
                          }
                        },
                        text: Text(
                          widget.pages == "AboutMeScreens"
                              ? 'Update'
                              : 'Save & Continue',
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
