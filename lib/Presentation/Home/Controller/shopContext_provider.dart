import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';
import 'package:tringo_owner/Presentation/Home/Controller/home_notifier.dart';
import 'package:tringo_owner/Presentation/Menu/Controller/subscripe_notifier.dart';

import '../../AboutMe/controller/about_me_notifier.dart';

final selectedShopProvider =
    StateNotifierProvider<SelectedShopNotifier, String?>(
      (ref) => SelectedShopNotifier(ref),
    );

class SelectedShopNotifier extends StateNotifier<String?> {
  final Ref ref;

  SelectedShopNotifier(this.ref) : super(null);

  Future<void> switchShop(String shopId) async {
    final prefs = await SharedPreferences.getInstance();

    // Treat empty as "use last saved shop" (never overwrite persisted selection).
    final String effectiveShopId = shopId.trim().isNotEmpty
        ? shopId.trim()
        : (prefs.getString('currentShopId') ?? '').trim();

    if (effectiveShopId.isEmpty) {
      state = null;
      return;
    }

    state = effectiveShopId;
    await prefs.setString('currentShopId', effectiveShopId);

    // Keep HomeNotifier's selectedShopId in sync (Home refresh uses it).
    await ref.read(homeNotifierProvider.notifier).selectShop(effectiveShopId);

    // 🔥 FIRE ALL DEPENDENT APIS HERE
    await Future.wait([
      ref
          .read(homeNotifierProvider.notifier)
          .fetchShops(shopId: effectiveShopId, filter: ''),
      ref
          .read(homeNotifierProvider.notifier)
          .fetchAllEnquiry(shopId: effectiveShopId),
      ref
          .read(aboutMeNotifierProvider.notifier)
          .fetchAllShopDetails(shopId: effectiveShopId),
      ref
          .read(offerNotifierProvider.notifier)
          .offerScreenEnquiry(shopId: effectiveShopId),
      ref.read(subscriptionNotifier.notifier).getCurrentPlan(),
    ]);
  }
}
