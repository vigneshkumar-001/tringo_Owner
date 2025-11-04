import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';

class OfferProducts extends StatefulWidget {
  const OfferProducts({super.key});

  @override
  State<OfferProducts> createState() => _OfferProductsState();
}

class _OfferProductsState extends State<OfferProducts> {
  List<bool> selectedItems = List.generate(10, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Back Arrow ---
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
                      'Select Offered Products',
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
                        children: [
                          _filterChip('All Items', true),
                          _filterChip('Mixture'),
                          _filterChip('Halwa'),
                          _filterChip('Badam'),
                          _filterChip('Cookies'),
                          _filterChip('Sweets'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Product List ---
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CommonContainer.horizonalDivider(),
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedItems[index] = !selectedItems[index];
                            });
                          },
                          child: _buildProductTile(index, selectedItems[index]),
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
                        onTap: () {},
                        imagePath: AppImages.rightStickArrow,
                        text: Text('Apply Offer'),
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
            style: TextStyle(
              color: isSelected ? AppColor.darkBlue : AppColor.darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isSelected) ...[
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, color: AppColor.darkGrey, size: 20),
          ],
        ],
      ),
    );
  }

  // --- Product Tile ---
  Widget _buildProductTile(int index, bool isSelected) {
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
                  'Badam Mysurpa - 500Gm',
                  style: AppTextStyles.mulish(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹85',
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹95',
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
            child: Image.asset(
              AppImages.phone,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
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
                  strokeWidth: 1,
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
