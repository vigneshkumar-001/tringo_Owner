import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Presentation/Create%20App%20Offer/Controller/offer_notifier.dart';
import 'package:tringo_vendor/Presentation/Home/Controller/home_notifier.dart';

import '../../AboutMe/controller/about_me_notifier.dart';


final selectedShopProvider =
StateNotifierProvider<SelectedShopNotifier, String?>(
      (ref) => SelectedShopNotifier(ref),
);

class SelectedShopNotifier extends StateNotifier<String?> {
  final Ref ref;

  SelectedShopNotifier(this.ref) : super(null);

  Future<void> switchShop(String shopId) async {
    state = shopId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentShopId', shopId);

    // 🔥 FIRE ALL DEPENDENT APIS HERE
    await Future.wait([
      ref.read(homeNotifierProvider.notifier)
          .fetchShops(shopId: shopId),
      ref.read(homeNotifierProvider.notifier)
          .fetchAllEnquiry(shopId: shopId),
      ref.read(aboutMeNotifierProvider.notifier)
          .fetchAllShopDetails(shopId: shopId),
      ref.read(offerNotifierProvider.notifier)
          .offerScreenEnquiry(shopId: shopId),
    ]);
  }
}
