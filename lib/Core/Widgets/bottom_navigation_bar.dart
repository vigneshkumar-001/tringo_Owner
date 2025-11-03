import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_vendor/Presentation/Home/Screens/home_screens.dart';

import '../../Presentation/AboutMe/Screens/about_me_screens.dart';
import '../../Presentation/Enquiry/Screens/enquiry_screens.dart';
import '../../Presentation/Menu/Screens/menu_screens.dart';
import '../../Presentation/Offer/Screen/offer_screens.dart';
import '../Const/app_color.dart';
import '../Const/app_images.dart';

class CommonBottomNavigation extends StatefulWidget {
  final int initialIndex;
  final int? openReceiptForPlanId;
  const CommonBottomNavigation({
    super.key,
    this.initialIndex = 0,
    this.openReceiptForPlanId,
  });

  @override
  CommonBottomNavigationState createState() => CommonBottomNavigationState();
}

class CommonBottomNavigationState extends State<CommonBottomNavigation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  // final TeacherListController teacherListController = Get.put(
  //   TeacherListController(),
  // );
  // final StudentHomeController controller = Get.put(StudentHomeController());
  late final List<Widget> _pages;

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

    _pages = [
      HomeScreens(),
      EnquiryScreens(),
      OfferScreens(),
      AboutMeScreens(),
      MenuScreens(),
    ];

    _updateSlideAnimation();
  }

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
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget current = KeyedSubtree(
      key: ValueKey('page-$_selectedIndex'),
      child: _pages[_selectedIndex],
    );

    final Widget? previous = (_selectedIndex == _prevIndex)
        ? null
        : KeyedSubtree(
            key: ValueKey('page-$_prevIndex'),
            child: _pages[_prevIndex],
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
                color: Colors.black.withOpacity(0.15), // Shadow color
                blurRadius: 15, // Spread of shadow
                offset: const Offset(0, -4), // Upward shadow
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
                  label: 'Offer',
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

/*
class CommonBottomNavigation extends StatefulWidget {
  final int initialIndex;
  final int? openReceiptForPlanId; // 👈 add this
  const CommonBottomNavigation({
    super.key,
    this.initialIndex = 0,
    this.openReceiptForPlanId,
  });

  @override
  CommonBottomNavigationState createState() => CommonBottomNavigationState();
}

class CommonBottomNavigationState extends State<CommonBottomNavigation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final TeacherListController teacherListController = Get.put(
    TeacherListController(),
  );

  final StudentHomeController controller = Get.put(StudentHomeController());
  late final List<Widget> _pages;

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

    // Store pages once so they don't refresh
    _pages = [
      HomeTab(),
      AnnouncementsScreen(),
      TaskScreen(),
      AttendenceScreen(),
      MoreScreen(openReceiptForPlanId: widget.openReceiptForPlanId),
    ];

    _updateSlideAnimation();
  }

  void _updateSlideAnimation() {
    _slideAnimation = Tween<Offset>(
      begin:
          _selectedIndex > _prevIndex
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward(from: 0.0);
  }

  */
/* void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _prevIndex = _selectedIndex;
      _selectedIndex = index;
      _animationController.reset();
      _updateSlideAnimation();
    });
  }*/ /*

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _prevIndex = _selectedIndex;
      _selectedIndex = index;

      // Slide direction based on index
      _slideAnimation = Tween<Offset>(
        begin:
            _selectedIndex > _prevIndex
                ? const Offset(1.0, 0.0) // slide from right
                : const Offset(-1.0, 0.0), // slide from left
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    final u = Uri.tryParse(s.trim());
    return u != null && (u.scheme == 'http' || u.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    // ==== FIX: guard against double mount of same page ====
    final Widget current = KeyedSubtree(
      key: ValueKey('page-$_selectedIndex'),
      child: _pages[_selectedIndex],
    );

    final Widget? previous =
        (_selectedIndex == _prevIndex)
            ? null
            : KeyedSubtree(
              key: ValueKey('page-$_prevIndex'),
              child: _pages[_prevIndex],
            );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            if (previous != null) previous,
            // If there is no previous page (first paint), don't animate.
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
        bottomNavigationBar: Obx(() {
          final siblings = controller.siblingsList;
          final activeStudent = siblings.firstWhere(
            (s) => s.isActive == true,
            orElse: () => siblings.first,
          );

          return BottomNavigationBar(
            backgroundColor: AppColor.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            selectedItemColor: AppColor.blueG2,
            unselectedItemColor: AppColor.lightBlack,
            selectedLabelStyle: GoogleFont.ibmPlexSans(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFont.ibmPlexSans(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(AppImages.bottum0, height: 26),
                activeIcon: Image.asset(AppImages.bottum0select, height: 30),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppImages.bottum3, height: 26),
                activeIcon: Image.asset(AppImages.bottum3select, height: 30),
                label: 'Announcements',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppImages.bottum1, height: 26),
                activeIcon: Image.asset(AppImages.bottum1select, height: 30),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppImages.bottum2, height: 26),
                activeIcon: Image.asset(AppImages.bottum2select, height: 30),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon:
                    (activeStudent.avatar != null &&
                            activeStudent.avatar.isNotEmpty)
                        ? ClipOval(
                          child: Image.network(
                            activeStudent.avatar,
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  AppImages.moreSimage1,
                                  height: 49,
                                  width: 30,
                                  fit: BoxFit.cover,
                                ),
                          ),
                        )
                        : Image.asset(
                          AppImages.moreSimage1,
                          height: 30,
                          width: 30,
                        ),
                activeIcon:
                    (activeStudent.avatar != null &&
                            activeStudent.avatar.isNotEmpty)
                        ? ClipOval(
                          child: Image.network(
                            activeStudent.avatar,
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  AppImages.moreSimage1,
                                  height: 49,
                                  width: 30,
                                  fit: BoxFit.cover,
                                ),
                          ),
                        )
                        : Image.asset(
                          AppImages.moreSimage1,
                          height: 30,
                          width: 30,
                        ),
                label: 'More',
              ),
            ],
          );
        }),
      ),
    );
  }
}
*/
