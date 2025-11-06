import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/search_keyword.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';

class ShopPhotoInfo extends StatefulWidget {
  const ShopPhotoInfo({super.key});

  @override
  State<ShopPhotoInfo> createState() => _ShopPhotoInfoState();
}

class _ShopPhotoInfoState extends State<ShopPhotoInfo> {
  final ImagePicker _picker = ImagePicker();

  // 4 containers = 4 image slots
  List<File?> _pickedImages = List<File?>.filled(4, null);
  List<bool> _hasError = List<bool>.filled(4, false);

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);
        _hasError[index] = false; // clear error once image selected
      });
    }
  }

  Widget _addImageContainer({required int index}) {
    final file = _pickedImages[index];
    final hasError = _hasError[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.lightGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasError
                        ? Colors.red
                        : (file != null
                              ? AppColor.lightSkyBlue
                              : Colors.transparent),
                    width: 1.5,
                  ),
                ),
                child: file == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppImages.addImage, height: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Add Image',
                              style: AppTextStyles.mulish(
                                color: AppColor.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        ),
                      ),
              ),
            ),
            // “Clear” Option — visible only when an image is selected
            if (file != null)
              Positioned(
                top: 15,
                right: 16,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _pickedImages[index] = null;
                      _hasError[index] = false;
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        AppImages.closeImage,
                        height: 28,
                        color: AppColor.scaffoldColor,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Clear',
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          color: AppColor.scaffoldColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 5),
            child: Text(
              'Please add this image',
              style: AppTextStyles.mulish(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _validateAndContinue() {
    // bool valid = true;
    // setState(() {
    //   for (int i = 0; i < _pickedImages.length; i++) {
    //     if (_pickedImages[i] == null) {
    //       _hasError[i] = true;
    //       valid = false;
    //     } else {
    //       _hasError[i] = false;
    //     }
    //   }
    // });
    //
    // if (!valid) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please add all required images before continuing.'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchKeyword()),
    );

    //  All images valid → proceed to next screen or API upload
    debugPrint('All images selected. Proceed.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                value: 0.6,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    CommonContainer.containerTitle(
                      context: context,
                      infoMessage:
                          'Please upload a clear photo of your shop signboard showing the name clearly.',
                      title: 'Sign Board Photo',
                      image: AppImages.iImage,
                    ),
                    SizedBox(height: 10),
                    _addImageContainer(index: 0),
                    SizedBox(height: 25),
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Shop Outside Photo',
                      image: AppImages.iImage,
                      infoMessage:
                      'Please upload a clear photo of your shop signboard showing the name clearly.',
                    ),
                    SizedBox(height: 10),
                    _addImageContainer(index: 1),
                    SizedBox(height: 25),
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Shop Inside Photo',
                      image: AppImages.iImage,
                      infoMessage:
                      'Please upload a clear photo of your shop signboard showing the name clearly.',
                    ),
                    SizedBox(height: 10),
                    _addImageContainer(index: 2),
                    SizedBox(height: 10),
                    _addImageContainer(index: 3),
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
    );
  }
}
