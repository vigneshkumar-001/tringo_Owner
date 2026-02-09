import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tringo_owner/Core/Utility/app_loader.dart';
import 'package:tringo_owner/Core/Utility/app_snackbar.dart';
import 'package:tringo_owner/Core/Widgets/bottom_navigation_bar.dart';
import 'package:tringo_owner/Presentation/Home/Screens/home_screens.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Core/Widgets/qr_scanner_page.dart';

import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Screens/subscription_screen.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';
import 'package:tringo_owner/Presentation/Home/Controller/shopContext_provider.dart';

import '../Controller/create_surprise_notifier.dart';
import '../Model/surprise_offer_list_response.dart';
import 'create_surprise_offer.dart';

class SurpriseOfferList extends ConsumerStatefulWidget {
  const SurpriseOfferList({super.key});

  @override
  ConsumerState<SurpriseOfferList> createState() => _SurpriseOfferListState();
}

class _SurpriseOfferListState extends ConsumerState<SurpriseOfferList>
    with TickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Live, 1 = Upcoming, 2 = Expired
  final Set<String> _expandedOfferIds = <String>{};

  bool _bootstrapped = false; // ✅ prevents repeated auto-calls

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialLoad(forceShopId: null);
    });
  }

  // ------------------ helpers ------------------

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Future<void> _initialLoad({String? forceShopId}) async {
    // 1) fetch shops
    // await ref.read(homeNotifierProvider.notifier).fetchShops(shopId: '');

    final homeState = ref.read(homeNotifierProvider);
    final shopsRes = homeState.shopsResponse;
    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];

    if (!mounted) return;

    if (shops.isEmpty) {
      return;
    }

    // ✅ always prefer real shopId from list / user tap
    final String sid = (forceShopId?.trim().isNotEmpty == true)
        ? forceShopId!.trim()
        : (ref.read(selectedShopProvider)?.toString().trim().isNotEmpty == true
              ? ref.read(selectedShopProvider)!.toString().trim()
              : (shops.first.id ?? '').toString().trim());

    if (sid.isEmpty) return;

    // 2) call surprise list api
    await ref
        .read(createSurpriseNotifier.notifier)
        .surpriseOfferList(shopId: sid);
  }

  Future<void> _openQrScanner() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerPage()),
    );

    if (result != null && result.isNotEmpty && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
    }
  }

  Future<void> _switchShopAndReload(dynamic shopId) async {
    final sid = (shopId ?? '').toString().trim();
    if (sid.isEmpty) return;

    // store selected shop
    ref.read(selectedShopProvider.notifier).switchShop(sid);

    await _initialLoad(forceShopId: sid);
  }

  void _onTabTap(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
  }

  void _toggleExpanded(String offerId) {
    setState(() {
      if (_expandedOfferIds.contains(offerId)) {
        _expandedOfferIds.remove(offerId);
      } else {
        _expandedOfferIds.add(offerId);
      }
    });
  }

  // ------------------ Call/WhatsApp helpers ------------------

  Map<String, dynamic> _claimerToMap(ClaimerPreview c) {
    try {
      final m = (c as dynamic).toJson();
      if (m is Map<String, dynamic>) return m;
    } catch (_) {}
    return {};
  }

  String? _findFirstStringByKeys(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  String? _findAnyPhoneLikeString(Map<String, dynamic> m) {
    final preferred = _findFirstStringByKeys(m, [
      'contact',
      'phone',
      'phoneNumber',
      'mobile',
      'mobileNumber',
      'whatsapp',
      'whatsappNumber',
      'call',
      'callNumber',
      'number',
    ]);

    final p = _normalizePhoneForIndia(preferred);
    if (p != null) return p;

    for (final e in m.entries) {
      final v = e.value;
      if (v is String) {
        final d = _normalizePhoneForIndia(v);
        if (d != null && d.length >= 10) return d;
      }
    }
    return null;
  }

  String _digitsOnly(String? v) => (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  String? _normalizePhoneForIndia(String? raw) {
    final d = _digitsOnly(raw);
    if (d.isEmpty) return null;

    // If 10-digit number, assume India and add 91
    if (d.length == 10) return '91$d';

    // If starts with 0 and then 10 digits (0xxxxxxxxxx)
    if (d.length == 11 && d.startsWith('0')) return '91${d.substring(1)}';

    // Otherwise assume already has country code
    return d;
  }

  String? _phoneFromClaimer(ClaimerPreview c) {
    // 1) direct fields (your current logic)
    final p1 = _normalizePhoneForIndia(c.contact);
    if (p1 != null) return p1;

    final cu = (c.callUri ?? '').trim();
    if (cu.isNotEmpty) {
      final s = cu.startsWith('tel:') ? cu.substring(4) : cu;
      final p2 = _normalizePhoneForIndia(s);
      if (p2 != null) return p2;
    }

    final wu = (c.whatsappUri ?? '').trim();
    if (wu.isNotEmpty) {
      final match = RegExp(r'(wa\.me\/|phone=)(\+?\d+)').firstMatch(wu);
      if (match != null) {
        final p3 = _normalizePhoneForIndia(match.group(2));
        if (p3 != null) return p3;
      }
      final d = _normalizePhoneForIndia(wu);
      if (d != null) return d;
    }

    // ✅ 2) fallback: auto-detect from toJson map
    final map = _claimerToMap(c);

    final callUriFromMap = _findFirstStringByKeys(map, [
      'callUri',
      'call_url',
      'callURL',
    ]);
    if ((callUriFromMap ?? '').isNotEmpty) {
      final s = callUriFromMap!.startsWith('tel:')
          ? callUriFromMap.substring(4)
          : callUriFromMap;
      final p = _normalizePhoneForIndia(s);
      if (p != null) return p;
    }

    final waUriFromMap = _findFirstStringByKeys(map, [
      'whatsappUri',
      'whatsapp_url',
      'whatsappURL',
    ]);
    if ((waUriFromMap ?? '').isNotEmpty) {
      final match = RegExp(
        r'(wa\.me\/|phone=)(\+?\d+)',
      ).firstMatch(waUriFromMap!);
      if (match != null) {
        final p = _normalizePhoneForIndia(match.group(2));
        if (p != null) return p;
      }
    }

    return _findAnyPhoneLikeString(map);
  }

  Uri? _safeParseWhatsApp(String raw, {required String message}) {
    var s = raw.trim();
    if (s.isEmpty) return null;

    // If only "wa.me/xxxx" -> add https://
    if (s.startsWith('wa.me/')) s = 'https://$s';
    if (s.startsWith('www.')) s = 'https://$s';

    // If already whatsapp scheme / http / https
    final uri = Uri.tryParse(s);
    if (uri == null) return null;

    // If it's a wa.me link but no text param, attach message
    if ((uri.host.contains('wa.me') || uri.path.contains('wa.me')) &&
        !uri.queryParameters.containsKey('text')) {
      return Uri.parse(
        '${uri.toString()}${uri.hasQuery ? '&' : '?'}text=${Uri.encodeComponent(message)}',
      );
    }

    return uri;
  }

  Future<void> _launchCallByClaimer(ClaimerPreview c) async {
    // 1) try callUri from object
    final raw = (c.callUri ?? '').trim();
    if (raw.isNotEmpty) {
      final fixed = raw.startsWith('tel:') ? raw : 'tel:${_digitsOnly(raw)}';
      final uri = Uri.tryParse(fixed);
      await _launchUriSafe(uri, errorMsg: 'Unable to open dialer');
      return;
    }

    // 2) try callUri from toJson map
    final map = _claimerToMap(c);
    final callUriFromMap = _findFirstStringByKeys(map, [
      'callUri',
      'call_url',
      'callURL',
    ]);
    if ((callUriFromMap ?? '').isNotEmpty) {
      final fixed = callUriFromMap!.startsWith('tel:')
          ? callUriFromMap
          : 'tel:${_digitsOnly(callUriFromMap)}';
      await _launchUriSafe(
        Uri.tryParse(fixed),
        errorMsg: 'Unable to open dialer',
      );
      return;
    }

    // 3) fallback: extract phone
    final phone = _phoneFromClaimer(c);
    if (phone == null) {
      await _launchUriSafe(null, errorMsg: 'Phone number not available');
      return;
    }

    await _launchUriSafe(
      Uri.parse('tel:+$phone'),
      errorMsg: 'Unable to open dialer',
    );
  }

  Future<void> _launchWhatsAppByClaimer(
    ClaimerPreview c, {
    String message = 'Hi',
  }) async {
    // 1) try whatsappUri from object
    final raw = (c.whatsappUri ?? '').trim();
    if (raw.isNotEmpty) {
      final uri = _safeParseWhatsApp(raw, message: message);
      await _launchUriSafe(uri, errorMsg: 'Unable to open WhatsApp');
      return;
    }

    // 2) try whatsappUri from toJson map
    final map = _claimerToMap(c);
    final waUriFromMap = _findFirstStringByKeys(map, [
      'whatsappUri',
      'whatsapp_url',
      'whatsappURL',
    ]);
    if ((waUriFromMap ?? '').isNotEmpty) {
      final uri = _safeParseWhatsApp(waUriFromMap!, message: message);
      await _launchUriSafe(uri, errorMsg: 'Unable to open WhatsApp');
      return;
    }

    // 3) fallback: extract phone
    final phone = _phoneFromClaimer(c);
    if (phone == null) {
      await _launchUriSafe(null, errorMsg: 'WhatsApp number not available');
      return;
    }

    // ✅ Try app scheme first (opens WhatsApp directly if installed)
    final appUri = Uri.parse(
      'whatsapp://send?phone=+$phone&text=${Uri.encodeComponent(message)}',
    );
    final okApp = await launchUrl(appUri, mode: LaunchMode.externalApplication);

    if (okApp) return;

    // ✅ fallback to wa.me
    final webUri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    await _launchUriSafe(webUri, errorMsg: 'Unable to open WhatsApp');
  }

  Future<void> _launchUriSafe(Uri? uri, {required String errorMsg}) async {
    if (uri == null) {
      if (!mounted) return;
      AppSnackBar.error(context, errorMsg); // ✅ if it needs context
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      AppSnackBar.error(context, errorMsg);
    }
  }

  // ------------------ build ------------------

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    ref.watch(subscriptionNotifier);

    final offerState = ref.watch(createSurpriseNotifier);
    final SurpriseOfferListResponse? resp =
        offerState.surpriseOfferListResponse;
    final bool isLoading = offerState.isLoading == true;
    final String? error = offerState.error;

    // ✅ shops
    final shopsRes = homeState.shopsResponse;
    final List<dynamic> shops =
        (shopsRes?.data.items as List?)?.toList() ?? <dynamic>[];
    final dynamic mainShop = shops.isNotEmpty ? shops.first : null;

    // ✅ data
    final data = resp?.data;

    final liveCount = data?.liveCount ?? 0;
    final upcomingCount = data?.upcomingCount ?? 0;
    final expiredCount = data?.expiredCount ?? 0;

    final List<OfferSection> sections = (_selectedTab == 0)
        ? (data?.liveSections ?? const [])
        : (_selectedTab == 1)
        ? (data?.upcomingSections ?? const [])
        : (data?.expiredSections ?? const []);

    // ✅ if first open and no data yet, auto load once
    if (!_bootstrapped &&
        resp == null &&
        !isLoading &&
        (error ?? '').trim().isEmpty) {
      _bootstrapped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _initialLoad(forceShopId: null);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _initialLoad(forceShopId: null),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CommonContainer.topLeftArrow(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommonBottomNavigation(initialIndex: 0),
                      ),
                    );
                  },
                  // onTap: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 30),

              // Shops scroller
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

                                  context.push(
                                    AppRoutes.shopCategoryInfoPath,
                                    extra: {
                                      'isService': isService,
                                      'isIndividual': '',
                                      'initialShopNameEnglish':
                                          shopsRes?.data.items[0].englishName,
                                      'initialShopNameTamil':
                                          shopsRes?.data.items[0].tamilName,
                                      'isEditMode': true,
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
                              },
                              shopImage: '',
                              addAnotherShop: true,
                              shopLocation: 'Premium User can add branch',
                              shopName: 'Add Another Shop',
                            ),
                          ],
                        );
                      }

                      final shop = shops[index];
                      return Row(
                        children: [
                          CommonContainer.smallShopContainer(
                            onTap: () async => _switchShopAndReload(shop.id),
                            switchOnTap: () async =>
                                _switchShopAndReload(shop.id),
                            shopImage: shop.primaryImageUrl ?? '',
                            shopLocation: '${shop.addressEn}, ${shop.city}',
                            shopName: shop.englishName,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Header + Create
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Surprise Offers',
                        style: AppTextStyles.mulish(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateSurpriseOffer(
                              shopId: mainShop?.id.toString() ?? '',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Create',
                          style: AppTextStyles.mulish(color: AppColor.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Tabs (API counts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _tabChip(
                        title: '$liveCount Live',
                        index: 0,
                        selectedIndex: _selectedTab,
                        onTap: () => _onTabTap(0),
                      ),
                      const SizedBox(width: 10),
                      _tabChip(
                        title: '$upcomingCount Upcoming',
                        index: 1,
                        selectedIndex: _selectedTab,
                        onTap: () => _onTabTap(1),
                      ),
                      const SizedBox(width: 10),
                      _tabChip(
                        title: '$expiredCount Expired',
                        index: 2,
                        selectedIndex: _selectedTab,
                        onTap: () => _onTabTap(2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ✅ Loading / Error / Empty / List
              if (isLoading) ...[
                const SizedBox(height: 80),
                Center(child: ThreeDotsLoader(dotColor: AppColor.darkBlue)),
                const SizedBox(height: 30),
              ] else if ((error ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    error!,
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => _initialLoad(forceShopId: null),
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (resp == null) ...[
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'No data loaded',
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                // const SizedBox(height: 12),
                // Center(
                //   child: TextButton(
                //     onPressed: () => _initialLoad(forceShopId: null),
                //     child: const Text('Load'),
                //   ),
                // ),
                const SizedBox(height: 30),
              ] else if (sections.isEmpty) ...[
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    _selectedTab == 0
                        ? 'No Live Offers'
                        : _selectedTab == 1
                        ? 'No Upcoming Offers'
                        : 'No Expired Offers',
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ] else ...[
                ...List.generate(sections.length, (sIndex) {
                  final section = sections[sIndex];
                  return Column(
                    children: [
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          section.dayLabel,
                          style: AppTextStyles.mulish(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColor.darkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: List.generate(section.items.length, (i) {
                            final offer = section.items[i];
                            final expanded = _expandedOfferIds.contains(
                              offer.id,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _OfferCardApi(
                                offer: offer,
                                expanded: expanded,
                                onToggleExpanded: () =>
                                    _toggleExpanded(offer.id),
                                onCall: (c) => _launchCallByClaimer(c),
                                onWhatsApp: (c) => _launchWhatsAppByClaimer(
                                  c,
                                  message: 'Hi, regarding "${offer.title}"',
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                }),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ widgets ------------------

  Widget _tabChip({
    required String title,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.darkBlue : AppColor.borderLightGrey,
            width: 1.5,
          ),
          color: AppColor.white,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mulish(
            color: isSelected ? AppColor.darkBlue : AppColor.borderLightGrey,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ------------------ Offer Card (API) ------------------

class _OfferCardApi extends StatelessWidget {
  final OfferItem offer;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final void Function(ClaimerPreview c) onCall;
  final void Function(ClaimerPreview c) onWhatsApp;

  const _OfferCardApi({
    required this.offer,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final claimers = offer.claimers.preview;
    final visibleClaimers = expanded
        ? claimers
        : (claimers.length <= 2 ? claimers : claimers.take(2).toList());

    final bool canToggle =
        offer.claimers.canShowMore || offer.claimers.total > 2;

    final String timeLabel = (offer.createdTime.isNotEmpty)
        ? offer.createdTime
        : (offer.createdAt != null
              ? DateFormat('h.mm a').format(offer.createdAt!.toLocal())
              : '-');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Optional banner
          if ((offer.bannerUrl ?? '').trim().isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Image.network(
                  offer.bannerUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE6EEE4),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          Text(
            offer.title,
            style: AppTextStyles.mulish(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            offer.description,
            style: AppTextStyles.mulish(
              fontSize: 12,
              height: 1.5,
              color: AppColor.gray84,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              InkWell(
                onTap: offer.editable ? () {} : null,
                child: Opacity(
                  opacity: offer.editable ? 1.0 : 0.4,
                  child: Container(
                    height: 40,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              DashedPill(text: timeLabel),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _InfoCard(
                title: "Coupons",
                valueBold: offer.coupons.claimed.toString(),
                valueLight: offer.coupons.total.toString(),
                trailing: null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _InfoCards(
                  title: "Available Range",
                  valueBold: _rangeStart(offer.availableRangeLabel),
                  valueLight: _rangeEnd(offer.availableRangeLabel),
                  trailing: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Text(
            "Claimers",
            style: AppTextStyles.mulish(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4EF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  if (visibleClaimers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "No claimers yet",
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.darkGrey,
                        ),
                      ),
                    )
                  else
                    ...List.generate(visibleClaimers.length, (i) {
                      final c = visibleClaimers[i];
                      final name = (c.displayName ?? '').trim().isEmpty
                          ? "Customer"
                          : c.displayName!.trim();
                      final isFaded = (!expanded && i == 1);

                      return Padding(
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          bottom: i == visibleClaimers.length - 1 ? 0 : 12,
                        ),
                        child: _ClaimerTile(
                          name: name,
                          time: c.claimedLabel,
                          faded: isFaded,
                          onCall: () => onCall(c),
                          onWhatsApp: () => onWhatsApp(c),
                        ),
                      );
                    }),

                  const SizedBox(height: 10),

                  if (canToggle)
                    InkWell(
                      onTap: onToggleExpanded,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              expanded ? "Show Less" : "Show More",
                              style: AppTextStyles.mulish(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _rangeStart(String label) {
    final parts = label.split(' to ');
    return parts.isNotEmpty ? parts.first.trim() : label;
  }

  static String _rangeEnd(String label) {
    final parts = label.split(' to ');
    return parts.length > 1 ? parts.last.trim() : label;
  }
}

// ------------------ Cards (same as your design) ------------------

class _InfoCard extends StatelessWidget {
  final String title;
  final String valueBold;
  final String valueLight;
  final Widget? trailing;

  const _InfoCard({
    required this.title,
    required this.valueBold,
    required this.valueLight,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.mulish(
                  fontSize: 12,
                  color: const Color(0xFF8B8B8B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: valueBold,
                      style: AppTextStyles.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: " Out of ",
                      style: AppTextStyles.mulish(
                        fontSize: 14,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                    TextSpan(
                      text: valueLight,
                      style: AppTextStyles.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _InfoCards extends StatelessWidget {
  final String title;
  final String valueBold;
  final String valueLight;
  final Widget? trailing;

  const _InfoCards({
    required this.title,
    required this.valueBold,
    required this.valueLight,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    color: const Color(0xFF8B8B8B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: valueBold,
                        style: AppTextStyles.mulish(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: " to ",
                        style: AppTextStyles.mulish(
                          fontSize: 11,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                      TextSpan(
                        text: valueLight,
                        style: AppTextStyles.mulish(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 1),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ClaimerTile extends StatelessWidget {
  final String name;
  final String time;
  final bool faded;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  const _ClaimerTile({
    required this.name,
    required this.time,
    required this.faded,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.45 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBF6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: AppTextStyles.mulish(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9A9A9A),
                    ),
                  ),
                ],
              ),
            ),
            _RoundActionButton(
              bg: Colors.black,
              child: Image.asset(AppImages.call, height: 16),
              onTap: onCall,
            ),
            const SizedBox(width: 12),
            _RoundActionButton(
              bg: const Color(0xFF2DBE60),
              child: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 18,
              ),
              onTap: onWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final Color bg;
  final Widget child;
  final VoidCallback onTap;

  const _RoundActionButton({
    required this.bg,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 35,
        width: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ------------------ Dashed Pill ------------------

class DashedPill extends StatelessWidget {
  final String text;
  const DashedPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFCFCFCF),
        radius: 22,
        dashWidth: 4,
        dashSpace: 2,
        strokeWidth: 1.2,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          text,
          style: AppTextStyles.mulish(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();

    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final len = dashWidth;
        final next = dist + len;
        canvas.drawPath(m.extractPath(dist, next.clamp(0, m.length)), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
