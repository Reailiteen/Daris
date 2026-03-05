import 'package:get/get.dart';
import '../../../data/models/study_task.dart';
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
    } catch (_) {
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
    if (user == null || title.trim().isEmpty) return;
    try {
      final row = await _supabaseService.insertTask(
        userId: user.id,
        title: title.trim(),
        difficulty: difficulty.name,
        rewardMinutes: difficulty.rewardMinutes,
        subjectId: subjectId,
      );
      tasks.insert(0, StudyTask.fromMap(row));
    } catch (_) {}
  }

  Future<void> completeTask(String taskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = tasks[index];
    try {
      await _supabaseService.completeTask(taskId);
      tasks.removeAt(index);
      await _balanceController.addEarning('task', task.rewardMinutes);
      Get.snackbar(
        'Task Complete!',
        'You earned ${task.rewardMinutes} minutes of screen time.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (_) {}
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _supabaseService.deleteTask(taskId);
      tasks.removeWhere((t) => t.id == taskId);
    } catch (_) {}
  }
}
