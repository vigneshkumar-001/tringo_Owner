
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';

// 👇 add this to read premium/non-premium
import 'package:tringo_vendor/Core/Session/registration_session.dart';

// Your screens
import 'package:tringo_vendor/Presentation/Home/Screens/home_screens.dart';
import 'package:tringo_vendor/Presentation/Enquiry/Screens/enquiry_screens.dart';
import 'package:tringo_vendor/Presentation/AboutMe/Screens/about_me_screens.dart';
import 'package:tringo_vendor/Presentation/Menu/Screens/menu_screens.dart';

import '../../Presentation/Offer/Screen/offer_screens.dart';
import '../../Presentation/Offer/Screen/premium_offers.dart';
import '../Session/registration_product_seivice.dart';

class CommonBottomNavigation extends StatefulWidget {
  final int initialIndex;
  final int? initialAboutMeTab;
  const CommonBottomNavigation({
    super.key,
    this.initialIndex = 0,
    this.initialAboutMeTab,
  });

  @override
  CommonBottomNavigationState createState() => CommonBottomNavigationState();
}

class CommonBottomNavigationState extends State<CommonBottomNavigation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;
    _prevIndex = _selectedIndex;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _updateSlideAnimation();
  }

  // 👉 Build the page on demand so it always sees latest businessType
  ///new///
  Widget _pageForIndex(int index) {
    final regPS = RegistrationProductSeivice.instance;
    final bool isPremium = regPS.isPremium; // company = premium

    switch (index) {
      case 0:
        return const HomeScreens();
      case 1:
        return const EnquiryScreens();
      case 2:
      // 🔹 Company (premium) → PremiumOffers
      // 🔹 Individual / null (non-premium) → OfferScreens
        return isPremium
            ? PremiumOffers()          // PREMIUM (company)
            : const OfferScreens();    // NON-PREMIUM (individual)
      case 3:
        return AboutMeScreens(initialTab: widget.initialAboutMeTab ?? 0,);
      case 4:
        return const MenuScreens(page : "bottomScreen");
      default:
        return const SizedBox.shrink();
    }
  }


  ///old///
  // Widget _pageForIndex(int index) {
  //   final bt = RegistrationSession.instance.businessType;
  //
  //   switch (index) {
  //     case 0:
  //       // If you have HomeScreens(showUpgradeOnFirstVisit: true) keep that param.
  //       return const HomeScreens();
  //     case 1:
  //       return const EnquiryScreens();
  //     case 2:
  //       // Company => premium; Individual => non-premium
  //       return (bt == BusinessType.company)
  //           ? PremiumOffers()
  //           : const OfferScreens();
  //     case 3:
  //       return AboutMeScreens(initialTab: widget.initialAboutMeTab ?? 0);
  //     case 4:
  //       return const MenuScreens();
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }

  void _updateSlideAnimation() {
    _slideAnimation =
        Tween<Offset>(
          begin: _selectedIndex > _prevIndex
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animation_controller_forward();
  }

  void _animation_controller_forward() {
    _animationController.forward(from: 0.0);
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _prevIndex = _selectedIndex;
      _selectedIndex = index;

      _slideAnimation =
          Tween<Offset>(
            begin: _selectedIndex > _prevIndex
                ? const Offset(1.0, 0.0)
                : const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

      _animationController.reset();
      _animation_controller_forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build current/previous from _pageForIndex so they reflect latest session
    final Widget current = KeyedSubtree(
      key: ValueKey('page-$_selectedIndex'),
      child: _pageForIndex(_selectedIndex),
    );

    final Widget? previous = (_selectedIndex == _prevIndex)
        ? null
        : KeyedSubtree(
            key: ValueKey('page-$_prevIndex'),
            child: _pageForIndex(_prevIndex),
          );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            if (previous != null) previous,
            (_selectedIndex == _prevIndex)
                ? current
                : SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: current,
                    ),
                  ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: AppColor.white,
              type: BottomNavigationBarType.fixed,
              elevation: 1,
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              selectedItemColor: AppColor.black,
              unselectedItemColor: AppColor.darkGrey,
              selectedLabelStyle: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.home, height: 26),
                  activeIcon: Image.asset(AppImages.homeFill, height: 30),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.enquiry, height: 26),
                  activeIcon: Image.asset(AppImages.enquiryFill, height: 30),
                  label: 'Enquiry',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.offer, height: 26),
                  activeIcon: Image.asset(AppImages.offerFill, height: 30),
                  label: 'Offers',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.aboutMe, height: 26),
                  activeIcon: Image.asset(AppImages.aboutMeFill, height: 30),
                  label: 'AboutMe',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.menu, height: 26),
                  activeIcon: Image.asset(
                    AppImages.menu,
                    height: 30,
                    color: AppColor.black,
                  ),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


