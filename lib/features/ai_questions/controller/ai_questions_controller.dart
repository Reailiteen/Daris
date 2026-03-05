import 'package:get/get.dart';
import '../../../data/models/study_question.dart';
import '../../../data/services/groq_service.dart';
import '../../balance/controller/balance_controller.dart';
import '../../subjects/controller/subjects_controller.dart';

class AIQuestionsController extends GetxController {
  final GroqService _groqService = Get.find<GroqService>();
  final BalanceController _balanceController = Get.find<BalanceController>();

  final RxList<StudyQuestion> questions = <StudyQuestion>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt correctCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool sessionComplete = false.obs;
  final RxBool isUnlockSession = false.obs;

  // MCQ / T/F: index of tapped option (null = not yet answered)
  final RxnInt selectedAnswer = RxnInt();

  // Open-ended: whether the user has revealed the expected answer
  final RxBool openEndedRevealed = false.obs;

  final RxString currentSubject = ''.obs;

  int get earnedMinutes {
    if (isUnlockSession.value) return 60;
    final base = correctCount.value * 2;
    final bonus = correctCount.value >= 5 ? 5 : 0;
    return base + bonus;
  }

  // Per-subject MCQ quiz
  Future<void> startSession(String subject, {String? syllabusBook}) async {
    isUnlockSession.value = false;
    currentSubject.value = subject;
    _resetState();
    isLoading.value = true;
    try {
      final generated = await _groqService.generateQuestions(
        subject,
        syllabusBook: syllabusBook,
        count: 5,
      );
      questions.assignAll(generated);
    } catch (_) {
      Get.snackbar('Error', 'Could not load questions. Check your internet.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Unlock 1 hour: 10 mixed questions from all subjects
  Future<void> startUnlockSession() async {
    isUnlockSession.value = true;
    currentSubject.value = 'All Subjects';
    _resetState();
    isLoading.value = true;
    try {
      final subjectsCtrl = Get.find<SubjectsController>();
      final descriptions = subjectsCtrl.subjects.map((s) {
        final book = (s.syllabusBook ?? '').isNotEmpty ? ' (${s.syllabusBook})' : '';
        return '${s.name}$book';
      }).toList();

      if (descriptions.isEmpty) {
        Get.snackbar('No Subjects', 'Add subjects first to unlock screen time.',
            snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }

      final generated = await _groqService.generateMixedQuestions(
        subjectDescriptions: descriptions,
        count: 10,
      );
      questions.assignAll(generated);
    } catch (_) {
      Get.snackbar('Error', 'Could not load questions. Check your internet.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // MCQ / T/F answer
  void answerQuestion(int selectedIndex) {
    if (selectedAnswer.value != null) return;
    selectedAnswer.value = selectedIndex;

    final q = questions[currentIndex.value];
    if (q.type == QuestionType.multipleChoice) {
      if (selectedIndex == q.correctIndex) correctCount.value++;
    } else if (q.type == QuestionType.trueOrFalse) {
      final pickedTrue = selectedIndex == 0;
      if (pickedTrue == q.correctBool) correctCount.value++;
    }
  }

  // Open-ended: reveal the expected answer
  void revealOpenEnded() {
    openEndedRevealed.value = true;
  }

  // Open-ended: user self-marks after reading the expected answer
  void selfMarkOpenEnded(bool gotIt) {
    if (gotIt) correctCount.value++;
    _advance();
  }

  void nextQuestion() => _advance();

  void _advance() {
    openEndedRevealed.value = false;
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      selectedAnswer.value = null;
    } else {
      sessionComplete.value = true;
    }
  }

  Future<void> finishSession() async {
    final minutes = earnedMinutes;
    if (minutes > 0) {
      await _balanceController.addEarning('ai_question', minutes);
    }
  }

  void reset() {
    questions.clear();
    _resetState();
    isUnlockSession.value = false;
    currentSubject.value = '';
  }

  void _resetState() {
    questions.clear();
    currentIndex.value = 0;
    correctCount.value = 0;
    sessionComplete.value = false;
    selectedAnswer.value = null;
    openEndedRevealed.value = false;
  }
}
