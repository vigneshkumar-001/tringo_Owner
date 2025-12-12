import 'package:flutter/material.dart';
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
import '../Model/create_offers.dart';
import 'offer_products.dart';

class CreateAppOffer extends ConsumerStatefulWidget {
  final String? shopId;
  final bool? isService;
  const CreateAppOffer({super.key, this.shopId, this.isService});

  @override
  ConsumerState<CreateAppOffer> createState() => _CreateAppOfferState();
}

class _CreateAppOfferState extends ConsumerState<CreateAppOffer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _offerTitleController = TextEditingController();
  final _availableDateController = TextEditingController();
  final _offerDescriptionController = TextEditingController();
  final _announcementDateController = TextEditingController();

  int percentage = 1;

  @override
  void dispose() {
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final extracted = _extractDateRange(_availableDateController.text);
    final announcementDate = convertToApiFormat(
      _announcementDateController.text.trim(),
    );

    final availableFrom = convertToApiFormat(extracted["from"]!);
    final availableTo = convertToApiFormat(extracted["to"]!);

    final notifier = ref.read(offerNotifierProvider.notifier);
    final bool isServiceFlow =
        widget.isService ??
            RegistrationProductSeivice.instance.isServiceBusiness;
    final CreateOffers? offer = await notifier.createOffer(
      shopId: widget.shopId ?? "",
      title: _offerTitleController.text.trim(),
      description: _offerDescriptionController.text.trim(),
      discountPercentage: percentage,
      availableFrom: availableFrom,
      availableTo: availableTo,
      announcementAt: announcementDate,
    );

    if (offer == null) {
      AppSnackBar.error(context, "Failed to create offer");
      return;
    }

    print("Offer ID = ${offer.data?.id}");
    print("Shop ID  = ${offer.data?.shop.id}");

    context.pushNamed(
      AppRoutes.offerProducts,
      extra: {
        'isService': isServiceFlow,
        'offerId': offer.data?.id,
        'shopId': offer.data?.shop.id,
        'type': offer.data?.nextListType ,
      },
    );

  }

  /*  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // final date = _extractDateRange(_availableDateController.text);
    final extracted = _extractDateRange(_availableDateController.text);
    final announcementDate = convertToApiFormat(
      _announcementDateController.text.trim(),
    );
    final availableFrom = convertToApiFormat(extracted["from"]!);
    final availableTo = convertToApiFormat(extracted["to"]!);
    // if (date["from"]!.isEmpty || date["to"]!.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Please select a valid date range")),
    //   );
    //   return;
    // }

    final notifier = ref.read(offerNotifierProvider.notifier);

    final id = await notifier.createOffer(
      shopId: widget.shopId ?? "",
      title: _offerTitleController.text.trim(),
      description: _offerDescriptionController.text.trim(),
      discountPercentage: percentage,
      availableFrom: availableFrom, // 11-12-2025
      availableTo: availableTo, // 15-12-2025
      announcementAt: announcementDate,
    );

    final offerState = ref.read(offerNotifierProvider);

    if (offerState.error != null) {
      AppSnackBar.error(context, offerState.error ?? '');
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(offerState.error!)));
      return;
    }

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text("Offer created successfully")));
    final bool isServiceFlow =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;
    AppLogger.log.i('IS Service : $isServiceFlow');
    context.pushNamed(
      AppRoutes.offerProducts,
      extra: {
        'isService': isServiceFlow,
        'offerId': id,         // <-- PASS ID HERE
      },
    );
  }*/

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
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter title" : null,
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
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter description" : null,
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
                                setState(() => percentage--);
                              }
                            },
                            child: _percentButton(AppImages.sub),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 40,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.leftArrow,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: Text(
                                  "$percentage%",
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColor.mildBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              setState(() => percentage++);
                            },
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
                        validator: (v) =>
                            v == null || v.isEmpty ? "Select date range" : null,
                      ),

                      SizedBox(height: 25),

                      Text(
                        "Announcement Date",
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _announcementDateController,
                        isDOB: true,
                        verticalDivider: true,
                        datePickMode: DatePickMode.single,
                        context: context,
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        validator: (v) => v == null || v.isEmpty
                            ? "Select announcement date"
                            : null,
                      ),

                      SizedBox(height: 30),

                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: _onSubmit,
                        text: offerState.isLoading
                            ? ThreeDotsLoader()
                            : Text(
                                "Next, Select Products",
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';
//
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_textstyles.dart';
// import '../../../Core/Utility/common_Container.dart';
// import '../../ShopInfo/Screens/shop_photo_info.dart';
// import 'offer_products.dart';
//
// class CreateAppOffer extends ConsumerStatefulWidget {
//   final String shopId;
//   const CreateAppOffer({super.key, required this.shopId});
//
//   @override
//   ConsumerState<CreateAppOffer> createState() => _CreateAppOfferState();
// }
//
// class _CreateAppOfferState extends ConsumerState<CreateAppOffer> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _offerTitleController = TextEditingController();
//   final TextEditingController _availableDateController =
//       TextEditingController();
//   final TextEditingController _offerDescriptionController =
//       TextEditingController();
//   final TextEditingController _announcementDateController =
//       TextEditingController();
//
//   int Percentage = 1;
//
//   @override
//   void dispose() {
//     _offerTitleController.dispose();
//     _availableDateController.dispose();
//     _offerDescriptionController.dispose();
//     _announcementDateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickDateRange() async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       final from = DateFormat('dd/MM/yyyy').format(picked.start);
//       final to = DateFormat('dd/MM/yyyy').format(picked.end);
//
//       _availableDateController.text = "$from - $to";
//     }
//   }
//
//
//   void _onSubmit() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all required fields')),
//       );
//       return;
//     }
//
//     final title = _offerTitleController.text.trim();
//     final description = _offerDescriptionController.text.trim();
//     final dateRange = _availableDateController.text.trim();
//     final announcementAt = _announcementDateController.text.trim();
//
//     // Expecting something like: "2025-01-10 - 2025-01-20"
//     String availableFrom = '';
//     String availableTo = '';
//
//     // if (dateRange.contains('-')) {
//     //   final parts = dateRange.split('-');
//     //   if (parts.length >= 2) {
//     //     availableFrom = parts[0].trim();
//     //     availableTo = parts[1].trim();
//     //   }
//     // }
//
//     if (dateRange.contains('-')) {
//       final parts = dateRange.split('-');
//       if (parts.length >= 2) {
//         availableFrom = parts[0].trim(); // "10/01/2025"
//         availableTo = parts[1].trim();   // "20/01/2025"
//       }
//     }
//
//
//     if (availableFrom.isEmpty || availableTo.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a valid date range')),
//       );
//       return;
//     }
//
//     // Call notifier
//     final notifier = ref.read(offerNotifierProvider.notifier);
//
//     await notifier.createOffer(
//       shopId: widget.shopId,
//       title: title,
//       description: description,
//       discountPercentage: Percentage,
//       availableFrom: availableFrom,
//       availableTo: availableTo,
//       announcementAt: announcementAt,
//     );
//
//     final offerState = ref.read(offerNotifierProvider);
//
//     if (offerState.error != null) {
//       // show error
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(offerState.error!)));
//       return;
//     }
//
//     // success – you already have offerState.createOffers
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Offer created successfully')));
//
//     // Now navigate to next screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => OfferProducts()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final offerState = ref.watch(offerNotifierProvider);
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 16,
//                   ),
//                   child: CommonContainer.topLeftArrow(
//                     onTap: () => Navigator.pop(context),
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(AppImages.registerBCImage),
//                       fit: BoxFit.cover,
//                     ),
//                     gradient: LinearGradient(
//                       colors: [AppColor.scaffoldColor, AppColor.papayaWhip],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     borderRadius: BorderRadius.only(
//                       bottomRight: Radius.circular(30),
//                       bottomLeft: Radius.circular(30),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Image.asset(AppImages.appOffer, height: 154),
//                       Text(
//                         'Create App Offer',
//                         style: AppTextStyles.mulish(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.mildBlack,
//                         ),
//                       ),
//                       SizedBox(height: 35),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'App Offer Title',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         verticalDivider: false,
//                         controller: _offerTitleController,
//                         validator: (value) => value == null || value.isEmpty
//                             ? 'Please enter App Offer Title'
//                             : null,
//                       ),
//                       SizedBox(height: 25),
//                       Text(
//                         'App Offer Description',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         maxLine: 4,
//                         verticalDivider: false,
//                         controller: _offerDescriptionController,
//                         validator: (value) => value == null || value.isEmpty
//                             ? 'Please enter App Offer Description'
//                             : null,
//                       ),
//                       SizedBox(height: 25),
//                       CommonContainer.containerTitle(
//                         context: context,
//                         title: 'App Offer Percentage',
//                         image: AppImages.iImage,
//                         infoMessage:
//                             'Please upload a clear photo of your shop signboard showing the name clearly.',
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         children: [
//                           InkWell(
//                             // onTap: () {
//                             //   if (Percentage > 0) {
//                             //     setState(() {
//                             //       Percentage -=
//                             //           5; // reduce by 5% or any step you want
//                             //       if (Percentage < 0) Percentage = 0;
//                             //     });
//                             //   }
//                             // },
//                             onTap: () {
//                               if (Percentage > 1) {
//                                 setState(() {
//                                   Percentage--;
//                                 });
//                               }
//                             },
//                             borderRadius: BorderRadius.circular(11),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.leftArrow,
//                                 borderRadius: BorderRadius.circular(11),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 22,
//                                   vertical: 20,
//                                 ),
//                                 child: Image.asset(AppImages.sub, width: 20),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(11),
//                                 color: AppColor.leftArrow,
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 60,
//                                   vertical: 20,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '$Percentage%',
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 16,
//                                       color: AppColor.mildBlack,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           InkWell(
//                             // onTap: () {
//                             //   setState(() {
//                             //     Percentage +=
//                             //         5; // increase by 5% or whatever increment you prefer
//                             //     if (Percentage > 100)
//                             //       Percentage = 100; // max limit
//                             //   });
//                             // },
//                             onTap: () {
//                               setState(() {
//                                 Percentage++;
//                               });
//                             },
//                             borderRadius: BorderRadius.circular(11),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.leftArrow,
//                                 borderRadius: BorderRadius.circular(11),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 22,
//                                   vertical: 20,
//                                 ),
//                                 child: Image.asset(
//                                   AppImages.addPlus,
//                                   width: 20,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 25),
//                       Row(
//                         children: [
//                           Text(
//                             'Available Date',
//                             style: AppTextStyles.mulish(
//                               color: AppColor.mildBlack,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             '( Start to End Date )',
//                             style: AppTextStyles.mulish(
//                               color: AppColor.mediumLightGray,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         imagePath: AppImages.dob,
//                         imageWidth: 20,
//                         imageHight: 25,
//                         controller: _availableDateController,
//                         context: context,
//                         datePickMode: DatePickMode.range,
//                         styledRangeText: true,
//                         validator: (value) {
//                           if ((value == null || value.isEmpty)) {
//                             return 'Please select a valid date range';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 25),
//                       Text(
//                         'Announcement Date',
//                         style: AppTextStyles.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         isDOB: true,
//                         verticalDivider: true,
//                         imagePath: AppImages.dob,
//                         imageWidth: 20,
//                         imageHight: 25,
//                         datePickMode: DatePickMode.single,
//                         controller: _announcementDateController,
//                         context: context,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select Announcement Date';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       SizedBox(height: 30),
//                       CommonContainer.button(
//                         buttonColor: AppColor.black,
//                         onTap: _onSubmit,
//                         text: offerState.isLoading
//                             ? ThreeDotsLoader()
//                             : Text(
//                                 'Next, Select Products',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                         imagePath: offerState.isLoading
//                             ? null
//                             : AppImages.rightStickArrow,
//                         imgHeight: 20,
//                       ),
//                       SizedBox(height: 36),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
