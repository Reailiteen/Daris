import 'package:get/get.dart';

import '../../../data/models/study_task.dart';
import '../../../data/models/wallet_models.dart';
import '../../../data/services/supabase_service.dart';
import '../../balance/controller/balance_controller.dart';

class TasksController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final BalanceController _balanceController = Get.find<BalanceController>();

  final RxList<StudyTask> tasks = <StudyTask>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    isLoading.value = true;
    try {
      final rows = await _supabaseService.getTasks(user.id);
      tasks.assignAll(rows.map(StudyTask.fromMap));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTask(
    String title,
    TaskDifficulty difficulty,
    String? subjectId,
  ) async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    final row = await _supabaseService.insertTask(
      userId: user.id,
      title: title.trim(),
      difficulty: difficulty.name,
      rewardMinutes: difficulty.rewardMinutes,
      subjectId: subjectId,
    );
    tasks.insert(0, StudyTask.fromMap(row));
  }

  /// Completes a task once and records its reward in the same database function.
  /// It never begins an unlock session.
  Future<RewardResult?> completeTask(String taskId) async {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) return null;
    final task = tasks[index];
    final previous = _balanceController.availableMinutes.value;
    final result = await _supabaseService.completeTaskAndRecordEarning(
      taskId: taskId,
      weekStart: BalanceController.sundayWeekStart(),
    );
    if (result == null) return null;
    tasks.removeAt(index);
    final earned =
        (result['reward_minutes'] as num?)?.toInt() ?? task.rewardMinutes;
    _balanceController.availableMinutes.value = previous + earned;
    return RewardResult(
      previousBalance: previous,
      earnedMinutes: earned,
      source: RewardSource.task,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _supabaseService.deleteTask(taskId);
    tasks.removeWhere((task) => task.id == taskId);
  }
}
