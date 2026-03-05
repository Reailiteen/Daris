import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/study_task.dart';
import '../../balance/controller/balance_controller.dart';
import '../../tasks/controller/tasks_controller.dart';
import '../../subjects/controller/subjects_controller.dart';

class EarnTab extends StatelessWidget {
  const EarnTab({super.key});

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
              Text(
                'Earn',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Study to earn screen time',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
              ),
              const SizedBox(height: 20),

              // Balance card
              const _BalanceCard(),
              const SizedBox(height: 24),

              // My Subjects
              _SectionHeader(
                title: 'My Subjects',
                isDark: isDark,
                trailing: GestureDetector(
                  onTap: () => _showAddSubjectSheet(context, isDark),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: AppColors.accentPurple, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _SubjectsChipList(),
              const SizedBox(height: 24),

              // Reward reference
              const _RewardReference(),
              const SizedBox(height: 24),

              // Tasks section
              _SectionHeader(
                title: 'Complete a Task',
                isDark: isDark,
                trailing: GestureDetector(
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
              ),
              const SizedBox(height: 10),
              const _TasksPreview(),
              const SizedBox(height: 24),

              // AI Quiz section
              _SectionHeader(title: 'Quick Quiz', isDark: isDark),
              const SizedBox(height: 4),
              Text(
                'Answer AI-generated questions to earn screen time',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 10),
              const _QuizSubjectChips(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectSheet(BuildContext context, bool isDark) {
    final textCtrl = TextEditingController();
    final subjectsCtrl = Get.find<SubjectsController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E2228) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Subject',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textCtrl,
              autofocus: true,
              style:
                  TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'e.g. Calculus, Physics...',
                hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  subjectsCtrl.addSubject(value.trim());
                  Navigator.of(ctx).pop();
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.accentPurple,
                ),
                onPressed: () {
                  final name = textCtrl.text.trim();
                  if (name.isEmpty) return;
                  subjectsCtrl.addSubject(name);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Section Header

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.trailing,
  });

  final String title;
  final bool isDark;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// MARK: - Balance Card

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

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
                'earned this week  ·  ${300 - earned}m until unlimited',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
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

// MARK: - Subjects Chip List

class _SubjectsChipList extends StatelessWidget {
  const _SubjectsChipList();

  @override
  Widget build(BuildContext context) {
    final subjectsCtrl = Get.find<SubjectsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final subjects = subjectsCtrl.subjects;
      if (subjects.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.school_outlined,
                  color: isDark ? Colors.white30 : Colors.black26, size: 20),
              const SizedBox(width: 10),
              Text(
                'No subjects yet. Tap + to add one.',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: subjects.map((s) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.accentPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : AppColors.accentPurple,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => subjectsCtrl.deleteSubject(s.id),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

// MARK: - Reward Reference

class _RewardReference extends StatelessWidget {
  const _RewardReference();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text(
                'How you earn',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _rewardRow('Small task', '+10m', isDark),
          _rewardRow('Medium task', '+25m', isDark),
          _rewardRow('Hard task', '+60m', isDark),
          _rewardRow('1 correct answer', '+2m', isDark),
          _rewardRow('5/5 perfect quiz', '+5m bonus', isDark),
          const SizedBox(height: 6),
          Text(
            '300m earned = unlimited for the week. Resets every Monday.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardRow(String action, String reward, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          Text(
            reward,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Tasks Preview

class _TasksPreview extends StatelessWidget {
  const _TasksPreview();

  @override
  Widget build(BuildContext context) {
    final tasksCtrl = Get.find<TasksController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
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
                const Icon(Icons.add_circle_outline,
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${task.difficulty.label}  ·  +${task.rewardMinutes}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
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
    });
  }
}

// MARK: - Quiz Subject Chips

class _QuizSubjectChips extends StatelessWidget {
  const _QuizSubjectChips();

  @override
  Widget build(BuildContext context) {
    final subjectsCtrl = Get.find<SubjectsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final subjects = subjectsCtrl.subjects;
      if (subjects.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Add subjects above to start quizzes',
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
    });
  }
}
