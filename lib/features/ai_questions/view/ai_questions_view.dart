import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../subjects/controller/subjects_controller.dart';
import '../controller/ai_questions_controller.dart';

class AIQuestionsView extends GetView<AIQuestionsController> {
  const AIQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient(isDark)),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _LoadingScreen(isDark: isDark);
            }
            if (controller.questions.isEmpty) {
              return _SubjectSelector(isDark: isDark);
            }
            if (controller.sessionComplete.value) {
              return _ResultsScreen(isDark: isDark);
            }
            return _QuestionScreen(isDark: isDark);
          }),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accentPurple),
          const SizedBox(height: 20),
          Text(
            'Generating questions...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectSelector extends GetView<AIQuestionsController> {
  const _SubjectSelector({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final subjectsCtrl = Get.find<SubjectsController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Quiz',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a subject to start a quiz and earn screen time',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Obx(() {
            final subjects = subjectsCtrl.subjects;
            if (subjects.isEmpty) {
              return Center(
                child: Text(
                  'No subjects added yet.\nGo back and add subjects first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 15,
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: subjects.map((s) {
                return GestureDetector(
                  onTap: () => controller.startSession(s.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.quiz_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          s.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 24),
          Text(
            'Earn 2 minutes per correct answer, +5 bonus for 5/5!',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionScreen extends GetView<AIQuestionsController> {
  const _QuestionScreen({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final q = controller.questions[controller.currentIndex.value];
      final total = controller.questions.length;
      final current = controller.currentIndex.value + 1;
      final selected = controller.selectedAnswer.value;

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.reset();
                    Get.back();
                  },
                  child: Icon(
                    Icons.close,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: current / total,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.black.withOpacity(0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accentPurple),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$current / $total',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              controller.currentSubject.value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              q.questionText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 32),
            ...List.generate(q.options.length, (i) {
              return _OptionCard(
                label: q.options[i],
                index: i,
                selected: selected,
                correctIndex: q.correctIndex,
                isDark: isDark,
                onTap: selected == null
                    ? () => controller.answerQuestion(i)
                    : null,
              );
            }),
            const Spacer(),
            if (selected != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.accentPurple,
                  ),
                  onPressed: controller.nextQuestion,
                  child: Text(
                    controller.currentIndex.value <
                            controller.questions.length - 1
                        ? 'Next Question'
                        : 'See Results',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.index,
    required this.selected,
    required this.correctIndex,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final int index;
  final int? selected;
  final int correctIndex;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    Color? bgColor;
    Color textColor = isDark ? Colors.white70 : Colors.black87;

    if (selected != null) {
      if (index == correctIndex) {
        borderColor = AppColors.accentGreen;
        bgColor = AppColors.accentGreen.withOpacity(0.12);
        textColor = AppColors.accentGreen;
      } else if (index == selected) {
        borderColor = AppColors.accentRed;
        bgColor = AppColors.accentRed.withOpacity(0.12);
        textColor = AppColors.accentRed;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor ??
              (isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ??
                (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08)),
            width: borderColor != null ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
            fontWeight:
                borderColor != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ResultsScreen extends GetView<AIQuestionsController> {
  const _ResultsScreen({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 56),
          ),
          const SizedBox(height: 32),
          Text(
            '${controller.correctCount.value} / ${controller.questions.length} Correct',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                'You earned ${controller.earnedMinutes} minutes of screen time!',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              )),
          if (controller.correctCount.value >= 5) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+5 bonus for perfect score!',
                style: TextStyle(
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.accentPurple,
              ),
              onPressed: () async {
                await controller.finishSession();
                controller.reset();
              },
              child: const Text(
                'Done',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              await controller.finishSession();
              final subject = controller.currentSubject.value;
              controller.reset();
              await controller.startSession(subject);
            },
            child: Text(
              'Study more',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
