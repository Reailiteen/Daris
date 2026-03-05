import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/study_task.dart';
import '../../subjects/controller/subjects_controller.dart';
import '../controller/tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Study Tasks',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete tasks to earn screen time',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt,
                              size: 56,
                              color: isDark ? Colors.white24 : Colors.black26),
                          const SizedBox(height: 12),
                          Text(
                            'No pending tasks',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first task',
                            style: TextStyle(
                              color: isDark ? Colors.white24 : Colors.black26,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.tasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.tasks[index];
                      return _TaskCard(task: task, isDark: isDark);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context, isDark),
        backgroundColor: AppColors.accentPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, bool isDark) {
    final titleController = TextEditingController();
    final selectedDifficulty = TaskDifficulty.small.obs;
    final RxnString selectedSubjectId = RxnString();
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
              'Add Task',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Task title (e.g., Read Chapter 3)',
                hintStyle:
                    TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Difficulty',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: TaskDifficulty.values.map((d) {
                    final isSelected = selectedDifficulty.value == d;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => selectedDifficulty.value = d,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradient
                                : null,
                            color: isSelected
                                ? null
                                : (isDark
                                    ? Colors.white.withOpacity(0.07)
                                    : Colors.black.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                d.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                              Text(
                                '+${d.rewardMinutes}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.white70
                                      : (isDark
                                          ? Colors.white38
                                          : Colors.black45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            if (subjectsCtrl.subjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Subject (optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subjectsCtrl.subjects.map((s) {
                      final isSelected = selectedSubjectId.value == s.id;
                      return GestureDetector(
                        onTap: () => selectedSubjectId.value =
                            isSelected ? null : s.id,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradient
                                : null,
                            color: isSelected
                                ? null
                                : (isDark
                                    ? Colors.white.withOpacity(0.07)
                                    : Colors.black.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ],
            const SizedBox(height: 24),
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
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  controller.addTask(
                    title,
                    selectedDifficulty.value,
                    selectedSubjectId.value,
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Add Task',
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.isDark});

  final StudyTask task;
  final bool isDark;

  Color get _difficultyColor {
    switch (task.difficulty) {
      case TaskDifficulty.small:
        return AppColors.accentTeal;
      case TaskDifficulty.medium:
        return AppColors.accentOrange;
      case TaskDifficulty.hard:
        return AppColors.accentRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasksController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
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
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.difficulty.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _difficultyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${task.rewardMinutes}m',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ctrl.completeTask(task.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => ctrl.deleteTask(task.id),
            child: Icon(
              Icons.close,
              size: 18,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
