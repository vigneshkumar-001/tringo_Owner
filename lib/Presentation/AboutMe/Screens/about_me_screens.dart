import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';
import 'package:tringo_owner/Core/Utility/app_loader.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Presentation/AboutMe/Controller/about_me_notifier.dart';
import 'package:tringo_owner/Presentation/AboutMe/Model/shop_root_response.dart';
import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';

import '../../../Core/Const/app_color.dart';

import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/common_Container.dart';
import '../../AddProduct/Controller/product_notifier.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../Home/Controller/shopContext_provider.dart';
import '../../Menu/Screens/subscription_screen.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';
import '../../ShopInfo/Screens/shop_photo_info.dart';

class AboutMeScreens extends ConsumerStatefulWidget {
  const AboutMeScreens({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<AboutMeScreens> createState() => _AboutMeScreensState();
}

enum AnalyticsFilter { day, week, month, year }

extension AnalyticsFilterX on AnalyticsFilter {
  String get api {
    switch (this) {
      case AnalyticsFilter.day:
        return "DAY";
      case AnalyticsFilter.week:
        return "WEEK";
      case AnalyticsFilter.month:
        return "MONTH";
      case AnalyticsFilter.year:
        return "YEAR";
    }
  }

  String get label {
    switch (this) {
      case AnalyticsFilter.day:
        return "Day";
      case AnalyticsFilter.week:
        return "Weekly";
      case AnalyticsFilter.month:
        return "Month";
      case AnalyticsFilter.year:
        return "Yearly";
    }
  }
}

class _AboutMeScreensState extends ConsumerState<AboutMeScreens> {
  int selectedIndex = 0;
  int followersSelectedIndex = 0;

  bool _isFreemium = false;
  String? _deletingProductId;
  String? _deletingServiceId;

  final ScrollController _scrollController = ScrollController();
  String? _currentShopId;

  final tabs = [
    {'icon': AppImages.aboutMeFill, 'label': 'Shop Details'},
    {'icon': AppImages.analytics, 'label': 'Analytics'},
    {'icon': AppImages.groupPeople, 'label': 'Followers'},
  ];

  // ✅ ANALYTICS STATE
  AnalyticsFilter _analyticsFilter = AnalyticsFilter.month;
  String? _monthKey; // ex "2026-03"
  String? _weekKey; // ex "2026-01-19_2026-01-25"
  String? _yearKey; // ex "2026"
  String? _dayKey; // if backend gives

  // ✅ Month labels for YEAR axis
  static const List<String> _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab;
    Future.microtask(_init);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('currentShopId');
    final isFreemium = prefs.getBool('isFreemium') ?? false;

    if (!mounted) return;
    setState(() {
      _isFreemium = isFreemium;
      _currentShopId = (savedId != null && savedId.isNotEmpty) ? savedId : null;
    });

    await ref
        .read(aboutMeNotifierProvider.notifier)
        .fetchAllShopDetails(shopId: _currentShopId);

    ref.read(subscriptionNotifier.notifier).getCurrentPlan();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToSelected(selectedIndex);
    });

    if (selectedIndex == 2 && mounted) {
      final aboutState = ref.read(aboutMeNotifierProvider);
      await _fetchFollowersForCurrentShop(aboutState);
    }

    if (selectedIndex == 1 && mounted) {
      final st = ref.read(aboutMeNotifierProvider);
      await _fetchAnalyticsSelected(st);
    }
  }

  void _scrollToSelected(int index) {
    const itemWidth = 150.0;
    final offset = index * itemWidth - (itemWidth * 1.3);
    final max = _scrollController.position.hasContentDimensions
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    _scrollController.animateTo(
      offset.clamp(0.0, max),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _selectedBranchName(AboutMeState state) {
    final shop = _getSelectedShop(state);
    if (shop == null) return "Select Branch";
    final name = (shop.shopEnglishName ?? shop.shopTamilName ?? '').trim();
    return name.isEmpty ? "Branch" : name;
  }

  String _rangeFromFollowersChip(int i) {
    switch (i) {
      case 0:
        return "WEEK";
      case 1:
        return "MONTH";
      case 2:
      default:
        return "ALL";
    }
  }

  Future<void> _fetchFollowersForCurrentShop(AboutMeState aboutState) async {
    final shopId = _getSelectedShop(aboutState)?.shopId;
    if (shopId == null || shopId.isEmpty) return;

    await ref
        .read(aboutMeNotifierProvider.notifier)
        .fetchAllFollowerList(
          shopId: shopId,
          range: _rangeFromFollowersChip(followersSelectedIndex),
          take: 20,
          skip: 0,
        );
  }

  Shop? _getSelectedShop(AboutMeState aboutState) {
    final response = aboutState.shopRootResponse;
    if (response == null || response.data.isEmpty) return null;

    final shops = response.data;
    if (_currentShopId == null) return shops.first;

    return shops.firstWhere(
      (s) => s.shopId == _currentShopId,
      orElse: () => shops.first,
    );
  }

  // ==========================================================
  // ✅ ANALYTICS HELPERS (CLEAN + FIXED)
  // ==========================================================

  void _syncAnalyticsDefaultsFromApi(AboutMeState state) {
    final data = state.shopAnalyticsResponse?.data;
    if (data == null) return;

    final active = data.active;
    final selectors = data.selectors;

    _monthKey ??=
        active?.month ??
        ((selectors?.months.isNotEmpty == true)
            ? selectors!.months.first.key
            : null);

    _weekKey ??=
        active?.week ??
        ((selectors?.weeks.isNotEmpty == true)
            ? selectors!.weeks.first.key
            : null);

    _yearKey ??=
        active?.year ??
        ((selectors?.years.isNotEmpty == true)
            ? selectors!.years.last.key
            : null);

    _dayKey ??= active?.day;
  }

  Future<void> _fetchAnalyticsSelected(AboutMeState state) async {
    final shopId = _currentShopId ?? _getSelectedShop(state)?.shopId;
    if (shopId == null || shopId.isEmpty) return;

    final monthsParam = (_analyticsFilter == AnalyticsFilter.month)
        ? (_monthKey ?? '')
        : '';

    await ref
        .read(aboutMeNotifierProvider.notifier)
        .fetchAnalytics(
          shopId: shopId,
          months: monthsParam, // ✅ only for MONTH (as per your backend)
          filter: _analyticsFilter.api,
        );
  }

  // ✅ Days in month from "YYYY-MM" (Feb auto 28/29)
  int _daysInMonthFromKey(String? monthKey) {
    if (monthKey == null || monthKey.trim().isEmpty) return 30;
    try {
      final parts = monthKey.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final first = DateTime(y, m, 1);
      final next = DateTime(y, m + 1, 1);
      return next.difference(first).inDays;
    } catch (_) {
      return 30;
    }
  }

  // ✅ Detect if WEEK series is W1..W4 style
  bool _isWeekBucketSeries(List series) {
    if (series.isEmpty) return false;
    bool ok = true;
    for (final it in series) {
      final lbl = (it.label ?? '').toString().trim().toUpperCase();
      if (!RegExp(r'^W\d+$').hasMatch(lbl)) {
        ok = false;
        break;
      }
    }
    // Usually your backend WEEK returns 4 items (W1..W4)
    return ok;
  }

  // ✅ Pad series to fixed length (MONTH=days, YEAR=12) ONLY
  List _padSeriesToLength(List series, int neededLen) {
    if (series.length >= neededLen) return series.take(neededLen).toList();
    final padded = [...series];
    for (int i = series.length; i < neededLen; i++) {
      padded.add(_FakeSeriesItem(value: 0, label: '${i + 1}'));
    }
    return padded;
  }

  // ✅ Parse month index from item.key ("YYYY-MM") or item.label ("Apr"/"04")
  int? _monthIndexFromSeriesItem(dynamic item) {
    final key = (item.key ?? '').toString().trim();
    final lbl = (item.label ?? '').toString().trim();

    if (key.length >= 7 && key.contains('-')) {
      final parts = key.split('-');
      if (parts.length >= 2) {
        final mm = int.tryParse(parts[1]);
        if (mm != null && mm >= 1 && mm <= 12) return mm - 1;
      }
    }

    final idxName = _monthShort.indexWhere(
      (m) => m.toLowerCase() == lbl.toLowerCase(),
    );
    if (idxName != -1) return idxName;

    final mm2 = int.tryParse(lbl);
    if (mm2 != null && mm2 >= 1 && mm2 <= 12) return mm2 - 1;

    return null;
  }

  // ✅ YEAR normalization: always 12 items (Jan..Dec), missing months => 0
  List<_FakeSeriesItem> _normalizeYearSeries(List rawSeries) {
    final values = List<int>.filled(12, 0);
    for (final it in rawSeries) {
      final idx = _monthIndexFromSeriesItem(it);
      if (idx == null) continue;
      final v = ((it.value ?? 0) as num).toInt();
      values[idx] = v;
    }

    return List.generate(
      12,
      (i) => _FakeSeriesItem(value: values[i], label: _monthShort[i]),
    );
  }

  // ✅ Build X labels based on filter (WEEK fix: show W1..W4 if bucket series)
  List<String> _buildXAxisLabelsForCurrentFilter({
    required dynamic data,
    required List series,
  }) {
    switch (_analyticsFilter) {
      case AnalyticsFilter.month:
        final days = _daysInMonthFromKey(_monthKey ?? data?.active?.month);
        return List.generate(days, (i) => '${i + 1}'); // 1..31

      case AnalyticsFilter.week:
        // ✅ YOUR API gives W1..W4 (bucket weeks) -> show W1..W4 in UI
        if (_isWeekBucketSeries(series)) {
          return List.generate(series.length, (i) {
            final dynamic it = series[i];
            final lbl = (it.label ?? '').toString().trim();
            return lbl.isEmpty ? 'W${i + 1}' : lbl;
          });
        }
        // fallback: show dates if it is a 7-day series
        final key = (_weekKey ?? data?.active?.week ?? '').toString();
        final parts = key.split('_');
        if (parts.length == 2) {
          try {
            final start = DateTime.parse(parts[0]);
            return List.generate(
              7,
              (i) => DateFormat('d').format(start.add(Duration(days: i))),
            );
          } catch (_) {}
        }
        return _labelsFromSeries(series);

      case AnalyticsFilter.year:
        // ✅ always show Jan..Dec
        return _monthShort;

      case AnalyticsFilter.day:
        return _labelsFromSeries(series);
    }
  }

  List<FlSpot> _spotsFromSeries(List series) {
    if (series.isEmpty) return [];
    return List.generate(series.length, (i) {
      final dynamic item = series[i];
      final v = ((item.value ?? 0) as num).toDouble();
      return FlSpot(i.toDouble(), v);
    });
  }

  List<String> _labelsFromSeries(List series) {
    if (series.isEmpty) return [];
    return List.generate(series.length, (i) {
      final dynamic item = series[i];
      final lbl = (item.label ?? '').toString().trim();
      return lbl.isEmpty ? '${i + 1}' : lbl;
    });
  }

  List<FlSpot> _ensureMin2(List<FlSpot> spots) {
    if (spots.isEmpty) return const [];
    if (spots.length == 1) {
      return [spots.first, FlSpot(spots.first.x + 1, spots.first.y)];
    }
    return spots;
  }

  LineChartData _trendChartData(
    Color blue,
    List<FlSpot> spots,
    List<String> xLabels,
  ) {
    final maxY = spots.map((e) => e.y).fold<double>(0, (p, v) => v > p ? v : p);
    final safeMaxY = maxY <= 0 ? 10.0 : (maxY * 1.2);

    final int interval = (_analyticsFilter == AnalyticsFilter.month)
        ? 1
        : (spots.length <= 10)
        ? 1
        : (spots.length <= 20)
        ? 2
        : (spots.length <= 35)
        ? 3
        : 5;

    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: 0,
      maxY: safeMaxY,

      // ✅ FIX: tooltip should NOT cause hiding
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipMargin: 12,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((t) {
              final idx = t.x.toInt();
              final label = (idx >= 0 && idx < xLabels.length)
                  ? xLabels[idx]
                  : '';
              return LineTooltipItem(
                '$label : ${t.y.toInt()}',
                AppTextStyles.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColor.white,
                ),
              );
            }).toList();
          },
        ),
      ),

      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: interval.toDouble(),
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= xLabels.length) return const SizedBox.shrink();
              if (i % interval != 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 15),
                child: Text(
                  xLabels[i],
                  style: AppTextStyles.mulish(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColor.gray84,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: blue,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                blue.withOpacity(0.22),
                blue.withOpacity(0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ✅ UI (Build)
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final aboutState = ref.watch(aboutMeNotifierProvider);
    final selectedShop = _getSelectedShop(aboutState);
    final isDoorDelivery = selectedShop?.shopDoorDelivery == true;

    if (!aboutState.isLoading && selectedShop == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: NoDataScreen(
              onRefresh: () async {
                await ref
                    .read(aboutMeNotifierProvider.notifier)
                    .fetchAllShopDetails();
              },
              showBottomButton: false,
              showTopBackArrow: false,
            ),
          ),
        ),
      );
    }

    return Skeletonizer(
      enabled: aboutState.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(aboutMeNotifierProvider.notifier)
                  .fetchAllShopDetails();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShopHero(aboutState),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        if (isDoorDelivery)
                          CommonContainer.doorDelivery(
                            text: 'Door Delivery',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            textColor: AppColor.skyBlue,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      _getShopTitle(selectedShop),
                      style: AppTextStyles.mulish(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // tabs
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: List.generate(tabs.length, (index) {
                          final isSelected = selectedIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => selectedIndex = index);

                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) _scrollToSelected(index);
                                });

                                if (index == 1) {
                                  final st = ref.read(aboutMeNotifierProvider);
                                  await _fetchAnalyticsSelected(st);
                                }

                                if (index == 2) {
                                  final currentState = ref.read(
                                    aboutMeNotifierProvider,
                                  );
                                  await _fetchFollowersForCurrentShop(
                                    currentState,
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColor.white
                                      : AppColor.leftArrow,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColor.black,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      tabs[index]['icon'] as String,
                                      height: 20,
                                      color: isSelected
                                          ? AppColor.black
                                          : AppColor.gray84,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      tabs[index]['label'] as String,
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColor.black
                                            : AppColor.gray84,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSelectedContent(selectedIndex, aboutState),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(int index, AboutMeState aboutState) {
    switch (index) {
      case 0:
        return _buildShopDetails(aboutState);
      case 1:
        return _buildAnalytics(aboutState);
      case 2:
        return buildFollowersDetails(aboutState);
      default:
        return const SizedBox();
    }
  }

  // ==========================================================
  // ✅ SHOP HERO + HEADER (YOUR ORIGINAL - unchanged)
  // ==========================================================

  Future<void> _showShopPickerBottomSheet(AboutMeState aboutState) async {
    final response = aboutState.shopRootResponse;
    if (response == null || response.data.isEmpty) return;

    final shops = response.data;

    final selected = await showModalBottomSheet<Shop>(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'Select Shop',
                  style: AppTextStyles.mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: shops.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final shop = shops[index];
                    final isSelected = shop.shopId == _currentShopId;

                    final en = (shop.shopEnglishName ?? '').trim();
                    final shopAddressEn = (shop.shopAddressEn ?? '').trim();
                    final name = en.isEmpty
                        ? (shop.shopTamilName ?? 'Untitled Shop')
                        : en;

                    final city = (shop.shopCity ?? '').toString();
                    final state = (shop.shopState ?? '').toString();

                    final subtitleParts = <String>[];
                    if (shopAddressEn.isNotEmpty)
                      subtitleParts.add(shopAddressEn);
                    if (city.isNotEmpty) subtitleParts.add(city);
                    if (state.isNotEmpty) subtitleParts.add(state);

                    final subtitle = subtitleParts.join(', ');

                    return ListTile(
                      title: Text(
                        '$name - $shopAddressEn',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      subtitle: subtitle.isEmpty
                          ? null
                          : Text(
                              subtitle,
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                color: AppColor.gray84,
                              ),
                            ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColor.resendOtp,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.pop(ctx, shop),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() => _currentShopId = selected.shopId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentShopId', _currentShopId ?? '');

    AppLogger.log.i('About me shopId = $_currentShopId');

    await ref
        .read(selectedShopProvider.notifier)
        .switchShop(_currentShopId ?? '');

    await ref
        .read(aboutMeNotifierProvider.notifier)
        .fetchAllShopDetails(shopId: _currentShopId);
    await ref
        .read(aboutMeNotifierProvider.notifier)
        .fetchAllFollowerList(shopId: _currentShopId ?? '');

    if (selectedIndex == 2 && mounted) {
      final aboutStateNew = ref.read(aboutMeNotifierProvider);
      await _fetchFollowersForCurrentShop(aboutStateNew);
    }

    if (selectedIndex == 1 && mounted) {
      final st = ref.read(aboutMeNotifierProvider);
      await _fetchAnalyticsSelected(st);
    }
  }

  String _getShopTitle(Shop? shop) {
    if (shop == null) return '';
    final en = (shop.shopEnglishName ?? '').trim();
    if (en.isNotEmpty) return en;
    final ta = (shop.shopTamilName ?? '').trim();
    if (ta.isNotEmpty) return ta;
    return '';
  }

  String _getShopAddress(Shop? shop) {
    if (shop == null) return 'Address not available';

    final addrEn = (shop.shopAddressEn ?? '').trim();
    if (addrEn.isNotEmpty) return addrEn;

    final addrTa = (shop.shopAddressTa ?? '').trim();
    if (addrTa.isNotEmpty) return addrTa;

    final city = (shop.shopCity ?? '').trim();
    final state = (shop.shopState ?? '').trim();
    final country = (shop.shopCountry ?? '').trim();

    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);

    if (parts.isEmpty) return 'Address not available';
    return parts.join(', ');
  }

  String _getShopCityState(Shop? shop) {
    if (shop == null) return '';
    final address = (shop.shopAddressEn ?? '').trim();
    final city = (shop.shopCity ?? '').trim();
    final state = (shop.shopState ?? '').trim();

    final cityState = [
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ].join(', ');

    if (address.isNotEmpty && cityState.isNotEmpty)
      return '$address, $cityState';
    if (address.isNotEmpty) return address;
    return cityState;
  }

  Widget _buildShopHeaderCard(AboutMeState aboutState) {
    final selectedShop = _getSelectedShop(aboutState);
    final name = _getShopTitle(selectedShop);
    final address = _getShopAddress(selectedShop);
    final cityState = _getShopCityState(selectedShop);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () => _showShopPickerBottomSheet(aboutState),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text('- $address', overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.black.withOpacity(0.05),
                    ),
                    child: Image.asset(
                      AppImages.downArrow,
                      height: 22,
                      color: AppColor.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColor.darkGrey, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    cityState,
                    style: AppTextStyles.mulish(
                      color: AppColor.darkGrey,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // buttons row (UNCHANGED)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CommonContainer.editShopContainer(
                  text: 'Add Branch',
                  onTap: () {
                    final bool isService =
                        selectedShop?.shopKind.toString().toUpperCase() ==
                        'SERVICE';
                    if (_isFreemium == false) {
                      context.push(
                        AppRoutes.shopCategoryInfoPath,
                        extra: {
                          'isService': isService,
                          'isIndividual': '',
                          'initialShopNameEnglish':
                              selectedShop?.shopEnglishName,
                          'initialShopNameTamil': selectedShop?.shopTamilName,
                          'isEditMode': true,
                        },
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SubscriptionScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(width: 10),
                CommonContainer.editShopContainer(
                  text: 'Edit Shop Details',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.remove('product_id');
                    prefs.remove('shop_id');
                    prefs.remove('service_id');

                    final selectedShop = _getSelectedShop(aboutState);
                    if (selectedShop == null) return;

                    final bool isServiceFlow =
                        (selectedShop.shopKind?.toUpperCase() == 'SERVICE');

                    String? openTimeText;
                    String? closeTimeText;

                    final List<ShopWeeklyHour> weekly =
                        selectedShop.shopWeeklyHours;

                    if (weekly.isNotEmpty) {
                      ShopWeeklyHour firstOpen;
                      try {
                        firstOpen = weekly.firstWhere(
                          (h) =>
                              h.closed != true &&
                              (h.opensAt?.trim().isNotEmpty ?? false) &&
                              (h.closesAt?.trim().isNotEmpty ?? false),
                        );
                      } catch (_) {
                        firstOpen = weekly.first;
                      }

                      openTimeText = firstOpen.opensAt?.trim();
                      closeTimeText = firstOpen.closesAt?.trim();
                    }

                    String? ownerImageUrl;

                    if (selectedShop.shopImages.isNotEmpty) {
                      ShopImage ownerImg;
                      try {
                        ownerImg = selectedShop.shopImages.firstWhere(
                          (img) => (img.type ?? '').toUpperCase() == 'OWNER',
                        );
                      } catch (_) {
                        ownerImg = selectedShop.shopImages.first;
                      }
                      ownerImageUrl = ownerImg.url;
                    }

                    if (ownerImageUrl == null &&
                        isServiceFlow &&
                        selectedShop.services.isNotEmpty) {
                      final firstService = selectedShop.services.first;
                      if (firstService.media.isNotEmpty) {
                        final media = [...firstService.media]
                          ..sort(
                            (a, b) => (a.displayOrder ?? 999).compareTo(
                              (b.displayOrder ?? 999),
                            ),
                          );
                        ownerImageUrl = media.first.url;
                      }
                    }

                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopCategoryInfo(
                          isEditMode: true,
                          pages: "AboutMeScreens",
                          shopId: selectedShop.shopId,
                          isService: isServiceFlow,
                          isIndividual: false,
                          initialShopNameEnglish: selectedShop.shopEnglishName,
                          initialShopNameTamil: selectedShop.shopTamilName,
                          initialDescriptionEnglish:
                              selectedShop.shopDescriptionEn,
                          initialDescriptionTamil:
                              selectedShop.shopDescriptionTa,
                          initialAddressEnglish: selectedShop.shopAddressEn,
                          initialAddressTamil: selectedShop.shopAddressTa,
                          initialGps:
                              (selectedShop.shopGpsLatitude?.isNotEmpty ==
                                      true &&
                                  selectedShop.shopGpsLongitude?.isNotEmpty ==
                                      true)
                              ? "${selectedShop.shopGpsLatitude}, ${selectedShop.shopGpsLongitude}"
                              : "",
                          initialPrimaryMobile: selectedShop.shopPhone,
                          initialWhatsapp: selectedShop.shopWhatsapp,
                          initialEmail: selectedShop.shopContactEmail,
                          initialCategoryName: selectedShop.category ?? "",
                          initialCategorySlug: selectedShop.category,
                          initialSubCategoryName:
                              selectedShop.subCategory ?? "",
                          initialSubCategorySlug: selectedShop.subCategory,
                          initialDoorDeliveryText:
                              selectedShop.shopDoorDelivery == true
                              ? 'Yes'
                              : 'No',
                          initialOpenTimeText: openTimeText,
                          initialCloseTimeText: closeTimeText,
                          initialOwnerImageUrl: ownerImageUrl,
                        ),
                      ),
                    );

                    if (updated == true && mounted) {
                      await ref
                          .read(aboutMeNotifierProvider.notifier)
                          .fetchAllShopDetails(
                            shopId: _currentShopId ?? selectedShop.shopId,
                          );
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 10),
                CommonContainer.editShopContainer(
                  text: 'Edit Shop Photos',
                  onTap: () async {
                    final selectedShop = _getSelectedShop(aboutState);
                    if (selectedShop == null) return;

                    final images = List.from(selectedShop.shopImages ?? [])
                      ..sort(
                        (a, b) => (a.displayOrder ?? 0).compareTo(
                          (b.displayOrder ?? 0),
                        ),
                      );

                    final initialImageUrls = List<String?>.filled(4, null);
                    for (int i = 0; i < images.length && i < 4; i++) {
                      final url = images[i].url;
                      if (url != null && url.trim().isNotEmpty) {
                        initialImageUrls[i] = url.trim();
                      }
                    }

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopPhotoInfo(
                          pages: "AboutMeScreens",
                          shopId: selectedShop.shopId,
                          initialImageUrls: initialImageUrls,
                        ),
                      ),
                    );

                    if (!mounted) return;
                    await ref
                        .read(aboutMeNotifierProvider.notifier)
                        .fetchAllShopDetails(
                          shopId: _currentShopId ?? selectedShop.shopId,
                        );
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openShopGallery(List images, int startIndex) {
    final urls = <String>[];
    for (final img in images) {
      final u = (img.url ?? '').toString().trim();
      if (u.isNotEmpty) urls.add(u);
    }
    if (urls.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGalleryPage(
          imageUrls: urls,
          initialIndex: startIndex.clamp(0, urls.length - 1),
        ),
      ),
    );
  }

  Widget _buildShopHero(AboutMeState aboutState) {
    final shop = _getSelectedShop(aboutState);

    if (shop == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Container(
            height: 150,
            width: 310,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColor.leftArrow,
            ),
            alignment: Alignment.center,
            child: Text(
              'No shop selected',
              style: AppTextStyles.mulish(
                fontWeight: FontWeight.w600,
                color: AppColor.darkBlue,
              ),
            ),
          ),
        ),
      );
    }

    final images = List.from(shop.shopImages ?? [])
      ..sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));

    final rating = (shop.shopRating ?? 0.0);
    final reviewCount = (shop.shopReviewCount ?? 0);

    if (images.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 150,
              width: 310,
              color: AppColor.leftArrow,
              alignment: Alignment.center,
              child: Text(
                'Add shop photos to make your profile attractive',
                textAlign: TextAlign.center,
                style: AppTextStyles.mulish(
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkBlue,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Row(
            children: List.generate(images.length, (index) {
              final img = images[index];
              final url = (img.url ?? '').trim();
              final hasValidUrl = url.isNotEmpty;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == images.length - 1 ? 0 : 10,
                ),
                child: GestureDetector(
                  onTap: () => _openShopGallery(images, index),
                  child: Stack(
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(20),
                        child: hasValidUrl
                            ? CachedNetworkImage(
                                imageUrl: url,
                                height: 150,
                                width: 310,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  height: 150,
                                  width: 310,
                                  color: AppColor.leftArrow,
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: 150,
                                  width: 310,
                                  color: AppColor.leftArrow,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColor.gray84,
                                  ),
                                ),
                              )
                            : Container(
                                height: 150,
                                width: 310,
                                color: AppColor.leftArrow,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColor.gray84,
                                  size: 32,
                                ),
                              ),
                      ),
                      if (index == 0)
                        Positioned(
                          top: 20,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.scaffoldColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  AppImages.starImage,
                                  height: 9,
                                  color: AppColor.green,
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 1.5,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: AppColor.darkBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  reviewCount.toString(),
                                  style: AppTextStyles.mulish(
                                    fontSize: 12,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ✅ ANALYTICS UI (FIXED: WEEK shows W1..W4, YEAR shows Jan..Dec)
  // ==========================================================
  Widget _scrollableTrendChart({
    required Color lineColor,
    required List<FlSpot> spots,
    required List<String> xLabels,
  }) {
    if (spots.isEmpty) {
      return Container(
        height: 180,
        color: Colors.white,
        alignment: Alignment.center,
        child: Text(
          'No data',
          style: AppTextStyles.mulish(
            color: AppColor.gray84,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final safeSpots = (spots.length >= 2)
        ? spots
        : [spots.first, FlSpot(spots.first.x + 1, spots.first.y)];

    const double perPointWidth = 40;
    final double chartWidth = (safeSpots.length * perPointWidth).clamp(
      350,
      6000,
    );

    return Container(
      height: 180,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: chartWidth,
          child: LineChart(_trendChartData(lineColor, safeSpots, xLabels)),
        ),
      ),
    );
  }

  Future<void> _showBranchPickerBottomSheet(AboutMeState aboutState) async {
    final response = aboutState.shopRootResponse;
    if (response == null || response.data.isEmpty) return;

    final shops = response.data;

    final selected = await showModalBottomSheet<Shop>(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'Select Branch',
                  style: AppTextStyles.mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: shops.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final shop = shops[index];
                    final isSelected = shop.shopId == _currentShopId;

                    final name =
                        (shop.shopEnglishName ?? shop.shopTamilName ?? 'Branch')
                            .trim();
                    final addr = (shop.shopAddressEn ?? '').trim();

                    return ListTile(
                      title: Text(
                        name,
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      subtitle: addr.isEmpty
                          ? null
                          : Text(
                              addr,
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                color: AppColor.gray84,
                              ),
                            ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColor.resendOtp,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.pop(ctx, shop),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() => _currentShopId = selected.shopId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentShopId', _currentShopId ?? '');

    await ref
        .read(selectedShopProvider.notifier)
        .switchShop(_currentShopId ?? '');

    await ref
        .read(aboutMeNotifierProvider.notifier)
        .fetchAllShopDetails(shopId: _currentShopId);

    await _fetchAnalyticsSelected(ref.read(aboutMeNotifierProvider));
  }

  Widget _buildAnalytics(AboutMeState aboutState) {
    final blue = const Color(0xFF2C7BE5);

    _syncAnalyticsDefaultsFromApi(aboutState);

    final data = aboutState.shopAnalyticsResponse?.data;
    final details = data?.moreDetails;

    final total = data?.total ?? 0;
    final enquiries = details?.enquiries ?? 0;
    final locationViews = details?.locations ?? 0;
    final whatsapp = details?.whatsappMsg ?? 0;
    final directCalls = details?.directCall ?? 0;
    final userClicks = details?.userClicks ?? 0;

    final rawSeries = data?.series ?? const [];
    List series = rawSeries;

    // ✅ IMPORTANT:
    // - WEEK: do NOT force 7 days when backend sends W1..W4 (bucket weeks)
    // - YEAR: always normalize to 12 months
    if (_analyticsFilter == AnalyticsFilter.month) {
      final days = _daysInMonthFromKey(_monthKey ?? data?.active?.month);
      series = _padSeriesToLength(rawSeries, days);
    } else if (_analyticsFilter == AnalyticsFilter.year) {
      series = _normalizeYearSeries(rawSeries); // ✅ Jan..Dec always
    } else if (_analyticsFilter == AnalyticsFilter.week) {
      // keep raw (W1..W4) as is
      series = rawSeries;
    }

    final spots = _ensureMin2(_spotsFromSeries(series));
    final xLabels = _buildXAxisLabelsForCurrentFilter(
      data: data,
      series: series,
    );

    final bottomItems = _bottomSelectorItemsFromApi(data);
    final selectedKey = _selectedKeyForFilter(data);
    final showChart = spots.isNotEmpty && spots.any((e) => e.y > 0);

    return Stack(
      children: [
        Container(
          key: const ValueKey('analytics'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                AppColor.leftArrow,
                AppColor.scaffoldColor,
                AppColor.scaffoldColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  child: _buildShopHeaderCard(aboutState),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          value: _analyticsFilter,
                          onChanged: (v) async {
                            if (v == null) return;

                            setState(() => _analyticsFilter = v);

                            _syncAnalyticsDefaultsFromApi(
                              ref.read(aboutMeNotifierProvider),
                            );

                            await _fetchAnalyticsSelected(
                              ref.read(aboutMeNotifierProvider),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _BranchDropdownButton(
                          title: _selectedBranchName(
                            ref.read(aboutMeNotifierProvider),
                          ),
                          onTap: () async {
                            await _showBranchPickerBottomSheet(
                              ref.read(aboutMeNotifierProvider),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: Column(
                    children: [
                      Text(
                        '$total',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: blue,
                        ),
                      ),
                      Text(
                        'Search Impressions',
                        style: AppTextStyles.mulish(
                          color: AppColor.darkBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!showChart)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'No data',
                            style: AppTextStyles.mulish(
                              color: AppColor.gray84,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SizedBox(
                    height: 180,
                    child: showChart
                        ? _scrollableTrendChart(
                            lineColor: blue,
                            spots: spots,
                            xLabels: xLabels,
                          )
                        : Center(
                            child: Text(
                              'No data',
                              style: AppTextStyles.mulish(
                                color: AppColor.gray84,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                if (bottomItems.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: bottomItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final item = bottomItems[i];
                        final isSel = item.key == selectedKey;

                        return GestureDetector(
                          onTap: () async {
                            _setSelectedKeyForFilter(item.key);
                            setState(() {});
                            await _fetchAnalyticsSelected(
                              ref.read(aboutMeNotifierProvider),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColor.resendOtp
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              item.label,
                              style: AppTextStyles.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSel
                                    ? AppColor.white
                                    : AppColor.slatePurple,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'More Details',
                    style: AppTextStyles.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        _analyticsCard(
                          icon: AppImages.enqury2,
                          value: '$enquiries',
                          label: 'Enquiries',
                        ),
                        const SizedBox(width: 15),
                        _analyticsCard(
                          icon: AppImages.hand,
                          value: '$userClicks',
                          label: 'User Clicks',
                        ),
                        const SizedBox(width: 15),
                        _analyticsCard(
                          icon: AppImages.loc,
                          value: '$locationViews',
                          label: 'Location Views',
                        ),
                        const SizedBox(width: 15),
                        _analyticsCard(
                          icon: AppImages.whatsappImage,
                          value: '$whatsapp',
                          label: 'WhatsApp Msg',
                        ),
                        const SizedBox(width: 15),
                        _analyticsCard(
                          icon: AppImages.call,
                          value: '$directCalls',
                          label: 'Direct Calls',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (aboutState.analyticsLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.6),
              child: Center(
                child: AppLoader.circularLoader(color: AppColor.darkBlue),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // ✅ KEEP YOUR SHOP DETAILS + FOLLOWERS (UNCHANGED)
  // ==========================================================
  // (Your _buildShopDetails and buildFollowersDetails are long; kept same from your paste)
  // ----------------------------------------------------------
  Widget _buildShopDetails(AboutMeState aboutState) {
    final isPremium = RegistrationProductSeivice.instance.isPremium;
    final selectedShop = _getSelectedShop(aboutState);
    final products = selectedShop?.products ?? [];
    final services = selectedShop?.services ?? [];
    final planState = ref.watch(subscriptionNotifier);
    final planData = planState.currentPlanResponse?.data;
    final shopReviews = selectedShop?.reviews ?? [];

    String time = '-';
    String date = '-';

    final String? startsAt = planData?.period.startsAt;

    if (startsAt != null && startsAt.isNotEmpty) {
      final DateTime dateTime = DateTime.parse(startsAt).toLocal();
      time = DateFormat('h.mm.a').format(dateTime);
      date = DateFormat('dd MMM yyyy').format(dateTime);
    }
    final bool hasServices = services.isNotEmpty;
    final bool hasProducts = products.isNotEmpty;

    final String title;

    if (hasServices && !hasProducts) {
      title = "Services";
    } else if (hasProducts && !hasServices) {
      title = "Products";
    } else {
      title = "Products & Services";
    }

    return Container(
      key: const ValueKey('shopDetails'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColor.leftArrow,
            AppColor.scaffoldColor,
            AppColor.scaffoldColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildShopHeaderCard(aboutState),
            const SizedBox(height: 28),
            if (!isPremium)
              planData?.isFreemium == false
                  ? CommonContainer.paidCustomerCard(
                      title:
                          '${planData?.plan.durationLabel} Premium Activated',
                      description: '${time} @ ${date}',
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SubscriptionScreen(),
                        //   ),
                        // );
                      },
                    )
                  : CommonContainer.attractCustomerCard(
                      title: 'Attract More Customers',
                      description: 'Unlock premium to attract more customers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionScreen(),
                          ),
                        );
                      },
                    ),
            SizedBox(height: isPremium ? 20 : 40),
            Row(
              children: [
                Image.asset(
                  AppImages.product,
                  height: 35,
                  color: AppColor.darkBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  hasServices ? 'Services' : 'Products',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!hasServices && !hasProducts)
              Text(
                'No products or services added yet.',
                style: AppTextStyles.mulish(
                  color: AppColor.gray84,
                  fontSize: 14,
                ),
              )
            else if (hasServices)
              // ----------------- SERVICES LIST -----------------
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = services[i];

                  final title = (s.englishName ?? s.tamilName ?? '').trim();
                  final serviceName = title.isEmpty ? 'Unnamed Service' : title;

                  final rating = (s.rating ?? 0).toDouble().toStringAsFixed(1);
                  final ratingCount = (s.ratingCount ?? 0).toString();

                  final startsAt = s.startsAt ?? 0;
                  final offerPrice = s.offerPrice ?? 0;
                  final priceText = ' ₹$startsAt';
                  final offerPriceText = ' ₹$offerPrice';

                  String imageUrl = '';
                  if (s.media.isNotEmpty) {
                    imageUrl = s.media.first.url ?? '';
                  }

                  return Column(
                    children: [
                      CommonContainer.foodList(
                        fontSize: 14,
                        titleWeight: FontWeight.w700,
                        onTap: () {},
                        imageWidth: 130,
                        image: imageUrl,
                        foodName: serviceName,
                        ratingStar: rating,
                        ratingCount: ratingCount,
                        offAmound: offerPriceText,
                        oldAmound: priceText,
                        km: '',
                        location: '',
                        Verify: false,
                        locations: false,
                        weight: false,
                        horizontalDivider: false,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                // prefs.remove('product_id');
                                prefs.remove('shop_id');
                                prefs.remove('service_id');
                                final selectedShop = _getSelectedShop(
                                  aboutState,
                                );
                                if (selectedShop == null) return;

                                final title =
                                    (s.englishName ?? s.tamilName ?? '').trim();
                                final englishName = title.isEmpty
                                    ? 'Unnamed Product'
                                    : title;

                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductCategoryScreens(
                                          page: 'AboutMeScreens',
                                          isService: true,
                                          shopId: selectedShop.shopId,
                                          productId: s.serviceId,
                                          allowOfferEdit: true,
                                          initialCategoryName: s.category,
                                          initialSubCategoryName: s.subCategory,
                                          initialProductName: englishName,
                                          initialPrice: s.startsAt,
                                          initialDescription: s.description,
                                          initialOfferLabel: s.offerLabel,
                                          initialOfferValue: s.offerValue,
                                        ),
                                  ),
                                );

                                //  AFTER POP: refresh automatically
                                if (updated == true && mounted) {
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                        shopId:
                                            _currentShopId ??
                                            selectedShop.shopId,
                                      );
                                  setState(() {});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.resendOtp,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.editImage,
                                      color: AppColor.white,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // prevent double tap while this service is deleting
                                if (_deletingServiceId == s.serviceId) return;

                                final confirm = await showDialog<bool>(
                                  context: this.context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColor.white,
                                    title: const Text('Confirm Remove'),
                                    content: const Text(
                                      'Are you sure you want to remove this service?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, true),
                                        child: Text(
                                          'Remove',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;
                                if (!mounted) return;

                                setState(
                                  () => _deletingServiceId = s.serviceId,
                                );

                                final success = await ref
                                    .read(productNotifierProvider.notifier)
                                    .deleteServiceAction(
                                      serviceId: s.serviceId,
                                    );

                                if (!mounted) return;

                                setState(() => _deletingServiceId = null);

                                final productState = ref.read(
                                  productNotifierProvider,
                                );
                                final deleteMsg =
                                    productState.serviceRemoveResponse?.message;

                                if (success) {
                                  // optional: instant local removal of the service
                                  final currentShop = _getSelectedShop(
                                    aboutState,
                                  );
                                  if (currentShop != null) {
                                    currentShop.services.removeWhere(
                                      (srv) => srv.serviceId == s.serviceId,
                                    );
                                  }

                                  // refresh from backend
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                        shopId:
                                            _currentShopId ??
                                            currentShop?.shopId,
                                      );

                                  if (!mounted) return;

                                  AppSnackBar.success(
                                    this.context,
                                    deleteMsg ?? 'Service removed successfully',
                                  );
                                } else {
                                  if (!mounted) return;
                                  AppSnackBar.error(
                                    this.context,
                                    productState.error ??
                                        'Failed to remove service',
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.leftArrow,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: (_deletingServiceId == s.serviceId)
                                      ? ThreeDotsLoader(
                                          dotColor: AppColor.black,
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              AppImages.closeImage,
                                              color: AppColor.black,
                                              height: 16,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Remove',
                                              style: AppTextStyles.mulish(
                                                color: AppColor.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final p = products[i];
                  final title = (p.englishName ?? p.tamilName ?? '').trim();
                  final englishName = title.isEmpty ? 'Unnamed Product' : title;

                  final rating = (p.rating ?? 0).toDouble().toStringAsFixed(1);
                  final ratingCount = (p.ratingCount ?? 0).toString();

                  final price = p.price ?? 0;
                  final priceText = '₹$price';

                  final offerPrice = p.offerPrice ?? 0;
                  final offerPriceText = '₹$offerPrice';

                  String imageUrl = '';
                  if (p.media.isNotEmpty) {
                    imageUrl = p.media.first.url ?? '';
                  }

                  final bool hasDoorDelivery = p.doorDelivery == true;

                  return Column(
                    children: [
                      CommonContainer.foodList(
                        fontSize: 14,

                        titleWeight: FontWeight.w700,
                        onTap: () {},
                        imageWidth: 130,
                        image: imageUrl,
                        foodName: englishName,
                        ratingStar: rating,
                        ratingCount: ratingCount,
                        offAmound: offerPriceText,

                        oldAmound: priceText,
                        km: '',
                        location: '',
                        Verify: false,
                        locations: false,
                        weight: false,
                        horizontalDivider: false,
                        doorDelivery: hasDoorDelivery,
                      ),
                      Row(
                        children: [
                          // 🔵 EDIT BUTTON (unchanged)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final selectedShop = _getSelectedShop(
                                  aboutState,
                                );
                                if (selectedShop == null) return;

                                final title =
                                    (p.englishName ?? p.tamilName ?? '').trim();
                                final englishName = title.isEmpty
                                    ? 'Unnamed Product'
                                    : title;
                                final price = p.price ?? 0;

                                final offerLabel = p.offerLabel;
                                final offerValue = p.offerValue;
                                final description = p.description;
                                final doorDelivery = (p.doorDelivery == true)
                                    ? 'Yes'
                                    : 'No';

                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductCategoryScreens(
                                          page: 'AboutMeScreens',
                                          isService: false,

                                          shopId: selectedShop.shopId,
                                          productId: p.productId,
                                          allowOfferEdit: true,
                                          initialCategoryName: p.category,
                                          initialSubCategoryName: p.subCategory,
                                          initialProductName: englishName,
                                          initialPrice: price,
                                          initialDescription: description,
                                          initialDoorDelivery: doorDelivery,
                                          initialOfferLabel: offerLabel,
                                          initialOfferValue: offerValue,
                                          initialCategorySlug: p.categorySlug,
                                          initialSubCategorySlug:
                                              p.subCategorySlug,
                                        ),
                                  ),
                                );
                                if (updated == true && mounted) {
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                        shopId:
                                            _currentShopId ??
                                            selectedShop.shopId,
                                      );
                                  setState(() {});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.resendOtp,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.editImage,
                                      color: AppColor.white,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          //  REMOVE BUTTON (NOW WIRED TO API)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (_deletingProductId == p.productId) return;

                                // use page-level context for dialog (safer)
                                final confirm = await showDialog<bool>(
                                  context: this.context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColor.white,
                                    title: const Text('Confirm Remove'),
                                    content: const Text(
                                      'Are you sure you want to remove this product?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, true),
                                        child: Text(
                                          'Remove',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;
                                if (!mounted) return;

                                setState(
                                  () => _deletingProductId = p.productId,
                                );

                                final success = await ref
                                    .read(productNotifierProvider.notifier)
                                    .deleteProductAction(
                                      productId: p.productId,
                                    );

                                if (!mounted) return;

                                setState(() => _deletingProductId = null);

                                final productState = ref.read(
                                  productNotifierProvider,
                                );
                                final deleteMsg =
                                    productState.DeleteResponses?.message;

                                if (success) {
                                  // (optional) local remove – only if you want instant effect
                                  final currentShop = _getSelectedShop(
                                    aboutState,
                                  );
                                  if (currentShop != null) {
                                    currentShop.products.removeWhere(
                                      (prod) => prod.productId == p.productId,
                                    );
                                  }

                                  // refresh from backend
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                        shopId:
                                            _currentShopId ??
                                            currentShop?.shopId,
                                      );

                                  if (!mounted) return;

                                  setState(() {});

                                  // IMPORTANT: use page context, NOT the row context
                                  AppSnackBar.success(
                                    this.context,
                                    deleteMsg ?? 'Product removed successfully',
                                  );
                                } else {
                                  if (!mounted) return;
                                  AppSnackBar.error(
                                    this.context,
                                    productState.error ??
                                        'Failed to remove product',
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.leftArrow,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: (_deletingProductId == p.productId)
                                      ? ThreeDotsLoader(
                                          dotColor: AppColor.black,
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              AppImages.closeImage,
                                              color: AppColor.black,
                                              height: 16,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Remove',
                                              style: AppTextStyles.mulish(
                                                color: AppColor.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 20),

            // 🔹 Add Product / Service
            InkWell(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('product_id');
                prefs.remove('shop_id');
                prefs.remove('service_id');
                final selectedShop = _getSelectedShop(aboutState);
                if (selectedShop == null) return;

                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCategoryScreens(
                      page: 'AboutMeScreens',
                      shopId: selectedShop.shopId,
                      isService: hasServices,
                      allowOfferEdit: true,
                    ),
                  ),
                );

                if (added == true && mounted) {
                  await ref
                      .read(aboutMeNotifierProvider.notifier)
                      .fetchAllShopDetails(
                        shopId: _currentShopId ?? selectedShop.shopId,
                      );
                  setState(() {});
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.addListImage,
                      height: 22,
                      color: AppColor.darkBlue,
                    ),
                    SizedBox(width: 9),
                    Text(
                      hasServices ? 'Add Service' : 'Add Product',
                      style: AppTextStyles.mulish(
                        color: AppColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Image.asset(AppImages.reviewImage, height: 27.08, width: 26),
                const SizedBox(width: 10),
                Text(
                  'Reviews',
                  style: AppTextStyles.mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Row(
              children: [
                Text(
                  ((selectedShop?.shopRating ?? 0.0).toStringAsFixed(1)),
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 33,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  AppImages.starImage,
                  height: 30,
                  color: AppColor.green,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Based on ${(selectedShop?.shopReviewCount ?? 0)} reviews',
              style: AppTextStyles.mulish(color: AppColor.gray84),
            ),
            const SizedBox(height: 17),

            if (shopReviews.isEmpty) ...[
              Text(
                'No reviews yet.',
                style: AppTextStyles.mulish(
                  color: AppColor.gray84,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shopReviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = shopReviews[index];

                  // 🔹 Your API: rating is "4.0" (String)
                  final rating =
                      double.tryParse((r.rating ?? '0').toString()) ?? 0.0;
                  final comment = (r.comment ?? '').toString().trim();

                  final reviewTime =
                      (r.createdAtRelative ?? '').trim().isNotEmpty
                      ? (r.createdAtRelative ?? '').trim()
                      : '_';

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.scaffoldColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColor.borderLightGrey,
                          width: 8,
                        ),
                        left: BorderSide(
                          color: AppColor.borderLightGrey,
                          width: 2,
                        ),
                        right: BorderSide(
                          color: AppColor.borderLightGrey,
                          width: 2,
                        ),
                        top: BorderSide(
                          color: AppColor.borderLightGrey,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Customer Review',
                                style: AppTextStyles.mulish(
                                  fontSize: 16,
                                  color: AppColor.darkBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                AppImages.dratImage,
                                height: 8,
                                width: 6,
                              ),
                              const SizedBox(width: 8),

                              // ✅ Stars Row
                              ...List.generate(5, (i) {
                                final filled = rating >= (i + 1);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Image.asset(
                                    AppImages.starImage,
                                    height: 12,
                                    color: filled
                                        ? AppColor.green
                                        : AppColor.lightSilver,
                                  ),
                                );
                              }),

                              const SizedBox(width: 8),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            comment.isEmpty ? '-' : comment,
                            style: AppTextStyles.mulish(color: AppColor.gray84),
                          ),
                          const SizedBox(height: 15),
                          CommonContainer.horizonalDivider(),
                          const SizedBox(height: 15),
                          Text(
                            reviewTime, // if API gives date later, map here
                            style: AppTextStyles.mulish(
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.floralWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset(
                      icon,
                      color: AppColor.black,
                      height: 28,
                      width: 26,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mulish(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    color: AppColor.gray84,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFollowersDetails(AboutMeState aboutState) {
    final followers = aboutState.followersResponse?.data.items ?? [];
    final counts = aboutState.followersResponse?.data.counts;
    final canViewProfiles =
        aboutState.followersResponse?.data.canViewProfiles ?? true;

    return Container(
      key: const ValueKey('followers'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColor.leftArrow,
            AppColor.scaffoldColor,
            AppColor.scaffoldColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: _buildShopHeaderCard(aboutState),
            ),
            Center(
              child: Text(
                'Followers List',
                style: AppTextStyles.mulish(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 20),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _followersChip(
                    '${counts?.week ?? 0} Last week',
                    0,
                    aboutState,
                  ),
                  const SizedBox(width: 10),
                  _followersChip(
                    '${counts?.month ?? 0} Last month',
                    1,
                    aboutState,
                  ),
                  const SizedBox(width: 10),
                  _followersChip('${counts?.all ?? 0} All time', 2, aboutState),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: aboutState.followersLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: ThreeDotsLoader(dotColor: AppColor.darkBlue),
                        ),
                      )
                    : followers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No followers found',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              color: AppColor.gray84,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: followers.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemBuilder: (context, index) {
                          final f = followers[index];

                          final blurred = !canViewProfiles;
                          // (f.isBlurred == true) || !canViewProfiles;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            child: GestureDetector(
                              onTap: canViewProfiles == true
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionScreen(),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Row(
                                children: [
                                  _FollowerAvatar(
                                    imageUrl: f.avatarUrl,
                                    isBlurred: blurred,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          f.followerName,
                                          style: AppTextStyles.mulish(
                                            color: AppColor.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          f.joinedLabel,
                                          style: AppTextStyles.mulish(
                                            color: AppColor.darkGrey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _followersChip(String label, int index, AboutMeState aboutState) {
    final isSelected = followersSelectedIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() => followersSelectedIndex = index);
        await _fetchFollowersForCurrentShop(aboutState);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.black : AppColor.borderLightGrey,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColor.black : AppColor.borderLightGrey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String? _selectedKeyForFilter(dynamic data) {
    final active = data?.active;

    switch (_analyticsFilter) {
      case AnalyticsFilter.month:
        return active?.month ?? _monthKey;
      case AnalyticsFilter.week:
        return active?.week ?? _weekKey;
      case AnalyticsFilter.year:
        return active?.year ?? _yearKey;
      case AnalyticsFilter.day:
        return active?.day ?? _dayKey;
    }
  }

  void _setSelectedKeyForFilter(String key) {
    switch (_analyticsFilter) {
      case AnalyticsFilter.month:
        _monthKey = key;
        break;
      case AnalyticsFilter.week:
        _weekKey = key;
        break;
      case AnalyticsFilter.year:
        _yearKey = key;
        break;
      case AnalyticsFilter.day:
        _dayKey = key;
        break;
    }
  }

  List<_KeyItem> _bottomSelectorItemsFromApi(dynamic data) {
    final selectors = data?.selectors;

    switch (_analyticsFilter) {
      case AnalyticsFilter.month:
        final months = selectors?.months ?? [];
        return months.map<_KeyItem>((m) => _KeyItem(m.key, m.label)).toList();

      case AnalyticsFilter.week:
        final weeks = selectors?.weeks ?? [];
        return weeks.map<_KeyItem>((w) => _KeyItem(w.key, w.label)).toList();

      case AnalyticsFilter.year:
        final years = selectors?.years ?? [];
        return years.map<_KeyItem>((y) => _KeyItem(y.key, y.label)).toList();

      case AnalyticsFilter.day:
        final days = selectors?.days ?? [];
        return days.map<_KeyItem>((d) => _KeyItem(d.key, d.label)).toList();
    }
  }
}

// ==========================================================
// ✅ SMALL WIDGETS (Dropdowns)
// ==========================================================
class _FilterDropdown extends StatelessWidget {
  final AnalyticsFilter value;
  final ValueChanged<AnalyticsFilter?> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.leftArrow, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalyticsFilter>(
          value: value,
          isExpanded: true,
          icon: Image.asset(
            AppImages.downArrow,
            height: 18,
            color: AppColor.black,
          ),
          items: AnalyticsFilter.values
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter',
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          color: AppColor.gray84,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f.label,
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColor.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _KeyDropdown extends StatelessWidget {
  const _KeyDropdown({
    required this.title,
    required this.valueKey,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final String? valueKey;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final keys = items.map((e) => e.value).toSet();
    final safeValue = (valueKey != null && keys.contains(valueKey))
        ? valueKey
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.leftArrow, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          hint: Text(
            title,
            style: AppTextStyles.mulish(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.gray84,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}

class _FollowerAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isBlurred;

  const _FollowerAvatar({required this.imageUrl, required this.isBlurred});

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl.trim().isNotEmpty;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasUrl
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Image.asset(AppImages.person, fit: BoxFit.cover),
                        errorWidget: (_, __, ___) =>
                            Image.asset(AppImages.person, fit: BoxFit.cover),
                      )
                    : Image.asset(AppImages.person, fit: BoxFit.cover),
                if (isBlurred)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isBlurred)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 15,
              width: 15,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(7)),
              ),
              child: Image.asset(AppImages.lock, height: 16),
            ),
          ),
      ],
    );
  }
}

class FullScreenGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGalleryPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGalleryPage> createState() => _FullScreenGalleryPageState();
}

class _FullScreenGalleryPageState extends State<FullScreenGalleryPage> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_current + 1}/${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.imageUrls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, index) {
            final url = widget.imageUrls[index];

            return InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BranchDropdownButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _BranchDropdownButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColor.leftArrow, width: 1.3),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Branch',
                    style: AppTextStyles.mulish(
                      color: AppColor.gray84,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mulish(
                      fontSize: 16,
                      color: AppColor.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColor.leftArrow,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AppImages.downArrow,
                color: AppColor.black,
                width: 18,
                height: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyItem {
  final String key;
  final String label;
  _KeyItem(this.key, this.label);
}

// ✅ Fake series item for padding / normalized series
class _FakeSeriesItem {
  final int value;
  final String label;
  _FakeSeriesItem({required this.value, required this.label});
}
