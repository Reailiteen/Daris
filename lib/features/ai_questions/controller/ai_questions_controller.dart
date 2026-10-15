import 'package:get/get.dart';

import '../../../data/models/study_question.dart';
import '../../../data/models/wallet_models.dart';
import '../../../data/services/fireworks_service.dart';
import '../../balance/controller/balance_controller.dart';

class AIQuestionsController extends GetxController {
  AIQuestionsController({
    FireworksService? fireworksService,
    BalanceController? balanceController,
  }) : _fireworksService = fireworksService ?? Get.find<FireworksService>(),
       _balanceController = balanceController ?? Get.find<BalanceController>();

  final FireworksService _fireworksService;
  final BalanceController _balanceController;
  final RxList<StudyQuestion> questions = <StudyQuestion>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt correctCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool sessionComplete = false.obs;
  final RxnInt selectedAnswer = RxnInt();
  final RxString errorMessage = ''.obs;
  final Rxn<RewardResult> rewardResult = Rxn<RewardResult>();

  StudyQuestion? get currentQuestion => currentIndex.value < questions.length
      ? questions[currentIndex.value]
      : null;
  bool get answered => selectedAnswer.value != null;
  bool get answerIsCorrect =>
      selectedAnswer.value == currentQuestion?.correctIndex;

  Future<void> startCourseQuiz({
    required String courseName,
    String? textbookName,
    String? materialNotes,
  }) async {
    reset();
    isLoading.value = true;
    try {
      questions.assignAll(
        await _fireworksService.generateQuestions(
          courseName: courseName,
          textbookName: textbookName,
          materialNotes: materialNotes,
        ),
      );
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void answer(int index) {
    if (answered || currentQuestion == null) return;
    selectedAnswer.value = index;
    if (answerIsCorrect) correctCount.value++;
    // The question list is also observed by the page. Refresh it so a tap is
    // always reflected immediately, even when a route rebuild is pending.
    questions.refresh();
  }

  Future<void> next() async {
    if (!answered) return;
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      selectedAnswer.value = null;
      return;
    }
    sessionComplete.value = true;
    rewardResult.value = await _balanceController.award(
      source: RewardSource.quickStudy,
      minutes: correctCount.value,
    );
  }

  void reset() {
    questions.clear();
    currentIndex.value = 0;
    correctCount.value = 0;
    selectedAnswer.value = null;
    sessionComplete.value = false;
    rewardResult.value = null;
    errorMessage.value = '';
  }
}
