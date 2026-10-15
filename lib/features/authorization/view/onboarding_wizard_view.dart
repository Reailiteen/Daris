import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_widgets.dart';

// ─────────────────────────────────────────────
// Screens:  0 & 1 = intro slides (no step bar)
//           2, 3, 4 = wizard steps (step bar)
// ─────────────────────────────────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.flat(isDark)),
        child: SafeArea(
          child: Obx(() {
            final step = controller.onboardingStep.value;
            final isIntro = step < 2;
            final wizardStep = step - 2; // 0..2 for steps 2-4
            final isLoading = controller.isLoading.value;

            return Column(
              children: [
                // ── Header (wizard only) ──────────────────────────
                if (!isIntro)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        _StepIndicator(
                          currentStep: wizardStep,
                          totalSteps: 2,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step ${wizardStep + 1} of 2',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                        ),
                      ],
                    ),
                  ),

                // ── Content ──────────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0.06, 0),
                                end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: anim, curve: Curves.easeOut)),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(step),
                      child: switch (step) {
                        0 => _Slide1Welcome(isDark: isDark),
                        1 => _Slide2HowItWorks(isDark: isDark),
                        2 => _StepPersonalInfo(isDark: isDark),
                        3 => _StepPhoneHabits(
                            isDark: isDark,
                            categories: _categories,
                            categoryLabels: _categoryLabels,
                            categoryIcons: _categoryIcons,
                          ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ),

                // ── Bottom actions ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      if (controller.errorMessage.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            controller.errorMessage.value!,
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      AuthGradientButton(
                        label: isLoading
                            ? null
                            : _buttonLabel(step),
                        onTap: isLoading
                            ? null
                            : () => _onContinue(step),
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
                                color: isDark ? Colors.white54 : Colors.black54),
                          ),
                        ),
                      ] else
                        const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _buttonLabel(int step) {
    if (step == 3) return 'Start Studying';
    if (step < 2) return 'Next';
    return 'Continue';
  }

  void _onContinue(int step) {
    if (step == 3) {
      controller.finishOnboarding();
    } else {
      controller.advanceStep();
    }
  }
}

// ─────────────────────────────────────────────
// Step Indicator (wizard steps 2-4)
// ─────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.isDark,
  });
  final int currentStep;
  final int totalSteps;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final filled = i <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: filled ? AppColors.primaryGradient : null,
              color: filled
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

// ─────────────────────────────────────────────
// Slide 0 — Welcome
// ─────────────────────────────────────────────

class _Slide1Welcome extends StatelessWidget {
  const _Slide1Welcome({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Icon
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 58),
          ),
          const SizedBox(height: 32),

          Text(
            'Welcome to Daris',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your study sessions pay for your screen time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Feature rows
          _FeatureRow(
            icon: Icons.menu_book_rounded,
            color: AppColors.primary,
            title: 'Study to earn',
            subtitle: 'Complete tasks and answer AI quizzes to earn screen time minutes.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.phone_android_rounded,
            color: AppColors.primary,
            title: 'Spend wisely',
            subtitle: 'Use your earned minutes for social media, gaming, and more.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.emoji_events_rounded,
            color: AppColors.accentOrange,
            title: 'Unlock unlimited',
            subtitle: 'Earn 300 minutes in a week and enjoy unlimited screen time until Monday.',
            isDark: isDark,
          ),

          const SizedBox(height: 40),
          // Slide dots
          _SlideDots(current: 0, isDark: isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Slide 1 — How It Works
// ─────────────────────────────────────────────

class _Slide2HowItWorks extends StatelessWidget {
  const _Slide2HowItWorks({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Two ways to earn',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick whichever fits your mood.',
            style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black45),
          ),
          const SizedBox(height: 28),

          // System A
          _EarnCard(
            gradient: AppColors.primaryGradient,
            icon: Icons.check_circle_outline_rounded,
            title: 'Study Tasks',
            rows: const [
              ('Small task (quiz)', '+10 min'),
              ('Medium task (assignment)', '+25 min'),
              ('Hard task (exam / project)', '+60 min'),
            ],
          ),
          const SizedBox(height: 14),

          // System B
          _EarnCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF26A69A), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.quiz_rounded,
            title: 'AI Quiz',
            rows: const [
              ('1 correct answer', '+2 min'),
              ('Perfect score (5/5)', '+5 min bonus'),
              ('Unlock Quiz (10 mixed Qs)', '+60 min flat'),
            ],
          ),
          const SizedBox(height: 28),

          // Weekly reset note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black38),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Balance resets every Monday. Earn 300 min to unlock unlimited for the week.',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Center(child: _SlideDots(current: 1, isDark: isDark)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 1 (screen 2) — Personal Info
// ─────────────────────────────────────────────

class _StepPersonalInfo extends GetView<AuthController> {
  const _StepPersonalInfo({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 52, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "Let's get personal",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'So we can greet you properly.',
            style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black45),
          ),
          const SizedBox(height: 36),

          Text(
            'First name',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54),
          ),
          const SizedBox(height: 8),
          Obx(() => _OnboardingField(
                initialValue: controller.firstName.value,
                hint: 'e.g. Majed',
                isDark: isDark,
                autofocus: false,
                onChanged: (v) => controller.firstName.value = v,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 2 (screen 3) — Phone Habits
// ─────────────────────────────────────────────

class _StepPhoneHabits extends GetView<AuthController> {
  const _StepPhoneHabits({
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_android_rounded,
                  size: 52, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Your phone habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Be honest — this helps us set you up right.',
            style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black45),
          ),
          const SizedBox(height: 32),

          // Weekly screen time slider
          Text(
            'Weekly screen time goal',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'How much time do you want to allow yourself per week?',
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45),
          ),
          const SizedBox(height: 20),

          Obx(() {
            final minutes = controller.weeklyScreenTimeMinutes.value;
            final hours = minutes ~/ 60;
            final mins = minutes % 60;
            final label = hours > 0
                ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
                : '${mins}m';
            return Column(
              children: [
                Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.success
                              ],
                            ).createShader(
                                const Rect.fromLTWH(0, 0, 120, 60)),
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
                    thumbColor: AppColors.primary,
                    overlayColor:
                        AppColors.primary.withOpacity(0.15),
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

          const SizedBox(height: 32),
          Container(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06)),
          const SizedBox(height: 28),

          // Distraction categories
          Text(
            'Apps that kill your focus',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Which categories do you waste the most time on?',
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45),
          ),
          const SizedBox(height: 16),

          Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((cat) {
                  final selected = controller.blockingCategories.contains(cat);
                  return _CategoryChip(
                    label: categoryLabels[cat]!,
                    icon: categoryIcons[cat]!,
                    isSelected: selected,
                    isDark: isDark,
                    onTap: () => controller.toggleBlockingCategory(cat),
                  );
                }).toList(),
              )),
          const SizedBox(height: 8),
          Text(
            'These categories will be blocked during focus sessions.',
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white30 : Colors.black38),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 3 (screen 4) — Subjects
// ─────────────────────────────────────────────

class _StepSubjects extends GetView<AuthController> {
  const _StepSubjects({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What are you studying?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add your subjects and semester plan — tasks get created automatically.',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45,
                    height: 1.4),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Subject list
        Expanded(
          child: Obx(() {
            final subjects = controller.onboardingSubjects;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                if (subjects.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_outlined,
                            color: isDark ? Colors.white24 : Colors.black26,
                            size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No subjects yet. You can skip and add them from the Earn tab later.',
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black45,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...subjects.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return _OnboardingSubjectCard(
                      subject: s,
                      isDark: isDark,
                      onDelete: () => controller.removeOnboardingSubject(i),
                    );
                  }),

                const SizedBox(height: 14),

                // Add subject button
                GestureDetector(
                  onTap: () => _showAddSheet(context, isDark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Add Subject',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OnboardingAddSubjectSheet(isDark: isDark),
    );
  }
}

// ─────────────────────────────────────────────
// Onboarding Subject Card
// ─────────────────────────────────────────────

class _OnboardingSubjectCard extends StatelessWidget {
  const _OnboardingSubjectCard({
    required this.subject,
    required this.isDark,
    required this.onDelete,
  });
  final Map<String, dynamic> subject;
  final bool isDark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = subject['name'] as String;
    final book = subject['syllabusBook'] as String?;
    final quizzes = (subject['numQuizzes'] as int?) ?? 0;
    final assignments = (subject['numAssignments'] as int?) ?? 0;
    final midterms = (subject['numMidterms'] as int?) ?? 0;
    final finals = (subject['numFinals'] as int?) ?? 0;
    final projects = (subject['numProjects'] as int?) ?? 0;
    final total = quizzes + assignments + midterms + finals + projects;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.school_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                if (book != null && book.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(book,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45)),
                ],
                if (total > 0) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (quizzes > 0)
                        _SmallPill('$quizzes Quiz${quizzes > 1 ? "zes" : ""}',
                            AppColors.primary),
                      if (assignments > 0)
                        _SmallPill(
                            '$assignments Assign${assignments > 1 ? "ments" : "ment"}',
                            AppColors.success),
                      if (midterms > 0)
                        _SmallPill(
                            '$midterms Midterm${midterms > 1 ? "s" : ""}',
                            AppColors.accentOrange),
                      if (finals > 0)
                        _SmallPill(
                            '$finals Final${finals > 1 ? "s" : ""}',
                            AppColors.error),
                      if (projects > 0)
                        _SmallPill(
                            '$projects Project${projects > 1 ? "s" : ""}',
                            AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$total tasks created automatically',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.black38)),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline_rounded,
                size: 18,
                color: isDark ? Colors.white24 : Colors.black26),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add Subject Sheet (onboarding — stores locally)
// ─────────────────────────────────────────────

class _OnboardingAddSubjectSheet extends StatefulWidget {
  const _OnboardingAddSubjectSheet({required this.isDark});
  final bool isDark;

  @override
  State<_OnboardingAddSubjectSheet> createState() =>
      _OnboardingAddSubjectSheetState();
}

class _OnboardingAddSubjectSheetState
    extends State<_OnboardingAddSubjectSheet> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _bookCtrl = TextEditingController();
  int _quizzes = 0, _assignments = 0, _midterms = 0, _finals = 0, _projects = 0;

  int get _total => _quizzes + _assignments + _midterms + _finals + _projects;
  int get _minutes =>
      _quizzes * 10 + _assignments * 25 + (_midterms + _finals + _projects) * 60;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bookCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1E24) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildStepDots(isDark),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.05, 0), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: _step == 0
                    ? _buildStep1(isDark)
                    : _buildStep2(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDots(bool isDark) {
    return Row(
      children: [
        _dot(0, isDark),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              gradient: _step >= 1 ? AppColors.primaryGradient : null,
              color: _step >= 1 ? null : (isDark ? Colors.white12 : Colors.black12),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _dot(1, isDark),
      ],
    );
  }

  Widget _dot(int index, bool isDark) {
    final active = _step >= index;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : (isDark ? Colors.white12 : Colors.black12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text('${index + 1}',
            style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.black38),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      key: const ValueKey('s1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject Details',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Text('Name and textbook',
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45)),
        const SizedBox(height: 24),
        _label('Subject Name', isDark),
        const SizedBox(height: 8),
        _field(_nameCtrl, 'e.g. Calculus I', isDark, autofocus: true),
        const SizedBox(height: 16),
        _label('Textbook / Syllabus (optional)', isDark),
        const SizedBox(height: 8),
        _field(_bookCtrl, 'e.g. Stewart Calculus 8th Edition', isDark),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              setState(() => _step = 1);
            },
            child: const Text('Continue',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Column(
      key: const ValueKey('s2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Semester Plan',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Text('How many of each? Tasks are auto-created.',
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.4)),
        const SizedBox(height: 20),
        _stepper('Quizzes', _quizzes, AppColors.primary, isDark,
            (v) => setState(() => _quizzes = v)),
        _stepper('Assignments', _assignments, AppColors.success, isDark,
            (v) => setState(() => _assignments = v)),
        _stepper('Midterms', _midterms, AppColors.accentOrange, isDark,
            (v) => setState(() => _midterms = v)),
        _stepper('Finals', _finals, AppColors.error, isDark,
            (v) => setState(() => _finals = v)),
        _stepper('Projects', _projects, AppColors.primary, isDark,
            (v) => setState(() => _projects = v)),
        if (_total > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Creates $_total tasks worth $_minutes minutes',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text('Back',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _save,
                child: const Text('Add Subject',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String text, bool isDark) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black54));

  Widget _field(TextEditingController ctrl, String hint, bool isDark,
      {bool autofocus = false}) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _stepper(String label, int value, Color color, bool isDark,
      ValueChanged<int> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87)),
          ),
          GestureDetector(
            onTap: value > 0 ? () => onChanged(value - 1) : null,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove,
                  size: 16,
                  color: value > 0
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
          ),
          GestureDetector(
            onTap: () => onChanged(value + 1),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final ctrl = Get.find<AuthController>();
    ctrl.addOnboardingSubject({
      'name': _nameCtrl.text.trim(),
      'syllabusBook':
          _bookCtrl.text.trim().isEmpty ? null : _bookCtrl.text.trim(),
      'numQuizzes': _quizzes,
      'numAssignments': _assignments,
      'numMidterms': _midterms,
      'numFinals': _finals,
      'numProjects': _projects,
    });
    if (mounted) Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────
// Support Widgets
// ─────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black54,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EarnCard extends StatelessWidget {
  const _EarnCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.rows,
  });
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(r.$1,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ),
                    Text(r.$2,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SlideDots extends StatelessWidget {
  const _SlideDots({required this.current, required this.isDark});
  final int current;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            gradient: active ? AppColors.primaryGradient : null,
            color: active
                ? null
                : (isDark ? Colors.white24 : Colors.black26),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
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
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87))),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// A simple uncontrolled text field that calls onChanged
class _OnboardingField extends StatefulWidget {
  const _OnboardingField({
    required this.initialValue,
    required this.hint,
    required this.isDark,
    required this.onChanged,
    this.autofocus = false,
  });
  final String initialValue;
  final String hint;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  State<_OnboardingField> createState() => _OnboardingFieldState();
}

class _OnboardingFieldState extends State<_OnboardingField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return TextField(
      controller: _ctrl,
      autofocus: widget.autofocus,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
