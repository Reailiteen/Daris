import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/study_task.dart';
import '../../../data/models/subject.dart';
import '../../../data/services/supabase_service.dart';
import '../../tasks/controller/tasks_controller.dart';

class SubjectsController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<Subject> subjects = <Subject>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    isLoading.value = true;
    try {
      final rows = await _supabaseService.getSubjects(user.id);
      subjects.assignAll(rows.map(Subject.fromMap));
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubject({
    required String name,
    String? syllabusBook,
    String? syllabusFilePath,
    String? materialNotes,
    DateTime? examDate,
    int numQuizzes = 0,
    int numAssignments = 0,
    int numMidterms = 0,
    int numFinals = 0,
    int numProjects = 0,
  }) async {
    final user = _supabaseService.currentUser;
    if (user == null || name.trim().isEmpty) return;

    try {
      final row = await _supabaseService.insertSubject(
        userId: user.id,
        name: name.trim(),
        syllabusBook: syllabusBook,
        syllabusFilePath: syllabusFilePath,
        materialNotes: materialNotes,
        examDate: examDate,
        numQuizzes: numQuizzes,
        numAssignments: numAssignments,
        numMidterms: numMidterms,
        numFinals: numFinals,
        numProjects: numProjects,
      );
      final subject = Subject.fromMap(row);
      subjects.add(subject);

      // Auto-create tasks for each semester component
      final tasksCtrl = Get.find<TasksController>();
      final n = name.trim();

      for (var i = 1; i <= numQuizzes; i++) {
        await tasksCtrl.addTask(
          'Quiz $i – $n',
          TaskDifficulty.small,
          subject.id,
        );
      }
      for (var i = 1; i <= numAssignments; i++) {
        await tasksCtrl.addTask(
          'Assignment $i – $n',
          TaskDifficulty.medium,
          subject.id,
        );
      }
      for (var i = 1; i <= numMidterms; i++) {
        final label = numMidterms > 1 ? 'Midterm $i' : 'Midterm';
        await tasksCtrl.addTask('$label – $n', TaskDifficulty.hard, subject.id);
      }
      for (var i = 1; i <= numFinals; i++) {
        final label = numFinals > 1 ? 'Final $i' : 'Final';
        await tasksCtrl.addTask('$label – $n', TaskDifficulty.hard, subject.id);
      }
      for (var i = 1; i <= numProjects; i++) {
        await tasksCtrl.addTask(
          'Project $i – $n',
          TaskDifficulty.hard,
          subject.id,
        );
      }
    } catch (_) {}
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _supabaseService.deleteSubject(subjectId);
      subjects.removeWhere((s) => s.id == subjectId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete subject. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> updateSubject({
    required Subject subject,
    required String name,
    String? syllabusBook,
    String? materialNotes,
  }) async {
    await _supabaseService.updateSubject(
      subjectId: subject.id,
      name: name.trim(),
      syllabusBook: syllabusBook?.trim(),
      materialNotes: materialNotes?.trim(),
    );
    final index = subjects.indexWhere((item) => item.id == subject.id);
    if (index >= 0) {
      subjects[index] = subject.copyWith(
        name: name.trim(),
        syllabusBook: syllabusBook?.trim(),
        materialNotes: materialNotes?.trim(),
      );
    }
  }
}
