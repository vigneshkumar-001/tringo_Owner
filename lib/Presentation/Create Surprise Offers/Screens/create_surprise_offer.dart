import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../Controller/create_surprise_notifier.dart';
import '../Model/surprise_offer_list_response.dart';
class CreateSurpriseOffer extends ConsumerStatefulWidget {
  final String shopId;
  final OfferItem? initialOffer;

  const CreateSurpriseOffer({
    super.key,
    required this.shopId,
    this.initialOffer,
  });

  bool get isEdit => initialOffer != null;

  @override
  ConsumerState<CreateSurpriseOffer> createState() =>
      _CreateSurpriseOfferState();
}
class _CreateSurpriseOfferState extends ConsumerState<CreateSurpriseOffer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Ã¢Å“â€¦ Controllers
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _offerTitleController = TextEditingController();
  final TextEditingController _availableDateController =
      TextEditingController();
  final TextEditingController _offerDescriptionController =
      TextEditingController();

  int Percentage = 1;

  // Ã¢Å“â€¦ Image Picker
  final ImagePicker _picker = ImagePicker();
  File? _bannerImageFile;
  String _existingBannerUrl = '';
  bool _didSyncBranchLabel = false;

  Map<String, String> _extractDateRange(String value) {
    if (value.isEmpty) return {"from": "", "to": ""};

    // UI format: "12-12-2025 to 15-12-2025"
    final parts = value.split(" to ");

    if (parts.length != 2) {
      return {"from": "", "to": ""};
    }

    return {"from": parts[0].trim(), "to": parts[1].trim()};
  }
  String _formatUiDate(DateTime d) =>
      DateFormat('dd-MM-yyyy').format(d.toLocal());

  String _formatUiDateRange(DateTime from, DateTime to) {
    return '${_formatUiDate(from)} to ${_formatUiDate(to)}';
  }

  void _prefillFromOffer(OfferItem offer) {
    _offerTitleController.text = offer.title;
    _offerDescriptionController.text = offer.description;

    final branch = offer.branchId.trim();
    _selectedBranchId = branch.isEmpty ? null : branch;

    _existingBannerUrl = (offer.bannerUrl ?? '').trim();

    final totalCoupons = offer.coupons.total;
    Percentage = totalCoupons > 0 ? totalCoupons : 1;

    final from = offer.availableFrom;
    final to = offer.availableTo;
    if (from != null && to != null) {
      _availableDateController.text = _formatUiDateRange(from, to);
    }
  }

  @override
  void dispose() {
    _branchController.dispose();
    _offerTitleController.dispose();
    _availableDateController.dispose();
    _offerDescriptionController.dispose();
    super.dispose();
  }

  String? _selectedBranchId;

  void _openBranchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(createSurpriseNotifier);
            final branches = state.storeListResponse?.data?.items ?? [];

            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Column(
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
                  const Text(
                    "Select Branch",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  /// Ã°Å¸â€Â½ CONTENT AREA
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        /// Ã°Å¸â€â€ž Loading (CENTERED)
                        if (state.isLoading) {
                          return const Center(
                            child: ThreeDotsLoader(dotColor: AppColor.black),
                          );
                        }

                        /// Ã¢ÂÅ’ Error (CENTERED)
                        if (state.error != null) {
                          return Center(
                            child: Text(
                              state.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        /// Ã¢Å¡Â Ã¯Â¸Â Empty (CENTERED)
                        if (branches.isEmpty) {
                          return const Center(
                            child: Text(
                              "No branches found",
                              style: TextStyle(fontSize: 14),
                            ),
                          );
                        }

                        /// Ã¢Å“â€¦ Success (LIST)
                        return ListView.separated(
                          itemCount: branches.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final branch = branches[index];

                            return ListTile(
                              title: Text(branch.label),
                              subtitle: Text(
                                "${branch.address}, ${branch.city}",
                              ),
                              onTap: () {
                                setState(() {
                                  _branchController.text = branch.label;
                                  _selectedBranchId = branch.id;
                                });

                                debugPrint("Selected Branch ID: ${branch.id}");
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Ã¢Å“â€¦ Image Picker function
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

  // Ã¢Å“â€¦ Banner picker bottomsheet
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

              // Ã¢Å“â€¦ Only show when image already selected
              if (_bannerImageFile != null || _existingBannerUrl.trim().isNotEmpty) ...[
                CommonContainer.horizonalDivider(),

                // // (Optional) View
                // ListTile(
                //   leading: const Icon(Icons.visibility),
                //   title: const Text("View Image"),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _viewBannerImage(); // create this function below
                //   },
                // ),

                // Ã¢Å“â€¦ Remove
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    "Remove Image",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() { _bannerImageFile = null; _existingBannerUrl = ''; });
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _viewBannerImage() {
    if (_bannerImageFile == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(_bannerImageFile!, fit: BoxFit.contain),
        ),
      ),
    );
  }

  String convertToApiFormat(String value) {
    // value = "12-12-2025"
    final parts = value.split("-");
    if (parts.length != 3) return value;

    final day = parts[0];
    final month = parts[1];
    final year = parts[2];

    return "$year-$month-$day"; // 2025-12-12
  }

  @override
  void initState() {
    super.initState();

    final offer = widget.initialOffer;
    if (offer != null) {
      _prefillFromOffer(offer);
    }

    Future.microtask(() {
      ref
          .read(createSurpriseNotifier.notifier)
          .getBranchList(apiShopId: widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSurpriseNotifier);

    final branches = state.storeListResponse?.data?.items ?? [];
    if (!_didSyncBranchLabel) {
      final selected = (_selectedBranchId ?? '').trim();
      final currentLabel = _branchController.text.trim();

      if (selected.isEmpty || currentLabel.isNotEmpty) {
        _didSyncBranchLabel = true;
      } else if (branches.isNotEmpty) {
        _didSyncBranchLabel = true;
        for (final b in branches) {
          if (b.id == selected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _branchController.text = b.label;
              });
            });
            break;
          }
        }
      }
    }

    AppLogger.log.w(widget.shopId);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Ã¢Å“â€¦ back arrow
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: CommonContainer.topLeftArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // Ã¢Å“â€¦ Top Banner UI
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
                        widget.isEdit ? 'Edit Surprise Offer' : 'Create Surprise Offer',
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

                // Ã¢Å“â€¦ FORM AREA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ã¢Å“â€¦ Select Branch
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

                      // Ã¢Å“â€¦ Banner Add Container
                      Text(
                        'Surprise Offer Banner',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      InkWell(
                        onTap: () {
                          if (_bannerImageFile != null) {
                            _openBannerPickerSheet(); // Ã¢Å“â€¦ view/replace/remove
                          } else {
                            _openBannerPickerSheet(); // Ã¢Å“â€¦ pick sheet
                          }
                        },
                        child: Container(
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: AppColor.leftArrow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _bannerImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _bannerImageFile!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (_existingBannerUrl.trim().isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(
                                          _existingBannerUrl,
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => SizedBox(
                                            height: 50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  AppImages.addImage,
                                                  width: 20,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "Add Image",
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              AppImages.addImage,
                                              width: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Add Image",
                                              style: AppTextStyles.mulish(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Ã¢Å“â€¦ Title
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

                      // Ã¢Å“â€¦ Description
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

                      // Ã¢Å“â€¦ Date Range
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

                      // Ã¢Å“â€¦ Count
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

                      // Ã¢Å“â€¦ Done Button
                      CommonContainer.button(
                        isLoading: state.isLoading,
                        buttonColor: AppColor.black,
                        onTap: state.isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                // -------- AVAILABLE DATE RANGE --------
                                final extracted = _extractDateRange(
                                  _availableDateController.text,
                                );

                                String availableFrom = extracted["from"] ?? "";
                                String availableTo = extracted["to"] ?? "";
                                final apiAvailableFrom = availableFrom.isEmpty
                                    ? ""
                                    : convertToApiFormat(availableFrom);
                                final apiAvailableTo = availableTo.isEmpty
                                    ? ""
                                    : convertToApiFormat(availableTo);
                                final branchId =
                                    (_selectedBranchId ?? '').trim();
                                if (branchId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select branch"),
                                    ),
                                  );
                                  return;
                                }

                                final hasBanner =
                                    _bannerImageFile != null ||
                                        _existingBannerUrl.trim().isNotEmpty;
                                if (!hasBanner) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please add banner image"),
                                    ),
                                  );
                                  return;
                                }
                                AppLogger.log.w(apiAvailableTo);
                                AppLogger.log.w(apiAvailableFrom);
                                final sucess = await ref
                                    .watch(createSurpriseNotifier.notifier)
                                    .saveSurpriseOffer(
                                      offerId: widget.initialOffer?.id,
                                      branchId: branchId,
                                      bannerImageFile: _bannerImageFile,
                                      existingBannerUrl: _existingBannerUrl
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _existingBannerUrl.trim(),
                                      title: _offerTitleController.text.trim(),
                                      description: _offerDescriptionController
                                          .text
                                          .trim(),
                                      shopIdToUse: widget.shopId,
                                      couponCount: Percentage,
                                      availableFrom: apiAvailableFrom,
                                      availableTo: apiAvailableTo,
                                    );
                                if (sucess) {
                                  if (!mounted) return;
                                  Navigator.pop(context, true);
                                } else {
                                  final latestError = ref
                                      .read(createSurpriseNotifier)
                                      .error;
                                  AppSnackBar.error(context, latestError ?? '');
                                }
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => SurpriseOfferList()),
                                // );
                              },
                        text: Text(
                          widget.isEdit ? 'Update' : 'Done',
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















