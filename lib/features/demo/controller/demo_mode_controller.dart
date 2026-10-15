import 'package:get/get.dart';
import '../../../data/models/study_question.dart';
import '../../../data/models/study_task.dart';
import '../../../data/models/wallet_models.dart';

/// Fully local: never resolves product controllers, Supabase, or Screen Time.
class DemoModeController extends GetxController {
  final RxInt availableMinutes = 5.obs;
  final RxList<StudyTask> tasks = <StudyTask>[].obs;
  final RxList<StudyQuestion> questions = <StudyQuestion>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt correctCount = 0.obs;
  final RxnInt selectedAnswer = RxnInt();
  final RxBool quizComplete = false.obs;
  final Rxn<RewardResult> rewardResult = Rxn<RewardResult>();
  @override
  void onInit() {
    super.onInit();
    reset();
  }

  void reset() {
    availableMinutes.value = 5;
    tasks.assignAll([
      StudyTask(
        id: 'chem101-lab',
        userId: 'demo',
        title: 'Balance the reaction worksheet',
        subjectId: 'CHEM101',
        difficulty: TaskDifficulty.small,
        rewardMinutes: 2,
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
    questions.assignAll(_questions());
    currentIndex.value = 0;
    correctCount.value = 0;
    selectedAnswer.value = null;
    quizComplete.value = false;
    rewardResult.value = null;
  }

  Future<RewardResult?> completeTask(StudyTask task) async {
    if (!tasks.remove(task)) return null;
    final result = RewardResult(
      previousBalance: availableMinutes.value,
      earnedMinutes: task.rewardMinutes,
      source: RewardSource.task,
    );
    availableMinutes.value = result.newBalance;
    return result;
  }

  void beginQuiz() {
    questions.assignAll(_questions());
    currentIndex.value = 0;
    correctCount.value = 0;
    selectedAnswer.value = null;
    quizComplete.value = false;
    rewardResult.value = null;
  }

  StudyQuestion get currentQuestion => questions[currentIndex.value];
  bool get answered => selectedAnswer.value != null;
  bool get answerIsCorrect =>
      selectedAnswer.value == currentQuestion.correctIndex;
  void answer(int index) {
    if (answered) return;
    selectedAnswer.value = index;
    if (answerIsCorrect) correctCount.value++;
    questions.refresh();
  }

  Future<void> next() async {
    if (!answered) return;
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      selectedAnswer.value = null;
      return;
    }
    final result = RewardResult(
      previousBalance: availableMinutes.value,
      earnedMinutes: correctCount.value,
      source: RewardSource.quickStudy,
    );
    availableMinutes.value = result.newBalance;
    rewardResult.value = result;
    quizComplete.value = true;
  }

  SpendResult? spendEntertainment() {
    const cost = 5;
    if (availableMinutes.value < cost) return null;
    final result = SpendResult(
      previousBalance: availableMinutes.value,
      spentMinutes: cost,
    );
    availableMinutes.value = result.remainingBalance;
    return result;
  }

  List<StudyQuestion> _questions() => const [
    StudyQuestion(
      id: 'demo-1',
      subject: 'CHEM101',
      questionText: 'What is the chemical symbol for sodium?',
      type: QuestionType.multipleChoice,
      options: ['So', 'Na', 'S', 'N'],
      correctIndex: 1,
      explanation: 'Na comes from natrium, the Latin name for sodium.',
    ),
    StudyQuestion(
      id: 'demo-2',
      subject: 'CHEM101',
      questionText: 'A solution with pH 3 is:',
      type: QuestionType.multipleChoice,
      options: ['Acidic', 'Neutral', 'Basic', 'A salt'],
      correctIndex: 0,
      explanation: 'A pH below 7 is acidic.',
    ),
    StudyQuestion(
      id: 'demo-3',
      subject: 'CHEM101',
      questionText: 'Which particle has a negative charge?',
      type: QuestionType.multipleChoice,
      options: ['Proton', 'Neutron', 'Electron', 'Nucleus'],
      correctIndex: 2,
      explanation: 'Electrons carry a negative elementary charge.',
    ),
  ];
}
