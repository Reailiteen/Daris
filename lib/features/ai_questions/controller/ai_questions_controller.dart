import 'package:get/get.dart';
import '../../../data/models/study_question.dart';
import '../../../data/services/groq_service.dart';
import '../../balance/controller/balance_controller.dart';

class AIQuestionsController extends GetxController {
  final GroqService _groqService = Get.find<GroqService>();
  final BalanceController _balanceController = Get.find<BalanceController>();

  final RxList<StudyQuestion> questions = <StudyQuestion>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt correctCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool sessionComplete = false.obs;
  final RxnInt selectedAnswer = RxnInt(); // null = not yet answered
  final RxString currentSubject = ''.obs;

  int get earnedMinutes {
    final base = correctCount.value * 2;
    final bonus = correctCount.value >= 5 ? 5 : 0;
    return base + bonus;
  }

  Future<void> startSession(String subject) async {
    currentSubject.value = subject;
    isLoading.value = true;
    questions.clear();
    currentIndex.value = 0;
    correctCount.value = 0;
    sessionComplete.value = false;
    selectedAnswer.value = null;
    try {
      final generated = await _groqService.generateQuestions(subject, count: 5);
      questions.assignAll(generated);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not load questions. Check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void answerQuestion(int selectedIndex) {
    if (selectedAnswer.value != null) return; // already answered
    selectedAnswer.value = selectedIndex;

    final q = questions[currentIndex.value];
    if (selectedIndex == q.correctIndex) {
      correctCount.value++;
    }
  }

  void nextQuestion() {
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
    currentIndex.value = 0;
    correctCount.value = 0;
    sessionComplete.value = false;
    selectedAnswer.value = null;
    currentSubject.value = '';
  }
}
