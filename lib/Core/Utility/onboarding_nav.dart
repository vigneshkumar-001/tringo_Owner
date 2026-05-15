import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:tringo_owner/Core/Routes/app_go_routes.dart';
import 'package:tringo_owner/Core/Utility/app_prefs.dart';

class OnboardingNav {
  OnboardingNav._();

  static Future<void> backToPreviousOrExit(GoRouter router) async {
    if (router.canPop()) {
      router.pop();
      return;
    }

    final step = (await AppPrefs.getOnboardingStep())?.trim().toLowerCase();
    final flags = await AppPrefs.getRegistrationFlags();
    final extra = <String, dynamic>{
      'isService': flags['isService'] == true,
      'isIndividual': flags['isIndividual'] == true,
    };

    if (step == 'step-2') {
      await AppPrefs.setOnboardingStep('step-1');
      router.goNamed(AppRoutes.ownerInfo, extra: extra);
      return;
    }
    if (step == 'step-3') {
      await AppPrefs.setOnboardingStep('step-2');
      router.goNamed(AppRoutes.shopCategoryInfo, extra: extra);
      return;
    }
    if (step == 'step-4') {
      await AppPrefs.setOnboardingStep('step-3');
      router.goNamed(AppRoutes.shopPhotoInfo, extra: 'onboarding');
      return;
    }
    if (step == 'step-5') {
      await AppPrefs.setOnboardingStep('step-4');
      router.goNamed(AppRoutes.searchKeyword);
      return;
    }

    // step-1 or unknown: exit
    await SystemNavigator.pop();
  }
}
