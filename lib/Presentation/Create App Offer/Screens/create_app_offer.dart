import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor/Core/Const/app_logger.dart';
import 'package:tringo_vendor/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../Offer/Model/offer_model.dart';
import '../Model/create_offers.dart';
import 'offer_products.dart';

class CreateAppOffer extends ConsumerStatefulWidget {
  final String? shopId;
  final bool? isService;
  final bool isEdit; // ✅ new
  final OfferItem? editOffer;
  const CreateAppOffer({
    super.key,
    this.shopId,
    this.isService,
    this.isEdit = false,
    this.editOffer,
  });

  @override
  ConsumerState<CreateAppOffer> createState() => _CreateAppOfferState();
}

class _CreateAppOfferState extends ConsumerState<CreateAppOffer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _offerTitleController = TextEditingController();
  final _availableDateController = TextEditingController();
  final _offerDescriptionController = TextEditingController();
  final _announcementDateController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController(
    text: '1',
  );

  int percentage = 1;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.editOffer != null) {
      final o = widget.editOffer!;

      _offerTitleController.text = o.title;
      _offerDescriptionController.text = o.description;

      // percentage
      final p = (o.discountPercentage is num)
          ? (o.discountPercentage.toInt())
          : 1;
      percentage = p.clamp(1, 100);
      _percentageController.text = percentage.toString();

      // available date range (UI format: dd-MM-yyyy to dd-MM-yyyy)
      final from = _fmtUiDate(o.availableFrom);
      final to = _fmtUiDate(o.availableTo);
      if (from.isNotEmpty && to.isNotEmpty) {
        _availableDateController.text = "$from to $to";
      }

      // announcement date (UI format dd-MM-yyyy)
      _announcementDateController.text = _fmtUiDate(o.announcementAt);
    }
  }

  String _fmtUiDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('dd-MM-yyyy').format(d);
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _offerTitleController.dispose();
    _availableDateController.dispose();
    _offerDescriptionController.dispose();
    _announcementDateController.dispose();
    super.dispose();
  }

  Map<String, String> _extractDateRange(String value) {
    if (value.isEmpty) return {"from": "", "to": ""};

    // UI format: "12-12-2025 to 15-12-2025"
    final parts = value.split(" to ");

    if (parts.length != 2) {
      return {"from": "", "to": ""};
    }

    return {"from": parts[0].trim(), "to": parts[1].trim()};
  }

  // Map<String, String> _extractDateRange(String value) {
  //   if (!value.contains("-")) return {"from": "", "to": ""};
  //
  //   final parts = value.split("-");
  //   if (parts.length < 2) return {"from": "", "to": ""};
  //
  //   return {"from": parts[0].trim(), "to": parts[1].trim()};
  // }
  String convertToApiFormat(String value) {
    // value = "12-12-2025"
    final parts = value.split("-");
    if (parts.length != 3) return value;

    final day = parts[0];
    final month = parts[1];
    final year = parts[2];

    return "$year-$month-$day"; // 2025-12-12
  }

  Future<void> _onSubmit() async {
    // -------- VALIDATION (create only) --------
    if (!widget.isEdit) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
        return;
      }
    }

    final notifier = ref.read(offerNotifierProvider.notifier);
    final state = ref.read(offerNotifierProvider);

    final OfferItem? existing = widget.editOffer;

    // -------- TITLE / DESCRIPTION --------
    final titleInput = _offerTitleController.text.trim();
    final descInput = _offerDescriptionController.text.trim();

    final String finalTitle = widget.isEdit
        ? (titleInput.isNotEmpty ? titleInput : (existing?.title ?? ""))
        : titleInput;

    final String finalDesc = widget.isEdit
        ? (descInput.isNotEmpty ? descInput : (existing?.description ?? ""))
        : descInput;

    // -------- DISCOUNT --------
    final enteredPercentage = int.tryParse(_percentageController.text.trim());

    final int finalPercentage =
        (enteredPercentage ?? existing?.discountPercentage.toInt() ?? 1).clamp(
          1,
          100,
        );

    // -------- AVAILABLE DATE RANGE --------
    final extracted = _extractDateRange(_availableDateController.text);

    String availableFrom = extracted["from"] ?? "";
    String availableTo = extracted["to"] ?? "";

    if (widget.isEdit) {
      if (availableFrom.isEmpty) {
        availableFrom = _fmtUiDate(existing?.availableFrom);
      }
      if (availableTo.isEmpty) {
        availableTo = _fmtUiDate(existing?.availableTo);
      }
    }

    final apiAvailableFrom = availableFrom.isEmpty
        ? ""
        : convertToApiFormat(availableFrom);
    final apiAvailableTo = availableTo.isEmpty
        ? ""
        : convertToApiFormat(availableTo);

    // -------- ANNOUNCEMENT DATE --------
    String announcement = _announcementDateController.text.trim();

    if (widget.isEdit && announcement.isEmpty) {
      announcement = _fmtUiDate(existing?.announcementAt);
    }

    final apiAnnouncement = announcement.isEmpty
        ? ""
        : convertToApiFormat(announcement);

    // ============================================================
    // ======================= CREATE =============================
    // ============================================================
    if (!widget.isEdit) {
      final created = await notifier.createOffer(
        shopId: widget.shopId ?? "",
        title: finalTitle,
        description: finalDesc,
        discountPercentage: finalPercentage,
        availableFrom: apiAvailableFrom,
        availableTo: apiAvailableTo,
        announcementAt: apiAnnouncement,
      );

      if (created == null) {
        final err = ref.read(offerNotifierProvider).error;
        AppSnackBar.error(
          context,
          err?.isNotEmpty == true ? err! : "Something went wrong",
        );
        return;
      }

      final bool isServiceFlow =
          widget.isService ??
          RegistrationProductSeivice.instance.isServiceBusiness;

      context.pushNamed(
        AppRoutes.offerProducts,
        extra: {
          'isService': isServiceFlow,
          'offerId': created.data?.id,
          'shopId': created.data?.shop.id,
          'type': created.data?.nextListType,
        },
      );

      return;
    }

    // ============================================================
    // ======================== UPDATE ============================
    // ============================================================

    final offerId = existing?.id ?? "";
    if (offerId.isEmpty) {
      AppSnackBar.error(context, "Offer id missing");
      return;
    }

    final bool isServiceFlow =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;

    final List<String> preSelectedIds = isServiceFlow
        ? (existing?.services.map((e) => e.id).toList() ?? <String>[])
        : (existing?.products.map((e) => e.id).toList() ?? <String>[]);

    final shopId = widget.shopId?.trim() ?? "";
    if (shopId.isEmpty) {
      AppSnackBar.error(context, "Shop id missing");
      return;
    }

    final bool ok = await notifier.editAndUpdateOffer(
      context: context, // you can remove later if you clean notifier
      offerId: offerId,
      shopId: shopId,
      type: isServiceFlow ? "SERVICE" : "PRODUCT",
      productIds: preSelectedIds,
      title: finalTitle,
      description: finalDesc,
      discountPercentage: finalPercentage,
      availableFrom: apiAvailableFrom,
      availableTo: apiAvailableTo,
      announcementAt: apiAnnouncement,
    );

    if (!ok) {
      final err = ref.read(offerNotifierProvider).error;
      AppSnackBar.error(
        context,
        err?.isNotEmpty == true ? err! : "Something went wrong",
      );
      return;
    }

    // -------- NAVIGATE AFTER UPDATE --------
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfferProducts(
          isService: isServiceFlow,
          shopId: shopId,
          offerId: offerId,
          type: isServiceFlow ? "SERVICE" : "PRODUCT",
          preSelectedIds: preSelectedIds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offerState = ref.watch(offerNotifierProvider);
    final bool isServiceFlow =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;
    AppLogger.log.i('IS Service : $isServiceFlow');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CommonContainer.topLeftArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                ),

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
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(AppImages.appOffer, height: 150),
                      Text(
                        "Create App Offer",
                        style: AppTextStyles.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "App Offer Title",
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _offerTitleController,
                        validator: (v) {
                          if (widget.isEdit)
                            return null; // ✅ no validation in edit mode
                          return v == null || v.isEmpty ? "Enter title" : null;
                        },
                      ),

                      SizedBox(height: 25),

                      Text(
                        "App Offer Description",
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _offerDescriptionController,
                        maxLine: 4,
                        validator: (v) => widget.isEdit
                            ? null
                            : (v == null || v.isEmpty
                                  ? "Enter description"
                                  : null),
                      ),

                      SizedBox(height: 25),

                      CommonContainer.containerTitle(
                        context: context,
                        title: "App Offer Percentage",
                        image: AppImages.iImage,
                        infoMessage: "Set your app offer discount percentage.",
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (percentage > 1) {
                                setState(() {
                                  percentage--;
                                  _percentageController.text = percentage
                                      .toString();
                                });
                              }
                            },

                            // onTap: () {
                            //   if (percentage > 1) {
                            //     setState(() => percentage--);
                            //   }
                            // },
                            child: _percentButton(AppImages.sub),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColor.leftArrow,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: IntrinsicWidth(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 45,
                                        child: TextFormField(
                                          controller: _percentageController,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                          ],
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColor.mildBlack,
                                          ),
                                          onChanged: (val) {
                                            final parsed =
                                                int.tryParse(val) ?? 0;
                                            final clamped = parsed.clamp(
                                              0,
                                              100,
                                            );
                                            if (clamped.toString() != val) {
                                              _percentageController.text =
                                                  clamped.toString();
                                              _percentageController.selection =
                                                  TextSelection.collapsed(
                                                    offset:
                                                        _percentageController
                                                            .text
                                                            .length,
                                                  );
                                            }
                                            setState(
                                              () => percentage = clamped,
                                            );
                                          },
                                        ),
                                      ),

                                      SizedBox(width: 2),

                                      // % (not editable)
                                      Text(
                                        '%',
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColor.mildBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Expanded(
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       vertical: 18,
                          //       horizontal: 40,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: AppColor.leftArrow,
                          //       borderRadius: BorderRadius.circular(11),
                          //     ),
                          //     child: Center(
                          //       child: Text(
                          //         "$percentage%",
                          //         style: AppTextStyles.mulish(
                          //           fontWeight: FontWeight.w700,
                          //           fontSize: 16,
                          //           color: AppColor.mildBlack,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              setState(() {
                                percentage++;
                                if (percentage > 100) percentage = 100;
                                _percentageController.text = percentage
                                    .toString();
                              });
                            },

                            // onTap: () {
                            //   setState(() => percentage++);
                            // },
                            child: _percentButton(AppImages.addPlus),
                          ),
                        ],
                      ),

                      SizedBox(height: 25),

                      Row(
                        children: [
                          Text(
                            "Available Date",
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "(Start to End Date)",
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _availableDateController,
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        context: context,
                        datePickMode: DatePickMode.range,
                        styledRangeText: true,
                        validator: (v) => widget.isEdit
                            ? null
                            : (v == null || v.isEmpty
                                  ? "Select date range"
                                  : null),
                      ),

                      SizedBox(height: 25),

                      Text(
                        "Announcement Date",
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),

                      SizedBox(height: 10),

                      // AnnouncementDateField(
                      //   controller: _announcementDateController,
                      //   // validator: (v) => v == null || v.isEmpty
                      //   //     ? "Select announcement date"
                      //   //     : null,
                      // ),
                      CommonContainer.fillingContainer(
                        controller: _announcementDateController,
                        isDOB: true,
                        verticalDivider: true,
                        datePickMode: DatePickMode.single,
                        singleType: DateSingleType.normal,
                        context: context,
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        validator: (v) => widget.isEdit
                            ? null
                            : (v == null || v.isEmpty
                                  ? "Select announcement date"
                                  : null),
                      ),
                      SizedBox(height: 30),

                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _onSubmit,
                        text: offerState.isLoading
                            ? ThreeDotsLoader()
                            : Text(
                                widget.isEdit
                                    ? "Update Offer"
                                    : "Next, Select Products",
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        imagePath: offerState.isLoading
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
      ),
    );
  }

  Widget _percentButton(String asset) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.leftArrow,
        borderRadius: BorderRadius.circular(11),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Image.asset(asset, width: 20),
    );
  }
}

// class AnnouncementDateField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final String? label;
//   final String dateFormat; // default: dd MMM yyyy
//   final FormFieldValidator<String>? validator;
//   final bool readOnly; // default: true
//
//   const AnnouncementDateField({
//     super.key,
//     required this.controller,
//     this.hintText = '',
//     this.label,
//     this.dateFormat = 'dd MMM yyyy',
//     this.validator,
//     this.readOnly = true,
//   });
//
//   @override
//   State<AnnouncementDateField> createState() => _AnnouncementDateFieldState();
// }
//
// class _AnnouncementDateFieldState extends State<AnnouncementDateField> {
//   Future<void> _pickDate() async {
//     FocusScope.of(context).unfocus();
//
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _tryParse(widget.controller.text) ?? now,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       helpText: 'Select announcement date',
//
//       // ✅ calendar popup white background
//       builder: (context, child) {
//         final base = Theme.of(context);
//         return Theme(
//           data: base.copyWith(
//             dialogBackgroundColor: Colors.white,
//
//             // ✅ Flutter datepicker uses ColorScheme + DatePickerTheme
//             colorScheme: base.colorScheme.copyWith(
//               brightness: Brightness.light,
//               primary: Colors.black, // selected day / buttons color
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//
//             datePickerTheme: const DatePickerThemeData(
//               backgroundColor: Colors.white, // whole calendar bg
//             ),
//
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.black, // OK / CANCEL
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked == null) return;
//
//     final formatted = DateFormat(widget.dateFormat).format(picked);
//     setState(() {
//       widget.controller.text = formatted;
//     });
//   }
//
//   DateTime? _tryParse(String v) {
//     if (v.trim().isEmpty) return null;
//     try {
//       return DateFormat(widget.dateFormat).parseStrict(v.trim());
//     } catch (_) {
//       return null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FormField<String>(
//       validator: widget.validator,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       builder: (state) {
//         final hasError = state.hasError;
//
//         final hasValue = widget.controller.text.trim().isNotEmpty;
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (widget.label != null) ...[
//               Text(
//                 widget.label!,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
//
//             GestureDetector(
//               onTap: _pickDate,
//               child: AbsorbPointer(
//                 absorbing: widget.readOnly, // ✅ keyboard open ஆகாது
//                 child: TextFormField(
//                   controller: widget.controller,
//                   readOnly: true,
//                   onChanged: (v) => state.didChange(v),
//                   decoration: InputDecoration(
//                     hintText: widget.hintText,
//
//                     // ✅ icon RIGHT side
//                     prefixIcon: null,
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // ✅ clear icon (only after selected)
//                         // if (hasValue)
//                         //   IconButton(
//                         //     icon: const Icon(Icons.close),
//                         //     onPressed: () {
//                         //       widget.controller.clear();
//                         //       state.didChange('');
//                         //       setState(() {});
//                         //     },
//                         //   ),
//
//                         // ✅ calendar icon always visible right side
//                         Padding(
//                           padding: EdgeInsets.only(right: 6),
//                           child: Image.asset(AppImages.dob, height: 20),
//                           // Icon(Icons.calendar_month),
//                         ),
//                       ],
//                     ),
//
//                     filled: true,
//                     fillColor: const Color(0xFFF5F5F5),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 14,
//                     ),
//
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide(
//                         color: hasError ? Colors.red : Colors.transparent,
//                         width: 1.5,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide(
//                         color: hasError ? Colors.red : Colors.transparent,
//                         width: 1.5,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide(
//                         color: hasError ? Colors.red : Colors.black,
//                         width: 2,
//                       ),
//                     ),
//                     errorText: null,
//                   ),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.singleLineFormatter,
//                   ],
//                 ),
//               ),
//             ),
//
//             if (hasError)
//               Padding(
//                 padding: const EdgeInsets.only(left: 12, top: 6),
//                 child: Text(
//                   state.errorText ?? '',
//                   style: const TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
