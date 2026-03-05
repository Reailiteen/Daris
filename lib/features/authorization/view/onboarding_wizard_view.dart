import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class OnboardingWizardView extends GetView<AuthController> {
  const OnboardingWizardView({super.key});

  static const List<String> _categories = [
    'social',
    'gaming',
    'entertainment',
    'news',
    'shopping',
  ];

  static const Map<String, String> _categoryLabels = {
    'social': 'Social Media',
    'gaming': 'Gaming',
    'entertainment': 'Entertainment',
    'news': 'News',
    'shopping': 'Shopping',
  };

  static const Map<String, IconData> _categoryIcons = {
    'social': Icons.people_rounded,
    'gaming': Icons.sports_esports_rounded,
    'entertainment': Icons.movie_rounded,
    'news': Icons.article_rounded,
    'shopping': Icons.shopping_bag_rounded,
  };

  @override
  Widget build(BuildContext context) {
    controller.loadUserSettings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Obx(() => _StepIndicator(
                          currentStep: controller.onboardingStep.value,
                          totalSteps: 2,
                          isDark: isDark,
                        )),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          'Step ${controller.onboardingStep.value + 1} of 2',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                        )),
                  ],
                ),
              ),

              // Step content
              Expanded(
                child: Obx(() {
                  switch (controller.onboardingStep.value) {
                    case 0:
                      return _Step1ScreenTime(isDark: isDark);
                    case 1:
                      return _Step3BlockingCategories(
                          isDark: isDark,
                          categories: _categories,
                          categoryLabels: _categoryLabels,
                          categoryIcons: _categoryIcons);
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Obx(() {
                  final step = controller.onboardingStep.value;
                  final isLoading = controller.isLoading.value;
                  return Column(
                    children: [
                      if (controller.errorMessage.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            controller.errorMessage.value!,
                            style:
                                const TextStyle(color: AppColors.accentRed),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      AuthGradientButton(
                        label: isLoading
                            ? null
                            : (step < 1 ? 'Continue' : 'Get Started'),
                        onTap: isLoading
                            ? null
                            : () {
                                if (step < 1) {
                                  controller.saveStepAndAdvance();
                                } else {
                                  controller.finishOnboarding();
                                }
                              },
                      ),
                      if (step > 0) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => controller.onboardingStep.value--,
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: - Step Indicator

class _StepIndicator extends StatelessWidget {
  const _StepIndicator(
      {required this.currentStep,
      required this.totalSteps,
      required this.isDark});

  final int currentStep;
  final int totalSteps;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: isActive || isDone ? AppColors.primaryGradient : null,
              color: isActive || isDone
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.08)),
            ),
          ),
        );
      }),
    );
  }
}

// MARK: - Step 1: Weekly Screen Time

class _Step1ScreenTime extends GetView<AuthController> {
  const _Step1ScreenTime({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_rounded,
                size: 56, color: AppColors.accentTeal),
          ),
          const SizedBox(height: 32),
          Text(
            'Weekly Screen Time',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'How much free screen time do you want each week?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Obx(() {
            final minutes = controller.weeklyScreenTimeMinutes.value;
            final hours = minutes ~/ 60;
            final mins = minutes % 60;
            final label = hours > 0
                ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
                : '${mins}m';
            return Column(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              AppColors.accentPurple,
                              AppColors.accentBlue
                            ],
                          ).createShader(
                              const Rect.fromLTWH(0, 0, 120, 60)),
                      ),
                ),
                Text(
                  'per week',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                ),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.accentPurple,
                    inactiveTrackColor: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
                    thumbColor: AppColors.accentPurple,
                    overlayColor: AppColors.accentPurple.withOpacity(0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: minutes.toDouble(),
                    min: 30,
                    max: 600,
                    divisions: 19,
                    onChanged: (v) =>
                        controller.weeklyScreenTimeMinutes.value = v.toInt(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('30m',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38)),
                    Text('10h',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38)),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// MARK: - Step 2: Blocking Categories

class _Step3BlockingCategories extends GetView<AuthController> {
  const _Step3BlockingCategories({
    required this.isDark,
    required this.categories,
    required this.categoryLabels,
    required this.categoryIcons,
  });

  final bool isDark;
  final List<String> categories;
  final Map<String, String> categoryLabels;
  final Map<String, IconData> categoryIcons;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Blocking Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Which app categories should be blocked during focus sessions?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You can change this later in settings.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Obx(() => Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: categories.map((cat) {
                  final isSelected =
                      controller.blockingCategories.contains(cat);
                  return _CategoryChip(
                    label: categoryLabels[cat]!,
                    icon: categoryIcons[cat]!,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () =>
                        controller.toggleBlockingCategory(cat),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.08)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18, color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
