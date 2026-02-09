import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';
import 'package:tringo_owner/Core/Const/app_images.dart';
import 'package:tringo_owner/Core/Utility/app_loader.dart';
import 'package:tringo_owner/Core/Utility/app_snackbar.dart';
import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
import 'package:tringo_owner/Core/Utility/common_Container.dart';
import 'package:tringo_owner/Presentation/Wallet/Controller/wallet_notifier.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/wallet_history_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Screens/qr_scan_screen.dart';
import 'package:tringo_owner/Presentation/Wallet/Screens/receive_screen.dart';
import 'package:tringo_owner/Presentation/Wallet/Screens/send_screen.dart';
import 'package:tringo_owner/Presentation/Wallet/Screens/withdraw_screen.dart';

class WalletScreens extends ConsumerStatefulWidget {
  const WalletScreens({super.key});

  @override
  ConsumerState<WalletScreens> createState() => _WalletScreensState();
}

class _WalletScreensState extends ConsumerState<WalletScreens>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';
  int selectedIndex = 0;

  // ✅ API types (backend supports)
  static const _types = ["ALL", "REWARDS", "SENT", "RECEIVED", "WITHDRAW"];

  // ✅ UI chips types (only what you show in UI)
  // NOTE: Your UI currently shows 4 chips: All, Sent, Received, Withdraw
  static const _chipTypes = ["ALL", "SENT", "RECEIVED", "WITHDRAW"];

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  String _norm(String v) => v.trim().toUpperCase();

  Color _badgeColorSmart({
    required String badgeType,
    required String badgeLabel,
  }) {
    final t = _norm(badgeType);
    final l = _norm(badgeLabel);
    final key = t.isNotEmpty ? t : l;

    if (key == "RECEIVED" || key == "SUCCESS") return AppColor.green;
    if (key == "SENT" || key == "REJECTED") return AppColor.red1;
    if (key == "WAITING" || key == "PENDING") return AppColor.skyBlue;
    if (key == "REWARD" || key == "REWARDS") return AppColor.positiveGreen;

    return AppColor.darkGrey;
  }

  Color _rowBgSmart({required String badgeType, required String badgeLabel}) {
    final t = _norm(badgeType);
    final l = _norm(badgeLabel);
    final key = t.isNotEmpty ? t : l;

    if (key == "RECEIVED" || key == "SUCCESS") return AppColor.lightGreenBg;
    if (key == "SENT" || key == "REJECTED") return AppColor.pinkSurface;
    if (key == "WAITING" || key == "PENDING") return AppColor.lightBlueGray;
    if (key == "REWARD" || key == "REWARDS") return AppColor.lightMint;

    return AppColor.leftArrow;
  }

  Map<String, int> _localCountsFromSections(List<Section> sections) {
    int all = 0, rewards = 0, sent = 0, received = 0, withdraw = 0;

    bool isReward(WalletHistoryItem it) {
      final title = _norm(it.title);
      final key = _norm(it.badgeType).isNotEmpty
          ? _norm(it.badgeType)
          : _norm(it.badgeLabel);

      if (key == "REWARD" || key == "REWARDS") return true;
      if (title.contains("BONUS") || title.contains("REWARD")) return true;
      if (title.contains("SIGNUP")) return true;
      return false;
    }

    bool isWithdraw(WalletHistoryItem it) {
      final title = _norm(it.title);
      final key = _norm(it.badgeType).isNotEmpty
          ? _norm(it.badgeType)
          : _norm(it.badgeLabel);

      if (key == "WITHDRAW" || key == "WITHDRAWAL") return true;
      if (key == "WAITING" && title.contains("WITHDRAW")) return true;
      if (title.contains("WITHDRAW")) return true;
      return false;
    }

    for (final sec in sections) {
      for (final it in sec.items) {
        all++;

        final key = _norm(it.badgeType).isNotEmpty
            ? _norm(it.badgeType)
            : _norm(it.badgeLabel);

        if (key == "SENT") sent++;
        if (key == "RECEIVED") received++;
        if (isWithdraw(it)) withdraw++;
        if (isReward(it)) rewards++;
      }
    }

    return {
      "ALL": all,
      "REWARDS": rewards,
      "SENT": sent,
      "RECEIVED": received,
      "WITHDRAW": withdraw,
    };
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ initial load
      ref.read(walletNotifier.notifier).walletHistory(type: _types[0]); // ALL
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ Client-side date filter
  List<Section> _applyLocalDateFilter(List<Section> sections) {
    if (sections.isEmpty) return sections;

    if (selectedDay == "Today" || selectedDay == "Yesterday") {
      final wanted = selectedDay.trim().toLowerCase();
      return sections
          .where((s) => s.dayLabel.trim().toLowerCase() == wanted)
          .toList();
    }

    final target = _fmt(selectedDate);
    final filtered = <Section>[];

    for (final sec in sections) {
      final items = sec.items
          .where((it) => it.dateLabel.trim() == target)
          .toList();
      if (items.isNotEmpty) {
        filtered.add(
          Section(dayKey: sec.dayKey, dayLabel: sec.dayLabel, items: items),
        );
      }
    }
    return filtered;
  }

  // ✅ Client-side type filter (chips)
  List<Section> _applyLocalTypeFilter(List<Section> sections) {
    if (sections.isEmpty) return sections;

    // ✅ IMPORTANT FIX: use chip types, not API _types
    final type = _chipTypes[selectedIndex].toUpperCase();
    if (type == "ALL") return sections;

    bool matchItem(WalletHistoryItem it) {
      final bt = _norm(it.badgeType);
      final bl = _norm(it.badgeLabel);
      final title = _norm(it.title);
      final key = bt.isNotEmpty ? bt : bl;

      if (type == "SENT") return key == "SENT";
      if (type == "RECEIVED") return key == "RECEIVED";

      if (type == "WITHDRAW") {
        if (key == "WITHDRAW" || key == "WITHDRAWAL") return true;
        if (key == "WAITING" && title.contains("WITHDRAW")) return true;
        if (title.contains("WITHDRAW")) return true;
        return false;
      }

      if (type == "REWARDS") {
        if (key == "REWARD" || key == "REWARDS") return true;
        if (title.contains("BONUS") || title.contains("REWARD")) return true;
        if (title.contains("SIGNUP")) return true;
        return false;
      }

      return false;
    }

    final out = <Section>[];
    for (final sec in sections) {
      final items = sec.items.where(matchItem).toList();
      if (items.isNotEmpty) {
        out.add(
          Section(dayKey: sec.dayKey, dayLabel: sec.dayLabel, items: items),
        );
      }
    }
    return out;
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
              _sheetItem('Yesterday', () => Navigator.pop(context, 'Yesterday')),
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
        selectedIndex = 0; // reset chips to ALL
      });
    } else if (res == 'Yesterday') {
      setState(() {
        selectedDay = 'Yesterday';
        selectedDate = DateTime.now().subtract(const Duration(days: 1));
        selectedIndex = 0; // reset chips to ALL
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
          selectedIndex = 0; // reset chips to ALL
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

  String _segmentLabel({required String title, required int count}) =>
      "$count $title";

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

    final resp = walletState.walletHistoryResponse;
    final data = resp?.data;

    final wallet = data?.wallet;
    final rawSections = data?.sections ?? const <Section>[];

    final dateFiltered = _applyLocalDateFilter(rawSections);
    final typeFiltered = _applyLocalTypeFilter(dateFiltered);

    final localCounts = _localCountsFromSections(dateFiltered);

    // ✅ IMPORTANT FIX: selectedType from chipTypes
    final selectedType = _chipTypes[selectedIndex];
    final selCount = localCounts[selectedType] ?? 0;
    final sections = (selCount == 0) ? <Section>[] : typeFiltered;

    if (walletState.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    // ✅ Your UI chips: All, Sent, Received, Withdraw
    final segments = <String>[
      _segmentLabel(title: "All", count: localCounts["ALL"] ?? 0),
      _segmentLabel(title: "Sent", count: localCounts["SENT"] ?? 0),
      _segmentLabel(title: "Received", count: localCounts["RECEIVED"] ?? 0),
      _segmentLabel(title: "Withdraw", count: localCounts["WITHDRAW"] ?? 0),
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(walletNotifier.notifier).walletHistory(type: _types[0]);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.leftSideArrow(
                        Color: AppColor.leftArrow,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Wallet',
                      style: AppTextStyles.mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // HEADER CARD
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(AppImages.walletBCImage)),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.veryLightMintGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 115),
                      child: Row(
                        children: [
                          Image.asset(AppImages.wallet, height: 55, width: 62),
                          const SizedBox(width: 15),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColor.brandBlue,
                                  AppColor.accentCyan,
                                  AppColor.successGreen,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              (wallet?.tcoinBalance ?? 0).toString(),
                              style: AppTextStyles.mulish(
                                fontSize: 42,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'TCoin Wallet Balance',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 135),
                      child: Row(
                        children: [
                          Text(
                            wallet?.uid ?? "—",
                            style: AppTextStyles.mulish(
                              fontSize: 13,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final uid = (wallet?.uid ?? "").trim();
                              if (uid.isEmpty) return;

                              await Clipboard.setData(ClipboardData(text: uid));
                              if (!mounted) return;
                              AppSnackBar.success(context, "UID copied: $uid");
                            },
                            child: Image.asset(AppImages.uID, height: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            AppColor.white.withOpacity(0.5),
                            AppColor.border.withOpacity(0.4),
                            AppColor.border.withOpacity(0.4),
                            AppColor.border.withOpacity(0.4),
                            AppColor.border.withOpacity(0.4),
                            AppColor.border.withOpacity(0.4),
                            AppColor.border.withOpacity(0.4),
                            AppColor.white.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 58, vertical: 25),
                      child: Row(
                        children: [
                          CommonContainer.walletSendBox(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SendScreen(
                                    tCoinBalance: wallet?.tcoinBalance.toString() ?? '',
                                    uid: wallet?.uid.toString() ?? '',
                                  ),
                                ),
                              );
                            },
                            text: 'Send',
                            image: AppImages.sendArrow,
                          ),
                          const SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            onTap: () {
                              final myUid = (wallet?.uid ?? "").trim();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReceiveScreen(toUid: myUid, amount: "0"),
                                ),
                              );
                            },
                            text: 'Receive',
                            image: AppImages.receiveArrow,
                          ),
                          const SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            onTap: () async {
                              final result = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QrScanScreen(title: 'Scan QR Code'),
                                ),
                              );

                              if (result == null || result.trim().isEmpty) return;

                              final payload = QrScanPayload.fromScanValue(result);
                              final toUid = (payload.toUid ?? '').trim();
                              if (toUid.isEmpty) {
                                AppSnackBar.error(context, "Invalid QR");
                                return;
                              }

                              final walletStateNow = ref.read(walletNotifier);
                              final walletNow =
                                  walletStateNow.walletHistoryResponse?.data.wallet;

                              final myUid = (walletNow?.uid ?? '').toString();
                              final myBal = (walletNow?.tcoinBalance ?? 0).toString();

                              if (!context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SendScreen(
                                    tCoinBalance: myBal,
                                    uid: myUid,
                                    initialToUid: toUid,
                                  ),
                                ),
                              );
                            },
                            text: 'Scan QR',
                            image: AppImages.smallScanQR,
                          ),
                          const SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            imageHeight: 30,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WithdrawScreen(
                                    tCoinBalance: wallet?.tcoinBalance.toString() ?? '',
                                    uid: wallet?.uid.toString() ?? '',
                                  ),
                                ),
                              );
                            },
                            text: 'Withdraw',
                            image: AppImages.withdraw,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // History header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      'History',
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _openDateFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.8, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColor.textWhite,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Image.asset(AppImages.filter, height: 16)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ✅ Segment chips
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(segments.length, (index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 7),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          segments[index],
                          style: AppTextStyles.mulish(
                            color: isSelected ? AppColor.darkBlue : Colors.grey,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              if (sections.isEmpty) ...[
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    "No history found",
                    style: AppTextStyles.mulish(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final sec in sections) ...[
                        Center(
                          child: Text(
                            sec.dayLabel,
                            style: AppTextStyles.mulish(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final item in sec.items) ...[
                          CommonContainer.walletHistoryBox(
                            upiTexts: false,
                            containerColor: _rowBgSmart(
                              badgeType: item.badgeType,
                              badgeLabel: item.badgeLabel,
                            ),
                            mainText: item.title,
                            timeText: item.timeLabel,
                            numberText: "${item.amountSign}${item.amountTcoin}",
                            endText: item.badgeLabel,
                            numberTextColor: _badgeColorSmart(
                              badgeType: item.badgeType,
                              badgeLabel: item.badgeLabel,
                            ),
                            endTextColor: _badgeColorSmart(
                              badgeType: item.badgeType,
                              badgeLabel: item.badgeLabel,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class QrScanPayload {
  final String? toUid;
  final String? shopId;
  final String? action;
  final List<String> options;

  const QrScanPayload({
    this.toUid,
    this.shopId,
    this.action,
    this.options = const [],
  });

  bool get hasUid => (toUid ?? '').trim().isNotEmpty;
  bool get hasShop => (shopId ?? '').trim().isNotEmpty;

  bool get canPay => options.contains('SEND_TCOIN') || hasUid;
  bool get canReview => options.contains('REVIEW') || hasShop;

  static QrScanPayload fromScanValue(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return const QrScanPayload();

    final uri = Uri.tryParse(v);

    final payloadParam = uri?.queryParameters['payload'];
    if (payloadParam != null && payloadParam.trim().isNotEmpty) {
      final jsonMap = _tryDecodePayloadToJson(payloadParam.trim());
      if (jsonMap != null) return _fromJsonMap(jsonMap);
    }

    if (uri != null && uri.queryParameters.isNotEmpty) {
      final qp = uri.queryParameters;
      final toUid = _pick(qp, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
      final shopId = _pick(qp, ['shopId', 'shopID', 'shop_id', 'shop']);
      if ((toUid ?? '').trim().isNotEmpty || (shopId ?? '').trim().isNotEmpty) {
        return QrScanPayload(
          toUid: toUid?.trim(),
          shopId: shopId?.trim(),
          action: _pick(qp, ['action'])?.trim(),
          options: const [],
        );
      }
    }

    final jsonMapDirect = _tryJsonDecode(v);
    if (jsonMapDirect != null) return _fromJsonMap(jsonMapDirect);

    final onlyUid = _extractUid(v);
    if (onlyUid != null) {
      return QrScanPayload(toUid: onlyUid, options: const ['SEND_TCOIN']);
    }

    return const QrScanPayload();
  }

  static QrScanPayload _fromJsonMap(Map<String, dynamic> m) {
    final toUid = _pick(m, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
    final shopId = _pick(m, ['shopId', 'shopID', 'shop_id', 'shop']);
    final action = _pick(m, ['action', 'act']);

    return QrScanPayload(
      toUid: toUid?.toString().trim(),
      shopId: shopId?.toString().trim(),
      action: action?.toString().trim(),
      options: _readOptions(m),
    );
  }

  static Map<String, dynamic>? _tryDecodePayloadToJson(String b64url) {
    try {
      var s = b64url.replaceAll('-', '+').replaceAll('_', '/');
      while (s.length % 4 != 0) {
        s += '=';
      }
      final bytes = base64Decode(s);
      final decoded = utf8.decode(bytes);
      final map = jsonDecode(decoded);
      return (map as Map).cast<String, dynamic>();
    } catch (_) {
      try {
        final bytes = base64Decode(b64url);
        final decoded = utf8.decode(bytes);
        final map = jsonDecode(decoded);
        return (map as Map).cast<String, dynamic>();
      } catch (_) {
        return null;
      }
    }
  }

  static Map<String, dynamic>? _tryJsonDecode(String v) {
    try {
      final map = jsonDecode(v);
      if (map is Map) return map.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _extractUid(String v) {
    final m = RegExp(r'(UID[A-Za-z0-9]+)', caseSensitive: false).firstMatch(v);
    return m?.group(1)?.toUpperCase();
  }

  static String? _pick(Map m, List<String> keys) {
    for (final k in keys) {
      if (m.containsKey(k) && (m[k]?.toString().trim().isNotEmpty ?? false)) {
        return m[k].toString();
      }
    }
    return null;
  }

  static List<String> _readOptions(Map<String, dynamic> jsonMap) {
    final opts = jsonMap['options'];
    if (opts is List) {
      return opts
          .map((e) {
        if (e is Map) {
          return (e['key'] ?? e['code'] ?? e['name'])?.toString();
        }
        return e?.toString();
      })
          .whereType<String>()
          .map((e) => e.trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}


// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:tringo_owner/Core/Const/app_color.dart';
// import 'package:tringo_owner/Core/Const/app_images.dart';
// import 'package:tringo_owner/Core/Utility/app_loader.dart';
// import 'package:tringo_owner/Core/Utility/app_snackbar.dart';
// import 'package:tringo_owner/Core/Utility/app_textstyles.dart';
// import 'package:tringo_owner/Core/Utility/common_Container.dart';
// import 'package:tringo_owner/Presentation/Wallet/Controller/wallet_notifier.dart';
// import 'package:tringo_owner/Presentation/Wallet/Model/wallet_history_response.dart';
// import 'package:tringo_owner/Presentation/Wallet/Screens/qr_scan_screen.dart';
// import 'package:tringo_owner/Presentation/Wallet/Screens/receive_screen.dart';
// import 'package:tringo_owner/Presentation/Wallet/Screens/send_screen.dart';
// import 'package:tringo_owner/Presentation/Wallet/Screens/withdraw_screen.dart';
//
// class WalletScreens extends ConsumerStatefulWidget {
//   const WalletScreens({super.key});
//
//   @override
//   ConsumerState<WalletScreens> createState() => _WalletScreensState();
// }
//
// class _WalletScreensState extends ConsumerState<WalletScreens>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   DateTime selectedDate = DateTime.now();
//   int selectedTypeIndex = 0; // old selectedIndex instead use this
//   String selectedDateMode = "Today"; // Today / Yesterday / Custom
//
//   String selectedDay = 'Today';
//   int selectedIndex = 0;
//
//   // API types
//   static const _types = ["ALL", "REWARDS", "SENT", "RECEIVED", "WITHDRAW"];
//
//   String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
//   String _norm(String v) => v.trim().toUpperCase();
//
//   Color _badgeColorSmart({
//     required String badgeType,
//     required String badgeLabel,
//   }) {
//     final t = _norm(badgeType);
//     final l = _norm(badgeLabel);
//
//     final key = t.isNotEmpty ? t : l;
//
//     if (key == "RECEIVED" || key == "SUCCESS") return AppColor.green;
//     if (key == "SENT" || key == "REJECTED") return AppColor.red1;
//     if (key == "WAITING" || key == "PENDING") return AppColor.skyBlue;
//     if (key == "REWARD" || key == "REWARDS") return AppColor.positiveGreen;
//
//     return AppColor.darkGrey;
//   }
//
//   Color _rowBgSmart({required String badgeType, required String badgeLabel}) {
//     final t = _norm(badgeType);
//     final l = _norm(badgeLabel);
//
//     final key = t.isNotEmpty ? t : l;
//
//     if (key == "RECEIVED" || key == "SUCCESS") return AppColor.lightGreenBg;
//     if (key == "SENT" || key == "REJECTED") return AppColor.pinkSurface;
//     if (key == "WAITING" || key == "PENDING") return AppColor.lightBlueGray;
//     if (key == "REWARD" || key == "REWARDS") return AppColor.lightMint;
//
//     return AppColor.leftArrow;
//   }
//
//   Map<String, int> _localCountsFromSections(List<Section> sections) {
//     int all = 0, rewards = 0, sent = 0, received = 0, withdraw = 0;
//
//     bool isReward(WalletHistoryItem it) {
//       final title = _norm(it.title);
//       final key = _norm(it.badgeType).isNotEmpty
//           ? _norm(it.badgeType)
//           : _norm(it.badgeLabel);
//
//       if (key == "REWARD" || key == "REWARDS") return true;
//       if (title.contains("BONUS") || title.contains("REWARD")) return true;
//       if (title.contains("SIGNUP")) return true; // Signup Bonus
//       return false;
//     }
//
//     bool isWithdraw(WalletHistoryItem it) {
//       final title = _norm(it.title);
//       final key = _norm(it.badgeType).isNotEmpty
//           ? _norm(it.badgeType)
//           : _norm(it.badgeLabel);
//
//       if (key == "WITHDRAW" || key == "WITHDRAWAL") return true;
//       if (key == "WAITING" && title.contains("WITHDRAW")) return true;
//       if (title.contains("WITHDRAW")) return true;
//       return false;
//     }
//
//     for (final sec in sections) {
//       for (final it in sec.items) {
//         all++;
//
//         final key = _norm(it.badgeType).isNotEmpty
//             ? _norm(it.badgeType)
//             : _norm(it.badgeLabel);
//
//         if (key == "SENT") sent++;
//         if (key == "RECEIVED") received++;
//         if (isWithdraw(it)) withdraw++;
//         if (isReward(it)) rewards++;
//       }
//     }
//
//     return {
//       "ALL": all,
//       "REWARDS": rewards,
//       "SENT": sent,
//       "RECEIVED": received,
//       "WITHDRAW": withdraw,
//     };
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // ✅ initial load only (keep as ALL or your selectedIndex)
//       ref.read(walletNotifier.notifier).walletHistory(type: _types[0]);
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   // ✅ Client-side date filter (works even if backend doesn’t support date param)
//   List<Section> _applyLocalDateFilter(List<Section> sections) {
//     if (sections.isEmpty) return sections;
//
//     if (selectedDay == "Today" || selectedDay == "Yesterday") {
//       final wanted = selectedDay.trim().toLowerCase();
//       return sections
//           .where((s) => s.dayLabel.trim().toLowerCase() == wanted)
//           .toList();
//     }
//
//     final target = _fmt(selectedDate); // "23 Jan 2026"
//     final filtered = <Section>[];
//
//     for (final sec in sections) {
//       final items = sec.items
//           .where((it) => it.dateLabel.trim() == target)
//           .toList();
//       if (items.isNotEmpty) {
//         filtered.add(
//           Section(dayKey: sec.dayKey, dayLabel: sec.dayLabel, items: items),
//         );
//       }
//     }
//     return filtered;
//   }
//
//   // ✅ NEW: Client-side type filter (chips filter)
//   List<Section> _applyLocalTypeFilter(List<Section> sections) {
//     if (sections.isEmpty) return sections;
//
//     final type = _types[selectedIndex].toUpperCase();
//     if (type == "ALL") return sections;
//
//     bool matchItem(WalletHistoryItem it) {
//       final bt = _norm(it.badgeType); // WAITING / SENT / RECEIVED
//       final bl = _norm(it.badgeLabel); // Waiting / Sent / Received
//       final title = _norm(it.title); // Withdraw Requested / Signup Bonus
//       final key = bt.isNotEmpty ? bt : bl;
//
//       // ✅ Sent
//       if (type == "SENT") return key == "SENT";
//
//       // ✅ Received (includes bonus)
//       if (type == "RECEIVED") return key == "RECEIVED";
//
//       // ✅ Withdraw:
//       // Backend uses WAITING for withdraw requested, so treat WAITING + title as Withdraw
//       if (type == "WITHDRAW") {
//         if (key == "WITHDRAW" || key == "WITHDRAWAL") return true;
//         if (key == "WAITING" && title.contains("WITHDRAW")) return true;
//         if (title.contains("WITHDRAW")) return true; // extra safe
//         return false;
//       }
//
//       // ✅ Rewards:
//       // Backend gives "Signup Bonus" as reward but badgeType is RECEIVED
//       if (type == "REWARDS") {
//         if (key == "REWARD" || key == "REWARDS") return true;
//         if (title.contains("BONUS") || title.contains("REWARD")) return true;
//         if (title.contains("SIGNUP")) return true; // Signup Bonus
//         return false;
//       }
//
//       return false;
//     }
//
//     final out = <Section>[];
//     for (final sec in sections) {
//       final items = sec.items.where(matchItem).toList();
//       if (items.isNotEmpty) {
//         out.add(
//           Section(dayKey: sec.dayKey, dayLabel: sec.dayLabel, items: items),
//         );
//       }
//     }
//     return out;
//   }
//
//   Future<void> _openDateFilterSheet() async {
//     final res = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: false,
//       builder: (_) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppColor.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 44,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: AppColor.lightGray,
//                   borderRadius: BorderRadius.circular(999),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               _sheetItem('Today', () => Navigator.pop(context, 'Today')),
//               _sheetItem(
//                 'Yesterday',
//                 () => Navigator.pop(context, 'Yesterday'),
//               ),
//               _sheetItem(
//                 'Custom Date',
//                 () => Navigator.pop(context, 'Custom Date'),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//
//     if (res == null) return;
//
//     if (res == 'Today') {
//       setState(() {
//         selectedDay = 'Today';
//         selectedDate = DateTime.now();
//
//         selectedIndex = 0; // ✅ reset chips to ALL
//       });
//     } else if (res == 'Yesterday') {
//       setState(() {
//         selectedDay = 'Yesterday';
//         selectedDate = DateTime.now().subtract(const Duration(days: 1));
//
//         selectedIndex = 0; // ✅ reset chips to ALL
//       });
//     } else if (res == 'Custom Date') {
//       final picked = await showDatePicker(
//         context: context,
//         initialDate: selectedDate,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               dialogBackgroundColor: AppColor.white,
//               colorScheme: ColorScheme.light(
//                 primary: AppColor.strongBlue,
//                 onPrimary: AppColor.iceBlue,
//                 onSurface: AppColor.black,
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColor.strongBlue,
//                 ),
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );
//
//       if (picked != null) {
//         setState(() {
//           selectedDate = picked;
//           selectedDay = _fmt(picked);
//
//           selectedIndex = 0; // ✅ reset chips to ALL
//         });
//       }
//     }
//   }
//
//   Widget _sheetItem(String title, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//         child: Row(
//           children: [
//             Text(
//               title,
//               style: AppTextStyles.mulish(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: AppColor.black,
//               ),
//             ),
//             const Spacer(),
//             const Icon(Icons.chevron_right, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _segmentLabel({required String title, required int count}) =>
//       "$count $title";
//
//   int _selectedCount(Counts? c) {
//     switch (selectedIndex) {
//       case 0:
//         return c?.all ?? 0;
//       case 1:
//         return c?.rewards ?? 0;
//       case 2:
//         return c?.sent ?? 0;
//       case 3:
//         return c?.received ?? 0; // ✅ RECEIVED COUNT
//       case 4:
//         return c?.withdraw ?? 0;
//       default:
//         return 0;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final walletState = ref.watch(walletNotifier);
//
//     final resp = walletState.walletHistoryResponse;
//     final data = resp?.data;
//
//     final wallet = data?.wallet;
//     final counts = data?.counts;
//
//     final rawSections = data?.sections ?? const <Section>[];
//
//     final dateFiltered = _applyLocalDateFilter(rawSections);
//     final typeFiltered = _applyLocalTypeFilter(dateFiltered);
//
//     final localCounts = _localCountsFromSections(dateFiltered);
//
//     // ✅ counts-based final decision
//     final selectedType = _types[selectedIndex];
//     final selCount = localCounts[selectedType] ?? 0;
//     final sections = (selCount == 0) ? <Section>[] : typeFiltered;
//
//     // if (walletState.error != null && walletState.error!.isNotEmpty) {
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     AppSnackBar.info(context, walletState.error!);
//     //   });
//     // }
//
//     if (walletState.isLoading) {
//       return Scaffold(
//         body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
//       );
//     }
//
//     final segments = <String>[
//       _segmentLabel(title: "All", count: localCounts["ALL"] ?? 0),
//
//       _segmentLabel(title: "Sent", count: localCounts["SENT"] ?? 0),
//       _segmentLabel(title: "Received", count: localCounts["RECEIVED"] ?? 0),
//       _segmentLabel(title: "Withdraw", count: localCounts["WITHDRAW"] ?? 0),
//     ];
//
//     return Scaffold(
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             // ✅ refresh calls API (kept)
//             await ref
//                 .read(walletNotifier.notifier)
//                 .walletHistory(type: _types[0]);
//           },
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               // TOP BAR
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 16,
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: CommonContainer.leftSideArrow(
//                         Color: AppColor.leftArrow,
//                         onTap: () => Navigator.pop(context),
//                       ),
//                     ),
//                     Text(
//                       'Wallet',
//                       style: AppTextStyles.mulish(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // HEADER CARD
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppImages.walletBCImage),
//                   ),
//                   gradient: LinearGradient(
//                     colors: [AppColor.white, AppColor.veryLightMintGreen],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(25),
//                     bottomRight: Radius.circular(25),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 115),
//                       child: Row(
//                         children: [
//                           Image.asset(AppImages.wallet, height: 55, width: 62),
//                           const SizedBox(width: 15),
//                           ShaderMask(
//                             shaderCallback: (bounds) {
//                               return LinearGradient(
//                                 colors: [
//                                   AppColor.brandBlue,
//                                   AppColor.accentCyan,
//                                   AppColor.successGreen,
//                                 ],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.bottomRight,
//                               ).createShader(bounds);
//                             },
//                             child: Text(
//                               (wallet?.tcoinBalance ?? 0).toString(),
//                               style: AppTextStyles.mulish(
//                                 fontSize: 42,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     Text(
//                       'TCoin Wallet Balance',
//                       style: AppTextStyles.mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 135),
//                       child: Row(
//                         children: [
//                           Text(
//                             wallet?.uid ?? "—",
//                             style: AppTextStyles.mulish(
//                               fontSize: 13,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () async {
//                               final uid = (wallet?.uid ?? "").trim();
//                               if (uid.isEmpty) return;
//
//                               await Clipboard.setData(ClipboardData(text: uid));
//
//                               if (!mounted) return;
//                               AppSnackBar.success(context, "UID copied: $uid");
//                             },
//                             child: Image.asset(AppImages.uID, height: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     Container(
//                       width: double.infinity,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerRight,
//                           end: Alignment.centerLeft,
//                           colors: [
//                             AppColor.white.withOpacity(0.5),
//                             AppColor.border.withOpacity(0.4),
//                             AppColor.border.withOpacity(0.4),
//                             AppColor.border.withOpacity(0.4),
//                             AppColor.border.withOpacity(0.4),
//                             AppColor.border.withOpacity(0.4),
//                             AppColor.border.withOpacity(0.4),
//                             AppColor.white.withOpacity(0.5),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 58,
//                         vertical: 25,
//                       ),
//                       child: Row(
//                         children: [
//                           CommonContainer.walletSendBox(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => SendScreen(
//                                     tCoinBalance:
//                                         wallet?.tcoinBalance.toString() ?? '',
//                                     uid: wallet?.uid.toString() ?? '',
//                                   ),
//                                 ),
//                               );
//                             },
//                             text: 'Send',
//                             image: AppImages.sendArrow,
//                           ),
//                           const SizedBox(width: 20),
//                           CommonContainer.walletSendBox(
//                             onTap: () {
//                               final myUid = (wallet?.uid ?? "").trim();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       ReceiveScreen(toUid: myUid, amount: "0"),
//                                 ),
//                               );
//                             },
//                             text: 'Receive',
//                             image: AppImages.receiveArrow,
//                           ),
//                           const SizedBox(width: 20),
//                           CommonContainer.walletSendBox(
//                             onTap: () async {
//                               final result = await Navigator.push<String>(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       const QrScanScreen(title: 'Scan QR Code'),
//                                 ),
//                               );
//
//                               if (result == null || result.trim().isEmpty)
//                                 return;
//
//                               debugPrint("SCANNED QR => $result");
//
//                               final payload = QrScanPayload.fromScanValue(
//                                 result,
//                               );
//
//                               final toUid = (payload.toUid ?? '').trim();
//                               if (toUid.isEmpty) {
//                                 AppSnackBar.error(context, "Invalid QR");
//                                 return;
//                               }
//
//                               final walletState = ref.read(walletNotifier);
//                               final wallet = walletState
//                                   .walletHistoryResponse
//                                   ?.data
//                                   .wallet;
//
//                               final myUid = (wallet?.uid ?? '').toString();
//                               final myBal = (wallet?.tcoinBalance ?? 0)
//                                   .toString();
//
//                               if (!context.mounted) return;
//
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => SendScreen(
//                                     tCoinBalance: myBal,
//                                     uid: myUid,
//                                     initialToUid: toUid,
//                                   ),
//                                 ),
//                               );
//                             },
//                             text: 'Scan QR',
//                             image: AppImages.smallScanQR,
//                           ),
//
//                           // CommonContainer.walletSendBox(
//                           //   onTap: () {
//                           //     Navigator.push(
//                           //       context,
//                           //       MaterialPageRoute(
//                           //         builder: (_) =>
//                           //             QrScanScreen(title: 'Scan QR Code'),
//                           //       ),
//                           //     );
//                           //   },
//                           //   text: 'Scan QR',
//                           //   image: AppImages.smallScanQR,
//                           // ),
//                           const SizedBox(width: 20),
//                           CommonContainer.walletSendBox(
//                             imageHeight: 30,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => WithdrawScreen(
//                                     tCoinBalance:
//                                         wallet?.tcoinBalance.toString() ?? '',
//                                     uid: wallet?.uid.toString() ?? '',
//                                   ),
//                                 ),
//                               );
//                             },
//                             text: 'Withdraw',
//                             image: AppImages.withdraw,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // const SizedBox(height: 31),
//               //
//               // Padding(
//               //   padding: const EdgeInsets.symmetric(horizontal: 15),
//               //   child: Row(
//               //     children: [
//               //       InkWell(
//               //         onTap: () {
//               //           // Navigator.push(
//               //           //   context,
//               //           //   MaterialPageRoute(builder: (_) => ReferralScreen()),
//               //           // );
//               //         },
//               //         child: Container(
//               //           decoration: BoxDecoration(
//               //             color: AppColor.surfaceBlue,
//               //             borderRadius: BorderRadius.circular(15),
//               //             border: Border(
//               //               left: BorderSide(color: AppColor.skyBlue, width: 2),
//               //             ),
//               //           ),
//               //           child: Padding(
//               //             padding: const EdgeInsets.only(
//               //               left: 20,
//               //               right: 40,
//               //               bottom: 25,
//               //               top: 25,
//               //             ),
//               //             child: Column(
//               //               crossAxisAlignment: CrossAxisAlignment.start,
//               //               children: [
//               //                 Image.asset(
//               //                   AppImages.referFriends,
//               //                   height: 64,
//               //                   width: 75,
//               //                 ),
//               //                 const SizedBox(height: 15),
//               //                 Text(
//               //                   'Refer Friends',
//               //                   style: AppTextStyles.mulish(
//               //                     fontSize: 16,
//               //                     fontWeight: FontWeight.w700,
//               //                     color: AppColor.darkBlue,
//               //                   ),
//               //                 ),
//               //                 const SizedBox(height: 3),
//               //                 Row(
//               //                   children: [
//               //                     Text(
//               //                       'Let’s Start',
//               //                       style: AppTextStyles.mulish(
//               //                         fontSize: 12,
//               //                         fontWeight: FontWeight.w700,
//               //                         color: AppColor.linkBlue,
//               //                       ),
//               //                     ),
//               //                     const SizedBox(width: 8),
//               //                     Image.asset(
//               //                       AppImages.rightStickArrow,
//               //                       height: 13,
//               //                       color: AppColor.linkBlue,
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ],
//               //             ),
//               //           ),
//               //         ),
//               //       ),
//               //       const SizedBox(width: 20),
//               //       InkWell(
//               //         onTap: () {
//               //           // Navigator.push(
//               //           //   context,
//               //           //   MaterialPageRoute(builder: (_) => ReviewAndEarn()),
//               //           // );
//               //         },
//               //         child: Container(
//               //           decoration: BoxDecoration(
//               //             color: AppColor.lightMint,
//               //             borderRadius: BorderRadius.circular(15),
//               //             border: Border(
//               //               right: BorderSide(
//               //                 color: AppColor.positiveGreen,
//               //                 width: 2,
//               //               ),
//               //             ),
//               //           ),
//               //           child: Padding(
//               //             padding: const EdgeInsets.only(
//               //               left: 20,
//               //               right: 25,
//               //               bottom: 25,
//               //               top: 25,
//               //             ),
//               //             child: Column(
//               //               crossAxisAlignment: CrossAxisAlignment.start,
//               //               children: [
//               //                 Image.asset(
//               //                   AppImages.earnByReview,
//               //                   height: 64,
//               //                   width: 83,
//               //                 ),
//               //                 const SizedBox(height: 15),
//               //                 Text(
//               //                   'Earn by Review',
//               //                   style: AppTextStyles.mulish(
//               //                     fontSize: 16,
//               //                     fontWeight: FontWeight.w700,
//               //                     color: AppColor.darkBlue,
//               //                   ),
//               //                 ),
//               //                 const SizedBox(height: 3),
//               //                 Row(
//               //                   children: [
//               //                     Text(
//               //                       'Know More',
//               //                       style: AppTextStyles.mulish(
//               //                         fontSize: 12,
//               //                         fontWeight: FontWeight.w700,
//               //                         color: AppColor.positiveGreen,
//               //                       ),
//               //                     ),
//               //                     const SizedBox(width: 8),
//               //                     Image.asset(
//               //                       AppImages.rightStickArrow,
//               //                       height: 13,
//               //                       color: AppColor.positiveGreen,
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ],
//               //             ),
//               //           ),
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               SizedBox(height: 20),
//               // History header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     Text(
//                       'History',
//                       style: AppTextStyles.mulish(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 28,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: _openDateFilterSheet,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12.8,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColor.textWhite,
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [Image.asset(AppImages.filter, height: 16)],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 26),
//
//               // ✅ Segment chips (CLICK -> local filter only)
//               SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: List.generate(segments.length, (index) {
//                     final isSelected = selectedIndex == index;
//
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() => selectedIndex = index); // ✅ no API call
//                       },
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 7),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 28,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected ? Colors.white : Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: isSelected ? Colors.black : Colors.grey,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: Text(
//                           segments[index],
//                           style: AppTextStyles.mulish(
//                             color: isSelected ? AppColor.darkBlue : Colors.grey,
//                             fontWeight: isSelected
//                                 ? FontWeight.w800
//                                 : FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               if (sections.isEmpty) ...[
//                 const SizedBox(height: 25),
//                 Center(
//                   child: Text(
//                     "No history found",
//                     style: AppTextStyles.mulish(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: AppColor.darkGrey,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//               ] else ...[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       for (final sec in sections) ...[
//                         Center(
//                           child: Text(
//                             sec.dayLabel,
//                             style: AppTextStyles.mulish(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                               color: AppColor.darkGrey,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         for (final item in sec.items) ...[
//                           CommonContainer.walletHistoryBox(
//                             upiTexts: false,
//                             containerColor: _rowBgSmart(
//                               badgeType: item.badgeType,
//                               badgeLabel: item.badgeLabel,
//                             ),
//                             mainText: item.title,
//                             timeText: item.timeLabel,
//                             numberText: "${item.amountSign}${item.amountTcoin}",
//                             endText: item.badgeLabel,
//                             numberTextColor: _badgeColorSmart(
//                               badgeType: item.badgeType,
//                               badgeLabel: item.badgeLabel,
//                             ),
//                             endTextColor: _badgeColorSmart(
//                               badgeType: item.badgeType,
//                               badgeLabel: item.badgeLabel,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                         const SizedBox(height: 10),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class QrScanPayload {
//   final String? toUid;
//   final String? shopId;
//   final String? action;
//   final List<String> options;
//
//   const QrScanPayload({
//     this.toUid,
//     this.shopId,
//     this.action,
//     this.options = const [],
//   });
//
//   bool get hasUid => (toUid ?? '').trim().isNotEmpty;
//   bool get hasShop => (shopId ?? '').trim().isNotEmpty;
//
//   // optional flags (if your backend sends options)
//   bool get canPay => options.contains('SEND_TCOIN') || hasUid;
//   bool get canReview => options.contains('REVIEW') || hasShop;
//
//   static QrScanPayload fromScanValue(String raw) {
//     final v = raw.trim();
//     if (v.isEmpty) return const QrScanPayload();
//
//     // 1) Try URI parsing
//     final uri = Uri.tryParse(v);
//
//     // 1A) payload base64url JSON: hoppr://qr?payload=BASE64URL_JSON
//     final payloadParam = uri?.queryParameters['payload'];
//     if (payloadParam != null && payloadParam.trim().isNotEmpty) {
//       final jsonMap = _tryDecodePayloadToJson(payloadParam.trim());
//       if (jsonMap != null) return _fromJsonMap(jsonMap);
//       // if payload decode failed, continue to other strategies
//     }
//
//     // 1B) direct query params: hoppr://qr?toUid=...&shopId=...
//     if (uri != null && uri.queryParameters.isNotEmpty) {
//       final qp = uri.queryParameters;
//       final toUid = _pick(qp, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
//       final shopId = _pick(qp, ['shopId', 'shopID', 'shop_id', 'shop']);
//       if ((toUid ?? '').trim().isNotEmpty || (shopId ?? '').trim().isNotEmpty) {
//         return QrScanPayload(
//           toUid: toUid?.trim(),
//           shopId: shopId?.trim(),
//           action: _pick(qp, ['action'])?.trim(),
//           options: const [],
//         );
//       }
//     }
//
//     // 2) Try JSON directly (some QR stores raw JSON)
//     final jsonMapDirect = _tryJsonDecode(v);
//     if (jsonMapDirect != null) return _fromJsonMap(jsonMapDirect);
//
//     // 3) Plain UID (customer QR): UIDA8189F085
//     final onlyUid = _extractUid(v);
//     if (onlyUid != null) {
//       return QrScanPayload(toUid: onlyUid, options: const ['SEND_TCOIN']);
//     }
//
//     // 4) If nothing matched
//     return const QrScanPayload();
//   }
//
//   static QrScanPayload _fromJsonMap(Map<String, dynamic> m) {
//     final toUid = _pick(m, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
//     final shopId = _pick(m, ['shopId', 'shopID', 'shop_id', 'shop']);
//     final action = _pick(m, ['action', 'act']);
//
//     return QrScanPayload(
//       toUid: toUid?.toString().trim(),
//       shopId: shopId?.toString().trim(),
//       action: action?.toString().trim(),
//       options: _readOptions(m),
//     );
//   }
//
//   static Map<String, dynamic>? _tryDecodePayloadToJson(String b64url) {
//     try {
//       var s = b64url.replaceAll('-', '+').replaceAll('_', '/');
//       while (s.length % 4 != 0) {
//         s += '=';
//       }
//       final bytes = base64Decode(s);
//       final decoded = utf8.decode(bytes);
//       final map = jsonDecode(decoded);
//       return (map as Map).cast<String, dynamic>();
//     } catch (_) {
//       // also try normal base64 (some apps use standard base64)
//       try {
//         final bytes = base64Decode(b64url);
//         final decoded = utf8.decode(bytes);
//         final map = jsonDecode(decoded);
//         return (map as Map).cast<String, dynamic>();
//       } catch (_) {
//         return null;
//       }
//     }
//   }
//
//   static Map<String, dynamic>? _tryJsonDecode(String v) {
//     try {
//       final map = jsonDecode(v);
//       if (map is Map) return map.cast<String, dynamic>();
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }
//
//   static String? _extractUid(String v) {
//     // support: "UIDA8189F085" OR "UID: UIDA8189F085" OR "toUid=UIDA..."
//     final m = RegExp(r'(UID[A-Za-z0-9]+)', caseSensitive: false).firstMatch(v);
//     return m?.group(1)?.toUpperCase();
//   }
//
//   static String? _pick(Map m, List<String> keys) {
//     for (final k in keys) {
//       if (m.containsKey(k) && (m[k]?.toString().trim().isNotEmpty ?? false)) {
//         return m[k].toString();
//       }
//     }
//     return null;
//   }
//
//   static List<String> _readOptions(Map<String, dynamic> jsonMap) {
//     final opts = jsonMap['options'];
//     if (opts is List) {
//       return opts
//           .map((e) {
//             if (e is Map) {
//               return (e['key'] ?? e['code'] ?? e['name'])?.toString();
//             }
//             return e?.toString();
//           })
//           .whereType<String>()
//           .map((e) => e.trim().toUpperCase())
//           .where((e) => e.isNotEmpty)
//           .toList();
//     }
//     return const [];
//   }
// }
