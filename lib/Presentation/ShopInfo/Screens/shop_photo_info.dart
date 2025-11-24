import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_vendor/Core/Utility/app_loader.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor/Presentation/ShopInfo/Screens/search_keyword.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../Controller/shop_notifier.dart';

class ShopPhotoInfo extends ConsumerStatefulWidget {
  final String? pages;
  const ShopPhotoInfo({super.key, this.pages = ''});

  @override
  ConsumerState<ShopPhotoInfo> createState() => _ShopPhotoInfoState();
}

class _ShopPhotoInfoState extends ConsumerState<ShopPhotoInfo> {
  final ImagePicker _picker = ImagePicker();
  bool _insidePhotoError = false;

  // 4 containers = 4 image slots
  List<File?> _pickedImages = List<File?>.filled(4, null);
  List<bool> _hasError = List<bool>.filled(4, false);

  // Future<void> _pickImage(int index) async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _pickedImages[index] = File(pickedFile.path);
  //       _hasError[index] = false; // clear error once image selected
  //     });
  //   }
  // }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);

        // Clear individual errors for first 2 slots
        if (index == 0 || index == 1) {
          _hasError[index] = false;
        }

        // Clear group error if at least 1 inside photo is selected
        if (index == 2 || index == 3) {
          if (_pickedImages[2] != null || _pickedImages[3] != null) {
            _insidePhotoError = false;
          }
        }
      });
    }
  }

  Widget _addImageContainer({
    required int index,
    bool checkIndividualError = false,
  }) {
    final file = _pickedImages[index];
    final hasError = checkIndividualError
        ? _hasError[index]
        : false; // only for 0 & 1

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

  Future<void> _validateImages() async {
    bool valid = true;

    // Validate slot 0 & 1 individually
    setState(() {
      for (int i = 0; i <= 1; i++) {
        if (_pickedImages[i] == null) {
          _hasError[i] = true;
          valid = false;
        } else {
          _hasError[i] = false;
        }
      }

      // Group validation for inside photos (index 2 & 3)
      if (_pickedImages[2] == null && _pickedImages[3] == null) {
        _insidePhotoError = true;
        valid = false;
      } else {
        _insidePhotoError = false;
      }
    });

    if (!valid) return;

    debugPrint("ALL IMAGES ARE VALID");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopCategoryNotifierProvider);
    final notifier = ref.read(shopCategoryNotifierProvider.notifier);

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
                      title: 'Sign Board Photo',
                      infoMessage:
                          'Please upload a clear photo of your shop signboard showing the name clearly.',
                      image: AppImages.iImage,
                    ),

                    SizedBox(height: 10),
                    _addImageContainer(index: 0, checkIndividualError: true),
                    SizedBox(height: 25),
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Shop Outside Photo',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload a clear photo showing the full outside view of your shop.',
                    ),

                    SizedBox(height: 10),
                    _addImageContainer(index: 1, checkIndividualError: true),
                    SizedBox(height: 25),
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Shop Inside Photo',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload a clear photo of the inside of your shop showing the interior clearly.',
                    ),

                    SizedBox(height: 10),
                    _addImageContainer(index: 2),
                    SizedBox(height: 10),
                    _addImageContainer(index: 3),

                    /// ONE GROUP ERROR MESSAGE
                    if (_insidePhotoError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 5),
                        child: Text(
                          'Please upload at least one inside photo',
                          style: AppTextStyles.mulish(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    SizedBox(height: 30),

                    CommonContainer.button(
                      buttonColor: AppColor.black,
                      onTap: () async {
                        await _validateImages();

                        // Validation failed → stop
                        if (_hasError.contains(true) || _insidePhotoError) {
                          AppSnackBar.error(
                            context,
                            'Please fix the highlighted errors before continuing',
                          );
                          return;
                        }

                        final notifier = ref.read(
                          shopCategoryNotifierProvider.notifier,
                        );

                        final success = await notifier.uploadShopImages(
                          images: _pickedImages,
                          context: context,
                        );

                        if (success) {
                          // SHOW SUCCESS SNACKBAR
                          AppSnackBar.success(
                            context,
                            'Shop images uploaded successfully!',
                          );

                          // Navigate after a short delay so user can see the message
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (widget.pages == "AboutMeScreens") {
                              final updatedPhotos = _pickedImages
                                  .where((img) => img != null)
                                  .map((f) => f!.path)
                                  .toList();
                              Navigator.pop(context, updatedPhotos);
                            } else {
                              context.pushNamed(AppRoutes.searchKeyword);
                            }
                          });
                        } else {
                          // SHOW ERROR SNACKBAR
                          final err = ref
                              .read(shopCategoryNotifierProvider)
                              .error;
                          AppSnackBar.error(
                            context,
                            err != null && err.isNotEmpty
                                ? err
                                : 'Image upload failed. Please try again.',
                          );
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
                      imgHeight: 20,
                    ),

                    // CommonContainer.button(
                    //   buttonColor: AppColor.black,
                    //   onTap: () async {
                    //     await _validateImages();
                    //     if (widget.pages == "AboutMeScreens") {
                    //       // Example: collect image data before returning
                    //       final updatedPhotos = _pickedImages
                    //           .where((img) => img != null)
                    //           .map((f) => f!.path)
                    //           .toList();
                    //
                    //       Navigator.pop(
                    //         context,
                    //         updatedPhotos,
                    //       ); // Return to AboutMeScreens
                    //     } else {
                    //       if (_pickedImages.every((img) => img == null)) {
                    //         AppSnackBar.error(
                    //           context,
                    //           'Please select all required images',
                    //         );
                    //         return;
                    //       }
                    //
                    //       final success = await ref
                    //           .read(shopCategoryNotifierProvider.notifier)
                    //           .uploadShopImages(
                    //             images: _pickedImages,
                    //
                    //             context: context,
                    //           );
                    //       if (success) {
                    //         context.pushNamed(AppRoutes.searchKeyword);
                    //       } else {
                    //         final err = ref
                    //             .read(shopCategoryNotifierProvider)
                    //             .error;
                    //         if (err != null && err.isNotEmpty) {
                    //           AppSnackBar.error(context, err);
                    //         } else {
                    //           AppSnackBar.error(
                    //             context,
                    //             'Image upload failed. Please try again.',
                    //           );
                    //         }
                    //       }
                    //     }
                    //   },
                    //   text: state.isLoading
                    //       ? const ThreeDotsLoader()
                    //       : Text(
                    //           widget.pages == "AboutMeScreens"
                    //               ? 'Update'
                    //               : 'Save & Continue',
                    //           style: AppTextStyles.mulish(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //   imagePath: state.isLoading
                    //       ? null
                    //       : AppImages.rightStickArrow,
                    //   imgHeight: 20,
                    // ),
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
