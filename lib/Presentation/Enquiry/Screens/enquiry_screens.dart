import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/call_helper.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';

import '../../../Api/Repository/api_url.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Home/Controller/shopContext_provider.dart';
import '../../Home/Model/shops_response.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';

class EnquiryScreens extends ConsumerStatefulWidget {
  const EnquiryScreens({super.key});

  @override
  ConsumerState<EnquiryScreens> createState() => _EnquiryScreensState();
}

class _EnquiryScreensState extends ConsumerState<EnquiryScreens> {
  int selectedIndex = 0; // 0 = Unanswered, 1 = Answered
  bool _isDownloading = false;

  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';
  final GlobalKey _filterKey = GlobalKey();

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  // ===================== SMART CONNECT REPLY STATE =====================
  static const int _maxMsgLen = 500;

  final ImagePicker _picker = ImagePicker();

  // per-enquiry states
  final Map<String, bool> _adsOpenMap = {}; // enquiryId -> reply form open?
  final Map<String, bool> _sendingMap = {}; // enquiryId -> is sending?
  final Map<String, TextEditingController> _msgCtrls = {};
  final Map<String, TextEditingController> _priceCtrls = {};
  final Map<String, XFile?> _pickedMap = {};

  bool _isAdsEnabled(String enquiryId) => _adsOpenMap[enquiryId] ?? false;

  void _enableAds(String enquiryId) {
    setState(() {
      _adsOpenMap[enquiryId] = true;
    });
  }

  bool _isSending(String enquiryId) => _sendingMap[enquiryId] ?? false;

  void _setSending(String enquiryId, bool value) {
    if (!mounted) return;
    setState(() {
      _sendingMap[enquiryId] = value;
    });
  }

  TextEditingController _getMsgCtrl(String enquiryId) {
    return _msgCtrls.putIfAbsent(enquiryId, () => TextEditingController());
  }

  TextEditingController _getPriceCtrl(String enquiryId) {
    return _priceCtrls.putIfAbsent(enquiryId, () => TextEditingController());
  }

  XFile? _getPicked(String enquiryId) => _pickedMap[enquiryId];

  void _setPicked(String enquiryId, XFile? x) {
    setState(() {
      _pickedMap[enquiryId] = x;
    });
  }

  void _removeImage(String enquiryId) {
    setState(() {
      _pickedMap.remove(enquiryId);
    });
  }

  Future<void> _showPickOptions(String enquiryId) async {
    // Bottom sheet: Camera / Gallery
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColor.lightGray,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final x = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (x != null) _setPicked(enquiryId, x);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final x = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (x != null) _setPicked(enquiryId, x);
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (final c in _msgCtrls.values) {
      c.dispose();
    }
    for (final c in _priceCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ===================== QR =====================
  Future<void> _openQrScanner() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerPage()),
      );

      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  // ===================== PDF =====================
  Future<void> downloadPDFs() async {
    final url =
        "${ApiUrl.base}api/v1/dashboard/enquiries/export?format=pdf&sessionToken=8e978bad-cdd4-408d-8b37-b3dbd40f514b";

    try {
      Directory dir;

      if (Platform.isAndroid) {
        dir = Directory("/storage/emulated/0/Download");
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final path =
          "${dir.path}/enquiry_${DateTime.now().millisecondsSinceEpoch}.pdf";

      await Dio().download(
        url,
        path,
        options: Options(responseType: ResponseType.bytes),
      );

      // ignore: avoid_print
      print("Saved: $path");
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
  }

  Future<void> openPdfInChrome() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('sessionToken') ?? '';

    final String urlString = ApiUrl.enguiriesDownload(
      sessionToken: sessionToken,
    );
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  // ===================== DATE FILTER =====================
  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime? _parseEnquiryDate(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso.toLocal();

    final formats = <DateFormat>[
      DateFormat("dd MMM yyyy"),
      DateFormat("dd MMM yyyy, hh:mm a"),
      DateFormat("yyyy-MM-dd"),
      DateFormat("yyyy-MM-dd HH:mm:ss"),
    ];

    for (final f in formats) {
      try {
        return f.parse(raw, true).toLocal();
      } catch (_) {}
    }
    return null;
  }

  Future<void> _openDateFilterSheet() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.lightGray,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              _sheetItem('Today', () => Navigator.pop(context, 'Today')),
              _sheetItem(
                'Yesterday',
                () => Navigator.pop(context, 'Yesterday'),
              ),
              _sheetItem(
                'Custom Date',
                () => Navigator.pop(context, 'Custom Date'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (res == null) return;

    if (res == 'Today') {
      setState(() {
        selectedDay = 'Today';
        selectedDate = DateTime.now();
      });
    } else if (res == 'Yesterday') {
      setState(() {
        selectedDay = 'Yesterday';
        selectedDate = DateTime.now().subtract(const Duration(days: 1));
      });
    } else if (res == 'Custom Date') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: AppColor.white,
              colorScheme: ColorScheme.light(
                primary: AppColor.strongBlue,
                onPrimary: AppColor.iceBlue,
                onSurface: AppColor.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.strongBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
          selectedDay = _fmt(picked);
        });
      }
    }
  }

  Widget _sheetItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.mulish(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColor.black,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    final enquiry = homeState.enquiryResponse;
    final shopsRes = homeState.shopsResponse;

    final List<Shop> shops = shopsRes?.data.items ?? [];
    final bool hasShops = shops.isNotEmpty;
    final bool hasEnquiries =
        (enquiry?.data.open.items ?? []).isNotEmpty ||
        (enquiry?.data.closed.items ?? []).isNotEmpty;

    final enquiryData = enquiry?.data;

    final openItems = enquiryData?.open.items ?? [];
    final closedItems = enquiryData?.closed.items ?? [];

    final filteredOpenItems = openItems.where((e) {
      final dt = _parseEnquiryDate(e.createdDate);
      if (dt == null) return false;
      return _isSameDate(dt, selectedDate);
    }).toList();

    final filteredClosedItems = closedItems.where((e) {
      final dt = _parseEnquiryDate(e.createdDate);
      if (dt == null) return false;
      return _isSameDate(dt, selectedDate);
    }).toList();

    final unansweredCount = filteredOpenItems.length;
    final answeredCount = filteredClosedItems.length;

    final bool isUnansweredTab = selectedIndex == 0;
    final currentItems = isUnansweredTab
        ? filteredOpenItems
        : filteredClosedItems;

    // GLOBAL NO DATA
    if (!homeState.isLoading && !hasShops && !hasEnquiries) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: NoDataScreen(
              showTopBackArrow: false,
              showBottomButton: false,
            ),
          ),
        ),
      );
    }

    final Shop? mainShop = hasShops ? shops.first : null;

    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchShops(shopId: '', filter: '');
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchAllEnquiry(shopId: '');
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: _openQrScanner,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.shadowBlue,
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  AppImages.qr_code,
                                  height: 23,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Text(
                                  (mainShop?.englishName ?? '').isNotEmpty
                                      ? mainShop!.englishName
                                      : 'My Shop',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  mainShop?.category ?? '',
                                  style: AppTextStyles.mulish(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.gray84,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MenuScreens(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: SizedBox(
                                  height: 52,
                                  width: 52,
                                  child: Image.asset(AppImages.profile),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= SHOPS STRIP =================
                    if (shops.isEmpty) ...[
                      CommonContainer.smallShopContainer(
                        shopImage: '',
                        shopLocation: '',
                        shopName: '',
                      ),
                    ] else ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: shops.length + 1,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == shops.length) {
                              return Row(
                                children: [
                                  CommonContainer.smallShopContainer(
                                    onTap: () {
                                      final isFreemium =
                                          shopsRes
                                              ?.data
                                              .subscription
                                              ?.isFreemium ??
                                          true;

                                      if (!isFreemium) {
                                        final bool isService =
                                            (shopsRes?.data.items[0].shopKind ??
                                                    '')
                                                .toUpperCase() ==
                                            'SERVICE';
                                        AppLogger.log.i(isService);

                                        context.push(
                                          AppRoutes.shopCategoryInfoPath,
                                          extra: {
                                            'isService': isService,
                                            'isIndividual': '',
                                            'initialShopNameEnglish': shopsRes
                                                ?.data
                                                .items[0]
                                                .englishName,
                                            'initialShopNameTamil': shopsRes
                                                ?.data
                                                .items[0]
                                                .tamilName,
                                            'isEditMode': true,
                                          },
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SubscriptionScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    shopImage: '',
                                    addAnotherShop: true,
                                    shopLocation: 'Premium User can add branch',
                                    shopName: 'Add Another Shop',
                                  ),
                                ],
                              );
                            }

                            final bool showSwitch = shops.length > 1;
                            final shop = shops[index];

                            return Row(
                              children: [
                                CommonContainer.smallShopContainer(
                                  showSwitch: showSwitch,
                                  onTap: () async {
                                    ref
                                        .read(selectedShopProvider.notifier)
                                        .switchShop(shop.id);
                                  },
                                  switchOnTap: () {
                                    ref
                                        .read(selectedShopProvider.notifier)
                                        .switchShop(shop.id);
                                  },
                                  shopImage: shop.primaryImageUrl ?? '',
                                  shopLocation:
                                      '${shop.addressEn}, ${shop.city}',
                                  shopName: shop.englishName,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // ================= ENQUIRIES TITLE =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Text(
                            'Enquiries',
                            style: AppTextStyles.mulish(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),

                          // Date filter
                          GestureDetector(
                            onTap: _openDateFilterSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.iceBlue,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedDay,
                                    style: AppTextStyles.mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.black,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(AppImages.filter, height: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Download/open PDF button
                          if (currentItems.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                if (_isDownloading) return;

                                setState(() => _isDownloading = true);
                                try {
                                  await openPdfInChrome();
                                  await Future.delayed(
                                    const Duration(milliseconds: 600),
                                  );
                                } catch (e) {
                                  AppSnackBar.error(
                                    context,
                                    'Failed to open PDF',
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isDownloading = false);
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 9.5,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  gradient: _isDownloading
                                      ? LinearGradient(
                                          colors: [
                                            AppColor.blueGradient1,
                                            AppColor.blueGradient2,
                                            AppColor.blueGradient1,
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [Colors.black, Colors.black],
                                        ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        axis: Axis.horizontal,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _isDownloading
                                      ? Row(
                                          key: const ValueKey('downloading'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColor.white,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Opening...',
                                              style: AppTextStyles.mulish(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColor.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          key: const ValueKey('normal'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              AppImages.downloadImage,
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= TABS =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: selectedIndex == 0
                                        ? AppColor.black
                                        : AppColor.borderLightGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$unansweredCount Unanswered',
                                    style: TextStyle(
                                      color: selectedIndex == 0
                                          ? AppColor.black
                                          : AppColor.borderLightGrey,
                                      fontWeight: selectedIndex == 0
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: selectedIndex == 1
                                        ? AppColor.black
                                        : AppColor.borderLightGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$answeredCount Answered',
                                    style: TextStyle(
                                      color: selectedIndex == 1
                                          ? AppColor.black
                                          : AppColor.borderLightGrey,
                                      fontWeight: selectedIndex == 1
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= LIST =================
                    if (currentItems.isEmpty)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No enquiries',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final data = currentItems[index];

                          // ✅ SAFE type
                          final type = (data.contextType ?? '')
                              .toString()
                              .toUpperCase();

                          String productTitle = 'Enquiry';
                          String rating = '0.0';
                          String ratingCount = '0';
                          String priceText = '';
                          String offerPrice = '';
                          String image = '';

                          // ✅ SAFE customer
                          final customer = data.customer;
                          final String customerName = customer?.name ?? '';
                          final String whatsappNumber =
                              customer?.whatsappNumber ?? '';
                          final String phone = customer?.phone ?? '';
                          final String customerImg = customer?.avatarUrl ?? '';
                          final String timeText = data.createdTime ?? '';

                          // ---------- context mapping ----------
                          if (type == 'PRODUCT_SHOP' ||
                              type == 'SERVICE_SHOP') {
                            final shop = data.shop;

                            final shopNameUpper = (shop?.englishName ?? '')
                                .toUpperCase();
                            productTitle = shopNameUpper.isNotEmpty
                                ? shopNameUpper
                                : 'Shop Enquiry';

                            rating = (shop?.rating ?? 0).toString();
                            ratingCount = (shop?.ratingCount ?? 0).toString();
                            offerPrice = (shop?.category ?? '').toUpperCase();
                            image = shop?.primaryImageUrl ?? '';
                          } else if (type == 'PRODUCT_SERVICE' ||
                              type == 'SERVICE_SHOP') {
                            final service = data.service;

                            final serviceName = (service?.name ?? '').trim();
                            productTitle = serviceName.isNotEmpty
                                ? serviceName
                                : 'Service Enquiry';

                            rating = (service?.rating ?? 0).toString();
                            ratingCount = (service?.ratingCount ?? 0)
                                .toString();
                            image = (service?.primaryImageUrl ?? '').toString();

                            final startsAt = service?.startsAt ?? 0;
                            if (startsAt > 0) {
                              priceText = 'From ₹$startsAt';
                            } else {
                              priceText = 'Service';
                            }
                          } else if (type == 'PRODUCT') {
                            productTitle = (data.product?.name ?? '')
                                .toString();
                            priceText = '${data.product?.price ?? ''}';
                            offerPrice = '₹${data.product?.offerPrice ?? ''}';
                            image = data.product?.imageUrl ?? '';
                            rating = '${data.product?.rating ?? 0}';
                            ratingCount = '${data.product?.ratingCount ?? 0}';
                          } else if (type == 'SERVICE') {
                            productTitle = (data.service?.name ?? '')
                                .toString();
                            offerPrice = '₹${data.service?.startsAt ?? ''}';
                            image = data.service?.primaryImageUrl ?? '';
                            rating = '${data.service?.rating ?? 0}';
                            ratingCount = '${data.service?.ratingCount ?? 0}';
                          }

                          // ---------- flags ----------
                          final enquirySource = (data.enquirySource ?? '')
                              .toString()
                              .toUpperCase();
                          final bool isSmartConnect =
                              enquirySource == 'SMART_CONNECT';

                          final status = (data.status ?? '')
                              .toString()
                              .toUpperCase();
                          final bool isClosed = status == 'CLOSED';

                          final String enquiryId = (data.id ?? '').toString();

                          // isAds = open reply-form toggle
                          final bool isAds = isSmartConnect
                              ? _isAdsEnabled(enquiryId)
                              : false;
                          final bool isSending = _isSending(enquiryId);

                          // ✅ SAFE answer parsing
                          final Map<String, dynamic>? answerMap =
                              (data.answer is Map<String, dynamic>)
                              ? (data.answer as Map<String, dynamic>)
                              : null;

                          // ✅ closed + smartconnect + has answer => show read-only answer UI
                          final bool showAnswerOnly =
                              isSmartConnect && isClosed && answerMap != null;

                          final String answerTitle = (answerMap?['title'] ?? '')
                              .toString();
                          final String answerDescription =
                              (answerMap?['description'] ?? '').toString();

                          final int answerPrice = (() {
                            final v = answerMap?['price'];
                            if (v == null) return 0;
                            if (v is int) return v;
                            return int.tryParse(v.toString()) ?? 0;
                          })();

                          final List<String> answerImages = (() {
                            final v = answerMap?['images'];
                            if (v is List) {
                              return v.map((e) => e.toString()).toList();
                            }
                            return <String>[];
                          })();

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                CommonContainer.inquiryProductCard(
                                  // ✅ smart connect flags
                                  isSmartConnect: isSmartConnect,
                                  isAds: isAds,

                                  // ✅ read-only answer details for CLOSED smart connect
                                  showAnswerOnly: showAnswerOnly,
                                  answerTitle: answerTitle,
                                  answerDescription: answerDescription,
                                  answerPrice: answerPrice,
                                  answerImages: answerImages,

                                  // ✅ reply controls only if OPEN (not closed)
                                  pickedImage: showAnswerOnly
                                      ? null
                                      : _getPicked(enquiryId),
                                  messageController: showAnswerOnly
                                      ? null
                                      : _getMsgCtrl(enquiryId),
                                  priceController: showAnswerOnly
                                      ? null
                                      : _getPriceCtrl(enquiryId),
                                  maxMessageLength: _maxMsgLen,
                                  isSending: showAnswerOnly ? false : isSending,

                                  onPickImage: showAnswerOnly
                                      ? null
                                      : () => _showPickOptions(enquiryId),
                                  onRemoveImage: showAnswerOnly
                                      ? null
                                      : () => _removeImage(enquiryId),

                                  onSendTap: showAnswerOnly
                                      ? null
                                      : () async {
                                          if (_isSending(enquiryId)) return;

                                          final msgCtrl = _getMsgCtrl(
                                            enquiryId,
                                          );
                                          final priceCtrl = _getPriceCtrl(
                                            enquiryId,
                                          );

                                          final msg = msgCtrl.text.trim();
                                          final priceStr = priceCtrl.text
                                              .trim();

                                          if (msg.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please enter message",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final price = int.tryParse(priceStr);
                                          if (price == null || price <= 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please enter valid price",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final pickedX = _getPicked(enquiryId);
                                          final File? pickedFile =
                                              pickedX == null
                                              ? null
                                              : File(pickedX.path);

                                          _setSending(enquiryId, true);
                                          try {
                                            await ref
                                                .read(
                                                  homeNotifierProvider.notifier,
                                                )
                                                .replyEnquiry(
                                                  shopId:
                                                      data.shop?.id
                                                          ?.toString() ??
                                                      '',
                                                  requestId: enquiryId,
                                                  productTitle: productTitle,
                                                  message: msg,
                                                  price: price,
                                                  ownerImageFile: pickedFile,
                                                );

                                            final st = ref.read(
                                              homeNotifierProvider,
                                            );

                                            if (st.error == null) {
                                              msgCtrl.clear();
                                              priceCtrl.clear();
                                              _removeImage(enquiryId);

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Reply sent successfully",
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    st.error ?? "Failed",
                                                  ),
                                                ),
                                              );
                                            }
                                          } finally {
                                            _setSending(enquiryId, false);
                                          }
                                        },

                                  // ✅ existing card fields
                                  questionText: data.message ?? '',
                                  productTitle: productTitle,
                                  rating: rating,
                                  ratingCount: ratingCount,
                                  priceText: offerPrice,
                                  mrpText: '$priceText',
                                  phoneImageAsset: image,
                                  avatarAsset: customerImg,
                                  customerName: customerName,
                                  timeText: timeText,

                                  // ✅ OPEN only actions
                                  onChatTap: () {
                                    if (showAnswerOnly) return;

                                    if (isSmartConnect) {
                                      _enableAds(enquiryId);
                                      return;
                                    }

                                    CallHelper.openWhatsapp(
                                      context: context,
                                      phone: whatsappNumber,
                                    );
                                    ref
                                        .read(homeNotifierProvider.notifier)
                                        .markEnquiry(enquiryId: data.id);
                                  },

                                  onCallTap: () {
                                    if (showAnswerOnly) return;
                                    if (isSmartConnect) return;

                                    CallHelper.openDialer(
                                      context: context,
                                      rawPhone: phone,
                                    );
                                    ref
                                        .read(homeNotifierProvider.notifier)
                                        .markEnquiry(enquiryId: data.id);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/call_helper.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Api/Repository/api_url.dart';
import '../../../Core/Routes/app_go_routes.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Widgets/qr_scanner_page.dart';
import '../../Home/Controller/shopContext_provider.dart';
import '../../Home/Model/shops_response.dart';
import '../../Login/controller/login_notifier.dart';
import '../../Menu/Screens/menu_screens.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiryScreens extends ConsumerStatefulWidget {
  const EnquiryScreens({super.key});

  @override
  ConsumerState<EnquiryScreens> createState() => _EnquiryScreensState();
}

class _EnquiryScreensState extends ConsumerState<EnquiryScreens> {
  int selectedIndex = 0; // 0 = Unanswered, 1 = Answered
  bool _isDownloading = false;

  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';
  final GlobalKey _filterKey = GlobalKey();

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Future<void> _openQrScanner() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerPage()),
      );

      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await ref.read(homeNotifierProvider.notifier).fetchShops();
    //   await ref.read(homeNotifierProvider.notifier).fetchAllEnquiry();
    // });
  }

  Future<void> downloadPDFs() async {
    final url =
        "${ApiUrl.base}api/v1/dashboard/enquiries/export?format=pdf&sessionToken=8e978bad-cdd4-408d-8b37-b3dbd40f514b";

    try {
      Directory dir;

      if (Platform.isAndroid) {
        dir = Directory("/storage/emulated/0/Download");
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final path =
          "${dir.path}/enquiry_${DateTime.now().millisecondsSinceEpoch}.pdf";

      await Dio().download(
        url,
        path,
        options: Options(responseType: ResponseType.bytes),
      );

      print("Saved: $path");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> openPdfInChrome() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('sessionToken') ?? '';

    // Assuming this returns a String like "https://.../enquiries/export?..."
    final String urlString = ApiUrl.enguiriesDownload(
      sessionToken: sessionToken,
    );

    final Uri url = Uri.parse(urlString);

    // Try opening in browser (Chrome if default)
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Optional: handle failure
      debugPrint("Could not launch $url");
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _parseEnquiryDate(String raw) {
    // 1) ISO parse try
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso.toLocal();

    // 2) Try common formats (தேவைப்பட்டா இன்னும் add பண்ணலாம்)
    final formats = <DateFormat>[
      DateFormat("dd MMM yyyy"),
      DateFormat("dd MMM yyyy, hh:mm a"),
      DateFormat("yyyy-MM-dd"),
      DateFormat("yyyy-MM-dd HH:mm:ss"),
    ];

    for (final f in formats) {
      try {
        return f.parse(raw, true).toLocal();
      } catch (_) {}
    }

    return null;
  }

  Future<void> _openDateFilterSheet() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.lightGray,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: 12),

              _sheetItem('Today', () => Navigator.pop(context, 'Today')),
              _sheetItem(
                'Yesterday',
                () => Navigator.pop(context, 'Yesterday'),
              ),
              _sheetItem(
                'Custom Date',
                () => Navigator.pop(context, 'Custom Date'),
              ),

              SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (res == null) return;

    if (res == 'Today') {
      setState(() {
        selectedDay = 'Today';
        selectedDate = DateTime.now();
      });
    } else if (res == 'Yesterday') {
      setState(() {
        selectedDay = 'Yesterday';
        selectedDate = DateTime.now().subtract(const Duration(days: 1));
      });
    } else if (res == 'Custom Date') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: AppColor.white,
              colorScheme: ColorScheme.light(
                primary: AppColor.strongBlue,
                onPrimary: AppColor.iceBlue,
                onSurface: AppColor.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.strongBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
          selectedDay = _fmt(picked);
        });
      }
    }
  }

  Widget _sheetItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.mulish(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColor.black,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    final enquiry = homeState.enquiryResponse;
    final shopsRes = homeState.shopsResponse;

    final List<Shop> shops = shopsRes?.data.items ?? [];
    final bool hasShops = shops.isNotEmpty;
    final bool isFreemium = shopsRes?.data.subscription?.isFreemium ?? true;
    // bool hasEnquiries = false;

    final enquiryData = enquiry?.data;

    final openItems = enquiryData?.open.items ?? [];
    final closedItems = enquiryData?.closed.items ?? [];

    final bool hasEnquiries = openItems.isNotEmpty || closedItems.isNotEmpty;

    final filteredOpenItems = openItems.where((e) {
      final dt = _parseEnquiryDate(e.createdDate);
      if (dt == null) return false;
      return _isSameDate(dt, selectedDate);
    }).toList();

    final filteredClosedItems = closedItems.where((e) {
      final dt = _parseEnquiryDate(e.createdDate);
      if (dt == null) return false;
      return _isSameDate(dt, selectedDate);
    }).toList();

    final unansweredCount = filteredOpenItems.length;
    final answeredCount = filteredClosedItems.length;

    final bool isUnansweredTab = selectedIndex == 0;
    final currentItems = isUnansweredTab
        ? filteredOpenItems
        : filteredClosedItems;

    //  GLOBAL "NO DATA FOUND" (no shops + no enquiries + not loading)
    if (!homeState.isLoading && !hasShops && !hasEnquiries) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: NoDataScreen(
              showTopBackArrow: false,
              showBottomButton: false,
            ),
          ),
        ),
      );
    }

    final Shop? mainShop = hasShops ? shops.first : null;
    return Skeletonizer(
      enabled: homeState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchShops(shopId: '', filter: '');
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchAllEnquiry(shopId: '');
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: _openQrScanner,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.shadowBlue,
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  AppImages.qr_code,
                                  height: 23,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Text(
                                  (mainShop?.englishName ?? '').isNotEmpty
                                      ? mainShop!.englishName
                                      : 'My Shop',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  mainShop?.category ?? '',
                                  style: AppTextStyles.mulish(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.gray84,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MenuScreens(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: SizedBox(
                                  height: 52,
                                  width: 52,
                                  child: Image.asset(AppImages.profile),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    if (shops.isEmpty) ...[
                      CommonContainer.smallShopContainer(
                        shopImage: '',
                        shopLocation: '',
                        shopName: '',
                      ),
                    ] else ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: shops.length + 1,
                          // itemCount: shops.length + 1,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == shops.length) {
                              return Row(
                                children: [
                                  CommonContainer.smallShopContainer(
                                    onTap: () {
                                      if (homeState
                                              .shopsResponse
                                              ?.data
                                              .subscription
                                              ?.isFreemium ==
                                          false) {
                                        final bool isService =
                                            shopsRes?.data.items[0].shopKind
                                                .toUpperCase() ==
                                            'SERVICE';
                                        AppLogger.log.i(isService);
                                        context.push(
                                          AppRoutes.shopCategoryInfoPath,
                                          extra: {
                                            'isService': isService,
                                            'isIndividual': '',
                                            'initialShopNameEnglish': shopsRes
                                                ?.data
                                                .items[0]
                                                .englishName,
                                            'initialShopNameTamil': shopsRes
                                                ?.data
                                                .items[0]
                                                .tamilName,

                                            'isEditMode':
                                                true, // ✅ pass the required parameter
                                          },
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionScreen(),
                                          ),
                                        );
                                      }

                                      // context.pushNamed(
                                      //
                                      //   AppRoutes.shopCategoryInfo,
                                      // );
                                    },
                                    shopImage: '',
                                    addAnotherShop: true,
                                    shopLocation: 'Premium User can add branch',
                                    shopName: 'Add Another Shop',
                                  ),
                                ],
                              );
                            }
                            final bool showSwitch = shops.length > 1;
                            final shop = shops[index];
                            return Row(
                              children: [
                                CommonContainer.smallShopContainer(
                                  showSwitch: showSwitch,
                                  onTap: () async {
                                    ref
                                        .read(selectedShopProvider.notifier)
                                        .switchShop(shop.id);
                                  },

                                  switchOnTap: () {
                                    ref
                                        .read(selectedShopProvider.notifier)
                                        .switchShop(shop.id);
                                  },
                                  shopImage: shop.primaryImageUrl ?? '',
                                  shopLocation:
                                      '${shop.addressEn}, ${shop.city}',
                                  shopName: shop.englishName,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],

                    SizedBox(height: 30),

                    // ================= ENQUIRIES TITLE =================
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enquiries',
                            style: AppTextStyles.mulish(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          // Date filter
                          GestureDetector(
                            onTap: _openDateFilterSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.iceBlue,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedDay,
                                    style: AppTextStyles.mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.black,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Image.asset(AppImages.filter, height: 16),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 15),

                          if (currentItems.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                if (_isDownloading) return;

                                setState(() => _isDownloading = true);

                                try {
                                  await openPdfInChrome();
                                  // Optional: small delay so animation is visible
                                  await Future.delayed(
                                    const Duration(milliseconds: 600),
                                  );
                                } catch (e) {
                                  AppSnackBar.error(
                                    context,
                                    'Failed to open PDF',
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isDownloading = false);
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 9.5,
                                ),
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  gradient: _isDownloading
                                      ? LinearGradient(
                                          colors: [
                                            AppColor.blueGradient1,
                                            AppColor.blueGradient2,
                                            AppColor.blueGradient1,
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [Colors.black, Colors.black],
                                        ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        axis: Axis.horizontal,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _isDownloading
                                      ? Row(
                                          key: ValueKey('downloading'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColor.white,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Opening...',
                                              style: AppTextStyles.mulish(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColor.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          key: ValueKey('normal'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              AppImages.downloadImage,
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          // Row(
                          //   children: [
                          //     GestureDetector(
                          //       onTap: () async {
                          //         final pickedDate = await showModalBottomSheet<DateTime>(
                          //           context: context,
                          //           backgroundColor: AppColor.white,
                          //           shape: const RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.vertical(
                          //               top: Radius.circular(20),
                          //             ),
                          //           ),
                          //           builder: (context) {
                          //             return Padding(
                          //               padding: const EdgeInsets.all(20.0),
                          //               child: Column(
                          //                 mainAxisSize: MainAxisSize.min,
                          //                 children: [
                          //                   Row(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment
                          //                             .spaceBetween,
                          //                     children: [
                          //                       Text(
                          //                         'Select Date',
                          //                         style: AppTextStyles.mulish(
                          //                           fontSize: 22,
                          //                           fontWeight: FontWeight.w800,
                          //                           color: AppColor.darkBlue,
                          //                         ),
                          //                       ),
                          //                       GestureDetector(
                          //                         onTap: () =>
                          //                             Navigator.pop(context),
                          //                         child: Container(
                          //                           decoration: BoxDecoration(
                          //                             color: AppColor.mistyRose,
                          //                             borderRadius:
                          //                                 BorderRadius.circular(
                          //                                   25,
                          //                                 ),
                          //                           ),
                          //                           padding:
                          //                               const EdgeInsets.symmetric(
                          //                                 horizontal: 17,
                          //                                 vertical: 10,
                          //                               ),
                          //                           child: Icon(
                          //                             Icons.close,
                          //                             size: 16,
                          //                             color: AppColor.red,
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                   const SizedBox(height: 15),
                          //                   CommonContainer.horizonalDivider(),
                          //
                          //                   ListTile(
                          //                     title: Text(
                          //                       'Today',
                          //                       style: AppTextStyles.mulish(
                          //                         fontSize: 16,
                          //                         fontWeight: FontWeight.w600,
                          //                         color: AppColor.darkBlue,
                          //                       ),
                          //                     ),
                          //                     onTap: () => Navigator.pop(
                          //                       context,
                          //                       DateTime.now(),
                          //                     ),
                          //                   ),
                          //
                          //                   ListTile(
                          //                     title: Text(
                          //                       'Yesterday',
                          //                       style: AppTextStyles.mulish(
                          //                         fontSize: 16,
                          //                         fontWeight: FontWeight.w600,
                          //                         color: AppColor.darkBlue,
                          //                       ),
                          //                     ),
                          //                     onTap: () => Navigator.pop(
                          //                       context,
                          //                       DateTime.now().subtract(
                          //                         const Duration(days: 1),
                          //                       ),
                          //                     ),
                          //                   ),
                          //
                          //                   ListTile(
                          //                     title: Text(
                          //                       'Custom Date',
                          //                       style: AppTextStyles.mulish(
                          //                         fontSize: 16,
                          //                         fontWeight: FontWeight.w600,
                          //                         color: AppColor.darkBlue,
                          //                       ),
                          //                     ),
                          //                     onTap: () async {
                          //                       final d = await showDatePicker(
                          //                         context: context,
                          //                         initialDate: selectedDate,
                          //                         firstDate: DateTime(2000),
                          //                         lastDate: DateTime(2100),
                          //                         builder: (context, child) {
                          //                           return Theme(
                          //                             data: Theme.of(context).copyWith(
                          //                               dialogBackgroundColor:
                          //                                   AppColor.white,
                          //                               colorScheme:
                          //                                   ColorScheme.light(
                          //                                     primary: AppColor
                          //                                         .brightBlue,
                          //                                     onPrimary:
                          //                                         Colors.white,
                          //                                     onSurface:
                          //                                         AppColor
                          //                                             .black,
                          //                                   ),
                          //                               textButtonTheme:
                          //                                   TextButtonThemeData(
                          //                                     style: TextButton.styleFrom(
                          //                                       foregroundColor:
                          //                                           AppColor
                          //                                               .brightBlue,
                          //                                     ),
                          //                                   ),
                          //                             ),
                          //                             child: child!,
                          //                           );
                          //                         },
                          //                       );
                          //
                          //                       if (d != null) {
                          //                         Navigator.pop(
                          //                           context,
                          //                           d,
                          //                         ); // ✅ IMPORTANT: close sheet + return date
                          //                       }
                          //                     },
                          //                   ),
                          //                 ],
                          //               ),
                          //             );
                          //           },
                          //         );
                          //
                          //         if (pickedDate != null) {
                          //           setState(() {
                          //             selectedDate = pickedDate;
                          //             final today = DateTime.now();
                          //             final yesterday = today.subtract(
                          //               const Duration(days: 1),
                          //             );
                          //
                          //             if (_isSameDate(pickedDate, today)) {
                          //               selectedDay = "Today";
                          //             } else if (_isSameDate(
                          //               pickedDate,
                          //               yesterday,
                          //             )) {
                          //               selectedDay = "Yesterday";
                          //             } else {
                          //               selectedDay = _fmt(pickedDate);
                          //             }
                          //           });
                          //         }
                          //
                          //         // final selected = await showModalBottomSheet<String>(
                          //         //   context: context,
                          //         //   backgroundColor: AppColor.white,
                          //         //   shape: RoundedRectangleBorder(
                          //         //     borderRadius: BorderRadius.vertical(
                          //         //       top: Radius.circular(20),
                          //         //     ),
                          //         //   ),
                          //         //   builder: (context) {
                          //         //     return Padding(
                          //         //       padding: const EdgeInsets.all(20.0),
                          //         //       child: Column(
                          //         //         mainAxisSize: MainAxisSize.min,
                          //         //         children: [
                          //         //           Row(
                          //         //             mainAxisAlignment:
                          //         //                 MainAxisAlignment
                          //         //                     .spaceBetween,
                          //         //             children: [
                          //         //               Text(
                          //         //                 'Select Date',
                          //         //                 style: AppTextStyles.mulish(
                          //         //                   fontSize: 22,
                          //         //                   fontWeight: FontWeight.w800,
                          //         //                   color: AppColor.darkBlue,
                          //         //                 ),
                          //         //               ),
                          //         //               GestureDetector(
                          //         //                 onTap: () =>
                          //         //                     Navigator.pop(context),
                          //         //                 child: Container(
                          //         //                   decoration: BoxDecoration(
                          //         //                     color: AppColor.mistyRose,
                          //         //                     borderRadius:
                          //         //                         BorderRadius.circular(
                          //         //                           25,
                          //         //                         ),
                          //         //                   ),
                          //         //                   child: Padding(
                          //         //                     padding:
                          //         //                         const EdgeInsets.symmetric(
                          //         //                           horizontal: 17,
                          //         //                           vertical: 10,
                          //         //                         ),
                          //         //                     child: Icon(
                          //         //                       size: 16,
                          //         //                       Icons.close,
                          //         //                       color: AppColor.red,
                          //         //                     ),
                          //         //                   ),
                          //         //                 ),
                          //         //               ),
                          //         //             ],
                          //         //           ),
                          //         //             SizedBox(height: 15),
                          //         //           CommonContainer.horizonalDivider(),
                          //         //           ListTile(
                          //         //             title: Text(
                          //         //               'Today',
                          //         //               style: AppTextStyles.mulish(
                          //         //                 fontSize: 16,
                          //         //                 fontWeight: FontWeight.w600,
                          //         //                 color: AppColor.darkBlue,
                          //         //               ),
                          //         //             ),
                          //         //             onTap: () => Navigator.pop(
                          //         //               context,
                          //         //               'Today',
                          //         //             ),
                          //         //           ),
                          //         //           ListTile(
                          //         //             title: Text(
                          //         //               'Yesterday',
                          //         //               style: AppTextStyles.mulish(
                          //         //                 fontSize: 16,
                          //         //                 fontWeight: FontWeight.w600,
                          //         //                 color: AppColor.darkBlue,
                          //         //               ),
                          //         //             ),
                          //         //             onTap: () => Navigator.pop(
                          //         //               context,
                          //         //               'Yesterday',
                          //         //             ),
                          //         //           ),
                          //         //           ListTile(
                          //         //             title: Text(
                          //         //               'Custom Date',
                          //         //               style: AppTextStyles.mulish(
                          //         //                 fontSize: 16,
                          //         //                 fontWeight: FontWeight.w600,
                          //         //                 color: AppColor.darkBlue,
                          //         //               ),
                          //         //             ),
                          //         //             onTap: () async {
                          //         //               final picked = await showDatePicker(
                          //         //                 context: context,
                          //         //                 initialDate: selectedDate,
                          //         //                 firstDate: DateTime(2000),
                          //         //                 lastDate: DateTime(2100),
                          //         //                 builder: (context, child) {
                          //         //                   return Theme(
                          //         //                     data: Theme.of(context).copyWith(
                          //         //                       dialogBackgroundColor:
                          //         //                           AppColor.white,
                          //         //                       colorScheme:
                          //         //                           ColorScheme.light(
                          //         //                             primary: AppColor
                          //         //                                 .brightBlue,
                          //         //                             onPrimary:
                          //         //                                 Colors.white,
                          //         //                             onSurface:
                          //         //                                 AppColor
                          //         //                                     .black,
                          //         //                           ),
                          //         //                       textButtonTheme:
                          //         //                           TextButtonThemeData(
                          //         //                             style: TextButton.styleFrom(
                          //         //                               foregroundColor:
                          //         //                                   AppColor
                          //         //                                       .brightBlue,
                          //         //                             ),
                          //         //                           ),
                          //         //                     ),
                          //         //                     child: child!,
                          //         //                   );
                          //         //                 },
                          //         //               );
                          //         //
                          //         //               if (picked != null) {
                          //         //                 setState(() {
                          //         //                   selectedDate = picked;
                          //         //                   selectedDay = _fmt(picked);
                          //         //                 });
                          //         //               }
                          //         //             },
                          //         //           ),
                          //         //         ],
                          //         //       ),
                          //         //     );
                          //         //   },
                          //         // );
                          //         //
                          //         // if (selected == 'Today') {
                          //         //   setState(() {
                          //         //     selectedDay = 'Today';
                          //         //     selectedDate = DateTime.now();
                          //         //   });
                          //         // } else if (selected == 'Yesterday') {
                          //         //   setState(() {
                          //         //     selectedDay = 'Yesterday';
                          //         //     selectedDate = DateTime.now().subtract(
                          //         //       const Duration(days: 1),
                          //         //     );
                          //         //   });
                          //         // }
                          //       },
                          //       child: Container(
                          //         padding: const EdgeInsets.symmetric(
                          //           horizontal: 12.5,
                          //           vertical: 8,
                          //         ),
                          //         decoration: BoxDecoration(
                          //           color: AppColor.iceBlue,
                          //           borderRadius: BorderRadius.circular(25),
                          //         ),
                          //         child: Image.asset(
                          //           AppImages.filter,
                          //           height: 19,
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //
                          //     if (currentItems.isNotEmpty)
                          //       GestureDetector(
                          //         onTap: () async {
                          //           if (_isDownloading) return;
                          //
                          //           setState(() => _isDownloading = true);
                          //
                          //           try {
                          //             await openPdfInChrome();
                          //             // Optional: small delay so animation is visible
                          //             await Future.delayed(
                          //               const Duration(milliseconds: 600),
                          //             );
                          //           } catch (e) {
                          //             AppSnackBar.error(
                          //               context,
                          //               'Failed to open PDF',
                          //             );
                          //           } finally {
                          //             if (mounted) {
                          //               setState(() => _isDownloading = false);
                          //             }
                          //           }
                          //         },
                          //         child: AnimatedContainer(
                          //           duration: const Duration(milliseconds: 300),
                          //           curve: Curves.easeOut,
                          //           padding: const EdgeInsets.symmetric(
                          //             horizontal: 14.5,
                          //             vertical: 9.5,
                          //           ),
                          //           margin: EdgeInsets.only(right: 8),
                          //           decoration: BoxDecoration(
                          //             gradient: _isDownloading
                          //                 ? LinearGradient(
                          //                     colors: [
                          //                       AppColor.blueGradient1,
                          //                       AppColor.blueGradient2,
                          //                       AppColor.blueGradient1,
                          //                     ],
                          //                   )
                          //                 : LinearGradient(
                          //                     colors: [
                          //                       Colors.black,
                          //                       Colors.black,
                          //                     ],
                          //                   ),
                          //             borderRadius: BorderRadius.circular(25),
                          //           ),
                          //           child: AnimatedSwitcher(
                          //             duration: const Duration(
                          //               milliseconds: 250,
                          //             ),
                          //             transitionBuilder: (child, animation) {
                          //               return FadeTransition(
                          //                 opacity: animation,
                          //                 child: SizeTransition(
                          //                   sizeFactor: animation,
                          //                   axis: Axis.horizontal,
                          //                   child: child,
                          //                 ),
                          //               );
                          //             },
                          //             child: _isDownloading
                          //                 ? Row(
                          //                     key: ValueKey('downloading'),
                          //                     mainAxisSize: MainAxisSize.min,
                          //                     children: [
                          //                       SizedBox(
                          //                         height: 18,
                          //                         width: 18,
                          //                         child:
                          //                             CircularProgressIndicator(
                          //                               strokeWidth: 2,
                          //                               color: AppColor.white,
                          //                             ),
                          //                       ),
                          //                       SizedBox(width: 6),
                          //                       Text(
                          //                         'Opening...',
                          //                         style: AppTextStyles.mulish(
                          //                           fontSize: 12,
                          //                           fontWeight: FontWeight.w700,
                          //                           color: AppColor.white,
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   )
                          //                 : Row(
                          //                     key: ValueKey('normal'),
                          //                     mainAxisSize: MainAxisSize.min,
                          //                     children: [
                          //                       Image.asset(
                          //                         AppImages.downloadImage,
                          //                         height: 15,
                          //                       ),
                          //                     ],
                          //                   ),
                          //           ),
                          //         ),
                          //       ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedIndex = 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: selectedIndex == 0
                                        ? AppColor.black
                                        : AppColor.borderLightGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$unansweredCount Unanswered',
                                    style: TextStyle(
                                      color: selectedIndex == 0
                                          ? AppColor.black
                                          : AppColor.borderLightGrey,
                                      fontWeight: selectedIndex == 0
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedIndex = 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: selectedIndex == 1
                                        ? AppColor.black
                                        : AppColor.borderLightGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$answeredCount Answered',
                                    style: TextStyle(
                                      color: selectedIndex == 1
                                          ? AppColor.black
                                          : AppColor.borderLightGrey,
                                      fontWeight: selectedIndex == 1
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (currentItems.isEmpty)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No enquiries',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final data = currentItems[index];

                          final type = data.contextType.toUpperCase();

                          String productTitle = 'Enquiry';
                          String rating = '0.0';
                          String ratingCount = '0';
                          String priceText = '';
                          String offerPrice = '';
                          String image = '';
                          String customerName = data.customer.name;
                          String whatsappNumber = data.customer.whatsappNumber;
                          String phone = data.customer.phone;
                          String customerImg = data.customer.avatarUrl
                              .toString();
                          String timeText = data.createdTime;

                          if (type == 'PRODUCT_SHOP' ||
                              type == 'SERVICE_SHOP') {
                            final shop = data.shop;
                            productTitle =
                                (shop?.englishName.toUpperCase() ?? '')
                                    .isNotEmpty
                                ? shop!.englishName.toUpperCase()
                                : 'Shop Enquiry';
                            rating = (shop?.rating ?? 0).toString();
                            ratingCount = (shop?.ratingCount ?? 0).toString();
                            offerPrice =
                                '${shop?.category.toUpperCase() ?? ''}';
                            image = shop?.primaryImageUrl ?? '';
                          } else if (type == 'PRODUCT_SERVICE' ||
                              type == 'SERVICE_SHOP') {
                            final service = data.service;
                            productTitle = (service?.name ?? '').isNotEmpty
                                ? service!.name
                                : 'Service Enquiry';
                            rating = (service?.rating ?? 0).toString();
                            image = (service?.primaryImageUrl ?? 0).toString();
                            ratingCount = (service?.ratingCount ?? 0)
                                .toString();
                            if (service != null && service.startsAt > 0) {
                              priceText = 'From ₹${service.startsAt}';
                            } else {
                              priceText = 'Service';
                            }
                          } else if (type == 'PRODUCT') {
                            productTitle = data.product?.name.toString() ?? '';
                            priceText = '${data.product?.price ?? ''}';
                            offerPrice = '₹${data.product?.offerPrice ?? ''}';
                            image = data.product?.imageUrl ?? '';
                            rating = '${data.product?.rating ?? ''}';
                            ratingCount = '${data.product?.ratingCount ?? ''}';
                          } else if (type == 'SERVICE') {
                            productTitle = data.service?.name.toString() ?? '';
                            offerPrice = '₹${data.service?.startsAt ?? ''}';

                            image = data.service?.primaryImageUrl ?? '';
                            rating = '${data.service?.rating ?? ''}';
                            ratingCount = '${data.service?.ratingCount ?? ''}';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                CommonContainer.inquiryProductCard(
                                  questionText: '',
                                  productTitle: productTitle,
                                  rating: rating,
                                  ratingCount: ratingCount,
                                  priceText: offerPrice,
                                  mrpText: '$priceText',
                                  phoneImageAsset: image,
                                  avatarAsset: customerImg,
                                  customerName: customerName,
                                  timeText: timeText,
                                  onChatTap: () {
                                    CallHelper.openWhatsapp(
                                      context: context,
                                      phone: whatsappNumber,
                                    );
                                    ref
                                        .read(homeNotifierProvider.notifier)
                                        .markEnquiry(enquiryId: data.id);
                                  },
                                  onCallTap: () {
                                    CallHelper.openDialer(
                                      context: context,
                                      rawPhone: phone,
                                    );
                                    ref
                                        .read(homeNotifierProvider.notifier)
                                        .markEnquiry(enquiryId: data.id);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
*/
