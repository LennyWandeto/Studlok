import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/components/studlok_button.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../home/home_screen.dart';
import 'onboarding_screens.dart';
import 'onboarding_steps.dart';
import 'onboarding_view_model.dart';

/// The whole onboarding experience as one screen: a shared shell (progress
/// dots + one consistently-positioned CTA) around a PageView of step
/// widgets, all driven by one [OnboardingViewModel]. Swiping is disabled —
/// progress is CTA-driven only — and transitions between steps are always
/// animated the same subtle way, so this reads as one continuous flow
/// rather than screens stacking on top of each other.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.startAt});

  final OnboardingStep startAt;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late final OnboardingViewModel _viewModel = OnboardingViewModel(startAt: widget.startAt);
  late final PageController _pageController = PageController(initialPage: _viewModel.stepIndex);

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_syncPage);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncPage);
    _viewModel.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage() {
    if (!_pageController.hasClients) return;
    if (_pageController.page?.round() == _viewModel.stepIndex) return;
    _pageController.animateToPage(
      _viewModel.stepIndex,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handlePrimaryAction() async {
    switch (_viewModel.step) {
      case OnboardingStep.welcome1:
      case OnboardingStep.welcome2:
      case OnboardingStep.personalization:
        _viewModel.next();
      case OnboardingStep.permissionPriming:
        final granted = await _viewModel.requestPermission();
        if (!granted && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PermissionDeniedScreen(viewModel: _viewModel)),
          );
        }
      case OnboardingStep.appPicker:
        await _viewModel.pickApps();
      case OnboardingStep.confirmed:
        await _viewModel.finish();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
    }
  }

  String _ctaLabel(OnboardingStep step) => switch (step) {
        OnboardingStep.welcome1 => 'CONTINUE',
        OnboardingStep.welcome2 => 'CONTINUE',
        OnboardingStep.personalization => 'CONTINUE',
        OnboardingStep.permissionPriming => 'CONTINUE',
        OnboardingStep.appPicker => 'CHOOSE APPS',
        OnboardingStep.confirmed => 'GO TO STUDLOK',
      };

  Widget _stepContent(OnboardingStep step) => switch (step) {
        OnboardingStep.welcome1 => const Welcome1Content(),
        OnboardingStep.welcome2 => const Welcome2Content(),
        OnboardingStep.personalization => const PersonalizationContent(),
        OnboardingStep.permissionPriming => const PermissionPrimingContent(),
        OnboardingStep.appPicker => const AppPickerContent(),
        OnboardingStep.confirmed => const ConfirmedContent(),
      };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: StudlokColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: StudlokSpacing.lg),
                  _ProgressDots(current: viewModel.stepIndex, total: viewModel.totalSteps),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: OnboardingStep.values.length,
                      itemBuilder: (context, index) {
                        final content = _stepContent(OnboardingStep.values[index]);
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            final page = _pageController.hasClients && _pageController.page != null
                                ? _pageController.page!
                                : _pageController.initialPage.toDouble();
                            final delta = (page - index).clamp(-1.0, 1.0);
                            return Opacity(
                              opacity: 1 - (delta.abs() * 0.7),
                              child: Transform.translate(offset: Offset(delta * 32, 0), child: child),
                            );
                          },
                          child: content,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(StudlokSpacing.xl),
                    child: StudlokButton(
                      label: _ctaLabel(viewModel.step),
                      onPressed: viewModel.isBusy ? null : _handlePrimaryAction,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: i == current ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i <= current ? StudlokColors.accent : StudlokColors.surface,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i != total - 1) const SizedBox(width: StudlokSpacing.xs),
        ],
      ],
    );
  }
}
