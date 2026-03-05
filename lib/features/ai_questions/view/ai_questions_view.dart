import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/study_question.dart';
import '../controller/ai_questions_controller.dart';

class AIQuestionsView extends StatefulWidget {
  const AIQuestionsView({super.key});

  @override
  State<AIQuestionsView> createState() => _AIQuestionsViewState();
}

class _AIQuestionsViewState extends State<AIQuestionsView> {
  late final AIQuestionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AIQuestionsController>();
    controller.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args?['unlock'] == true) {
        controller.startUnlockSession();
      } else if (args?['subjectName'] != null) {
        controller.startSession(
          args!['subjectName'] as String,
          syllabusBook: args['syllabusBook'] as String?,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration:
            BoxDecoration(color: AppColors.flat(isDark)),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _LoadingScreen(isDark: isDark);
            }
            if (controller.questions.isEmpty) {
              return _EmptyScreen(isDark: isDark);
            }
            if (controller.sessionComplete.value) {
              return _ResultsScreen(isDark: isDark, controller: controller);
            }
            return _QuestionScreen(isDark: isDark, controller: controller);
          }),
        ),
      ),
    );
  }
}

// MARK: - Loading

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            'Generating questions...',
            style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54),
          ),
        ],
      ),
    );
  }
}

// MARK: - Empty (no arguments provided)

class _EmptyScreen extends StatelessWidget {
  const _EmptyScreen({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const Spacer(),
          Text(
            'Navigate here from a subject card or the Unlock button.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38, fontSize: 15),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// MARK: - Question Screen (dispatcher for question types)

class _QuestionScreen extends StatelessWidget {
  const _QuestionScreen(
      {required this.isDark, required this.controller});
  final bool isDark;
  final AIQuestionsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final q = controller.questions[controller.currentIndex.value];
      final total = controller.questions.length;
      final current = controller.currentIndex.value + 1;

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.reset();
                    Get.back();
                  },
                  child: Icon(Icons.close,
                      color: isDark ? Colors.white54 : Colors.black45),
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
                          AppColors.success),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$current / $total',
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subject + type badge
            Row(
              children: [
                Text(
                  q.subject,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                _TypeBadge(type: q.type),
              ],
            ),
            const SizedBox(height: 14),

            // Question text
            Text(
              q.questionText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 28),

            // Question-type-specific content
            Expanded(
              child: switch (q.type) {
                QuestionType.multipleChoice =>
                  _MCQOptions(q: q, isDark: isDark, controller: controller),
                QuestionType.trueOrFalse =>
                  _TrueFalseOptions(q: q, isDark: isDark, controller: controller),
                QuestionType.openEnded =>
                  _OpenEndedSection(q: q, isDark: isDark, controller: controller),
              },
            ),
          ],
        ),
      );
    });
  }
}

// MARK: - Type badge

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final QuestionType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      QuestionType.multipleChoice => ('MCQ', AppColors.primaryLight),
      QuestionType.trueOrFalse => ('True / False', AppColors.primary),
      QuestionType.openEnded => ('Open-ended', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// MARK: - MCQ Options

class _MCQOptions extends StatelessWidget {
  const _MCQOptions(
      {required this.q, required this.isDark, required this.controller});
  final StudyQuestion q;
  final bool isDark;
  final AIQuestionsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedAnswer.value;
      const letters = ['A', 'B', 'C', 'D'];
      return Column(
        children: [
          ...List.generate(q.options.length, (i) {
            Color? border;
            Color? bg;
            Color text = isDark ? Colors.white70 : Colors.black87;
            Color badgeBg = AppColors.primary;

            if (selected != null) {
              if (i == q.correctIndex) {
                border = AppColors.success;
                bg = AppColors.success.withOpacity(0.12);
                text = AppColors.success;
                badgeBg = AppColors.success;
              } else if (i == selected) {
                border = AppColors.error;
                bg = AppColors.error.withOpacity(0.12);
                text = AppColors.error;
                badgeBg = AppColors.error;
              }
            }

            return GestureDetector(
              onTap: selected == null ? () => controller.answerQuestion(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bg ??
                      (isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.black.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: border ??
                        (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.08)),
                    width: border != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: badgeBg,
                      child: Text(
                        i < letters.length ? letters[i] : '${i + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(q.options[i],
                          style: TextStyle(
                              fontSize: 15,
                              color: text,
                              fontWeight: border != null
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          if (selected != null)
            _NextButton(
              label: controller.currentIndex.value <
                      controller.questions.length - 1
                  ? 'Next Question'
                  : 'See Results',
              onTap: controller.nextQuestion,
            ),
        ],
      );
    });
  }
}

// MARK: - True / False Options

class _TrueFalseOptions extends StatelessWidget {
  const _TrueFalseOptions(
      {required this.q, required this.isDark, required this.controller});
  final StudyQuestion q;
  final bool isDark;
  final AIQuestionsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedAnswer.value;
      // 0 = True, 1 = False
      final correctIndex = (q.correctBool ?? true) ? 0 : 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _TFButton(
                  label: 'True',
                  icon: Icons.check_rounded,
                  index: 0,
                  selected: selected,
                  correctIndex: correctIndex,
                  onTap: selected == null
                      ? () => controller.answerQuestion(0)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TFButton(
                  label: 'False',
                  icon: Icons.close_rounded,
                  index: 1,
                  selected: selected,
                  correctIndex: correctIndex,
                  onTap: selected == null
                      ? () => controller.answerQuestion(1)
                      : null,
                ),
              ),
            ],
          ),

          // Explanation after answering
          if (selected != null && q.explanation != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explanation',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Text(
                    q.explanation!,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),
          if (selected != null)
            _NextButton(
              label: controller.currentIndex.value <
                      controller.questions.length - 1
                  ? 'Next Question'
                  : 'See Results',
              onTap: controller.nextQuestion,
            ),
        ],
      );
    });
  }
}

class _TFButton extends StatelessWidget {
  const _TFButton({
    required this.label,
    required this.icon,
    required this.index,
    required this.selected,
    required this.correctIndex,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int index;
  final int? selected;
  final int correctIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (selected == null) {
      bg = Colors.white.withOpacity(0.07);
      fg = Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.black87;
    } else if (index == correctIndex) {
      bg = AppColors.success.withOpacity(0.15);
      fg = AppColors.success;
    } else if (index == selected) {
      bg = AppColors.error.withOpacity(0.15);
      fg = AppColors.error;
    } else {
      bg = Colors.white.withOpacity(0.04);
      fg = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: fg.withOpacity(0.3),
            width: selected != null && (index == correctIndex || index == selected) ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: fg)),
          ],
        ),
      ),
    );
  }
}

// MARK: - Open-ended Section

class _OpenEndedSection extends StatelessWidget {
  const _OpenEndedSection(
      {required this.q, required this.isDark, required this.controller});
  final StudyQuestion q;
  final bool isDark;
  final AIQuestionsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final revealed = controller.openEndedRevealed.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!revealed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Think about your answer, then tap "Reveal Answer" when ready.',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                    height: 1.5),
              ),
            ),
            const Spacer(),
            _NextButton(
              label: 'Reveal Answer',
              onTap: controller.revealOpenEnded,
              color: AppColors.reward,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.reward.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.reward.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expected Answer',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.reward)),
                  const SizedBox(height: 8),
                  Text(
                    q.expectedAnswer ?? '—',
                    style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Did you get it right?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selfMarkOpenEnded(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_up_rounded,
                                color: AppColors.success, size: 20),
                            SizedBox(width: 8),
                            Text('Got it',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selfMarkOpenEnded(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.25)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_down_rounded,
                                color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text('Missed it',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

// MARK: - Next / Action Button

class _NextButton extends StatelessWidget {
  const _NextButton(
      {required this.label, required this.onTap, this.color});
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color ?? AppColors.primary,
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// MARK: - Results Screen

class _ResultsScreen extends StatelessWidget {
  const _ResultsScreen(
      {required this.isDark, required this.controller});
  final bool isDark;
  final AIQuestionsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUnlock = controller.isUnlockSession.value;
      final correct = controller.correctCount.value;
      final total = controller.questions.length;
      final earned = controller.earnedMinutes;
      final perfect =
          !isUnlock && correct >= 5 && total == 5;

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle),
              child: Icon(
                isUnlock
                    ? Icons.lock_open_rounded
                    : Icons.emoji_events_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isUnlock ? 'Quiz Complete!' : '$correct / $total Correct',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              isUnlock
                  ? 'You unlocked 60 minutes of screen time!'
                  : 'You earned $earned minutes of screen time!',
              style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (perfect) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.reward.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('+5 bonus for perfect score!',
                    style: TextStyle(
                        color: AppColors.reward,
                        fontWeight: FontWeight.w600)),
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
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () async {
                  await controller.finishSession();
                  controller.reset();
                  Get.back();
                },
                child: const Text('Done',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            if (!isUnlock) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await controller.finishSession();
                  final subject = controller.currentSubject.value;
                  controller.reset();
                  await controller.startSession(subject);
                },
                child: Text('Study more',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45)),
              ),
            ],
          ],
        ),
      );
    });
  }
}
