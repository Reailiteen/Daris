import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/home_controller.dart';
import '../widgets/active_session_card.dart';
import '../widgets/start_session_card.dart';
import '../../authorization/controller/authorization_controller.dart';
import '../../balance/controller/balance_controller.dart';
import '../../tasks/controller/tasks_controller.dart';
import '../../subjects/controller/subjects_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(isDark),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 20),

              if (AuthorizationController.isAuthorizationSkipped) ...[
                _buildAuthorizationBanner(isDark),
                const SizedBox(height: 16),
              ],

              // Balance card
              _BalanceCard(isDark: isDark),
              const SizedBox(height: 20),

              // Complete a Task section
              _TasksSection(isDark: isDark),
              const SizedBox(height: 20),

              // Quick Quiz section
              _QuizSection(isDark: isDark),
              const SizedBox(height: 20),

              // Deep Focus (optional)
              _buildSectionHeader(context, 'Deep Focus', isDark),
              const SizedBox(height: 10),
              Obx(() => controller.isSessionActive.value
                  ? const ActiveSessionCard()
                  : const StartSessionCard()),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
    } else {
      greeting = 'Good night';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
        ),
        Text(
          'Study & Earn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
    );
  }

  Widget _buildAuthorizationBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Screen Time Not Authorized',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus session features are disabled. Grant permission in Settings > Screen Time.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Balance Card

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final balance = Get.find<BalanceController>();

    return Obx(() {
      final isUnlimited = balance.isUnlimited;
      final earned = balance.earnedMinutesThisWeek.value;
      final progress = (earned / 300).clamp(0.0, 1.0);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Screen Time Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (isUnlimited)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'UNLIMITED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isUnlimited ? 'Unlimited!' : balance.formattedBalance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isUnlimited) ...[
              const SizedBox(height: 4),
              Text(
                'earned this week · ${300 - earned}m until unlimited',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              const Text(
                'You hit the 300-minute milestone! Enjoy your week.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// MARK: - Tasks Section

class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tasksCtrl = Get.find<TasksController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Complete a Task',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed('/tasks'),
              child: Text(
                'See all',
                style: TextStyle(
                  color: AppColors.accentPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final tasks = tasksCtrl.tasks.take(3).toList();
          if (tasks.isEmpty) {
            return GestureDetector(
              onTap: () => Get.toNamed('/tasks'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: AppColors.accentPurple, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Add your first study task',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: tasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color:
                                  isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${task.difficulty.label} · +${task.rewardMinutes}m',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => tasksCtrl.completeTask(task.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

// MARK: - Quiz Section

class _QuizSection extends StatelessWidget {
  const _QuizSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final subjectsCtrl = Get.find<SubjectsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Quiz',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Answer questions and earn screen time instantly',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final subjects = subjectsCtrl.subjects;
          if (subjects.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                ),
              ),
              child: Text(
                'Add subjects in onboarding or settings to start quizzes',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13,
                ),
              ),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((s) {
              return GestureDetector(
                onTap: () => Get.toNamed('/ai-questions'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.quiz_rounded,
                          color: Colors.white, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        s.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
