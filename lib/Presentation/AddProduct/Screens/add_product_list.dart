import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Screens/product_search_keyword.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';

class AddProductList extends StatefulWidget {
  const AddProductList({super.key});

  @override
  State<AddProductList> createState() => _AddProductListState();
}

class _AddProductListState extends State<AddProductList> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  List<File?> _pickedImages = List<File?>.filled(4, null);
  List<bool> _hasError = List<bool>.filled(4, false);

  List<Map<String, TextEditingController>> _featureControllers = [
    {'heading': TextEditingController(), 'answer': TextEditingController()},
  ];

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);
        _hasError[index] = false;
      });
    }
  }

  void _addFeatureList() {
    setState(() {
      _featureControllers.add({
        'heading': TextEditingController(),
        'answer': TextEditingController(),
      });
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _featureControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var map in _featureControllers) {
      map['heading']?.dispose();
      map['answer']?.dispose();
    }
    super.dispose();
  }

  Widget _addImageContainer({required int index}) {
    final file = _pickedImages[index];
    final hasError = _hasError[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                        SizedBox(width: 10),
                        Text(
                          'Add Image',
                          style: AppTextStyles.mulish(color: AppColor.darkGrey),
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

  Widget _buildFeatureItem(int index) {
    final headingController = _featureControllers[index]['heading']!;
    final answerController = _featureControllers[index]['answer']!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Feature Title + Remove Button ---
          Row(
            children: [
              Text(
                '${index + 1}. Feature',
                style: AppTextStyles.mulish(color: AppColor.mildBlack),
              ),
              Spacer(),
              if (_featureControllers.length > 1)
                InkWell(
                  onTap: () => _removeFeature(index),
                  child: Icon(Icons.close, size: 20, color: Colors.red),
                ),
            ],
          ),
          SizedBox(height: 10),

          // --- Heading Row ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CommonContainer.fillingContainer(
                  verticalDivider: false,
                  controller: headingController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter Feature Heading'
                      : null,
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Heading',
                style: AppTextStyles.mulish(color: AppColor.mildBlack),
              ),
            ],
          ),
          SizedBox(height: 10),

          // --- Answer Row ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CommonContainer.fillingContainer(
                  verticalDivider: false,
                  controller: answerController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter Feature Answer'
                      : null,
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Answer ',
                style: AppTextStyles.mulish(color: AppColor.mildBlack),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _validateAndSubmit() {
    // bool imageValid = true;
    // if (_pickedImages[0] == null) {
    //   imageValid = false;
    //   _hasError[0] = true;
    // }
    //
    // final formValid = _formKey.currentState?.validate() ?? false;
    // setState(() {}); // Refresh borders / error text
    //
    // if (!imageValid) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please add required product image")),
    //   );
    //   return;
    // }
    //
    // if (!formValid) return;

    //  All valid → proceed to next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchKeyword(isCompany: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                      Text(
                        'Product Image',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      _addImageContainer(index: 0),
                      SizedBox(height: 25),
                      Text(
                        'Feature List',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 20),

                      // --- Dynamic Feature Items ---
                      Column(
                        children: List.generate(
                          _featureControllers.length,
                          (index) => _buildFeatureItem(index),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: _addFeatureList,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.lightGray,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 22.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.addListImage, height: 20),
                              SizedBox(width: 10),
                              Text(
                                'Add Feature List',
                                style: AppTextStyles.mulish(
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _validateAndSubmit,
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
