import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Core/Routes/app_go_routes.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../Controller/shop_notifier.dart';

class SearchKeyword extends ConsumerStatefulWidget {
  const SearchKeyword({super.key});

  @override
  ConsumerState<SearchKeyword> createState() => _SearchKeywordState();
}

class _SearchKeywordState extends ConsumerState<SearchKeyword> {
  final TextEditingController _searchKeywordController =
      TextEditingController();

  final List<String> _keywords = [];
  final List<String> _recommendedKeywords = [
    'Saravana store',
    'Textile near me',
    'Tshirt Sale',
    'Mens Clothing',
    'Trending costumes',
  ];
  int selectedIndex = 0;
  bool _showRecommended = false;

  void _addKeyword(String keyword) {
    final text = keyword.trim();

    if (text.isEmpty) return;

    if (_keywords.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keyword already added')));
      return;
    }

    if (_keywords.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 5 keywords')),
      );
      return;
    }

    setState(() => _keywords.add(text));
  }

  void _onSubmitted() {
    _addKeyword(_searchKeywordController.text);
    _searchKeywordController.clear();
  }

  void _removeKeyword(String keyword) {
    setState(() => _keywords.remove(keyword));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopCategoryNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                value: 0.8,
              ),

              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Search Keyword title
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Search Keyword',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload a clear photo of your shop signboard showing the name clearly.',
                    ),
                    SizedBox(height: 10),

                    // Typing Field
                    TextField(
                      controller: _searchKeywordController,
                      enabled: _keywords.length < 5,
                      onSubmitted: (_) => _onSubmitted(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColor.lightGray,
                        hintText: _keywords.length >= 5
                            ? 'Keyword limit reached'
                            : 'Enter keyword',
                        hintStyle: AppTextStyles.mulish(
                          fontSize: 14,
                          color: AppColor.gray84,
                        ),
                        suffixIcon: _searchKeywordController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    _searchKeywordController.clear(),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    SizedBox(height: 10),
                    Text(
                      'Maximum 5 keywords acceptable',
                      style: AppTextStyles.mulish(
                        fontSize: 12,
                        color: AppColor.darkGrey,
                      ),
                    ),
                    SizedBox(height: 15),

                    // Show typed/added keywords only
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _keywords.map((keyword) {
                        return DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          color: AppColor.black,
                          strokeWidth: 1,
                          dashPattern: [3, 2],
                          padding: EdgeInsets.all(1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 9,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  keyword,
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.black,
                                  ),
                                ),
                                SizedBox(width: 10),
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
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20),

                    //  Toggle Button (show/hide recommended)
                    GestureDetector(
                      onTap: () => setState(() {
                        _showRecommended = !_showRecommended;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.brightBlue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          child: Text(
                            _showRecommended
                                ? 'Hide Recommended Keywords'
                                : 'View Recommended Keywords',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              color: AppColor.scaffoldColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    //  Recommended Keywords (only when toggled)
                    if (_showRecommended)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _recommendedKeywords.map((keyword) {
                          return GestureDetector(
                            onTap: () => _addKeyword(keyword),
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
                                child: Text(
                                  keyword,
                                  style: AppTextStyles.mulish(
                                    color: AppColor.gray84,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: 30),

                    //  Save & Continue
                    // CommonContainer.button(
                    //   buttonColor: AppColor.black,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => ProductCategoryScreens(),
                    //       ),
                    //     );
                    //   },
                    //   text: Text(
                    //     'Save & Continue',
                    //     style: AppTextStyles.mulish(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w700,
                    //     ),
                    //   ),
                    //   imagePath: AppImages.rightStickArrow,
                    //   imgHeight: 20,
                    // ),
                    CommonContainer.button(
                      buttonColor: AppColor.black,
                      onTap: () async {
                        if (_keywords.isEmpty) {
                          AppSnackBar.error(
                            context,
                            'Please add at least one keyword',
                          );
                          return;
                        }

                        // Call the API with the keywords list
                        final result = await ref
                            .read(shopCategoryNotifierProvider.notifier)
                            .searchKeywords(keywords: _keywords);

                        // Check state or API response, then navigate
                        final state = ref.read(shopCategoryNotifierProvider);
                        if (result) {
                          context.pushNamed(
                            AppRoutes.productCategoryScreens,
                            extra: 'SearchKeyword',
                          );
                          // Only navigate if API call is successful
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ProductCategoryScreens(),
                          //   ),
                          // );
                        } else if (state.error != null) {
                          AppSnackBar.error(context, state.error!);
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
    );
  }
}
