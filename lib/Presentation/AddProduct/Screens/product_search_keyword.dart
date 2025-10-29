import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../AddProduct/Screens/product_category_screens.dart';

class ProductSearchKeyword extends StatefulWidget {
  const ProductSearchKeyword({super.key});

  @override
  State<ProductSearchKeyword> createState() => _ProductSearchKeywordState();
}

class _ProductSearchKeywordState extends State<ProductSearchKeyword> {
  final TextEditingController _searchKeywordController =
      TextEditingController();

  final List<String> _keywords = [
    'Face tissue',
    'Paper product',
    'Bathroom product',
    'Paper',
    'face towel',
  ];

  void _onKeywordTap(String keyword) {
    _searchKeywordController.text = keyword;
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
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
                    CommonContainer.containerTitle(
                      title: 'Search Keyword',
                      image: AppImages.iImage,
                    ),
                    SizedBox(height: 10),
                    CommonContainer.fillingContainer(
                      imagePath: AppImages.downArrow,
                      verticalDivider: false,
                      controller: _searchKeywordController,
                      isDropdown: true,
                      // dropdownItems: categories,
                      context: context,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a Search Keyword'
                          : null,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Maximum 5 keywords acceptable',
                      style: AppTextStyles.mulish(
                        fontSize: 12,
                        color: AppColor.darkGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _keywords.map((keyword) {
                        return GestureDetector(
                          onTap: () => _onKeywordTap(keyword),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            color: AppColor.lightSilver,
                            strokeWidth: 1,
                            dashPattern: const [3, 2],
                            padding: const EdgeInsets.all(1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    keyword,
                                    style: AppTextStyles.mulish(
                                      color: AppColor.gray84,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _removeKeyword(keyword),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.leftArrow,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      padding: const EdgeInsets.all(9.5),
                                      child: Image.asset(
                                        AppImages.closeImage,
                                        height: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    CommonContainer.button(
                      buttonColor: AppColor.black,
                      onTap: () {
                        // Validate before navigation (optional)
                        if (_searchKeywordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select or enter a search keyword.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Navigate to next screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProductCategoryScreens(),
                          ),
                        );
                      },
                      text: Text(
                        'Preview Shop & Product',
                        style: AppTextStyles.mulish(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      imagePath: AppImages.rightStickArrow,
                      imgHeight: 20,
                    ),
                    SizedBox(height: 36),
                    // DottedBorder(
                    //   borderType: BorderType.RRect,
                    //   radius: const Radius.circular(20),
                    //   color: AppColor.lightSilver,
                    //   strokeWidth: 1.5,
                    //   dashPattern: const [8, 4],
                    //   padding: const EdgeInsets.all(1),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 11.5),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text(
                    //           'Saravana store',
                    //           style: AppTextStyles.mulish(
                    //             color: AppColor.gray84,
                    //           ),
                    //         ),
                    //         SizedBox(width: 10),
                    //         Container(
                    //           decoration: BoxDecoration(
                    //             color: AppColor.leftArrow,
                    //             borderRadius: BorderRadius.circular(9),
                    //           ),
                    //           child: Padding(
                    //             padding: const EdgeInsets.all(9.5),
                    //             child: Image.asset(
                    //               AppImages.closeImage,
                    //               height: 11,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
