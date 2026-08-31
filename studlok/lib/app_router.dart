import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router_view_model.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_flow_screen.dart';
import 'onboarding/onboarding_view_model.dart';
import 'splash/splash_screen.dart';

/// Decides where a launch lands: onboarding (not yet authorized), straight
/// to the picker step (authorized but nothing selected), or Home (both
/// already done — onboarding never re-triggers). Pure View — the actual
/// decision lives in [AppRouterViewModel].
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppRouterViewModel(),
      child: Consumer<AppRouterViewModel>(
        builder: (context, viewModel, _) => switch (viewModel.route) {
          AppRoute.loading => const SplashScreen(),
          // A fresh, never-authorized launch gets the full flow starting at
          // welcome1; a returning launch that's authorized but hasn't
          // picked apps yet resumes directly at the app picker step.
          AppRoute.permissionPriming => const OnboardingFlowScreen(startAt: OnboardingStep.welcome1),
          AppRoute.appPicker => const OnboardingFlowScreen(startAt: OnboardingStep.appPicker),
          AppRoute.home => const HomeScreen(),
        },
      ),
    );
  }
}
