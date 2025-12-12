import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Widgets/bottom_navigation_bar.dart';
import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';
import 'package:tringo_vendor/Presentation/No%20Data%20Screen/Screen/no_data_screen.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';

class OfferProducts extends ConsumerStatefulWidget {
  final bool? isService;
  final String? shopId;
  final String? offerId;
  final String? type;
  const OfferProducts({
    super.key,
    required this.isService,
    this.shopId,
    this.offerId,
    this.type,
  });

  @override
  ConsumerState<OfferProducts> createState() => _OfferProductsState();
}

class _OfferProductsState extends ConsumerState<OfferProducts> {
  List<bool> selectedItems = List.generate(10, (_) => false);
  int selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Items',
    'Mixture',
    'Halwa',
    'Badam',
    'Cookies',
    'Sweets',
  ];
  @override
  void initState() {
    super.initState();
    AppLogger.log.i('App Offer id = ${widget.offerId}');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(offerNotifierProvider.notifier)
          .productListShowForOffer(
            shopId: widget.shopId ?? '',
            type: widget.type ?? '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isService =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;
    final offerState = ref.watch(offerNotifierProvider);
    final notifier = ref.read(offerNotifierProvider.notifier);
    final offerProductsData = offerState.offerProducts;

    final isProduct = !isService;
    return Skeletonizer(
      enabled: offerState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: CommonContainer.topLeftArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // --- Header Banner ---
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.registerBCImage),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                      colors: [AppColor.scaffoldColor, AppColor.papayaWhip],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(AppImages.appOffer, height: 154),
                      Text(
                        isProduct
                            ? 'Select Offered Products'
                            : 'Select Offered Services',
                        style: AppTextStyles.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      const SizedBox(height: 35),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Content ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      // --- Filter Chips ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_filters.length, (index) {
                            final title = _filters[index];
                            final isSelected = selectedFilterIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilterIndex = index;
                                });
                              },
                              child: _filterChip(title, isSelected),
                            );
                          }),
                        ),
                      ),

                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       _filterChip('All Items', true),
                      //       _filterChip('Mixture'),
                      //       _filterChip('Halwa'),
                      //       _filterChip('Badam'),
                      //       _filterChip('Cookies'),
                      //       _filterChip('Sweets'),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(height: 20),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: offerProductsData?.data?.items.length ?? 0,
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: CommonContainer.horizonalDivider(),
                        ),
                        itemBuilder: (context, index) {
                          final data = offerProductsData?.data?.items[index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedItems[index] = !selectedItems[index];
                              });
                            },
                            child: _buildProductTile(
                              title:
                                  data?.name.toUpperCase().toString() ??
                                  '',
                              url: data?.imageUrl.toString() ?? '',
                              offerPrice: 0,
                              price: 0,

                              index,
                              selectedItems[index],
                            ),
                          );
                        },
                      ),

                      // --- Footer ---
                      const SizedBox(height: 20),
                      Text(
                        '${selectedItems.where((e) => e).length} Products Selected',
                        style: AppTextStyles.mulish(color: AppColor.gray84),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CommonContainer.button(
                          onTap: () async {
                            final items = offerProductsData?.data?.items;
                            if (items == null || items.isEmpty) {
                              AppSnackBar.error(context, "No items available");
                              return;
                            }

                            final selectedIds = <String>[
                              for (int i = 0; i < items.length; i++)
                                if (selectedItems[i]) items[i].id,
                            ];

                            if (selectedIds.isEmpty) {
                              AppSnackBar.error(context, "No products selected");
                              return;
                            }

                            final success = await notifier.updateOfferList(
                              productIds: selectedIds,             // <-- now List<String>
                              shopId: widget.shopId ?? '',
                              offerId: widget.offerId ?? '',
                            );

                            print("Selected Product IDs: $selectedIds");

                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommonBottomNavigation(initialIndex: 2),
                                ),
                              );
                            }
                          },

                          imagePath: AppImages.rightStickArrow,
                          text: offerState.updateInsertLoading
                              ? ThreeDotsLoader()
                              : Text(
                                  'Apply Offer',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  // --- Filter Chip ---
  Widget _filterChip(String title, [bool isSelected = false]) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColor.darkBlue : AppColor.lightSilver,
        ),
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.mulish(
              color: isSelected ? AppColor.darkBlue : AppColor.darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isSelected)
            const Icon(Icons.chevron_right, color: AppColor.darkBlue, size: 20)
          else
            const Icon(Icons.chevron_right, color: AppColor.darkGrey, size: 20),

          // if (!isSelected) ...[
          //     SizedBox(width: 2),
          //   Icon(Icons.chevron_right, color: AppColor.darkGrey, size: 20),
          // ],
        ],
      ),
    );
  }

  // --- Product Tile ---
  Widget _buildProductTile(
    int index,
    bool isSelected, {
    required String title,
    required int price,
    required int offerPrice,
    required String url,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Left: Product Info ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mulish(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹$offerPrice',
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹$price',
                      style: AppTextStyles.mulish(
                        color: AppColor.borderLightGrey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Middle: Product Image ---
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: url, // your image URL
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                height: 35,
                width: 35,
                child: Center(child: CircularProgressIndicator(strokeAlign: 2)),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          const SizedBox(width: 15),

          // --- Right: Selection Box ---
          isSelected
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.blue, size: 20),
                )
              : DottedBorder(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade400,
                  strokeWidth: 1.5,
                  dashPattern: const [4, 4],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(15),
                  child: const SizedBox(width: 28, height: 28),
                ),
        ],
      ),
    );
  }
}
