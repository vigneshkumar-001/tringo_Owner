import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Controller/product_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../Shops Details/Screen/shops_details.dart';
import '../Service Info/Controller/service_info_notifier.dart';
import 'add_product_list.dart';

class ProductSearchKeyword extends ConsumerStatefulWidget {
  final bool? isCompany;
  const ProductSearchKeyword({super.key, this.isCompany});
  bool get isCompanyResolved =>
      isCompany ??
      (RegistrationSession.instance.businessType == BusinessType.company);

  @override
  ConsumerState<ProductSearchKeyword> createState() =>
      _ProductSearchKeywordState();
}

class _ProductSearchKeywordState extends ConsumerState<ProductSearchKeyword> {
  final TextEditingController _searchKeywordController =
      TextEditingController();

  final List<String> _keywords = []; // Only added/typed ones
  final List<String> _recommendedKeywords = [
    'Face tissue',
    'Paper product',
    'Bathroom product',
    'Paper',
    'face towel',
  ];

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
    final state = ref.watch(productNotifierProvider);

    final isProduct = RegistrationProductSeivice.instance.isProductBusiness;
    final isService = RegistrationProductSeivice.instance.isServiceBusiness;
    final bool isCompany = widget.isCompanyResolved;

    final serviceState = ref.watch(serviceInfoNotifierProvider);
    final productState = ref.watch(productNotifierProvider);

    final bool isLoading = isService
        ? serviceState.isLoading
        : productState.isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CommonContainer.topLeftArrow(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductList(),
                          ),
                        );
                      },
                      // onTap: () => Navigator.pop(context),
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
                text: isService ? 'Add Service' : 'Add Product',
                imageHeight: 85,
                gradientColor: AppColor.lavenderMist,
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
                          'Add relevant search keywords customers might use to find your shop.',
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

                    CommonContainer.button(
                      buttonColor: AppColor.black,
                      onTap: () async {
                        FocusScope.of(context).unfocus();

                        // 🔹 Basic validation
                        if (_keywords.isEmpty) {
                          AppSnackBar.error(
                            context,
                            'Please add at least one keyword',
                          );
                          return;
                        }

                        final session = RegistrationProductSeivice.instance;
                        final isService = session.isServiceBusiness;

                        bool success = false;

                        // 🔹 Call correct API (service / product)
                        if (isService) {
                          success = await ref
                              .read(serviceInfoNotifierProvider.notifier)
                              .serviceSearchWords(keywords: _keywords);
                        } else {
                          success = await ref
                              .read(productNotifierProvider.notifier)
                              .updateProductSearchWords(keywords: _keywords);
                        }

                        final productState = ref.read(productNotifierProvider);
                        final serviceState = ref.read(
                          serviceInfoNotifierProvider,
                        );

                        // ❌ Handle errors
                        if (!success) {
                          if (!isService && productState.error != null) {
                            AppSnackBar.error(context, productState.error!);
                          } else if (isService && serviceState.error != null) {
                            AppSnackBar.error(context, serviceState.error!);
                          }
                          return;
                        }

                        // ✅ SUCCESS FLOW
                        final productSession =
                            RegistrationProductSeivice.instance;
                        final regSession = RegistrationSession.instance;

                        // Company + NOT subscribed → go to subscription
                        if (regSession.isCompanyBusiness &&
                            productSession.isNonPremium) {
                          context.pushNamed(
                            AppRoutes.subscriptionScreen,
                            extra: true,
                          );
                        } else {
                          // ✅ Preview → ShopsDetails (GoRouter)
                          context.pushNamed(
                            AppRoutes.shopsDetails,
                            extra: {
                              'backDisabled': true,
                              'fromSubscriptionSkip': false,
                            },
                          );
                        }
                      },
                      text: isLoading
                          ? ThreeDotsLoader()
                          : Text(
                              'Preview Shop & Product',
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
                    //     // --- Basic validation ---
                    //     if (_keywords.isEmpty) {
                    //       AppSnackBar.error(
                    //         context,
                    //         'Please add at least one keyword',
                    //       );
                    //       return;
                    //     }
                    //
                    //     final session = RegistrationProductSeivice.instance;
                    //     final isService = session.isServiceBusiness;
                    //     final isPremium = session.isPremium;
                    //     AppLogger.log.i('isPremium : $isPremium');
                    //     bool success = false;
                    //
                    //     // --- CASE: SERVICE BUSINESS ---
                    //     if (isService) {
                    //       success = await ref
                    //           .read(serviceInfoNotifierProvider.notifier)
                    //           .serviceSearchWords(keywords: _keywords);
                    //     }
                    //     // --- CASE: PRODUCT BUSINESS ---
                    //     else {
                    //       success = await ref
                    //           .read(productNotifierProvider.notifier)
                    //           .updateProductSearchWords(keywords: _keywords);
                    //     }
                    //
                    //     final productState = ref.read(productNotifierProvider);
                    //     final serviceState = ref.read(
                    //       serviceInfoNotifierProvider,
                    //     );
                    //
                    //     // --- HANDLE RESULT ---
                    //     if (success) {
                    //       final productSession =
                    //           RegistrationProductSeivice.instance;
                    //       final regSession = RegistrationSession.instance;
                    //
                    //       // Company + NOT subscribed → go to subscription
                    //       if (regSession.isCompanyBusiness &&
                    //           productSession.isNonPremium) {
                    //         context.pushNamed(
                    //           AppRoutes.subscriptionScreen,
                    //           extra: true,
                    //         );
                    //       } else {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => ShopsDetails(),
                    //           ),
                    //         );
                    //       }
                    //     }
                    //     // if (success) {
                    //     //   if (isPremium) {
                    //     //     context.pushNamed(
                    //     //       AppRoutes.subscriptionScreen,
                    //     //       extra: true,
                    //     //     );
                    //     //   }
                    //     //   else {
                    //     //     Navigator.push(
                    //     //       context,
                    //     //       MaterialPageRoute(
                    //     //         builder: (context) => ShopsDetails(),
                    //     //       ),
                    //     //     );
                    //     //   }
                    //     // }
                    //     else {
                    //       // --- Product error ---
                    //       if (!isService && productState.error != null) {
                    //         AppSnackBar.error(context, productState.error!);
                    //       }
                    //
                    //       // --- Service error ---
                    //       if (isService && serviceState.error != null) {
                    //         AppSnackBar.error(context, serviceState.error!);
                    //       }
                    //     }
                    //   },
                    //   text: isLoading
                    //       ? ThreeDotsLoader()
                    //       : Text(
                    //           'Preview Shop & Product',
                    //           style: AppTextStyles.mulish(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //   imagePath: isLoading ? null : AppImages.rightStickArrow,
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
