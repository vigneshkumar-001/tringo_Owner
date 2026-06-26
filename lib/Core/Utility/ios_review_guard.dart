// iOS review hiding is now disabled. T-Coin wallet, Subscription and the
// Attract Customer cards are shown on iOS exactly like Android.
// To re-hide for an App Store review build, restore:
//   bool get isIOSReviewBuild => !kIsWeb && Platform.isIOS;
bool get isIOSReviewBuild => false;
