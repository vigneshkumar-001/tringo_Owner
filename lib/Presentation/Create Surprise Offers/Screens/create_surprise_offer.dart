import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_vendor/Presentation/Create%20Surprise%20Offers/Screens/surprise_offer_list.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';

class CreateSurpriseOffer extends StatefulWidget {
  const CreateSurpriseOffer({super.key});

  @override
  State<CreateSurpriseOffer> createState() => _CreateSurpriseOfferState();
}

class _CreateSurpriseOfferState extends State<CreateSurpriseOffer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ✅ Controllers
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _offerTitleController = TextEditingController();
  final TextEditingController _availableDateController =
      TextEditingController();
  final TextEditingController _offerDescriptionController =
      TextEditingController();

  int Percentage = 1;

  // ✅ Image Picker
  final ImagePicker _picker = ImagePicker();
  File? _bannerImageFile;

  // ✅ Dummy Branch list (API response இருந்தா அதுல இருந்து set pannunga)
  final List<String> _branches = [
    "Main Branch - Madurai",
    "Anna Nagar Branch",
    "KK Nagar Branch",
    "Villapuram Branch",
  ];

  @override
  void dispose() {
    _branchController.dispose();
    _offerTitleController.dispose();
    _availableDateController.dispose();
    _offerDescriptionController.dispose();
    super.dispose();
  }

  // ✅ Branch BottomSheet
  void _openBranchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Select Branch",
                style: AppTextStyles.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.mildBlack,
                ),
              ),
              const SizedBox(height: 14),

              // ✅ list
              ListView.separated(
                shrinkWrap: true,
                itemCount: _branches.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final b = _branches[index];
                  return ListTile(
                    title: Text(
                      b,
                      style: AppTextStyles.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _branchController.text = b;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Image Picker function
  Future<void> _pickBannerImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (file == null) return;

      setState(() {
        _bannerImageFile = File(file.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image pick failed: $e")));
    }
  }

  // ✅ Banner picker bottomsheet
  void _openBannerPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Add Surprise Banner",
                style: AppTextStyles.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.mildBlack,
                ),
              ),
              const SizedBox(height: 14),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickBannerImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickBannerImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Submit
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Banner validation optional (if required)
    // if (_bannerImageFile == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please add banner image")),
    //   );
    //   return;
    // }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurpriseOfferList()),
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
                // ✅ back arrow
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: CommonContainer.topLeftArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // ✅ Top Banner UI
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
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.surprise, height: 154),
                      const SizedBox(height: 10),
                      Text(
                        'Create Surprise Offer',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      const SizedBox(height: 35),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ FORM AREA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Select Branch
                      Text(
                        'Select Branch',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      InkWell(
                        onTap: _openBranchBottomSheet,
                        child: IgnorePointer(
                          child: CommonContainer.fillingContainer(
                            imagePath: AppImages.downArrow,
                            verticalDivider: false,
                            controller: _branchController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select branch'
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ✅ Banner Add Container
                      Text(
                        'Surprise Offer Banner',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      InkWell(
                        onTap: _openBannerPickerSheet,
                        child: Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColor.leftArrow,
                            borderRadius: BorderRadius.circular(16),

                          ),
                          child: _bannerImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _bannerImageFile!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                               Image.asset(AppImages.addImage, width: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Add Image",
                                      style: AppTextStyles.mulish(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ✅ Title
                      Text(
                        'Surprise Offer Title',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _offerTitleController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Surprise Offer Title'
                            : null,
                      ),

                      const SizedBox(height: 25),

                      // ✅ Description
                      Text(
                        'Surprise Offer Description',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        verticalDivider: false,
                        controller: _offerDescriptionController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Surprise Offer Description'
                            : null,
                      ),

                      const SizedBox(height: 25),

                      // ✅ Date Range
                      Row(
                        children: [
                          Text(
                            'Available Date',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '( Start to End Date )',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        controller: _availableDateController,
                        context: context,
                        datePickMode: DatePickMode.range,
                        styledRangeText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a valid date range';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // ✅ Count
                      Text(
                        'Surprise Coupon Count',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          InkWell(
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
                          const SizedBox(width: 10),

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
                                    '$Percentage',
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

                          const SizedBox(width: 10),

                          InkWell(
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

                      const SizedBox(height: 30),

                      // ✅ Done Button
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _onSubmit,
                        text: Text(
                          'Done',
                          style: AppTextStyles.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        imgHeight: 20,
                      ),

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
