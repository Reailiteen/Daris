import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../demo/controller/demo_mode_controller.dart';
import '../../subjects/controller/subjects_controller.dart';
import '../../subjects/view/course_editor_sheet.dart';
import '../controller/ai_questions_controller.dart';
import 'reward_result_view.dart';
import '../widgets/ai_question_generation_loader.dart';

class QuickStudyView extends StatefulWidget {
  const QuickStudyView({super.key, this.demo = false});
  final bool demo;
  @override
  State<QuickStudyView> createState() => _QuickStudyViewState();
}

class _QuickStudyViewState extends State<QuickStudyView> {
  String? selectedCourseId;
  @override
  Widget build(BuildContext context) {
    if (widget.demo) return _DemoQuiz();
    final controller = Get.find<AIQuestionsController>();
    final subjects = Get.find<SubjectsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Study')),
      body: Obx(() {
        if (controller.isLoading.value)
          return const AiQuestionGenerationLoader();
        if (controller.errorMessage.value.isNotEmpty)
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedCourseId == null
                        ? null
                        : () {
                            final s = subjects.subjects.firstWhere(
                              (x) => x.id == selectedCourseId,
                            );
                            controller.startCourseQuiz(
                              courseName: s.name,
                              textbookName: s.syllabusBook,
                              materialNotes: s.materialNotes,
                            );
                          },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        if (controller.questions.isEmpty)
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Choose a course',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your pasted course notes can guide the questions. Local PDFs are never sent.',
              ),
              const SizedBox(height: 18),
              ...subjects.subjects.map(
                (s) => RadioListTile<String>(
                  value: s.id,
                  groupValue: selectedCourseId,
                  onChanged: (value) =>
                      setState(() => selectedCourseId = value),
                  title: Text(s.name),
                  subtitle: Text(s.syllabusBook ?? 'No textbook listed'),
                  secondary: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit course material',
                    onPressed: () => showCourseEditor(context, subject: s),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedCourseId == null
                    ? null
                    : () {
                        final s = subjects.subjects.firstWhere(
                          (x) => x.id == selectedCourseId,
                        );
                        controller.startCourseQuiz(
                          courseName: s.name,
                          textbookName: s.syllabusBook,
                          materialNotes: s.materialNotes,
                        );
                      },
                child: const Text('Start 5-question challenge'),
              ),
            ],
          );
        if (controller.sessionComplete.value &&
            controller.rewardResult.value != null)
          return RewardResultView(result: controller.rewardResult.value!);
        final question = controller.currentQuestion!;
        return _QuestionBody(
          number: controller.currentIndex.value + 1,
          total: controller.questions.length,
          question: question.questionText,
          options: question.options,
          selected: controller.selectedAnswer.value,
          correct: question.correctIndex,
          explanation:
              question.explanation ??
              'Review the course material and try another challenge.',
          onSelect: (index) {
            controller.answer(index);
            setState(() {});
          },
          onNext: controller.next,
        );
      }),
    );
  }
}

class _DemoQuiz extends StatefulWidget {
  @override
  State<_DemoQuiz> createState() => _DemoQuizState();
}

class _DemoQuizState extends State<_DemoQuiz> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DemoModeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('CHEM101 Quick Study')),
      body: Obx(() {
        if (controller.quizComplete.value &&
            controller.rewardResult.value != null)
          return RewardResultView(
            result: controller.rewardResult.value!,
            demo: true,
          );
        final q = controller.currentQuestion;
        return _QuestionBody(
          number: controller.currentIndex.value + 1,
          total: controller.questions.length,
          question: q.questionText,
          options: q.options,
          selected: controller.selectedAnswer.value,
          correct: q.correctIndex,
          explanation: q.explanation ?? '',
          onSelect: (index) {
            controller.answer(index);
            setState(() {});
          },
          onNext: controller.next,
        );
      }),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.number,
    required this.total,
    required this.question,
    required this.options,
    required this.selected,
    required this.correct,
    required this.explanation,
    required this.onSelect,
    required this.onNext,
  });
  final int number;
  final int total;
  final String question;
  final List<String> options;
  final int? selected;
  final int correct;
  final String explanation;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onNext;
  @override
  Widget build(BuildContext c) {
    final answered = selected != null;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $number of $total',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            question,
            style: Theme.of(
              c,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          ...List.generate(options.length, (i) {
            final isSelected = i == selected;
            final color = !answered
                ? null
                : i == correct
                ? AppColors.success
                : isSelected
                ? AppColors.error
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: answered ? null : () => onSelect(i),
                style: OutlinedButton.styleFrom(
                  backgroundColor: color?.withValues(alpha: .12),
                  side: BorderSide(color: color ?? AppColors.divider),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(options[i]),
              ),
            );
          }),
          if (answered)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    (selected == correct ? AppColors.success : AppColors.error)
                        .withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selected == correct
                    ? 'Correct! $explanation'
                    : 'Not quite. $explanation',
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: answered ? onNext : null,
              child: Text(number == total ? 'See results' : 'Next question'),
            ),
          ),
        ],
      ),
    );
  }
}
